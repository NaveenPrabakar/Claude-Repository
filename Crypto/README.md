# crypto-toolkit

A complete crypto analysis plugin for Claude, built on the free [CoinGecko API](https://www.coingecko.com/en/api) (no API key required, though one is supported for a higher rate limit).

## What's inside

**Scripts** (`scripts/`)
- `coingecko.sh` — bash CLI wrapper around the CoinGecko public API: prices, market tables, full coin detail, historical price/market-cap/volume charts, OHLC candles, historical snapshots, search, trending, global market data, categories, exchanges, and a derived gainers/losers command.
- `indicators.py` — pure-Python (stdlib only, matplotlib optional) technical indicator engine: SMA, EMA, MACD, RSI, Bollinger Bands, annualized volatility, and max drawdown, computed from `coingecko.sh chart` output. Can also render a static price/RSI/MACD chart PNG.

**Skills** (`skills/`)
| Skill | Use it for |
|---|---|
| `crypto-price-check` | Fast current price / 24h stats for one or more coins |
| `crypto-market-analysis` | Deep-dive single-coin research writeup (fundamentals + trend) |
| `crypto-technical-charting` | Charts and technical indicators (SMA/EMA/MACD/RSI/Bollinger) |
| `crypto-portfolio-tracker` | Live portfolio valuation, allocation, and P/L |
| `crypto-comparison` | Side-by-side comparison of 2+ coins |
| `crypto-market-pulse` | Market-wide briefing: dominance, trending, gainers/losers |

Each skill is self-contained and routes to the two scripts above — Claude picks the right skill based on what you ask for.

## Setup

```bash
chmod +x scripts/coingecko.sh scripts/indicators.py
```

Requires: `curl` (required), `jq` (optional, for pretty JSON), `python3` (for indicators), `matplotlib` (optional, only for `--plot` chart images: `pip install matplotlib --break-system-packages`).

Optional: set `COINGECKO_API_KEY` in your environment to use a free CoinGecko Demo API key for a higher rate limit. The scripts work without one.

## Quick examples

```bash
# Price check
./scripts/coingecko.sh price bitcoin,ethereum usd --full

# 90-day chart data + indicators
./scripts/coingecko.sh chart bitcoin usd 90 daily > /tmp/btc.json
python3 scripts/indicators.py /tmp/btc.json --plot /tmp/btc.png

# What's moving today
./scripts/coingecko.sh gainers-losers usd 250

# Market overview
./scripts/coingecko.sh global
./scripts/coingecko.sh trending
```

## Notes

- CoinGecko's free public API is rate-limited (roughly 10-30 requests/minute). `coingecko.sh` auto-retries once on HTTP 429.
- Coin IDs are CoinGecko slugs, not tickers (`bitcoin`, not `BTC`). Use `./scripts/coingecko.sh search "<name or ticker>"` to resolve one.
- All output is treated as market/technical data for informational purposes, not financial advice — the skills are written to present findings factually rather than recommend trades.
