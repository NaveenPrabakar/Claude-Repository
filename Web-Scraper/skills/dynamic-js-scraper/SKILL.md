---
name: dynamic-js-scraper
description: >
  Use this skill when the target page renders content via JavaScript (infinite
  scroll, "click to load more", single-page apps, content that's empty in raw
  HTML but visible in a browser). Trigger on phrases like "scrape this site but
  the data isn't in the page source", "this is a React/Vue site I need to scrape",
  "scrape after clicking a button", "scroll and collect all results", "the table
  loads dynamically". Provides an R implementation (RSelenium) and Python
  implementations (Selenium and Playwright).
---

# Dynamic (JavaScript-Rendered) Scraper

Scrape pages where content is injected by JavaScript after initial load. This
requires driving a real (or headless) browser rather than just fetching raw HTML.

## Workflow

1. **Confirm it's actually needed first.** Fetch the raw HTML (e.g. with
   `curl` or `httr::GET`) and check whether the data is already present but
   just styled oddly — dynamic scraping is slower and more fragile than static
   scraping, so only reach for it when static scraping genuinely returns empty
   or incomplete content.
2. **Pick a driver.** Python defaults to Playwright (faster, more reliable,
   auto-waits for elements) unless the user's project already uses Selenium.
   R has one practical option: RSelenium.
3. **Wait for elements explicitly** rather than using fixed `sleep()` calls
   wherever possible — explicit waits are far less flaky.
4. **Always run headless** for scraping tasks unless the user needs to watch
   the browser to debug a selector.
5. **Close the browser/driver in a `finally`/`on.exit()` block** so failed
   runs don't leave orphan browser processes.

## Python Implementation (Playwright — preferred)

```python
from playwright.sync_api import sync_playwright
import pandas as pd

def scrape_dynamic(url):
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(user_agent="Mozilla/5.0 (compatible; ResearchBot/1.0)")
        page.goto(url, wait_until="networkidle")

        # Wait for the specific content to appear
        page.wait_for_selector(".product-card", timeout=10000)

        # Optional: handle infinite scroll
        prev_count = 0
        for _ in range(20):  # cap the number of scroll attempts
            cards = page.query_selector_all(".product-card")
            if len(cards) == prev_count:
                break
            prev_count = len(cards)
            page.mouse.wheel(0, 3000)
            page.wait_for_timeout(1000)

        rows = []
        for card in page.query_selector_all(".product-card"):
            title = card.query_selector(".product-title")
            price = card.query_selector(".price")
            rows.append({
                "title": title.inner_text() if title else None,
                "price": price.inner_text() if price else None,
            })

        browser.close()
        return rows

data = scrape_dynamic("https://example.com/spa-products")
pd.DataFrame(data).to_csv("scraped_dynamic.csv", index=False)
```

Install: `pip install playwright && playwright install chromium`

### Handling "click to load more"

```python
while page.query_selector("button.load-more"):
    page.click("button.load-more")
    page.wait_for_timeout(1200)
```

## Python Implementation (Selenium — fallback)

```python
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options

options = Options()
options.add_argument("--headless=new")
options.add_argument("user-agent=Mozilla/5.0 (compatible; ResearchBot/1.0)")

driver = webdriver.Chrome(options=options)
try:
    driver.get("https://example.com/spa-products")
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, ".product-card"))
    )
    cards = driver.find_elements(By.CSS_SELECTOR, ".product-card")
    rows = [{"title": c.find_element(By.CSS_SELECTOR, ".product-title").text} for c in cards]
finally:
    driver.quit()
```

## R Implementation (RSelenium)

```r
library(RSelenium)
library(dplyr)

rD <- rsDriver(browser = "chrome", chromever = "latest", headless = TRUE)
remDr <- rD$client

tryCatch({
  remDr$navigate("https://example.com/spa-products")

  # Explicit wait for content to appear
  wait_for_element <- function(css, timeout = 10) {
    for (i in 1:(timeout * 2)) {
      els <- remDr$findElements("css selector", css)
      if (length(els) > 0) return(els)
      Sys.sleep(0.5)
    }
    stop("Element not found: ", css)
  }

  cards <- wait_for_element(".product-card")

  results <- purrr::map_dfr(cards, function(card) {
    tibble(
      title = tryCatch(card$findChildElement("css selector", ".product-title")$getElementText()[[1]],
                        error = function(e) NA_character_),
      price = tryCatch(card$findChildElement("css selector", ".price")$getElementText()[[1]],
                        error = function(e) NA_character_)
    )
  })

  write.csv(results, "scraped_dynamic.csv", row.names = FALSE)
}, finally = {
  remDr$close()
  rD$server$stop()
})
```

Requires a running Chrome/Chromedriver — `rsDriver()` manages this
automatically via the `wdman` package but needs Java installed locally.

## Practical guidance

- **Playwright > Selenium for new Python work** — better auto-waiting, faster,
  fewer flaky failures.
- **RSelenium is the only mature R option** for this; if the user is R-first
  but the site is heavily dynamic, it's reasonable to suggest a Python
  Playwright script as a companion utility even in an R-primary project.
- Infinite scroll and "load more" patterns need a loop with a hard cap on
  iterations — never loop unbounded on live sites.
- If a site uses aggressive anti-bot detection (CAPTCHAs, browser
  fingerprinting challenges), stop and flag this to the user rather than
  attempting to circumvent it — see `scraping-compliance-check`.

## When NOT to use this skill

- If raw HTML already contains the data → use `static-html-scraper` (much faster).
- If the site has a public/documented API powering the same data (check the
  Network tab for XHR/fetch calls) → use `api-data-scraper` instead; it's
  more stable and far less likely to break.
