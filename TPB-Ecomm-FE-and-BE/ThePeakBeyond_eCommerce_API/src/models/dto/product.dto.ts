export class ProductDto {
  id: number;
  name: string | null;
  description: string | null;
  category_id: number;
  brand_id: number;
  image_url: string;
  thumb_image: string;
  stock: number;
  min_price: number;
  brand_name: string;
  promotion?: string;
  featured?: boolean;
  sku: string;
  tags?: string[];
}
