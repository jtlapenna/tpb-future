import { Controller, Get } from '@nestjs/common';

@Controller('apiv1/')
export class AppController {
  constructor() {}

  @Get()
  async getHello(): Promise<any> {
    return 'hello';
  }
}
