with source as (
    select * from {{ source('instacart', 'aisles') }} --source function to pull data from the source table defined in sources.yml file
),

renamed as (
    select
        aisle_id,
        aisle as aisle_name
    from source
)

select * from renamed