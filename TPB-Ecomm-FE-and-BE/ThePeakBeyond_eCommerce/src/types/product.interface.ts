export interface IProduct {
  id: string
  name: string
  category_id: string
  description: string
  brand_id: string
  image_url: string
  thumb_image: string
  stock: number
  min_price: string
  brand_name: string
  promotion?: string
  sku: string
  tags?:Tag[];
}

export interface Tag{
  name:string;
}
