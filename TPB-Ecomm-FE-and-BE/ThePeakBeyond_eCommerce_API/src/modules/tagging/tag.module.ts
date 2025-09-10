import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TagInfo } from 'src/models/tagging/tag-infos.entity';
import { TagInfoController } from './tag.controller';
import { TagInfoService } from './tag.service';

@Module({
  imports: [TypeOrmModule.forFeature([TagInfo])],
  controllers: [TagInfoController],
  providers: [TagInfoService],
  exports: [TypeOrmModule],
})
export class TagInfoModule {}
