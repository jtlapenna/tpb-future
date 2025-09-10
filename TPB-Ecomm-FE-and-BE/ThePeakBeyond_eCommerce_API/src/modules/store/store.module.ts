import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StoreSettings } from 'src/models/stores/store-settings.entity';
import { Store } from 'src/models/stores/store.entity';
import { StoreController } from './store.controller';
import { StoreService } from './store.service';

@Module({
  imports: [TypeOrmModule.forFeature([Store, StoreSettings])],
  controllers: [StoreController],
  providers: [StoreService],
  exports: [TypeOrmModule],
})
export class StoreModule {}
