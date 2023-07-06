select *
from PortfolioProject..CovidDeaths$
order by 3,4

select *
from PortfolioProject..CovidVaccinations$
order by 3,4

--SELECTING DATA WE ARE USING--

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
ORDER BY 3,4

--total cases v/s total death
--covid affted population--
select location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as deathpercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
ORDER BY 1,2

--countries with highest infection rate compared to population--

select location, population, max(total_cases) as highestinfectioncount, max(total_cases/population)* 100 as percentpopulationinfected
from PortfolioProject..CovidDeaths$
GROUP BY LOCATION,population
order by percentpopulationinfected desc

--countries with high death count per population--

select location,max(cast(Total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths$
WHERE continent is not null
group by location
order by totaldeathcount desc

--continents with highest death count per population--

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers--

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2

--total population v/s vaccinations--

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--rolling populations--total population vs vaccinations--

--cte--

with popvsvac (continent,location,date, population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)

select *,(rollingpeoplevaccinated/population)*100
from popvsvac


--temp table--
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select *,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--creating view to store data for later visualisation--

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null


select *
from percentpopulationvaccinated
