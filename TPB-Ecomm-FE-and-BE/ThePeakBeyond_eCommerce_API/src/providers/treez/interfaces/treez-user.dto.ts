import { AddressType } from '../enums/address-type.enum';
import { ImageType } from '../enums/image-type.enum';
import { ApiProperty } from '@nestjs/swagger';

export class TreezUserDto {
  @ApiProperty()
  id?: number;

  @ApiProperty()
  birthday: string;

  @ApiProperty()
  email: string;

  @ApiProperty()
  phone: string;

  @ApiProperty()
  notes: string;

  @ApiProperty()
  gender: string;

  @ApiProperty()
  banned: boolean;

  @ApiProperty()
  first_name: string;

  @ApiProperty()
  middle_name: string;

  @ApiProperty()
  nickname: string;

  @ApiProperty()
  last_name: string;

  @ApiProperty()
  drivers_license: string;

  @ApiProperty()
  drivers_license_expiration: string;

  @ApiProperty()
  is_caregiver: boolean;

  @ApiProperty()
  caregiver_license_number: string;

  @ApiProperty()
  state_medical_id: string;

  @ApiProperty()
  permit_expiration: string;

  @ApiProperty()
  physician_first_name: string;

  @ApiProperty()
  physician_last_name: string;

  @ApiProperty()
  physician_license: string;

  @ApiProperty()
  physician_address: string;

  @ApiProperty()
  physician_phone: number;

  @ApiProperty()
  caregiver_name_1: string;

  @ApiProperty()
  caregiver_name_2: string;

  @ApiProperty()
  opt_out: boolean;

  @ApiProperty()
  referral_source: string;

  @ApiProperty()
  warning_1: boolean;

  @ApiProperty()
  warning_2: boolean;

  @ApiProperty()
  patient_type: string;

  @ApiProperty()
  customer_groups: string;
  @ApiProperty()
  customer_id?: number;
  @ApiProperty()
  verification_status?: string;
  @ApiProperty()
  verification_reasons?: any[];
  @ApiProperty()
  caregiver_details?: any[];
  @ApiProperty()
  rewards_balance?: number;
  @ApiProperty()
  rewards_type?: string;

  @ApiProperty()
  signup_date?: Date;
  @ApiProperty()
  last_visit_date?: Date;
  @ApiProperty()
  last_update?: Date;
  @ApiProperty()
  addresses?: AddresstDto[];
  @ApiProperty()
  imageList?: ImageListDto[];
}

export class ImageListDto {
  @ApiProperty()
  type: ImageType;

  @ApiProperty()
  url: string;

  @ApiProperty()
  lastupdated: string;
}

export class AddresstDto {
  @ApiProperty()
  type: AddressType;

  @ApiProperty()
  street1: string;
  @ApiProperty()
  street2: string;

  @ApiProperty()
  city: string;

  @ApiProperty()
  state: string;

  @ApiProperty()
  primary: boolean;

  @ApiProperty()
  zipcode: string;
}
