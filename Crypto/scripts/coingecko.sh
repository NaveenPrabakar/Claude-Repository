#!/usr/bin/env bash
#
# coingecko.sh — CLI wrapper around the CoinGecko free/public API.
#
# All commands print raw JSON to stdout so Claude (or any downstream script)
# can pipe the output into jq, python, or a file for further analysis.
#
# Usage:
#   ./coingecko.sh <command> [args...]
#
# Commands:
#   price <ids> [vs_currencies] [--full]
#       Simple current price lookup. ids and vs_currencies are comma-separated.
#       --full also includes market cap, 24h volume, 24h change, last updated.
#       Example: ./coingecko.sh price bitcoin,ethereum usd --full
#
#   markets [vs_currency] [per_page] [page] [order] [ids] [category]
#       Ranked market table (price, market cap, volume, 24h/7d change, supply, ATH).
#       order: market_cap_desc | volume_desc | id_asc | percent_change_24h_desc ...
#       Example: ./coingecko.sh markets usd 50 1 market_cap_desc
#       Example (specific coins): ./coingecko.sh markets usd 250 1 market_cap_desc bitcoin,ethereum,solana
#
#   coin <id>
#       Full coin detail: description, links, dev/community stats, current market data.
#       Example: ./coingecko.sh coin bitcoin
#
#   chart <id> [vs_currency] [days] [interval]
#       Historical market chart: arrays of [timestamp, price], market_cap, volume.
#       days: 1,7,14,30,90,180,365,max. interval: leave blank for auto, or "daily".
#       Example: ./coingecko.sh chart bitcoin usd 90 daily
#
#   ohlc <id> [vs_currency] [days]
#       Candlestick OHLC data. days: 1,7,14,30,90,180,365.
#       Example: ./coingecko.sh ohlc bitcoin usd 30
#
#   history <id> <dd-mm-yyyy>
#       Snapshot of coin data on a specific past date.
#       Example: ./coingecko.sh history bitcoin 25-12-2024
#
#   search <query>
#       Search coins/exchanges/categories by name or symbol (useful for resolving IDs).
#       Example: ./coingecko.sh search "dogwifhat"
#
#   trending
#       Top trending searches on CoinGecko in the last 24h (coins, nfts, categories).
#
#   global
#       Aggregate global market data: total market cap, volume, BTC/ETH dominance.
#
#   categories
#       All coin categories ranked by market cap.
#
#   exchanges [per_page]
#       Top exchanges ranked by trust score / volume.
#
#   gainers-losers [vs_currency] [universe_size]
#       Derived command: pulls a markets snapshot (default top 250 by market cap)
#       and prints it sorted so you can see biggest 24h gainers and losers.
#       Example: ./coingecko.sh gainers-losers usd 250
#
# Environment variables:
#   COINGECKO_API_KEY   Optional. If set, sent as the x-cg-demo-api-key header
#                        (CoinGecko's free "Demo" tier key — get one at
#                        coingecko.com/en/api/pricing). Not required; the public
#                        endpoint works without a key but has a lower rate limit.
#
# Notes:
#   - Requires curl. jq is used to pretty-print/validate JSON if present, but is
#     not required for the script to function.
#   - The public free API is rate-limited (roughly 10-30 calls/min depending on
#     load). The script auto-retries once on HTTP 429 after a short backoff.

set -euo pipefail

BASE_URL="https://api.coingecko.com/api/v3"
MAX_RETRIES=3
RETRY_DELAY=8

err() { echo "Error: $*" >&2; }

have_jq() { command -v jq >/dev/null 2>&1; }

# curl_get <path-and-query>
# Performs the GET request, retries on 429, prints body, returns non-zero on failure.
curl_get() {
  local path="$1"
  local url="${BASE_URL}${path}"
  local attempt=1
  local tmp_body
  tmp_body="$(mktemp)"

  local -a headers=(-H "Accept: application/json")
  if [[ -n "${COINGECKO_API_KEY:-}" ]]; then
    headers+=(-H "x-cg-demo-api-key: ${COINGECKO_API_KEY}")
  fi

  while (( attempt <= MAX_RETRIES )); do
    local http_code
    http_code="$(curl -sS -o "$tmp_body" -w "%{http_code}" --max-time 30 "${headers[@]}" "$url" || echo "000")"

    if [[ "$http_code" == "200" ]]; then
      if have_jq; then
        jq '.' "$tmp_body"
      else
        cat "$tmp_body"
      fi
      rm -f "$tmp_body"
      return 0
    elif [[ "$http_code" == "429" ]]; then
      err "Rate limited (429). Retrying in ${RETRY_DELAY}s (attempt ${attempt}/${MAX_RETRIES})..."
      sleep "$RETRY_DELAY"
    elif [[ "$http_code" == "404" ]]; then
      err "Not found (404) for: $url"
      err "Tip: coin IDs are CoinGecko slugs, not tickers. e.g. 'bitcoin' not 'BTC'. Use the 'search' command to resolve an ID."
      rm -f "$tmp_body"
      return 1
    else
      err "Request failed with HTTP ${http_code} for: $url"
      cat "$tmp_body" >&2 || true
      rm -f "$tmp_body"
      return 1
    fi
    ((attempt++))
  done

  err "Exceeded max retries for: $url"
  rm -f "$tmp_body"
  return 1
}

urlencode() {
  local raw="$1"
  local out=""
  local i c
  for (( i=0; i<${#raw}; i++ )); do
    c="${raw:$i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) out+="$c" ;;
      ' ') out+="%20" ;;
      *) printf -v hex '%%%02X' "'$c"; out+="$hex" ;;
    esac
  done
  echo "$out"
}

cmd_price() {
  local ids="${1:-}"; local vs="${2:-usd}"; local full_flag="${3:-}"
  if [[ -z "$ids" ]]; then err "Usage: price <ids> [vs_currencies] [--full]"; exit 1; fi
  local extra=""
  if [[ "$full_flag" == "--full" || "$vs" == "--full" ]]; then
    [[ "$vs" == "--full" ]] && vs="usd"
    extra="&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true&include_last_updated_at=true"
  fi
  curl_get "/simple/price?ids=$(urlencode "$ids")&vs_currencies=$(urlencode "$vs")${extra}"
}

cmd_markets() {
  local vs="${1:-usd}"; local per_page="${2:-100}"; local page="${3:-1}"
  local order="${4:-market_cap_desc}"; local ids="${5:-}"; local category="${6:-}"
  local q="/coins/markets?vs_currency=$(urlencode "$vs")&order=$(urlencode "$order")&per_page=${per_page}&page=${page}&sparkline=false&price_change_percentage=1h,24h,7d"
  [[ -n "$ids" ]] && q+="&ids=$(urlencode "$ids")"
  [[ -n "$category" ]] && q+="&category=$(urlencode "$category")"
  curl_get "$q"
}

cmd_coin() {
  local id="${1:-}"
  if [[ -z "$id" ]]; then err "Usage: coin <id>"; exit 1; fi
  curl_get "/coins/$(urlencode "$id")?localization=false&tickers=false&market_data=true&community_data=true&developer_data=true&sparkline=false"
}

cmd_chart() {
  local id="${1:-}"; local vs="${2:-usd}"; local days="${3:-30}"; local interval="${4:-}"
  if [[ -z "$id" ]]; then err "Usage: chart <id> [vs_currency] [days] [interval]"; exit 1; fi
  local q="/coins/$(urlencode "$id")/market_chart?vs_currency=$(urlencode "$vs")&days=${days}"
  [[ -n "$interval" ]] && q+="&interval=$(urlencode "$interval")"
  curl_get "$q"
}

cmd_ohlc() {
  local id="${1:-}"; local vs="${2:-usd}"; local days="${3:-30}"
  if [[ -z "$id" ]]; then err "Usage: ohlc <id> [vs_currency] [days]"; exit 1; fi
  curl_get "/coins/$(urlencode "$id")/ohlc?vs_currency=$(urlencode "$vs")&days=${days}"
}

cmd_history() {
  local id="${1:-}"; local date="${2:-}"
  if [[ -z "$id" || -z "$date" ]]; then err "Usage: history <id> <dd-mm-yyyy>"; exit 1; fi
  curl_get "/coins/$(urlencode "$id")/history?date=$(urlencode "$date")&localization=false"
}

cmd_search() {
  local query="${1:-}"
  if [[ -z "$query" ]]; then err "Usage: search <query>"; exit 1; fi
  curl_get "/search?query=$(urlencode "$query")"
}

cmd_trending() {
  curl_get "/search/trending"
}

cmd_global() {
  curl_get "/global"
}

cmd_categories() {
  curl_get "/coins/categories"
}

cmd_exchanges() {
  local per_page="${1:-50}"
  curl_get "/exchanges?per_page=${per_page}&page=1"
}

cmd_gainers_losers() {
  local vs="${1:-usd}"; local universe="${2:-250}"
  local data
  data="$(cmd_markets "$vs" "$universe" 1 market_cap_desc)"
  if have_jq; then
    echo "=== TOP 10 GAINERS (24h) ==="
    echo "$data" | jq -c 'map(select(.price_change_percentage_24h != null)) | sort_by(-.price_change_percentage_24h) | .[:10] | .[] | {id, symbol, price: .current_price, change_24h: .price_change_percentage_24h}'
    echo "=== TOP 10 LOSERS (24h) ==="
    echo "$data" | jq -c 'map(select(.price_change_percentage_24h != null)) | sort_by(.price_change_percentage_24h) | .[:10] | .[] | {id, symbol, price: .current_price, change_24h: .price_change_percentage_24h}'
  else
    echo "$data"
    err "jq not found — printed raw markets data instead. Install jq for sorted gainers/losers."
  fi
}

main() {
  local cmd="${1:-}"
  [[ $# -gt 0 ]] && shift || true
  case "$cmd" in
    price) cmd_price "$@" ;;
    markets) cmd_markets "$@" ;;
    coin) cmd_coin "$@" ;;
    chart) cmd_chart "$@" ;;
    ohlc) cmd_ohlc "$@" ;;
    history) cmd_history "$@" ;;
    search) cmd_search "$@" ;;
    trending) cmd_trending "$@" ;;
    global) cmd_global "$@" ;;
    categories) cmd_categories "$@" ;;
    exchanges) cmd_exchanges "$@" ;;
    gainers-losers) cmd_gainers_losers "$@" ;;
    *)
      cat >&2 <<EOF
Usage: $0 <command> [args...]

Commands: price, markets, coin, chart, ohlc, history, search, trending,
          global, categories, exchanges, gainers-losers

Run with no args to see this message. See the top of coingecko.sh for
full usage examples of each command.
EOF
      exit 1
      ;;
  esac
}

main "$@"
