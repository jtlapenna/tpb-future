-- The Peak Beyond E-commerce Database Seeding Script
-- This script populates the database with comprehensive test data

-- Connect to the database
\c tpb_ecommerce;

-- Clear existing data (in case of re-seeding)
TRUNCATE TABLE favorites, products, store_categories, brands, stores, store_settings, tags RESTART IDENTITY CASCADE;

-- Insert sample companies/clients
INSERT INTO clients (id, name, active, created_at) VALUES
(1, 'The Peak Beyond', true, NOW()),
(2, 'Cannabis Co', true, NOW());

-- Insert sample stores
INSERT INTO stores (id, name, client_id, tax, active, created_at, api_settings) VALUES
(1, 'Downtown Dispensary', 1, '8.5', true, NOW(), '{"api_key": "test_key", "sync_enabled": true}'),
(2, 'Westside Cannabis', 1, '8.5', true, NOW(), '{"api_key": "test_key_2", "sync_enabled": true}'),
(3, 'Green Valley Store', 2, '9.0', true, NOW(), '{"api_key": "test_key_3", "sync_enabled": true}');

-- Insert sample brands
INSERT INTO brands (id, name, description, created_at) VALUES
(1, 'Green Mountain', 'Premium organic cannabis products', NOW()),
(2, 'Blue Dream Co', 'High-quality concentrates and edibles', NOW()),
(3, 'Purple Haze', 'Artisanal flower and pre-rolls', NOW()),
(4, 'CBD Plus', 'CBD-focused wellness products', NOW()),
(5, 'THC Labs', 'Laboratory-tested concentrates', NOW());

-- Insert sample categories
INSERT INTO store_categories (id, store_id, name, "order", created_at) VALUES
-- Store 1 categories
(1, 1, 'Flower', 1, NOW()),
(2, 1, 'Edibles', 2, NOW()),
(3, 1, 'Concentrates', 3, NOW()),
(4, 1, 'Vapes', 4, NOW()),
(5, 1, 'Accessories', 5, NOW()),
-- Store 2 categories
(6, 2, 'Flower', 1, NOW()),
(7, 2, 'Edibles', 2, NOW()),
(8, 2, 'Concentrates', 3, NOW()),
(9, 2, 'Vapes', 4, NOW()),
-- Store 3 categories
(10, 3, 'CBD Products', 1, NOW()),
(11, 3, 'Wellness', 2, NOW()),
(12, 3, 'Topicals', 3, NOW());

-- Insert sample products
INSERT INTO products (id, name, description, created_at) VALUES
-- Flower products
(1, 'Blue Dream Flower', 'Classic sativa-dominant hybrid with sweet berry aroma', NOW()),
(2, 'OG Kush', 'Indica-dominant strain with earthy, pine flavors', NOW()),
(3, 'Sour Diesel', 'Energizing sativa with diesel and citrus notes', NOW()),
(4, 'Purple Haze', 'Fruity sativa with grape and berry flavors', NOW()),
(5, 'White Widow', 'Balanced hybrid with earthy, woody taste', NOW()),

-- Edible products
(6, 'Chocolate Chip Cookies', 'Delicious cookies with 10mg THC each', NOW()),
(7, 'Gummy Bears', 'Mixed fruit gummies, 5mg THC per piece', NOW()),
(8, 'Brownie Bites', 'Rich chocolate brownies, 15mg THC each', NOW()),
(9, 'Hard Candies', 'Assorted fruit flavors, 2mg THC per candy', NOW()),

-- Concentrate products
(10, 'Live Resin', 'Fresh-frozen extract with full terpene profile', NOW()),
(11, 'Shatter', 'Glass-like concentrate, 85% THC', NOW()),
(12, 'Wax', 'Budder consistency concentrate', NOW()),
(13, 'Rosin', 'Solventless pressed extract', NOW()),

-- Vape products
(14, 'Blue Dream Cartridge', '0.5g vape cartridge, sativa', NOW()),
(15, 'OG Kush Cartridge', '1g vape cartridge, indica', NOW()),
(16, 'Disposable Vape', 'All-in-one disposable, 0.3g', NOW()),

-- CBD products
(17, 'CBD Oil Tincture', 'Full spectrum CBD oil, 1000mg', NOW()),
(18, 'CBD Gummies', 'CBD-only gummies, 25mg per piece', NOW()),
(19, 'CBD Topical Cream', 'Pain relief cream with CBD', NOW()),

-- Accessories
(20, 'Glass Pipe', 'Hand-blown glass pipe', NOW()),
(21, 'Grinder', '4-piece aluminum grinder', NOW()),
(22, 'Rolling Papers', 'Premium hemp rolling papers', NOW());

-- Insert sample tags
INSERT INTO tags (id, name, created_at) VALUES
(1, 'Sativa', NOW()),
(2, 'Indica', NOW()),
(3, 'Hybrid', NOW()),
(4, 'High THC', NOW()),
(5, 'CBD Rich', NOW()),
(6, 'Organic', NOW()),
(7, 'Premium', NOW()),
(8, 'Best Seller', NOW()),
(9, 'New Arrival', NOW()),
(10, 'On Sale', NOW());

-- Insert store settings
INSERT INTO store_settings (id, store_id, setting_key, setting_value, created_at) VALUES
(1, 1, 'min_order_amount', '20.00', NOW()),
(2, 1, 'delivery_fee', '5.00', NOW()),
(3, 1, 'pickup_available', 'true', NOW()),
(4, 1, 'delivery_available', 'true', NOW()),
(5, 2, 'min_order_amount', '25.00', NOW()),
(6, 2, 'delivery_fee', '7.50', NOW()),
(7, 2, 'pickup_available', 'true', NOW()),
(8, 2, 'delivery_available', 'false', NOW()),
(9, 3, 'min_order_amount', '15.00', NOW()),
(10, 3, 'delivery_fee', '3.00', NOW()),
(11, 3, 'pickup_available', 'true', NOW()),
(12, 3, 'delivery_available', 'true', NOW());

-- Display summary
SELECT 'Database seeded successfully!' as status;
SELECT 'Stores: ' || COUNT(*) as stores_count FROM stores;
SELECT 'Products: ' || COUNT(*) as products_count FROM products;
SELECT 'Categories: ' || COUNT(*) as categories_count FROM store_categories;
SELECT 'Brands: ' || COUNT(*) as brands_count FROM brands;
SELECT 'Tags: ' || COUNT(*) as tags_count FROM tags;
