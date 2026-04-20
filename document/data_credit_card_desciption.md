## This dataset is a CSV file containing roughly 1.85 million simulated credit card transactions (split into 1.29M training rows and 0.55M testing rows).

It tracks the behavior of 1,000 customers across 800 merchants over a two-year period (2019-2020), capturing both normal activity and fraudulent behavior.

## The file contains 23 columns that provide complete context for each transaction:

## Transaction Basics:
- trans_date_trans_time, unix_time: When the transaction happened. (`Thời điểm giao dịch`)
- amt: The amount spent. (`số tiền đã chi`)
- trans_num: A unique transaction identifier. (`mã định danh giao dịch`)
- is_fraud: The target variable (1 for fraud, 0 for normal). 

## Cardholder Details:
- cc_num: The credit card number. 
- first, last: Customer name. 
- gender, dob: Customer demographics. 
- job: The customer's profession.

## Location Data (Helps identify geospatial anomalies):
- Customer: street, city, state, zip, lat, long, city_pop. 
- Merchant: merch_lat, merch_long.

## Merchant Info:
- merchant: Name of the business. 
- category: Type of expense (e.g., groceries, travel, online shopping, etc.). 
- Why this matters: Unlike simpler datasets that only show generic, anonymized PCA-transformed numbers (like the famous European card dataset), this file provides rich, human-readable attributes. This makes it excellent for training models that look for complex geographical and categorical patterns in fraud detection!