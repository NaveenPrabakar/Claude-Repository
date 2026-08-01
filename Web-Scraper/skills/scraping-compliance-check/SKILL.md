---
name: scraping-compliance-check
description: >
  Use this skill before writing or running any scraper against a real site,
  or when the user asks "am I allowed to scrape this", "check robots.txt",
  "is this scraping legal", "how do I scrape politely", "what's the rate
  limit for this site". Also trigger proactively whenever another scraping
  skill in this plugin is about to hit a live external site for the first
  time in a conversation. Covers robots.txt checking, rate limiting, ToS
  considerations, and identifying yourself properly to servers.
---

# Scraping Compliance & Etiquette Check

Before scraping any real site, check what's allowed and scrape responsibly.
This isn't a legal opinion — it's a practical checklist to reduce risk and
avoid harming the target site.

## Checklist to run before scraping a new site

1. **Check `robots.txt`** at `https://<domain>/robots.txt` for `Disallow`
   rules and any `Crawl-delay` directive.
2. **Check the Terms of Service** for an explicit scraping/automated-access
   clause, if the user's use case is commercial or high-volume.
3. **Prefer the official API** if one exists — see `api-data-scraper`.
4. **Scrape only publicly accessible pages** — never attempt to bypass a
   login, paywall, or CAPTCHA to reach content that isn't otherwise public.
5. **Rate-limit requests** — space requests out, keep concurrency low, and
   scrape during off-peak hours for large jobs.
6. **Identify the client honestly** with a descriptive `User-Agent`, rather
   than spoofing a browser to evade detection.
7. **Cache results** rather than re-scraping the same pages repeatedly.
8. **Respect personal data carefully** — scraping personal information
   (names, emails, contact info) carries additional privacy obligations
   (e.g. GDPR/CCPA) beyond general scraping etiquette; flag this to the user
   if the target data includes personal information about private individuals.

## Checking robots.txt programmatically

### R

```r
library(httr)
library(stringr)

check_robots <- function(domain, path = "/") {
  robots_url <- paste0("https://", domain, "/robots.txt")
  resp <- tryCatch(GET(robots_url), error = function(e) NULL)
  if (is.null(resp) || status_code(resp) != 200) {
    message("No robots.txt found or unreachable — proceed cautiously")
    return(invisible(NULL))
  }
  txt <- content(resp, as = "text", encoding = "UTF-8")
  cat(txt)
  # crude relevant-rule check
  lines <- str_split(txt, "\n")[[1]]
  disallowed <- lines[str_detect(lines, "^Disallow:")]
  crawl_delay <- lines[str_detect(lines, "^Crawl-delay:")]
  list(disallowed = disallowed, crawl_delay = crawl_delay)
}

check_robots("example.com")
```

Or use the dedicated package: `robotstxt::get_robotstxt("example.com")` and
`robotstxt::paths_allowed("https://example.com/some-path")`.

### Python

```python
from urllib.robotparser import RobotFileParser

def check_robots(domain, target_path, user_agent="ResearchBot"):
    rp = RobotFileParser()
    rp.set_url(f"https://{domain}/robots.txt")
    rp.read()
    allowed = rp.can_fetch(user_agent, f"https://{domain}{target_path}")
    delay = rp.crawl_delay(user_agent)
    print(f"Allowed: {allowed} | Crawl-delay: {delay}")
    return allowed, delay

check_robots("example.com", "/products")
```

## Rate limiting patterns

### R — simple throttle

```r
polite_fetch <- function(urls, delay = 2) {
  purrr::map(urls, function(u) {
    Sys.sleep(delay)
    httr::GET(u, httr::user_agent("Mozilla/5.0 (compatible; ResearchBot/1.0; +contact@example.com)"))
  })
}
```

### Python — simple throttle with jitter

```python
import time, random

def polite_fetch(urls, base_delay=2):
    results = []
    for u in urls:
        time.sleep(base_delay + random.uniform(0, 1))  # jitter avoids lockstep patterns
        results.append(requests.get(u, headers={"User-Agent": "ResearchBot/1.0 (+contact@example.com)"}))
    return results
```

## What to flag to the user, not just proceed silently on

- `robots.txt` explicitly disallows the target path — surface this and ask
  how they want to proceed rather than scraping anyway.
- The target requires login/paywall bypass to reach the data.
- The data is personal information about private individuals at any volume.
- The intended use is clearly commercial resale of scraped data, where ToS
  often has specific restrictions worth reading first.
- The site is returning noticeably different content to automated requests
  than browsers, suggesting active anti-bot measures — treat that as a signal
  to slow down or reconsider, not a puzzle to defeat.

## What this skill does NOT do

This is a practical courtesy/risk checklist, not legal advice. For anything
with real legal exposure (commercial scraping at scale, scraping behind
authentication, competitive intelligence use cases), suggest the user
consult a lawyer familiar with their jurisdiction rather than treating this
checklist as a compliance sign-off.
