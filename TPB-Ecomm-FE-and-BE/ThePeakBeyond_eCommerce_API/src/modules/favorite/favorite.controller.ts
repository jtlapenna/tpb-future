import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { DataBaseQueryEnum } from 'src/common/constants/database.query.enum';
import { User } from 'src/common/decorators/user.decorator';
import { AuthGuard } from 'src/common/guards/auth.guard';
import { FavoriteDto } from 'src/models/dto/favorite.dto';
import { ProductDto } from 'src/models/dto/product.dto';
import { UserDto } from 'src/models/dto/user.dto';
import { FavoriteService } from './favorite.service';

@UseGuards(AuthGuard)
@Controller('apiv1/favorite')
export class FavoriteController {
  constructor(private readonly favoriteService: FavoriteService) {}

  @Get('all/:storeId/:sort?/:page?/:count?')
  async getAll(
    @User() user: UserDto,
    @Param('storeId') storeId: number,
    @Param('sort') sort?: string,
    @Param('page') page?: number,
    @Param('count') count?: number,
  ): Promise<ProductDto[]> {
    return this.favoriteService.findAll(
      storeId,
      sort || 'Id',
      user,
      page || 1,
      count || DataBaseQueryEnum.COUNT,
    );
  }

  @Post('add')
  async add(@Body() data: FavoriteDto, @User() user: UserDto): Promise<any> {
    return this.favoriteService.add(data, user);
  }

  @Delete('delete/:id')
  async delete(@Param('id') id: number, @User() user: UserDto): Promise<any> {
    return this.favoriteService.remove(id, user);
  }
}
