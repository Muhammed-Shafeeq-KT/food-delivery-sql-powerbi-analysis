# Food Delivery Analytics Using SQL and Power BI

## Overview

This project analyzes food delivery data to generate business insights on revenue distribution, delivery performance, and customer behavior.

The workflow covers end-to-end analytics:

* Data ingestion and validation
* Data cleaning and transformation
* SQL-based analysis
* Power BI dashboard for visualization

---

## Dataset

The dataset consists of three tables:

* Orders (transaction-level data)
* Customers
* Restaurants

It includes over 1200 orders across 10 cities, 50 restaurants, and 100 customers.

---

## Data Preparation

* Removed missing and invalid order records
* Fixed delivery time inconsistencies
* Standardized city names
* Verified relationships between tables
* Converted `order_amount` from VARCHAR to DECIMAL for accurate analysis

---

## Key Insights

* Revenue is concentrated in a few cities, with Chennai, Hyderabad, and Jaipur leading performance
* Significant delivery delays (140+ minutes) highlight operational inefficiencies in certain cities
* A small group of restaurants and customers contributes a large share of total revenue
* Customer ratings do not consistently correlate with revenue, indicating other influencing factors
* Peak order demand occurs during afternoon and evening hours

---

## Dashboard

A Power BI dashboard was built by connecting directly to MySQL using ODBC.

It includes:

* KPI tracking (Revenue, Orders, AOV, Delivery Time)
* Revenue by city and monthly trends
* Peak order hours
* Top customers and restaurants
* Delivery performance metrics

---

## Data Model

A relational schema was designed with Orders linked to Customers and Restaurants using primary and foreign keys, ensuring data integrity and accurate joins.

---

## Tools Used

* MySQL
* Power BI

---

## Skills Demonstrated

* SQL (joins, aggregations, window functions)
* Data cleaning and validation
* Data modeling
* Dashboard development
* Business insight generation
