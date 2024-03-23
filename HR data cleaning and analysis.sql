-- createing a new database for our project
CREATE DATABASE Portfolio_project;

-- command to use particular database
use Portfolio_project;

-- pulling all records from table
SELECT *
FROM `portfolio_project`.`human resources`;

-- rename the table
ALTER TABLE `human resources` RENAME TO HR;

--  CHANGING COLUMN TYPE AND NAME
ALTER TABLE HR CHANGE COLUMN `new_column_name` ID VARCHAR(20) NULL;

-- CHANGING THE DATA TYPE OF BIRTHDATE COLUMN FROM STR TO DATE TYPE AND ALSO CHANGING DATE FORMAT

SELECT birthdate from HR;
UPDATE HR
set birthdate = CASE WHEN birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
	when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
    else null
 end;   
 
 select birthdate from HR;
 
 alter table HR 
 modify column birthdate date;
 
-- CHANGING DATA TYPE AND DATE FORMAT FOR COLUMN HIRE_DATE
UPDATE HR
set hire_date = CASE WHEN hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
	when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
    else null
 end;   
  select hire_date 
  from HR;
alter table HR 
 modify column hire_date date;

-- CHANGING DATA TYPE AND DATE FORMAT FOR COLUMN TERMDATE
select termdate from HR;
UPDATE HR
set termdate =  date(str_to_date(termdate,'%Y-%m-%d %H:%i:%sUTC'))
	where termdate is not null and termdate !='';
alter table HR 
 modify column termdate date;
 
 -- ADDING AGE COLUMN TO TABLE AND CALCULATING CURRENT AGE AGE OF EMPLOYEE
ALTER TABLE HR ADD COLUMN age INT;
UPDATE HR SET AGE = timestampdiff(YEAR, BIRTHDATE, CURDATE());
SELECT AGE FROM HR;

-- IDENTIFYING THE OUTLIYER 
SELECT BIRTHDATE ,AGE , HIRE_DATE , TERMDATE
 FROM HR 
WHERE AGE <= 0 ;
SELECT count(AGE)
 FROM HR 
WHERE AGE <= 0;

--  ANALYZING THE DATA AND SOLVING THE QUESTIONS 
-- 1. What is the gender breakdown of employees in the company?
SELECT GENDER , COUNT(*) FROM HR 
WHERE AGE >= 18 AND TERMDATE = 0000-00-00
GROUP BY GENDER;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race , count(*) from hr
where age >= 18 and termdate = 0000-00-00
group by race
order by race ;

-- 3. What is the age distribution of employees in the company?
select 
case when age between 18 and 25 then '18-25'
when age between 26 and 35 then '26-35'
when age between 36 and 45 then '36-45'
when age between 46 and 55 then '46-55'
else '55+' 
end as age_group,
count(*) as count
from HR
where age >= 18 and termdate = 0000-00-00
group by  age_group
order by  age_group;

-- 4. How many employees work at headquarters versus remote locations?
select location ,count(*) as count
from HR 
where age >= 18 and termdate = 0000-00-00
group by location;


select count(*) 
from HR 
where age >= 18 and termdate = 0000-00-00;
-- 5. What is the average length of employment for employees who have been terminated?
select 
round(AVG(DATEDIFF(termdate, hire_date))/365,2) AS AverageTimeSpentInYears
from hr 
where termdate <=curdate() and age >= 18 and termdate <> 0000-00-00;
;

-- 6. How does the gender distribution vary across departments and job titles?
select  department , gender , count(*) as count
from HR 
where age >= 18 and termdate = 0000-00-00
group by department , gender
order by department , gender ;

-- 7. What is the distribution of job titles across the company? (top 10)
select jobtitle, count(*)as count from HR
where age >= 18 and termdate = 0000-00-00
group by jobtitle
order by count desc
limit 10 ;

-- 8. Which department has the highest termination rate?

SELECT 
    department,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN termdate IS NOT NULL AND termdate != 0000-00-00 THEN 1 ELSE 0 END) AS TerminationCount,
    ROUND((SUM(CASE WHEN termdate IS NOT NULL AND termdate != 0000-00-00 THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS TerminationRate
FROM HR
where age >=18 
GROUP BY department
ORDER BY TerminationRate DESC 
limit 10 ;
-- 9. What is the distribution of employees across locations by city and state?
select location_state , count(*)as count from HR
where age >= 18 and termdate = 0000-00-00
group by location_state 
order by count desc 
limit 10;

select * from hr;

-- 10. How has the company's employee count changed over time based on hire and term dates?
	SELECT 
		YEAR(hire_date) AS year,
		COUNT(*) AS no_of_hires,
		SUM(CASE WHEN termdate IS NOT NULL AND termdate != '0' THEN 1 ELSE 0 END) AS no_of_terminations,
		(COUNT(*) - SUM(CASE WHEN termdate IS NOT NULL AND termdate != '0' THEN 1 ELSE 0 END)) / NULLIF(COUNT(*), 0) * 100 AS net_change_percentage
	FROM 
		hr
	WHERE 
		age >= 18
	GROUP BY 
		YEAR(hire_date)
	ORDER BY 
		year;