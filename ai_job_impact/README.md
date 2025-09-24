# 📊 AI Impact on the Job Market (SQL + Tableau Project)

## 🔎 Project Overview
This project explores how **Artificial Intelligence (AI)** is transforming the global job market across industries and countries. Using SQL for **data exploration** and Tableau for **visual storytelling**, I investigated critical questions such as:
- Which industries will gain or lose the most jobs by 2030?  
- Are high-paying jobs safer from automation?  
- How do education, gender diversity, and remote work trends interact with AI’s impact?  
- Which jobs are **“future-proof”** (high pay, low automation risk, increasing demand)?  
- Which jobs act as **“Chameleon Jobs”** (appearing across multiple industries and countries)?  

The dataset contains **30,000 records**, covering **639 job titles** across **8 industries** and **8 countries**.

---

## 🛠️ Process & Methodology
1. **Data Source & Structure**  
   - Table: `silver.ai_job_impact`  
   - Key fields: job_title, industry, job_status, ai_impact_level, median_salary_usd, required_education, experience_years, job_openings_2024, projected_openings_2030, automation_risk, location, gender_ratio.  

2. **Exploratory Data Analysis (EDA)**  
   - Validated row counts, inspected sample rows, and checked for anomalies.  
   - Explored unique industries, job statuses, and salary distributions.  
   - Derived descriptive trends such as job growth, pay averages, and automation risks.  

3. **Business Analysis**  
   - Measured industry-level job shifts between 2024–2030.  
   - Compared education levels and their vulnerability to AI disruption.  
   - Analyzed the relationship between gender diversity and remote work.  
   - Identified outliers and unusual job–industry combinations.  

4. **Advanced Analytics**  
   - Ranked jobs by automation risk and salary.  
   - Defined “future-proof jobs” based on salary, automation risk, and demand growth.  
   - Detected “Chameleon Jobs” across industries and countries.  
   - Tested correlations (e.g., salary vs automation risk).  

5. **Visualization in Tableau**  
   - Translated SQL insights into **interactive dashboards**.  
   - Focused on one-pager storytelling to highlight the most actionable insights.  

---

## 📈 Key Results & Insights

### 1. Dataset Snapshot
- **Total Rows**: 30,000  
- **Unique Jobs**: 639  
- **Industries**: 8  
- **Countries**: 8  
- **Average Salary**: ~$90K  
- **Average Experience**: 10 years  

---

### 2. Job Market Trends
- **Jobs Increasing**: 15,136  
- **Jobs Decreasing**: 14,864  
➡ The job market is nearly balanced between growth and decline.  

**Top Growth Industries (2030):**  
- IT (+511,824 jobs)  
- Healthcare (+403,323 jobs)  
- Entertainment (+386,550 jobs)  

**Declining Industries:**  
- Education (−92,910 jobs)  
- Transportation (−444,302 jobs)  

---

### 3. Salary & Automation Risk
- Salary range: **$30K – $150K**  
- Salary vs. automation risk correlation: **~0.008 (negligible)**  
➡ High salaries do **not** guarantee immunity from automation.  

**Future-proof Jobs (example set):**  
- Development Worker (IT) – $149K, Risk: 13%  
- Marine Scientist (Retail) – $149K, Risk: <1%  
- Insurance Account Manager (Entertainment) – $149K, Risk: 2%  
- Structural Engineer (Retail) – $149K, Risk: 17%  

---

### 4. Education & AI Impact
- **Most impacted education levels (job decreases):**  
  - Master’s Degree (−3,057)  
  - Bachelor’s Degree (−3,040)  

➡ AI disrupts **both high-skill and low-skill roles**.  

---

### 5. Gender Diversity & Remote Work
- Industries with the **highest gender balance**:  
  - Transportation (50.27%)  
  - IT (50.26%)  
  - Retail (50.23%)  

- Remote work averages around **50%**, suggesting a **global hybrid model**.  

---

### 6. Chameleon Jobs
Jobs spread across **multiple industries/countries** = **flexible & resilient roles**.  

Examples:  
- Product Manager  
- Environmental Education Officer  
- Mental Health Nurse  
- Music Tutor  

---

### 7. Odd Job–Industry Combinations
- Product Manager in Healthcare (15 records)  
- Mental Health Nurse in Manufacturing (15 records)  
- Music Tutor in Education (14 records)  

---

## 📊 Tableau Dashboard
To complement SQL analysis, I designed an **interactive Tableau dashboard**:  

**Features**  
- 📈 **Industry Growth & Decline** – stacked bar charts comparing 2024 vs. 2030 job openings.  
- 💰 **Salary vs. Automation Risk Scatterplot** – visualize whether pay shields against automation.  
- 🎓 **Education Impact** – boxplots of median salary by education level.  
- 👥 **Diversity & Remote Work** – dual-axis charts for gender ratio vs. remote work.  
- 🌀 **Chameleon Jobs Tracker** – highlight transferable jobs across industries.  
- 📌 **Summary KPIs** – total jobs gained/lost, average salary, % remote roles.  

**Design Choices**  
- Built as a **one-pager dashboard** (optimized for Tableau Public).  
- Used **minimal whitespace** with **fit-to-width layout**.  
- Color-coded by **industry** for easier cross-comparison.  
- Tooltips enriched with **2030 projections** for drill-downs.  

---

## 🚀 Conclusion
AI’s impact is **multi-dimensional**:
- Balanced: growth ≈ decline in jobs.  
- Winners: IT, Healthcare, Entertainment.  
- Losers: Education, Transportation.  
- No salary safety: high-paying jobs are at risk.  
- Resilient strategies: “Future-proof” + “Chameleon Jobs” offer the best adaptability.  

The combination of **SQL analysis + Tableau dashboards** transforms raw data into a **story-driven, interactive exploration** of how AI is reshaping the workforce.  

---

## 📂 Repository Structure
