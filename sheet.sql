SELECT * FROM job_salary.salaries;

-- You're a Compensation analyst employed by a multinational corporation. 
-- Your Assignment is to Pinpoint Countries who give work fully remotely, for the title 
-- 'managers’ Paying salaries Exceeding $90,000 USD

select distinct company_location from job_salary.salaries where job_title LIKE "%manager%" AND remote_ratio LIKE "100" AND salary_in_usd > 90000;

select distinct(job_title) from job_salary.salaries;




/* AS a remote work advocate Working for a progressive HR tech startup who place their freshers’
 clients IN large tech firms.
 you're tasked WITH Identifying top 5 Country Having greatest count of large (company size) number of companies. */


SELECT * FROM job_salary.salaries;

SELECT company_location , count(company_size) as company_counts FROM job_salary.salaries 
where experience_level LIKE "EN" AND company_size LIKE "L" 
GROUP BY company_location 
order by company_counts DESC
LIMIT 5;

select  company_location , count(company_size) as company_counts  from (select * from job_salary.salaries 
where experience_level LIKE "EN" AND company_size LIKE "L")t 
GROUP BY  company_location ORDER BY company_counts;

/*Picture yourself AS a data scientist Working for a workforce management platform.
 Your objective is to calculate the percentage of employees.
 Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, 
 Shedding light ON the attractiveness of high-paying remote positions IN today's job market.
*/

set @total = (SELECT count(*) FROM job_salary.salaries where salary_in_usd > 100000);
set @Count = (SELECT count(*) FROM job_salary.salaries where salary_in_usd > 100000 and  remote_ratio LIKE "100" );
set @percentage = round(((select @Count)/(select @total)) * 100,2);

select  @percentage ;

/*Imagine you're a data analyst Working for a global recruitment agency.
 Your Task is to identify the Locations where entry-level average salaries exceed the average salary 
 for that job title IN market for entry level,
 helping your agency guide candidates towards lucrative opportunities.
*/
SELECT * FROM job_salary.salaries;

SELECT * FROM 
(
SELECT job_title , round(avg(salary_in_usd),2) as "avg" FROM job_salary.salaries 
GROUP BY job_title
)t1
inner join
(
SELECT company_location ,job_title, avg(salary_in_usd) as "EN_avg" FROM job_salary.salaries 
WHERE experience_level LIKE "EN" 
GROUP BY company_location,job_title
)t2 
ON t1.job_title = t2.job_title where EN_avg > avg ;

/*You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. 
Your job is to Find out for each job title which. Country pays the maximum average salary.
 This helps you to place your candidates IN those countries.*/

SELECT * FROM job_salary.salaries;

SELECT * FROM (
SELECT * , dense_rank() over (partition by job_title order by avg_salary ) as ranks FROM (
SELECT company_location , job_title , avg(salary_in_usd) as avg_salary FROM job_salary.salaries 
GROUP BY 1,2 order by 1,2)t )s where ranks = 1;


/*AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary
trends across different company Locations.
 Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years 
 (Countries WHERE data is available for 3 years Only(present year and past two years) providing Insights into
 Locations experiencing Sustained salary growth.*/
 
 
 SELECT * FROM job_salary.salaries;
 


with kunal as (SELECT * FROM  job_salary.salaries WHERE company_location IN (SELECT company_location FROM (
SELECT company_location , avg(salary_in_usd) as "avg_salary",count(distinct(work_year)) as "cnt" FROM job_salary.salaries
WHERE work_year >= (Year(current_date())- 2) GROUP BY company_location HAVING  cnt = 3)t)) 

SELECT company_location, 
MAX(CASE WHEN work_year = 2022 THEN avg_salary END) as avg_salary_2022,
MAX(CASE WHEN work_year = 2023 THEN avg_salary END) as avg_salary_2023,
MAX(CASE WHEN work_year = 2024 THEN avg_salary END) as avg_salary_2024 
FROM (SELECT company_location, work_year,  avg(salary_in_usd) as avg_salary  FROM kunal group by company_location, work_year ) q  group by company_location 
having avg_salary_2022> avg_salary_2023 and avg_salary_2023>avg_salary_2024;salaries



