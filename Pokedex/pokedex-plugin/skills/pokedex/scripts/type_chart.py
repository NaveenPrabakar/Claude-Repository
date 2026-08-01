#!/usr/bin/env python3
"""
type_chart.py — Gen 6+ (current) type effectiveness chart.

Hardcoded for speed (no network round-trip needed for every matchup check).
Matches the damage_relations data on https://pokeapi.co/api/v2/type/{name}.
If a discrepancy is ever suspected (e.g. checking an older generation),
cross-verify against pokeapi_client.get_type(name)["damage_relations"].

ATTACK_TABLE[attacking_type][defending_type] = multiplier
"""

TYPES = [
    "normal", "fire", "water", "electric", "grass", "ice", "fighting",
    "poison", "ground", "flying", "psychic", "bug", "rock", "ghost",
    "dragon", "dark", "steel", "fairy",
]

# multiplier grid, rows = attacking type, cols = defending type, order == TYPES
_GRID = {
    "normal":   {"rock": 0.5, "ghost": 0, "steel": 0.5},
    "fire":     {"fire": 0.5, "water": 0.5, "grass": 2, "ice": 2, "bug": 2,
                 "rock": 0.5, "dragon": 0.5, "steel": 2},
    "water":    {"fire": 2, "water": 0.5, "grass": 0.5, "ground": 2,
                 "rock": 2, "dragon": 0.5},
    "electric": {"water": 2, "electric": 0.5, "grass": 0.5, "ground": 0,
                 "flying": 2, "dragon": 0.5},
    "grass":    {"fire": 0.5, "water": 2, "grass": 0.5, "poison": 0.5,
                 "ground": 2, "flying": 0.5, "bug": 0.5, "rock": 2,
                 "dragon": 0.5, "steel": 0.5},
    "ice":      {"fire": 0.5, "water": 0.5, "grass": 2, "ice": 0.5,
                 "ground": 2, "flying": 2, "dragon": 2, "steel": 0.5},
    "fighting": {"normal": 2, "ice": 2, "poison": 0.5, "flying": 0.5,
                 "psychic": 0.5, "bug": 0.5, "rock": 2, "ghost": 0,
                 "dark": 2, "steel": 2, "fairy": 0.5},
    "poison":   {"grass": 2, "poison": 0.5, "ground": 0.5, "rock": 0.5,
                 "ghost": 0.5, "steel": 0, "fairy": 2},
    "ground":   {"fire": 2, "electric": 2, "grass": 0.5, "poison": 2,
                 "flying": 0, "bug": 0.5, "rock": 2, "steel": 2},
    "flying":   {"electric": 0.5, "grass": 2, "fighting": 2, "bug": 2,
                 "rock": 0.5, "steel": 0.5},
    "psychic":  {"fighting": 2, "poison": 2, "psychic": 0.5, "dark": 0,
                 "steel": 0.5},
    "bug":      {"fire": 0.5, "grass": 2, "fighting": 0.5, "poison": 0.5,
                 "flying": 0.5, "psychic": 2, "ghost": 0.5, "dark": 2,
                 "steel": 0.5, "fairy": 0.5},
    "rock":     {"fire": 2, "ice": 2, "fighting": 0.5, "ground": 0.5,
                 "flying": 2, "bug": 2, "steel": 0.5},
    "ghost":    {"normal": 0, "psychic": 2, "ghost": 2, "dark": 0.5},
    "dragon":   {"dragon": 2, "steel": 0.5, "fairy": 0},
    "dark":     {"fighting": 0.5, "psychic": 2, "ghost": 2, "dark": 0.5,
                 "fairy": 0.5},
    "steel":    {"fire": 0.5, "water": 0.5, "electric": 0.5, "ice": 2,
                 "rock": 2, "steel": 0.5, "fairy": 2},
    "fairy":    {"fire": 0.5, "fighting": 2, "poison": 0.5, "dragon": 2,
                 "dark": 2, "steel": 0.5},
}


def effectiveness(attacking_type: str, defending_type: str) -> float:
    """Multiplier of one attacking type vs one defending type. Default 1.0 (neutral)."""
    return _GRID.get(attacking_type.lower(), {}).get(defending_type.lower(), 1.0)


def multi_type_effectiveness(attacking_type: str, defending_types: list) -> float:
    """Multiplier of one attacking type vs a Pokemon that may have 1-2 types (multiplied)."""
    mult = 1.0
    for dt in defending_types:
        mult *= effectiveness(attacking_type, dt)
    return mult


def full_matchup(defending_types: list) -> dict:
    """
    For a defending Pokemon (1-2 types), classify every attacking type into
    buckets: immune (0x), quarter (0.25x), half (0.5x), neutral (1x),
    double (2x), quadruple (4x). Useful for weakness/resistance summaries.
    """
    buckets = {"immune": [], "quarter": [], "half": [], "neutral": [], "double": [], "quadruple": []}
    for atk in TYPES:
        m = multi_type_effectiveness(atk, defending_types)
        if m == 0:
            buckets["immune"].append(atk)
        elif m == 0.25:
            buckets["quarter"].append(atk)
        elif m == 0.5:
            buckets["half"].append(atk)
        elif m == 1:
            buckets["neutral"].append(atk)
        elif m == 2:
            buckets["double"].append(atk)
        elif m == 4:
            buckets["quadruple"].append(atk)
    return buckets


if __name__ == "__main__":
    import sys, json

    types = sys.argv[1:] or ["fire", "flying"]
    print(f"Matchup summary for types: {types}")
    print(json.dumps(full_matchup(types), indent=2))
