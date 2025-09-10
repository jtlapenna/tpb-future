export interface IStore {
  id: string
  name: string
  active: boolean
  clientId: string
  createdAt: string
  tax: string
  images?: IStoreImages[];
}

export interface IStoreImages {
  id: string;
  text: string;
  codename: string;
  special_type: string;
  url: string;
  store_id:string;
  advertisable_id: number;
  advertisable_type: string;
  brand_url: string;
}
