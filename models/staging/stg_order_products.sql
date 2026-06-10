with source as (
    select * from {{ source('instacart', 'order_products__prior') }} --source function to pull data from the source table defined in sources.yml file
),

renamed as (
    select
        CAST(order_id AS INTEGER) as order_id, --cast to integer for consistency with stg_orders model
        CAST(product_id AS INTEGER) as product_id, --cast to integer for consistency with stg_products model
        CAST(add_to_cart_order AS INTEGER) as add_to_cart_order, --cast to integer for constistency
        CAST(reordered AS BOOLEAN) as reordered --cast to boolean for better data representation
    from source
)

select * from renamed