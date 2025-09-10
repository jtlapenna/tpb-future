import { Controller, Get, Param } from '@nestjs/common';
import { DataBaseQueryEnum } from 'src/common/constants/database.query.enum';
import { Company } from 'src/models/companies/company.entity';
import { CompanyService } from './company.service';

@Controller('apiv1/company')
export class CompanyController {
  constructor(private readonly companyService: CompanyService) {}

  @Get('all/:sort?/:page?/:count?')
  async getAll(
    @Param('sort') sort?: string,
    @Param('page') page?: number,
    @Param('count') count?: number,
  ): Promise<Company[]> {
    return this.companyService.findAll(
      sort || 'name',
      page || 1,
      count || DataBaseQueryEnum.COUNT,
    );
  }

  @Get('find/:id')
  async find(@Param('id') id: number): Promise<Company> {
    return this.companyService.findOne(id);
  }
}
