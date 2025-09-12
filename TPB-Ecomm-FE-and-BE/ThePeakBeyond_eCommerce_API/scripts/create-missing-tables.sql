-- Create missing tables for the e-commerce application
-- This script creates the tables that the application expects but are missing

-- Connect to the database
\c tpb_ecommerce;

-- Create store_products table (main products table per store)
CREATE TABLE IF NOT EXISTS store_products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    store_id INTEGER NOT NULL REFERENCES stores(id),
    store_category_id INTEGER REFERENCES store_categories(id),
    brand_id INTEGER REFERENCES brands(id),
    sku VARCHAR(100) UNIQUE,
    stock INTEGER DEFAULT 0,
    primary_image_id INTEGER,
    thumb_image_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create images table
CREATE TABLE IF NOT EXISTS images (
    id SERIAL PRIMARY KEY,
    url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create product_values table (for pricing and other attributes)
CREATE TABLE IF NOT EXISTS product_values (
    id SERIAL PRIMARY KEY,
    valuable_id INTEGER NOT NULL,
    valuable_type VARCHAR(50) NOT NULL,
    attribute_name VARCHAR(100) NOT NULL,
    value VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create store_product_promotions table
CREATE TABLE IF NOT EXISTS store_product_promotions (
    id SERIAL PRIMARY KEY,
    store_product_id INTEGER NOT NULL REFERENCES store_products(id),
    promotion VARCHAR(255),
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create kiosk_products table (for featured products)
CREATE TABLE IF NOT EXISTS kiosk_products (
    id SERIAL PRIMARY KEY,
    store_product_id INTEGER NOT NULL REFERENCES store_products(id),
    featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create taggings table (for product tags)
CREATE TABLE IF NOT EXISTS taggings (
    id SERIAL PRIMARY KEY,
    taggable_id INTEGER NOT NULL,
    taggable_type VARCHAR(50) NOT NULL,
    tag_id INTEGER NOT NULL REFERENCES tags(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_store_products_store_id ON store_products(store_id);
CREATE INDEX IF NOT EXISTS idx_store_products_category_id ON store_products(store_category_id);
CREATE INDEX IF NOT EXISTS idx_store_products_brand_id ON store_products(brand_id);
CREATE INDEX IF NOT EXISTS idx_product_values_valuable ON product_values(valuable_id, valuable_type);
CREATE INDEX IF NOT EXISTS idx_taggings_taggable ON taggings(taggable_id, taggable_type);

-- Display success message
SELECT 'Missing tables created successfully!' as status;
