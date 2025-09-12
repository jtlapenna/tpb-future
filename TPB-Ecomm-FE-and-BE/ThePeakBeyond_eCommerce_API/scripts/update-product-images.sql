-- Update product images to use real images instead of placeholders
-- This script updates the images table with actual product image URLs

\c tpb_ecommerce;

-- Update images table with real product images
-- Flower products
UPDATE images SET url = '/images/products/blue-dream-flower.jpg', alt_text = 'Blue Dream Flower' WHERE id = 1;
UPDATE images SET url = '/images/products/og-kush-indica.webp', alt_text = 'OG Kush Indica' WHERE id = 2;
UPDATE images SET url = '/images/products/sour-diesel-sativa.png', alt_text = 'Sour Diesel Sativa' WHERE id = 3;
UPDATE images SET url = '/images/products/purple-haze-sativa.png', alt_text = 'Purple Haze Sativa' WHERE id = 4;
UPDATE images SET url = '/images/products/white-widow-hybrid.webp', alt_text = 'White Widow Hybrid' WHERE id = 5;

-- Edible products
UPDATE images SET url = '/images/products/chocolate-chip-cookies.jpg', alt_text = 'Chocolate Chip Cookies' WHERE id = 6;
UPDATE images SET url = '/images/products/gummy-bears.jpg', alt_text = 'Gummy Bears' WHERE id = 7;
UPDATE images SET url = '/images/products/hard-candies.webp', alt_text = 'Hard Candies' WHERE id = 9;

-- Concentrate products
UPDATE images SET url = '/images/products/live-resin.jpg', alt_text = 'Live Resin' WHERE id = 10;
UPDATE images SET url = '/images/products/shatter.jpg', alt_text = 'Shatter' WHERE id = 11;
UPDATE images SET url = '/images/products/wax.jpg', alt_text = 'Wax' WHERE id = 12;
UPDATE images SET url = '/images/products/rosin.jpg', alt_text = 'Rosin' WHERE id = 13;

-- Vape products
UPDATE images SET url = '/images/products/vape-cartridge.webp', alt_text = 'Vape Cartridge' WHERE id = 14;
UPDATE images SET url = '/images/products/disposable-vape.jpg', alt_text = 'Disposable Vape' WHERE id = 15;

-- CBD products
UPDATE images SET url = '/images/products/cbd-oil.jpg', alt_text = 'CBD Oil' WHERE id = 16;
UPDATE images SET url = '/images/products/cbd-gummies.jpg', alt_text = 'CBD Gummies' WHERE id = 17;
UPDATE images SET url = '/images/products/cbd-cream.jpg', alt_text = 'CBD Cream' WHERE id = 18;

-- Accessories
UPDATE images SET url = '/images/products/glass-pipe.jpg', alt_text = 'Glass Pipe' WHERE id = 19;
UPDATE images SET url = '/images/products/grinder.jpg', alt_text = 'Grinder' WHERE id = 20;
UPDATE images SET url = '/images/products/rolling-papers.jpg', alt_text = 'Rolling Papers' WHERE id = 21;

-- Display success message
SELECT 'Product images updated successfully!' as status;
