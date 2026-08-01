# Web Scraper Toolkit

A diverse web scraping plugin covering the full workflow from raw HTML to
clean, exported data — with working R and Python implementations side by side
for every technique.

## Skills

| Skill | Use it for | Languages |
|---|---|---|
| `static-html-scraper` | Server-rendered pages — listings, tables, articles | R (rvest/httr), Python (requests/BeautifulSoup) |
| `dynamic-js-scraper` | JS-rendered SPAs, infinite scroll, click-to-load | R (RSelenium), Python (Playwright, Selenium) |
| `api-data-scraper` | Documented or discoverable JSON/REST endpoints | R (httr2), Python (requests) |
| `scrape-data-cleaner` | Cleaning, deduping, normalizing, exporting scraped data | R (dplyr/tidyr/janitor), Python (pandas) |
| `scraping-compliance-check` | robots.txt, rate limiting, scraping etiquette | R (robotstxt/httr), Python (urllib.robotparser) |

## Typical workflow

1. **Check compliance first** (`scraping-compliance-check`) — confirm
   robots.txt allows the target path and plan a polite rate limit.
2. **Pick the right scraping approach**:
   - Data visible in page source → `static-html-scraper`
   - Data only appears after JS runs → `dynamic-js-scraper`
   - A JSON API backs the page (check Network tab) → `api-data-scraper`
     (prefer this over the other two when available — it's the most stable)
3. **Clean and export** (`scrape-data-cleaner`) — dedupe, normalize types,
   ship to CSV/Excel/JSON/SQLite.

## Why R and Python side by side

Both ecosystems are genuinely good at this, with different strengths:
- **R (rvest/httr2)** — very fast to write for one-off scrapes, pipes well
  into `dplyr` cleaning, natural fit if the downstream analysis is already
  in R.
- **Python (BeautifulSoup/Playwright/requests)** — broader library ecosystem
  for dynamic scraping (Playwright is genuinely stronger than any R option
  for JS-heavy sites), better fit for production pipelines.

Each skill defaults to R when the user hasn't specified a stack, since R
is often faster to prototype a scrape in — but always follows an explicit
language preference if the user states one.

## Requirements

**R**: `rvest`, `httr`, `httr2`, `dplyr`, `purrr`, `tidyr`, `janitor`,
`stringr`, `lubridate`, `RSelenium` (dynamic scraping only), `robotstxt`,
`jsonlite`, `writexl`, `DBI`/`RSQLite` (for DB export)

**Python**: `requests`, `beautifulsoup4`, `pandas`, `playwright` (+
`playwright install chromium`), `selenium` (optional fallback)

## Responsible use

This plugin includes a dedicated compliance-check skill and every scraper
example sets a descriptive User-Agent and includes rate limiting by default.
It does not include any anti-detection, CAPTCHA-bypass, or credential-bypass
techniques, and the compliance skill actively flags cases (paywalled content,
personal data, disallowed paths) where the user should pause and reconsider
before proceeding.
