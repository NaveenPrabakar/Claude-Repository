---
name: api-data-scraper
description: >
  Use this skill when data can be pulled from a REST/JSON API instead of
  parsing HTML — either a documented public API, or an undocumented internal
  API discovered via browser devtools Network tab (XHR/fetch calls). Trigger
  on phrases like "pull data from this API", "this site has a JSON endpoint",
  "paginate through this API and collect all results", "I found the XHR call
  the site uses". Provides an R implementation (httr2) and a Python
  implementation (requests), covering auth, pagination, and rate limiting.
---

# API Data Scraper

Extracting data via a REST/JSON API is almost always preferable to HTML
scraping — it's faster, returns structured data with no parsing guesswork,
and is far less likely to break when the site's front-end changes.

## Workflow

1. **Find the endpoint.** If undocumented, open browser devtools → Network
   tab → filter by XHR/Fetch → reload the page or trigger the action → find
   the request returning the JSON you need. Note the URL, method, headers,
   and any query params.
2. **Check for a documented API first** — search `<site> API docs` before
   reverse-engineering an internal endpoint; documented APIs are more stable
   and explicitly intended for external use.
3. **Identify auth requirements** — API key in header/query param, bearer
   token, or none. Never hardcode credentials in scripts; use environment
   variables.
4. **Handle pagination** — look for `page`/`offset`/`cursor` params or a
   `next` link in the response, and loop until the response signals no more
   data.
5. **Respect rate limits** — check response headers like `X-RateLimit-Remaining`
   or documented limits, and add backoff on `429` responses.

## R Implementation (httr2)

```r
library(httr2)
library(dplyr)
library(purrr)

fetch_page <- function(page_num, api_key = Sys.getenv("API_KEY")) {
  req <- request("https://api.example.com/v1/items") %>%
    req_headers(Authorization = paste("Bearer", api_key)) %>%
    req_url_query(page = page_num, per_page = 100) %>%
    req_retry(max_tries = 3, backoff = ~ 2 ^ .x) %>%
    req_throttle(rate = 60 / 60)  # 60 requests per minute

  resp <- req_perform(req)
  resp_body_json(resp)
}

all_items <- list()
page <- 1
repeat {
  result <- fetch_page(page)
  if (length(result$items) == 0) break
  all_items <- c(all_items, result$items)
  if (isFALSE(result$has_more)) break
  page <- page + 1
}

df <- map_dfr(all_items, as_tibble)
write.csv(df, "api_data.csv", row.names = FALSE)
```

### Handling cursor-based pagination

```r
fetch_all_cursor <- function(base_url, api_key) {
  results <- list()
  cursor <- NULL
  repeat {
    req <- request(base_url) %>%
      req_headers(Authorization = paste("Bearer", api_key)) %>%
      req_url_query(cursor = cursor)
    resp <- req_perform(req) %>% resp_body_json()
    results <- c(results, resp$data)
    cursor <- resp$next_cursor
    if (is.null(cursor)) break
  }
  results
}
```

## Python Implementation (requests)

```python
import requests
import pandas as pd
import os
import time

API_KEY = os.environ.get("API_KEY")
BASE_URL = "https://api.example.com/v1/items"

def fetch_page(page_num, session):
    resp = session.get(
        BASE_URL,
        headers={"Authorization": f"Bearer {API_KEY}"},
        params={"page": page_num, "per_page": 100},
        timeout=10,
    )
    if resp.status_code == 429:
        retry_after = int(resp.headers.get("Retry-After", 5))
        time.sleep(retry_after)
        return fetch_page(page_num, session)
    resp.raise_for_status()
    return resp.json()

all_items = []
with requests.Session() as session:
    page = 1
    while True:
        data = fetch_page(page, session)
        items = data.get("items", [])
        if not items:
            break
        all_items.extend(items)
        if not data.get("has_more"):
            break
        page += 1
        time.sleep(0.5)  # basic throttling

df = pd.DataFrame(all_items)
df.to_csv("api_data.csv", index=False)
```

### Handling cursor-based pagination

```python
def fetch_all_cursor(base_url, headers):
    results = []
    cursor = None
    while True:
        resp = requests.get(base_url, headers=headers, params={"cursor": cursor})
        resp.raise_for_status()
        data = resp.json()
        results.extend(data["data"])
        cursor = data.get("next_cursor")
        if not cursor:
            break
    return results
```

## Discovering undocumented endpoints responsibly

- Only use endpoints that are already served to any visitor's browser via
  normal page interaction — this is the same data a browser receives, just
  accessed directly instead of parsed out of rendered HTML.
- Don't attempt to access endpoints that require bypassing auth you don't
  have, guessing internal IDs outside your own account, or that return data
  clearly scoped to other users.
- Prefer official/documented APIs whenever they exist, even if an
  undocumented one looks more convenient — documented APIs come with terms
  of service that make usage expectations explicit.

## When NOT to use this skill

- If there's genuinely no API backing the data (fully server-rendered,
  static site) → use `static-html-scraper`.
- If data only loads via complex client-side rendering with no discoverable
  network calls → use `dynamic-js-scraper`.
