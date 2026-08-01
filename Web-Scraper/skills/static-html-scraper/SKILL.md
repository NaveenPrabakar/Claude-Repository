---
name: static-html-scraper
description: >
  Use this skill when scraping static HTML pages that don't require JavaScript
  rendering — product listings, news articles, tables, directories, blog archives.
  Trigger on phrases like "scrape this page", "pull the table from this site",
  "extract product prices from this URL", "grab all the links/headlines from",
  "parse this HTML for me". Provides both an R implementation (rvest + httr)
  and a Python implementation (requests + BeautifulSoup) — pick based on the
  user's stack, or default to R when the user has not specified.
---

# Static HTML Scraper

Scrape static (server-rendered) HTML using CSS selectors or XPath. Two equivalent
implementations are provided: R (rvest/httr) and Python (requests/BeautifulSoup).
Default to R unless the user's project is clearly Python-based — R's pipe-based
`rvest` syntax is often faster to write for one-off scrapes.

## Workflow

1. **Inspect the target page structure first.** Fetch the raw HTML and look at
   the actual tag/class names before writing selectors — do not guess selectors
   from memory of "typical" site layouts.
2. **Identify the right selector strategy.** Prefer stable attributes (`id`,
   `data-*` attributes, semantic tags) over auto-generated CSS classes (e.g.
   `css-1x2y3z`) which change on every deploy.
3. **Write the scraper as a script**, not inline one-liners, so it's reusable
   and the user can rerun it if the page changes.
4. **Respect rate limits and identify the client.** Always set a descriptive
   `User-Agent` and add a delay between requests when scraping multiple pages.
   Check `scraping-compliance-check` skill before scraping at any volume.
5. **Handle missing elements gracefully.** Real pages have inconsistent
   markup — wrap extraction in checks so one missing element doesn't crash
   the whole scrape.

## R Implementation (rvest + httr)

```r
library(rvest)
library(httr)
library(dplyr)
library(purrr)

scrape_page <- function(url) {
  resp <- GET(url, user_agent("Mozilla/5.0 (compatible; ResearchBot/1.0)"))
  stop_for_status(resp)
  page <- read_html(resp)

  # Example: scrape a product listing
  items <- page %>% html_elements(".product-card")

  tibble(
    title = items %>% html_element(".product-title") %>% html_text2(),
    price = items %>% html_element(".price") %>% html_text2(),
    link  = items %>% html_element("a") %>% html_attr("href")
  )
}

# Scrape multiple pages with a polite delay
urls <- paste0("https://example.com/products?page=", 1:5)
results <- map_dfr(urls, function(u) {
  Sys.sleep(1.5)  # be polite
  scrape_page(u)
})

write.csv(results, "scraped_products.csv", row.names = FALSE)
```

### Extracting tables directly

```r
library(rvest)

page <- read_html("https://example.com/data-table")
tables <- html_table(page, fill = TRUE)
df <- tables[[1]]  # first table on the page
```

### Common rvest selector patterns

| Goal | Code |
|---|---|
| All links | `html_elements(page, "a") %>% html_attr("href")` |
| Text of one element | `html_element(page, "h1") %>% html_text2()` |
| Attribute value | `html_element(page, "img") %>% html_attr("src")` |
| Nested selector | `html_elements(page, ".card .title")` |
| By XPath | `html_elements(page, xpath = "//div[@class='card']")` |

## Python Implementation (requests + BeautifulSoup)

```python
import requests
from bs4 import BeautifulSoup
import pandas as pd
import time

HEADERS = {"User-Agent": "Mozilla/5.0 (compatible; ResearchBot/1.0)"}

def scrape_page(url):
    resp = requests.get(url, headers=HEADERS, timeout=10)
    resp.raise_for_status()
    soup = BeautifulSoup(resp.text, "html.parser")

    rows = []
    for card in soup.select(".product-card"):
        title_el = card.select_one(".product-title")
        price_el = card.select_one(".price")
        link_el = card.select_one("a")
        rows.append({
            "title": title_el.get_text(strip=True) if title_el else None,
            "price": price_el.get_text(strip=True) if price_el else None,
            "link": link_el["href"] if link_el else None,
        })
    return rows

all_rows = []
for page_num in range(1, 6):
    url = f"https://example.com/products?page={page_num}"
    all_rows.extend(scrape_page(url))
    time.sleep(1.5)  # be polite

df = pd.DataFrame(all_rows)
df.to_csv("scraped_products.csv", index=False)
```

### Extracting tables directly

```python
import pandas as pd
tables = pd.read_html("https://example.com/data-table")
df = tables[0]
```

## Choosing selectors — practical tips

- View source or use browser devtools; don't assume markup.
- Prefer `html_text2()` (R) / `.get_text(strip=True)` (Python) over raw text
  to auto-collapse whitespace.
- If a site returns different HTML to scripts than to browsers (common
  anti-bot measure), that's a signal to check `scraping-compliance-check`
  and consider the `dynamic-js-scraper` skill instead — it may mean the
  content is JS-rendered.
- For paginated sites, look for a predictable URL pattern (`?page=N`) before
  resorting to clicking "next" (which requires the dynamic scraper).

## When NOT to use this skill

- If content only appears after JavaScript executes (empty `<div id="root">`
  in raw HTML) → use `dynamic-js-scraper` instead.
- If the site exposes a documented API → use `api-data-scraper` instead;
  APIs are more stable and lower-risk than scraping rendered HTML.
