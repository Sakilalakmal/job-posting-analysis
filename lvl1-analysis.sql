USE JOB_POSTINGS

-- Total number of job postings
select COUNT(*) number_of_job_postings from gold.job_postings_fact

-- Total number of hiring companies
SELECT COUNT(*) hiring_compny_count FROM gold.company_dim

-- Total number of listed skills

select COUNT(*) nr_skills from gold.skills_dim

-- Job postings by country
select job_country,COUNT(*) job_count from gold.job_postings_fact group by job_country order by COUNT(*) DESC

-- Job postings by search location
select search_location,COUNT(*) job_count from gold.job_postings_fact group by search_location order by COUNT(*) DESC

-- Top 10 companies by number of job postings
select TOP(10)
	fact.company_id,
	comp.name AS company_name,
	count(fact.job_id) AS job_post_count
from gold.job_postings_fact AS fact
	LEFT JOIN gold.company_dim AS comp
	ON fact.company_id = comp.company_id
	GROUP BY fact.company_id , comp.name
	ORDER BY count(fact.job_id) DESC

-- Top 10 job roles by job_title_short
select 
job_title_short,
count(*) AS job_count
from gold.job_postings_fact
group by job_title_short 
ORDER BY COUNT(*) DESC

-- Job postings by source (job_via)

select job_via , COUNT(*)job_count from gold.job_postings_fact group by job_via order by COUNT(*) DESC

-- Remote vs non-remote jobs using job_work_from_home

select
job_work_from_home,
COUNT(*) job_count
from gold.job_postings_fact
group by job_work_from_home

-- Job postings by schedule type

select job_schedule_type,COUNT(*) job_count from gold.job_postings_fact where job_schedule_type IS NOT NULL group by job_schedule_type order by COUNT(*) DESC

-- Jobs with and without degree mention

select 
job_no_degree_mention,
COUNT(*) job_count
from gold.job_postings_fact
group by job_no_degree_mention

-- Jobs with and without health insurance

select job_health_insurance , COUNT(*) job_count from gold.job_postings_fact group by job_health_insurance order by COUNT(*) DESC;

-- Average yearly salary overall
select AVG(CAST(salary_year_avg AS DECIMAL(18,2))) from gold.job_postings_fact

--  Average yearly salary by job title
select
job_title_short,
AVG(salary_year_avg) AS avg_salary
from gold.job_postings_fact
where salary_year_avg IS NOT NULL
group by job_title_short;

select * from gold.job_postings_fact;
-- 	Top 15 most requested skills

select TOP(15)
	skild.skill_id,
	ski.skills,
	COUNT(*) skill_count
from gold.job_postings_fact AS fact
	LEFT JOIN gold.skills_job_dim AS skild
	ON fact.job_id = skild.job_id
	LEFT JOIN gold.skills_dim AS ski
	ON skild.skill_id = ski.skill_id
	WHERE skild.skill_id IS NOT NULL
	group by skild.skill_id,
	ski.skills
	ORDER BY COUNT(*) DESC


select * from gold.skills_dim
select * from gold.skills_job_dim