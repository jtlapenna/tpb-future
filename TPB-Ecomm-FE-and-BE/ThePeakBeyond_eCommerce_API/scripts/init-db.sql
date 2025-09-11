-- The Peak Beyond E-commerce Database Initialization
-- This script creates the basic database structure for local development

-- Create database (run this as superuser)
-- CREATE DATABASE tpb_ecommerce;

-- Create user (run this as superuser)
-- CREATE USER tpb_user WITH PASSWORD 'tpb_password';
-- GRANT ALL PRIVILEGES ON DATABASE tpb_ecommerce TO tpb_user;

-- Connect to the database and create tables
\c tpb_ecommerce;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create basic tables (these will be managed by TypeORM in development)
-- The actual table creation will be handled by TypeORM synchronize: true in development mode

-- Sample data for development (optional)
-- This can be used to seed the database with test data

-- Example: Insert sample stores
-- INSERT INTO store (id, name, address, created_at, updated_at) VALUES
-- (uuid_generate_v4(), 'Sample Store 1', '123 Main St, City, State', NOW(), NOW()),
-- (uuid_generate_v4(), 'Sample Store 2', '456 Oak Ave, City, State', NOW(), NOW());

-- Example: Insert sample brands
-- INSERT INTO brand (id, name, description, created_at, updated_at) VALUES
-- (uuid_generate_v4(), 'Sample Brand 1', 'Premium cannabis products', NOW(), NOW()),
-- (uuid_generate_v4(), 'Sample Brand 2', 'Organic cannabis products', NOW(), NOW());

-- Example: Insert sample categories
-- INSERT INTO category (id, name, description, created_at, updated_at) VALUES
-- (uuid_generate_v4(), 'Flower', 'Cannabis flower products', NOW(), NOW()),
-- (uuid_generate_v4(), 'Edibles', 'Cannabis edible products', NOW(), NOW()),
-- (uuid_generate_v4(), 'Concentrates', 'Cannabis concentrate products', NOW(), NOW());

-- Note: In development mode with synchronize: true, TypeORM will automatically create
-- all tables based on the entity definitions. This script is mainly for reference
-- and can be used to create sample data if needed.
