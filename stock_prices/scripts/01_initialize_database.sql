/*
 
 ===============================================
 Initialize Database and Tables
 ===============================================
 
Script Purpose: This script drops, and creates two tables 
Database creation is not required in PostgreSQL when using DBeaver. 
Simply connect to the desired database and execute the script.
The following line is unnecessary in PostgreSQL/DBeaver context, uncomment if using another SQL version

 */

-- CREATE DATABASE portfolio_analysis;
-- USE portfolio_analysis;


-- ===============================================
-- Table: stock_prices
-- ===============================================

DROP TABLE IF EXISTS stock_prices;

CREATE TABLE stock_prices (
    date DATE,
    ticker VARCHAR(10),
    adj_close FLOAT
);

-- ===============================================
-- Table: ticker_metadata
-- ===============================================

DROP TABLE IF EXISTS ticker_metadata;

CREATE TABLE ticker_metadata (
    ticker VARCHAR(10),
    sector VARCHAR(50),
    type CHAR(5) CHECK (type IN ('Stock', 'Index')) -- Constraint: must be either 'Stock' or 'Index'
);


-- ===============================================
-- Data Import
-- Note: Data for these tables is imported using DBeaver's "Import Data" option.
-- ===============================================

