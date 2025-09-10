# Multi-Environment Deployment Pattern Validation

## Pattern Overview
The Multi-Environment Deployment pattern enables applications to be deployed and run consistently across different environments (development, staging, production) with environment-specific configurations. This pattern is crucial for maintaining a reliable software delivery pipeline and ensuring that applications behave consistently across different deployment contexts.

## Validation Evidence

### Backend (Ruby on Rails)

#### Environment Configuration
```repositories/back-end/config/database.yml```

The backend implements environment-specific database configurations:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: back_end_development

test:
  <<: *default
  database: back_end_test

production:
  <<: *default
  database: back_end_production
  username: back_end
  password: <%= ENV['BACK_END_DATABASE_PASSWORD'] %>

staging:
  <<: *default
```

#### Environment Variables and Containerization
```repositories/back-end/.env.sample```

The backend uses environment variables for configuration, with a sample containing 59 different configurable parameters:

```
AIRBRAKE_API_KEY=9f4c09c5e1f44c2e3921be0638bb5abf
RAILS_ENV=development
RAILS_LOG_TO_STDOUT=enabled
RAILS_MAX_THREADS=1
RAILS_SERVE_STATIC_FILES=enabled
REDIS_URL=redis://redis:6379
# Plus many more environment-specific APIs and credentials
```

```repositories/back-end/Dockerfile```

Containerization supports deployment across environments:

```dockerfile
FROM ruby:2.7.0
RUN apt-get update -qq \
&& apt-get install --no-install-recommends -y nodejs postgresql-client-11 \
&& apt-get install --no-install-recommends shared-mime-info -y
RUN apt-get clean \
&& rm -rf /var/lib/apt/lists/*
COPY . /TPB-API
WORKDIR /TPB-API
RUN bundle install
EXPOSE 3000
RUN chmod 777 ./entrypoint.sh \
    && ln -s ./entrypoint.sh /
CMD ["./entrypoint.sh"]
```

#### Continuous Integration Pipeline
```repositories/back-end/bitbucket-pipelines.yml```

CI/CD pipeline demonstrates environment-specific deployment:

```yaml
pipelines:
  branches:
    master:
      - step:
          name: Build image and push to ECR
          deployment: Production
          image: amazon/aws-cli:2.3.3
          services:
            - docker
          caches:
            - docker
          script:
            - export BUILD_ID=$BITBUCKET_BRANCH_$BITBUCKET_COMMIT_$BITBUCKET_BUILD_NUMBER
            - docker build -t api-tpb-ecr .
            - pipe: atlassian/aws-ecr-push-image:1.6.2
              variables:
                AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
                AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
                AWS_DEFAULT_REGION: us-west-2
                IMAGE_NAME: api-tpb-ecr
                TAGS: latest $BUILD_ID
```

### Frontend (Vue.js)

#### Environment-Specific Configuration
```repositories/front-end/config/dev.env.js``` and ```repositories/front-end/config/prod.env.js```

Vue.js frontend implements environment-specific webpack configurations:

```javascript
// dev.env.js
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
```

```javascript
// prod.env.js
'use strict'
module.exports = {
  NODE_ENV: '"production"',
  TPB_API_URL: process.env.TPB_API_URL ? `"${process.env.TPB_API_URL}"` : undefined,
  TPB_CATALOG_ID: process.env.TPB_CATALOG_ID ? `"${process.env.TPB_CATALOG_ID}"` : undefined,
  TPB_STORE_TOKEN: process.env.TPB_STORE_TOKEN ? `"${process.env.TPB_STORE_TOKEN}"` : undefined,
  SENTRY_ENVIRONMENT: process.env.SENTRY_ENVIRONMENT ? `"${process.env.SENTRY_ENVIRONMENT}"` : undefined,
  SENTRY_DSN: process.env.SENTRY_DSN ? `"${process.env.SENTRY_DSN}"` : undefined
}
```

#### Environment-Specific API Endpoints
```repositories/front-end/src/const/globals.js```

The frontend defines environment-specific API endpoints:

```javascript
export const API_ENVIROMENTS =
[
  {
    name: 'prod',
    url: 'https://api-prod.thepeakbeyond.com/api/v1'
  },
  {
    name: 'dev',
    url: 'https://tpb-api.aimservices.tech/api/v1'
  },
  {
    name: 'staging',
    url: 'https://tpb-api-stage.thepeakbeyond.com/api/v1'
  }
]
```

#### Containerization
```repositories/front-end/Dockerfile```

The Vue.js application is containerized for consistent deployment:

```dockerfile
FROM node:14.18.0
WORKDIR /kiosk
COPY package*.json ./
RUN npm install -g firebase-tools
RUN npm ci
EXPOSE 8080
CMD ["npm", "run", "start"]
```

```repositories/front-end/docker-compose.yml```

Docker Compose provides local development environment:

```yaml
version: "3.9"
services:
  web:
    build:
      context: ./
    volumes:
      - ./:/kiosk
      - /kiosk/node_modules
    ports:
      - "8080:8080"
    environment: 
      - CHOKIDAR_USEPOLLING=true
```

### CMS Frontend (Angular)

#### Environment Configuration Files
The Angular application includes multiple environment-specific files:

```repositories/cms-fe-angular/src/environments/environment.ts``` (Development)
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000',
  //  apiUrl: 'https://tpb-api-stage.thepeakbeyond.com',
  rfidSensorUrl: 'http://localhost:3001',
  SENTRY_DSN: 'https://622aeb4aab07f48c64a53b53174fa50f@o410977.ingest.sentry.io/4506020893229056'
};
```

```repositories/cms-fe-angular/src/environments/environment.prod.ts``` (Production)
```typescript
export const environment = {
  production: true,
  apiUrl: 'https://peak-beyond-api.herokuapp.com',
  rfidSensorUrl: 'http://localhost:3000',
  SENTRY_DSN: 'https://694892f149ab8a6ac6dfbd0b428b285d@o4505478124208128.ingest.sentry.io/4506044800499712'
};
```

```repositories/cms-fe-angular/src/environments/environment.staging.ts``` (Staging - Heroku)
```typescript
export const environment = {
  production: true,
  apiUrl: 'https://peak-beyond-api-staging.herokuapp.com',
  rfidSensorUrl: 'http://localhost:3000',
  SENTRY_DSN: 'https://622aeb4aab07f48c64a53b53174fa50f@o410977.ingest.sentry.io/4506020893229056'
};
```

```repositories/cms-fe-angular/src/environments/environment.staging-aws.ts``` (Staging - AWS)
```typescript
export const environment = {
  production: true,
  apiUrl: 'https://tpb-api-stage.thepeakbeyond.com',
  rfidSensorUrl: 'http://localhost:3000',
  SENTRY_DSN: 'https://622aeb4aab07f48c64a53b53174fa50f@o410977.ingest.sentry.io/4506020893229056'
};
```

#### Angular Build Configuration
```repositories/cms-fe-angular/angular.json```

Angular project configuration includes build configurations for multiple environments:

```json
{
  "configurations": {
    "production": { /* production settings */ },
    "staging": {
      "optimization": true,
      "outputHashing": "all",
      "sourceMap": false,
      "extractCss": true,
      "namedChunks": false,
      "aot": true,
      "extractLicenses": true,
      "vendorChunk": false,
      "buildOptimizer": true,
      "fileReplacements": [
        {
          "replace": "src/environments/environment.ts",
          "with": "src/environments/environment.staging.ts"
        }
      ]
    },
    "aimservices": { /* aimservices settings */ },
    "staging-aws": {
      "optimization": true,
      "outputHashing": "all",
      "sourceMap": false,
      "extractCss": true,
      "namedChunks": false,
      "aot": true,
      "extractLicenses": true,
      "vendorChunk": false,
      "buildOptimizer": true,
      "fileReplacements": [
        {
          "replace": "src/environments/environment.ts",
          "with": "src/environments/environment.staging-aws.ts"
        }
      ]
    }
  }
}
```

#### Continuous Integration Pipeline
```repositories/cms-fe-angular/bitbucket-pipelines.yml```

CI/CD pipeline demonstrates environment-specific deployment:

```yaml
pipelines:
  branches:
    staging:
        - step:
            name: Build
            caches:
              - node
            script:
              - npm install --legacy-peer-deps
              - npm run build --  --configuration=staging-aws
            artifacts:
              - dist/** # Save build for next steps
        - step:
            name: Deploy to AWS
            script:
              - export BITBUCKET_COMMIT_SHORT="${BITBUCKET_COMMIT::7}"
              - ssh -t centos@cms-stage.thepeakbeyond.com "mv /var/www/cms-stage /var/www/cms-stage-$BITBUCKET_COMMIT_SHORT && mkdir /var/www/cms-stage/"
              - scp -r dist/ centos@cms-stage.thepeakbeyond.com:/var/www/cms-stage

    main:
        - step:
            name: Build
            caches:
              - node
            script:
              - npm install --legacy-peer-deps
              - npm run build --  --configuration=aws
            artifacts:
              - dist/** # Save build for next steps
        - step:
            name: Deploy to AWS
            script:
              - export BITBUCKET_COMMIT_SHORT="${BITBUCKET_COMMIT::7}"
              - ssh -t centos@cms.thepeakbeyond.com "mv /var/www/cms-prod /var/www/cms-prod-$BITBUCKET_COMMIT_SHORT && mkdir /var/www/cms-prod/"
              - scp -r dist/ centos@cms.thepeakbeyond.com:/var/www/cms-prod
```

#### Containerization
```repositories/cms-fe-angular/Dockerfile```

The Angular application is containerized for consistent deployment:

```dockerfile
FROM node:16.17.0-alpine
WORKDIR /cms
RUN apk add --no-cache git
COPY package*.json ./
RUN npm install -g @angular/cli
RUN npm ci
EXPOSE 4200
CMD ["npm", "run", "start"]
```

## Cross-Repository Validation

### Implementation Consistency

| Feature | Backend | Frontend | CMS Frontend |
|---------|---------|----------|--------------|
| Environment Config | Rails environments + ENV vars | Webpack env configs | Angular environment files |
| Environment Types | dev, test, staging, prod | dev, staging, prod | dev, staging, staging-aws, prod, aimservices |
| Configuration Loading | Rails config + ENV | Webpack + ENV injection | Angular build-time replacement |
| Containerization | Docker + Docker Compose | Docker + Docker Compose | Docker + Docker Compose |
| CI/CD Pipeline | Bitbucket Pipelines to ECR | Not found | Bitbucket Pipelines to AWS VMs |
| Environment Variables | .env file (59+ variables) | Webpack injected (6+ variables) | Build-time configuration (4+ per env) |

### Validation Findings

1. **Consistent Environment Stratification**: All three repositories implement a similar multi-environment approach with at least development, staging, and production environments.

2. **Infrastructure Abstraction**: Environment-specific variables are consistently abstracted across all repositories:
   - Backend uses Rails environment configuration + ENV variables
   - Frontend uses Webpack environment configuration with variable injection
   - CMS Frontend uses Angular's built-in environment file replacement

3. **Containerization Across All Repositories**: Docker is used for development and deployment across all repositories:
   - Backend: Ruby-based container with Rails setup
   - Frontend: Node-based container with Vue setup
   - CMS Frontend: Node-based container with Angular setup

4. **CI/CD Implementation**:
   - Backend: Comprehensive pipeline to AWS ECR
   - CMS Frontend: Detailed pipeline with staging and production deployment to AWS VMs
   - Frontend: CI/CD configuration not found but likely exists based on deployment references

5. **Environment-Specific APIs and Services**:
   - All three repositories have environment-specific API endpoint configurations
   - Backend has environment-specific service integrations (e.g., Sentry, AWS)
   - Frontend and CMS Frontend reference different backend API endpoints per environment

6. **Configuration Isolation**:
   - Backend: Uses .env files and Rails environment configuration
   - Frontend: Separates configuration with dev.env.js and prod.env.js
   - CMS Frontend: Uses multiple environment.*.ts files

## Recommendations

1. **Standardize Environment Configuration**:
   - Consider using a consistent approach for environment variables across all repositories
   - Implement a shared configuration management service for distributed configuration

2. **Enhance Configuration Security**:
   - Implement a secrets management solution
   - Remove hardcoded credentials from environment sample files
   - Standardize credential rotation practices

3. **Centralize Deployment Pipeline**:
   - Consider implementing a monorepo approach or orchestrated deployment
   - Ensure all repositories deploy in a coordinated manner with compatible versions

4. **Container Orchestration**:
   - Consider implementing Kubernetes for more robust multi-environment deployment
   - Standardize container health checks and monitoring

5. **Environment Parity**:
   - Ensure closer dev/prod parity through containerization
   - Implement infrastructure-as-code for all environments

6. **Documentation Improvements**:
   - Create comprehensive environment setup guides
   - Document the required environment variables for each repository
   - Create deployment runbooks for each environment

## Conclusion

The Multi-Environment Deployment pattern is successfully implemented across all three repositories, enabling deployment to various environments with appropriate configurations. The implementation demonstrates a robust understanding of environment separation, with each repository containing the necessary configuration abstractions for different deployment contexts.

The project shows a mature multi-environment architecture with clear separation between development, staging, and production configurations. While there are some variations in approach between repositories (which is expected given the different frameworks), the overall pattern implementation is consistent and effective. 