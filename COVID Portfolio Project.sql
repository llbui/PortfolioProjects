--Select data that we are going to be using
SELECT * FROM PortfolioProject.dbo.CovidDeaths

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID-19 in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2 DESC


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID-19

SELECT location, date, population, total_cases, (total_cases/population*100) AS PopulationPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2 DESC


-- Looking at countries with highest infection rate compared to population

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population*100)) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Looking at countries with highest death count compared to population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Looking at death count by continent

--SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS NULL
--GROUP BY Location
--ORDER BY TotalDeathCount DESC

SELECT continent, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--SELECT continent, location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE 
----location = 'Canada' OR location = 'United States' OR location = 'Mexico' OR 
--continent = 'North America' 
----OR location = 'North America'
--GROUP BY location
--ORDER BY TotalDeathCount DESC


-- Looking at global numbers

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL



-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
ON dea.location = vax.location AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Use CTE

WITH PopvsVax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
ON dea.location = vax.location AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100 FROM PopvsVax ORDER BY 2,3


-- Use Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
ON dea.location = vax.location AND dea.date = vax.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 FROM #PercentPopulationVaccinated ORDER BY 2,3


-- Creating VIEW to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
ON dea.location = vax.location AND dea.date = vax.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated