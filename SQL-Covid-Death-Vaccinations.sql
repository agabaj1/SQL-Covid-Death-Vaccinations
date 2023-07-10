SELECT * 
FROM portfoliocovid..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM portfoliocovid..CovidVaccinations$
ORDER BY 3,4

--select data that I am going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfoliocovid..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in Poland
SELECT location, date, total_cases, total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM portfoliocovid..CovidDeaths$
WHERE continent IS NOT NULL
WHERE location LIKE 'Poland'
ORDER BY 1,2

--looking at total cases vs population
--show what percentage of population got Covid in Poland
SELECT location, date, population, total_cases, 
	(total_cases/population)*100 AS PercentPopulationInfected
FROM portfoliocovid..CovidDeaths$
WHERE continent IS NOT NULL
WHERE location LIKE 'Poland'
ORDER BY 1,2

--looking at country with higest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM portfoliocovid..CovidDeaths$
WHERE continent IS NOT NULL
--WHERE location LIKE 'Poland'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

----by continent
--SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
--FROM portfoliocovid..CovidDeaths$
--WHERE continent IS NOT NULL
----WHERE location LIKE 'Poland'
--GROUP BY continent
--ORDER BY TotalDeathCount DESC

--Showing Countries with Higest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM portfoliocovid..CovidDeaths$
WHERE continent IS NULL
--WHERE location LIKE 'Poland'
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing contintents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM portfoliocovid..CovidDeaths$
WHERE continent IS NOT NULL
--WHERE location LIKE 'Poland'
GROUP BY continent
ORDER BY TotalDeathCount DESC

--global numbers
SELECT SUM(new_cases) AS total_case, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM portfoliocovid..CovidDeaths$
WHERE continent IS NOT NULL
--WHERE location LIKE 'Poland'
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs Vaccinations
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
	SUM(CONVERT(INT, V.new_vaccinations)) 
	OVER (Partition BY D.location ORDER BY D.location, D.date ) AS RollingPeopleVaccinated,
	(RollingPeopleVaccinated/population)*100
FROM portfoliocovid..CovidDeaths$ D
JOIN portfoliocovid..CovidVaccinations$ V
	ON D.location = V.location 
	AND D.date = V.date 
WHERE D.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
WITH PopysVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS 
	(
	SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
		SUM(CONVERT(INT, V.new_vaccinations)) 
		OVER (Partition BY D.location ORDER BY D.location, D.date ) AS RollingPeopleVaccinated
		--(RollingPeopleVaccinated/population)*100
	FROM portfoliocovid..CovidDeaths$ D
	JOIN portfoliocovid..CovidVaccinations$ V
		ON D.location = V.location 
		AND D.date = V.date 
	WHERE D.continent IS NOT NULL
	--ORDER BY 2,3
	)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopysVac

--temp table

DROP TABLE IF EXICTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
	(
	continent NVARCHAR(255),
	location NVARCHAR(255),
	date DATETIME,
	population NUMERIC,
	new_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
	)

INSERT INTO #PercentPopulationVaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
	SUM(CONVERT(INT, V.new_vaccinations)) 
	OVER (Partition BY D.location ORDER BY D.location, D.date ) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM portfoliocovid..CovidDeaths$ D
JOIN portfoliocovid..CovidVaccinations$ V
	ON D.location = V.location 
	AND D.date = V.date 
--WHERE D.continent IS NOT NULL
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
WHERE D.continent IS NOT NULL
--ORDER BY 2,3

