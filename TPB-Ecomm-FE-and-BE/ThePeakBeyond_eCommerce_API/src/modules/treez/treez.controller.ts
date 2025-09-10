import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  UploadedFiles,
  UseInterceptors,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { formatDateToISODate } from 'src/common/helpers/date.helper';
import { UserDto } from 'src/models/dto/user.dto';
import { AWSService } from 'src/providers/aws/aws.service';
import { ImageType } from 'src/providers/treez/enums/image-type.enum';
import { OrderDetails } from 'src/providers/treez/interfaces/order-response.interface';
import { OrderDto } from 'src/providers/treez/interfaces/order.dto';
import { TreezUserDto } from 'src/providers/treez/interfaces/treez-user.dto';
import { UserFindDto } from 'src/providers/treez/interfaces/user-find.dto';
import { TreezService } from 'src/providers/treez/treez.service';

@Controller('apiv1/treez')
export class TreezController {
  constructor(
    private readonly treezService: TreezService,
    private readonly awsSService: AWSService,
  ) {}

  @Get('login/:storeId')
  async login(@Param('storeId') storeId: number): Promise<any> {
    return this.treezService.getToken(storeId);
  }

  @Post('findUser/:storeId')
  async findUser(
    @Param('storeId') storeId: number,
    @Body() userDto: UserFindDto,
  ): Promise<any> {
    return this.treezService.findUser(storeId, userDto);
  }

  @Post('createUser/:storeId')
  async createUser(
    @Param('storeId') storeId: number,
    @Body() userDto: TreezUserDto,
  ): Promise<any> {
    return this.treezService.createUser(storeId, userDto);
  }

  @Post('updateUser/:storeId')
  async updateUser(
    @Param('storeId') storeId: number,
    @Body() userDto: TreezUserDto,
  ): Promise<any> {
    return this.treezService.updateUser(storeId, userDto);
  }

  @Post('createOrder/:storeId')
  async createOrder(
    @Param('storeId') storeId: number,
    @Body() orderDto: OrderDto,
  ): Promise<any> {
    return this.treezService.createOrder(storeId, orderDto);
  }

  @Get('getOrder/:storeId/:orderId')
  async getOrder(
    @Param('storeId') storeId: number,
    @Param('orderId') orderId: number,
  ): Promise<OrderDetails> {
    return this.treezService.getOrderById(storeId, orderId);
  }

  @Post('getOrders/:storeId/:page?/:count?')
  async getOrders(
    @Param('storeId') storeId: number,
    @Body() userDto: UserDto,
    @Param('page') page?: number,
    @Param('count') count?: number,
  ): Promise<OrderDetails[]> {
    const orders = await this.treezService.getOrders(
      storeId,
      userDto,
      page,
      count,
    );
    console.log('orders', orders?.ticketList);
    return orders;
  }

  @Post('uploadDocument/:storeId/:type')
  @UseInterceptors(FilesInterceptor('files'))
  async uploadDocument(
    @Param('storeId') storeId: number,
    @Param('type') type: ImageType,
    @UploadedFiles() files: Express.Multer.File,
    @Body() userDto: TreezUserDto,
  ): Promise<any> {
    for (const file of files as any) {
      const { Location, key } = await this.awsSService
        .uploadFile(file.originalname, file.buffer)
        .catch((e) => {
          console.log('uploadFile', e);
          return { Location: null, key: null };
        });

      if (Location && key) {
        const currentUser = await this.treezService.findUser(storeId, {
          id: +userDto.id,
        });
        console.log('currentUser', currentUser);
        console.log('userDto', userDto);
        const r = await this.treezService.updateUser(storeId, {
          ...currentUser.data[0],
          ...userDto,
          phone: userDto.phone.replace('+1', ''),
          imageList: [
            {
              lastupdated: formatDateToISODate(new Date()),
              type: type,
              url: Location,
            },
          ],
        });
        console.log('updateUser', r);
        return r;
      }
    }

    return false;
  }
}
