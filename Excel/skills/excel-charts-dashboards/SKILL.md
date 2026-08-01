---
name: excel-charts-dashboards
description: >
  This skill should be used when the user wants a chart, pivot table, sparkline,
  or dashboard-style summary sheet built inside an Excel workbook. Trigger on
  phrases like "add a chart", "chart this data", "make a bar/line/pie chart",
  "build a pivot table", "summarize this into a dashboard", "add sparklines",
  "visualize this in Excel", or "create a summary sheet". Covers native
  openpyxl chart objects and PivotTable-equivalent aggregation, not the
  Visualizer inline-widget tool — this skill's output lives inside the
  .xlsx file itself.
metadata:
  version: "0.1.0"
---

# Excel Charts & Dashboards

Build native, editable Excel charts and pivot-style summaries that live inside the workbook — not images or external visuals. The output should look and behave like something a person built by hand in Excel: it stays interactive and updates if the user changes source data and re-triggers a refresh.

## Choosing a chart type

| Data shape | Chart |
|---|---|
| Comparing categories | Bar/column chart |
| Trend over time | Line chart |
| Part-to-whole, few categories (≤6) | Pie chart — avoid for more categories, it becomes unreadable |
| Two numeric variables, looking for correlation | Scatter chart |
| Distribution across many categories at once | Stacked bar/column |
| Multiple metrics, different scales | Combo chart (bar + line on secondary axis) |

Never default to pie charts for more than ~6 slices, and never use 3D chart variants — they distort proportions and are hard to read.

## Native charts with openpyxl

```python
from openpyxl.chart import BarChart, LineChart, PieChart, ScatterChart, Reference, Series

wb = load_workbook("workbook.xlsx")
ws = wb["Data"]

chart = BarChart()
chart.type = "col"
chart.title = "Revenue by Region"
chart.y_axis.title = "Revenue ($)"
chart.x_axis.title = "Region"

data = Reference(ws, min_col=2, min_row=1, max_row=ws.max_row, max_col=2)  # includes header for series name
categories = Reference(ws, min_col=1, min_row=2, max_row=ws.max_row)
chart.add_data(data, titles_from_data=True)
chart.set_categories(categories)

ws.add_chart(chart, "E2")  # anchor cell for top-left corner
wb.save("workbook.xlsx")
```

**Combo chart (bar + line on a secondary axis)** — build two chart objects and combine them:
```python
bar = BarChart()
bar.add_data(Reference(ws, min_col=2, min_row=1, max_row=ws.max_row), titles_from_data=True)

line = LineChart()
line.add_data(Reference(ws, min_col=3, min_row=1, max_row=ws.max_row), titles_from_data=True)
line.y_axis.axId = 200
line.y_axis.title = "Growth %"
line.y_axis.crosses = "max"

bar += line  # combines onto one chart object
ws.add_chart(bar, "E2")
```

## Pivot-style summaries (aggregate, not a live Excel PivotTable object)

openpyxl cannot create a true interactive Excel PivotTable object — build the aggregation in pandas and write the result as a formatted summary table, which covers the vast majority of "give me a pivot table" requests and is more portable:

```python
summary = df.pivot_table(index="Region", columns="Quarter", values="Revenue",
                          aggfunc="sum", fill_value=0, margins=True, margins_name="Total")
summary.to_excel(writer, sheet_name="Summary")
```

If the user specifically needs a native, Excel-refreshable PivotTable (e.g. they want to change fields themselves in Excel), say so explicitly and note it requires building the workbook with a real PivotCache — flag this as a manual step to complete in Excel (Insert > PivotTable) rather than silently substituting a static summary and calling it a pivot table.

## Sparklines

openpyxl doesn't support native Excel sparklines directly. Two options:
1. Write a compact `LineChart` sized to fit in a single cell's row height as a visual approximation.
2. Note to the user that true inline sparklines (Insert > Sparklines in Excel) need to be added in Excel itself, and provide the exact data range to select.

## Dashboard sheet layout

For a "summarize this into a dashboard" request:
1. Put raw/detail data on its own sheet, kept out of view of the summary.
2. Build a dedicated `Dashboard` sheet with: a title row, 2–4 key summary numbers as large bold cells (each driven by a formula referencing the data sheet, never hardcoded), and 1–3 charts anchored below.
3. Keep every dashboard number formula-driven (`=SUM(Data!C:C)`, not a typed-in total) so it updates if source data changes.
4. Order charts by importance top-to-bottom/left-to-right — don't just place them in creation order.

## Gotchas

- **`Reference` ranges are 1-indexed and inclusive of `max_row`/`max_col`** — an off-by-one here is the most common cause of a chart that's missing the last data point or includes a stray blank row.
- **`titles_from_data=True` requires the header row inside the `Reference` range** (`min_row=1`, not `min_row=2`) — otherwise the series legend shows a generic "Series1" instead of the column header.
- **Chart data must already exist in the sheet.** openpyxl charts reference live cell ranges, not values passed in Python — write the data to cells first, then build the `Reference` against those cells.
- **Anchoring**: the string passed to `ws.add_chart(chart, "E2")` places the chart's top-left corner at that cell; charts float above the grid and can visually overlap data if the anchor and chart size aren't checked against the sheet's actual content extent.
- **A pandas-only round-trip (`to_excel`) will not preserve charts** created by a prior openpyxl pass on the same file — build charts as the last step, directly with openpyxl, after any pandas-based data writes are done.
