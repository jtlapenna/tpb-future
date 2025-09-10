# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
user = User.new
user.email = ENV['ADMIN_EMAIL']
user.name = 'ADMIN'
user.password = ENV['ADMIN_PASSWORD']
user.password_confirmation = ENV['ADMIN_PASSWORD']
user.save!

category = Category.find_or_create_by(name: 'CATEGORY')
brand = Brand.find_or_create_by(name: 'AMUL')
product = category.products.find_or_create_by(name: 'PRODUCT')
product.product_variants.find_or_create_by(name: 'WILDCARD PRODUCT', brand_id: brand.id)


AttributeDef.find_or_create_by(name: 'TYPE')
