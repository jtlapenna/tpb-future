# Back-end API

A Rails API application with PostgreSQL database.

## Requirements

- Ruby 3.0.x
- PostgreSQL
- Bundler

## Setup

1. Install dependencies:
```bash
bundle install
```

2. Setup database:
```bash
rails db:create db:migrate
```

3. Start the server:
```bash
rails server
```

## Testing

Run the test suite with coverage:
```bash
COVERAGE=true bundle exec rspec
```

The coverage report will be generated in `coverage/index.html`.

## API Documentation

Generate API documentation:
```bash
bundle exec rake docs:generate
```

The documentation will be generated in `doc/api/index.html`.

## API Endpoints

### Health Check
- `GET /api/v1/health` - Get application health status
- `GET /api/v1/ping` - Simple ping endpoint

### Users
- `GET /api/v1/users` - List all users
- `GET /api/v1/users/:id` - Get a specific user

## Run dev server
```bash
rails server
```

## Run dev server and test

```bash
bundle exec guard
```

This will start the API on port 3001

## To avoid run `bundle update peak_beyond_model`
```bash
bundle config local.peak_beyond_model /path/to/local/git/repository
```

## Generate api docs
```bash
rake docs:generate
```

## Restoring a backup in your local

* For this one you can check the `restore_db.sh` file and follow the steps in that script, it's not automated on purpose, the idea is that you simply follow the steps in it.
* IMPORTANT: Use the steps in the script, don't run the `restore_db.sh` script.

## Known issues

* If you are getting a 401 after a restore you must make sure that the user you are using is active in the database.