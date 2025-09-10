export const GET_BRANDS_BY_STORE = `
WITH CTE AS (
    SELECT sp.brand_id ,
    MAX(featured::TEXT) as featured,
        (SELECT COUNT(1) FROM store_products WHERE store_products.store_id = $1 AND 
		store_products.brand_id = sp.brand_id AND store_products.stock>0) as products
        
        FROM public.store_products as sp LEFT JOIN 
        kiosk_products on kiosk_products.store_product_id = sp.id
        where sp.store_id = $1
        GROUp BY sp.brand_id)
    
    SELECT brands.*,CTE.featured::BOOL,assets.url as logo
    ,SUBSTRING(brands.name,1,1) as initial
    from brands JOIN CTE ON CTE.brand_id = brands.id
    LEFT JOIN assets ON assets.source_id = brands.Id and source_type = 'Brand'
    WHERE CTE.products >0
    LIMIT $3 OFFSET $2
`;
