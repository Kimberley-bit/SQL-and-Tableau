
/*
Covid 19 Data Exploration
Skills used: Joins, Converting Data, Types CTEs, Temp Tables, Window Functions, Aggregate Functions, Creating Views
*/

Select * --select all
From [Portfolio Project ]..['Covid Deaths']
where continent is not null
order by 3,4


--Select * 
--From [Portfolio Project ]..['Covid Vaccinations']
--order by 3,4 (ordering columns)


-- Selecting Data that I will be using 
Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project ]..['Covid Deaths']
order by 1,2


-- Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project ]..['Covid Deaths']
Where location like '%states%' -- Zooming in on States 
order by 1,2


-- Total Cases vs Population 
-- Shows what percentage of population got Covid
Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project ]..['Covid Deaths']
Where location like '%states%' -- Zooming in on States 
order by 1,2


-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project ]..['Covid Deaths']
Group by Location,Population
order by PercentPopulationInfected desc -- Highest number first 


-- Countries with Highest Death Count per Populatioin
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['Covid Deaths']
where continent is null
Group by location
order by TotalDeathCount desc


-- Breaking Things Down by Continent 
-- Showing the continent with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['Covid Deaths']
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project ]..['Covid Deaths']
where continent is not null 
Group by date
order by 1,2


-- Total Population vs Vaccination (Combining two data sets)
-- Shows percentage of population that has received at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(Numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from [Portfolio Project ]..['Covid Deaths'] dea
Join [Portfolio Project ]..['Covid Vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(Numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from [Portfolio Project ]..['Covid Deaths'] dea
Join [Portfolio Project ]..['Covid Vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac 


-- Using Temp Table to perform Calculation on Partition By in previous query 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinatins numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(Numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from [Portfolio Project ]..['Covid Deaths'] dea
Join [Portfolio Project ]..['Covid Vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3
 
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to Store Data for later Visualisations
Create View PercentPopulationVaccinated_2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(Numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project ]..['Covid Deaths'] dea
Join [Portfolio Project ]..['Covid Vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select*
From PercentPopulationVaccinated_2


-- For Tableau don't include for SQL Git hub --
-- No. 1 (First) 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project ]..['Covid Deaths']
where continent is not null 
-- Group by date
order by 1,2

-- No. 2 (Second)
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Portfolio Project ]..['Covid Deaths']
where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- No.3 (Third)
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project ]..['Covid Deaths']
Group by Location,Population
order by PercentPopulationInfected desc -- Highest number first 

-- No.4 (Fourth)
Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project ]..['Covid Deaths']
Group by Location,Population, date
order by PercentPopulationInfected desc -- Highest number first
