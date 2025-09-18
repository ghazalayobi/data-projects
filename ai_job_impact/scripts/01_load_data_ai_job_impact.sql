
CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.ai_job_impact CASCADE;
CREATE TABLE silver.ai_job_impact (
    job_title               VARCHAR(100),  
    industry                VARCHAR(100)  NOT NULL,  
    job_status              VARCHAR(20)      NOT NULL,  
    ai_impact_level         VARCHAR(50)      NOT NULL,  
    median_salary_usd       FLOAT,  
    required_education      VARCHAR(50),            
    experience_years        SMALLINT, 
    job_openings_2024       INT,
    projected_openings_2030 INT,
    remote_work_ratio       NUMERIC(5,2), 
    automation_risk         NUMERIC(5,2),   
    location                VARCHAR(50) NOT NULL,    
    gender_ratio			NUMERIC(5,2)
);

TRUNCATE TABLE silver.ai_job_impact CASCADE;
COPY silver.ai_job_impact
FROM '/Users/ghazalayobi/portfolio_projects/ai_impact_job/ai_job_trends_dataset.csv'
DELIMITER ','
CSV HEADER;