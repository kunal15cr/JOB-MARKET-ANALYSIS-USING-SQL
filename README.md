Certainly! Here's a sample `README.md` file for your GitHub repository, which explains the different SQL queries used for job market analysis:

---

# Breadcrumbs Job Market Analysis Using SQL

Welcome to the Breadcrumbs Job Market Analysis repository! This project contains SQL queries and analyses designed to provide insights into job market trends, focusing on compensation, remote work, and company metrics across various countries and experience levels. Below, you'll find detailed explanations of each query used in this analysis.

## Table of Contents

1. [Introduction](#introduction)
2. [Queries and Analysis](#queries-and-analysis)
   - [1. Identifying Fully Remote Manager Positions with High Salaries](#1-identifying-fully-remote-manager-positions-with-high-salaries)
   - [2. Top 5 Countries with the Largest Number of Large Companies](#2-top-5-countries-with-the-largest-number-of-large-companies)
   - [3. Percentage of High-Paying Remote Jobs](#3-percentage-of-high-paying-remote-jobs)
   - [4. Locations with Higher Average Entry-Level Salaries](#4-locations-with-higher-average-entry-level-salaries)
   - [5. Countries Paying the Maximum Average Salary for Each Job Title](#5-countries-paying-the-maximum-average-salary-for-each-job-title)
   - [6. Locations with Consistently Increasing Salaries](#6-locations-with-consistently-increasing-salaries)
   - [7. Remote Work Adoption Comparison between 2021 and 2024](#7-remote-work-adoption-comparison-between-2021-and-2024)
3. [Conclusion](#conclusion)

## Introduction

This repository is dedicated to analyzing job market data using SQL queries to uncover trends related to salaries, remote work, and company sizes across various locations and experience levels. The data is used to guide job seekers and employers in making informed decisions about employment and compensation.

## Queries and Analysis

### 1. Identifying Fully Remote Manager Positions with High Salaries

```sql
SELECT * FROM job_salary.salaries  
WHERE job_title LIKE '%Manager%' AND remote_ratio = 100 
AND salary_in_usd > 90000;
```

**Objective:** Find countries where manager positions are fully remote and pay more than $90,000 USD.

### 2. Top 5 Countries with the Largest Number of Large Companies

```sql
SELECT company_location, experience_level, company_size,
       COUNT(company_size) AS company_count 
FROM job_salary.salaries
GROUP BY company_location, company_size, experience_level
HAVING company_size LIKE 'L' AND experience_level LIKE 'EN'
ORDER BY company_count DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the greatest number of large companies for entry-level positions.

### 3. Percentage of High-Paying Remote Jobs

```sql
-- Calculate the count of remote employees with salaries over $100,000
SET @COUNT = (SELECT COUNT(*) FROM job_salary.salaries WHERE salary_in_usd > 100000 AND remote_ratio = 100);

-- Calculate the total count of employees with salaries over $100,000
SET @total = (SELECT COUNT(*) FROM job_salary.salaries WHERE salary_in_usd > 100000);

-- Compute the percentage
SET @percentage = ROUND((@COUNT / @total) * 100, 2);

-- Select the percentage
SELECT @percentage AS percentage_of_people_working_remotely_and_having_salary_over_100000_usd;
```

**Objective:** Calculate the percentage of employees with salaries exceeding $100,000 USD who work fully remotely.

### 4. Locations with Higher Average Entry-Level Salaries

```sql
SELECT * FROM (
    SELECT company_location, job_title, AVG(salary_in_usd) AS avg_salary_job
    FROM job_salary.salaries
    WHERE experience_level LIKE 'EN'
    GROUP BY company_location, job_title
) ent 
JOIN (
    SELECT company_location, AVG(salary_in_usd) AS avg_salary
    FROM job_salary.salaries
    WHERE experience_level LIKE 'EN'
    GROUP BY company_location
) s_avg ON ent.company_location = s_avg.company_location
WHERE avg_salary < avg_salary_job;
```

**Objective:** Identify locations where entry-level average salaries exceed the market average for that job title.

### 5. Countries Paying the Maximum Average Salary for Each Job Title

```sql
SELECT * FROM (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY job_title ORDER BY avg_salary DESC) AS ranks 
    FROM (
        SELECT company_location, job_title, AVG(salary_in_usd) AS avg_salary
        FROM job_salary.salaries
        GROUP BY company_location, job_title
        ORDER BY company_location, avg_salary DESC
    ) t
) b
WHERE ranks = 1;
```

**Objective:** Determine which country offers the highest average salary for each job title.

### 6. Locations with Consistently Increasing Salaries

```sql
WITH company_growth AS (
    SELECT *  
    FROM job_salary.salaries
    WHERE company_location IN (
        SELECT company_location 
        FROM (
            SELECT company_location, AVG(salary_in_usd) AS avg_salary, 
                   COUNT(DISTINCT work_year) AS cnt
            FROM job_salary.salaries
            WHERE work_year >= (YEAR(CURRENT_DATE()) - 2)
            GROUP BY company_location
            HAVING cnt = 3
        ) c
    )
)
SELECT company_location,
       MAX(CASE WHEN work_year = 2022 THEN avg_salary END) AS avg_of_2022,
       MAX(CASE WHEN work_year = 2023 THEN avg_salary END) AS avg_of_2023,
       MAX(CASE WHEN work_year = 2024 THEN avg_salary END) AS avg_of_2024
FROM (
    SELECT company_location, work_year, AVG(salary_in_usd) AS avg_salary 
    FROM company_growth 
    GROUP BY company_location, work_year
) t  
GROUP BY company_location
HAVING avg_of_2024 > avg_of_2023 AND avg_of_2023 > avg_of_2022;
```

**Objective:** Identify locations where the average salary has consistently increased over the past three years.

### 7. Remote Work Adoption Comparison between 2021 and 2024

```sql
SELECT * 
FROM (
    SELECT *, (remote_count / total_count) * 100 AS remote_21 
    FROM (
        SELECT t.experience_level, total_count, remote_count 
        FROM (
            SELECT experience_level, COUNT(*) AS total_count 
            FROM job_salary.salaries 
            WHERE work_year = 2021 
            GROUP BY experience_level
        ) t
        JOIN (
            SELECT experience_level, COUNT(*) AS remote_count  
            FROM job_salary.salaries 
            WHERE remote_ratio = 100 AND work_year = 2021 
            GROUP BY experience_level
        ) t2 ON t.experience_level = t2.experience_level
    ) final
) t21 
JOIN (
    SELECT *, (remote_count / total_count) * 100 AS remote_24 
    FROM (
        SELECT t.experience_level, total_count, remote_count 
        FROM (
            SELECT experience_level, COUNT(*) AS total_count 
            FROM job_salary.salaries 
            WHERE work_year = 2024 
            GROUP BY experience_level
        ) t
        JOIN (
            SELECT experience_level, COUNT(*) AS remote_count  
            FROM job_salary.salaries 
            WHERE remote_ratio = 100 AND work_year = 2024 
            GROUP BY experience_level
        ) t2 ON t.experience_level = t2.experience_level
    ) final 
) t24 ON t21.experience_level = t24.experience_level;
```

**Objective:** Compare the percentage of fully remote work for each experience level between 2021 and 2024.

## Conclusion

This repository showcases a series of SQL queries that analyze various aspects of the job market, including salary trends, remote work patterns, and company metrics. By utilizing these queries, analysts can gain valuable insights into compensation practices, remote work adoption, and company growth across different regions.

Feel free to explore the queries, modify them to fit your specific needs, and use them to enhance your understanding of the job market.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or feedback, please reach out to [your-email@example.com](mailto:kunal15cr@gmail.com).

---

This README provides a comprehensive overview of each query and its purpose, helping users understand the analysis performed and the insights gathered from the data.
