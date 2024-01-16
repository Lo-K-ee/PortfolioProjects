--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Data that we are going to use in our project

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
-- At the end of April 2021, in Asia the death percent 1.3 with 520000 deaths approximately
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From PortfolioProject..CovidDeaths
Where location like '%Asia%'
order by 1,2


-- Total Cases vs Population
-- percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as CovidCasePercent
From PortfolioProject..CovidDeaths
Where location like '%Asia%'
order by 1,2

-- Highest infection rate on countries with population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by 4 DESC

-- Highest death percent per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by 2 DESC

-- By continent with highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by 2 DESC

-- rates per dates across the world

Select date, SUM(new_cases) as TotalCases, SUM(Cast(new_deaths as int)) as TotalDeaths, (SUM(new_cases)/SUM(Cast(new_deaths as int))*100) as DeathPercent
From PortfolioProject..CovidDeaths
-- Where location like '%Asia%'
Where continent is not null
Group by date
order by 1,2


--JOINING TWO TABLES - checking the vaccinates per dates across countries

Select dea.date, dea.location, dea.continent, dea.population, vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order By dea.location,
		dea.date) as RollingCountPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 1

-- WITH CTE (creating a custom virtual table) to get a rolling percentage for a specific location

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingCountPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order By dea.location,
		dea.date) as RollingCountPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.Location like '%Albania%'
--order by 2, 1
)
Select *, (RollingCountPeopleVaccinated/Population)*100 as RollingPercentPeopleVaccinated
From PopVsVac


-- Creating VIEW

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order By dea.location,
		dea.date) as RollingCountPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.Location like '%Albania%'
--order by 2, 1

Select *
from PercentPopulationVaccinated