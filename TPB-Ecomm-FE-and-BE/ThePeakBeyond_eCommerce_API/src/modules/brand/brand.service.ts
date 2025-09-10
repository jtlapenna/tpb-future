import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { GET_BRANDS_BY_STORE } from 'src/database/brands.query';
import { Brand } from 'src/models/brands/brand.entity';
import { BrandDto } from 'src/models/dto/brand.dto';
import { Repository } from 'typeorm';

@Injectable()
export class BrandService {
  constructor(
    @InjectRepository(Brand)
    private brandRepository: Repository<Brand>,
  ) {}

  findAll(storeId: number, pageIndex = 1, count = 20): Promise<BrandDto[]> {
    return this.brandRepository.query(GET_BRANDS_BY_STORE, [
      storeId,
      (pageIndex - 1) * count,
      count,
    ]);
  }

  findOne(id: number): Promise<Brand> {
    return this.brandRepository.findOne(id);
  }
}
