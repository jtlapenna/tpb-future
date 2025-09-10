import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import {
  GET_STORE_IMAGES,
  GET_STORE_IMAGES_BY_COMPANY,
} from 'src/database/store.query';
import { StoreDto } from 'src/models/dto/store.dto';
import { StoreSettings } from 'src/models/stores/store-settings.entity';
import { Store } from 'src/models/stores/store.entity';
import { Repository } from 'typeorm';

@Injectable()
export class StoreService {
  constructor(
    @InjectRepository(Store)
    private storeRepository: Repository<Store>,
    @InjectRepository(StoreSettings)
    private storeSettingsRepository: Repository<StoreSettings>,
  ) {}

  findAll(
    column: string,
    clientId: number,
    pageIndex = 1,
    count = 20,
  ): Promise<Store[]> {
    return this.storeRepository.find({
      where: { clientId: clientId },
      order: {
        [column]: 'ASC',
      },
      skip: (pageIndex - 1) * count,
      take: count,
    });
  }

  findOne(id: number): Promise<Store> {
    return this.storeRepository.findOne(id);
  }

  async terms(id: number): Promise<string> {
    const terms = await this.storeSettingsRepository.find({ storeId: id });

    if (terms && terms.length) {
      const data = terms[0]?.data;

      if (data) {
        const term = JSON.parse(data);

        return term?.t_a_c || '';
      }
    }

    return '';
  }

  async storeImages(id: number): Promise<StoreDto[]> {
    return this.storeRepository.query(GET_STORE_IMAGES, [id]);
  }

  async storeImagesByCompanyId(id: number): Promise<StoreDto[]> {
    return this.storeRepository.query(GET_STORE_IMAGES_BY_COMPANY, [id]);
  }
}
