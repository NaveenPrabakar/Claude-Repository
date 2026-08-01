---
name: crypto-market-analysis
description: Deep-dive fundamental and market analysis on a single cryptocurrency — combining live market data, project fundamentals, developer/community activity, and historical performance into a written analysis. Use this when the user asks to "analyze" a coin, wants a research writeup, asks "should I look into X", wants fundamentals (supply, ATH/ATL, dev activity, community size), or wants a narrative summary of how a coin has been doing and why. For pure price lookups use crypto-price-check; for indicator-heavy charting use crypto-technical-charting.
---

# Crypto Market Analysis

Produce a well-rounded analysis of a single cryptocurrency by combining several CoinGecko data pulls into one narrative: current market standing, fundamentals, recent trend, and context.

## Script

Use `${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh`.

## Workflow

1. **Resolve the coin ID** with `search` if not already known (see crypto-price-check for the pattern).

2. **Pull full coin detail** — this is the core of the analysis:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh coin bitcoin > /tmp/coin.json
   ```
   This response is large. Useful fields to pull out (via `jq` or by reading the JSON):
   - `market_data.current_price`, `market_cap`, `market_cap_rank`, `total_volume`
   - `market_data.price_change_percentage_{24h,7d,30d,1y}`
   - `market_data.ath`, `market_data.ath_change_percentage`, `market_data.ath_date`
   - `market_data.atl`, `market_data.atl_change_percentage`
   - `market_data.circulating_supply`, `total_supply`, `max_supply`
   - `community_data` (Twitter followers, Reddit subscribers, Telegram)
   - `developer_data` (GitHub stars, forks, commits in last 4 weeks, contributors)
   - `description.en` (project description — paraphrase, don't quote at length; see copyright rules)
   - `categories`, `links.homepage`, `links.repos_url.github`

3. **Pull recent price history for trend context** (90-180 days is usually enough for a narrative):
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh chart bitcoin usd 180 daily > /tmp/chart.json
   ```
   Then run the indicator summary to get a quantified trend read:
   ```bash
   python3 ${CLAUDE_PLUGIN_ROOT}/scripts/indicators.py /tmp/chart.json
   ```
   This gives SMA20/50, RSI, MACD, volatility, and max drawdown in one shot — fold these into the narrative rather than re-deriving them by hand.

4. **Pull global context** if the analysis benefits from comparing the coin's performance to the broader market:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh global
   ```

5. **Visualize before/alongside the writeup.** Generate a price chart with indicators overlaid:
   ```bash
   python3 ${CLAUDE_PLUGIN_ROOT}/scripts/indicators.py /tmp/chart.json --plot /tmp/chart.png --title "Bitcoin — 180 Day Trend"
   ```
   Present the chart image alongside the analysis (or via the Visualizer / artifact tool if working in an environment with one, using the underlying data rather than the PNG when a native chart is preferred).

6. **Write the analysis.** Structure it loosely as:
   - **Snapshot**: price, rank, market cap, 24h/7d/30d moves
   - **Trend read**: what the indicators say (momentum, overbought/oversold, volatility) — always frame as descriptive market analysis, not financial advice
   - **Fundamentals**: supply schedule, distance from ATH, notable dev/community activity signals
   - **Context**: how it's doing relative to the broader market (BTC dominance, total market cap trend from `global`)
   - Keep it grounded in the numbers actually pulled — don't speculate beyond the data.

## Important framing

This produces market/technical analysis, not investment advice. Present findings as factual information the person can use to make their own decision (see financial-advice guidance) — avoid phrases like "you should buy/sell" and instead describe what the data shows.

## Notes

- The `coin` endpoint response is large; don't dump raw JSON into the conversation — extract and synthesize.
- If `developer_data` or `community_data` come back empty/zeroed, note that data isn't tracked for that project rather than treating it as a negative signal.
