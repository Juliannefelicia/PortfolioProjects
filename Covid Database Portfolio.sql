SELECT * 
FROM Portfolio..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--Select * 
--From Portfolio..CovidVaccination
--Order by 3,4

--Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country
SELECT Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentaage
FROM Portfolio..CovidDeaths
WHERE continent is NOT NULL AND Location like '%states%'
ORDER BY 1,2


-- Looking at Total  Cases vs. Population
-- Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 AS DeathPercentaage
FROM Portfolio..CovidDeaths
WHERE continent is NOT NULL
-- WHERE Location like '%states%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Popoulation
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0)))*100 AS PercentPopulationInfected
FROM Portfolio..CovidDeaths
WHERE continent is NOT NULL
-- WHERE Location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is NOT NULL
-- WHERE Location like '%states%'
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT location, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is NULL
-- WHERE continent like '%states%'
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is NULL
-- WHERE continent like '%states%'
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as bigint)) AS Total_Deaths, SUM(cast(new_deaths as bigint))/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE continent is NOT NULL
-- Location like '%states%'
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as bigint)) AS Total_Deaths, SUM(cast(new_deaths as bigint))/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE continent is NOT NULL
-- Location like '%states%'
-- GROUP BY date
ORDER BY 1,2



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccination vac
	On dea.location =vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
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
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccination vac
	On dea.location =vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for lataer visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccination vac
	On dea.location =vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
-- ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated