with users as (
    select * from {{ ref('dim_users') }}
),

orders as (
    select * from {{ ref('fct_orders') }}
),

products as (
    select * from {{ ref('dim_products') }}
),

--order department table to calculate department level metrics for each user
order_dept as (
    select
        orders.user_id,
        orders.order_id,
        orders.product_id,
        products.department_id,
        products.department_name
    from orders
    left join products on orders.product_id = products.product_id
),

dept_counts as (
    select
        user_id,
        department_id,
        department_name,
        count(product_id) as product_count
    from order_dept
    group by user_id, department_id, department_name
),

--top departments per user
dept_rank as (
    select
        user_id,
        department_name,
        product_count,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY product_count DESC) as dept_rank
    from dept_counts
),

--top department
top_dept as (
    select
        user_id,
        department_name as top_department
    from dept_rank
    where dept_rank = 1
),

--percentiles p33 and p66 thresholds for segmentation
percentiles as (
    select
        PERCENTILE_CONT(0.33) WITHIN GROUP (ORDER BY total_orders) as p33_orders,
        PERCENTILE_CONT(0.66) WITHIN GROUP (ORDER BY total_orders) as p66_orders,
        PERCENTILE_CONT(0.33) WITHIN GROUP (ORDER BY reorder_rate) as p33_reorder,
        PERCENTILE_CONT(0.66) WITHIN GROUP (ORDER BY reorder_rate) as p66_reorder
    from users
),

--bring it all together and create segments
final as (
    select
    users.user_id,
    users.total_orders,
    users.reorder_rate,
    users.avg_days_between_orders,
    users.avg_basket_size,
    top_dept.top_department,
    CASE
        WHEN users.total_orders >= percentiles.p66_orders THEN 'High Value'
        WHEN users.total_orders >= percentiles.p33_orders THEN 'Mid Value'
        ELSE 'Low Value'
    END AS customer_segment,
    CASE
        WHEN users.reorder_rate >= percentiles.p66_reorder THEN 'High Reorder'
        WHEN users.reorder_rate >= percentiles.p33_reorder THEN 'Mid Reorder'
        ELSE 'Low Reorder'
    END AS reorder_segment
    from users
    cross join percentiles
    left join top_dept on users.user_id = top_dept.user_id
)

select * from final