import { Injectable } from '@nestjs/common';
import * as AWS from 'aws-sdk';

@Injectable()
export class AWSService {
  constructor() {
    AWS.config.update({
      accessKeyId: process.env.S3_AWS_ACCESS_KEY,
      secretAccessKey: process.env.S3_SECRET_KEY,
    });
  }

  async uploadFile(key: any, fileContent: any): Promise<any> {
    const date = new Date();
    const s3 = new AWS.S3();
    const params = {
      Bucket: process.env.S3_BUCKET_NAME,
      Key: `${date.getTime()}-${key}`,
      Body: fileContent,
    };

    return await s3.upload(params).promise();
  }

  async getSecretKey(secretName: string): Promise<any> {
    const client = new AWS.SecretsManager({
      region: process.env.S3_REGION,
    });

    const data = await client
      .getSecretValue({ SecretId: secretName })
      .promise()
      .catch((e) => e);

    if (data.code) {
      console.log(data.code);

      return { error: data.code };
    }

    if (data.SecretString) {
      return data.SecretString;
    } else {
      const buff = new Buffer(data.SecretBinary, 'base64');
      return buff.toString('ascii');
    }
  }
}
