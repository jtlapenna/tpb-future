import { ApiProperty } from '@nestjs/swagger';

export class UserFindDto {
  @ApiProperty()
  id?: number;

  @ApiProperty()
  email?: string;

  @ApiProperty()
  firstName?: string;

  @ApiProperty()
  lastName?: string;

  @ApiProperty()
  phone?: string;

  @ApiProperty()
  driverLicense?: string;

  @ApiProperty()
  birthday?: string;
}
