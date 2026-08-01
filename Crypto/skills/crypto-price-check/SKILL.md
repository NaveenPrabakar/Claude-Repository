---
name: crypto-price-check
description: Fast current-price and quick-stat lookups for one or more cryptocurrencies using the CoinGecko free API. Use this whenever the user asks "what's the price of X", wants current prices for a coin or list of coins, asks about 24h change/market cap/volume for a coin, or wants a quick multi-coin price snapshot. This is the lightweight lookup skill — for deep trend/technical analysis use crypto-market-analysis or crypto-technical-charting instead.
---

# Crypto Price Check

Quick, low-latency lookups of current crypto prices and basic stats via CoinGecko's free public API. No API key required.

## Script

Use `${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh`. Make sure it's executable (`chmod +x`) before first use if needed.

## Workflow

1. **Resolve the coin ID(s).** CoinGecko uses lowercase slug IDs, not tickers — `bitcoin`, not `BTC`. Common ones: `bitcoin`, `ethereum`, `solana`, `dogecoin`, `ripple` (XRP), `cardano`, `binancecoin` (BNB), `avalanche-2` (AVAX). If unsure or the user gives a ticker/ambiguous name, resolve it first:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh search "<query>"
   ```
   Look at the `coins` array in the result for the correct `id`.

2. **Fetch the price.** For a single quick number:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh price bitcoin usd
   ```
   For richer context (market cap, 24h volume, 24h % change, last updated) — almost always preferred for a "how's X doing" question:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh price bitcoin,ethereum,solana usd --full
   ```
   Coin IDs and vs_currencies are both comma-separated, so one call covers a whole watchlist.

3. **Present the answer conversationally.** For a single coin, just state the price and 24h move in plain language ("BTC is at $X, up/down Y% over the last 24 hours"). For multiple coins, a compact table works well:

   | Coin | Price | 24h Change | Market Cap |
   |------|-------|-----------|------------|
   | BTC  | ...   | ...       | ...        |

4. If the user wants more than a snapshot — trend lines, indicators, historical context, a written report — hand off conceptually to `crypto-market-analysis` (single-coin deep dive) or `crypto-comparison` (multi-coin side-by-side) rather than trying to cram it into a quick price check.

## Notes

- The free public endpoint is rate-limited (roughly 10-30 req/min). The script auto-retries once on HTTP 429; if it keeps failing, wait a few seconds and retry, or batch more coins into a single `price` call instead of looping one-by-one.
- If the user has a `COINGECKO_API_KEY` environment variable set (CoinGecko Demo tier), the script uses it automatically for a higher rate limit — no code changes needed.
- Never fabricate a price if the API call fails — surface the error and retry or ask the user to confirm the coin ID.
