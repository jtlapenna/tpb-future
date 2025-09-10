export const GET_STORE_IMAGES = `
    select ab.store_id, ab.id,ab.text,abl.codename,abl.special_type ,
    images.url
    from ad_banners as ab 
    LEFT JOIN ad_banner_locations as abl ON
    ab.ad_banner_location_id = abl.id
    LEFT JOIN images ON
    images.imageable_id = ab.id AND imageable_type = 'AdBanner'
    where ab.store_id = $1;
`;

export const GET_STORE_IMAGES_BY_COMPANY = `
WITH stores as (
	SELECT id from stores
	where client_id = $1
)

SELECT ab.store_id,
	ab.id,ab.text,abl.codename,abl.special_type ,
	images.url,
    ab.advertisable_id,
	ab.advertisable_type,
    assets.url as brand_url
	from ad_banners as ab 
	LEFT JOIN ad_banner_locations as abl ON
	ab.ad_banner_location_id = abl.id
	LEFT JOIN images ON
	images.imageable_id = ab.id AND imageable_type = 'AdBanner'
    LEFT JOIN assets ON assets.source_id = ab.id and assets.source_type = 'AdBanner'
WHERE ab.store_id IN (SELECT id from stores)
ORDER BY ab.store_id;
`;
