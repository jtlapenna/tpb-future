import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { userAuthorization } from '../helpers/authorization.helper';

export const User = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const token = (request.headers.authorization || '').replace('Bearer ', '');
    const payload = userAuthorization(token);
    return payload;
  },
);
