const GET_PRODUCTS_JOINS = ` 
    FROM store_products 
    LEFT JOIN product_values as pv ON pv.valuable_id = store_products.id AND pv.valuable_type = 'StoreProduct'
    LEFT JOIN images ON images.id = store_products.primary_image_id
    LEFT JOIN images as thumb ON thumb.id = store_products.thumb_image_id
`;

const TAGS_FILTER = ` 
    JOIN
    ( SELECT distinct taggings.taggable_id, taggings.taggable_type 
        FROM taggings 
        WHERE EXISTS (SELECT 1 FROM tags WHERE tags.id = taggings.tag_id AND tags.name IN ( $6 ))
    ) AS tags ON tags.taggable_id = store_products.id
    AND tags.taggable_type = 'StoreProduct'
`;

const GET_PRODUCTS_JOINS_BY_TAGS = `${GET_PRODUCTS_JOINS} ${TAGS_FILTER}`;

const GET_PRODUCTS_BY_PAGES = ` 
    SELECT 
        CTE.*,brands.name as brand_name 
    FROM CTE LEFT JOIN brands 
        ON brands.id = CTE.brand_id
    WHERE (category_id = $4 OR $4 = 0) AND (brand_id = $5 OR $5 = 0)
    ORDER BY {SORT_COLUMN} {SORT_ORDER}
    LIMIT $2 OFFSET $3
`;

const SELECT_PRODUCTS = `	
    SELECT
    store_products.id,
    store_products.name,
    store_products.store_category_id AS category_id,
    store_products.description,
    store_products.brand_id,
    images.url as image_url,
    thumb.url as thumb_image,
    store_products.stock as stock,
    pv.value as min_price,
    store_products.sku as sku
`;
const SELECT_PRODUCTS_BY_PROMITION = `,store_product_promotions.promotion`;

const SELECT_PRODUCTS_GROUP_BY = `
    WHERE store_products.store_id = $1
    --GROUP BY products.id,products.name,products.category_id,products.description
`;

const SELECT_IN_STOCK_PRODUCTS_GROUP_BY = `
WHERE store_products.store_id = $1 AND store_products.stock > 0
--GROUP BY products.id,products.name,products.category_id,products.description
`;

const SELECT_PRODUCTS_GROUP_BY_FEATURED = `
    WHERE store_products.store_id = $1 AND kiosk_products.featured = true
    --GROUP BY products.id,products.name,products.category_id,products.description
`;

const SELECT_PRODUCTS_GROUP_BY_ID = `
    WHERE store_products.id = $1
    --GROUP BY products.id,products.name,products.category_id,products.description
`;
const GET_PRODUCTS_JOINS_BY_PROMOTION = ` JOIN store_product_promotions ON store_product_promotions.store_product_id = store_products.id`;
const SELECT_PRODUCTS_GROUP_BY_PROMOTION = `,store_product_promotions.promotion
`;

const GET_PRODUCTS_JOINS_FEATURED = ` JOIN kiosk_products on kiosk_products.store_product_id = store_products.id`;

export const GET_FEATURED_PRODUCTS = `
    WITH CTE AS (
        ${SELECT_PRODUCTS}
        ${GET_PRODUCTS_JOINS}
        ${GET_PRODUCTS_JOINS_FEATURED}
        ${SELECT_PRODUCTS_GROUP_BY_FEATURED}
    )
    ${GET_PRODUCTS_BY_PAGES}
`;

export const GET_PRODUCTS_ON_SALES = `
    WITH CTE AS (
        ${SELECT_PRODUCTS}
        ${SELECT_PRODUCTS_BY_PROMITION}
        ${GET_PRODUCTS_JOINS}
        ${GET_PRODUCTS_JOINS_BY_PROMOTION}
        ${SELECT_PRODUCTS_GROUP_BY}
    )
    ${GET_PRODUCTS_BY_PAGES}
`;

const GET_PRODUCTS_JOINS_FAVORITE = ` JOIN favorites ON favorites."product_id" = store_products.id `;
const SELECT_PRODUCTS_FAVORITE_BY_USER_ID = `
    WHERE store_products.store_id = $1 AND favorites."user_id" = $6
    --GROUP BY products.id,products.name,products.category_id,products.description
`;
export const GET_FAVORITE_PRODUCTS = `
    WITH CTE AS (
        ${SELECT_PRODUCTS}
        ${GET_PRODUCTS_JOINS}
        ${GET_PRODUCTS_JOINS_FAVORITE}
        ${SELECT_PRODUCTS_FAVORITE_BY_USER_ID}
    )
    ${GET_PRODUCTS_BY_PAGES}
`;

export const GET_PRODUCTS = `
    WITH CTE AS (
        ${SELECT_PRODUCTS}
        ${GET_PRODUCTS_JOINS}
        ${SELECT_IN_STOCK_PRODUCTS_GROUP_BY}
    )
    ${GET_PRODUCTS_BY_PAGES}
`;

const GET_PRODUCTS_WITHOUT_PAGES = ` 
    SELECT 
        CTE.*,brands.name as brand_name 
    FROM CTE LEFT JOIN brands 
        ON brands.id = CTE.brand_id
`;

export const GET_PRODUCT_BY_ID = `
    WITH CTE AS (
        ${SELECT_PRODUCTS}
        ${GET_PRODUCTS_JOINS}
        ${SELECT_PRODUCTS_GROUP_BY_ID}
    )
    ${GET_PRODUCTS_WITHOUT_PAGES}
`;

export const GET_PRODUCTS_BY_TAG = `
    WITH CTE AS (
        ${SELECT_PRODUCTS}
        ${GET_PRODUCTS_JOINS_BY_TAGS}
        ${SELECT_PRODUCTS_GROUP_BY}
    )
    ${GET_PRODUCTS_BY_PAGES}
`;

const SELECT_PRODUCTS_GROUP_BY_SKU = `
    WHERE store_products.sku = $1
`;

export const GET_PRODUCT_BY_SKU = `
    WITH CTE AS (
        ${SELECT_PRODUCTS}
        ${GET_PRODUCTS_JOINS}
        ${SELECT_PRODUCTS_GROUP_BY_SKU}
    )
    ${GET_PRODUCTS_WITHOUT_PAGES}
`;

export const GET_PRODUCT_TAGS = `
SELECT tags.name
        FROM taggings 
        left join tags on tags.id = taggings.tag_id 
		where taggable_id = $1`;
