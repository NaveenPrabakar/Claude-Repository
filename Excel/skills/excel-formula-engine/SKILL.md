---
name: excel-formula-engine
description: >
  This skill should be used when the user wants formulas written, fixed, or
  verified in an Excel workbook — lookups, financial calculations, conditional
  aggregation, running totals, error handling, or any cell that should compute
  rather than hold a static number. Trigger on phrases like "add a formula for",
  "calculate this with a formula", "use VLOOKUP/INDEX MATCH", "why is this
  formula returning an error", "make this dynamic", "sum if", "build a
  financial model", or whenever a deliverable must recalculate correctly when
  its inputs change. Also covers verifying formulas actually evaluate without
  errors before delivery.
metadata:
  version: "0.1.0"
---

# Excel Formula Engine

Write formulas that are correct, use functions that actually evaluate in this environment, and are verified before delivery — never hand back a workbook with unverified or hardcoded-looking formulas.

## The core rule: formulas, never hardcoded results

Write `ws["B10"] = "=SUM(B2:B9)"`, never the Python-computed number. A cell that holds a static result stops updating the moment the user changes an input, which defeats the point of a spreadsheet. The only exception is a value the user explicitly typed in as a raw input.

## Function compatibility

This environment verifies formulas with a headless LibreOffice recalculation pass (see `../../shared/scripts/recalc.py`), and LibreOffice implements a narrower function set than modern Excel. A function it can't parse gets written back into the file as a literal error or lowercased text — which looks fine in your code but breaks the delivered file.

- **Safe without any prefix** (Excel 2007-era, universally supported): `SUM`, `SUMIF`, `SUMIFS`, `AVERAGEIFS`, `COUNTIFS`, `INDEX`, `MATCH`, `VLOOKUP`, `HLOOKUP`, `IFERROR`, `IF`, `AND`, `OR`, `SUMPRODUCT`, `ROUND`, `TEXT`, `CONCATENATE`.
- **Needs an `_xlfn.` prefix in the raw formula string** (post-2007 functions — openpyxl writes XML directly, and Excel's file format stores these names prefixed even though the UI hides it): `_xlfn.TEXTJOIN`, `_xlfn.CONCAT`, `_xlfn.IFS`, `_xlfn.SWITCH`, `_xlfn.MAXIFS`, `_xlfn.MINIFS`. Writing them without the prefix silently produces `#NAME?`.
- **Never use `XLOOKUP`, `XMATCH`, `SORT`, `FILTER`, `UNIQUE`, or `SEQUENCE`.** These are dynamic-array/spill functions; an openpyxl-written file carries no spill metadata, so even where the function is understood, only the top-left cell of the intended range receives a value and the rest silently stay blank — and the recalculation check reports zero errors on that truncated result, so it looks clean and isn't. Use `INDEX`/`MATCH` in place of `XLOOKUP`, and pre-sort/filter/dedupe the data in Python before writing cells instead of relying on `SORT`/`FILTER`/`UNIQUE`.

Prefer `INDEX`/`MATCH` over `VLOOKUP` for anything where the lookup column might move, since `VLOOKUP` breaks silently if a column is inserted to its left.

## Recalculation is mandatory, not optional

openpyxl writes formula strings with no cached value. Until recalculated, every formula cell reads back as `None` to pandas, to `load_workbook(data_only=True)`, and to most previewers — so an un-recalculated file looks broken even when every formula is correct.

```bash
python ../../shared/scripts/recalc.py output.xlsx [timeout_seconds]
```

This rewrites the file in place with LibreOffice-computed values and prints a JSON report (`status`, `total_formulas`, `total_errors`, `error_summary`). Never ship a workbook while `status` is `errors_found`. A clean exit code alone doesn't mean the workbook is error-free — `errors_found` still exits 0 by design, so always read the JSON.

**A clean recalc proves formulas evaluate, not that they're correct.** An off-by-one range or a formula anchored to the wrong row produces a spotless, error-free file with wrong numbers. Before scaling a formula across a full grid, write 2–3 instances and manually check they pull the values you expect.

## Verifying an inherited error isn't yours

If a cell already shows an error before you touch the file, don't assume the fix is on you or skip it — confirm which case it is: load the *original* file with `data_only=True` and inspect that exact cell. An error you just introduced is indistinguishable by eye from one that predates you; only comparing against the original proves it.

## Reading formulas + values together

One `load_workbook` call gives you either formula strings (default) or cached values (`data_only=True`), never both. To audit or explain a model, load twice:

```python
from openpyxl import load_workbook
wb_formulas = load_workbook("model.xlsx", data_only=False)
wb_values = load_workbook("model.xlsx", data_only=True)
```

`data_only=True` is destructive if you save that workbook back — every formula is replaced by its literal cached result, permanently. Only use it for reading.

## Common formula patterns

**Conditional sum across multiple criteria:**
```
=SUMIFS(Sales!D:D, Sales!A:A, "West", Sales!C:C, ">="&DATE(2026,1,1))
```

**Robust lookup that survives inserted columns:**
```
=INDEX(Prices!C:C, MATCH(A2, Prices!A:A, 0))
```

**Lookup with a graceful fallback instead of `#N/A`:**
```
=IFERROR(INDEX(Prices!C:C, MATCH(A2, Prices!A:A, 0)), "Not found")
```

**Guarded division (avoid `#DIV/0!` when a denominator can be zero):**
```
=IF(B2=0, "", A2/B2)
```

**Running total:**
```
=SUM($C$2:C2)
```
(anchor the start, let the end grow as you copy down)

## Cross-sheet references

Quote any sheet name containing a space: `='Q1 Actuals'!B5` — unquoted, Excel evaluates this as `#VALUE!` rather than resolving the sheet.

## Financial-model conventions

When the deliverable is a model rather than a one-off calc (unless the user or an existing file already specifies otherwise):

- Every assumption lives in its own labeled, referenced cell — `=B5*(1+$B$6)`, never `=B5*1.05` — so the reader can find and change every lever.
- Formulas stay structurally identical across a projection row; a manually edited cell mid-row is the single most common silent modeling error.
- Percentages are stored as fractions (`0.15`, formatted `0.0%`) — storing `15` renders `1500.0%`.
- Color convention: blue text for hardcoded inputs, black for formulas, green for links to another sheet, red for links to another file, yellow fill for key assumptions or cells meant to be filled in.

## External workbook links

A formula like `='[1]Returns Analysis'!$B$2` references a *separate file on disk* via an index into the workbook's external-reference list — that file is rarely present in this environment, so the cell's cached value is the only thing holding real data. Saving with openpyxl strips that cached value; the subsequent recalculation pass then can't resolve the reference and writes `#NAME?`, destroying the link entirely. Copy the values you need out of the original file *before* saving over it if any formulas look like this.
