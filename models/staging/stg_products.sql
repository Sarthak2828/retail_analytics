with source as (
    select * from {{ source('instacart', 'products') }} --source function to pull data from the source table defined in sources.yml file
),

renamed as (
    select
        product_id,
        TRIM(product_name) as product_name,
        aisle_id,
        department_id
    from source
)

select * from renamed