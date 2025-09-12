-- Populate store_products table with data from the existing products table
-- This script migrates the basic product data to the new schema

-- Connect to the database
\c tpb_ecommerce;

-- Insert sample images first
INSERT INTO images (id, url, alt_text) VALUES
(1, 'https://via.placeholder.com/300x300/4CAF50/white?text=Blue+Dream', 'Blue Dream Flower'),
(2, 'https://via.placeholder.com/300x300/8BC34A/white?text=OG+Kush', 'OG Kush Flower'),
(3, 'https://via.placeholder.com/300x300/FF9800/white?text=Sour+Diesel', 'Sour Diesel Flower'),
(4, 'https://via.placeholder.com/300x300/9C27B0/white?text=Purple+Haze', 'Purple Haze Flower'),
(5, 'https://via.placeholder.com/300x300/607D8B/white?text=White+Widow', 'White Widow Flower'),
(6, 'https://via.placeholder.com/300x300/795548/white?text=Cookies', 'Chocolate Chip Cookies'),
(7, 'https://via.placeholder.com/300x300/E91E63/white?text=Gummies', 'Gummy Bears'),
(8, 'https://via.placeholder.com/300x300/3F51B5/white?text=Brownies', 'Brownie Bites'),
(9, 'https://via.placeholder.com/300x300/FF5722/white?text=Candies', 'Hard Candies'),
(10, 'https://via.placeholder.com/300x300/00BCD4/white?text=Live+Resin', 'Live Resin'),
(11, 'https://via.placeholder.com/300x300/FFC107/white?text=Shatter', 'Shatter'),
(12, 'https://via.placeholder.com/300x300/4CAF50/white?text=Wax', 'Wax'),
(13, 'https://via.placeholder.com/300x300/8BC34A/white?text=Rosin', 'Rosin'),
(14, 'https://via.placeholder.com/300x300/FF9800/white?text=Vape+Cart', 'Vape Cartridge'),
(15, 'https://via.placeholder.com/300x300/9C27B0/white?text=Vape+Pen', 'Disposable Vape'),
(16, 'https://via.placeholder.com/300x300/607D8B/white?text=CBD+Oil', 'CBD Oil'),
(17, 'https://via.placeholder.com/300x300/795548/white?text=CBD+Gummies', 'CBD Gummies'),
(18, 'https://via.placeholder.com/300x300/E91E63/white?text=CBD+Cream', 'CBD Cream'),
(19, 'https://via.placeholder.com/300x300/3F51B5/white?text=Glass+Pipe', 'Glass Pipe'),
(20, 'https://via.placeholder.com/300x300/FF5722/white?text=Grinder', 'Grinder'),
(21, 'https://via.placeholder.com/300x300/00BCD4/white?text=Papers', 'Rolling Papers'),
(22, 'https://via.placeholder.com/300x300/FFC107/white?text=OG+Kush+Vape', 'OG Kush Vape');

-- Insert store_products data (migrating from products table)
INSERT INTO store_products (id, name, description, store_id, store_category_id, brand_id, sku, stock, primary_image_id, thumb_image_id) VALUES
-- Store 1 (Downtown Dispensary) - Flower products
(1, 'Blue Dream Flower - Premium', 'Classic sativa-dominant hybrid with sweet berry aroma. Perfect for daytime use with uplifting effects.', 1, 1, 1, 'BD-FLOWER-001', 50, 1, 1),
(2, 'OG Kush - Indica', 'Indica-dominant strain with earthy, pine flavors. Great for relaxation and pain relief.', 1, 1, 2, 'OG-FLOWER-001', 30, 2, 2),
(3, 'Sour Diesel - Sativa', 'Energizing sativa with diesel and citrus notes. Ideal for creative activities and focus.', 1, 1, 3, 'SD-FLOWER-001', 25, 3, 3),
(4, 'Purple Haze - Sativa', 'Fruity sativa with grape and berry flavors. Uplifting and euphoric effects.', 1, 1, 3, 'PH-FLOWER-001', 40, 4, 4),
(5, 'White Widow - Hybrid', 'Balanced hybrid with earthy, woody taste. Perfect balance of relaxation and energy.', 1, 1, 1, 'WW-FLOWER-001', 35, 5, 5),

-- Store 1 - Edibles
(6, 'Chocolate Chip Cookies - 10mg THC', 'Delicious homemade-style cookies with 10mg THC each. Perfect for beginners.', 1, 2, 4, 'COOKIES-10MG', 20, 6, 6),
(7, 'Gummy Bears - Mixed Fruit', 'Mixed fruit gummies with 5mg THC per piece. Great for micro-dosing.', 1, 2, 4, 'GUMMIES-5MG', 30, 7, 7),
(8, 'Brownie Bites - 15mg THC', 'Rich chocolate brownies with 15mg THC each. For experienced users.', 1, 2, 4, 'BROWNIES-15MG', 15, 8, 8),
(9, 'Hard Candies - Assorted', 'Assorted fruit flavors with 2mg THC per candy. Discreet and portable.', 1, 2, 4, 'CANDIES-2MG', 25, 9, 9),

-- Store 1 - Concentrates
(10, 'Live Resin - Blue Dream', 'Fresh-frozen extract with full terpene profile. Premium concentrate experience.', 1, 3, 1, 'LR-BD-001', 10, 10, 10),
(11, 'Shatter - OG Kush', 'Glass-like concentrate with 85% THC. High potency for experienced users.', 1, 3, 2, 'SH-OG-001', 8, 11, 11),
(12, 'Wax - Sour Diesel', 'Budder consistency concentrate. Easy to work with and potent.', 1, 3, 3, 'WAX-SD-001', 12, 12, 12),
(13, 'Rosin - Purple Haze', 'Solventless pressed extract. Clean and pure concentrate.', 1, 3, 3, 'ROS-PH-001', 6, 13, 13),

-- Store 1 - Vapes
(14, 'Blue Dream Vape Cartridge', '0.5g vape cartridge with sativa effects. Convenient and discreet.', 1, 4, 1, 'VAPE-BD-05G', 20, 14, 14),
(15, 'Disposable Vape Pen', 'All-in-one disposable vape with 0.3g. No charging or refilling needed.', 1, 4, 5, 'VAPE-DISP-03G', 15, 15, 15),

-- Store 1 - Accessories
(20, 'Glass Pipe - Hand Blown', 'Beautiful hand-blown glass pipe. Durable and easy to clean.', 1, 5, 5, 'PIPE-GLASS-001', 10, 19, 19),
(21, '4-Piece Grinder', 'Premium aluminum grinder with pollen catcher. Sharp teeth for easy grinding.', 1, 5, 5, 'GRINDER-4PC', 8, 20, 20),
(22, 'Hemp Rolling Papers', 'Premium hemp rolling papers. Slow burning and natural.', 1, 5, 5, 'PAPERS-HEMP', 25, 21, 21),

-- Store 2 (Westside Cannabis) - Some overlapping products
(23, 'OG Kush - Indica', 'Indica-dominant strain with earthy, pine flavors. Great for relaxation and pain relief.', 2, 6, 2, 'OG-FLOWER-002', 20, 2, 2),
(24, 'Blue Dream Vape Cartridge', '0.5g vape cartridge with sativa effects. Convenient and discreet.', 2, 9, 1, 'VAPE-BD-05G-2', 15, 14, 14),
(25, 'Gummy Bears - Mixed Fruit', 'Mixed fruit gummies with 5mg THC per piece. Great for micro-dosing.', 2, 7, 4, 'GUMMIES-5MG-2', 20, 7, 7),

-- Store 3 (Green Valley Store) - CBD focused
(26, 'CBD Oil Tincture - 1000mg', 'Full spectrum CBD oil for wellness and relaxation. No psychoactive effects.', 3, 10, 4, 'CBD-OIL-1000', 12, 16, 16),
(27, 'CBD Gummies - 25mg', 'CBD-only gummies with 25mg per piece. Perfect for daily wellness.', 3, 10, 4, 'CBD-GUMMIES-25', 18, 17, 17),
(28, 'CBD Topical Cream', 'Pain relief cream with CBD. Apply directly to affected areas.', 3, 12, 4, 'CBD-CREAM-001', 10, 18, 18);

-- Insert product values (pricing)
INSERT INTO product_values (valuable_id, valuable_type, attribute_name, value) VALUES
-- Flower pricing
(1, 'StoreProduct', 'min_price', '45.00'),
(2, 'StoreProduct', 'min_price', '50.00'),
(3, 'StoreProduct', 'min_price', '48.00'),
(4, 'StoreProduct', 'min_price', '52.00'),
(5, 'StoreProduct', 'min_price', '47.00'),

-- Edibles pricing
(6, 'StoreProduct', 'min_price', '12.00'),
(7, 'StoreProduct', 'min_price', '15.00'),
(8, 'StoreProduct', 'min_price', '18.00'),
(9, 'StoreProduct', 'min_price', '8.00'),

-- Concentrates pricing
(10, 'StoreProduct', 'min_price', '65.00'),
(11, 'StoreProduct', 'min_price', '70.00'),
(12, 'StoreProduct', 'min_price', '60.00'),
(13, 'StoreProduct', 'min_price', '75.00'),

-- Vapes pricing
(14, 'StoreProduct', 'min_price', '35.00'),
(15, 'StoreProduct', 'min_price', '25.00'),

-- Accessories pricing
(20, 'StoreProduct', 'min_price', '30.00'),
(21, 'StoreProduct', 'min_price', '25.00'),
(22, 'StoreProduct', 'min_price', '5.00'),

-- Store 2 products
(23, 'StoreProduct', 'min_price', '48.00'),
(24, 'StoreProduct', 'min_price', '32.00'),
(25, 'StoreProduct', 'min_price', '14.00'),

-- Store 3 CBD products
(26, 'StoreProduct', 'min_price', '80.00'),
(27, 'StoreProduct', 'min_price', '35.00'),
(28, 'StoreProduct', 'min_price', '45.00');

-- Insert some featured products
INSERT INTO kiosk_products (store_product_id, featured) VALUES
(1, true),  -- Blue Dream featured
(6, true),  -- Cookies featured
(10, true), -- Live Resin featured
(14, true), -- Vape cartridge featured
(26, true); -- CBD Oil featured

-- Insert some product tags
INSERT INTO taggings (taggable_id, taggable_type, tag_id) VALUES
-- Blue Dream tags
(1, 'StoreProduct', 1), -- Sativa
(1, 'StoreProduct', 7), -- Premium

-- OG Kush tags
(2, 'StoreProduct', 2), -- Indica
(2, 'StoreProduct', 8), -- Best Seller

-- Sour Diesel tags
(3, 'StoreProduct', 1), -- Sativa
(3, 'StoreProduct', 4), -- High THC

-- CBD products tags
(26, 'StoreProduct', 5), -- CBD Rich
(26, 'StoreProduct', 6), -- Organic
(27, 'StoreProduct', 5), -- CBD Rich
(28, 'StoreProduct', 5); -- CBD Rich

-- Display summary
SELECT 'Store products populated successfully!' as status;
SELECT 'Store Products: ' || COUNT(*) as store_products_count FROM store_products;
SELECT 'Images: ' || COUNT(*) as images_count FROM images;
SELECT 'Product Values: ' || COUNT(*) as product_values_count FROM product_values;
SELECT 'Featured Products: ' || COUNT(*) as featured_count FROM kiosk_products WHERE featured = true;
SELECT 'Product Tags: ' || COUNT(*) as taggings_count FROM taggings;
