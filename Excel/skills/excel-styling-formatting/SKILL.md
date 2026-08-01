---
name: excel-styling-formatting
description: >
  This skill should be used when the user wants an Excel workbook to look
  professional or communicate meaning through formatting — fonts, colors,
  borders, number formats, conditional formatting, frozen headers, column
  widths, or an overall visual theme. Trigger on phrases like "make this look
  professional", "format this spreadsheet", "add conditional formatting",
  "highlight cells where", "freeze the header row", "color code this", "apply
  currency formatting", "clean up the formatting", or "match our brand style".
metadata:
  version: "0.1.0"
---

# Excel Styling & Formatting

Apply formatting that communicates meaning and looks professional, using `openpyxl.styles` directly on the workbook rather than rebuilding it through pandas (which drops formatting entirely).

## Baseline rules for every deliverable

- Use a professional font throughout — Arial or Calibri for general work, Times New Roman if the user wants a more formal/print feel — unless the user or an existing file's convention says otherwise.
- **Editing an existing file: match its conventions, don't impose new ones.** Find the file's existing font, header style, and color scheme first and extend it, rather than restyling from scratch.
- Freeze the header row (`ws.freeze_panes = "A2"`) on any sheet with more than ~15 rows of data.
- Auto-fit or explicitly set column widths — default openpyxl column widths truncate most real content.
- Zero out stray gridlines/borders inconsistency: pick a border style for the table and apply it uniformly, not cell-by-cell as an afterthought.

## Core building blocks

```python
from openpyxl.styles import Font, PatternFill, Border, Side, Alignment, NamedStyle
from openpyxl.utils import get_column_letter
from openpyxl.formatting.rule import CellIsRule, ColorScaleRule, FormulaRule, IconSetRule

# Fonts
header_font = Font(name="Calibri", size=12, bold=True, color="FFFFFF")
body_font = Font(name="Calibri", size=11)

# Fills (ARGB or RGB hex, no leading '#')
header_fill = PatternFill(start_color="1F4E78", end_color="1F4E78", fill_type="solid")

# Borders
thin = Side(style="thin", color="B7B7B7")
box_border = Border(left=thin, right=thin, top=thin, bottom=thin)

# Alignment
center = Alignment(horizontal="center", vertical="center", wrap_text=True)
```

Apply to a header row in one pass:
```python
for cell in ws[1]:
    cell.font = header_font
    cell.fill = header_fill
    cell.alignment = center
    cell.border = box_border
ws.row_dimensions[1].height = 22
```

Auto-size columns from content (openpyxl has no built-in autofit):
```python
for col_cells in ws.columns:
    length = max(len(str(c.value)) for c in col_cells if c.value is not None)
    col_letter = get_column_letter(col_cells[0].column)
    ws.column_dimensions[col_letter].width = min(max(length + 2, 10), 40)
```

## Number formats

Set `cell.number_format`, not text formatting — this keeps the underlying value numeric so formulas and sorting still work.

| Purpose | Format string |
|---|---|
| Currency, no decimals, negatives in parens, zero as dash | `$#,##0;($#,##0);"-"` |
| Percentage (value stored as a fraction, e.g. `0.15`) | `0.0%` |
| Thousands separator | `#,##0` |
| Date | `mm/dd/yyyy` or `yyyy-mm-dd` |
| Valuation multiple | `0.0x` |
| Year as text (avoid `2,024`) | store as a string, or format `0"";@` |

## Conditional formatting

Highlight cells that meet a condition without hardcoding which cells qualify — the rule re-evaluates as data changes.

```python
# Highlight values over a threshold
ws.conditional_formatting.add(
    "D2:D100",
    CellIsRule(operator="greaterThan", formula=["1000"],
               fill=PatternFill(start_color="C6EFCE", end_color="C6EFCE", fill_type="solid"))
)

# 3-color scale for a heat map effect
ws.conditional_formatting.add(
    "E2:E100",
    ColorScaleRule(start_type="min", start_color="F8696B",
                    mid_type="percentile", mid_value=50, mid_color="FFEB84",
                    end_type="max", end_color="63BE7B")
)

# Formula-driven rule (e.g. flag rows where status is "Overdue")
ws.conditional_formatting.add(
    "A2:F100",
    FormulaRule(formula=['$C2="Overdue"'],
                fill=PatternFill(start_color="FFC7CE", end_color="FFC7CE", fill_type="solid"))
)
```

## Reusable named styles (for consistency across many sheets)

```python
title_style = NamedStyle(name="title_style")
title_style.font = Font(size=16, bold=True, color="1F4E78")
wb.add_named_style(title_style)
ws["A1"].style = "title_style"
```

## Table objects (banded rows, built-in filter dropdowns)

```python
from openpyxl.worksheet.table import Table, TableStyleInfo

tab = Table(displayName="SalesTable", ref=f"A1:{get_column_letter(ws.max_column)}{ws.max_row}")
tab.tableStyleInfo = TableStyleInfo(name="TableStyleMedium9", showRowStripes=True)
ws.add_table(tab)
```

## Gotchas

- **Merged cells**: only the top-left cell of a merge accepts a `.value` or most style writes; the rest are `MergedCell` objects. Style the top-left cell, or unmerge, style each cell, and re-merge if every cell in the range needs identical formatting (e.g. a border).
- **Colors are hex ARGB/RGB strings without `#`** (`"FF0000"` not `"#FF0000"`) — a leading `#` is silently ignored or errors depending on openpyxl version.
- **Number format vs. text**: don't format a numeric-looking value by converting it to a string (`f"${value:,.0f}"`) — that breaks `SUM`/sorting/conditional formatting downstream. Keep the cell numeric and set `.number_format` instead.
- **Conditional formatting ranges use A1-style strings**, not row/column indices — double-check the range matches the actual data extent, especially after rows are added or removed.
- **Column width units are approximate character widths**, not pixels or points — there's no exact conversion, so `min(max(...), cap)` heuristics (as above) are the practical approach, not a formula for a guaranteed pixel width.
- **Styling a file with a pandas round-trip destroys it.** `pd.read_excel` → `pd.to_excel` rebuilds the sheet from the DataFrame alone, discarding every style, conditional format, and chart not represented in the data. Always style via `openpyxl.load_workbook` directly on the target file.
