import { ApiProperty } from '@nestjs/swagger';
import { OrderStatus } from '../enums/order-status.enum';
import { OrderType } from '../enums/order-type.enum';
import { OrderItemDto } from './order-item.dto';

export class DeliveryAddressDto {
  @ApiProperty()
  street: string;

  @ApiProperty()
  city: string;

  @ApiProperty()
  country: string;

  @ApiProperty()
  state: string;

  @ApiProperty()
  zip: string;
}

export class OrderDto {
  @ApiProperty()
  type: OrderType;

  @ApiProperty()
  customer_id: number;

  @ApiProperty()
  ticket_note?: string;

  @ApiProperty()
  delivery_address?: DeliveryAddressDto;

  @ApiProperty()
  external_order_number?: string;

  @ApiProperty()
  items: OrderItemDto[];

  @ApiProperty()
  order_status?: OrderStatus;
}
