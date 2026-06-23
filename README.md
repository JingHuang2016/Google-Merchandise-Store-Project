
Project Overview
This project analyzes Google Merchandise Store e-commerce data using BigQuery, SQL Server, and Power BI. The goal is to evaluate store performance, customer shopping behavior, funnel performance, marketing channel contribution, product performance, and customer segmentation opportunities.
The analysis uses GA4-style event, item, campaign, customer, and transaction data to prepare dashboard-ready tables for an interactive Power BI report.

Here I included all the BigQuery and SQL Server files for this analysis project.

File lists and Purpose:
Extract Event & Item Data-Big Query.sql	                         Extracts GA4 event-level and item-level data from BigQuery.
Extract Campaign Data-Big Query.sql	                             Extracts campaign and traffic source data from BigQuery.
Create Combined Table.sql	                                       Combines cleaned event, item, and campaign table data for analysis.
Simplify Event Name.sql	                                         Standardizes and simplifies GA4 event names for easier funnel and dashboard analysis.
Standardize Campaign Name.sql	                                   Cleans and groups campaign/channel names for marketing performance reporting.
Create channel_funnel table.sql	                                 Creates a session-based funnel stage table by marketing channel.
Create Funnel by Priceband Table.sql	                           Builds funnel metrics by product price band to compare purchase intent across price ranges.
Create LTV, Cohort Table, Cohort Matrix.sql	                     Creates customer lifespan, cohort, and retention analysis tables.
Create RFEM table.sql	                                           Creates segments based on recency, frequency, engagement, and monetary value.
Create Seg Name.sql	                                             Assigns customer segment names based on RFEM scores and purchase behavior.


