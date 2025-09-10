import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Favorites } from 'src/models/favorites/favorites.entity';
import { Product } from 'src/models/product/product.entity';
import { ProductService } from '../product/product.service';
import { FavoriteController } from './favorite.controller';
import { FavoriteService } from './favorite.service';

@Module({
  imports: [TypeOrmModule.forFeature([Favorites, Product])],
  controllers: [FavoriteController],
  providers: [FavoriteService, ProductService],
  exports: [TypeOrmModule],
})
export class FavoriteModule {}
