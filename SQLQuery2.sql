SELECT*
FROM Covid_portfolio_project#1..CovidDeaths
WHERE continent is not null
Order



--SELECT*
--FROM Covid_portfolio_project#1..CovidVaccinations
--ORDER BY 3,4;

--SELECT DATA that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid_portfolio_project#1..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of gying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases) *100 AS DeathPersentage
FROM Covid_portfolio_project#1..CovidDeaths
WHERE location like '%ukrai%'
ORDER BY 1,2;

--Looking at the total cases vs Population
--Shows what persentage of population got covid
SELECT Location, date, total_cases, population, (Total_cases/population) *100 AS PercentPopulationInfected
FROM Covid_portfolio_project#1..CovidDeaths
WHERE location like '%ukrain%'
ORDER BY 1,2;

--Looking at country with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((Total_cases/population)) *100 AS PercentPopulationInfected
FROM Covid_portfolio_project#1..CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc;


--Showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Covid_portfolio_project#1..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc;

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the continents with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Covid_portfolio_project#1..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;


--GLOBAL NUMBERS
-- BY DAY
SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM Covid_portfolio_project#1..CovidDeaths
--WHERE location like '%ukrai%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

--For whole period
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM Covid_portfolio_project#1..CovidDeaths
--WHERE location like '%ukrai%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;


--Vaccination table
--Looking at tptal Population vs Vaccinations


--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Covid_portfolio_project#1..CovidDeaths dea
JOIN Covid_portfolio_project#1..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Covid_portfolio_project#1..CovidDeaths dea
JOIN Covid_portfolio_project#1..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating a view to store data for visualisations later
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Covid_portfolio_project#1..CovidDeaths dea
JOIN Covid_portfolio_project#1..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*
FROM PercentPopulationVaccinated

CREATE VIEW PercentPopulationInfected as 
--Looking at country with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((Total_cases/population)) *100 AS PercentPopulationInfected
FROM Covid_portfolio_project#1..CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY Location, Population
--ORDER BY PercentPopulationInfected desc;


CREATE VIEW TotalDeathCount as 
--Showing countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Covid_portfolio_project#1..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
--ORDER BY TotalDeathCount desc;


--GLOBAL NUMBERS
-- BY DAY
CREATE VIEW GlobalNumbersBYDay as 
SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM Covid_portfolio_project#1..CovidDeaths
WHERE continent is not null
GROUP BY date
--ORDER BY 1,2;

CREATE VIEW GlobalNumbersGeneral as 
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM Covid_portfolio_project#1..CovidDeaths
WHERE continent is not null
--ORDER BY 1,2;