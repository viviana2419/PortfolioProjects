
--INSERT INTO EmployeeDemographics VALUES
--(1002, 'Pam', 'Beasley', 30, 'Female'),
--(1003, 'Dwight', 'Schrute', 29, 'Male'),
--(1004, 'Angela', 'Martin', 31, 'Female'),
--(1005, 'Toby', 'Flenderson', 32, 'Male'),
--(1006, 'Michael', 'Scott', 35, 'Male'),
--(1007, 'Meredith', 'Palmer', 32, 'Female'),
--(1008, 'Stanley', 'Hudson', 38, 'Male'),
--(1009, 'Kevin', 'Malone', 31, 'Male')

--INSERT INTO EmployeeSalary VALUES
--(1001, 'Salesman', 45000),
--(1002, 'Receptionist', 36000),
--(1003, 'Salesman', 63000),
--(1004, 'Accountant', 47000),
--(1005, 'HR', 50000),
--(1006, 'Regional Manager', 65000),
--(1007, 'Supplier Relations', 41000),
--(1008, 'Salesman', 48000),
--(1009, 'Accountant', 42000)

SELECT *
FROM [Portfoilo Project].dbo.CovidDeath
WHERE continent IS NOT NULL
order by 3,4

--SELECT *
--FROM [Portfoilo Project].dbo.CovidVaccinations
--order by 3,4

SELECT location, date,total_cases,new_cases,total_deaths, population
FROM [Portfoilo Project].dbo.CovidDeath
order by 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country
SELECT location, date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfoilo Project].dbo.CovidDeath
WHERE location like 'Canad%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
SELECT location, date,population,total_cases,(total_deaths/population)*100 as PercentPopulation
FROM [Portfoilo Project].dbo.CovidDeath
--WHERE location like 'Canad%'
order by 1,2

--looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases)AS HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfoilo Project].dbo.CovidDeath
--WHERE location like 'Canad%'
GROUP BY location, population
order by 4 desc

--LET'S BREAK THINGS DOWN BY CONTINENT 

--showing countinents with highest death count per population
SELECT continent,  MAX(cast(total_deaths as int))AS TotalDeathCount
FROM [Portfoilo Project].dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
order by 2 desc

--Global numbers
SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfoilo Project].dbo.CovidDeath
--WHERE location like 'Canad%'
WHERE continent IS NOT NULL
--GROUP BY date
order by 1,2

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) 
as
(
--looking at total population vs vaccinations
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING)
as RollingPeopleVaccinated
FROM [Portfoilo Project].dbo.CovidDeath dea
JOIN [Portfoilo Project].dbo.CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
--USE CTE
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
Create Table #PercVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercVac
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING)
as RollingPeopleVaccinated
FROM [Portfoilo Project].dbo.CovidDeath dea
JOIN [Portfoilo Project].dbo.CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
--USE CTE
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercVac


--Creating view to store data for later visulizations
USE [Portfoilo Project]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create View percPopVac1 as(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING)
as RollingPeopleVaccinated
FROM [Portfoilo Project].dbo.CovidDeath dea
JOIN [Portfoilo Project].dbo.CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
GO

SELECT *
FROM percPopVac1
