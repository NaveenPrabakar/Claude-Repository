---
name: text-fields
description: >
  This skill should be used when the user wants to "extract a column", "pull a field from a CSV/TSV",
  "cut out columns", "reorder columns", "convert CSV to TSV", "sum/average a numeric column", or
  otherwise work with delimited/column-based text data. Covers cut and awk based field extraction
  and simple column math.
metadata:
  version: "0.1.0"
---

# Text Fields

Wraps `cut` and `awk` for column/field-oriented operations on delimited text (CSV, TSV, whitespace-separated).

## Scripts

Run with `bash ${CLAUDE_PLUGIN_ROOT}/skills/text-fields/scripts/<script>.sh <args>`.

| Script | Purpose | Usage |
|---|---|---|
| `extract_columns.sh` | Extract one or more columns by number | `extract_columns.sh <file> <column_list> [delimiter]` |
| `extract_by_header.sh` | Extract a column by its header name (first row is header) | `extract_by_header.sh <file> <header_name> [delimiter]` |
| `reorder_columns.sh` | Reorder columns into a new sequence | `reorder_columns.sh <file> <column_order> [delimiter]` |
| `csv_to_tsv.sh` | Convert comma-delimited to tab-delimited | `csv_to_tsv.sh <file> [output_file]` |
| `tsv_to_csv.sh` | Convert tab-delimited to comma-delimited | `tsv_to_csv.sh <file> [output_file]` |
| `sum_column.sh` | Sum a numeric column | `sum_column.sh <file> <column_num> [delimiter]` |
| `avg_column.sh` | Average a numeric column | `avg_column.sh <file> <column_num> [delimiter]` |

`column_list` for `extract_columns.sh` is a comma-separated list matching `cut -f`, e.g. `1,3,5` or `1-3`.
`column_order` for `reorder_columns.sh` is a comma-separated list of 1-indexed column numbers in the new order, e.g. `3,1,2`.

## Workflow

1. Default delimiter is comma (`,`) since most "field extraction" requests are CSV-flavored; pass a tab (`$'\t'`) or other delimiter explicitly when the data isn't CSV.
2. Check whether the file has a header row before running `sum_column.sh`/`avg_column.sh` — skip row 1 if so (these scripts assume no header by default; mention this to the user and offer `tail -n +2` piping if needed).
3. For `extract_by_header.sh`, the script scans row 1 for a case-sensitive exact match; tell the user if no match is found rather than guessing.
4. If a file has quoted fields containing the delimiter (proper CSV quoting), these `cut`/`awk`-based scripts will mis-split — flag this to the user and recommend a dedicated CSV tool (e.g. Python `csv` module) for that edge case.

## Notes

- All extraction scripts print to stdout; redirect (`> out.csv`) to save.
