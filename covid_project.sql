use covid_db;
 -- show tables;
-- select * from covid_deaths order by 3,4;
-- select * from covid_vaccinations order by 3,4
-- 1.Total cases & deaths
select location,date ,total_cases,total_deaths
from covid_deaths
order by location,date;

-- 2.Death percentage
select location,date,
total_cases,total_deaths,
(total_deaths/total_cases)*100 as death_percentage
from covid_deaths;

-- 3.Countries with highest cases
select location,MAX(total_cases) as max_cases
from covid_deaths
group by location
order by max_cases desc;

-- 4.Countries with highest deaths
select location,max(total_deaths) as max_deaths
from covid_deaths
group by location
order by max_deaths desc;

-- 5.Death rate per country
select location,
max(total_deaths)/max(total_cases)*100 as death_rate
from covid_deaths
where total_cases > 0
group by location
order by death_rate desc;

-- 6.Continent-wise deaths
select continent,sum(total_deaths) as total_deaths
from covid_deaths
where continent is not null
group by continent
order by total_deaths desc;

-- 7.Daily global cases
select date,sum(new_cases) as global_cases
from covid_deaths
group by date
order by date;

-- 8.Join deaths+Vaccinations
select d.location , d.date ,
d.total_cases,
v.total_vaccinations
from covid_deaths d
join covid_vaccinations v
on d.location = v.location
and d.date=v.date;
 
-- 9.Vaccination vs population
SELECT d.location, 
MAX(d.population) AS population,
MAX(v.total_vaccinations) AS total_vaccinated,
(MAX(v.total_vaccinations) / MAX(d.population)) * 100 AS vaccinated_percent
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
GROUP BY d.location
ORDER BY vaccinated_percent DESC;

-- 10.Rolling Vaccinations(cummulative)
SELECT d.location, d.date,
v.new_vaccinations,
SUM(v.new_vaccinations)
OVER (PARTITION BY d.location ORDER BY d.date) AS rolling_vaccinations
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL;

-- 11.% of population vaccinated over time
SELECT d.location, d.date, d.population,
SUM(v.new_vaccinations)
OVER (PARTITION BY d.location ORDER BY d.date) 
/ d.population * 100 AS rolling_vaccinated_percent
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL;

-- Using Common Table Expression(data analyst level)
    with vacc_progress as (
    SELECT d.location, d.date, d.population,
    SUM(v.new_vaccinations)
    OVER (PARTITION BY d.location ORDER BY d.date) AS rolling_vaccinations
    FROM covid_deaths d
    JOIN covid_vaccinations v
    ON d.location = v.location
    AND d.date = v.date)


SELECT *,
(rolling_vaccinations / population) * 100 AS vaccinated_percent
FROM vacc_progress;

-- temp table(data engineering)
CREATE TEMPORARY TABLE temp_vacc AS
SELECT d.location, d.date, d.population,
SUM(v.new_vaccinations)
OVER (PARTITION BY d.location ORDER BY d.date) AS rolling_vaccinations
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location
AND d.date = v.date;

SELECT *,
(rolling_vaccinations / population) * 100
FROM temp_vacc;

-- 13.Top 10 vaccinated countries
SELECT location,
MAX(total_vaccinations_per_hundred) AS vaccination_rate
FROM covid_vaccinations
GROUP BY location
ORDER BY vaccination_rate DESC
LIMIT 10;

-- 14.Highest death rate countries
SELECT location,
MAX(total_deaths / total_cases) * 100 AS death_rate
FROM covid_deaths
GROUP BY location
ORDER BY death_rate DESC
LIMIT 10;

-- Vaccination vs Death Rate
SELECT d.location,
MAX(d.total_deaths / d.total_cases) * 100 AS death_rate,
MAX(v.total_vaccinations_per_hundred) AS vaccination_rate
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
GROUP BY d.location
ORDER BY vaccination_rate DESC;

-- High vaccination + low death = success

-- Peak COVID Waves
SELECT d.location, d.date, d.new_cases
FROM covid_deaths d
JOIN (
    SELECT location, MAX(new_cases) AS peak_cases
    FROM covid_deaths
    WHERE continent IS NOT NULL
    GROUP BY location
) m
ON d.location = m.location
AND d.new_cases = m.peak_cases
WHERE d.continent IS NOT NULL;


-- Before vs After Vaccination
SELECT location,
AVG(CASE WHEN date < '2021-01-01' THEN new_deaths END) AS before_vaccine,
AVG(CASE WHEN date >= '2021-01-01' THEN new_deaths END) AS after_vaccine
FROM covid_deaths
GROUP BY location;

-- Most affected countries per population
SELECT location,
MAX(total_cases / population) * 100 AS infection_rate
FROM covid_deaths
GROUP BY location
ORDER BY infection_rate DESC;

-- INSIGHTS
-- Countries with higher vaccination rates show lower death percentages

-- Peak infection waves vary significantly across regions

-- Developed countries had faster vaccination rollout

-- Advanced SQL 

with total_cases_ctc as (
select location,max(total_cases) as max_cases
from covid_deaths
group by location)
select * from total_case_ctc
order by max_cases desc;

WITH death_rate_cte AS (
    SELECT location,
    MAX(total_deaths) / MAX(total_cases) * 100 AS death_rate
    FROM covid_deaths
    WHERE continent IS NOT NULL
    GROUP BY location
)

SELECT *
FROM death_rate_cte
WHERE death_rate > 5
ORDER BY death_rate DESC;

select location,
case 
when total_cases>1000000 then 'high'
when total_cases>100000 then 'medium'
else 'low'
end as case_category
from covid_deaths;


-- 1.Vaccination Impact on Death Rate
WITH country_stats AS (
    SELECT d.location,
    MAX(d.total_cases) AS total_cases,
    MAX(d.total_deaths) AS total_deaths,
    MAX(v.total_vaccinations_per_hundred) AS vaccination_rate
    FROM covid_deaths d
    JOIN covid_vaccinations v
    ON d.location = v.location AND d.date = v.date
    WHERE d.continent IS NOT NULL
    GROUP BY d.location
)

SELECT location,
(total_deaths / total_cases) * 100 AS death_rate,
vaccination_rate
FROM country_stats
ORDER BY vaccination_rate DESC;



-- 2.Top 5 Countries per Continent(Window+Ranking)

WITH ranked_cases AS (
    SELECT continent, location,
    MAX(total_cases) AS total_cases,
    RANK() OVER (PARTITION BY continent ORDER BY MAX(total_cases) DESC) AS rnk
    FROM covid_deaths
    WHERE continent IS NOT NULL
    GROUP BY continent, location
)

SELECT *
FROM ranked_cases
WHERE rnk <= 5;

-- 3.Growth Rate of Cases(Trend Analysis)
SELECT location, date,
new_cases,
LAG(new_cases) OVER (PARTITION BY location ORDER BY date) AS prev_day,
(new_cases - LAG(new_cases) OVER (PARTITION BY location ORDER BY date)) AS growth
FROM covid_deaths
WHERE continent IS NOT NULL;

-- 4.Categorize Countries(case+analysis)
SELECT location,
MAX(total_cases) AS total_cases,
CASE 
    WHEN MAX(total_cases) > 10000000 THEN 'Severely Affected'
    WHEN MAX(total_cases) > 1000000 THEN 'Highly Affected'
    ELSE 'Moderately Affected'
END AS impact_level
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_cases DESC;

-- 5.Rolling Vaccination % (CTE+WINDOW)
WITH vacc_progress AS (
    SELECT d.location, d.date, d.population,
    SUM(v.new_vaccinations)
    OVER (PARTITION BY d.location ORDER BY d.date) AS rolling_vaccinations
    FROM covid_deaths d
    JOIN covid_vaccinations v
    ON d.location = v.location AND d.date = v.date
    WHERE d.continent IS NOT NULL
)

SELECT location, date,
(rolling_vaccinations / population) * 100 AS vaccinated_percent
FROM vacc_progress;

-- 6.Identify Peak Wave Period
SELECT location, date, new_cases
FROM covid_deaths d
JOIN (
    SELECT location, MAX(new_cases) AS peak_cases
    FROM covid_deaths
    WHERE continent IS NOT NULL
    GROUP BY location
) m
ON d.location = m.location AND d.new_cases = m.peak_cases;

-- 7.Countries with Fastest Vaccination Growth
SELECT location,
MAX(new_vaccinations_smoothed) AS max_daily_vaccination
FROM covid_vaccinations
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max_daily_vaccination DESC
LIMIT 10;

-- 8.Deaths vs Hospital Capacity

select location,
max(total_deaths) as total_deaths,
avg(hospital_beds_per_thousand) as hospital_capacity
from covid_deaths
where continents is not null
group by location
order by total_deaths desc;

-- 9.Create View (Reusable Dataset)
CREATE VIEW covid_analysis AS
SELECT d.location, d.date,
d.total_cases, d.total_deaths,
v.total_vaccinations
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

-- 10.Index for performance

create index idx_loc_date
on covid_deaths(location,date);

create index idx_loc_date_vac 
on covid_vaccinations(location,date);

-- Vaccination rollout significantly varies across countries
-- Countries with better healthcare infrastracture show lower death rates
-- Peak infection waves differ regionally
-- Rapid vaccination correlates with reduced cases growth


























