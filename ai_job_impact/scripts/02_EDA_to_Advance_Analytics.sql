
--=================================================
--=================BASIC EDA=======================
--=================================================

-- Sample rows
SELECT * 
FROM silver.ai_job_impact 
LIMIT 5;

-- Row counts & basic sanity checks
SELECT COUNT(*) AS total_rows,
       COUNT(job_title) AS total_job_titles,
       COUNT(industry) AS total_industries
FROM silver.ai_job_impact;

-- Unique industries & job status categories
SELECT DISTINCT industry FROM silver.ai_job_impact;
SELECT DISTINCT job_status FROM silver.ai_job_impact;

-- Salary distribution
SELECT MIN(median_salary_usd) AS min_salary,
       MAX(median_salary_usd) AS max_salary,
       AVG(median_salary_usd) AS avg_salary
FROM silver.ai_job_impact;


--=================================================
--================Descriptive Trends===============
--=================================================

-- Jobs by status
SELECT job_status, COUNT(*) AS job_count
FROM silver.ai_job_impact
GROUP BY job_status;

-- Top 10 highest paying jobs
SELECT job_title, industry, median_salary_usd
FROM silver.ai_job_impact
ORDER BY median_salary_usd DESC
LIMIT 10;

-- Avg salary & experience overall
SELECT ROUND(AVG(median_salary_usd)) AS avg_salary,
       ROUND(AVG(experience_years)) AS avg_experience
FROM silver.ai_job_impact;


--=================================================
--================Business Questions===============
--=================================================

-- Which industries will gain/lose the most jobs by 2030?
SELECT industry,
       SUM(job_openings_2024) AS openings_2024,
       SUM(projected_openings_2030) AS openings_2030,
       (SUM(projected_openings_2030) - SUM(job_openings_2024)) AS growth
FROM silver.ai_job_impact
GROUP BY industry
ORDER BY growth DESC;

--Are high-paying jobs safer from automation?
SELECT industry, 
       ROUND(AVG(median_salary_usd)) AS avg_salary, 
       ROUND(AVG(automation_risk)) AS avg_automation_risk
FROM silver.ai_job_impact
GROUP BY industry
ORDER BY avg_automation_risk DESC;

-- Which education levels are most impacted by AI?
SELECT required_education, 
       COUNT(*) FILTER (WHERE job_status = 'Increasing') AS increasing_job,
       COUNT(*) FILTER (WHERE job_status = 'Decreasing') AS decreasing_job
FROM silver.ai_job_impact
GROUP BY required_education
ORDER BY decreasing_job DESC;

-- What’s the relationship between gender diversity and remote work?
SELECT industry, 
       ROUND(AVG(gender_ratio), 2) AS avg_gender_diversity,
       ROUND(AVG(remote_work_ratio), 2) AS avg_remote_ratio
FROM silver.ai_job_impact
GROUP BY industry
ORDER BY avg_gender_diversity DESC;


-- Where do salaries, gender diversity, 
--and AI risk stand relative to the overall job market distribution?
SELECT 
    job_title,
    industry,
    median_salary_usd,
    gender_ratio ,
    automation_risk,
    NTILE(4) OVER (ORDER BY median_salary_usd) AS salary_quartile,
    NTILE(4) OVER (ORDER BY gender_ratio) AS gender_diversity_quartile,
    NTILE(4) OVER (ORDER BY automation_risk) AS ai_risk_quartile
FROM silver.ai_job_impact;

-- How do jobs within the same industry differ in terms of pay and AI risk exposure?
SELECT 
    j1.industry,
    j1.job_title AS job1,
    j2.job_title AS job2,
    j1.median_salary_usd - j2.median_salary_usd AS salary_gap,
    j1.automation_risk  - j2.automation_risk AS risk_gap
FROM silver.ai_job_impact j1
JOIN silver.ai_job_impact j2
    ON j1.industry = j2.industry
   AND j1.job_title < j2.job_title  -- avoid duplicate pairs & self-pairs
WHERE ABS(j1.median_salary_usd - j2.median_salary_usd) > 10000
   OR ABS(j1.automation_risk - j2.automation_risk) >= 2
ORDER BY j1.industry, salary_gap DESC;

--=================================================
--================Advanced Analytics===============
--=================================================

-- Future-proof jobs (high pay, low risk, increasing)
SELECT job_title, industry, median_salary_usd, automation_risk
FROM silver.ai_job_impact
WHERE job_status = 'Increasing'
  AND automation_risk < 30
  AND median_salary_usd > 70000
ORDER BY median_salary_usd DESC;

-- Rank jobs by automation risk & salary
SELECT job_title, industry, automation_risk,
       RANK() OVER (PARTITION BY industry ORDER BY automation_risk DESC) AS risk_rank
FROM silver.ai_job_impact
ORDER BY risk_rank;

-- Salary rank within industry
SELECT job_title, industry, median_salary_usd,
       RANK() OVER (PARTITION BY industry ORDER BY median_salary_usd DESC) AS salary_rank
FROM silver.ai_job_impact
WHERE job_status = 'Increasing'
ORDER BY industry, salary_rank;

-- YOY Growth %
SELECT industry,
       ROUND(100.0 * (SUM(projected_openings_2030) - SUM(job_openings_2024)) / 
             SUM(job_openings_2024), 2) AS pct_growth
FROM silver.ai_job_impact
GROUP BY industry
ORDER BY pct_growth DESC;

-- Correlation: Salary vs Automation Risk
SELECT corr(median_salary_usd, automation_risk) AS salary_automation_corr
FROM silver.ai_job_impact;


--=================================================
--================Deeper Analysis==================
--=================================================

-- Jobs that exist in multiple industries
SELECT job_title, COUNT(DISTINCT industry) AS industry_count
FROM silver.ai_job_impact
GROUP BY job_title
HAVING COUNT(DISTINCT industry) > 1
ORDER BY industry_count DESC;


-- Jobs that exist in multiple countries
SELECT job_title, COUNT(DISTINCT location) AS country_count
FROM silver.ai_job_impact
GROUP BY job_title
HAVING COUNT(DISTINCT location) > 1
ORDER BY country_count DESC;

-- “Chameleon Jobs” → appear in multiple industries AND countries
WITH industry_cte AS (
    SELECT job_title, COUNT(DISTINCT industry) AS industry_count
    FROM silver.ai_job_impact
    GROUP BY job_title
),
country_cte AS (
    SELECT job_title, COUNT(DISTINCT location) AS country_count
    FROM silver.ai_job_impact
    GROUP BY job_title
)
SELECT i.job_title, i.industry_count, c.country_count
FROM industry_cte i
JOIN country_cte c ON i.job_title = c.job_title
WHERE i.industry_count > 1 AND c.country_count > 1
ORDER BY industry_count DESC, country_count DESC;


-- Spotting “odd” job–industry combos
SELECT job_title, industry, COUNT(*) AS records
FROM silver.ai_job_impact
GROUP BY job_title, industry
HAVING COUNT(*) > 1
ORDER BY job_title, records DESC;



