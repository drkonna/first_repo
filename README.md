# Dev Server Setup: .NET + Vue 3 + MySQL

A step-by-step guide to setting up your Windows PC as a local development server for hosting **.NET** back-end APIs, **Vue 3** front-end applications, and a **MySQL** database — everything installed directly on your machine.

---

## Table of Contents

1. [Overview](#overview)
2. [1. Install MySQL on Windows](#1-install-mysql-on-windows)
3. [2. Install .NET SDK](#2-install-net-sdk)
4. [3. Install Node.js & npm](#3-install-nodejs--npm)
5. [4. Create a .NET Web API Project](#4-create-a-net-web-api-project)
6. [5. Create a Vue 3 Project](#5-create-a-vue-3-project)
7. [6. Connect .NET API to MySQL](#6-connect-net-api-to-mysql)
8. [Environment Variables](#environment-variables)
9. [Useful Commands](#useful-commands)

---

## Overview

| Layer       | Technology          | Default Port |
|-------------|---------------------|-------------|
| Database    | MySQL 8             | 3306        |
| Back-end    | .NET 8 Web API      | 5000 / 5001 |
| Front-end   | Vue 3 (Vite)        | 5173        |

---

## 1. Install MySQL on Windows

1. Go to https://dev.mysql.com/downloads/installer/ and download **MySQL Installer for Windows**.
2. Run the installer and choose **Developer Default** (installs MySQL Server, MySQL Workbench, and the shell).
3. During setup, set a **root password** — remember it, you'll need it.
4. Leave the default port as **3306** and finish the wizard.
5. MySQL will be installed as a Windows service and start automatically on boot.

> **Verify the installation** — open a new Command Prompt and run:
> ```cmd
> mysql -u root -p
> ```
> Enter your root password. You should see the `mysql>` prompt.

### Create a database and user for your project

Inside the MySQL prompt:

```sql
CREATE DATABASE devdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'devuser'@'localhost' IDENTIFIED BY 'devpassword';
GRANT ALL PRIVILEGES ON devdb.* TO 'devuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

> Replace `devpassword` with a strong password of your choice.

---

## 2. Install .NET SDK

1. Go to https://dotnet.microsoft.com/download and download the **.NET 8 SDK** for Windows.
2. Run the installer.
3. Open a new Command Prompt and verify:

```cmd
dotnet --version
```

---

## 3. Install Node.js & npm

1. Go to https://nodejs.org and download the **LTS** installer for Windows.
2. Run the installer (keep all defaults).
3. Open a new Command Prompt and verify:

```cmd
node -v
npm -v
```

---

## 4. Create a .NET Web API Project

```cmd
dotnet new webapi -n MyApi --framework net8.0
cd MyApi

dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Pomelo.EntityFrameworkCore.MySql
dotnet add package Microsoft.EntityFrameworkCore.Design

dotnet dev-certs https --trust

dotnet run
```

Update `appsettings.Development.json` with your connection string:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Port=3306;Database=devdb;User=devuser;Password=devpassword;"
  }
}
```

---

## 5. Create a Vue 3 Project

```cmd
npm create vite@latest my-app -- --template vue
cd my-app
npm install
npm run dev
```

The dev server starts at **http://localhost:5173**.

To proxy API calls to your .NET backend, add this to `vite.config.js`:

```js
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
```

---

## 6. Connect .NET API to MySQL

Register the DB context in `Program.cs`:

```csharp
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));
```

Run migrations to create your tables:

```cmd
dotnet ef migrations add InitialCreate
dotnet ef database update
```

---

## Environment Variables

Copy `.env.example` to `.env` and fill in your values.

| Variable            | Description                   | Example                   |
|---------------------|-------------------------------|---------------------------|
| `DB_HOST`           | MySQL host                    | `localhost`               |
| `DB_PORT`           | MySQL port                    | `3306`                    |
| `DB_NAME`           | Database name                 | `devdb`                   |
| `DB_USER`           | Database user                 | `devuser`                 |
| `DB_PASSWORD`       | Database user password        | `devpassword`             |
| `VITE_API_BASE_URL` | Base URL for API calls in Vue | `http://localhost:5000`   |

---

## Useful Commands

```cmd
:: .NET
dotnet run                          :: start API
dotnet watch run                    :: hot-reload during development
dotnet ef migrations add <Name>     :: create a new EF migration
dotnet ef database update           :: apply pending migrations

:: Vue 3
npm run dev                         :: start Vite dev server
npm run build                       :: production build

:: MySQL (connect via Command Prompt)
mysql -u devuser -p devdb           :: open MySQL shell for your dev database
mysqldump -u devuser -p devdb > backup.sql  :: export database
```
