-- Initial database setup
-- This script runs automatically when the MySQL container first starts.

-- Ensure the database exists and uses a sensible character set
CREATE DATABASE IF NOT EXISTS devdb
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE devdb;

-- Example table – remove or replace with your own schema
CREATE TABLE IF NOT EXISTS items (
    id         INT          NOT NULL AUTO_INCREMENT,
    name       VARCHAR(255) NOT NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
