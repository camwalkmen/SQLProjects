CREATE DATABASE covid_data_project;
SHOW DATABASES;
USE covid_data_project;

SELECT *
FROM covid_deaths
WHERE continent IS  NOT NULL
ORDER BY 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY location, date;

-- Looking at Total Cases vs Total Deaths

SELECT 
	location, 
    date, 
    total_cases, 
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM covid_deaths
WHERE location LIKE '%states%'
ORDER BY location, date;


-- Looking at Total Cases vs Total Population showing what percentage of population got Covid

SELECT 
	location, 
    date,
    population,
    total_cases, 
    (total_cases / population) * 100 AS Covid
FROM covid_deaths
WHERE location LIKE '%states%'
ORDER BY location, date;

-- Looking at Countries with the Highest Infection Rate compared to Population

SELECT 
	location, 
    population,
    MAX(total_cases) AS HighestInfectionCount, 
    MAX((total_cases / population)) * 100 AS PopulationInfectedPercentage
FROM covid_deaths
GROUP BY location, population
ORDER BY PopulationInfectedPercentage DESC;

-- Showing Countries with the Highest Death Count per Population

SELECT 
	location, 
	MAX(total_deaths) AS DeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathCount DESC;

-- Continents with Highest Death Count per Population

SELECT 
	continent, 
	MAX(total_deaths) AS DeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathCount DESC;

-- GLOBAL NUMBERS

SELECT 
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS DeathPercentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Total Population vs Vaccinations

SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- Need to calculate Total Vaccinated People over the Total Population

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
	(
    SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
	)
SELECT
	*,
    (RollingPeopleVaccinated / population) * 100 AS Vaccinations
FROM PopVsVac
ORDER BY Vaccinations DESC;

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;