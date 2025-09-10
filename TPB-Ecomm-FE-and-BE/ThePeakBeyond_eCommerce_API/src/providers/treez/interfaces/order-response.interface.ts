export interface OrderDetails {
  readonly type: string;
  readonly ticket_id: string;
  readonly order_number: string;
  readonly order_source?: string;
  readonly customer_id: number;
  readonly order_status: string;
  readonly payment_status: string;
  readonly date_created: string;
  readonly sub_total: number;
  readonly tax_total: number;
  readonly discount_total: number;
  readonly total: number;
  readonly ticket_note?: string;
  readonly items: Items[];
}

export interface Items {
  readonly product_id: string;
  readonly barcodes: string[];
  readonly inventory_barcodes: string[];
  readonly size_id: string;
  readonly quantity: number;
  readonly price_total: number;
  readonly price_sell: number;
  readonly product_unit: string;
}
