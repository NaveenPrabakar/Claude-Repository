---
name: excel-automation-vba
description: >
  This skill should be used when the user wants to batch-process multiple
  Excel files, generate or edit VBA macros inside a .xlsm workbook, template
  out repeated report generation, or automate a repetitive spreadsheet workflow
  end-to-end. Trigger on phrases like "run this on every file in this folder",
  "do this for each sheet", "write a macro that", "automate this report",
  "generate one file per region", "batch convert these", or "set up a template
  I can reuse". Covers multi-file/multi-sheet orchestration and .xlsm macro
  handling — for single-file data cleaning use excel-data-wrangling instead.
metadata:
  version: "0.1.0"
---

# Excel Automation & VBA

Handle repeated or multi-file spreadsheet workflows: batch processing across many workbooks, generating one output per group, and reading/writing VBA macros in `.xlsm` files.

## Batch processing many files

```python
import glob
from pathlib import Path
from openpyxl import load_workbook

input_files = sorted(glob.glob("inputs/*.xlsx"))
results = []
for path in input_files:
    wb = load_workbook(path, data_only=True)
    ws = wb.active
    # ... extract/transform per file ...
    results.append({"file": Path(path).name, "total": ws["B10"].value})

print(f"Processed {len(results)} files, {len([r for r in results if r['total'] is None])} had missing totals")
```

Always print a per-file summary/count rather than silently looping — batch jobs fail quietly on one bad file otherwise, and the failure is invisible until someone notices missing output later.

## Generating one file per group (e.g. "one report per region")

```python
import pandas as pd

df = pd.read_excel("all_data.xlsx")
for region, group in df.groupby("Region"):
    out_path = f"outputs/report_{region.replace(' ', '_')}.xlsx"
    group.to_excel(out_path, index=False, sheet_name="Data")
```

For anything beyond a raw data dump per group (formulas, formatting, a template look), build one styled template workbook first with openpyxl, then copy it per group and write only the data cells — don't reconstruct formatting logic inside the loop.

## Reusable templates

1. Build a single template `.xlsx` with all formulas, formatting, named ranges, and static structure in place, with clearly marked input cells (a distinct fill color, and a legend explaining which cells to fill in).
2. For each run, copy the template file, then open the copy with openpyxl and write only into the marked input cells — never regenerate structure from scratch each time.
3. If formulas exist in the template, recalculate each generated copy before delivering it (see `../../shared/scripts/recalc.py` in `excel-formula-engine`).

```python
import shutil
shutil.copy("template.xlsx", f"outputs/report_{name}.xlsx")
wb = load_workbook(f"outputs/report_{name}.xlsx")
wb["Inputs"]["B2"] = value
wb.save(f"outputs/report_{name}.xlsx")
```

## VBA macros in .xlsm files

- **Always load with `keep_vba=True`**, or the macro project is silently dropped on save: `load_workbook("file.xlsm", keep_vba=True)`.
- **openpyxl cannot write or edit VBA code itself** — it preserves an existing macro project through a load/save cycle but has no API to author new macro source. To add or modify actual VBA code:
  1. Extract existing macro source for review/editing purposes using a library that reads the `vbaProject.bin` binary stream (e.g. `oletools`' `olevba`), or
  2. Write the desired VBA source as a `.bas`/`.cls` text file and give the user exact import instructions (Alt+F11 → right-click VBAProject → Import File), since round-tripping compiled VBA binary blobs programmatically is unreliable and easy to corrupt.
- When a user asks for "a macro that does X," default to writing the VBA source as readable text (in a `.bas` file or inline) with clear instructions for pasting it into the VBA editor, rather than attempting to inject compiled bytecode.
- Prefer a Python/openpyxl solution over VBA whenever the end goal is just "transform this data" — VBA is the right tool specifically when the user needs the automation to run *inside Excel* itself (a button, a `Workbook_Open` event, an in-app macro), not as a one-off external script.

### Example VBA macro (delivered as text for manual import)

```vba
Sub HighlightOverdue()
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Set ws = ActiveSheet
    lastRow = ws.Cells(ws.Rows.Count, "C").End(xlUp).Row
    For i = 2 To lastRow
        If ws.Cells(i, 3).Value = "Overdue" Then
            ws.Rows(i).Interior.Color = RGB(255, 199, 206)
        End If
    Next i
End Sub
```

## Gotchas

- **`.xlsm` vs `.xlsx`**: never save a macro-enabled workbook with a `.xlsx` extension — Excel will refuse to open it or silently strip the macros. Keep the extension `.xlsm` throughout, and pass `keep_vba=True` on every load.
- **Batch jobs need per-item error isolation.** Wrap each file's processing in a try/except that logs the failing filename and continues, rather than letting one malformed input file crash the entire batch silently mid-run.
- **Recalculation cost scales with file count.** Running `recalc.py` (a LibreOffice subprocess) per file in a large batch is slow — recalculate once per generated file, not repeatedly during iterative editing of the same file.
- **Templates drift.** If a template is edited, regenerate a fresh baseline rather than patching already-generated output files individually — divergence between "what the template says" and "what past outputs contain" is a common silent bug in recurring-report setups.
