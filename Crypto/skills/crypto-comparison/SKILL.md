---
name: crypto-comparison
description: Side-by-side comparison of two or more cryptocurrencies across price, market cap, volume, supply, all-time-high distance, and historical performance, using the CoinGecko free API. Use this when the user asks to compare coins ("X vs Y"), wants to know which of several coins has performed better, or wants a table/chart ranking multiple coins against each other. For analysis of a single coin use crypto-market-analysis instead.
---

# Crypto Comparison

Build a side-by-side comparison across two or more cryptocurrencies.

## Script

Use `${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh`.

## Workflow

1. **Resolve all coin IDs** the user wants compared (use `search` for any that aren't obvious).

2. **Pull a single batched markets snapshot** — this is far more efficient than calling `coin` once per coin, and covers most comparison needs in one request:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh markets usd 250 1 market_cap_desc bitcoin,ethereum,solana,cardano
   ```
   This returns, per coin: current price, market cap + rank, 24h volume, 1h/24h/7d % change, circulating/total/max supply, ATH + % from ATH, ATL + % from ATL.

3. **Build the comparison table**, e.g.:

   | Metric | BTC | ETH | SOL |
   |--------|-----|-----|-----|
   | Price | | | |
   | Market Cap (Rank) | | | |
   | 24h Volume | | | |
   | 24h / 7d Change | | | |
   | Circulating Supply | | | |
   | % From ATH | | | |

4. **For performance-over-time comparison** (e.g. "which has done better over the last 90 days"), pull each coin's chart data and normalize to a common starting index (e.g. 100) so relative performance is directly comparable regardless of price scale:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh chart bitcoin usd 90 daily > /tmp/btc.json
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh chart ethereum usd 90 daily > /tmp/eth.json
   ```
   Normalize each series (`price / price[0] * 100`) and plot them on the same axes — this is the clearest way to show "which coin outperformed" regardless of absolute price differences. Use `indicators.py` on each individually first if the user also wants indicator-level comparison (e.g. "which one is more volatile" → compare `annualized_volatility_pct`).

5. **Visualize.** A grouped bar chart works well for the snapshot metrics (market cap, volume); a multi-line normalized chart works well for performance-over-time. Use a native chart/artifact tool if available; otherwise a clear table is the fallback.

6. **Summarize the comparison in prose**, calling out the standout differences (e.g. "SOL has been more volatile but also had the stronger 90-day return; BTC's move has been steadier"). Keep it descriptive, not prescriptive.

## Notes

- Limit to a reasonable number of coins per comparison (roughly 2-8) — beyond that a table gets unreadable and it's better suited to `crypto-market-pulse`'s ranked-table approach.
- The `markets` endpoint accepts up to ~250 IDs in one call, so even a larger comparison set is still just one API request.
