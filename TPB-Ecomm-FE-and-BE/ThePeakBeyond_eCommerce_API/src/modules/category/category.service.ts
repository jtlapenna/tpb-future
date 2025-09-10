import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Category } from 'src/models/product/category.entity';
import { Repository } from 'typeorm';

@Injectable()
export class CategoryService {
  constructor(
    @InjectRepository(Category)
    private categoryRepository: Repository<Category>,
  ) {}

  findAll(
    storeId: number,
    column: string,
    pageIndex = 1,
    count = 20,
  ): Promise<Category[]> {
    return this.categoryRepository.find({
      where: { storeId: storeId },
      order: {
        [column]: 'ASC',
      },
      skip: (pageIndex - 1) * count,
      take: count,
    });
  }

  findOne(id: number): Promise<Category> {
    return this.categoryRepository.findOne(id);
  }
}
