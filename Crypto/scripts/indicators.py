#!/usr/bin/env python3
"""
indicators.py — Compute common technical indicators from CoinGecko market_chart
data, and (optionally) render a chart image.

Input: JSON in the shape returned by `coingecko.sh chart <id> <vs> <days>`:
    {"prices": [[ts_ms, price], ...], "market_caps": [...], "total_volumes": [...]}

Usage:
    ./coingecko.sh chart bitcoin usd 90 daily > /tmp/btc.json
    python3 indicators.py /tmp/btc.json
    python3 indicators.py /tmp/btc.json --plot /tmp/btc_chart.png
    python3 indicators.py /tmp/btc.json --json   # machine-readable output

What it computes:
    - SMA (20, 50)      simple moving averages
    - EMA (12, 26)       exponential moving averages
    - MACD + signal      12/26 EMA crossover, 9-period signal line
    - RSI (14)            relative strength index
    - Bollinger Bands (20, 2 std)
    - Realized volatility (annualized, from daily log returns)
    - Max drawdown over the window
    - Simple trend read: price vs SMA20/SMA50, RSI zone, MACD state

Dependencies: only the Python standard library, unless --plot is used
(needs matplotlib) — the script degrades gracefully and tells you if
matplotlib isn't installed.
"""

import sys
import json
import math
import argparse
from datetime import datetime, timezone


def load_prices(path):
    with open(path) as f:
        data = json.load(f)
    prices = data.get("prices", [])
    if not prices:
        raise ValueError("No 'prices' array found in input JSON.")
    timestamps = [p[0] / 1000 for p in prices]
    values = [p[1] for p in prices]
    return timestamps, values


def sma(values, window):
    out = [None] * len(values)
    for i in range(window - 1, len(values)):
        out[i] = sum(values[i - window + 1:i + 1]) / window
    return out


def ema(values, window):
    out = [None] * len(values)
    k = 2 / (window + 1)
    seed_idx = window - 1
    if seed_idx >= len(values):
        return out
    seed = sum(values[:window]) / window
    out[seed_idx] = seed
    prev = seed
    for i in range(seed_idx + 1, len(values)):
        prev = values[i] * k + prev * (1 - k)
        out[i] = prev
    return out


def macd(values, fast=12, slow=26, signal=9):
    ema_fast = ema(values, fast)
    ema_slow = ema(values, slow)
    macd_line = [
        (f - s) if (f is not None and s is not None) else None
        for f, s in zip(ema_fast, ema_slow)
    ]
    # signal line = EMA of macd_line, only over the non-None tail
    first_valid = next((i for i, v in enumerate(macd_line) if v is not None), None)
    signal_line = [None] * len(values)
    if first_valid is not None:
        tail = macd_line[first_valid:]
        sig_tail = ema(tail, signal)
        for i, v in enumerate(sig_tail):
            signal_line[first_valid + i] = v
    histogram = [
        (m - s) if (m is not None and s is not None) else None
        for m, s in zip(macd_line, signal_line)
    ]
    return macd_line, signal_line, histogram


def rsi(values, window=14):
    out = [None] * len(values)
    if len(values) <= window:
        return out
    gains, losses = [], []
    for i in range(1, len(values)):
        change = values[i] - values[i - 1]
        gains.append(max(change, 0))
        losses.append(max(-change, 0))
    avg_gain = sum(gains[:window]) / window
    avg_loss = sum(losses[:window]) / window

    def rsi_from(avg_gain, avg_loss):
        if avg_loss == 0:
            return 100.0
        rs = avg_gain / avg_loss
        return 100 - (100 / (1 + rs))

    out[window] = rsi_from(avg_gain, avg_loss)
    for i in range(window, len(gains)):
        avg_gain = (avg_gain * (window - 1) + gains[i]) / window
        avg_loss = (avg_loss * (window - 1) + losses[i]) / window
        out[i + 1] = rsi_from(avg_gain, avg_loss)
    return out


def bollinger(values, window=20, num_std=2):
    mid = sma(values, window)
    upper = [None] * len(values)
    lower = [None] * len(values)
    for i in range(window - 1, len(values)):
        window_vals = values[i - window + 1:i + 1]
        mean = mid[i]
        variance = sum((v - mean) ** 2 for v in window_vals) / window
        std = math.sqrt(variance)
        upper[i] = mean + num_std * std
        lower[i] = mean - num_std * std
    return upper, mid, lower


def realized_volatility_annualized(values):
    if len(values) < 2:
        return None
    log_returns = [
        math.log(values[i] / values[i - 1])
        for i in range(1, len(values))
        if values[i - 1] > 0 and values[i] > 0
    ]
    if len(log_returns) < 2:
        return None
    mean = sum(log_returns) / len(log_returns)
    variance = sum((r - mean) ** 2 for r in log_returns) / (len(log_returns) - 1)
    daily_std = math.sqrt(variance)
    return daily_std * math.sqrt(365) * 100  # annualized %, assumes daily sampling


def max_drawdown(values):
    peak = values[0]
    max_dd = 0.0
    for v in values:
        peak = max(peak, v)
        dd = (v - peak) / peak
        max_dd = min(max_dd, dd)
    return max_dd * 100  # %


def last_valid(series):
    for v in reversed(series):
        if v is not None:
            return v
    return None


def build_summary(timestamps, values):
    sma20 = sma(values, 20)
    sma50 = sma(values, 50)
    ema12 = ema(values, 12)
    ema26 = ema(values, 26)
    macd_line, signal_line, hist = macd(values)
    rsi14 = rsi(values, 14)
    bb_up, bb_mid, bb_low = bollinger(values, 20, 2)

    price_now = values[-1]
    sma20_now = last_valid(sma20)
    sma50_now = last_valid(sma50)
    rsi_now = last_valid(rsi14)
    macd_now = last_valid(macd_line)
    signal_now = last_valid(signal_line)

    trend_notes = []
    if sma20_now and sma50_now:
        trend_notes.append("SMA20 above SMA50 (short-term uptrend)" if sma20_now > sma50_now
                            else "SMA20 below SMA50 (short-term downtrend)")
    if price_now and sma20_now:
        trend_notes.append("price above SMA20" if price_now > sma20_now else "price below SMA20")
    if rsi_now is not None:
        if rsi_now >= 70:
            trend_notes.append(f"RSI {rsi_now:.1f} — overbought zone")
        elif rsi_now <= 30:
            trend_notes.append(f"RSI {rsi_now:.1f} — oversold zone")
        else:
            trend_notes.append(f"RSI {rsi_now:.1f} — neutral zone")
    if macd_now is not None and signal_now is not None:
        trend_notes.append("MACD above signal (bullish momentum)" if macd_now > signal_now
                            else "MACD below signal (bearish momentum)")

    period_start = datetime.fromtimestamp(timestamps[0], tz=timezone.utc).date().isoformat()
    period_end = datetime.fromtimestamp(timestamps[-1], tz=timezone.utc).date().isoformat()
    period_return_pct = (values[-1] / values[0] - 1) * 100 if values[0] else None

    return {
        "period": {"start": period_start, "end": period_end, "num_points": len(values)},
        "price_now": price_now,
        "period_return_pct": period_return_pct,
        "sma20": sma20_now,
        "sma50": sma50_now,
        "ema12": last_valid(ema12),
        "ema26": last_valid(ema26),
        "macd": macd_now,
        "macd_signal": signal_now,
        "macd_histogram": last_valid(hist),
        "rsi14": rsi_now,
        "bollinger_upper": last_valid(bb_up),
        "bollinger_mid": last_valid(bb_mid),
        "bollinger_lower": last_valid(bb_low),
        "annualized_volatility_pct": realized_volatility_annualized(values),
        "max_drawdown_pct": max_drawdown(values),
        "trend_notes": trend_notes,
    }, {
        "timestamps": timestamps, "prices": values, "sma20": sma20, "sma50": sma50,
        "ema12": ema12, "ema26": ema26, "macd": macd_line, "macd_signal": signal_line,
        "macd_histogram": hist, "rsi14": rsi14, "bb_upper": bb_up, "bb_mid": bb_mid, "bb_lower": bb_low,
    }


def maybe_plot(series, out_path, title):
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
        import matplotlib.dates as mdates
    except ImportError:
        print("matplotlib not installed — skipping --plot. "
              "Install with: pip install matplotlib --break-system-packages", file=sys.stderr)
        return

    dates = [datetime.fromtimestamp(t, tz=timezone.utc) for t in series["timestamps"]]
    nan = float("nan")

    def clean(vals):
        return [v if v is not None else nan for v in vals]

    fig, (ax1, ax2, ax3) = plt.subplots(
        3, 1, figsize=(11, 9), sharex=True,
        gridspec_kw={"height_ratios": [3, 1, 1]}
    )

    ax1.plot(dates, series["prices"], label="Price", color="#2563eb", linewidth=1.3)
    ax1.plot(dates, clean(series["sma20"]), label="SMA20", color="#f59e0b", linewidth=1)
    ax1.plot(dates, clean(series["sma50"]), label="SMA50", color="#ef4444", linewidth=1)
    ax1.plot(dates, clean(series["bb_upper"]), label="BB Upper", color="#94a3b8", linewidth=0.8, linestyle="--")
    ax1.plot(dates, clean(series["bb_lower"]), label="BB Lower", color="#94a3b8", linewidth=0.8, linestyle="--")
    ax1.fill_between(dates, clean(series["bb_lower"]), clean(series["bb_upper"]), color="#94a3b8", alpha=0.08)
    ax1.set_title(title)
    ax1.legend(loc="upper left", fontsize=8)
    ax1.grid(alpha=0.2)

    ax2.plot(dates, clean(series["rsi14"]), color="#7c3aed", linewidth=1.1)
    ax2.axhline(70, color="#ef4444", linewidth=0.8, linestyle="--")
    ax2.axhline(30, color="#22c55e", linewidth=0.8, linestyle="--")
    ax2.set_ylabel("RSI(14)")
    ax2.set_ylim(0, 100)
    ax2.grid(alpha=0.2)

    ax3.plot(dates, clean(series["macd"]), label="MACD", color="#2563eb", linewidth=1)
    ax3.plot(dates, clean(series["macd_signal"]), label="Signal", color="#f59e0b", linewidth=1)
    hist_colors = ["#22c55e" if (h or 0) >= 0 else "#ef4444" for h in series["macd_histogram"]]
    ax3.bar(dates, clean(series["macd_histogram"]), color=hist_colors, width=0.8, alpha=0.5)
    ax3.legend(loc="upper left", fontsize=8)
    ax3.set_ylabel("MACD")
    ax3.grid(alpha=0.2)

    ax3.xaxis.set_major_formatter(mdates.DateFormatter("%Y-%m-%d"))
    fig.autofmt_xdate()
    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    print(f"Chart saved to {out_path}", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(description="Compute technical indicators from CoinGecko market_chart JSON.")
    parser.add_argument("input", help="Path to market_chart JSON file (or '-' for stdin)")
    parser.add_argument("--json", action="store_true", help="Print full summary as JSON instead of readable text")
    parser.add_argument("--plot", metavar="OUT_PNG", help="Also render a price/RSI/MACD chart to this PNG path")
    parser.add_argument("--title", default="Price Chart", help="Chart title when using --plot")
    args = parser.parse_args()

    if args.input == "-":
        data = json.load(sys.stdin)
        timestamps = [p[0] / 1000 for p in data["prices"]]
        values = [p[1] for p in data["prices"]]
    else:
        timestamps, values = load_prices(args.input)

    summary, series = build_summary(timestamps, values)

    if args.plot:
        maybe_plot(series, args.plot, args.title)

    if args.json:
        print(json.dumps(summary, indent=2))
    else:
        print(f"Period: {summary['period']['start']} to {summary['period']['end']} "
              f"({summary['period']['num_points']} data points)")
        print(f"Price now: {summary['price_now']:.6g}")
        if summary["period_return_pct"] is not None:
            print(f"Period return: {summary['period_return_pct']:.2f}%")
        print(f"SMA20: {summary['sma20']:.6g}" if summary["sma20"] else "SMA20: n/a")
        print(f"SMA50: {summary['sma50']:.6g}" if summary["sma50"] else "SMA50: n/a")
        print(f"RSI(14): {summary['rsi14']:.2f}" if summary["rsi14"] is not None else "RSI(14): n/a")
        print(f"MACD: {summary['macd']:.6g} | Signal: {summary['macd_signal']:.6g}"
              if summary["macd"] is not None and summary["macd_signal"] is not None else "MACD: n/a")
        print(f"Bollinger: lower {summary['bollinger_lower']:.6g} / mid {summary['bollinger_mid']:.6g} / "
              f"upper {summary['bollinger_upper']:.6g}" if summary["bollinger_mid"] else "Bollinger: n/a")
        if summary["annualized_volatility_pct"] is not None:
            print(f"Annualized volatility: {summary['annualized_volatility_pct']:.1f}%")
        print(f"Max drawdown over period: {summary['max_drawdown_pct']:.2f}%")
        print("Trend notes:")
        for note in summary["trend_notes"]:
            print(f"  - {note}")


if __name__ == "__main__":
    main()
