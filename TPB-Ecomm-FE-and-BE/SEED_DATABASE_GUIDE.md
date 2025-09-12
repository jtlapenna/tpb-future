# 🌱 Database Seeding Guide

## ✅ **STATUS: DATABASE FULLY POPULATED**

**Last Updated**: September 11, 2025  
**Status**: ✅ **COMPLETE** - Database is fully populated with test data

## 🎯 **Current Database State**

Your e-commerce app is **fully functional** with comprehensive test data:

### **✅ What's Already Populated**
- **3 Stores**: Downtown Dispensary, Westside Cannabis, Green Valley Store
- **24 Products**: Across 5 categories (Flower, Edibles, Concentrates, Vapes, Accessories)
- **5 Brands**: Green Mountain, Blue Dream Co, Purple Haze, Wellness Co, Accessories Co
- **22 Product Images**: Placeholder images for all products
- **Pricing Data**: All products have realistic pricing
- **Product Tags**: 10 tags for product categorization
- **Store Images**: Ad banners and branding images for all stores

## 🔄 **Re-seeding (If Needed)**

If you need to reset or re-populate the database, run these scripts:

```bash
# Navigate to the API directory
cd TPB-Ecomm-FE-and-BE/ThePeakBeyond_eCommerce_API

# Run the main seeding script
psql -h localhost -U tpb_user -d tpb_ecommerce -f scripts/seed-database.sql

# Run the product details script
psql -h localhost -U tpb_user -d tpb_ecommerce -f scripts/seed-products.sql

# Run the store products script (if needed)
psql -h localhost -U tpb_user -d tpb_ecommerce -f scripts/populate-store-products.sql
```

### **Step 2: Verify Data Population**

```bash
# Check that data was inserted
psql -h localhost -U tpb_user -d tpb_ecommerce -c "
SELECT 'Stores: ' || COUNT(*) FROM stores;
SELECT 'Products: ' || COUNT(*) FROM products;
SELECT 'Categories: ' || COUNT(*) FROM store_categories;
SELECT 'Brands: ' || COUNT(*) FROM brands;
"
```

## 📊 **What Gets Created**

### **🏪 Stores (3 locations)**
- **Downtown Dispensary** (Store ID: 1)
- **Westside Cannabis** (Store ID: 2) 
- **Green Valley Store** (Store ID: 3)

### **🛍️ Products (22 items)**
- **Flower**: Blue Dream, OG Kush, Sour Diesel, Purple Haze, White Widow
- **Edibles**: Cookies, Gummies, Brownies, Hard Candies
- **Concentrates**: Live Resin, Shatter, Wax, Rosin
- **Vapes**: Cartridges, Disposable Pens
- **CBD**: Oil Tincture, Gummies, Topical Cream
- **Accessories**: Glass Pipe, Grinder, Rolling Papers

### **📂 Categories (12 categories)**
- Flower, Edibles, Concentrates, Vapes, Accessories
- CBD Products, Wellness, Topicals

### **🏷️ Brands (5 brands)**
- Green Mountain, Blue Dream Co, Purple Haze, CBD Plus, THC Labs

### **🏷️ Tags (10 tags)**
- Sativa, Indica, Hybrid, High THC, CBD Rich, Organic, Premium, Best Seller, New Arrival, On Sale

## 🔧 **How the App Works After Seeding**

### **1. Store Selection**
- App automatically loads available stores
- User can switch between stores using the store picker
- Each store has different products and categories

### **2. Product Browsing**
- Products are organized by categories
- Users can filter by category, brand, or tags
- Search functionality works across all products

### **3. Favorites System**
- **Requires user login** (this is correct behavior!)
- Users can add/remove favorites
- Favorites are stored per user and store

### **4. Shopping Cart**
- Add products to cart
- View cart contents
- Proceed to checkout (Treez integration)

## 🚨 **Important Notes**

### **Authentication Required for:**
- ✅ **Favorites** - Users must be logged in
- ✅ **Cart persistence** - Requires user session
- ✅ **Order history** - Needs user authentication
- ✅ **Profile management** - User-specific data

### **Public Access (No Login Required):**
- ✅ **Product browsing** - Anyone can view products
- ✅ **Category filtering** - Public product catalog
- ✅ **Store selection** - Public store information

## 🎯 **Expected Results After Seeding**

1. **Store picker** will show 3 available stores
2. **Products page** will display 22 products across categories
3. **Categories** will show organized product groups
4. **Search** will work across all products
5. **Favorites** will require login (as designed)
6. **Cart** will allow adding products

## 🔄 **Re-seeding the Database**

If you need to clear and re-populate:

```bash
# Clear all data and re-seed
psql -h localhost -U tpb_user -d tpb_ecommerce -c "
TRUNCATE TABLE favorites, products, store_categories, brands, stores, store_settings, tags RESTART IDENTITY CASCADE;
"

# Then run the seeding scripts again
psql -h localhost -U tpb_user -d tpb_ecommerce -f scripts/seed-database.sql
psql -h localhost -U tpb_user -d tpb_ecommerce -f scripts/seed-products.sql
```

## 🎉 **Next Steps After Seeding**

1. **Test the app** - Browse products, try different stores
2. **Create a user account** - Test login and favorites
3. **Add products to cart** - Test shopping functionality
4. **Explore categories** - Test filtering and search

Your e-commerce app will be fully functional with realistic test data!
