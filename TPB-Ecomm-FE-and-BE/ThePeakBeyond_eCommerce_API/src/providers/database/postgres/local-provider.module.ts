import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Brand } from 'src/models/brands/brand.entity';
import { Company } from 'src/models/companies/company.entity';
import { Favorites } from 'src/models/favorites/favorites.entity';
import { Category } from 'src/models/product/category.entity';
import { Product } from 'src/models/product/product.entity';
import { StoreSettings } from 'src/models/stores/store-settings.entity';
import { Store } from 'src/models/stores/store.entity';
import { TagInfo } from 'src/models/tagging/tag-infos.entity';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT) || 5432,
      username: process.env.DB_USERNAME || 'tpb_user',
      password: process.env.DB_PASSWORD || 'tpb_password',
      database: process.env.DB_DATABASE || 'tpb_ecommerce',
      entities: [
        Product,
        Category,
        TagInfo,
        Brand,
        Store,
        Company,
        Favorites,
        StoreSettings,
      ],
      synchronize: false, // Disable auto-sync to prevent schema conflicts
      logging: false, // Disable all database logging
      autoLoadEntities: false, // Disable automatic entity loading
    }),
  ],
})
export class LocalProviderModule {}
