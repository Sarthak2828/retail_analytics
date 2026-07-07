select 
    order_number,
    customer_segment,
    avg(products_per_order) as avg_products
from (
    select 
        order_id,
        order_number,
        customer_segment,
        count(product_id) as products_per_order
    from main.fct_orders
    join main.mart_customer_segments
        on mart_customer_segments.user_id = fct_orders.user_id
    where order_number <= 30
    group by order_id, customer_segment, order_number
)
group by order_number, customer_segment
order by order_number