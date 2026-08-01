---
name: excel-data-wrangling
description: >
  This skill should be used when the user wants to clean, reshape, filter, merge,
  deduplicate, or restructure data inside an Excel workbook or CSV/TSV file.
  Trigger on phrases like "clean up this spreadsheet", "remove duplicates",
  "merge these two sheets", "split this column", "pivot this data", "reshape
  this table", "fix the messy headers", "combine these workbooks", "filter rows
  where...", or when the input is a messy/malformed tabular file that needs to
  become a proper structured spreadsheet. Covers pandas-based bulk transforms
  and openpyxl-based cell-level edits on existing workbooks.
metadata:
  version: "0.1.0"
---

# Excel Data Wrangling

Handle the "get the data into the right shape" half of spreadsheet work: reading messy input, cleaning it, and writing it back out as a clean workbook.

## Tool selection

| Situation | Tool |
|---|---|
| Reading/writing large tables, bulk transforms, joins, group-by, dedup | `pandas` (`read_excel`, `read_csv`, `to_excel`) |
| Editing specific cells in an existing workbook without disturbing the rest | `openpyxl`, loaded directly against that file |
| Quick structural look at a workbook before deciding a plan | `markitdown file.xlsx` for a per-sheet text preview (no cell coordinates — don't plan edits from it alone) |
| Reading a workbook that has both formulas and cached values | Two separate `load_workbook` calls: one default (formula strings), one `data_only=True` (cached values). One pass can't give you both. |

`openpyxl`, `pandas`, and `markitdown` are normally preinstalled in this environment — import directly rather than pip installing first. Only install if an import actually fails.

## Core workflow

1. **Inspect before touching.** Load the file and print `df.shape`, `df.dtypes`, `df.head()`, and `df.isna().sum()` (or the openpyxl equivalent: sheet names, dimensions, header row) before writing any transform. Never guess column names or header row position.
2. **Identify the real header row.** Messy exports often have title rows, merged banners, or blank rows above the real header. Detect it by scanning for the first row where most cells are non-null strings and the row below has a different dtype pattern, rather than assuming row 1.
3. **Normalize before deduping or joining.** Trim whitespace, unify case, and coerce types (dates, numbers stored as text) before running `drop_duplicates()` or a `merge()` — otherwise near-duplicates and mismatched keys slip through silently.
4. **State the join type explicitly.** When merging two sheets/files, pick `inner`/`left`/`right`/`outer` deliberately and report row counts before and after so silent row loss is visible.
5. **Preserve what you weren't asked to change.** If editing an existing workbook (not producing a brand-new one), open it with openpyxl and write only to the target cells/columns. A pandas round-trip (`read_excel` → `to_excel`) rebuilds the file from scratch and silently drops formatting, formulas, charts, and merged cells that weren't in the DataFrame — never do this on a file you were told to "edit" or "fix" unless the user wants a full rebuild.

## Common operations

**Deduplicate with a report, not silently:**
```python
before = len(df)
df = df.drop_duplicates(subset=["email"], keep="first")
print(f"Removed {before - len(df)} duplicate rows")
```

**Split one column into several:**
```python
df[["first_name", "last_name"]] = df["full_name"].str.split(" ", n=1, expand=True)
```

**Merge two sheets on a key, checking for unmatched rows:**
```python
merged = df_left.merge(df_right, on="order_id", how="left", indicator=True)
unmatched = merged[merged["_merge"] == "left_only"]
print(f"{len(unmatched)} rows in left had no match in right")
```

**Reshape wide-to-long (unpivot) or long-to-wide (pivot):**
```python
long_df = df.melt(id_vars=["region"], var_name="month", value_name="revenue")
wide_df = long_df.pivot(index="region", columns="month", values="revenue").reset_index()
```

**Filter with a readable boolean mask, not chained one-liners that hide intent:**
```python
mask = (df["status"] == "active") & (df["balance"] > 0)
filtered = df[mask]
```

**Combine many workbooks/sheets into one:**
```python
import glob
frames = [pd.read_excel(f, sheet_name="Data") for f in glob.glob("inputs/*.xlsx")]
combined = pd.concat(frames, ignore_index=True)
```

**Surgical edit on an existing file with openpyxl (no rebuild):**
```python
from openpyxl import load_workbook
wb = load_workbook("workbook.xlsx")
ws = wb["Sheet1"]
for row in ws.iter_rows(min_row=2):
    if row[3].value == "N/A":
        row[3].value = None
wb.save("workbook.xlsx")
```

## Gotchas

- **Merged cells**: only the top-left cell of a merged range holds a value in openpyxl; every other cell in the range is a read-only `MergedCell`. Unmerge first (`ws.unmerge_cells(...)`) if you need to write across the range.
- **Numbers stored as text**: a column that looks numeric but sorts/filters wrong is usually text — check `df["col"].apply(type).value_counts()` and coerce with `pd.to_numeric(df["col"], errors="coerce")`.
- **Dates**: Excel serial dates read into pandas as numbers if the source cell wasn't formatted as a date. Verify with a spot check against a known row rather than assuming `pd.to_datetime` will guess correctly.
- **`.xlsm` files**: pass `keep_vba=True` to `load_workbook` or the macros are silently stripped on save.
- **Sheet names with spaces**: must be quoted in any formula reference that touches them (`'Q1 Data'!A1`), otherwise Excel evaluates it as `#VALUE!` — relevant when writing formulas that reference a sheet this skill just created.
- **A pandas round-trip is destructive to everything not in the DataFrame** (formatting, formulas, charts, comments). Route full-file edits through the `excel-formula-engine` or `excel-styling-formatting` skills, which use openpyxl in place, when the original workbook's formatting or formulas need to survive.

## After writing output

If the output workbook contains any formulas (including ones this skill added, like a totals row), recalculate before delivering it — see `../excel-formula-engine/SKILL.md` and `../../shared/scripts/recalc.py`. A pandas-only write (`to_excel`, no formulas) doesn't need this step.
