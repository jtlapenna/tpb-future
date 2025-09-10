export const GET_TAGS_BY_STORE = `
SELECT ts.name FROM taggings tgs INNER JOIN tags ts ON ts.id = tgs.tag_id WHERE taggable_type = 'StoreProduct' 
AND  EXISTS (
	SELECT 1 from store_products where store_id = $1 AND id = taggable_id
	and (store_category_id = $2 OR $2 = -1)
)
GROUP BY ts.name
`;
