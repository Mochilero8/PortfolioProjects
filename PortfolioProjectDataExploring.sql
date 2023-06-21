/*
	Data Exploration in SQL 
*/

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY location, date

SELECT * 
FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY location, date

-- Select Data that we are going to be using

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Looking at the Total Cases vs Total Deaths 

SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date 

-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date 

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as 
	PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing Continents with Highest Death Count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

-- Looking Total Cases, Total Deaths and Death Percentage in the world each day

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
	(SUM(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date 

-- Looking Total Cases, Total Deaths and Death Percentage in the World

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
	(SUM(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY TotalCases, TotalDeaths

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,VAC.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
--, (PeopleVaccinated/dea.population)*100
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date


-- USE A CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, PeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,VAC.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE dea.continent IS NOT NULL

)

SELECT *, (PeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,VAC.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
--WHERE dea.continent IS NOT NULL

SELECT *, (PeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store date for later visualization

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,VAC.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated