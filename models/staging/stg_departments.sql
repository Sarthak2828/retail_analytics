with source as (
    select * from {{ source('instacart', 'departments') }} --source function to pull data from the source table defined in sources.yml file
),

renamed as (
    select
        department_id,
        department as department_name
    from source
)

select * from renamed