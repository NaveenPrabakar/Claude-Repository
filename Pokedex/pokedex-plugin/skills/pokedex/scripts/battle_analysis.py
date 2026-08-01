#!/usr/bin/env python3
"""
battle_analysis.py — head-to-head comparison utilities.

Combines pokeapi_client (live data) with type_chart (offline matchup table)
to produce:
  - stat-by-stat comparison
  - bidirectional type effectiveness (who threatens who, and by how much)
  - speed check (who moves first at base speed, no items/abilities/EVs)
  - rough damage estimate for a given move (standard formula, level 50,
    neutral nature, 0 EVs/31 IVs assumed — this is an ESTIMATE, not a
    guaranteed in-game number; real battles involve EVs, natures, items,
    abilities, weather, and held items which can swing results significantly)

Import and call compare(), or run standalone:
    python battle_analysis.py pikachu charizard
"""
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from pokeapi_client import summarize_pokemon, get_move, PokeAPIError  # noqa: E402
from type_chart import multi_type_effectiveness, full_matchup  # noqa: E402

STAT_LABELS = {
    "hp": "HP",
    "attack": "Attack",
    "special-attack": "Sp. Atk",
    "defense": "Defense",
    "special-defense": "Sp. Def",
    "speed": "Speed",
}


def stat_comparison(a: dict, b: dict) -> dict:
    """a, b are summarize_pokemon() dicts. Returns per-stat deltas + winner."""
    out = {}
    for key in ["hp", "attack", "defense", "special-attack", "special-defense", "speed"]:
        av, bv = a["stats"][key], b["stats"][key]
        out[key] = {
            "label": STAT_LABELS[key],
            a["name"]: av,
            b["name"]: bv,
            "diff": av - bv,
            "winner": a["name"] if av > bv else (b["name"] if bv > av else "tie"),
        }
    out["base_stat_total"] = {
        a["name"]: a["base_stat_total"],
        b["name"]: b["base_stat_total"],
        "winner": a["name"] if a["base_stat_total"] > b["base_stat_total"]
        else (b["name"] if b["base_stat_total"] > a["base_stat_total"] else "tie"),
    }
    return out


def type_threat_summary(a: dict, b: dict) -> dict:
    """
    For each side, how hard does the OTHER side's typing hit them (best case,
    ignoring movepool — i.e. 'if they had a perfectly-typed STAB move').
    """
    a_best_vs_b = max(multi_type_effectiveness(t, b["types"]) for t in a["types"])
    b_best_vs_a = max(multi_type_effectiveness(t, a["types"]) for t in b["types"])
    return {
        f"{a['name']}_vs_{b['name']}": a_best_vs_b,
        f"{b['name']}_vs_{a['name']}": b_best_vs_a,
        f"{a['name']}_weaknesses": full_matchup(a["types"]),
        f"{b['name']}_weaknesses": full_matchup(b["types"]),
    }


def speed_check(a: dict, b: dict) -> dict:
    a_spd, b_spd = a["stats"]["speed"], b["stats"]["speed"]
    if a_spd == b_spd:
        winner = "tie (speed tie — coin flip in-game)"
    else:
        winner = a["name"] if a_spd > b_spd else b["name"]
    return {"faster": winner, a["name"]: a_spd, b["name"]: b_spd}


def estimate_damage(attacker: dict, defender: dict, move_name: str, level: int = 50) -> dict:
    """
    Rough damage estimate using the standard formula, assuming:
    level=50, neutral nature, 0 EVs, 31 IVs, no items/abilities/weather/crit.
    This is meant for ballpark comparison, not a precise in-game prediction.
    """
    move = get_move(move_name)
    power = move.get("power")
    if power is None:
        return {"error": f"'{move_name}' has no base power (status move) — no direct damage to estimate."}

    move_type = move["type"]["name"]
    damage_class = move["damage_class"]["name"]  # physical / special / status

    if damage_class == "physical":
        atk_stat = attacker["stats"]["attack"]
        def_stat = defender["stats"]["defense"]
    else:
        atk_stat = attacker["stats"]["special-attack"]
        def_stat = defender["stats"]["special-defense"]

    # Effective stat at level 50, neutral nature, 0 EV, 31 IV (simplified, ignores base HP formula nuance)
    def eff_stat(base):
        return math.floor(((2 * base + 31 + 0) * level) / 100) + 5

    atk_eff = eff_stat(atk_stat)
    def_eff = eff_stat(def_stat)

    stab = 1.5 if move_type in attacker["types"] else 1.0
    type_mult = multi_type_effectiveness(move_type, defender["types"])

    base_damage = (((2 * level / 5 + 2) * power * (atk_eff / def_eff)) / 50) + 2
    low = base_damage * stab * type_mult * 0.85
    high = base_damage * stab * type_mult * 1.00

    def_hp = eff_stat(defender["stats"]["hp"]) + level + 10  # HP formula differs slightly; close enough for ballpark
    pct_low = round(100 * low / def_hp, 1)
    pct_high = round(100 * high / def_hp, 1)

    return {
        "move": move["name"],
        "power": power,
        "type": move_type,
        "category": damage_class,
        "stab_applied": stab == 1.5,
        "type_effectiveness": type_mult,
        "damage_range": [round(low), round(high)],
        "approx_defender_hp": round(def_hp),
        "approx_pct_hp_dealt": [pct_low, pct_high],
        "note": "Estimate only: level 50, neutral nature, 0 EVs/31 IVs, no items/abilities/weather/crits.",
    }


def compare(name_a: str, name_b: str, move_a: str = None, move_b: str = None) -> dict:
    a = summarize_pokemon(name_a)
    b = summarize_pokemon(name_b)
    result = {
        "pokemon": {a["name"]: a, b["name"]: b},
        "stat_comparison": stat_comparison(a, b),
        "type_threats": type_threat_summary(a, b),
        "speed_check": speed_check(a, b),
    }
    if move_a:
        result[f"{a['name']}_move_estimate"] = estimate_damage(a, b, move_a)
    if move_b:
        result[f"{b['name']}_move_estimate"] = estimate_damage(b, a, move_b)
    return result


if __name__ == "__main__":
    import json

    if len(sys.argv) < 3:
        print("Usage: python battle_analysis.py <pokemon_a> <pokemon_b> [move_a] [move_b]")
        sys.exit(1)
    args = sys.argv[1:]
    pa, pb = args[0], args[1]
    ma = args[2] if len(args) > 2 else None
    mb = args[3] if len(args) > 3 else None
    try:
        print(json.dumps(compare(pa, pb, ma, mb), indent=2))
    except PokeAPIError as e:
        print(f"Error: {e}")
        sys.exit(1)
