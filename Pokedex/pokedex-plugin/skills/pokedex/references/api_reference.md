# PokeAPI Quick Reference

Base URL: `https://pokeapi.co/api/v2/`
No auth, no API key, free and unlimited (be reasonable — cache results, which `pokeapi_client.py` already does).

## Endpoints used by this skill

| Endpoint | Example | Gives you |
|---|---|---|
| `/pokemon/{name-or-id}` | `/pokemon/charizard` | base stats, types, abilities, height/weight, moves list, sprites |
| `/pokemon-species/{name-or-id}` | `/pokemon-species/charizard` | flavor text, evolution chain URL, capture rate, egg groups, generation |
| `/type/{name-or-id}` | `/type/fire` | `damage_relations` — authoritative double/half/no-damage-to/from lists |
| `/move/{name-or-id}` | `/move/flamethrower` | power, accuracy, PP, damage class (physical/special/status), effect text |
| `/ability/{name-or-id}` | `/ability/blaze` | effect text, which Pokemon have it |
| `/evolution-chain/{id}` | `/evolution-chain/2` | full evolution tree with triggers/conditions |

Full docs: https://pokeapi.co/docs/v2

## Notes on data

- Names/keys are lowercase-hyphenated (`mr-mime`, `nidoran-f`, `special-attack`).
- National dex number also works as the lookup key (`/pokemon/6` == `/pokemon/charizard`).
- Some Pokemon have form variants (e.g. `deoxys-attack`, `charizard-mega-x`) — these are separate `/pokemon/` entries but share one `/pokemon-species/` entry.
- Base stats are the raw numbers used in this skill's `stats_chart.py` / `battle_analysis.py` — these are NOT the same as a specific in-game Pokemon's actual stats (which depend on level, IVs, EVs, nature).

## Rate limiting / etiquette

PokeAPI is a free community resource. `pokeapi_client.py` caches every response to `.pokeapi_cache/` so repeated queries in one session don't re-fetch. Don't strip the caching out for bulk scripts that hit hundreds of Pokemon.
