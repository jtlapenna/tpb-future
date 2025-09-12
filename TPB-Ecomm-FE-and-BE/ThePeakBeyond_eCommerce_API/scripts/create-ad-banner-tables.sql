-- Create missing ad_banner tables for store images
-- This script creates the tables needed for store images functionality

-- Connect to the database
\c tpb_ecommerce;

-- Create ad_banner_locations table
CREATE TABLE IF NOT EXISTS ad_banner_locations (
    id SERIAL PRIMARY KEY,
    codename VARCHAR(100) NOT NULL,
    special_type VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create ad_banners table
CREATE TABLE IF NOT EXISTS ad_banners (
    id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL REFERENCES stores(id),
    ad_banner_location_id INTEGER REFERENCES ad_banner_locations(id),
    text VARCHAR(500),
    advertisable_id INTEGER,
    advertisable_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create assets table
CREATE TABLE IF NOT EXISTS assets (
    id SERIAL PRIMARY KEY,
    source_id INTEGER NOT NULL,
    source_type VARCHAR(50) NOT NULL,
    url VARCHAR(500) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert default ad_banner_locations
INSERT INTO ad_banner_locations (id, codename, special_type) VALUES
(1, 'HEADER_IMAGE', 'header'),
(2, 'DEALS', 'deals'),
(3, 'LAST_PURCHASE', 'purchase'),
(4, 'BRAND_SPOTLIGHT', 'brand')
ON CONFLICT (id) DO NOTHING;

-- Insert sample ad_banners for each store
INSERT INTO ad_banners (store_id, ad_banner_location_id, text, advertisable_id, advertisable_type) VALUES
-- Store 1 (Downtown Dispensary)
(1, 1, 'Welcome to Downtown Dispensary', NULL, NULL),
(1, 2, 'Special Deals This Week', NULL, NULL),
(1, 3, 'Your Last Purchase', NULL, NULL),
(1, 4, 'Featured Brand: Green Mountain', 1, 'Brand'),

-- Store 2 (Westside Cannabis)
(2, 1, 'Welcome to Westside Cannabis', NULL, NULL),
(2, 2, 'Weekly Specials', NULL, NULL),
(2, 3, 'Recent Orders', NULL, NULL),
(2, 4, 'Featured Brand: Blue Dream Co', 2, 'Brand'),

-- Store 3 (Green Valley Store)
(3, 1, 'Welcome to Green Valley Store', NULL, NULL),
(3, 2, 'CBD Specials', NULL, NULL),
(3, 3, 'Your Orders', NULL, NULL),
(3, 4, 'Featured Brand: Wellness Co', 4, 'Brand')
ON CONFLICT DO NOTHING;

-- Insert sample images for ad_banners
INSERT INTO images (id, url, alt_text) VALUES
(100, 'https://via.placeholder.com/800x200/4CAF50/white?text=Downtown+Dispensary+Header', 'Downtown Dispensary Header'),
(101, 'https://via.placeholder.com/400x200/FF9800/white?text=Special+Deals', 'Special Deals Banner'),
(102, 'https://via.placeholder.com/400x200/9C27B0/white?text=Last+Purchase', 'Last Purchase Banner'),
(103, 'https://via.placeholder.com/400x200/2196F3/white?text=Green+Mountain+Brand', 'Green Mountain Brand'),
(104, 'https://via.placeholder.com/800x200/8BC34A/white?text=Westside+Cannabis+Header', 'Westside Cannabis Header'),
(105, 'https://via.placeholder.com/400x200/FF5722/white?text=Weekly+Specials', 'Weekly Specials Banner'),
(106, 'https://via.placeholder.com/400x200/607D8B/white?text=Recent+Orders', 'Recent Orders Banner'),
(107, 'https://via.placeholder.com/400x200/E91E63/white?text=Blue+Dream+Brand', 'Blue Dream Brand'),
(108, 'https://via.placeholder.com/800x200/00BCD4/white?text=Green+Valley+Store+Header', 'Green Valley Store Header'),
(109, 'https://via.placeholder.com/400x200/795548/white?text=CBD+Specials', 'CBD Specials Banner'),
(110, 'https://via.placeholder.com/400x200/3F51B5/white?text=Your+Orders', 'Your Orders Banner'),
(111, 'https://via.placeholder.com/400x200/FFC107/white?text=Wellness+Brand', 'Wellness Brand')
ON CONFLICT (id) DO NOTHING;

-- Insert sample assets for brand images
INSERT INTO assets (source_id, source_type, url) VALUES
(1, 'AdBanner', 'https://via.placeholder.com/200x100/4CAF50/white?text=Green+Mountain'),
(2, 'AdBanner', 'https://via.placeholder.com/200x100/8BC34A/white?text=Blue+Dream+Co'),
(3, 'AdBanner', 'https://via.placeholder.com/200x100/00BCD4/white?text=Wellness+Co')
ON CONFLICT DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_ad_banners_store_id ON ad_banners(store_id);
CREATE INDEX IF NOT EXISTS idx_ad_banners_location_id ON ad_banners(ad_banner_location_id);
CREATE INDEX IF NOT EXISTS idx_assets_source ON assets(source_id, source_type);

-- Display success message
SELECT 'Ad banner tables created successfully!' as status;
SELECT 'Ad Banner Locations: ' || COUNT(*) as locations_count FROM ad_banner_locations;
SELECT 'Ad Banners: ' || COUNT(*) as banners_count FROM ad_banners;
SELECT 'Assets: ' || COUNT(*) as assets_count FROM assets;
