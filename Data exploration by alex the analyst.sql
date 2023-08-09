SELECT *
FROM dbo.CovidDeaths
ORDER BY 3, 4

--SELECT *
--FROM dbo.CovidVaccinations
--ORDER BY 3, 4

--SELECT Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths. what is the % of people who died vs people who had'nt

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at the total cases vs ppulation
-- shows whhat percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS DeathPercentage
FROM dbo.CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2


--what country has the highest infection rate compared to the population
-- Looking at country with the higest infection rate compared to population

SELECT location, 
	   population, 
	   MAX(total_cases) AS higest_infection_count, 
	   MAX((total_cases/population))*100 AS Percent_population_infected
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY Percent_population_infected DESC

-- showing the country with the higest death count per population

SELECT location,  
	   MAX(CAST(total_deaths AS int)) AS total_death_count
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Lets break things down by continent

SELECT location,  
	   MAX(CAST(total_deaths AS int)) AS total_death_count
FROM dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC



-- Global Numbers

SELECT date, 
	   SUM(new_cases) AS total_cases,
	   SUM(CAST(new_deaths AS int)) AS total_deaths,
	   SUM(CAST(new_deaths AS int))/SUM(new_cases) AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT  
	   SUM(new_cases) AS total_cases,
	   SUM(CAST(new_deaths AS int)) AS total_deaths,
	   SUM(CAST(new_deaths AS int))/SUM(new_cases) AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2




SELECT *
FROM PortfolioProject..CovidVaccinations


-- Joining the two tables
SELECT*
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Looking at total population vs vaccinations

SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated,
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- Use a CTE

WITH PopvsVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVacc


-- CREATE TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location order by dea.location, dea.date) 
--RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3