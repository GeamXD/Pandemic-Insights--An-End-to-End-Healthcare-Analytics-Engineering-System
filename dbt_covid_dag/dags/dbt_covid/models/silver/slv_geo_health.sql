WITH geo_base AS (
    SELECT DISTINCT TRIM(geography) AS code
    FROM {{ ref('brz__population') }}
),

cvs_death AS (
    SELECT
    trim(geography) as code,
    SAFE_CAST(cvs_death_rate_per_ten_thousand as FLOAT64) as death_rate_2017
FROM {{ ref('brz__death_rate_from_cardiovascular_disease') }}
WHERE cvs_death_rate_per_ten_thousand IS NOT NULL AND geography IS NOT NULL
),

dm_prev AS (
            SELECT
                TRIM(geography) as code,
                SAFE_CAST(pct_diabetes as FLOAT64) as pct_diabetes
            FROM {{ ref('brz__diabetes_prevalence') }}
            WHERE pct_diabetes IS NOT NULL AND geography IS NOT NULL
            ),
gdp AS (
            SELECT
                trim(geography) as code,
                SAFE_CAST(gdp as FLOAT64) as gdp
        FROM {{ ref('brz__gross_domestic_product') }}
        WHERE gdp IS NOT NULL AND geography IS NOT NULL
    ),

high_risk AS (
            SELECT
                trim(geography) as code,
                COALESCE(
                        SAFE_CAST(
                        MAX(CASE WHEN high_risk_age_grp_indicator = '70 years and older' THEN pct_high_risk_age_grp END) AS FLOAT64
                        )
                , 0) as pct_70_plus,
                COALESCE(
                        SAFE_CAST(
                        MAX(CASE WHEN high_risk_age_grp_indicator <> '70 years and older' THEN pct_high_risk_age_grp END) AS FLOAT64
                        )
                , 0) as pct_under_70
        FROM {{ ref('brz__high_risk_age_groups') }}
        WHERE geography IS NOT NULL
        GROUP BY 1
    ),
hosp_hand AS (
            SELECT
                TRIM(geography) AS code,
                -- Handle pct_handwashing
                SAFE_CAST(COALESCE(
                    NULLIF(
                        MAX(CASE
                            WHEN handwashing_indicator = '% of population with basic handwashing facilities on premises'
                            THEN pct_handwashing
                        END),
                    'Null'),
                '0') AS FLOAT64) AS pct_handwashing,
                -- Handle pct_hos_beds
                SAFE_CAST(COALESCE(
                    NULLIF(
                        MAX(CASE
                            WHEN handwashing_indicator <> '% of population with basic handwashing facilities on premises'
                            THEN pct_handwashing
                        END),
                    'Null'),
                '0') AS FLOAT64) AS pct_hos_beds
            FROM {{ ref('brz__hopsital_beds_and_handwashing') }}
            WHERE geography IS NOT NULL
            GROUP BY 1
    ),
human_index AS (
            SELECT
                    TRIM(geography) as Code,
                    SAFE_CAST(NULLIF(hum_dev_index, 'Null') AS FLOAT64) as hum_dev_index
            FROM {{ ref('brz__human_development_index') }}
            WHERE geography IS NOT NULL AND hum_dev_index IS NOT NULL
    ),
life_exp_and_med_age AS (
        SELECT
                TRIM(geography) AS code,
                COALESCE(SAFE_CAST(
                        MAX(CASE
                            WHEN median_age_life_expectancy_indicator = 'Median age'
                                THEN median_age_life_expectancy_value END) AS FLOAT64), 0) as median_age,
                COALESCE(SAFE_CAST(
                        MAX(CASE
                            WHEN median_age_life_expectancy_indicator <> 'Median age'
                                THEN median_age_life_expectancy_value END) AS FLOAT64), 0) as life_expectancy
                FROM {{ ref('brz__median_age_and_life_expectancy') }}
                WHERE geography IS NOT NULL
                GROUP BY 1
    ),
population AS (
            SELECT
                TRIM(geography) as code,
                COALESCE(
                    SAFE_CAST(
                        MAX(CASE WHEN population_indicator = 'Population in 2020' THEN population_value END)
                    AS FLOAT64)
                , 0) AS population_2020,
                COALESCE(
                    SAFE_CAST(
                        MAX(CASE WHEN population_indicator <> 'Population in 2020' THEN population_value END)
                    AS FLOAT64)
                , 0) AS population_density_2020
        FROM {{ ref('brz__population') }}
        WHERE geography IS NOT NULL
        GROUP BY 1
    ),
vaccine_adm AS (
        SELECT
            TRIM(geography) as code,
            COALESCE(SAFE_CAST(
                    NULLIF(
                             MAX(
            CASE WHEN vaccine_indicator = 'Received at least one vaccine dose' THEN no_of_people_vaccinated
            END
            ),
            'Null') AS FLOAT64),
                    0) AS least_1_vaccine_dose,
            COALESCE(SAFE_CAST(
                    NULLIF(
                             MAX(
            CASE WHEN vaccine_indicator <> 'Received at least one vaccine dose' THEN no_of_people_vaccinated
            END
            ),
            'Null') AS FLOAT64),
                    0) AS all_vaccine_doses
            FROM {{ ref('brz__vaccine_administered') }}
            GROUP BY 1
    )

SELECT
    g.code,
    cds.death_rate_2017,
    dm.pct_diabetes,
    gdp.gdp,
    hr.pct_70_plus,
    hr.pct_under_70,
    hh.pct_handwashing,
    hh.pct_hos_beds,
    hi.hum_dev_index,
    le.median_age,
    le.life_expectancy,
    pop.population_2020,
    pop.population_density_2020,
    va.least_1_vaccine_dose,
    va.all_vaccine_doses
FROM geo_base g
LEFT JOIN cvs_death cds      USING (code)
LEFT JOIN dm_prev dm         USING (code)
LEFT JOIN gdp                USING (code)
LEFT JOIN high_risk hr       USING (code)
LEFT JOIN hosp_hand hh       USING (code)
LEFT JOIN human_index hi     USING (code)
LEFT JOIN life_exp_and_med_age le USING (code)
LEFT JOIN population pop     USING (code)
LEFT JOIN vaccine_adm va     USING (code)