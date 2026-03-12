USE JOB_POSTINGS

-- 	Which job_title_short roles have the highest average yearly salary?

select
job_title_short,
COUNT(*) job_count,
AVG(salary_year_avg) avg_salary
from gold.job_postings_fact
group by job_title_short
ORDER BY AVG(salary_year_avg) DESC

-- Which countries have the highest average salary for job postings?

select 
job_country,
AVG(salary_year_avg) max_avg_salary
from gold.job_postings_fact
WHERE job_country IS NOT NULL
group by job_country
HAVING COUNT(salary_year_avg) >= 10
ORDER BY AVG(salary_year_avg) DESC

-- Which companies post the most high-salary jobs?
select 
fact.company_id,
com.name,
count(*) job_count,
AVG(fact.salary_year_avg) salary
from gold.job_postings_fact AS fact
LEFT JOIN gold.company_dim AS com
ON fact.company_id = com.company_id
WHERE com.name IS NOT NULL
group by fact.company_id , com.name
HAVING COUNT(*) >= 10
ORDER BY AVG(fact.salary_year_avg) DESC

--------- assumption salary 12000k companies around 10 ---

select TOP(10)
fact.company_id ,
com.name,
COUNT(*) job_count
from gold.job_postings_fact AS fact
LEFT JOIN gold.company_dim AS com
ON fact.company_id = com.company_id
WHERE fact.salary_year_avg > 120000
group by fact.company_id , com.name
ORDER BY COUNT(*) DESC

-- What are the top skills required for the highest-paying roles
-- assumption highest paying = 120,000k

select
	skills.skills,
	COUNT(skills.skills) AS skill_count
from gold.job_postings_fact AS fact
	LEFT JOIN gold.skills_job_dim AS dim
	ON fact.job_id = dim.job_id
	LEFT JOIN gold.skills_dim AS skills
	ON dim.skill_id = skills.skill_id
	where fact.salary_year_avg >= 120000
	group by skills.skills;

-- Which job roles are most associated with remote work
SELECT * FROM (
	select 
		job_title_short,
		SUM(CASE WHEN job_work_from_home = 'TRUE' THEN 1 
				 ELSE 0
			END) AS remote_count
	from gold.job_postings_fact
		group by job_title_short
		) t 
		ORDER BY remote_count DESC

-- Do remote jobs offer higher average salaries than non-remote jobs
WITH remote_salary AS (
	select 
		job_title_short,
		AVG(salary_year_avg) salary_year_avg,
		COUNT(*) remote_count
	from gold.job_postings_fact
		where job_work_from_home = 'TRUE' AND salary_year_avg IS NOT NULL
		group by job_title_short
	),
	non_remote AS (
	select 
		job_title_short,
		AVG(salary_year_avg) non_re_salary_year_avg,
		COUNT(*) non_remote_count
	from gold.job_postings_fact 
		where job_work_from_home = 'FALSE' AND salary_year_avg IS NOT NULL
		group by job_title_short
	)
	select
		remote_salary.job_title_short,
		remote_salary.remote_count,
		non_remote.non_remote_count,
		remote_salary.salary_year_avg,
		non_remote.non_re_salary_year_avg,
		remote_salary.salary_year_avg - non_remote.non_re_salary_year_avg AS differencce
	from remote_salary 
		JOIN non_remote
		ON remote_salary.job_title_short = non_remote.job_title_short

-- Which schedule types (full-time, part-time, etc.) have the highest average salary?
-- make assumption at least 10 job posts

	select
		job_schedule_type ,
		count(job_id) AS job_count,
		AVG(CAST(salary_year_avg AS DECIMAL(18,2))) avg_salary
	from gold.job_postings_fact
		where job_schedule_type IS NOT NULL
		group by job_schedule_type
		HAVING count(job_id) >= 10
		ORDER BY AVG(CAST(salary_year_avg AS DECIMAL(18,2))) DESC

-- 	Which countries have the highest demand for specific top skills like SQL, Python, Azure, Power BI?

select 
		fact.job_country,
		count(distinct fact.job_id) skill_count
	from gold.job_postings_fact AS fact
		LEFT JOIN gold.skills_job_dim AS skills
		ON fact.job_id = skills.job_id
		LEFT JOIN gold.skills_dim AS name_skills
		On skills.skill_id = name_skills.skill_id
		where fact.job_country IS NOT NULL AND name_skills.skills IN ('SQL','Python','Azure','Power BI')
		group by fact.job_country
		order by count(*) DESC

-- Which companies hire for the widest variety of skills?

select
	comp.name AS company_name,
	COUNT(distinct fact.job_id) number_of_jobs,
	count(distinct skills.skill_id) AS nr_of_skills
from gold.job_postings_fact AS fact
	LEFT JOIN gold.company_dim AS comp
		ON fact.company_id = comp.company_id
	LEFT JOIN gold.skills_job_dim AS skills
		ON fact.job_id = skills.job_id
	LEFT JOIN gold.skills_dim AS name_skill
		ON skills.skill_id = name_skill.skill_id
	where comp.name IS NOT NULL
	group by comp.name
	ORDER BY count(distinct skills.skill_id) DESC