# API Client Libraries

## Overview
The Peak Beyond API provides client libraries for multiple programming languages to facilitate integration. These libraries are hosted in private repositories and require appropriate credentials for access.

## Available Libraries

### JavaScript/TypeScript
- Package: `@peakbeyond/api-client`
- Repository: Private NPM registry
- Contact your system administrator for access credentials

### Ruby
- Package: `peakbeyond-api-client`
- Repository: Private gem server
- Contact your system administrator for access credentials

### Python
- Package: `peakbeyond-api-client`
- Repository: Private PyPI server
- Contact your system administrator for access credentials

## Installation

### JavaScript/TypeScript
```bash
# Configure NPM for private registry
npm config set @peakbeyond:registry https://npm.peakbeyond.com/
npm install @peakbeyond/api-client
```

### Ruby
```bash
# Add private gem source to your Gemfile
source 'https://gems.peakbeyond.com' do
  gem 'peakbeyond-api-client'
end
```

### Python
```bash
# Configure pip for private repository
pip config set global.extra-index-url https://pypi.peakbeyond.com/simple/
pip install peakbeyond-api-client
```

## Authentication
Each client library requires appropriate authentication credentials. Contact your system administrator for access tokens and configuration details.

*Last Updated: March 20, 2024* 