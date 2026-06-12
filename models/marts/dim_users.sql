with orders as (
    select * from {{ ref('fct_orders') }}
),

--base table with user level metrics
user_orders as (
    select
        user_id,
        MIN(order_number) as first_order_number,
        MAX(order_number) as last_order_number,
        COUNT(DISTINCT order_id) as total_orders,
        COUNT(product_id) as total_products_ordered,
        SUM(CASE WHEN reordered = True THEN 1 ELSE 0 END) as total_reorders,   
        AVG(days_since_prior_order) as avg_days_between_orders
    from orders
    group by user_id
),

--calculate count of products per order for each user and order combination
basket_size as (
    select
        user_id,
        order_id,
        count(product_id) as products_per_order
    from orders
    group by user_id, order_id
),

--calculate average basket size for each user
avg_basket_size as (
    select
        user_id,
        AVG(products_per_order) as avg_basket_size
    from basket_size
    group by user_id
),

--final table with all user metrics
final as (
    select
        user_orders.user_id,
        first_order_number,
        last_order_number,
        total_orders,
        total_products_ordered,
        total_reorders,
        total_reorders/total_products_ordered as reorder_rate,
        avg_days_between_orders,
        avg_basket_size
    from user_orders
    left join avg_basket_size on user_orders.user_id = avg_basket_size.user_id
)

select * from final