/*
## Covid 19 Data Exploration ##
Skills Used/Learnt: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT
	location, date, total_cases, new_cases, total_deaths, population
FROM
	PortfolioProjects..CovidDeaths
ORDER BY 1,2;

-- Looking at total cases vs. total deaths
-- Shows likelihood of dying if you contract Covid-19 in India
SELECT
	location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS DeathPercentage
FROM
	PortfolioProjects..CovidDeaths
WHERE
	location = 'India'
ORDER BY 1,2;

-- Looking at total cases vs. Population
-- Shows what % of population contracted Covid-19
SELECT
	location, date, population, total_cases, ROUND((total_cases/population)*100, 2) AS PercentPopulationInfected
FROM
	PortfolioProjects..CovidDeaths
WHERE
	location = 'India'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT
	location, population, MAX(total_cases) AS HighestInfectionCount, MAX(ROUND((total_cases/population)*100, 2)) AS PercentPopulationInfected
FROM
	PortfolioProjects..CovidDeaths
GROUP BY
	location,
	population
ORDER BY PercentPopulationInfected DESC;

-- Looking at countries with highest death count
SELECT
	location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM
	PortfolioProjects..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY TotalDeathCount DESC;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with highest death count per population
SELECT
	location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM
	PortfolioProjects..CovidDeaths
WHERE
	continent IS NULL
GROUP BY
	location
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS
SELECT 
	SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, ROUND(SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100, 2) AS DeathPercentage
FROM 
	PortfolioProjects..CovidDeaths
WHERE 
	continent is not null 
	--GROUP BY date
ORDER BY 
	1,2;


-- Total population vs. vaccination
-- Shows percentage of population that has recieved at least one dose of Covid vaccine
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations))
	OVER(
		PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM
	PortfolioProjects..CovidDeaths dea
JOIN
	PortfolioProjects..CovidVaccinations vac
	ON
		dea.location = vac.location
		AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
	--AND dea.continent = 'Asia'
	--AND dea.location = 'India'
ORDER BY
	1,2,3;


-- Using CTE to perform calculations on PARTITION BY in previous query
WITH 
	PopVsVac(Continent, Location, Date, Population, New_Vacciations, RollingVaccinationCount)
AS(
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations))
	OVER(
		PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM
	PortfolioProjects..CovidDeaths dea
JOIN
	PortfolioProjects..CovidVaccinations vac
	ON
		dea.location = vac.location
		AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
	--AND dea.location = 'India'
--ORDER BY
--	1,2,3
)
SELECT 
	*, ROUND((RollingVaccinationCount/Population)*100, 2) AS PerPopulationVaccinated
FROM
	PopVsVac
--WHERE
--	Location = 'India'
;


-- Using Temp Table to perform Calculation on PARTITION BY in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationCount numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int))
	OVER(
		PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS RollingVaccinationCount 
FROM
	PortfolioProjects..CovidDeaths dea
JOIN
	PortfolioProjects..CovidVaccinations vac
	ON 
	dea.location = vac.location
	AND dea.date = vac.date

SELECT 
	*, ROUND((RollingVaccinationCount/Population)*100, 2)
FROM
	#PercentPopulationVaccinated


-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int))
	OVER(
		PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS RollingVaccinationCount 
FROM
	PortfolioProjects..CovidDeaths dea
JOIN
	PortfolioProjects..CovidVaccinations vac
	ON 
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinated;
