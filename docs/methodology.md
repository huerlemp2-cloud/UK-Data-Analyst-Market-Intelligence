# Methodology

## UK Data Analyst Market Intelligence

This document summarises the methodology used to collect, clean, classify and analyse UK analytics vacancies for the UK Data Analyst Market Intelligence project.

---

## 1. Data Source

Vacancy data was collected from the Adzuna Jobs API.

Three complementary search queries were used:

- `data analyst`
- `business intelligence analyst`
- `reporting analyst`

Using multiple search terms increased market coverage but also introduced overlap because the same vacancy could be returned by more than one query.

The initial API collection contained:

- 532 raw observations
- 491 unique Adzuna job IDs
- 41 overlapping observations by job ID

Adzuna is a live data source. A new API request made at a later date may return a different set of vacancies.

---

## 2. Data Cleaning

The raw vacancy data was cleaned and standardised in Python using pandas.

The cleaning process included:

- duplicate identification;
- duplicate resolution;
- text normalisation;
- missing-value assessment;
- salary field inspection;
- contract-field inspection;
- title standardisation;
- job-family classification;
- seniority classification;
- occupational-scope classification;
- geographic grouping.

After duplicate resolution and classification, 390 vacancies remained in the final classified dataset.

---

## 3. Analytical Market Scope

Not every vacancy returned by the API represented a core analytics role.

Vacancies were therefore classified by occupational relevance.

Three important dataset sizes emerged from this process:

| Analytical Scope           | Vacancies |
| -------------------------- | --------: |
| Final classified vacancies |       390 |
| Extended Analytics market  |       334 |
| Core Analytics market      |       244 |

The **Core Analytics market** is the primary population used throughout the main Power BI dashboard.

The Core Analytics market includes the following standardised job families:

- Data Analyst
- Business Intelligence
- Reporting Analytics
- Insights Analytics
- Management Information

---

## 4. Seniority Classification

Seniority was inferred primarily from vacancy titles.

The final Core Analytics sample contained:

| Seniority        | Vacancies |
| ---------------- | --------: |
| Unspecified      |       202 |
| Senior           |        24 |
| Lead / Principal |        10 |
| Junior           |         5 |
| Entry / Trainee  |         1 |
| Manager          |         1 |
| Head / Director  |         1 |

Most vacancies did not explicitly state a seniority level in the title and were therefore classified as `Unspecified`.

---

## 5. Salary Methodology

Adzuna provides salary fields alongside a `salary_is_predicted` indicator.

This distinction was retained throughout the analysis because predicted salaries should not be treated as equivalent to salaries explicitly advertised by employers.

Within the 244 Core Analytics vacancies:

- 120 vacancies had advertised / non-predicted salary information;
- 124 vacancies relied on Adzuna-predicted salary values.

Headline salary comparisons in the dashboard use advertised salary observations where appropriate.

The median advertised salary for the Core Analytics market was:

**£44,750**

---

## 6. Geographic Analysis

Vacancies were grouped into three geographic categories:

- London
- Rest of UK
- UK-wide / Unspecified

The Core Analytics sample contained:

| Geography             | Vacancies | Share |
| --------------------- | --------: | ----: |
| Rest of UK            |       140 | 57.4% |
| London                |        75 | 30.7% |
| UK-wide / Unspecified |        29 | 11.9% |

For vacancies with advertised salary information:

- London median salary: **£52,500**
- Rest of UK median salary: **£40,053**

This corresponds to an observed London salary premium of approximately:

**31.1%**

This comparison reflects the analysed sample and should not be interpreted as a universal UK labour-market estimate.

---

## 7. Technology and Capability Extraction

Technology and analytical-capability mentions were extracted from the vacancy-description text supplied by Adzuna.

Examples of technology categories included:

- Power BI
- SQL
- Excel
- Python
- Tableau
- SQL Server
- Snowflake
- Azure

Examples of capability categories included:

- Reporting
- Dashboarding
- Data Analysis
- Data Transformation
- Data Visualisation
- KPI
- Data Quality
- Data Modelling
- Forecasting

Within the Core Analytics market:

- 38 vacancies contained at least one detected technology mention;
- 127 vacancies contained at least one detected analytical-capability mention.

Technology coverage:

**15.6%**

Capability coverage:

**52.0%**

---

## 8. Text-Analysis Limitation

Adzuna may provide job-description snippets rather than complete vacancy descriptions.

For this reason, a technology or capability that is not detected in the available text should **not** be interpreted as evidence that the employer does not require that skill.

The analysis therefore measures:

> observed mentions in the available Adzuna vacancy text

rather than:

> definitive employer requirements.

This distinction is important when interpreting technology and capability percentages.

---

## 9. SQL Analysis

DuckDB was used to reproduce and extend key analytical questions using SQL.

The SQL analysis included:

- filtering;
- aggregation;
- salary benchmarking;
- geographic comparisons;
- job-family analysis;
- employer / advertiser concentration;
- conditional aggregation;
- joins;
- CTEs;
- subqueries;
- ranking;
- window functions;
- `LAG`;
- `NTILE`.

This provided a second analytical workflow alongside Python.

---

## 10. Exploratory Machine Learning

An exploratory salary-prediction exercise was conducted using the available structured vacancy features.

The models tested included:

- Median Baseline
- Decision Tree
- Random Forest
- Gradient Boosting

Repeated cross-validation indicated that predictive performance was modest.

The strongest tested model, Gradient Boosting, achieved approximately:

- MAE: £16,591
- RMSE: £22,351
- R²: 0.14

The model is therefore presented as an exploratory analytical experiment rather than a production salary-prediction system.

Permutation importance suggested that features including contract type, geography and job family contributed more predictive information than individual technology flags.

---

## 11. Power BI Data Model

The final dashboard uses a dimensional model centred on `FactJobs`.

Supporting dimension tables include:

- `DimDate`
- `DimTechnology`
- `DimCapability`
- `DimSearchTerm`

Bridge tables include:

- `BridgeJobTechnology`
- `BridgeJobCapability`
- `BridgeJobSearchTerm`

This structure allows vacancies to be analysed across dates, technologies, capabilities and original API search terms.

---

## 12. Key Methodological Limitations

The main limitations of the analysis are:

1. Adzuna represents a market sample rather than the complete UK vacancy market.
2. Search-query selection affects which vacancies are retrieved.
3. The same vacancy may initially appear under multiple search queries.
4. Approximately half of Core Analytics vacancies relied on Adzuna-predicted salary values.
5. Technology and capability extraction is based on the vacancy text available through Adzuna.
6. Small job-family samples can produce unstable salary estimates.
7. Machine-learning performance was limited by the available structured features.
8. The vacancy market changes over time, so the analysis represents the dataset collected for this project.

---

## 13. Analytical Principle

The project prioritises methodological transparency over presenting artificially strong conclusions.

Advertised and predicted salary values are distinguished, small samples are treated cautiously, text-derived skill mentions are not interpreted as complete job requirements, and the machine-learning experiment is reported according to its observed predictive performance.
