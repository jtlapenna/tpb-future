import { Controller, Get, Param } from '@nestjs/common';
import { DataBaseQueryEnum } from 'src/common/constants/database.query.enum';
import { TagInfo } from 'src/models/tagging/tag-infos.entity';
import { TagInfoService } from './tag.service';

@Controller('apiv1/tags')
export class TagInfoController {
  constructor(private readonly tagInfoService: TagInfoService) {}

  @Get('all/:storeId/:page?/:count?/:categoryId?')
  async getAll(
    @Param('storeId') storeId: number,
    @Param('page') page?: number,
    @Param('count') count?: number,
    @Param('categoryId') categoryId?: number,
  ): Promise<TagInfo[]> {
    return this.tagInfoService.findAll(
      storeId,
      page || 1,
      count || DataBaseQueryEnum.COUNT,
      categoryId || -1,
    );
  }

  @Get('find/:id')
  async find(@Param('id') id: number): Promise<TagInfo> {
    return this.tagInfoService.findOne(id);
  }
}
