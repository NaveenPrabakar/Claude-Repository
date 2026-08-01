#!/usr/bin/env python3
"""
pokeapi_client.py — thin, cached wrapper around https://pokeapi.co/api/v2/

No API key needed. Free, public REST API. Be a good citizen: this module
caches every response to disk (.pokeapi_cache/) so repeated lookups (e.g.
during a battle-analysis session touching the same Pokemon/types many times)
don't re-hit the network.

Usage:
    from pokeapi_client import get_pokemon, get_species, get_type, get_move

    data = get_pokemon("charizard")     # by name or national dex number
    species = get_species("charizard")
    fire = get_type("fire")
    move = get_move("flamethrower")
"""
import json
import os
import time
import urllib.request
import urllib.error
from pathlib import Path

BASE_URL = "https://pokeapi.co/api/v2"
CACHE_DIR = Path(os.environ.get("POKEAPI_CACHE_DIR", ".pokeapi_cache"))
USER_AGENT = "pokedex-skill/1.0 (+https://pokeapi.co)"


class PokeAPIError(Exception):
    pass


def _cache_path(endpoint: str, key: str) -> Path:
    safe_key = str(key).lower().replace("/", "_")
    d = CACHE_DIR / endpoint
    d.mkdir(parents=True, exist_ok=True)
    return d / f"{safe_key}.json"


def _fetch(url: str, retries: int = 3, backoff: float = 1.5) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    last_err = None
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            if e.code == 404:
                raise PokeAPIError(f"Not found: {url}")
            last_err = e
        except urllib.error.URLError as e:
            last_err = e
        time.sleep(backoff ** attempt)
    raise PokeAPIError(f"Failed to fetch {url}: {last_err}")


def _get(endpoint: str, key: str) -> dict:
    """Generic cached GET for a PokeAPI resource endpoint + lookup key (name or id)."""
    cache_file = _cache_path(endpoint, key)
    if cache_file.exists():
        return json.loads(cache_file.read_text())
    key_norm = str(key).lower().strip().replace(" ", "-")
    url = f"{BASE_URL}/{endpoint}/{key_norm}"
    data = _fetch(url)
    cache_file.write_text(json.dumps(data))
    return data


def get_pokemon(name_or_id) -> dict:
    """Full Pokemon resource: stats, types, abilities, height/weight, moves, sprites."""
    return _get("pokemon", name_or_id)


def get_species(name_or_id) -> dict:
    """Species resource: flavor text, evolution chain url, capture rate, egg groups, etc."""
    return _get("pokemon-species", name_or_id)


def get_type(name_or_id) -> dict:
    """Type resource, includes damage_relations (the authoritative type chart)."""
    return _get("type", name_or_id)


def get_move(name_or_id) -> dict:
    """Move resource: power, accuracy, PP, damage class, type, effect text."""
    return _get("move", name_or_id)


def get_ability(name_or_id) -> dict:
    return _get("ability", name_or_id)


def get_evolution_chain(url_or_id) -> dict:
    """Accepts either the evolution_chain 'url' field from a species resource, or a raw id."""
    if isinstance(url_or_id, str) and url_or_id.startswith("http"):
        chain_id = url_or_id.rstrip("/").split("/")[-1]
    else:
        chain_id = url_or_id
    return _get("evolution-chain", chain_id)


def summarize_pokemon(name_or_id) -> dict:
    """Convenience: flattens the pieces most needed for stats/visualization/battle work."""
    p = get_pokemon(name_or_id)
    stats = {s["stat"]["name"]: s["base_stat"] for s in p["stats"]}
    types = [t["type"]["name"] for t in sorted(p["types"], key=lambda t: t["slot"])]
    abilities = [
        {"name": a["ability"]["name"], "hidden": a["is_hidden"]}
        for a in p["abilities"]
    ]
    return {
        "id": p["id"],
        "name": p["name"],
        "height_m": p["height"] / 10,
        "weight_kg": p["weight"] / 10,
        "types": types,
        "abilities": abilities,
        "stats": {
            "hp": stats.get("hp", 0),
            "attack": stats.get("attack", 0),
            "defense": stats.get("defense", 0),
            "special-attack": stats.get("special-attack", 0),
            "special-defense": stats.get("special-defense", 0),
            "speed": stats.get("speed", 0),
        },
        "base_stat_total": sum(stats.values()),
        "sprite": (p.get("sprites") or {}).get("front_default"),
        "artwork": ((p.get("sprites") or {}).get("other") or {})
        .get("official-artwork", {})
        .get("front_default"),
    }


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python pokeapi_client.py <pokemon-name-or-id>")
        sys.exit(1)
    print(json.dumps(summarize_pokemon(sys.argv[1]), indent=2))
