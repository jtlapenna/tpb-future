import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Company } from 'src/models/companies/company.entity';
import { Repository } from 'typeorm';

@Injectable()
export class CompanyService {
  constructor(
    @InjectRepository(Company)
    private companyRepository: Repository<Company>,
  ) {}

  findAll(column: string, pageIndex = 1, count = 20): Promise<Company[]> {
    return this.companyRepository.find({
      order: {
        [column]: 'ASC',
      },
      skip: (pageIndex - 1) * count,
      take: count,
    });
  }

  findOne(id: number): Promise<Company> {
    return this.companyRepository.findOne(id);
  }
}
