SELECT * 
FROM portfoliocovid..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM portfoliocovid..CovidVaccinations$
--ORDER BY 3,4

--Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfoliocovid..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths (in Poland)
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfoliocovid..CovidDeaths$
WHERE continent is not null
WHERE location like 'Poland'
ORDER BY 1,2

--Looking at Total Cases vs Population (in Poland)
--Show what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM portfoliocovid..CovidDeaths$
WHERE continent is not null
WHERE location like 'Poland'
ORDER BY 1,2

--Looking at Country with Higest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM portfoliocovid..CovidDeaths$
WHERE continent is not null
--WHERE location like 'Poland'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

----Let's break things down by continent
--SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM portfoliocovid..CovidDeaths$
--WHERE continent is not null
----WHERE location like 'Poland'
--GROUP BY continent
--ORDER BY TotalDeathCount DESC

--Showing Countries with Higest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfoliocovid..CovidDeaths$
WHERE continent is null
--WHERE location like 'Poland'
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing contintents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfoliocovid..CovidDeaths$
WHERE continent is not null
--WHERE location like 'Poland'
GROUP BY continent
ORDER BY TotalDeathCount DESC

--global numbers
SELECT SUM(new_cases) AS total_case, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM portfoliocovid..CovidDeaths$
WHERE continent is not null
--WHERE location like 'Poland'
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs Vaccinations
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(INT, V.new_vaccinations)) 
OVER (Partition by D.location ORDER BY D.location, D.date ) AS RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
FROM portfoliocovid..CovidDeaths$ D
JOIN portfoliocovid..CovidVaccinations$ V
	ON D.location = V.location 
	AND D.date = V.date 
WHERE D.continent is not null
ORDER BY 2,3

--USE CTE
WITH PopysVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS 
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(INT, V.new_vaccinations)) 
OVER (Partition by D.location ORDER BY D.location, D.date ) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM portfoliocovid..CovidDeaths$ D
JOIN portfoliocovid..CovidVaccinations$ V
	ON D.location = V.location 
	AND D.date = V.date 
WHERE D.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopysVac

--temp table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(INT, V.new_vaccinations)) 
OVER (Partition by D.location ORDER BY D.location, D.date ) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM portfoliocovid..CovidDeaths$ D
JOIN portfoliocovid..CovidVaccinations$ V
	ON D.location = V.location 
	AND D.date = V.date 
--WHERE D.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--crete view to store data for later visualisations
CREATE VIEW PercentPopulationVaccinated AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(INT, V.new_vaccinations)) 
OVER (Partition by D.location ORDER BY D.location, D.date ) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM portfoliocovid..CovidDeaths$ D
JOIN portfoliocovid..CovidVaccinations$ V
	ON D.location = V.location 
	AND D.date = V.date 
WHERE D.continent is not null
--ORDER BY 2,3

