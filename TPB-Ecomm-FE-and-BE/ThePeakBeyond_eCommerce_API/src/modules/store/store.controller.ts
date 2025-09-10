import { Controller, Get, Param } from '@nestjs/common';
import { DataBaseQueryEnum } from 'src/common/constants/database.query.enum';
import { StoreDto } from 'src/models/dto/store.dto';
import { Store } from 'src/models/stores/store.entity';
import { StoreService } from './store.service';

@Controller('apiv1/store')
export class StoreController {
  constructor(private readonly storeService: StoreService) {}

  @Get('all/:company/:sort?/:page?/:count?')
  async getAll(
    @Param('company') company: number,
    @Param('sort') sort?: string,
    @Param('page') page?: number,
    @Param('count') count?: number,
  ): Promise<Store[]> {
    return this.storeService.findAll(
      sort || 'name',
      company,
      page || 1,
      count || DataBaseQueryEnum.COUNT,
    );
  }

  @Get('find/:id')
  async find(@Param('id') id: number): Promise<Store> {
    return this.storeService.findOne(id);
  }

  @Get('terms/:id')
  async terms(@Param('id') id: number): Promise<any> {
    const term = await this.storeService.terms(id);
    return {
      term,
    };
  }

  @Get('images/:id')
  async storeImages(@Param('id') id: number): Promise<StoreDto[]> {
    return this.storeService.storeImages(id);
  }

  @Get('images/company/:id')
  async storeImagesByCompanyId(@Param('id') id: number): Promise<StoreDto[]> {
    return this.storeService.storeImagesByCompanyId(id);
  }
}
