CREATE OR REPLACE VIEW vw_telco_churn_clean AS
SELECT 
    customerID,
    gender,
    SeniorCitizen,
    Partner,
    Dependents,
    tenure,

    CASE 
        WHEN tenure <= 6 THEN '0-6 hó (Kritikus belépő)'
        WHEN tenure <= 12 THEN '7-12 hó (1 év alatti)'
        WHEN tenure <= 24 THEN '1-2 év (Közép)'
        ELSE '2+ év (Hűséges)'
    END AS TenureCohort,
    
    PhoneService,
    MultipleLines,
    InternetService,
    OnlineSecurity,
    OnlineBackup,
    DeviceProtection,
    TechSupport,
    StreamingTV,
    StreamingMovies,
    Contract,
    PaperlessBilling,
    PaymentMethod,
    MonthlyCharges,
    
    CASE 
        WHEN TRIM(TotalCharges) = '' OR TotalCharges IS NULL THEN 0.0
        ELSE CAST(TotalCharges AS DOUBLE)
    END AS TotalChargesClean,
    
    CASE 
        WHEN Churn = true OR Churn = 'Yes' THEN 1 
        ELSE 0 
    END AS ChurnFlag,
    
    CASE 
        WHEN Churn = true OR Churn = 'Yes' THEN 'Yes' 
        ELSE 'No' 
    END AS ChurnLabel

FROM read_csv('WA_Fn-UseC_-Telco-Customer-Churn.csv');

COPY (SELECT * FROM vw_telco_churn_clean) 
TO 'telco_churn_cleaned.csv' (HEADER, DELIMITER ',');

SELECT 
    Contract,
    COUNT(customerID) AS TotalCustomers,
    SUM(ChurnFlag) AS ChurnedCustomers,
    ROUND(SUM(ChurnFlag) * 100.0 / COUNT(customerID), 2) AS ChurnRatePct,
    ROUND(SUM(MonthlyCharges), 2) AS TotalMRR,
    ROUND(SUM(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges ELSE 0 END), 2) AS LostMRR
FROM vw_telco_churn_clean
GROUP BY Contract
ORDER BY LostMRR DESC;