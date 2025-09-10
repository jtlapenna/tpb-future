# Infrastructure Analysis Findings

## Overview
This document provides a detailed analysis of the infrastructure configuration and deployment strategies across the three repositories. It examines how each component is deployed, the hosting environments used, and the integration between different infrastructure components.

**Sources Reviewed:**
- Backend: Docker configurations, AWS deployment scripts, environment configurations
- Frontend: Docker configurations, Firebase configurations, environment settings
- CMS: Docker configurations, AWS deployment scripts, environment variables
- CI/CD: Pipeline configurations in Bitbucket pipelines

## Key Findings

### Infrastructure Architecture

#### Multi-Environment Deployment Strategy
- **Three Distinct Environments**:
  - Development (Local): Docker Compose setup
  - Staging: AWS/Firebase hosting
  - Production: AWS hosting with specialized configurations

#### Containerization Approach
- **Docker-based Development Environment**:
  - All three repositories use Docker for local development
  - Docker Compose orchestrates multi-container applications
  - Consistent environment configuration across repositories

#### Cloud Provider Selection
- **AWS as Primary Production Infrastructure**:
  - Backend: EC2, Elastic Beanstalk, and ECR for container registry
  - CMS: EC2-hosted Angular application
  - S3 for asset storage with CloudFront distribution

- **Firebase for Frontend Hosting**:
  - Multiple Firebase targets for different store implementations
  - Separation of concerns with target-specific configurations

### Backend Infrastructure Implementation

#### Docker-Based Local Development
```yaml
# From repositories/back-end/docker-compose.yml
version: '3.8'
services:
  db:
    image: postgres:12.19
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: tpb
      POSTGRES_PASSWORD: tpb    
      POSTGRES_DB: tpb_api
    volumes:
      - ~/.postgres/data/tpb:/var/lib/postgresql/data
  redis:
      build:
        context: ./redis
      image: myredis
      ports:
        - 6379:6379
  api:
    build: .
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    volumes:
      - .:/TPB-API
    ports:
      - "3000:3000"
    depends_on:
      - db
    env_file:
      - .env
  sidekiq:
    build: .
    command: bundle exec sidekiq
    depends_on:
      - redis
    volumes:
      - .:/TPB-API
    env_file:
      - .env
```

#### AWS Production Deployment
- **Elastic Beanstalk for API Service**:
  ```yaml
  # From repositories/back-end/bitbucket-pipelines.yml
  - pipe: atlassian/aws-elasticbeanstalk-deploy:0.2.3
    variables:
      AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
      AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
      AWS_DEFAULT_REGION: us-west-2
      APPLICATION_NAME: 'tpb-api-be'
      COMMAND: 'deploy-only'
      ENVIRONMENT_NAME: 'api-prod'
      VERSION_LABEL: 'api-prod-stable'
      WAIT: 'true'
  ```

- **EC2 Instances for Sidekiq Workers**:
  ```yaml
  # From repositories/back-end/bitbucket-pipelines.yml
  - ssh -t centos@sidekiq.thepeakbeyond.com "cd /srv/cms && sudo systemctl stop puma && sudo systemctl stop sidekiq && git pull origin master && bundle install && rails db:migrate && sudo systemctl start puma && sudo systemctl start sidekiq"
  ```

#### S3 Asset Storage
- **Configured via Environment Variables**:
  ```ruby
  # From repositories/back-end/app/operations/clone_kiosk_operation.rb
  def bucket_name
    ENV['BUCKET_NAME'] || raise_error('BUCKET_NAME must be defined.')
  end

  def bucket_region
    ENV['BUCKET_REGION'] || raise_error('BUCKET_REGION must be defined.')
  end
  ```

### CMS Infrastructure Implementation

#### Docker-Based Local Development
```yaml
# From repositories/cms-fe-angular/docker-compose.yml
version: "3.9"
services:
  web:
    build:
      context: ./
    volumes:
      - ./:/cms
      - /cms/node_modules
    ports:
      - "4200:4200"
```

#### AWS Production Deployment
- **Angular Application on EC2**:
  ```yaml
  # From repositories/cms-fe-angular/bitbucket-pipelines.yml
  - step:
      name: Deploy to AWS
      script:
        - export BITBUCKET_COMMIT_SHORT="${BITBUCKET_COMMIT::7}"
        - ssh -t centos@cms.thepeakbeyond.com "mv /var/www/cms-prod /var/www/cms-prod-$BITBUCKET_COMMIT_SHORT && mkdir /var/www/cms-prod/"
        - scp -r dist/ centos@cms.thepeakbeyond.com:/var/www/cms-prod
  ```

#### Environment Configuration
- **Environment-Specific Settings**:
  ```typescript
  // From repositories/cms-fe-angular/src/environments/environment.aws.ts
  export const environment = {
    production: true,
    apiUrl: 'https://api-prod.thepeakbeyond.com',
    rfidSensorUrl: 'http://localhost:3000',
    SENTRY_DSN: 'https://622aeb4aab07f48c64a53b53174fa50f@o410977.ingest.sentry.io/4506020893229056'
  };
  ```

### Frontend Infrastructure Implementation

#### Docker-Based Local Development
```yaml
# From repositories/front-end/docker-compose.yml
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

#### Firebase Hosting for Production
- **Multiple Target Configurations**:
  ```json
  // From repositories/front-end/.firebaserc
  {
    "projects": {
      "staging": "tpb-kiosk-fe-vue"
    },
    "targets": {
      "tpb-kiosk-fe-vue": {
        "hosting": {
          "purchase-limit": [
            "purchase-limit"
          ],
          "jarupa": [
            "tpb-kiosk-jarupa"
          ],
          "treez": [
            "tpb-kiosk-treez"
          ],
          ...
        }
      }
    }
  }
  ```

#### Environment Configuration
- **Environment Variables Through Config**:
  ```javascript
  // From repositories/front-end/src/main.js
  const TPB_API_URL = process.env.TPB_API_URL
    ? process.env.TPB_API_URL
    : self.kioskConfig.API.URL
  const TPB_CATALOG_ID = process.env.TPB_CATALOG_ID
    ? process.env.TPB_CATALOG_ID
    : self.kioskConfig.API.CATALOG_ID
  const TPB_STORE_TOKEN = process.env.TPB_STORE_TOKEN
    ? process.env.TPB_STORE_TOKEN
    : self.kioskConfig.API.TOKEN
  ```

### CI/CD Implementation

#### Bitbucket Pipelines
- **Backend Pipeline**:
  - Build Docker image
  - Push to ECR
  - Deploy to Elastic Beanstalk
  - Update Sidekiq workers

- **CMS Pipeline**:
  - Build Angular application
  - Deploy to EC2 instance
  - Versioned backups of previous deployments

- **Frontend Pipeline**:
  - Implicitly using Firebase deployment
  - Multiple target configurations

### Cross-Repository Infrastructure Connections

#### API URL Configuration
- **CMS to Backend**:
  ```typescript
  // From repositories/cms-fe-angular/src/environments/environment.aws.ts
  export const environment = {
    apiUrl: 'https://api-prod.thepeakbeyond.com',
    // other settings
  };
  ```

- **Frontend to Backend**:
  ```javascript
  // From repositories/front-end/src/main.js
  const TPB_API_URL = process.env.TPB_API_URL
    ? process.env.TPB_API_URL
    : self.kioskConfig.API.URL
  ```

#### Shared Asset Management
- **S3 for Asset Storage**:
  - Backend creates presigned URLs
  - CMS and Frontend access assets via CloudFront distribution
  - Common asset structure across all environments

## Integration Challenges and Patterns

### Challenges Identified
1. **Environment Synchronization**: Different deployment cycles may lead to version mismatches
2. **Token Management**: Environment-specific token handling adds complexity
3. **Separate Hosting Providers**: AWS for Backend/CMS, Firebase for Frontend requires coordination
4. **Manual Deployment Steps**: Some deployment steps require SSH and manual intervention

### Effective Patterns
1. **Containerized Development**: Consistent Docker development environment
2. **Environment-Specific Configurations**: Clear separation of dev/staging/production configs
3. **Versioned Deployments**: CMS deployments create backup versions
4. **Infrastructure as Code**: Most infrastructure defined in version-controlled configs

## Questions & Gaps

### Open Questions
1. How is database migration coordinated with API deployments?
2. What is the disaster recovery strategy?
3. How are infrastructure changes tested before deployment?

### Areas Needing Investigation
- Load balancing configuration
- Monitoring and alerting setup
- Secret management approach
- Database backup strategy

### Potential Risks
- **Manual Deployment Steps**: SSH commands in pipelines create potential for human error
- **Long-lived SSH Access**: Security implications of direct server access
- **Environment Variable Management**: Potential for misconfiguration
- **Different Hosting Providers**: Coordination challenges between AWS and Firebase

## Next Steps
1. Document complete infrastructure diagram
2. Analyze scaling strategy
3. Review security implications of current setup
4. Establish deployment coordination practices

## Cross-References
- Related to: [API Integration Analysis](./api-integration-findings.md)
- Related to: [Auth Flow Analysis](./auth-flow-findings.md)
- Supports: [Data Store Findings](./data-store-findings.md)

## Version History
- 1.0.0 (2024-03-21): Initial findings document created 