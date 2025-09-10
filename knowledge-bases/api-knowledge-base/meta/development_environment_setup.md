# Development Environment Setup

## Overview
The application uses Docker for containerization, with separate services for the API, PostgreSQL database, Redis, and Sidekiq. This setup ensures consistent development environments across the team.

## Prerequisites

1. **Required Software**
   - Docker Engine
   - Docker Compose
   - Git
   - Ruby 2.7.0 (optional, for local development)

2. **System Requirements**
   - Memory: 4GB minimum
   - Storage: 10GB free space
   - Ports: 3000, 5432, 6379 available

## Repository Setup

1. **Clone the Repository**
   ```bash
   git clone [repository-url]
   cd thepeakbeyond-aim-tpb-be
   ```

2. **Environment Configuration**
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

## Docker Configuration

### 1. Service Architecture
The application consists of four main services:

1. **API Service** (`api`)
   - Rails application
   - Port: 3000
   - Base image: ruby:2.7.0

2. **Database Service** (`db`)
   - PostgreSQL 12.19
   - Port: 5432
   - Credentials:
     - User: tpb
     - Password: tpb
     - Database: tpb_api

3. **Redis Service** (`redis`)
   - Custom Redis build
   - Port: 6379
   - Used for caching and job queue

4. **Sidekiq Service** (`sidekiq`)
   - Background job processing
   - Depends on Redis
   - Shares codebase with API

### 2. Docker Files

1. **Main Dockerfile**
   ```dockerfile
   FROM ruby:2.7.0
   RUN apt-get update -qq \
   && apt-get install --no-install-recommends -y nodejs postgresql-client-11 \
   && apt-get install --no-install-recommends shared-mime-info -y
   WORKDIR /TPB-API
   RUN bundle install
   EXPOSE 3000
   CMD ["./entrypoint.sh"]
   ```

2. **Docker Compose Configuration**
   ```yaml
   version: '3.8'
   services:
     db:
       image: postgres:12.19
     redis:
       build: ./redis
     api:
       build: .
       ports: ["3000:3000"]
     sidekiq:
       build: .
       command: bundle exec sidekiq
   ```

## Development Workflow

### 1. Initial Setup
```bash
# Build and start services
docker-compose build
docker-compose up -d

# Setup database
docker-compose exec api rails db:setup
```

### 2. Common Commands
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f [service]

# Run tests
docker-compose exec api rspec

# Rails console
docker-compose exec api rails c

# Stop all services
docker-compose down
```

### 3. Database Management
```bash
# Create database
docker-compose exec api rails db:create

# Run migrations
docker-compose exec api rails db:migrate

# Seed data
docker-compose exec api rails db:seed
```

## Configuration Files

### 1. Environment Variables
Required variables in `.env`:
```bash
RAILS_ENV=development
DATABASE_URL=postgres://tpb:tpb@db:5432/tpb_api
REDIS_URL=redis://redis:6379/0
```

### 2. Database Configuration
Located in `config/database.yml`:
```yaml
development:
  url: <%= ENV['DATABASE_URL'] %>
```

### 3. Redis Configuration
Located in `config/redis.yml`:
```yaml
development:
  url: <%= ENV['REDIS_URL'] %>
```

## Testing Environment

### 1. Test Setup
```bash
# Create test database
docker-compose exec api rails db:test:prepare

# Run all tests
docker-compose exec api rspec

# Run specific tests
docker-compose exec api rspec path/to/spec
```

### 2. Test Configuration
Located in `config/environments/test.rb`:
- Cache disabled
- Error reports enabled
- Mailer in test mode

## Debugging

### 1. Logging
- Application logs: `docker-compose logs -f api`
- Database logs: `docker-compose logs -f db`
- Sidekiq logs: `docker-compose logs -f sidekiq`

### 2. Rails Console
```bash
docker-compose exec api rails c
```

### 3. Database Console
```bash
docker-compose exec db psql -U tpb -d tpb_api
```

## Best Practices

1. **Container Management**
   - Use named volumes for persistence
   - Clean up unused containers/images
   - Monitor container resources

2. **Development Workflow**
   - Keep containers updated
   - Use consistent environment variables
   - Follow Git workflow

3. **Performance**
   - Monitor container memory usage
   - Use volume mounts for development
   - Optimize Docker builds

## Troubleshooting

1. **Common Issues**
   - Port conflicts
   - Database connection errors
   - Redis connection issues
   - Permission problems

2. **Solutions**
   - Check port availability
   - Verify service dependencies
   - Review container logs
   - Reset Docker state

## Next Steps

1. **Local Development**
   - Configure IDE integration
   - Set up debugging tools
   - Install development gems

2. **Testing**
   - Configure test coverage
   - Set up CI integration
   - Add automated tests

3. **Monitoring**
   - Set up logging aggregation
   - Configure performance monitoring
   - Implement error tracking

*Last Updated: March 20, 2024* 