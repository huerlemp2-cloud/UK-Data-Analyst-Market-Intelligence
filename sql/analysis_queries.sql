-- ============================================================
-- UK Data Analyst Market Intelligence
-- SQL Analysis
-- ============================================================
--
-- SQL engine: DuckDB
--
-- These queries reproduce key analyses from the project's
-- SQL notebook.
--
-- The queries assume the following analytical tables have been
-- loaded as demonstrated in notebooks/05_sql_analysis.ipynb:
--
--   vacancies
--   core_jobs
--   extended_jobs
--   job_search_terms
--
-- Core Analytics vacancies are the primary analytical population.
-- Advertised salary analysis excludes Adzuna-predicted salaries
-- where indicated.
-- ============================================================


-- ============================================================
-- 1. DATA VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS total_vacancies,
    COUNT(DISTINCT job_id) AS unique_job_ids
FROM vacancies;


SELECT
    COUNT(*) AS core_vacancies,
    COUNT(DISTINCT job_id) AS unique_core_jobs
FROM core_jobs;


SELECT
    COUNT(*) AS extended_vacancies,
    COUNT(DISTINCT job_id) AS unique_extended_jobs
FROM extended_jobs;


-- ============================================================
-- 2. CORE MARKET COMPOSITION
-- ============================================================

SELECT
    job_family,
    COUNT(*) AS vacancies,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        1
    ) AS share_pct

FROM core_jobs

GROUP BY job_family

ORDER BY vacancies DESC;


-- ============================================================
-- 3. ADVERTISED VS PREDICTED SALARIES
-- ============================================================

SELECT
    salary_source,
    COUNT(*) AS vacancies,

    ROUND(
        AVG(salary_midpoint),
        2
    ) AS mean_salary,

    ROUND(
        MEDIAN(salary_midpoint),
        2
    ) AS median_salary,

    ROUND(
        MIN(salary_midpoint),
        2
    ) AS min_salary,

    ROUND(
        MAX(salary_midpoint),
        2
    ) AS max_salary

FROM core_jobs

GROUP BY salary_source

ORDER BY vacancies DESC;


-- ============================================================
-- 4. GEOGRAPHIC SALARY ANALYSIS
-- ============================================================

SELECT
    CASE
        WHEN LOWER(location) LIKE '%london%'
            THEN 'London'

        WHEN LOWER(TRIM(location)) = 'uk'
            THEN 'UK-wide / Unspecified'

        ELSE 'Rest of UK'
    END AS geo_scope,

    COUNT(*) AS vacancies,

    ROUND(
        AVG(salary_midpoint),
        2
    ) AS mean_salary,

    ROUND(
        MEDIAN(salary_midpoint),
        2
    ) AS median_salary

FROM core_jobs

WHERE salary_is_predicted = 0

GROUP BY geo_scope

ORDER BY vacancies DESC;


-- ============================================================
-- 5. LONDON SALARY PREMIUM
-- ============================================================

WITH geo_salary AS (

    SELECT
        CASE
            WHEN LOWER(location) LIKE '%london%'
                THEN 'London'

            WHEN LOWER(TRIM(location)) = 'uk'
                THEN 'UK-wide / Unspecified'

            ELSE 'Rest of UK'
        END AS geo_scope,

        salary_midpoint

    FROM core_jobs

    WHERE salary_is_predicted = 0
),

median_by_geo AS (

    SELECT
        geo_scope,
        MEDIAN(salary_midpoint) AS median_salary

    FROM geo_salary

    WHERE geo_scope IN (
        'London',
        'Rest of UK'
    )

    GROUP BY geo_scope
)

SELECT
    MAX(
        CASE
            WHEN geo_scope = 'London'
            THEN median_salary
        END
    ) AS london_median,

    MAX(
        CASE
            WHEN geo_scope = 'Rest of UK'
            THEN median_salary
        END
    ) AS rest_uk_median,

    ROUND(
        (
            MAX(
                CASE
                    WHEN geo_scope = 'London'
                    THEN median_salary
                END
            )
            -
            MAX(
                CASE
                    WHEN geo_scope = 'Rest of UK'
                    THEN median_salary
                END
            )
        )
        /
        MAX(
            CASE
                WHEN geo_scope = 'Rest of UK'
                THEN median_salary
            END
        )
        * 100,
        1
    ) AS london_premium_pct

FROM median_by_geo;


-- ============================================================
-- 6. SALARY BY JOB FAMILY
-- ============================================================

SELECT
    job_family,

    COUNT(*) AS advertised_vacancies,

    ROUND(
        AVG(salary_midpoint),
        2
    ) AS mean_salary,

    ROUND(
        MEDIAN(salary_midpoint),
        2
    ) AS median_salary,

    ROUND(
        MIN(salary_midpoint),
        2
    ) AS min_salary,

    ROUND(
        MAX(salary_midpoint),
        2
    ) AS max_salary

FROM core_jobs

WHERE salary_is_predicted = 0

GROUP BY job_family

ORDER BY median_salary DESC;


-- ============================================================
-- 7. SALARY RANK WITHIN JOB FAMILY
-- ============================================================

WITH ranked_jobs AS (

    SELECT
        job_id,
        title,
        company,
        job_family,
        salary_midpoint,

        ROW_NUMBER() OVER (
            PARTITION BY job_family
            ORDER BY salary_midpoint DESC
        ) AS salary_rank

    FROM core_jobs

    WHERE salary_is_predicted = 0
)

SELECT
    job_family,
    salary_rank,
    title,
    company,

    ROUND(
        salary_midpoint,
        2
    ) AS salary_midpoint

FROM ranked_jobs

WHERE salary_rank <= 3

ORDER BY
    job_family,
    salary_rank;


-- ============================================================
-- 8. SALARY BANDS
-- ============================================================

WITH salary_bands AS (

    SELECT
        CASE
            WHEN salary_midpoint < 30000
                THEN 'Under £30k'

            WHEN salary_midpoint < 40000
                THEN '£30k–£39,999'

            WHEN salary_midpoint < 50000
                THEN '£40k–£49,999'

            WHEN salary_midpoint < 60000
                THEN '£50k–£59,999'

            WHEN salary_midpoint < 80000
                THEN '£60k–£79,999'

            WHEN salary_midpoint < 100000
                THEN '£80k–£99,999'

            ELSE '£100k+'
        END AS salary_band,

        salary_midpoint

    FROM core_jobs

    WHERE salary_is_predicted = 0
)

SELECT
    salary_band,
    COUNT(*) AS vacancies,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        1
    ) AS share_pct

FROM salary_bands

GROUP BY salary_band

ORDER BY
    MIN(salary_midpoint);


-- ============================================================
-- 9. ADVERTISER CONCENTRATION
-- ============================================================

WITH advertiser_counts AS (

    SELECT
        company,
        COUNT(*) AS vacancies

    FROM core_jobs

    WHERE company IS NOT NULL

    GROUP BY company
),

ranked_advertisers AS (

    SELECT
        company,
        vacancies,

        ROW_NUMBER() OVER (
            ORDER BY vacancies DESC, company
        ) AS advertiser_position

    FROM advertiser_counts
),

totals AS (

    SELECT
        COUNT(*) AS total_vacancies

    FROM core_jobs
)

SELECT
    ROUND(
        SUM(
            CASE
                WHEN advertiser_position <= 5
                THEN vacancies
                ELSE 0
            END
        )
        * 100.0
        / MAX(total_vacancies),
        1
    ) AS top_5_share_pct,

    ROUND(
        SUM(
            CASE
                WHEN advertiser_position <= 10
                THEN vacancies
                ELSE 0
            END
        )
        * 100.0
        / MAX(total_vacancies),
        1
    ) AS top_10_share_pct

FROM ranked_advertisers

CROSS JOIN totals;


-- ============================================================
-- 10. SEARCH-QUERY COVERAGE
-- ============================================================

SELECT
    s.search_term,

    COUNT(
        DISTINCT c.job_id
    ) AS core_vacancies,

    ROUND(
        COUNT(DISTINCT c.job_id) * 100.0
        /
        (
            SELECT COUNT(*)
            FROM core_jobs
        ),
        1
    ) AS core_coverage_pct

FROM core_jobs AS c

INNER JOIN job_search_terms AS s
    ON c.job_id = s.job_id

GROUP BY s.search_term

ORDER BY core_vacancies DESC;


-- ============================================================
-- 11. SEARCH-QUERY OVERLAP
-- ============================================================

SELECT
    c.job_id,
    c.title,
    c.company,
    c.job_family,

    COUNT(
        DISTINCT s.search_term
    ) AS query_matches,

    STRING_AGG(
        DISTINCT s.search_term,
        ' | '
    ) AS matched_queries

FROM core_jobs AS c

INNER JOIN job_search_terms AS s
    ON c.job_id = s.job_id

GROUP BY
    c.job_id,
    c.title,
    c.company,
    c.job_family

HAVING COUNT(
    DISTINCT s.search_term
) > 1

ORDER BY
    query_matches DESC,
    c.title;


-- ============================================================
-- 12. SALARY QUARTILES WITH NTILE
-- ============================================================

WITH salary_quartiles AS (

    SELECT
        job_id,
        job_family,
        salary_midpoint,

        NTILE(4) OVER (
            ORDER BY salary_midpoint
        ) AS salary_quartile

    FROM core_jobs

    WHERE salary_is_predicted = 0
)

SELECT
    salary_quartile,

    COUNT(*) AS vacancies,

    ROUND(
        MIN(salary_midpoint),
        2
    ) AS min_salary,

    ROUND(
        MEDIAN(salary_midpoint),
        2
    ) AS median_salary,

    ROUND(
        MAX(salary_midpoint),
        2
    ) AS max_salary

FROM salary_quartiles

GROUP BY salary_quartile

ORDER BY salary_quartile;


-- ============================================================
-- 13. ADVERTISER POSTING CADENCE WITH LAG
-- ============================================================

WITH advertiser_jobs AS (

    SELECT
        job_id,
        company,
        title,

        TRY_CAST(
            created AS TIMESTAMPTZ
        ) AS created_at

    FROM core_jobs

    WHERE company IS NOT NULL
),

posting_sequence AS (

    SELECT
        job_id,
        company,
        title,
        created_at,

        LAG(created_at) OVER (
            PARTITION BY company
            ORDER BY created_at
        ) AS previous_posted_at

    FROM advertiser_jobs
)

SELECT
    company,
    title,
    created_at,
    previous_posted_at,

    DATE_DIFF(
        'day',
        previous_posted_at,
        created_at
    ) AS days_since_previous_post

FROM posting_sequence

WHERE previous_posted_at IS NOT NULL

ORDER BY
    company,
    created_at;