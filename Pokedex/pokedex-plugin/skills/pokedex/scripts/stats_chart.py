#!/usr/bin/env python3
"""
stats_chart.py — generates a base-stats radar chart (single Pokemon) or an
overlaid radar chart (2-6 Pokemon comparison) as a PNG file using matplotlib.

This is the PORTABLE fallback for environments without an inline visual tool
(e.g. Claude Code, plain terminal use). In claude.ai, prefer the Visualizer
tool for an interactive inline chart — see SKILL.md.

Usage:
    python stats_chart.py pikachu
    python stats_chart.py pikachu charizard blastoise --out compare.png
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from pokeapi_client import summarize_pokemon  # noqa: E402

STAT_ORDER = ["hp", "attack", "defense", "special-attack", "special-defense", "speed"]
STAT_LABELS = ["HP", "Attack", "Defense", "Sp. Atk", "Sp. Def", "Speed"]

TYPE_COLORS = {
    "normal": "#A8A77A", "fire": "#EE8130", "water": "#6390F0", "electric": "#F7D02C",
    "grass": "#7AC74C", "ice": "#96D9D6", "fighting": "#C22E28", "poison": "#A33EA1",
    "ground": "#E2BF65", "flying": "#A98FF3", "psychic": "#F95587", "bug": "#A6B91A",
    "rock": "#B6A136", "ghost": "#735797", "dragon": "#6F35FC", "dark": "#705746",
    "steel": "#B7B7CE", "fairy": "#D685AD",
}


def _color_for(mon: dict) -> str:
    return TYPE_COLORS.get(mon["types"][0], "#888888")


def radar_chart(names: list, out_path: str = "pokemon_stats.png"):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import numpy as np

    mons = [summarize_pokemon(n) for n in names]

    angles = np.linspace(0, 2 * np.pi, len(STAT_ORDER), endpoint=False).tolist()
    angles += angles[:1]

    fig, ax = plt.subplots(figsize=(7, 7), subplot_kw=dict(polar=True))
    ax.set_theta_offset(np.pi / 2)
    ax.set_theta_direction(-1)
    ax.set_xticks(angles[:-1])
    ax.set_xticklabels(STAT_LABELS, size=11)
    ax.set_rlabel_position(0)
    max_stat = max(255, max(v for m in mons for v in m["stats"].values()) + 20)
    ax.set_ylim(0, max_stat)

    for mon in mons:
        values = [mon["stats"][s] for s in STAT_ORDER]
        values += values[:1]
        color = _color_for(mon)
        label = f"{mon['name'].title()} (BST {mon['base_stat_total']})"
        ax.plot(angles, values, linewidth=2, label=label, color=color)
        ax.fill(angles, values, alpha=0.15, color=color)

    title = " vs ".join(m["name"].title() for m in mons)
    ax.set_title(f"Base Stats: {title}", size=14, weight="bold", pad=20)
    ax.legend(loc="upper right", bbox_to_anchor=(1.3, 1.1), fontsize=9)
    plt.tight_layout()
    plt.savefig(out_path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    return out_path


def bar_chart(names: list, out_path: str = "pokemon_stats_bar.png"):
    """Grouped bar chart alternative — often clearer than radar for >3 Pokemon."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import numpy as np

    mons = [summarize_pokemon(n) for n in names]
    x = np.arange(len(STAT_LABELS))
    width = 0.8 / len(mons)

    fig, ax = plt.subplots(figsize=(10, 6))
    for i, mon in enumerate(mons):
        values = [mon["stats"][s] for s in STAT_ORDER]
        offset = (i - len(mons) / 2) * width + width / 2
        ax.bar(x + offset, values, width, label=mon["name"].title(), color=_color_for(mon))

    ax.set_xticks(x)
    ax.set_xticklabels(STAT_LABELS)
    ax.set_ylabel("Base Stat Value")
    ax.set_title(" vs ".join(m["name"].title() for m in mons) + " — Base Stats")
    ax.legend()
    ax.grid(axis="y", alpha=0.3)
    plt.tight_layout()
    plt.savefig(out_path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    return out_path


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python stats_chart.py <pokemon1> [pokemon2] ... [--bar] [--out path.png]")
        sys.exit(1)
    args = sys.argv[1:]
    use_bar = "--bar" in args
    if use_bar:
        args.remove("--bar")
    out = "pokemon_stats.png"
    if "--out" in args:
        idx = args.index("--out")
        out = args[idx + 1]
        del args[idx:idx + 2]
    fn = bar_chart if use_bar else radar_chart
    path = fn(args, out)
    print(f"Saved chart to {path}")
