import { UnauthorizedException } from '@nestjs/common';
import * as CognitoExpress from 'cognito-express';

export const userAuthorization = async (token: string) => {
  if (!token) {
    throw new UnauthorizedException();
  }

  const cognitoExpress = new CognitoExpress({
    region: process.env.S3_REGION,
    cognitoUserPoolId: process.env.COGNITO_USER_POOL_ID,
    tokenUse: 'access',
    tokenExpiration: 3600,
  });

  const result = await cognitoExpress.validate(token).catch((e) => {
    console.log('e', token);
    return null;
  });

  if (!result) {
    throw new UnauthorizedException();
  }

  return result;
};
