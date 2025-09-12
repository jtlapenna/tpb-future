-- Add products to the on-sale page by creating promotions
-- This script adds several products to the store_product_promotions table

\c tpb_ecommerce;

-- Add some popular products to the sale
INSERT INTO store_product_promotions (store_product_id, promotion, start_date, end_date) VALUES
-- Flower products on sale
(1, '20% OFF - Premium Quality', NOW() - INTERVAL '1 day', NOW() + INTERVAL '30 days'),
(2, '15% OFF - Limited Time', NOW() - INTERVAL '2 days', NOW() + INTERVAL '25 days'),
(3, '25% OFF - Best Seller', NOW() - INTERVAL '1 day', NOW() + INTERVAL '20 days'),

-- Edibles on sale
(6, 'Buy 2 Get 1 FREE', NOW() - INTERVAL '3 days', NOW() + INTERVAL '15 days'),
(7, '30% OFF - Stock Up Sale', NOW() - INTERVAL '1 day', NOW() + INTERVAL '10 days'),
(8, '20% OFF - Weekend Special', NOW() - INTERVAL '2 days', NOW() + INTERVAL '5 days'),

-- Concentrates on sale
(10, '15% OFF - Premium Extract', NOW() - INTERVAL '1 day', NOW() + INTERVAL '20 days'),
(11, '25% OFF - High Potency', NOW() - INTERVAL '2 days', NOW() + INTERVAL '18 days'),
(12, '20% OFF - Pure Quality', NOW() - INTERVAL '1 day', NOW() + INTERVAL '22 days'),

-- Vapes on sale
(14, 'Buy 1 Get 1 50% OFF', NOW() - INTERVAL '1 day', NOW() + INTERVAL '12 days'),
(15, '30% OFF - Disposable Special', NOW() - INTERVAL '2 days', NOW() + INTERVAL '8 days'),

-- CBD products on sale
(26, '25% OFF - Wellness Focus', NOW() - INTERVAL '1 day', NOW() + INTERVAL '14 days'),
(27, '20% OFF - CBD Gummies', NOW() - INTERVAL '2 days', NOW() + INTERVAL '16 days'),
(28, '15% OFF - Topical Relief', NOW() - INTERVAL '1 day', NOW() + INTERVAL '18 days'),

-- Accessories on sale
(20, '10% OFF - Grinder Sale', NOW() - INTERVAL '1 day', NOW() + INTERVAL '7 days'),
(21, '15% OFF - Rolling Papers', NOW() - INTERVAL '2 days', NOW() + INTERVAL '6 days');

-- Display success message
SELECT 'Sale products added successfully!' as status;
