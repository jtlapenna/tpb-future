import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { userAuthorization } from '../helpers/authorization.helper';

@Injectable()
export class AuthGuard implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();

    const token = (request.headers.authorization || '').replace('Bearer ', '');
    return userAuthorization(token);
  }
}
