# Data Dictionary

## UK Data Analyst Market Intelligence

This document describes the analytical tables used by the Power BI semantic model.

The model is centred on `FactJobs`, where each row represents one unique Core Analytics vacancy.

Many-to-many relationships between vacancies and technologies, capabilities and search terms are handled through dedicated bridge tables.

---

## 1. FactJobs

**File:** `data/powerbi/FactJobs.csv`

**Grain:** One row per unique Core Analytics vacancy.

**Primary key:** `job_id`

| Column                | Description                                                                                             |
| --------------------- | ------------------------------------------------------------------------------------------------------- |
| `job_id`              | Unique Adzuna vacancy identifier.                                                                       |
| `title`               | Vacancy job title.                                                                                      |
| `company`             | Employer or advertiser name supplied by Adzuna.                                                         |
| `location`            | Original vacancy location.                                                                              |
| `job_family`          | Standardised analytical job-family classification.                                                      |
| `seniority`           | Seniority classification inferred primarily from the vacancy title.                                     |
| `created`             | Vacancy creation timestamp.                                                                             |
| `created_date`        | Date-only version of the vacancy creation timestamp, used to relate vacancies to `DimDate`.             |
| `salary_min`          | Lower bound of the annual salary range supplied by Adzuna.                                              |
| `salary_max`          | Upper bound of the annual salary range supplied by Adzuna.                                              |
| `salary_midpoint`     | Midpoint between `salary_min` and `salary_max`.                                                         |
| `salary_is_predicted` | Indicator identifying whether the salary was predicted by Adzuna. `1` = predicted, `0` = non-predicted. |
| `salary_source`       | Human-readable distinction between advertised/non-predicted and Adzuna-predicted salaries.              |
| `salary_band`         | Salary midpoint grouped into analytical salary bands.                                                   |
| `geo_scope`           | Standardised geography: London, Rest of UK, or UK-wide / Unspecified.                                   |
| `contract_type`       | Contract type where available, such as permanent or contract.                                           |
| `contract_time`       | Working-time classification where available, such as full-time or part-time.                            |

### Job Family Values

The Core Analytics population contains five standardised job families:

- Data Analyst
- Business Intelligence
- Reporting Analytics
- Insights Analytics
- Management Information

### Geography Values

`geo_scope` contains:

- London
- Rest of UK
- UK-wide / Unspecified

### Salary Source Values

`salary_source` distinguishes:

- Advertised / non-predicted
- Adzuna predicted

---

## 2. DimDate

**File:** `data/powerbi/DimDate.csv`

**Grain:** One row per calendar date.

**Primary key:** `date`

The date dimension spans the full date range represented in `FactJobs`.

| Column               | Description                                 |
| -------------------- | ------------------------------------------- |
| `date`               | Calendar date used as the dimension key.    |
| `year`               | Calendar year.                              |
| `month_number`       | Numeric month from 1 to 12.                 |
| `month_name`         | Full calendar month name.                   |
| `year_month`         | Year and month formatted as `YYYY-MM`.      |
| `quarter`            | Calendar quarter, such as Q1, Q2, Q3 or Q4. |
| `day_of_week_number` | Numeric weekday value.                      |
| `day_of_week`        | Weekday name.                               |

### Relationship

```text
DimDate[date]
    1
    │
    *
FactJobs[created_date]
```
