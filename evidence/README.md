# Instacart Analytics Dashboard — Evidence + DuckDB

## Overview
An interactive analytics dashboard built on top of the retail_analytics dbt project,
visualizing customer segmentation and behavioral patterns from the
[Instacart Market Basket dataset](https://www.kaggle.com/datasets/yasserh/instacart-online-grocery-basket-analysis-dataset)
using Evidence.dev and DuckDB.

## Tech Stack
- **Evidence.dev** — SQL-driven dashboard framework
- **DuckDB** — local analytical warehouse (shared with dbt project)
- **Node.js 24** — Evidence runtime

## Dashboard Structure

Four sections covering the full analytical narrative:

| Section | Content |
|---|---|
| Overview | KPI cards — total customers, avg reorder rate, most popular department |
| Customer Segments | Segment summary table with behavioral metrics by tier |
| Shopping Behavior | Department preference by segment, loyalty overlap across tiers |
| Trends Over Time | Basket size trend across first 30 orders by segment |
| Explore the Data | Interactive scatter plot — reorder rate vs order frequency by department |

## Key Findings

- **High Value customers place 8x more orders** than Low Value customers and reorder at nearly 2.5x the rate
- **Produce dominates across all segments** — High Value customers make up a disproportionate share of every department
- **Order frequency and reorder loyalty are correlated** — the same customers who order most also reorder most
- **Basket size converges by order 5** — High Value customers start with slightly larger baskets but all segments stabilize around 10 items

## How to Run

### Prerequisites
- Node.js 18+
- dbt project set up with `dev.duckdb` built at the project root
- See the main [README](../README.md) for dbt setup instructions

### Setup

**1. Navigate to the evidence folder**

```bash
cd evidence
```

**2. Install dependencies**

```bash
npm install
```

**3. Load sources**

```bash
npm run sources
```

**4. Start the dev server**

```bash
npm run dev
```

Navigate to `http://localhost:3000`

## Key Concepts Demonstrated
- **BI as code** — dashboards defined in SQL and Markdown, version controlled alongside the dbt project
- **Pre-aggregated sources** — large fact tables aggregated at the source layer to keep Evidence performant
- **Insight-driven titles** — chart titles state the finding, not just the metric
- **Interactive exploration** — legend-based series filtering for ad hoc department analysis