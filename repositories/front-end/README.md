# Setup TPB Frontend (FE)

Follow these steps to set up and run the TPB frontend:

## 1. Clone the Repository
Download the project code from the repository.

```sh
git clone <your-repo-url>
cd <your-repo-folder>
```

## 2. Update Configuration
Navigate to the `config.js` file inside the `static/js/` directory and update the following values:

- **URL:** Replace with your API URL (default: `http://localhost:3000/api/v1`). You can also use the **staging** or **production** URLs to point your local environment to one of those environments.
- **CATALOG_ID:** Set this to your store ID.
- **TOKEN:** Use the token you generated while running the CMS. If you need a token for a **production kiosk**, you must obtain it from the **infra support team** via **Puppet/Guacamole**, as generating a new token will disrupt existing kiosk configurations.

staging URL: `https://tpb-api-stage.thepeakbeyond.com/api/v1`
production URL: `https://api-prod.thepeakbeyond.com/api/v1`

### Example `config.js`:
```js
URL: "http://localhost:3000/api/v1",
  CATALOG_ID: 1,
  TOKEN: "your-generated-token-here",
```

## 3. Install Docker Compose
Ensure that **Docker Compose** is installed on your system before proceeding. If you haven’t installed it yet, follow the [official Docker documentation](https://docs.docker.com/compose/install/) to set it up.

## 4. Start the Application
Open a terminal, navigate to the project folder, and run:

```sh
docker-compose up -d
```

## 5. Access the Frontend
Once the application is running, open your browser and go to:

[http://localhost:8080](http://localhost:8080)
