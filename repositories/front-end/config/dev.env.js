'use strict'
require('dotenv').config({ path: '.env' });
const merge = require('webpack-merge')
const prodEnv = require('./prod.env')

module.exports = merge(prodEnv, {
  NODE_ENV: '"development"',
  TPB_API_URL: process.env.TPB_API_URL ? `"${process.env.TPB_API_URL}"` : undefined,
  TPB_CATALOG_ID: process.env.TPB_CATALOG_ID ? `"${process.env.TPB_CATALOG_ID}"` : undefined,
  TPB_STORE_TOKEN: process.env.TPB_STORE_TOKEN ? `"${process.env.TPB_STORE_TOKEN}"` : undefined,
  SENTRY_ENVIRONMENT: process.env.SENTRY_ENVIRONMENT ? `"${process.env.SENTRY_ENVIRONMENT}"` : undefined,
  SENTRY_DSN: process.env.SENTRY_DSN ? `"${process.env.SENTRY_DSN}"` : undefined
})
