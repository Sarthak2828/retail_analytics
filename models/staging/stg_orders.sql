with source as (
    select * from {{ source('instacart', 'orders') }} --source function to pull data from the source table defined in sources.yml file
),

renamed as (
    select
        order_id,
        user_id,
        order_number,
        order_dow,
        order_hour_of_day,
        days_since_prior_order
    from source
)

select * from renamed