CREATE SCHEMA IF NOT EXISTS raw_covid;

-- Table: Vaccine administered
CREATE TABLE IF NOT EXISTS raw_covid.vaccine_administered (
	Geography VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);


-- Table: tests-conducted-7-day-avg
CREATE TABLE IF NOT EXISTS raw_covid.tests_conducted_7_day_avg (
	Geography VARCHAR(256),
	date VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);


-- Table: stringency-index
CREATE TABLE IF NOT EXISTS raw_covid.stringency_index (
	Geography VARCHAR(256),
	date VARCHAR(256),
	Count VARCHAR(256)
);



-- Table: new-deaths-per-month
CREATE TABLE IF NOT EXISTS raw_covid.new_deaths_per_month (
	Geography VARCHAR(256),
	date VARCHAR(256),
	Count VARCHAR(256)
);



-- Table: new-deaths-7-day-avg
CREATE TABLE IF NOT EXISTS raw_covid.new_deaths_7_day_avg (
	Geography VARCHAR(256),
	date VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);


-- Table: new-cases-per-month
CREATE TABLE IF NOT EXISTS raw_covid.new_cases_per_month (
	Geography VARCHAR(256),
	date VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);


-- Table: new-cases-7day-avg
CREATE TABLE IF NOT EXISTS raw_covid.new_cases_7day_avg (
	Geography VARCHAR(256),
	date VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);

-- Table: human-development-index
CREATE TABLE IF NOT EXISTS raw_covid.human_development_index (
	Geography VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);


-- Table: hopsital-beds-and-handwashing
CREATE TABLE IF NOT EXISTS raw_covid.hopsital_beds_and_handwashing (
	Geography VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);


-- Table: median-age-and-life-expectancy
CREATE TABLE IF NOT EXISTS raw_covid.median_age_and_life_expectancy (
	Geography VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);

-- Table: death-rate-from-cardiovascular-disease
CREATE TABLE IF NOT EXISTS raw_covid.death_rate_from_cardiovascular_disease (
	Geography VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);


-- Table: high-risk-age-groups
CREATE TABLE IF NOT EXISTS raw_covid.high_risk_age_groups (
	Geography VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);


-- Table: gross-domestic-product
CREATE TABLE IF NOT EXISTS raw_covid.gross_domestic_product (
	Geography VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);

-- Table: smoking
CREATE TABLE IF NOT EXISTS raw_covid.smoking (
	Geography VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);


-- Table: population
CREATE TABLE IF NOT EXISTS raw_covid.population (
	Geography VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);



-- Table: diabetes-prevalence
CREATE TABLE IF NOT EXISTS raw_covid.diabetes_prevalence (
	Geography VARCHAR(256),
	Indicator VARCHAR(256),
	Count VARCHAR(256)
);


-- PSQL

-- \copy raw_covid.stringency_index FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/stringency-index.csv' CSV HEADER;

-- \copy raw_covid.tests_conducted_7_day_avg FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/tests-conducted-7-day-avg.csv' CSV HEADER;

-- \copy raw_covid.vaccine_administered FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/vaccine-administered.csv' CSV HEADER;

-- \copy raw_covid.new_cases_per_month FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/new-cases-per-month.csv' CSV HEADER;

-- \copy raw_covid.new_deaths_7_day_avg FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/new-deaths-7-day-avg.csv' CSV HEADER;

-- \copy raw_covid.new_deaths_per_month FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/new-deaths-per-month.csv' CSV HEADER;

-- \copy raw_covid.new_cases_7day_avg FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/new-cases-7day-avg.csv' CSV HEADER;


-- \copy raw_covid.diabetes_prevalence FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/diabetes-prevalence.csv' CSV HEADER;


-- \copy raw_covid.population FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/population.csv' CSV HEADER;

-- \copy raw_covid.smoking FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/smoking.csv' CSV HEADER;


-- \copy raw_covid.gross_domestic_product FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/gross-domestic-product.csv' CSV HEADER;

-- \copy raw_covid.high_risk_age_groups FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/high-risk-age-groups.csv' CSV HEADER;

-- \copy raw_covid.death_rate_from_cardiovascular_disease FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/death-rate-from-cardiovascular-disease.csv' CSV HEADER;


-- \copy raw_covid.median_age_and_life_expectancy FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/median-age-and-life-expectancy.csv' CSV HEADER;

-- \copy raw_covid.hopsital_beds_and_handwashing FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/hopsital-beds-and-handwashing.csv' CSV HEADER;

-- \copy raw_covid.human_development_index FROM '/Users/geamxd/Documents/GitHub/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/data/raw/human-development-index.csv' CSV HEADER;

