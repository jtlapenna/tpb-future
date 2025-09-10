import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ProductModule } from './modules/product/product.module';
import { CategoryModule } from './modules/category/category.module';
import { StoreModule } from './modules/store/store.module';
import { TagInfoModule } from './modules/tagging/tag.module';
import { BrandModule } from './modules/brand/brand.module';
import { ProviderModule } from './providers/database/postgres/provider.module';
import { CompanyModule } from './modules/company/company.module';
import { FavoriteModule } from './modules/favorite/favorite.module';
import { TreezModule } from './modules/treez/treez.module';
import { AWSService } from './providers/aws/aws.service';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';

@Module({
  imports: [
    ProductModule,
    CategoryModule,
    StoreModule,
    TagInfoModule,
    BrandModule,
    ProviderModule,
    CompanyModule,
    FavoriteModule,
    TreezModule,
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '../..', 'client'),
    }),
  ],
  controllers: [AppController],
  providers: [AppService, AWSService],
})
export class AppModule {}
