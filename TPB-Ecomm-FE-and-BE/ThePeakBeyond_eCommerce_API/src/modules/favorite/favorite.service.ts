import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { FavoriteDto } from 'src/models/dto/favorite.dto';
import { ProductDto } from 'src/models/dto/product.dto';
import { UserDto } from 'src/models/dto/user.dto';
import { Favorites } from 'src/models/favorites/favorites.entity';
import { Repository } from 'typeorm';
import { ProductService } from '../product/product.service';

@Injectable()
export class FavoriteService {
  constructor(
    @InjectRepository(Favorites)
    private favoriteRepository: Repository<Favorites>,
    private productService: ProductService,
  ) {}

  findAll(
    storeId: number,
    column: string,
    user: UserDto,
    pageIndex = 1,
    count = 20,
  ): Promise<ProductDto[]> {
    return this.productService.findAll({
      storeId: storeId,
      brand: 0,
      category: 0,
      count: count,
      page: pageIndex,
      sortColumn: column,
      sortDirection: 'ASC',
      tag: 0,
      userId: user.sub,
      loadFavorites: true,
    });
  }

  findOne(id: number): Promise<Favorites> {
    return this.favoriteRepository.findOne(id);
  }

  async add(data: FavoriteDto, user: UserDto): Promise<any> {
    const fav = {
      ...data,
      userId: user.sub,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    return this.favoriteRepository.insert(fav);
  }

  async remove(id: number, user: UserDto): Promise<any> {
    const fav = await this.favoriteRepository.findOne({
      where: {
        productId: id,
        userId: user.sub,
      },
    });

    if (fav && fav.userId === user.sub) {
      return this.favoriteRepository.remove(fav);
    }

    return null;
  }
}
