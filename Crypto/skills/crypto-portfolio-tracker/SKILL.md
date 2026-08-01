---
name: crypto-portfolio-tracker
description: Track and analyze a crypto portfolio's current value, allocation breakdown, and profit/loss given a list of holdings (coin + amount, optionally with cost basis), using live CoinGecko prices. Use this when the user shares their crypto holdings, asks "what's my portfolio worth", wants an allocation breakdown/pie chart of their holdings, or wants P/L given purchase prices. Not for single-coin price checks (use crypto-price-check) or general market analysis (use crypto-market-analysis).
---

# Crypto Portfolio Tracker

Compute live portfolio value, allocation, and (if cost basis is provided) profit/loss from a list of holdings.

## Script

Use `${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh`.

## Workflow

1. **Get the holdings from the user.** Each holding needs: coin (resolve to a CoinGecko ID), amount held, and optionally a cost basis (total spent or average buy price). If the user gives tickers or coin names, resolve each to an ID via `search` first — don't guess IDs for less-common coins.

2. **Fetch current prices for all holdings in one call** (batch, don't loop):
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh price bitcoin,ethereum,solana usd --full
   ```

3. **Compute per-holding and total values:**
   - `value = amount_held * current_price`
   - `allocation_pct = value / total_portfolio_value * 100`
   - If cost basis given: `pl_dollars = value - cost_basis`, `pl_pct = pl_dollars / cost_basis * 100`

4. **Present a summary table:**

   | Coin | Amount | Price | Value | Allocation | 24h Change | P/L |
   |------|--------|-------|-------|------------|-----------|-----|
   | BTC  | 0.5    | ...   | ...   | ...%       | ...%      | ...|

   Include a total row.

5. **Visualize the allocation.** A pie/donut chart of allocation-by-value is the natural visual here. If a visualization/artifact tool is available, build it directly from the computed values (interactive is preferable). Otherwise describe the breakdown clearly in text/table form — allocation percentages are usually more useful than a static image if no chart tool exists.

6. **Optional: portfolio-level trend.** If the user wants to know how the whole portfolio has been trending, weight each coin's `chart` history by its current holding amount to build a synthetic portfolio value series over time. This requires one `chart` call per coin — mention the extra API calls if the portfolio is large (>10 coins), since the free tier is rate-limited.

## Framing

This is a valuation and tracking tool, not investment advice. State the numbers plainly (current value, allocation, P/L) without recommending trades. If the user asks whether to rebalance or what to do, provide the factual breakdown they'd need to decide and note you can't give personal financial advice.

## Notes

- Never store or persist portfolio holdings across conversations unless the user explicitly asks — treat each session's holdings as freshly provided.
- If a coin ID can't be resolved via `search`, ask the user to confirm rather than guessing — a wrong ID silently produces a wrong portfolio value.
- Stablecoins (e.g. `tether`, `usd-coin`) are valid holdings too — don't skip them from allocation math just because their price barely moves.
