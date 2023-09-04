Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From	PortfolioProject..CovidDeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) 
From	PortfolioProject..CovidDeaths
Order by 1,2

--Show the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, Population, (try_cast(total_deaths as decimal(12,2)) /(try_cast(total_cases as int)))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%Vietnam%'
order by 1,2

Select location, date, total_cases, Population, ((try_cast(total_cases as decimal(12,2)))/(try_cast(Population as int)))*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where location like '%Vietnam%'
order by 1,2

--Looking at countries with highest infection rate compared to population 
Select location, Population, Max(total_cases) as HighestInfectionCount, ((try_cast(Max(total_cases) as decimal(12,2)))/(try_cast(Population as int)))*100 as PopulationInfectedRate
From PortfolioProject..CovidDeaths
Group by location, population
Order by PopulationInfectedRate desc

--Showing countries with highest Death Count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Showing continents with highest deathcount
Select continent, Max(cast(total_deaths as int)) as DeathPerContinent
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by DeathPerContinent desc

Select location, Max(cast(total_deaths as int)) as DeathPerContinent
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by DeathPerContinent desc

--Global numbers doesnt work!

select date, Sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths  as decimal(12,2)))/Sum(cast(new_cases as bigint))*100 as PercetageNewDeath
--(try_cast(total_deaths as decimal(12,2)) /(try_cast(total_cases as int)))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%Vietnam%'
Where continent is not null
Group by date
order by 1,2

--Below doesnt work

select Sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths  as decimal(12,2)))/Sum(cast(new_cases as bigint))*100 as PercetageNewDeath
--(try_cast(total_deaths as decimal(12,2)) /(try_cast(total_cases as int)))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%Vietnam%'
Where continent is not null
Group by date
order by 1,2


--Looking at total population vs vaccination
Select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
Order by 2,3


Select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
Order by 2,3

--Use CTEs

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp table (dont know why doesnt work)

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated2 as
Select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated2
