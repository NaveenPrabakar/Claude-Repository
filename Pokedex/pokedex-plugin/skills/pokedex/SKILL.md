---
name: pokedex
description: A full Pokedex toolkit backed by the live PokeAPI (pokeapi.co) — stat lookups, visual stat comparisons (radar/bar charts), and battle analysis (type matchups, speed checks, rough damage estimates). Use this whenever the user asks about a Pokemon's stats, types, abilities, or moves; wants to compare two or more Pokemon; asks "who would win" or wants a battle/matchup analysis; asks about type effectiveness or weaknesses/resistances; or wants any kind of Pokemon visualization or stat chart. Trigger on Pokemon names themselves (e.g. "tell me about Charizard", "Garchomp vs Excadrill") even if the user doesn't say the word "pokedex" or "PokeAPI" explicitly.
---

# Pokedex Skill

A Pokedex backed by live data from [PokeAPI](https://pokeapi.co/) (`https://pokeapi.co/api/v2/`) — free, no API key. This skill covers three jobs: **stat lookups**, **visual comparisons**, and **battle analysis**.

## Setup (once per session)

```bash
cd scripts
pip install matplotlib numpy --break-system-packages --quiet   # only needed for stats_chart.py
```

`pokeapi_client.py` uses only the Python standard library (`urllib`), so lookups and battle analysis work with zero dependencies. Only chart generation needs matplotlib/numpy.

## 1. Stats viewer (single Pokemon lookup)

```bash
python scripts/pokeapi_client.py charizard
```

Returns a clean JSON summary: base stats (HP/Atk/Def/SpA/SpD/Spe), types, abilities (with hidden ability flagged), height/weight, base stat total, and sprite URLs.

Present this to the user as a readable card, not raw JSON — name, dex number, type badges, a stat table or short bar visualization, notable abilities. Pull flavor text from `pokeapi_client.get_species()` if the user wants Pokedex-entry flavor text.

## 2. Visualization

**If you're in claude.ai (Visualizer tool available):** prefer that for an interactive inline radar/bar chart — call `read_me` with the `chart` module, then build the SVG/HTML directly from the JSON stats returned by `pokeapi_client.py`. This gives a nicer, in-conversation result than a static PNG.

**Everywhere else (Claude Code, Cowork, terminal use):** use the portable matplotlib fallback:

```bash
# Single Pokemon
python scripts/stats_chart.py pikachu

# Compare 2-6 Pokemon on one radar chart
python scripts/stats_chart.py pikachu raichu --out compare.png

# Grouped bar chart instead of radar (clearer for 4+ Pokemon)
python scripts/stats_chart.py garchomp excadrill hydreigon --bar --out bar.png
```

Colors are auto-assigned by the Pokemon's primary type (fire=orange, water=blue, etc.). Save output to the appropriate outputs directory and present it to the user — don't just report the file path in text.

## 3. Battle analysis / comparison

```bash
python scripts/battle_analysis.py garchomp excadrill
# Optionally include specific moves to get rough damage estimates:
python scripts/battle_analysis.py garchomp excadrill earthquake iron-head
```

This returns:
- **Stat-by-stat comparison** with a per-stat winner and base-stat-total winner
- **Type threat summary** — for each side, the best-case type effectiveness the *other* side's typing could exploit (before considering movepool), plus each side's full weakness/resistance/immunity buckets (`scripts/type_chart.py`)
- **Speed check** — who moves first at base speed (caveat: real games have items, abilities, and EVs that change this)
- **Rough damage estimate** (if moves given) — uses the standard damage formula at level 50, neutral nature, 0 EVs/31 IVs, no items/abilities/weather/crits. This is a **ballpark**, not a competitive-battle prediction — always caveat this to the user, since real teams run EV spreads, items, and abilities that can swing results by 20-30%+.

### Presenting battle analysis

Don't just dump the JSON. Synthesize it into a verdict: which Pokemon has the type advantage and by how much, who's faster, where the stat gaps matter most, and (if moves were given) roughly what fraction of HP each hit takes. Be explicit about the simplifying assumptions so the user doesn't mistake this for a precise competitive calc (for that level of precision, point them to a dedicated damage calculator like Pikalytics/Honko's calc, which model full team data).

## Type effectiveness lookups (standalone)

For a quick "what beats X" or "what is X weak to" question without a full battle comparison:

```bash
python scripts/type_chart.py fire flying
```

Prints the full weakness/resistance/immunity breakdown for that type combination (used internally by `battle_analysis.py` too). See `references/api_reference.md` for how this maps to PokeAPI's own `/type/{name}` `damage_relations` field, in case you need to cross-check a generation-specific rule change.

## Reference

- `references/api_reference.md` — PokeAPI endpoint cheat-sheet, naming conventions (lowercase-hyphenated, form variants like `charizard-mega-x`), and rate-limit etiquette.
- All network calls are cached to `.pokeapi_cache/` by `pokeapi_client.py` — safe to call repeatedly in one session without worrying about redundant requests.

## Things to get right

- Pokemon and move names are lowercase-hyphenated in the API (`mr-mime`, `special-attack`, `iron-head`). Convert user-friendly names before calling scripts, or let `pokeapi_client.py` do it (it lowercases + hyphenates automatically).
- A national dex number works anywhere a name does.
- Always caveat damage estimates as approximations — never present them as exact in-game numbers.
- If a Pokemon has two types, matchup multipliers multiply (e.g. Fire move vs a Grass/Steel Pokemon = 2× × 2× = 4×).
