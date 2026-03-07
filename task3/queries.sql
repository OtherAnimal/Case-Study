/* Transformation code */

/* ===== BLOCK: Block 1 ===== */

/* ===== CODE: Remove duplicates ===== */

-- Remove duplicates
CREATE OR REPLACE TABLE csv_deduplicated AS
SELECT DISTINCT *
FROM csv_input;

/* ===== BLOCK: Block 2 ===== */

/* ===== CODE: Check nulls ===== */

-- Null values handling for the critical columns
CREATE OR REPLACE TABLE csv_nulls_handled AS
SELECT *
FROM csv_deduplicated
WHERE TransactionID IS NOT NULL
AND CustomerID IS NOT NULL
AND Email IS NOT NULL;

/* ===== BLOCK: Block 3 ===== */

/* ===== CODE: Standardize formats ===== */

-- Remove all spaces around the columns values
-- Lower email for consistency
CREATE OR REPLACE TABLE csv_standardized AS
SELECT
  TransactionID,
  TRIM(Category) AS Category,
  TRIM(Product) AS Product,
  TransactionDate,
  Quantity,
  Price,
  TotalValue,
  CustomerID,
  TRIM(PaymentMethod) AS PaymentMethod,
  TRIM(ShippingAddress) AS ShippingAddress,
  TRIM(LOWER(Email)) AS Email,
  TRIM(OrderStatus) AS OrderStatus,
  TRIM(DiscountCode) AS DiscountCode,
  PaymentAmount
FROM csv_nulls_handled;

/* ===== BLOCK: Block 4 ===== */

/* ===== CODE: Validate TotalValue calculation ===== */

-- Check TotalValue calculations while casting values to int or float
-- BigQuery’s SAFE_CAST is used to return NULL instead of throwing an error - due to the dirty data
-- CTE is used to avoid duplicated castings
CREATE OR REPLACE TABLE csv_validated AS
WITH casted AS (
  SELECT *,
    SAFE_CAST(Quantity AS INT64) AS qty,
    SAFE_CAST(Price AS FLOAT64) AS price_num,
    SAFE_CAST(TotalValue AS FLOAT64) AS total_num
  FROM csv_standardized
)
SELECT *,
  CASE
    WHEN qty IS NULL OR price_num IS NULL OR total_num IS NULL
      THEN 'INVALID_DATA'
    WHEN ABS(total_num - (qty * price_num)) > 0.01
      THEN 'MISMATCH'
    ELSE 'OK'
  END AS total_value_check
FROM casted;

/* ===== BLOCK: Block 5 ===== */

/* ===== CODE: Clean final output ===== */

-- Cast data types to the calculatable ones where still needed
-- Filter all rows with mismatched TotalValue calculations
-- Note: the filtering above is not suitable for production-level code, there should be some error report instead
-- Create a final cleaned table

CREATE OR REPLACE TABLE CSV_CLEANED AS
SELECT 
  TransactionID,
  Category,
  Product,
  SAFE.PARSE_DATE('%Y-%m-%d', TransactionDate) AS TransactionDate,
  Quantity,
  Price,
  TotalValue,
  CustomerID,
  PaymentMethod,
  ShippingAddress,
  Email,
  OrderStatus,
  DiscountCode,
  SAFE_CAST(PaymentAmount AS FLOAT64) AS PaymentAmount
FROM csv_validated
WHERE total_value_check = 'OK';

