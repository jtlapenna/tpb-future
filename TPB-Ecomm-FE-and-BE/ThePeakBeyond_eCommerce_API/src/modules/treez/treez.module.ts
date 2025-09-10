import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StoreSettings } from 'src/models/stores/store-settings.entity';
import { Store } from 'src/models/stores/store.entity';
import { AWSService } from 'src/providers/aws/aws.service';
import { TreezService } from 'src/providers/treez/treez.service';
import { StoreService } from '../store/store.service';
import { TreezController } from './treez.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Store, StoreSettings])],
  controllers: [TreezController],
  providers: [TreezService, StoreService, AWSService],
})
export class TreezModule {}
