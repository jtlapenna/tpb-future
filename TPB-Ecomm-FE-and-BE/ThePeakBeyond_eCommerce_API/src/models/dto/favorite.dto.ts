import { ApiProperty } from '@nestjs/swagger';

export class FavoriteDto {
  @ApiProperty()
  storeId: number;

  @ApiProperty()
  productId: number;
}
