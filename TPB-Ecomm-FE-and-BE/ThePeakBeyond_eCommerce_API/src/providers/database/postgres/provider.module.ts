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
import { getSecretKey } from 'src/providers/aws/aws-secret-key.service';

@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      useFactory: async () => {
        const cnnString = await getSecretKey(process.env.API_STAGE_POSTGRES);

        const jsonCnnString = JSON.parse(cnnString);
        console.log('jsonCnnString', jsonCnnString);

        return {
          type: jsonCnnString.engine,
          host: jsonCnnString.host,
          port: +jsonCnnString.port,
          username: jsonCnnString.username,
          password: `${jsonCnnString.password}`,
          database: jsonCnnString.dbname,
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
          synchronize: false,
        };
      },
    }),
  ],
})
export class ProviderModule {}
