import { Controller, Get, Param } from '@nestjs/common';
import { DataBaseQueryEnum } from 'src/common/constants/database.query.enum';
import { Brand } from 'src/models/brands/brand.entity';
import { BrandDto } from 'src/models/dto/brand.dto';
import { BrandService } from './brand.service';

@Controller('apiv1/brands')
export class BrandController {
  constructor(private readonly brandService: BrandService) {}

  @Get('all/:storeId/:page?/:count?')
  async getAll(
    @Param('storeId') storeId: number,
    @Param('page') page?: number,
    @Param('count') count?: number,
  ): Promise<BrandDto[]> {
    return this.brandService.findAll(
      storeId,
      page || 1,
      count || DataBaseQueryEnum.COUNT,
    );
  }

  @Get('find/:id')
  async find(@Param('id') id: number): Promise<Brand> {
    return this.brandService.findOne(id);
  }
}
