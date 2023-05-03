


--1. Slect data using/ 
Select 
location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Coviddeaths
order by 1,2

--2. Looking at total deaths/total cases for %state%
Select 
location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPrecentage
from PortfolioProject..Coviddeaths
where location like '%state%' and continent is not null
order by 1,2

--3. Looking at total cases/population
Select 
location, population, date,
Max(cast(total_cases as float)) as HighestInfectionCount,
Max(cast(total_cases as float)/population)*100 as PrecentPopulationInfected
from PortfolioProject..Coviddeaths
group by population, location, date
--where location like '%state%'
order by PrecentPopulationInfected desc

--4. show countries with hightest death count per population
Select location, Max(cast(total_deaths as int) ) as TotalDeathCount
from PortfolioProject..Coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc

--5. show continent with hightest death count per population
Select continent, Max(cast(total_deaths as int) ) as TotalDeathCount
from PortfolioProject..Coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc

---6. Global Numbers
Select 
Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths
, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..Coviddeaths
where continent is not null
order by 1,2

---7. looking at total population vs Vaccinations
Select dea.continent, dea.location, dea.population, dea.date,
vac.new_vaccinations, Sum(convert(float,vac.new_vaccinations)) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccination
--(RollingPeopleVaccination/population)*100
from PortfolioProject..Covid_vaccinations vac
join PortfolioProject..Coviddeaths dea
on vac.date=dea.date and vac.location=dea.location
where dea.continent is not null
order by 2,3


--8. Use cte

with PopvsVac (continent, location,population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.population,-- dea.date,
vac.new_vaccinations, Sum(cast(vac.new_vaccinations as float)) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccination/population)*100
from PortfolioProject..Covid_vaccinations vac
join PortfolioProject..Coviddeaths dea
on vac.date=dea.date and vac.location=dea.location
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated /population)*100
From PopvsVac




----9. Temp Table create table

Drop Table if exists #PercentPeopleVaccinated

Create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
population numeric,
Date datetime,
New_vaccinations numeric,
RollingPeopleVaccinated numeric

)

insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.population, dea.date,
vac.new_vaccinations, Sum(cast(vac.new_vaccinations as float)) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccination/population)*100
from PortfolioProject..Covid_vaccinations vac
join PortfolioProject..Coviddeaths dea
on vac.date=dea.date and vac.location=dea.location
--where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated /population)*100
From #PercentPeopleVaccinated 



---10. Create View for table PercentPeopleVaccinated as
Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.population, dea.date,
vac.new_vaccinations, Sum(cast(vac.new_vaccinations as float)) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccination/population)*100
from PortfolioProject..Covid_vaccinations vac
join PortfolioProject..Coviddeaths dea
on vac.date=dea.date and vac.location=dea.location
where dea.continent is not null

Select *
from PercentPeopleVaccinated
