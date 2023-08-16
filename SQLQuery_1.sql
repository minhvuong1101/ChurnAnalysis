-- Finding the total number of customers
SELECT DISTINCT COUNT(CustomerID) as TotalNumberOfCustomers
FROM ecommercechurn

-- Checking for duplicate rows
SELECT CustomerID, COUNT (CustomerID) as Count
FROM ecommercechurn
GROUP BY CustomerID
Having COUNT (CustomerID) > 1

-- Checking for null values
SELECT
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS Count_CustomerID,
    SUM(CASE WHEN Churn IS NULL THEN 1 ELSE 0 END) AS Count_Churn,
    SUM(CASE WHEN Tenure IS NULL THEN 1 ELSE 0 END) AS Count_Tenure,
    SUM(CASE WHEN PreferredLoginDevice IS NULL THEN 1 ELSE 0 END) AS Count_PreferredLoginDevice,
    SUM(CASE WHEN CityTier IS NULL THEN 1 ELSE 0 END) AS Count_CityTier,
    SUM(CASE WHEN WarehouseToHome IS NULL THEN 1 ELSE 0 END) AS Count_WarehouseToHome,
    SUM(CASE WHEN PreferredPaymentMode IS NULL THEN 1 ELSE 0 END) AS Count_PreferredPaymentMode,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS Count_Gender,
    SUM(CASE WHEN HourSpendOnApp IS NULL THEN 1 ELSE 0 END) AS Count_HourSpendOnApp,
    SUM(CASE WHEN NumberOfDeviceRegistered IS NULL THEN 1 ELSE 0 END) AS Count_NumberOfDeviceRegistered,
    SUM(CASE WHEN PreferedOrderCat IS NULL THEN 1 ELSE 0 END) AS Count_PreferedOrderCat,
    SUM(CASE WHEN SatisfactionScore IS NULL THEN 1 ELSE 0 END) AS Count_SatisfactionScore,
    SUM(CASE WHEN MaritalStatus IS NULL THEN 1 ELSE 0 END) AS Count_MaritalStatus,
    SUM(CASE WHEN NumberOfAddress IS NULL THEN 1 ELSE 0 END) AS Count_NumberOfAddress,
    SUM(CASE WHEN Complain IS NULL THEN 1 ELSE 0 END) AS Count_Complain,
    SUM(CASE WHEN OrderAmountHikeFromlastYear IS NULL THEN 1 ELSE 0 END) AS Count_OrderAmountHikeFromlastYear,
    SUM(CASE WHEN CouponUsed IS NULL THEN 1 ELSE 0 END) AS Count_CouponUsed,
    SUM(CASE WHEN OrderCount IS NULL THEN 1 ELSE 0 END) AS Count_OrderCount,
    SUM(CASE WHEN DaySinceLastOrder IS NULL THEN 1 ELSE 0 END) AS Count_DaySinceLastOrder,
    SUM(CASE WHEN CashbackAmount IS NULL THEN 1 ELSE 0 END) AS Count_CashbackAmount
FROM ecommercechurn;

-- Handling null values
UPDATE ecommercechurn
SET HourSpendOnApp = (SELECT AVG(HourSpendOnApp) FROM ecommercechurn)
WHERE HourSpendOnApp IS NULL 

UPDATE ecommercechurn
SET Tenure = (SELECT AVG(Tenure) FROM ecommercechurn)
WHERE Tenure IS NULL 

UPDATE ecommercechurn
SET OrderAmountHikeFromlastYear = (SELECT AVG(OrderAmountHikeFromlastYear) FROM ecommercechurn)
WHERE OrderAmountHikeFromlastYear IS NULL 

UPDATE ecommercechurn
SET WarehouseToHome = (SELECT  AVG(WarehouseToHome) FROM ecommercechurn)
WHERE WarehouseToHome IS NULL 

UPDATE ecommercechurn
SET CouponUsed = (SELECT AVG(CouponUsed) FROM ecommercechurn)
WHERE CouponUsed IS NULL 

UPDATE ecommercechurn
SET OrderCount = (SELECT AVG(OrderCount) FROM ecommercechurn)
WHERE OrderCount IS NULL 

UPDATE ecommercechurn
SET DaySinceLastOrder = (SELECT AVG(DaySinceLastOrder) FROM ecommercechurn)
WHERE DaySinceLastOrder IS NULL 

-- Creating a new column from an already existing “churn” column
ALTER TABLE ecommercechurn
ADD CustomerStatus NVARCHAR(50)

UPDATE ecommercechurn
SET CustomerStatus = 
CASE 
    WHEN Churn = 1 THEN 'Churned' 
    WHEN Churn = 0 THEN 'Stayed'
END 

-- Creating a new column from an already existing “complain” column
ALTER TABLE ecommercechurn
ADD ComplainRecieved NVARCHAR(10)

UPDATE ecommercechurn
SET ComplainRecieved =  
CASE 
    WHEN complain = 1 THEN 'Yes'
    WHEN complain = 0 THEN 'No'
END

-- Checking values in each column for correctness and accuracy
-- Fixing redundancy in “PreferedLoginDevice” Column
UPDATE ecommercechurn
SET PreferredLoginDevice = 'Phone'
WHERE PreferredLoginDevice = 'Mobile Phone'

-- Fixing redundancy in “PreferedOrderCat” Column
UPDATE ecommercechurn
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile'

-- Fixing redundancy in “PreferredPaymentMode” Column
UPDATE ecommercechurn
SET PreferredPaymentMode  = 'Cash on Delivery'
WHERE PreferredPaymentMode  = 'COD'

-- Fixing wrongly entered values in “WarehouseToHome” column
UPDATE ecommercechurn
SET warehousetohome = '27'
WHERE warehousetohome = '127'

UPDATE ecommercechurn
SET warehousetohome = '26'
WHERE warehousetohome = '126'

-- EDA
-- What is the overall customer churn rate?
SELECT 
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN CustomerStatus = 'churned' THEN 1 ELSE 0 END) AS ChurnedCustomers,
    CAST(SUM(CASE WHEN CustomerStatus = 'churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate
FROM 
    ecommercechurn;

-- How does the churn rate vary based on the preferred login device?
SELECT 
    preferredlogindevice, 
    COUNT(*) AS TotalCustomers,
    SUM(churn) AS ChurnedCustomers,
    CAST(SUM (churn) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM 
    ecommercechurn
GROUP BY preferredlogindevice

-- What is the distribution of customers across different city tiers?
SELECT citytier, 
       COUNT(*) AS TotalCustomer, 
       SUM(Churn) AS ChurnedCustomers, 
       CAST(SUM (churn) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY citytier
ORDER BY churnrate DESC

-- Is there any correlation between the warehouse-to-home distance and customer churn?
ALTER TABLE ecommercechurn
ADD warehousetohomerange NVARCHAR(50)

UPDATE ecommercechurn
SET warehousetohomerange =
CASE 
    WHEN warehousetohome <= 10 THEN 'Very close distance'
    WHEN warehousetohome > 10 AND warehousetohome <= 20 THEN 'Close distance'
    WHEN warehousetohome > 20 AND warehousetohome <= 30 THEN 'Moderate distance'
    WHEN warehousetohome > 30 THEN 'Far distance'
END

SELECT warehousetohomerange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY warehousetohomerange
ORDER BY Churnrate DESC

-- Which is the most preferred payment mode among churned customers?
SELECT preferredpaymentmode,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY preferredpaymentmode
ORDER BY Churnrate DESC

-- What is the typical tenure for churned customers?
ALTER TABLE ecommercechurn
ADD TenureRange NVARCHAR(50)

UPDATE ecommercechurn
SET TenureRange =
CASE 
    WHEN tenure <= 6 THEN '6 Months'
    WHEN tenure > 6 AND tenure <= 12 THEN '1 Year'
    WHEN tenure > 12 AND tenure <= 24 THEN '2 Years'
    WHEN tenure > 24 THEN 'more than 2 years'
END

SELECT TenureRange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY TenureRange
ORDER BY Churnrate DESC

-- Is there any difference in churn rate between male and female customers?
SELECT gender,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY gender
ORDER BY Churnrate DESC

-- How does the average time spent on the app differ for churned and non-churned customers?
SELECT customerstatus, avg(HourSpendOnApp) AS AverageHourSpentonApp
FROM ecommercechurn
GROUP BY customerstatus

-- Does the number of registered devices impact the likelihood of churn?
SELECT NumberofDeviceRegistered,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY NumberofDeviceRegistered
ORDER BY Churnrate DESC

-- Which order category is most preferred among churned customers?
SELECT preferedordercat,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY preferedordercat
ORDER BY Churnrate DESC

-- Is there any relationship between customer satisfaction scores and churn?
SELECT satisfactionscore,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY satisfactionscore
ORDER BY Churnrate DESC

-- Does the marital status of customers influence churn behavior?
SELECT maritalstatus,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY maritalstatus
ORDER BY Churnrate DESC

-- Do customer complaints influence churned behavior?
SELECT complainrecieved,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY complainrecieved
ORDER BY Churnrate DESC

-- How does the use of coupons differ between churned and non-churned customers?
SELECT customerstatus, SUM(CouponUsed) AS SumofCouponUsed
FROM ecommercechurn
GROUP BY customerstatus

-- What is the average number of days since the last order for churned customers?
SELECT AVG(daysincelastorder) AS AverageNumofDaysSinceLastOrder
FROM ecommercechurn
WHERE customerstatus = 'churned'

-- Is there any correlation between cashback amount and churn rate?
ALTER TABLE ecommercechurn
ADD cashbackamountrange NVARCHAR(50)

UPDATE ecommercechurn
SET cashbackamountrange =
CASE 
    WHEN cashbackamount <= 100 THEN 'Low Cashback Amount'
    WHEN cashbackamount > 100 AND cashbackamount <= 200 THEN 'Moderate Cashback Amount'
    WHEN cashbackamount > 200 AND cashbackamount <= 300 THEN 'High Cashback Amount'
    WHEN cashbackamount > 300 THEN 'Very High Cashback Amount'
END

SELECT cashbackamountrange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY cashbackamountrange
ORDER BY Churnrate DESC



