---
name: crypto-technical-charting
description: Historical price charting and technical indicator computation (SMA, EMA, MACD, RSI, Bollinger Bands, volatility, drawdown) for a cryptocurrency, using CoinGecko OHLC/market-chart data. Use this when the user wants a chart, candlestick data, technical indicators, moving averages, RSI/MACD readings, volatility numbers, or asks to "visualize" price action / "plot" a coin over some time window. For a narrative fundamentals writeup use crypto-market-analysis instead; this skill is about the quantitative chart itself.
---

# Crypto Technical Charting

Fetch historical OHLC/price-series data from CoinGecko and turn it into computed indicators and visual charts.

## Scripts

- `${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh` — data fetching
- `${CLAUDE_PLUGIN_ROOT}/scripts/indicators.py` — indicator math + optional PNG chart rendering

## Workflow

1. **Resolve the coin ID** with `search` if needed.

2. **Pick a time window** based on what the user asked for (map loosely: "recent"/"this week" → 7-14 days, "this month" → 30 days, "this year"/"long term" → 365, "all time" → max). CoinGecko `days` accepts 1, 7, 14, 30, 90, 180, 365, or `max`.

3. **Fetch the series.** Two options depending on what's needed:

   - **Line/indicator data** (price, market cap, volume over time — what `indicators.py` expects):
     ```bash
     ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh chart bitcoin usd 90 daily > /tmp/chart.json
     ```
   - **True candlestick OHLC** (open/high/low/close per period — for candlestick-style charts):
     ```bash
     ${CLAUDE_PLUGIN_ROOT}/scripts/coingecko.sh ohlc bitcoin usd 90 > /tmp/ohlc.json
     ```
     Note CoinGecko auto-selects the candle granularity based on `days` (30 min candles for 1-2 days, 4h for 30 days, 4 days for >30 days) — mention this if the user asks for a specific granularity that isn't available.

4. **Compute indicators** from the market_chart data:
   ```bash
   python3 ${CLAUDE_PLUGIN_ROOT}/scripts/indicators.py /tmp/chart.json --json
   ```
   This returns SMA(20,50), EMA(12,26), MACD + signal + histogram, RSI(14), Bollinger Bands(20,2σ), annualized realized volatility, and max drawdown for the period — all as a single JSON object. Use `--json` when you need to reason over the numbers programmatically; drop it for a human-readable text summary instead.

5. **Render a chart.** The indicators script can produce a static PNG with price+SMA+Bollinger on top, RSI in the middle, MACD histogram on the bottom:
   ```bash
   python3 ${CLAUDE_PLUGIN_ROOT}/scripts/indicators.py /tmp/chart.json --plot /tmp/chart.png --title "ETH — 90 Day"
   ```
   In environments with a native visualization/artifact tool (e.g. an interactive chart widget, or Code Execution + Files), prefer building an interactive chart directly from the fetched JSON (price line, SMA overlays, RSI/MACD subplots) over the static PNG — it's a better experience when available. Fall back to the PNG from `indicators.py` when only file output is possible.

6. **Explain what the chart shows** in plain language: trend direction (SMA20 vs SMA50), momentum (MACD state), overbought/oversold (RSI zone), and volatility — pulling straight from the `trend_notes` array in the indicator output rather than re-deriving commentary from scratch.

## Framing

Present indicator readings as descriptive technical analysis ("RSI is in overbought territory, suggesting the recent rally has been fast"), not as trading signals or advice to act on.

## Notes

- `indicators.py` needs at least ~50 data points for SMA50/MACD to populate meaningfully; for short windows (`days=7`) some longer-period indicators will show as unavailable (`n/a`) — that's expected, not a bug.
- matplotlib is required only for `--plot`; if unavailable the script still prints the numeric summary and says so.
