USE JOB_POSTINGS;

-- Top paying skills for Data Analyst roles

select 
		skill_name.skills,
		count(*) job_count,
		AVG(salary_year_avg) AS year_avg
	from gold.job_postings_fact AS fact
		LEFT JOIN gold.skills_job_dim AS dim
		ON fact.job_id = dim.job_id
		LEFT JOIN gold.skills_dim AS skill_name
		ON dim.skill_id = skill_name.skill_id
		WHERE fact.job_title_short = 'Data Analyst'
		group by skill_name.skills
		HAVING count(*)  >= 10
		order by AVG(salary_year_avg) DESC ;

-- Highest paying companies for Data roles

select
		distinct fact.company_id,
		com.name,
		fact.job_title_short,
		count(distinct fact.job_id) job_count,
		AVG(salary_year_avg) AS avg_year
	from gold.job_postings_fact AS fact
		LEFT JOIN gold.company_dim AS com
		ON fact.company_id  = com.company_id
		where com.name IS NOT NULL AND LOWER(fact.job_title_short) LIKE '%data%'
		group by  fact.company_id , com.name , fact.job_title_short
		having count(distinct fact.job_id) >= 10
		order by AVG(salary_year_avg) DESC

-- Skills that appear most in high-paying jobs
            -- Skills most common in jobs paying >= 120k --

select 
		COUNT(*) skill_count,
		skills.skills
	from gold.job_postings_fact AS fact
		LEFT JOIN gold.skills_job_dim AS skill_dim
		ON fact.job_id = skill_dim.job_id 
		LEFT JOIN gold.skills_dim AS skills
		ON skill_dim.skill_id = skills.skill_id
		where fact.salary_year_avg >= 120000
		group by skills.skills
		ORDER BY COUNT(*) DESC

-- Top 3 highest paying jobs per role

select * from (
	select
		job_id,
		job_title_short,
		job_country,
		salary_year_avg,

		RANK() OVER(PARTITION BY job_title_short ORDER BY salary_year_avg DESC) AS ranks
	from gold.job_postings_fact 
	) t 
	WHERE ranks <= 3

-- Companies posting the most jobs per role

select * from (
	select 
		fact.job_title_short,
		com.name,
		COUNT(distinct fact.job_id) job_count,
		RANK() OVER(PARTITION BY fact.job_title_short ORDER BY COUNT(distinct fact.job_id) DESC) AS ranks
	from gold.job_postings_fact AS fact
		LEFT JOIN gold.company_dim AS com
		ON fact.company_id = com.company_id
		WHERE com.name IS NOT NULL
		group by fact.job_title_short ,com.name
	) t 
	WHERE ranks = 1

-- Most valuable skills (high demand + high salary)

select 
		skills.skills,
		count(*) skill_count,
		CAST(AVG(fact.salary_year_avg) AS DECIMAL(18,2)) avg_salary
	from gold.job_postings_fact AS fact
		LEFT JOIN gold.skills_job_dim AS dim
		ON fact.job_id = dim.job_id
		LEFT JOIN gold.skills_dim AS skills
		ON dim.skill_id = skills.skill_id
		group by skills.skills
		HAVING count(*) >= 100
		order by AVG(fact.salary_year_avg) DESC ,count(*)DESC

-- Salary difference between remote and non-remote roles

select 
	AVG(CASE WHEN job_work_from_home = 'FALSE' 
		THEN salary_year_avg END) AS onsite_avg,
	AVG(CASE WHEN job_work_from_home = 'TRUE' 
		THEN salary_year_avg END) AS remote_avg,
	AVG(CASE WHEN job_work_from_home = 'TRUE' 
		THEN salary_year_avg END) 
	- AVG(CASE WHEN job_work_from_home = 'FALSE' 
		THEN salary_year_avg END) AS differences
from gold.job_postings_fact

-- Top countries for high-paying jobs

select 
	job_country,
	AVG(salary_year_avg) AS avg,
	count(*) job_count
from gold.job_postings_fact
	where job_country IS NOT NULL
	group by job_country
	having count(*) >= 15
	order by AVG(salary_year_avg) desc

-- Skills required by the highest paying job per role

with job_ranking AS (
	select
	job_id,
	job_title_short,
	salary_year_avg,
	RANK() OVER(PARTITION BY job_title_short ORDER BY salary_year_avg DESC) AS job_rank
from gold.job_postings_fact
)
select 
	jr.job_id,
	jr.job_title_short,
	dm.skills
from job_ranking jr
	LEFT JOIN gold.skills_job_dim AS skill
	ON jr.job_id = skill.job_id
	LEFT JOIN gold.skills_dim AS dm
	ON skill.skill_id = dm.skill_id
	WHERE skill.skill_id IS NOT NULL AND jr.job_rank = 1

-- Top 3 highest paying companies per job role

SELECT 
company_id,
job_title_short,
company_name,
avg_salary
FROM (
select
		job_title_short,
		com.company_id AS company_id,
		com.name AS company_name,
		AVG(salary_year_avg) AS avg_salary,
		RANK() OVER(PARTITION BY job_title_short ORDER BY AVG(salary_year_avg) DESC) rank_salary,
		COUNT(*) AS job_count
	from gold.job_postings_fact AS fact
		LEFT JOIN gold.company_dim AS com
		ON fact.company_id = com.company_id
		WHERE fact.salary_year_avg IS NOT NULL AND fact.salary_year_avg != 0
		group by job_title_short , com.company_id , com.name
		HAVING COUNT(*) >= 15
) t
WHERE rank_salary <= 3

-- Companies whose salaries are above the global average

with global_average AS (
	select
		AVG(CAST(salary_year_avg AS DECIMAL(18,2))) AS global_avg
	from gold.job_postings_fact 
	)
	select 
			comp.company_id,
			comp.name,
			AVG(fact.salary_year_avg) AS company_year_avg,
			count(distinct job_id) AS job_count
		from gold.job_postings_fact AS fact
			LEFT JOIN gold.company_dim AS comp
			ON fact.company_id = comp.company_id
			WHERE comp.name IS NOT NULL AND fact.salary_year_avg IS NOT NULL
			group by comp.company_id , comp.name
			HAVING count(distinct job_id) >= 20 AND AVG(fact.salary_year_avg) > (select global_avg from global_average)
			ORDER BY AVG(fact.salary_year_avg) DESC


-- Countries where remote jobs pay more than non-remote jobs

select * from (
	select
		job_country,
		AVG(CASE WHEN job_work_from_home = 'TRUE' THEN salary_year_avg END) AS remote_average,
		AVG(CASE WHEN job_work_from_home = 'FALSE' THEN salary_year_avg END) AS onsite_average,
		AVG(CASE WHEN job_work_from_home = 'TRUE' THEN salary_year_avg END) - AVG(CASE WHEN job_work_from_home = 'FALSE' THEN salary_year_avg END) AS salary_difference,
		COUNT(job_id) AS job_count
	from gold.job_postings_fact 
		WHERE salary_year_avg IS NOT NULL AND job_country IS NOT NULL
		group by job_country
		HAVING COUNT(job_id) >= 15
	) t 
	WHERE salary_difference > 0

-- Countries where remote jobs pay less than non-remote jobs

select * from (
	select
		job_country,
		AVG(CASE WHEN job_work_from_home = 'TRUE' THEN salary_year_avg END) AS remote_average,
		AVG(CASE WHEN job_work_from_home = 'FALSE' THEN salary_year_avg END) AS onsite_average,
		AVG(CASE WHEN job_work_from_home = 'TRUE' THEN salary_year_avg END) - AVG(CASE WHEN job_work_from_home = 'FALSE' THEN salary_year_avg END) AS salary_difference,
		COUNT(job_id) AS job_count
	from gold.job_postings_fact 
		WHERE salary_year_avg IS NOT NULL AND job_country IS NOT NULL
		group by job_country
		HAVING COUNT(job_id) >= 15
	) t 
	WHERE salary_difference < 0

