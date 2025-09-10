import { Injectable } from '@nestjs/common';
import fetch from 'node-fetch';
import { UserDto } from 'src/models/dto/user.dto';
import { StoreService } from 'src/modules/store/store.service';
import { OrderStatus } from './enums/order-status.enum';
import { ResponseCode } from './enums/response-code.enum';
import { OrderDetails } from './interfaces/order-response.interface';
import { OrderDto } from './interfaces/order.dto';
import { TreezUserDto } from './interfaces/treez-user.dto';
import { UserFindDto } from './interfaces/user-find.dto';

const options = {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
};

@Injectable()
export class TreezService {
  constructor(private readonly storeService: StoreService) {}

  async post(body: any, url: string): Promise<any> {
    const response = await fetch(url, {
      ...options,
      body,
    });

    return response.json();
  }

  async get(url: string, storeId: number): Promise<any> {
    const { token, dispensaryName, clientId } = await this.getToken(storeId);

    const response = await fetch(this.replaceDispensary(url, dispensaryName), {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
        client_id: clientId,
      },
    });

    return response.json();
  }

  replaceDispensary(url: string, dispensaryName: string) {
    if (+process.env.SANDBOX === 1) {
      return url
        .replace('{0}', dispensaryName)
        .replace('{1}', 'partnersandbox2');
    }
    return url.replace('{0}', dispensaryName).replace('{1}', 'dispensary');
  }

  async postJson(body: any, url: string, storeId: number): Promise<any> {
    const { token, dispensaryName, clientId } = await this.getToken(storeId);

    const response = await fetch(this.replaceDispensary(url, dispensaryName), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
        client_id: clientId,
      },
      body: JSON.stringify(body),
    });

    return response.json();
  }

  async getToken(storeId: number): Promise<any> {
    const store = await this.storeService.findOne(storeId);
    const settings =
      +process.env.SANDBOX === 1
        ? {
            api_client_id: 'KmuKhv3XlvnLZ31mhAsgueQlTaEObHGz',
            api_key: 'ZWM4Y2Q1MTA2MWMxYTYzZDgxN',
            dispensary_name: 'partnersandbox2',
          }
        : JSON.parse(store.apiSettings);

    const response = await this.post(
      `client_id = ${settings.api_client_id}&apikey=${settings.api_key}`,
      `${this.replaceDispensary(
        process.env.TREEZ_API,
        settings.dispensary_name,
      )}config/api/gettokens`,
    );

    if (response.resultCode === ResponseCode.SUCCESS) {
      return {
        token: response.access_token,
        dispensaryName: settings.dispensary_name,
        clientId: settings.api_client_id || '',
      };
    }

    return null;
  }

  async updateUser(storeId: number, userDto: TreezUserDto): Promise<any> {
    const response = await this.postJson(
      userDto,
      `${process.env.TREEZ_API}customer/update/${+userDto.id}`,
      storeId,
    );

    return response;
  }

  async createUser(storeId: number, userDto: TreezUserDto): Promise<any> {
    const response = await this.postJson(
      userDto,
      `${process.env.TREEZ_API}customer/detailcustomer`,
      storeId,
    );

    return response;
  }

  async isUserValid(storeId: number, user: any, userFindDto: UserFindDto) {
    if (user.resultCode === 'SUCCESS') {
      if (user.data && user.data.length > 0) {
        if (userFindDto.birthday) {
          const users = user.data.filter(
            (c) => c.birthday === `${userFindDto.birthday}`,
          );

          if (users.length === 1) {
            return {
              ...user,
              data: [users[0]],
            };
          }
          return null;
        }

        if (!user.data[0].email && userFindDto.email) {
          await this.updateUser(storeId, {
            ...user.data[0],
            email: userFindDto.email,
          });
        }

        return {
          ...user,
          data: [user.data[0]],
        };
      } else if (user.data && user.data.length === 0) {
        return null;
      } else if (user.data) {
        if (!user.data.email && userFindDto.email) {
          await this.updateUser(storeId, {
            ...user.data,
            email: userFindDto.email,
          });
        }

        return {
          ...user,
          data: [user.data],
        };
      }
    }

    return null;
  }

  async findUser(storeId: number, userFindDto: UserFindDto): Promise<any> {
    let user = null;

    if (userFindDto.id) {
      user = await this.get(
        `${process.env.TREEZ_API}customer/${userFindDto.id}`,
        storeId,
      );

      user = await this.isUserValid(storeId, user, userFindDto);
      if (user) {
        return user;
      }
    }

    if (userFindDto.email) {
      user = await this.get(
        `${process.env.TREEZ_API}customer/email/${userFindDto.email}`,
        storeId,
      );

      user = await this.isUserValid(storeId, user, userFindDto);
      if (user) {
        return user;
      }
    }

    if (userFindDto.firstName && userFindDto.lastName) {
      user = await this.get(
        `${process.env.TREEZ_API}customer/firstname/${userFindDto.firstName}/lastname/${userFindDto.lastName}`,
        storeId,
      );

      user = await this.isUserValid(storeId, user, userFindDto);
      if (user) {
        return user;
      }
    }

    if (userFindDto.phone) {
      user = await this.get(
        `${process.env.TREEZ_API}customer/phone/${userFindDto.phone}`,
        storeId,
      );

      user = await this.isUserValid(storeId, user, userFindDto);
      if (user) {
        return user;
      }
    }

    if (userFindDto.driverLicense) {
      user = await this.get(
        `${process.env.TREEZ_API}customer/driverlicense/${userFindDto.driverLicense}`,
        storeId,
      );

      user = await this.isUserValid(storeId, user, userFindDto);
      if (user) {
        return user;
      }
    }

    return {
      resultCode: 'SUCCESS',
      data: [],
    };
  }

  async createOrder(storeId: number, orderDto: OrderDto): Promise<any> {
    const response = await this.postJson(
      {
        ...orderDto,
        order_status: OrderStatus.AWAITING_PROCESSING,
      },
      `${process.env.TREEZ_API}ticket/detailticket`,
      storeId,
    );

    return response;
  }

  async getOrderById(storeId: number, orderId: number): Promise<OrderDetails> {
    return this.get(`${process.env.TREEZ_API}ticket/${orderId}`, storeId);
  }

  async getOrders(
    storeId: number,
    userDto: UserDto,
    page?: number,
    pagesize?: number,
  ): Promise<any> {
    const user = await this.findUser(storeId, {
      id: +userDto.customerId,
      lastName: userDto.lastName,
      firstName: userDto.firstName,
      email: userDto.email,
    });

    if (!user || !user.data || user.data.length === 0) {
      return [];
    }

    return this.get(
      `${process.env.TREEZ_API}ticket/customer/${+user.data[0]
        ?.customer_id}/page/${page || 1}/pagesize/${pagesize || 25}`,
      storeId,
    );
  }
}
