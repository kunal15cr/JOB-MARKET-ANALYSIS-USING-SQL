SELECT distinct(remote_ratio) FROM job_salary.salaries;

# You&#39;re a Compensation analyst employed by a multinational corporation. Your
# Assignment is to Pinpoint Countries who give work fully remotely, for the title
#39;managers’ Paying salaries Exceeding $90,000 USD

# remote_ratio Full Remote


SELECT * FROM job_salary.salaries  where job_title LIKE '%Manager%' and remote_ratio = 100 and salary_in_usd > 90000;

# AS a remote work advocate Working for a progressive HR tech startup who
# place their freshers’ clients IN large tech firms. you're tasked WITH Identifying
# top 5 Country Having greatest count of large (company size) number of
# companies.
SELECT  company_location,experience_level, company_size  , count(company_size) as company_count FROM job_salary.salaries
group by company_location , company_size, experience_level
Having company_size LIKE 'L' and experience_level LIKE "EN"
order by company_count DESC
LIMIT 5;

# Picture yourself AS a data scientist Working for a workforce management
# platform. Your objective is to calculate the percentage of employees. Who
# enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding
# light ON the attractiveness of high-paying remote positions IN today"s job
# market.


-- Calculate the count of remote employees with salaries over $100,000
SET @COUNT = (SELECT COUNT(*) FROM job_salary.salaries WHERE salary_in_usd > 100000 AND remote_ratio = 100);

-- Calculate the total count of employees with salaries over $100,000
SET @total = (SELECT COUNT(*) FROM job_salary.salaries WHERE salary_in_usd > 100000);

-- Compute the percentage
SET @percentage = ROUND((@COUNT / @total) * 100, 2);

-- Select the percentage
SELECT @percentage AS percentage_of_people_working_remotely_and_having_salary_over_100000_usd;


/*4.	Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations where entry-level average salaries exceed the 
average salary for that job title in market for entry level, helping your agency guide candidates towards lucrative countries.*/

select * from (
SELECT company_location ,job_title, avg(salary_in_usd) as avg_salary_job
FROM job_salary.salaries
WHERE experience_level LIKE "EN"
GROUP BY company_location , job_title) ent Join 

(SELECT company_location , avg(salary_in_usd) as avg_salary
FROM job_salary.salaries
WHERE experience_level LIKE "EN"
GROUP BY company_location ) s_avg on ent.company_location = s_avg.company_location
WHERE avg_salary < avg_salary_job;


/*5. You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. Your job is to Find out for each job title which
Country pays the maximum average salary. This helps you to place your candidates IN those countries.*/


SELECT * FROM (
select *, DENSE_RANK() OVER(partition by job_title order by avg_salary DESC) as ranks from (select company_location,job_title,avg(salary_in_usd)  as avg_salary
from job_salary.salaries
group by company_location,job_title
order by company_location, avg_salary DESC)t)b
where ranks = 1;


/*6.  AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations.
 Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data is available for 3 years Only(this and pst two years) 
 providing Insights into Locations experiencing Sustained salary growth.*/


with comany_groth as(
SELECT *  FROM job_salary.salaries
where company_location in (SELECT company_location from (SELECT company_location , avg(salary_in_usd) as avg_salary , count(distinct work_year) as cnt
FROM job_salary.salaries
where work_year >= (year(current_date())-2)
group by company_location having cnt = 3)c))
 
 
 select company_location,
MAX( CASE WHEN work_year = 2022 then avrage_salary END) as avg_of_2022,
MAX( CASE WHEN work_year = 2023 then avrage_salary END) as avg_of_2023,
MAX( CASE WHEN work_year = 2024 then avrage_salary END) as avg_of_2024
 from (
select company_location, work_year, avg(salary_in_usd) as avrage_salary 
FROM comany_groth group by  company_location, work_year)t  
group by  company_location
having avg_of_2024 > avg_of_2023 and avg_of_2023 > avg_of_2022 ;

/* 7.	Picture yourself AS a workforce strategist employed by a global HR tech startup. Your missiON is to determINe the percentage of  fully remote work for each 
 experience level IN 2021 and compare it WITH the correspONdINg figures for 2024, highlightINg any significant INcreASes or decreASes IN remote work adoptiON
 over the years.*/
 select * 
from job_salary.salaries;

select * from (
select * , (remote_count/total_count) * 100 as remote_21 from (
select t.experience_level, total_count, remote_count from (

Select experience_level,count(*) as total_count from job_salary.salaries where work_year = 2021 group by experience_level

)t
join (

Select experience_level,count(*) as remote_count  from job_salary.salaries where remote_ratio = 100 and work_year = 2021 group by experience_level

)t2
ON t.experience_level = t2.experience_level)final
)t21 join (

select * , (remote_count/total_count) * 100 as remote_24 from (
select t.experience_level, total_count, remote_count from (

Select experience_level,count(*) as total_count from job_salary.salaries where work_year = 2024 group by experience_level

)t
join (

Select experience_level,count(*) as remote_count  from job_salary.salaries where remote_ratio = 100 and work_year = 2024 group by experience_level

)t2 ON t.experience_level = t2.experience_level)final )t24
on t21.experience_level = t24.experience_level;

