
SELECT *
FROM PortofolioProject.dbo.CovidDeaths
where continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortofolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- Looking at the total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location = 'Indonesia' and continent is NOT NULL
--WHERE location like '%indo%'
ORDER BY 1,2

-- Looking at Total Cases VS Population
-- Shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
FROM PortofolioProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location = 'Indonesia'
--WHERE location like '%indo%'
ORDER BY 1,2


-- Looking at the countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
	PopulationInfectedPercentage
FROM PortofolioProject..CovidDeaths
WHERE continent is NOT NULL
group by Location, population
ORDER BY PopulationInfectedPercentage desc

-- Showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent is NOT NULL
group by Location
ORDER BY TotalDeathCount desc

-- now, we're looking for Continent with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent is NULL
group by location
ORDER BY TotalDeathCount desc

-- Global Numbers per day

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage	
FROM PortofolioProject..CovidDeaths
--WHERE location = 'Indonesia' 
WHERE continent is NOT NULL
--WHERE location like '%indo%'
GROUP BY date
ORDER BY 1,2

-- Global Numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage	
FROM PortofolioProject..CovidDeaths
--WHERE location = 'Indonesia' 
WHERE continent is NOT NULL
--WHERE location like '%indo%'
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dth.location order by dth.location, dth.date) 
	as RollingPeopleVaccinated
FROM PortofolioProject.dbo.CovidDeaths as dth
JOIN PortofolioProject.dbo.CovidVaccinations as vac
	ON dth.location = vac.location
	and dth.date = vac.date
where dth.continent is NOT NULL
order by 2,3

-- USE CTE for getting percentage of people got vaccinated

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dth.location order by dth.location, dth.date) 
	as RollingPeopleVaccinated
FROM PortofolioProject.dbo.CovidDeaths as dth
JOIN PortofolioProject.dbo.CovidVaccinations as vac
	ON dth.location = vac.location
	and dth.date = vac.date
where dth.continent is NOT NULL
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinatedPopulation
FROM PopvsVac


-- TEMP Table

DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dth.location order by dth.location, dth.date) 
	as RollingPeopleVaccinated
FROM PortofolioProject.dbo.CovidDeaths as dth
JOIN PortofolioProject.dbo.CovidVaccinations as vac
	ON dth.location = vac.location
	and dth.date = vac.date
--where dth.continent is NOT NULL
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinatedPopulation
FROM #PercentPopulationVaccinated

-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dth.location order by dth.location, dth.date) 
	as RollingPeopleVaccinated
FROM PortofolioProject.dbo.CovidDeaths as dth
JOIN PortofolioProject.dbo.CovidVaccinations as vac
	ON dth.location = vac.location
	and dth.date = vac.date
where dth.continent is NOT NULL
--order by 2,3


SELECT *
FROM PercentPopulationVaccinated