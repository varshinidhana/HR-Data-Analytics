create database projects;
use projects;
select*from hr;

#data cleaning

alter table hr
change column ï»¿id emp_id varchar(20);

desc hr;

select birthdate from hr;

set sql_safe_updates=0;

update hr
set birthdate=case
  when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
  when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
else null
end;
alter table hr 
modify column birthdate DATE;
select birthdate from hr;

update hr
set hire_date=case
  when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
  when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
else null
end;
alter table hr
modify column hire_date date;

select hire_date from hr;

select termdate from hr;

update hr
set termdate = if(termdate is not null and termdate!='',date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC')),'0000-00-00')
where true;

set sql_mode='allow_invalid_dates';

alter table hr
modify column termdate date;
desc hr;

alter table hr add  column age int;


update hr
set age= timestampdiff(YEAR,birthdate,CURDATE());

SELECT birthdate,age from hr;

select
  min(age) as youngest,
  max(age) as oldest
from hr;

select count(*) from hr where age<18;


-- what is gender break down employees in the company?
select gender,count(*) as count
from hr
where age>=18 and termdate='0000-00-00'
group by gender;

-- what is the race/ethnicity break dwon employees in the company?
select race ,count(*) as count
from hr
where age>=18 and termdate='0000-00-00'
group by race
order by count(*) desc;
-- 3. what is the age distribution of employess in the company?
select
 min(age) as youngest,
 max(age) as oldest
from hr
where age>=18 and termdate='0000-00-00';

select
 case 
   when age>=18 and age <=24 then '18-24'
   when age>=25 and age <=34 then '25-34'
   when age>=35 and age <=44 then '35-44'
   when age>=45 and age <=54 then '45-54'
   when age>=55 and age <=64 then '55-64'
   else '65+'
   end as age_group,gender,
   count(*) as count
from hr 
where age>=18 and termdate='0000-00-00'
group by age_group,gender
order by age_group,gender;

-- 4.how many employess wprk at headquaters versus remote locations?
select location ,count(*) as count from hr
where age >=18 and termdate='0000-00-00'
group by location;

-- 5.what is the average length of employment who have been terminated
select
 round(avg(datediff(termdate,hire_date))/365,0) as avg_length_employment
from hr
where termdate<= curdate() and termdate <> '0000-00-00' and age >=18;

-- 6. how does the gender distribution vary across department job titles
 select department,gender,count(*)as count
 from hr
 where age>=18 and termdate='0000-00-00'
group by department,gender
order by department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) AS count
FROM hr
WHERE age >= 18
GROUP BY jobtitle
ORDER BY jobtitle DESC;


-- 8. Which department has the highest turnover rate?
SELECT department,
       total_count,
       terminated_count,
       terminated_count / total_count AS termination_rate
FROM (SELECT department,
             COUNT(*) AS total_count,
             SUM(CASE WHEN termdate <= CURDATE() AND termdate != '0000-00-00' THEN 1 ELSE 0 END) AS terminated_count
      FROM hr
      WHERE age >= 18
      GROUP BY department) AS subquery
ORDER BY termination_rate DESC
LIMIT 1;



-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, COUNT(*) AS count
FROM hr
WHERE age >= 18
GROUP BY location_state
ORDER BY count DESC;


-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT
	year,
    hires,
    terminations,
    hires - terminations AS net_change,
    ROUND((hires - terminations)/hires*100,2) AS net_change_percent
FROM(
	SELECT
    YEAR(hire_date) AS year,
    COUNT(*) as hires,
    SUM(CASE WHEN termdate <= curdate() AND termdate <> '0000-00-00' THEN 1 ELSE 0 END) AS terminations
    FROM hr
    WHERE age >= 18
    GROUP BY year(hire_date)
    ) AS subquery
ORDER BY year ASC;

-- 11. What is the tenure distribution for each department?
SELECT department, round(avg(datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age >= 18
GROUP BY department;




