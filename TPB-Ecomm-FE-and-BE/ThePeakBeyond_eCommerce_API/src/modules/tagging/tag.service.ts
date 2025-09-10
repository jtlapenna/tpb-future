import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { GET_TAGS_BY_STORE } from 'src/database/tags.query';
import { TagInfo } from 'src/models/tagging/tag-infos.entity';
import { Repository } from 'typeorm';

@Injectable()
export class TagInfoService {
  constructor(
    @InjectRepository(TagInfo)
    private tagRepository: Repository<TagInfo>,
  ) {}

  findAll(
    storeId: number,
    pageIndex = 1,
    count = 20,
    categoryId = -1,
  ): Promise<TagInfo[]> {
    return this.tagRepository.query(GET_TAGS_BY_STORE, [storeId, categoryId]);
  }

  findOne(id: number): Promise<TagInfo> {
    return this.tagRepository.findOne(id);
  }
}
