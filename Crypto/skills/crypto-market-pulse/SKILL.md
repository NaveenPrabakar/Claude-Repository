---
name: crypto-market-pulse
description: Market-wide crypto overview — total market cap, BTC/ETH dominance, trending coins, top gainers and losers, and category leaders — using the CoinGecko free API. Use this when the user asks "what's happening in crypto today", wants trending/hot coins, top gainers or losers, overall market sentiment/direction, or a general market briefing not focused on one specific coin. For single-coin or multi-coin deep dives use crypto-market-analysis or crypto-comparison instead.
---

# Crypto Market Pulse

Produce a market-wide snapshot: overall direction, what's trending, and who's moving.

## Script

Use `${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh`.

## Workflow

1. **Global market state:**
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh global
   ```
   Key fields: `data.total_market_cap.usd`, `data.market_cap_change_percentage_24h_usd`, `data.market_cap_percentage.btc` (BTC dominance), `.eth` (ETH dominance), `data.total_volume.usd`, `data.active_cryptocurrencies`.

2. **What's trending right now:**
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh trending
   ```
   Returns the top searched coins/NFTs/categories on CoinGecko in the last 24h — a good proxy for "what people are paying attention to" (distinct from price performance).

3. **Biggest movers:**
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh gainers-losers usd 250
   ```
   This pulls the top 250 coins by market cap and sorts them into top-10 gainers and top-10 losers by 24h % change — a reasonable "meaningful market cap" filter so the list isn't dominated by illiquid micro-caps. Increase the universe size (e.g. 500) if the user wants a wider net, at the cost of one larger API call.

4. **Category leaders (optional)**, if the user's asking about a sector (DeFi, memecoins, AI tokens, L2s, etc.):
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh categories
   ```
   Sort by `market_cap_change_24h` to see which categories/narratives are hot.

5. **Synthesize into a briefing**, roughly:
   - **Overall tone**: total market cap and its 24h change, framed as risk-on/risk-off in plain terms
   - **Dominance**: is money concentrating in BTC or rotating into alts
   - **Trending**: what's getting attention (note: attention ≠ performance — call this out if trending coins aren't also gainers)
   - **Movers**: top gainers/losers table
   - **Sector angle**: if relevant, which categories are leading/lagging

6. **Visualize** where it adds clarity — e.g. a horizontal bar chart of top gainers/losers, or a simple dominance donut (BTC / ETH / other). Use a native chart tool if available; otherwise present clean tables.

## Framing

This is a snapshot of current market conditions, not a prediction or trading signal. Avoid characterizing moves as buy/sell opportunities — describe what's happening and let the person draw their own conclusions.

## Notes

- `gainers-losers` makes one `markets` call under the hood — cheap on rate limit even though it returns two ranked lists.
- Trending data reflects search interest on CoinGecko itself, not the whole market — say so if precision matters to the user's question.
