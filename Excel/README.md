# Excel Power Toolkit

A Claude plugin that packages five specialized skills for fully manipulating Excel workbooks — from raw, messy data all the way to a polished, formula-driven, chart-backed deliverable.

## Overview

Each skill covers one slice of real Excel work, so Claude loads only the guidance it needs for the task at hand instead of one giant catch-all skill. They're designed to be used together: a typical request (e.g. "clean this data and turn it into a dashboard") will pull in two or three skills in sequence.

## Skills

| Skill | Covers |
|---|---|
| `excel-data-wrangling` | Cleaning, filtering, deduplicating, splitting/merging columns, joining sheets, reshaping (pivot/melt), combining multiple files |
| `excel-formula-engine` | Writing correct formulas (lookups, conditional aggregation, financial calcs), function-compatibility rules, mandatory recalculation and error verification |
| `excel-styling-formatting` | Fonts, colors, number formats, conditional formatting, table objects, professional visual conventions |
| `excel-charts-dashboards` | Native openpyxl charts (bar/line/pie/scatter/combo), pivot-style summaries, dashboard sheet layout |
| `excel-automation-vba` | Batch processing many files, reusable templates, `.xlsm` macro handling |

## Setup

No external services or credentials required. The skills assume a Python environment with `openpyxl`, `pandas`, and `markitdown` available, and LibreOffice (`soffice`) on the PATH for formula recalculation — all standard in Claude's code-execution environment.

## Usage

These skills trigger automatically based on the request — just describe the Excel task in natural language ("clean up this spreadsheet," "add a chart for revenue by region," "write a macro that highlights overdue rows," etc.). No slash commands needed.

A shared recalculation utility lives at `shared/scripts/recalc.py` and is referenced by the formula, automation, and (indirectly) data-wrangling skills whenever a delivered workbook contains formulas — it recalculates via headless LibreOffice and reports any formula errors before the file is considered done.

## Design notes

- **Never rebuild a file via a pandas round-trip when editing an existing workbook** — this silently destroys formatting, formulas, and charts not represented in a DataFrame. All skills default to `openpyxl.load_workbook` for in-place edits.
- **Every delivered workbook with formulas is recalculated and checked for errors before being called done** — a clean exit code alone isn't sufficient proof; the JSON report from `recalc.py` must show zero errors.
- **Dynamic-array functions (`XLOOKUP`, `FILTER`, `UNIQUE`, `SORT`, `SEQUENCE`) are avoided** in favor of `INDEX`/`MATCH` and Python-side sorting/filtering, since this environment's recalculation engine (LibreOffice) doesn't reliably evaluate them.
