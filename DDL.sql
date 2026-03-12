USE JOB_POSTINGS;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'gold')
BEGIN
    EXEC(N'CREATE SCHEMA gold');
END;
GO

DROP TABLE IF EXISTS gold.skills_job_dim;
DROP TABLE IF EXISTS gold.job_postings_fact;
DROP TABLE IF EXISTS gold.skills_dim;
DROP TABLE IF EXISTS gold.company_dim;

DROP TABLE IF EXISTS gold.company_dim_stg;
DROP TABLE IF EXISTS gold.skills_dim_stg;
DROP TABLE IF EXISTS gold.job_postings_fact_stg;
DROP TABLE IF EXISTS gold.skills_job_dim_stg;
GO

CREATE TABLE gold.company_dim
(
    company_id   INT            NULL,
    name         NVARCHAR(500)  NULL,
    link         NVARCHAR(1000) NULL,
    link_google  NVARCHAR(2000) NULL,
    thumbnail    NVARCHAR(1000) NULL
);
GO

CREATE TABLE gold.skills_dim
(
    skill_id  INT            NULL,
    skills    NVARCHAR(100)  NULL,
    type      NVARCHAR(100)  NULL
);
GO

CREATE TABLE gold.job_postings_fact
(
    job_id                   INT              NULL,
    company_id               INT              NULL,
    job_title_short          NVARCHAR(200)    NULL,
    job_title                NVARCHAR(500)    NULL,
    job_location             NVARCHAR(300)    NULL,
    job_via                  NVARCHAR(300)    NULL,
    job_schedule_type        NVARCHAR(100)    NULL,
    job_work_from_home       VARCHAR(50)      NULL,
    search_location          NVARCHAR(100)    NULL,
    job_posted_date          VARCHAR(50)      NULL,
    job_no_degree_mention    VARCHAR(50)      NULL,
    job_health_insurance     VARCHAR(50)      NULL,
    job_country              NVARCHAR(100)    NULL,
    salary_rate              VARCHAR(50)      NULL,
    salary_year_avg          INT              NULL,
    salary_hour_avg          DECIMAL(18, 9)   NULL
);
GO

CREATE TABLE gold.skills_job_dim
(
    job_id    INT NULL,
    skill_id  INT NULL
);
GO

CREATE TABLE gold.company_dim_stg
(
    company_id   VARCHAR(50)    NULL,
    name         NVARCHAR(500)  NULL,
    link         NVARCHAR(1000) NULL,
    link_google  NVARCHAR(2000) NULL,
    thumbnail    NVARCHAR(1000) NULL
);
GO

CREATE TABLE gold.skills_dim_stg
(
    skill_id  VARCHAR(50)    NULL,
    skills    NVARCHAR(100)  NULL,
    type      NVARCHAR(100)  NULL
);
GO

CREATE TABLE gold.job_postings_fact_stg
(
    job_id                   VARCHAR(50)    NULL,
    company_id               VARCHAR(50)    NULL,
    job_title_short          NVARCHAR(200)  NULL,
    job_title                NVARCHAR(500)  NULL,
    job_location             NVARCHAR(300)  NULL,
    job_via                  NVARCHAR(300)  NULL,
    job_schedule_type        NVARCHAR(100)  NULL,
    job_work_from_home       VARCHAR(50)    NULL,
    search_location          NVARCHAR(100)  NULL,
    job_posted_date          VARCHAR(50)    NULL,
    job_no_degree_mention    VARCHAR(50)    NULL,
    job_health_insurance     VARCHAR(50)    NULL,
    job_country              NVARCHAR(100)  NULL,
    salary_rate              VARCHAR(50)    NULL,
    salary_year_avg          VARCHAR(50)    NULL,
    salary_hour_avg          VARCHAR(50)    NULL
);
GO

CREATE TABLE gold.skills_job_dim_stg
(
    job_id    VARCHAR(50) NULL,
    skill_id  VARCHAR(50) NULL
);
GO

TRUNCATE TABLE gold.company_dim_stg;
TRUNCATE TABLE gold.skills_dim_stg;
TRUNCATE TABLE gold.job_postings_fact_stg;
TRUNCATE TABLE gold.skills_job_dim_stg;
GO

BULK INSERT gold.company_dim_stg
FROM 'D:\DE-DA\JOB_POSTING_BIG_DATA\data-set\company_dim.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    CODEPAGE = '65001',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    MAXERRORS = 100,
    ERRORFILE = 'D:\DE-DA\JOB_POSTING_BIG_DATA\data-set\company_dim_error'
);
GO

BULK INSERT gold.skills_dim_stg
FROM 'D:\DE-DA\JOB_POSTING_BIG_DATA\data-set\skills_dim.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    CODEPAGE = '65001',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    MAXERRORS = 100,
    ERRORFILE = 'D:\DE-DA\JOB_POSTING_BIG_DATA\data-set\skills_dim_error'
);
GO

BULK INSERT gold.job_postings_fact_stg
FROM 'D:\DE-DA\JOB_POSTING_BIG_DATA\data-set\job_postings_fact.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    CODEPAGE = '65001',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    MAXERRORS = 100,
    ERRORFILE = 'D:\DE-DA\JOB_POSTING_BIG_DATA\data-set\job_postings_fact_error'
);
GO

BULK INSERT gold.skills_job_dim_stg
FROM 'D:\DE-DA\JOB_POSTING_BIG_DATA\data-set\skills_job_dim.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    CODEPAGE = '65001',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    MAXERRORS = 100,
    ERRORFILE = 'D:\DE-DA\JOB_POSTING_BIG_DATA\data-set\skills_job_dim_error'
);
GO

TRUNCATE TABLE gold.company_dim;
TRUNCATE TABLE gold.skills_dim;
TRUNCATE TABLE gold.job_postings_fact;
TRUNCATE TABLE gold.skills_job_dim;
GO

INSERT INTO gold.company_dim
(
    company_id,
    name,
    link,
    link_google,
    thumbnail
)
SELECT
    TRY_CAST(NULLIF(company_id, '') AS INT),
    NULLIF(name, ''),
    NULLIF(link, ''),
    NULLIF(link_google, ''),
    NULLIF(thumbnail, '')
FROM gold.company_dim_stg;
GO

INSERT INTO gold.skills_dim
(
    skill_id,
    skills,
    type
)
SELECT
    TRY_CAST(NULLIF(skill_id, '') AS INT),
    NULLIF(skills, ''),
    NULLIF(type, '')
FROM gold.skills_dim_stg;
GO

INSERT INTO gold.job_postings_fact
(
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_location,
    job_via,
    job_schedule_type,
    job_work_from_home,
    search_location,
    job_posted_date,
    job_no_degree_mention,
    job_health_insurance,
    job_country,
    salary_rate,
    salary_year_avg,
    salary_hour_avg
)
SELECT
    TRY_CAST(NULLIF(job_id, '') AS INT),
    TRY_CAST(NULLIF(company_id, '') AS INT),
    NULLIF(job_title_short, ''),
    NULLIF(job_title, ''),
    NULLIF(job_location, ''),
    NULLIF(job_via, ''),
    NULLIF(job_schedule_type, ''),
    NULLIF(job_work_from_home, ''),
    NULLIF(search_location, ''),
    NULLIF(job_posted_date, ''),
    NULLIF(job_no_degree_mention, ''),
    NULLIF(job_health_insurance, ''),
    NULLIF(job_country, ''),
    NULLIF(salary_rate, ''),
    TRY_CAST(NULLIF(salary_year_avg, '') AS INT),
    TRY_CAST(NULLIF(salary_hour_avg, '') AS DECIMAL(18,9))
FROM gold.job_postings_fact_stg;
GO

INSERT INTO gold.skills_job_dim
(
    job_id,
    skill_id
)
SELECT
    TRY_CAST(NULLIF(job_id, '') AS INT),
    TRY_CAST(NULLIF(skill_id, '') AS INT)
FROM gold.skills_job_dim_stg;
GO

select * from gold.skills_job_dim