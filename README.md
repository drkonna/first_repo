# Dev Server Setup: .NET + Vue 3 + MySQL

A step-by-step guide to setting up your laptop as a local development server for hosting **.NET** back-end APIs, **Vue 3** front-end applications, and a **MySQL** database.

---

## Table of Contents

1. [Overview](#overview)
2. [Option A – Native Installation](#option-a--native-installation)
   - [1. Install .NET SDK](#1-install-net-sdk)
   - [2. Install Node.js & npm](#2-install-nodejs--npm)
   - [3. Install MySQL Server](#3-install-mysql-server)
   - [4. Create a .NET Web API Project](#4-create-a-net-web-api-project)
   - [5. Create a Vue 3 Project](#5-create-a-vue-3-project)
   - [6. Connect .NET API to MySQL](#6-connect-net-api-to-mysql)
   - [7. Set Up a Reverse Proxy with Nginx](#7-set-up-a-reverse-proxy-with-nginx)
3. [Option B – Docker (Recommended for Dev)](#option-b--docker-recommended-for-dev)
4. [Environment Variables](#environment-variables)
5. [Useful Commands](#useful-commands)

---

## Overview

| Layer       | Technology          | Default Port |
|-------------|---------------------|-------------|
| Database    | MySQL 8             | 3306        |
| Back-end    | .NET 8 Web API      | 5000 / 5001 |
| Front-end   | Vue 3 (Vite)        | 5173        |
| Proxy       | Nginx (optional)    | 80 / 443    |

---

## Option A – Native Installation

### 1. Install .NET SDK

**Linux (Ubuntu/Debian)**
\`\`\`bash
# Add Microsoft package repository
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0
dotnet --version
\`\`\`

**macOS**
\`\`\`bash
brew install dotnet
dotnet --version
\`\`\`

**Windows**  
Download and run the installer from https://dotnet.microsoft.com/download

---

### 2. Install Node.js & npm

Use **nvm** (Node Version Manager) – works on Linux, macOS, and WSL on Windows:

\`\`\`bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc          # or ~/.zshrc

nvm install --lts
nvm use --lts
node -v && npm -v
\`\`\`

**Windows (without WSL)**  
Download the LTS installer from https://nodejs.org

---

### 3. Install MySQL Server

**Linux (Ubuntu/Debian)**
\`\`\`bash
sudo apt-get update
sudo apt-get install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql   # start on boot

# Secure the installation (set root password, remove anonymous users, etc.)
sudo mysql_secure_installation
\`\`\`

**macOS**
\`\`\`bash
brew install mysql
brew services start mysql
mysql_secure_installation
\`\`\`

**Windows**  
Download MySQL Installer from https://dev.mysql.com/downloads/installer/ and follow the wizard.

After installation, create a database and user:
\`\`\`sql
-- Connect as root
mysql -u root -p

CREATE DATABASE devdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'devuser'@'localhost' IDENTIFIED BY 'devpassword';
GRANT ALL PRIVILEGES ON devdb.* TO 'devuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
\`\`\`

---

### 4. Create a .NET Web API Project

\`\`\`bash
# Create the project
dotnet new webapi -n MyApi --framework net8.0
cd MyApi

# Add Entity Framework Core + MySQL provider
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Pomelo.EntityFrameworkCore.MySql
dotnet add package Microsoft.EntityFrameworkCore.Design

# Trust the HTTPS development certificate
dotnet dev-certs https --trust

# Run the API (default: http://localhost:5000, https://localhost:5001)
dotnet run
\`\`\`

Update \`appsettings.Development.json\` with your connection string:
\`\`\`json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Port=3306;Database=devdb;User=devuser;Password=devpassword;"
  }
}
\`\`\`

---

### 5. Create a Vue 3 Project

\`\`\`bash
# Scaffold with Vite (recommended)
npm create vite@latest my-app -- --template vue
cd my-app
npm install

# Development server (http://localhost:5173)
npm run dev

# Production build
npm run build
\`\`\`

Configure the Vite dev server to proxy API calls in \`vite.config.js\`:
\`\`\`js
export default {
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      },
    },
  },
}
\`\`\`

---

### 6. Connect .NET API to MySQL

Register the DB context in \`Program.cs\`:
\`\`\`csharp
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));
\`\`\`

Run migrations:
\`\`\`bash
dotnet ef migrations add InitialCreate
dotnet ef database update
\`\`\`

---

### 7. Set Up a Reverse Proxy with Nginx

Install Nginx and use the provided configuration template:

\`\`\`bash
# Linux
sudo apt-get install -y nginx

# macOS
brew install nginx
\`\`\`

Copy \`nginx/dev-server.conf\` (included in this repo) to your Nginx config directory and reload:

\`\`\`bash
# Linux
sudo cp nginx/dev-server.conf /etc/nginx/sites-available/dev-server
sudo ln -s /etc/nginx/sites-available/dev-server /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# macOS
cp nginx/dev-server.conf /usr/local/etc/nginx/servers/dev-server.conf
nginx -t && brew services reload nginx
\`\`\`

---

## Option B – Docker (Recommended for Dev)

Docker Compose spins up all three services with one command and avoids installing MySQL/Nginx locally.

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows / macOS)  
- Docker Engine + Docker Compose plugin (Linux):

\`\`\`bash
sudo apt-get install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER   # allow running docker without sudo (re-login required)
\`\`\`

### Start All Services

\`\`\`bash
# Copy the example environment file
cp .env.example .env
# Edit .env with your preferred passwords / settings

docker compose up --build
\`\`\`

| Service    | URL                        |
|------------|----------------------------|
| Vue 3 App  | http://localhost:5173      |
| .NET API   | http://localhost:5000      |
| MySQL      | localhost:3306             |
| Nginx      | http://localhost:80        |

### Stop All Services

\`\`\`bash
docker compose down          # keep database volume
docker compose down -v       # also delete database volume
\`\`\`

---

## Environment Variables

Copy \`.env.example\` to \`.env\` and fill in the values before running Docker Compose or your local apps.

| Variable              | Description                      | Default        |
|-----------------------|----------------------------------|----------------|
| \`MYSQL_ROOT_PASSWORD\` | MySQL root password              | \`rootpassword\` |
| \`MYSQL_DATABASE\`      | Database name                    | \`devdb\`        |
| \`MYSQL_USER\`          | Application DB user              | \`devuser\`      |
| \`MYSQL_PASSWORD\`      | Application DB user password     | \`devpassword\`  |
| \`ASPNETCORE_URLS\`     | URLs the .NET API listens on     | \`http://+:5000\`|
| \`VITE_API_BASE_URL\`   | Base URL for API calls in Vue    | \`http://localhost:5000\` |

---

## Useful Commands

\`\`\`bash
# .NET
dotnet run                         # start API
dotnet watch run                   # hot-reload during development
dotnet ef migrations add <Name>    # create a new EF migration
dotnet ef database update          # apply pending migrations

# Vue 3
npm run dev                        # start Vite dev server
npm run build                      # production build
npm run preview                    # preview production build locally

# MySQL CLI
mysql -u devuser -p devdb          # connect to the dev database
mysqldump -u devuser -p devdb > backup.sql  # export database

# Docker
docker compose up --build          # build and start all services
docker compose logs -f api         # tail .NET API logs
docker compose logs -f db          # tail MySQL logs
docker compose exec db mysql -u devuser -p devdb  # open MySQL shell inside container
\`\`\`
