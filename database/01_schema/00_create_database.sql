/*
    File: database/01_schema/00_create_database.sql
    Description: Initializes the PCKAL database with the required
                 character set and collation.
    Prerequisite Parent Tables: None
*/

CREATE DATABASE IF NOT EXISTS pckal_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE pckal_db;