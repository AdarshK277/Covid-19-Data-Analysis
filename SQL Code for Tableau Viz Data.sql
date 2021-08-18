-- Queries Used For Tableau Visualizations --
-- Data used: Covid-19 Data From Feb 2020 - Jul 2021

/*
-- Table 1:
Table consisting of total cases, total deaths and death percentage values of the world.
*/
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage 
FROM 
    PortfolioProjects..CovidDeaths
WHERE
    -- location = 'India' AND
    continent IS NOT NULL
ORDER BY 1, 2;

/*
Performing a double check, to see if the data is correct...
*/
SELECT
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM
    PortfolioProjects..CovidDeaths
WHERE
    [location] = 'World'
ORDER BY 1, 2;

/*
The data is extemely close to the "Table 1" query. So let us perform visualizations on it!
*/

/*
-- Table 2:
Excluding some data as they are not part of the 1st query.
*/
SELECT
    [location], SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM
    PortfolioProjects..CovidDeaths
WHERE
    continent IS NULL
    AND [location] NOT IN ('World', 'European Union', 'International')
GROUP BY [location]
ORDER BY TotalDeathCount DESC;

/*
-- Table 3:
Values regarding infection. Grouped by location and population
*/
SELECT
    [location], 
    population, 
    MAX(total_cases) as HighestInfectionCount, 
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM
    PortfolioProjects..CovidDeaths
GROUP BY [location], population
ORDER BY PercentPopulationInfected DESC;

/*
-- Table 4:
Values regarding infection. Grouped by location, population, and date
*/
SELECT
    [location],
    population,
    [date],
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM
    PortfolioProjects..CovidDeaths
GROUP BY [location], population, [date]
ORDER BY PercentPopulationInfected DESC;