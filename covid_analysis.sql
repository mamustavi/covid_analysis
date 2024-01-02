SELECT * 
FROM covid_deaths
ORDER BY location, date;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY location, date;

-- Total cases versus total deaths
SELECT location, date, total_deaths, total_cases, (total_deaths / total_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE location LIKE '%Canada%'
ORDER BY location, date;

-- Total cases versus population
-- What percentage of the population had gotten COVID?
SELECT location, date, total_cases, population, (total_cases / population) * 100 AS population_percentage
FROM covid_deaths
WHERE location LIKE '%Canada%'
ORDER BY location, date;

-- Which countries have the highest infection rate compared to population?
SELECT location, population, MAX(total_cases) AS max_cases, MAX((total_cases / population) * 100) AS max_percentage
FROM covid_deaths
WHERE total_cases IS NOT NULL
GROUP BY location, population
ORDER BY max_percentage DESC;

-- Which countries had the highest death count per population?
SELECT location, population, MAX(total_deaths) AS max_deaths, MAX((total_deaths / population) / 100) AS max_death_percentage
FROM covid_deaths
WHERE total_deaths IS NOT NULL 
	AND location IS NOT NULL
GROUP BY location, population
ORDER BY max_death_percentage DESC;

-- Which continents had the highest death count?
-- Note that these numbers are not wholly accurate, but follows the instructions given in relevant tutorial
SELECT continent, MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- Which continents had the highest death count per population?
SELECT continent, MAX(population) as continent_population, MAX(total_deaths) AS total_death_count, MAX(total_deaths/population) AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY death_percentage DESC;

-- What are the global COVID numbers of each day?
SELECT date, MAX(population) AS global_population, MAX(total_cases) AS global_cases, MAX(total_deaths) AS global_deaths
FROM covid_deaths
WHERE date IS NOT NULL
	AND population IS NOT NULL
	AND total_cases IS NOT NULL
	AND total_deaths IS NOT NULL
GROUP BY date
ORDER BY date ASC;

-- How many new cases and new deaths occurred each day?
SELECT date, SUM(new_cases) AS global_new_cases, SUM(new_deaths) AS global_new_deaths
FROM covid_deaths
WHERE location = 'World'
	AND date IS NOT NULL 
	AND new_cases IS NOT NULL
	AND new_deaths IS NOT NULL
GROUP BY date
ORDER BY date ASC;


-- Compare total world population versus total amount of people that have been vaccinated
SELECT covid_deaths.date, population, total_vaccinations, (total_vaccinations/population)*100 AS vaccination_rate
FROM covid_deaths
JOIN covid_vaccinations
	ON covid_deaths.date = covid_vaccinations.date
	AND covid_deaths.location = covid_vaccinations.location
WHERE covid_deaths.location = 'World'
	AND covid_deaths.date IS NOT NULL 
	AND covid_deaths.population IS NOT NULL
	AND total_vaccinations IS NOT NULL
GROUP BY covid_deaths.date, covid_deaths.population, total_vaccinations
ORDER BY covid_deaths.date ASC;

-- Count the number of new vaccinations per day per country
SELECT 
	-- deaths.continent, 
	deaths.date, 
	deaths.location, 
	deaths.population, 
	new_vaccinations, 
	SUM(new_vaccinations) OVER (
		PARTITION BY deaths.location
		ORDER BY deaths.date ASC
	) AS rolling_vaccinations
FROM covid_deaths deaths
JOIN covid_vaccinations vaccinations
	ON deaths.location = vaccinations.location
	AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL
	AND new_vaccinations IS NOT NULL
ORDER BY deaths.location ASC;

-- Find the percentage of people vaccinated in the country using rolling vaccination number and CTEs
WITH pop_vs_vac AS (
	SELECT 
		-- deaths.continent, 
		deaths.date, 
		deaths.location, 
		deaths.population, 
		new_vaccinations, 
		SUM(new_vaccinations) OVER (
			PARTITION BY deaths.location
			ORDER BY deaths.date ASC
		) AS rolling_vaccinations
	FROM covid_deaths deaths
	JOIN covid_vaccinations vaccinations
		ON deaths.location = vaccinations.location
		AND deaths.date = vaccinations.date
	WHERE deaths.continent IS NOT NULL
		AND new_vaccinations IS NOT NULL
	ORDER BY deaths.location ASC
)
SELECT *, rolling_vaccinations / population AS vaccination_percentage 
FROM pop_vs_vac;

-- Find the percentage of people vaccinated in the country using rolling vaccination number and temp tables

DROP TABLE IF EXISTS temp_table;

CREATE TEMPORARY TABLE temp_table (
	date DATE,
	location VARCHAR(255), 
	population FLOAT, 
	new_vaccinations FLOAT,
	rolling_vaccinations FLOAT
);

INSERT INTO temp_table
SELECT 
	-- deaths.continent, 
	deaths.date, 
	deaths.location, 
	deaths.population, 
	new_vaccinations, 
	SUM(new_vaccinations) OVER (
		PARTITION BY deaths.location
		ORDER BY deaths.date ASC
	) AS rolling_vaccinations
FROM covid_deaths deaths
JOIN covid_vaccinations vaccinations
	ON deaths.location = vaccinations.location
	AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL
	AND new_vaccinations IS NOT NULL
ORDER BY deaths.location ASC;

SELECT *, rolling_vaccinations / population AS vaccination_percentage
FROM temp_table;

-- Create a view to store data for later visualization

DROP VIEW IF EXISTS percent_population_vaccinated;

CREATE VIEW percent_population_vaccinated AS
SELECT
	deaths.continent,
	deaths.date, 
	deaths.location, 
	deaths.population, 
	new_vaccinations, 
	SUM(new_vaccinations) OVER (
		PARTITION BY deaths.location
		ORDER BY deaths.date ASC
	) AS rolling_vaccinations
FROM covid_deaths deaths
JOIN covid_vaccinations vaccinations
	ON deaths.location = vaccinations.location
	AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL
	AND new_vaccinations IS NOT NULL
ORDER BY deaths.location ASC;

-- Show view
SELECT * FROM percent_population_vaccinated;


