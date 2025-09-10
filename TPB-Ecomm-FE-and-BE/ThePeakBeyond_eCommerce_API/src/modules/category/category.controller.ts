import { Controller, Get, Param } from '@nestjs/common';
import { DataBaseQueryEnum } from 'src/common/constants/database.query.enum';
import { Category } from 'src/models/product/category.entity';
import { CategoryService } from './category.service';

@Controller('apiv1/category')
export class CategoryController {
  constructor(private readonly categoryService: CategoryService) {}

  @Get('all/:storeId/:sort?/:page?/:count?')
  async getAll(
    @Param('storeId') storeId: number,
    @Param('sort') sort?: string,
    @Param('page') page?: number,
    @Param('count') count?: number,
  ): Promise<Category[]> {
    return this.categoryService.findAll(
      storeId,
      sort || 'order',
      page || 1,
      count || DataBaseQueryEnum.COUNT,
    );
  }

  @Get('find/:id')
  async find(@Param('id') id: number): Promise<Category> {
    return this.categoryService.findOne(id);
  }
}
