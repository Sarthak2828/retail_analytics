with order_products as (
    select * from {{ ref('stg_order_products') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

final as (
    select
        order_products.order_id, -- order line identifier column
        order_products.product_id,
        order_products.add_to_cart_order,
        order_products.reordered,
        orders.user_id,
        orders.order_number,
        orders.order_dow,
        orders.order_hour_of_day,
        orders.days_since_prior_order
    from order_products
    left join orders on orders.order_id = order_products.order_id
)

select * from final

