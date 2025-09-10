import { ApiProperty } from '@nestjs/swagger';

export class OrderItemDto {
  @ApiProperty()
  quantity: number;

  @ApiProperty()
  product_id?: string;

  @ApiProperty()
  size_id: string;
}
