# Instacart Analytics Dashboard
## Customer Segmentation & Behavior Analysis
*Built on the Instacart Market Basket dataset using dbt + DuckDB*

---

## Overview

```sql kpi_total_users
select count(*) as total_users
from instacart.customer_segments
```

```sql kpi_reorder_rate
select round(avg(reorder_rate), 2) as avg_reorder_rate
from instacart.customer_segments
```

```sql kpi_top_department
select top_department
from instacart.customer_segments
group by top_department
order by count(*) desc
limit 1
```

<div style="display: flex; justify-content: center; gap: 2rem;">

<BigValue 
    data={kpi_total_users}
    value=total_users
    title="Total Customers"
/>

<BigValue 
    data={kpi_reorder_rate}
    value=avg_reorder_rate
    fmt=pct1
    title="Avg Reorder Rate"
/>

<BigValue 
    data={kpi_top_department}
    value=top_department
    title="Most Popular Department"
/>

</div>

---

## Customer Segments

*Customers are segmented into three tiers based on order frequency using percentile thresholds calculated from the full user population.*

```sql segments_summary
select 
    customer_segment,
    count(*) as total_users,
    round(avg(reorder_rate), 3) as avg_reorder_rate,
    round(avg(total_orders), 1) as avg_orders,
    round(avg(avg_basket_size), 1) as avg_basket_size
from instacart.customer_segments
group by customer_segment
order by avg_orders desc
```

<DataTable data={segments_summary}/>

*High Value customers place 8x more orders on average than Low Value customers and reorder at nearly 2.5x the rate.*

---

## Shopping Behavior

*How do customer segments differ in what they buy and how loyal they are?*

```sql dept_pref
select
    customer_segment,    
    top_department,
    count(user_id) as user_count
from instacart.customer_segments
where top_department != 'missing'
group by customer_segment, top_department
```

<BarChart
    data={dept_pref}
    x=top_department
    y=user_count
    series=customer_segment
    swapXY=true
    chartAreaHeight=400
    title="Department Preference by Customer Segment"
/>

*Produce dominates across all segments. High Value customers make up a disproportionate share of every department.*

```sql segment_comp
select
    customer_segment,    
    reorder_segment,
    count(user_id) as user_count
from instacart.customer_segments
group by customer_segment, reorder_segment
```

<BarChart
    data={segment_comp}
    x=customer_segment
    y=user_count
    series=reorder_segment
    swapXY=true
    chartAreaHeight=400
    title="High Value Customers Are Also the Most Loyal Reorderers"
/>

*Order frequency and reorder loyalty are correlated. Customers who order more also tend to buy the same products repeatedly.*

---

## Trends Over Time

*How does customer behavior evolve as shoppers gain experience on the platform?*

```sql basket_trend
select * from instacart.fct_orders
order by order_number
```

<LineChart
    data={basket_trend}
    x=order_number
    y=avg_products
    series=customer_segment
    chartAreaHeight=400
    yMin=9.5
    title="Basket Size Converges Across Customer Segments"
/>

*High Value customers start with slightly larger baskets but all segments converge to around 10 items by order 5 and remain stable thereafter*

---

## Explore the Data

*Select individual departments in the legend to isolate their reorder patterns.*

```sql reorder_vs_orders
select
    customer_segment,
    total_orders,
    round(reorder_rate, 3) as reorder_rate,
    top_department
from instacart.customer_segments
where top_department in ('produce', 'dairy eggs', 'beverages', 'snacks', 'frozen')
USING SAMPLE 5000
```

<ScatterPlot
    data={reorder_vs_orders}
    x=total_orders
    y=reorder_rate
    series=top_department
    title="Reorder Rate Rises With Order Frequency Across Top 5 Departments"
    pointSize=3
    opacity=0.5
    chartAreaHeight=400
    xMin=0
    yMin=0
/>

*Click any department in the legend to hide or show it. All five departments show the same upward trend. Loyal shoppers reorder more regardless of what they buy.*