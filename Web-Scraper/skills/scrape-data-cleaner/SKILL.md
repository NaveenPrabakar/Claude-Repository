---
name: scrape-data-cleaner
description: >
  Use this skill after raw data has been scraped, to clean, deduplicate,
  normalize, and export it into an analysis-ready format. Trigger on phrases
  like "clean up this scraped data", "dedupe these results", "the prices
  have dollar signs and commas in them", "normalize these dates", "export
  this to a database/Excel/JSON", "combine these scraped CSVs". Provides an
  R implementation (dplyr/tidyr/janitor) and a Python implementation (pandas).
---

# Scrape Data Cleaner & Exporter

Raw scraped data is messy by default: inconsistent whitespace, currency
symbols mixed into numeric fields, duplicate rows from overlapping pagination,
inconsistent date formats, and missing values represented differently across
sources. Clean before analysis or storage.

## Workflow

1. **Inspect first** — print column types, `NA`/missing counts, and a sample
   of raw values before writing cleaning logic. Don't assume the format.
2. **Standardize types** — strip currency symbols/commas from numbers, parse
   dates into a consistent format, trim whitespace from strings.
3. **Deduplicate** — scraped data from paginated or retried requests often
   has exact or near-duplicate rows; dedupe on a natural key (URL, ID) rather
   than the whole row when possible.
4. **Handle missing values explicitly** — decide per-column whether missing
   means "drop row", "fill with default", or "leave as NA" — don't silently
   drop rows with any missing field unless that's actually correct.
5. **Validate before export** — sanity-check row counts and a few spot values
   against the source page.
6. **Export to the format the user needs** — CSV for portability, JSON for
   nested data, Excel for stakeholders, or directly to a database.

## R Implementation (dplyr/tidyr/janitor)

```r
library(dplyr)
library(tidyr)
library(janitor)
library(stringr)
library(lubridate)

raw <- read.csv("scraped_products.csv", stringsAsFactors = FALSE)

clean <- raw %>%
  clean_names() %>%                                   # standardize column names
  distinct(link, .keep_all = TRUE) %>%                 # dedupe on natural key
  mutate(
    price = as.numeric(str_remove_all(price, "[$,]")),
    title = str_squish(title),                         # collapse whitespace
    scraped_date = as_date(scraped_date, format = "%Y-%m-%d")
  ) %>%
  filter(!is.na(price)) %>%                             # drop rows with unusable price
  arrange(desc(price))

# Report what was cleaned
cat("Rows before:", nrow(raw), " | after:", nrow(clean), "\n")
cat("Removed", nrow(raw) - nrow(clean), "duplicate/invalid rows\n")

write.csv(clean, "cleaned_products.csv", row.names = FALSE)
```

### Export options

```r
# Excel
writexl::write_xlsx(clean, "cleaned_products.xlsx")

# JSON
jsonlite::write_json(clean, "cleaned_products.json", pretty = TRUE)

# SQLite database
con <- DBI::dbConnect(RSQLite::SQLite(), "scraped_data.db")
DBI::dbWriteTable(con, "products", clean, overwrite = TRUE)
DBI::dbDisconnect(con)
```

## Python Implementation (pandas)

```python
import pandas as pd
import re

raw = pd.read_csv("scraped_products.csv")

def clean_price(val):
    if pd.isna(val):
        return None
    return float(re.sub(r"[$,]", "", str(val)))

clean = (
    raw
    .drop_duplicates(subset="link")
    .assign(
        price=lambda df: df["price"].apply(clean_price),
        title=lambda df: df["title"].str.strip().str.replace(r"\s+", " ", regex=True),
        scraped_date=lambda df: pd.to_datetime(df["scraped_date"], errors="coerce"),
    )
    .dropna(subset=["price"])
    .sort_values("price", ascending=False)
)

print(f"Rows before: {len(raw)} | after: {len(clean)}")
print(f"Removed {len(raw) - len(clean)} duplicate/invalid rows")

clean.to_csv("cleaned_products.csv", index=False)
```

### Export options

```python
# Excel
clean.to_excel("cleaned_products.xlsx", index=False)

# JSON
clean.to_json("cleaned_products.json", orient="records", indent=2)

# SQLite database
import sqlite3
con = sqlite3.connect("scraped_data.db")
clean.to_sql("products", con, if_exists="replace", index=False)
con.close()
```

## Merging multiple scrape runs

```r
# R: combine and dedupe across multiple CSVs from repeated scrape runs
library(purrr)
files <- list.files("scrapes/", pattern = "*.csv", full.names = TRUE)
combined <- map_dfr(files, read.csv) %>% distinct(link, .keep_all = TRUE)
```

```python
# Python equivalent
import glob
files = glob.glob("scrapes/*.csv")
combined = pd.concat([pd.read_csv(f) for f in files]).drop_duplicates(subset="link")
```

## Common gotchas

- Currency strings often mix formats across regions (`$1,000.00` vs `1.000,00`) —
  check locale before blanket regex.
- Dates scraped from relative text ("2 days ago") need conversion to absolute
  dates at scrape time, since they become stale otherwise.
- Encoding issues (mangled non-ASCII characters) usually mean the source page
  wasn't decoded as UTF-8 — fix at the fetch stage, not the cleaning stage.
