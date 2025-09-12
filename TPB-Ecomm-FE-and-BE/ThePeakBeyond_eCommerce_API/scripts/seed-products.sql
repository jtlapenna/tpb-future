-- Product Details Seeding Script
-- This script adds detailed product information including pricing, images, and inventory

-- Connect to the database
\c tpb_ecommerce;

-- Note: The products table structure is basic. We need to extend it with additional columns
-- for a fully functional e-commerce system. For now, we'll work with the existing structure.

-- Update products with more detailed information
UPDATE products SET 
  name = 'Blue Dream Flower - Premium',
  description = 'Classic sativa-dominant hybrid with sweet berry aroma. Perfect for daytime use with uplifting effects.'
WHERE id = 1;

UPDATE products SET 
  name = 'OG Kush - Indica',
  description = 'Indica-dominant strain with earthy, pine flavors. Great for relaxation and pain relief.'
WHERE id = 2;

UPDATE products SET 
  name = 'Sour Diesel - Sativa',
  description = 'Energizing sativa with diesel and citrus notes. Ideal for creative activities and focus.'
WHERE id = 3;

UPDATE products SET 
  name = 'Purple Haze - Sativa',
  description = 'Fruity sativa with grape and berry flavors. Uplifting and euphoric effects.'
WHERE id = 4;

UPDATE products SET 
  name = 'White Widow - Hybrid',
  description = 'Balanced hybrid with earthy, woody taste. Perfect balance of relaxation and energy.'
WHERE id = 5;

UPDATE products SET 
  name = 'Chocolate Chip Cookies - 10mg THC',
  description = 'Delicious homemade-style cookies with 10mg THC each. Perfect for beginners.'
WHERE id = 6;

UPDATE products SET 
  name = 'Gummy Bears - Mixed Fruit',
  description = 'Mixed fruit gummies with 5mg THC per piece. Great for micro-dosing.'
WHERE id = 7;

UPDATE products SET 
  name = 'Brownie Bites - 15mg THC',
  description = 'Rich chocolate brownies with 15mg THC each. For experienced users.'
WHERE id = 8;

UPDATE products SET 
  name = 'Hard Candies - Assorted',
  description = 'Assorted fruit flavors with 2mg THC per candy. Discreet and portable.'
WHERE id = 9;

UPDATE products SET 
  name = 'Live Resin - Blue Dream',
  description = 'Fresh-frozen extract with full terpene profile. Premium concentrate experience.'
WHERE id = 10;

UPDATE products SET 
  name = 'Shatter - OG Kush',
  description = 'Glass-like concentrate with 85% THC. High potency for experienced users.'
WHERE id = 11;

UPDATE products SET 
  name = 'Wax - Sour Diesel',
  description = 'Budder consistency concentrate. Easy to work with and potent.'
WHERE id = 12;

UPDATE products SET 
  name = 'Rosin - Purple Haze',
  description = 'Solventless pressed extract. Clean and pure concentrate.'
WHERE id = 13;

UPDATE products SET 
  name = 'Blue Dream Vape Cartridge',
  description = '0.5g vape cartridge with sativa effects. Convenient and discreet.'
WHERE id = 14;

UPDATE products SET 
  name = 'OG Kush Vape Cartridge',
  description = '1g vape cartridge with indica effects. Long-lasting and potent.'
WHERE id = 15;

UPDATE products SET 
  name = 'Disposable Vape Pen',
  description = 'All-in-one disposable vape with 0.3g. No charging or refilling needed.'
WHERE id = 16;

UPDATE products SET 
  name = 'CBD Oil Tincture - 1000mg',
  description = 'Full spectrum CBD oil for wellness and relaxation. No psychoactive effects.'
WHERE id = 17;

UPDATE products SET 
  name = 'CBD Gummies - 25mg',
  description = 'CBD-only gummies with 25mg per piece. Perfect for daily wellness.'
WHERE id = 18;

UPDATE products SET 
  name = 'CBD Topical Cream',
  description = 'Pain relief cream with CBD. Apply directly to affected areas.'
WHERE id = 19;

UPDATE products SET 
  name = 'Glass Pipe - Hand Blown',
  description = 'Beautiful hand-blown glass pipe. Durable and easy to clean.'
WHERE id = 20;

UPDATE products SET 
  name = '4-Piece Grinder',
  description = 'Premium aluminum grinder with pollen catcher. Sharp teeth for easy grinding.'
WHERE id = 21;

UPDATE products SET 
  name = 'Hemp Rolling Papers',
  description = 'Premium hemp rolling papers. Slow burning and natural.'
WHERE id = 22;

-- Display updated products
SELECT 'Products updated with detailed descriptions!' as status;
SELECT id, name, description FROM products ORDER BY id;
