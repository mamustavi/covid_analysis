-- TABLEAU VISUALIZATION #1: Global death percentage
SELECT 
	SUM(new_cases) AS total_cases, 
	SUM(new_deaths) AS total_deaths, 
	(SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL;

-- TABLEAU VISUALIZATION #2: Total death count per continent
SELECT 
	continent, 
	SUM(new_deaths) AS total_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent;

-- TABLEAU VISUALIZATION #3: Rank countries based on percentage of people infected (most recent)
SELECT 
	location,
	population,
	SUM(new_cases) AS total_cases,
	SUM(new_cases)/population AS percent_infected
FROM covid_deaths
WHERE continent IS NOT NULL
	AND population IS NOT NULL
	AND new_cases IS NOT NULL
GROUP BY location, population
ORDER BY percent_infected DESC;

 -- TABLEAU VISUALIZATAION #4: Rank countries based highest infection rate per day
SELECT 
	location,
	population,
	date,
	MAX(total_cases) AS higest_infection_count,
	MAX((total_cases/population)*100) AS percent_population_infected
FROM covid_deaths
WHERE continent IS NOT NULL
	AND total_cases IS NOT NULL
GROUP BY location, date, population
ORDER BY percent_population_infected DESC;







