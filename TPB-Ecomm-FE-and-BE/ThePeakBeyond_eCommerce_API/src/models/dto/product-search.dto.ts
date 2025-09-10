import { ApiProperty } from '@nestjs/swagger';

export class ProductSearchDto {
  @ApiProperty()
  storeId: number;

  @ApiProperty()
  sortColumn?: string;

  @ApiProperty()
  sortDirection?: string;

  @ApiProperty()
  page?: number;

  @ApiProperty()
  count?: number;

  @ApiProperty()
  category?: number;

  @ApiProperty()
  brand?: number;

  @ApiProperty()
  tag?: number;

  @ApiProperty()
  userId?: string;

  @ApiProperty()
  loadFavorites?: boolean;

  @ApiProperty()
  random?: string;

  @ApiProperty()
  name?: string;
}
