import * as AWS from 'aws-sdk';

export const getSecretKey = async (secretName: string): Promise<any> => {
  AWS.config.update({
    accessKeyId: process.env.S3_AWS_ACCESS_KEY,
    secretAccessKey: process.env.S3_SECRET_KEY,
  });

  const client = new AWS.SecretsManager({
    region: process.env.S3_REGION,
  });

  const data = await client
    .getSecretValue({ SecretId: secretName })
    .promise()
    .catch((e) => e);

  if (data.code) {
    console.log('getSecretValue', data.code);

    return { error: data.code };
  }

  if (data.SecretString) {
    return data.SecretString;
  } else {
    const buff = new Buffer(data.SecretBinary, 'base64');
    return buff.toString('ascii');
  }
};
