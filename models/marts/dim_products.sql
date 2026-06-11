with products as (
    select * from {{ ref('stg_products') }}
),

aisles as (
    select * from {{ ref('stg_aisles') }}
),

departments as (
    select * from {{ ref('stg_departments') }}
),

final as (
    select
        products.product_id,
        products.product_name,
        aisles.aisle_id,
        aisles.aisle_name,
        departments.department_id,
        departments.department_name
    from products
    left join aisles on aisles.aisle_id = products.aisle_id
    left join departments on departments.department_id = products.department_id
)

select * from final