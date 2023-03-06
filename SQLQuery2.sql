create database portfolio;
use portfolio;

SELECT * FROM dbo.CovidDeaths ORDER BY 3, 4;
SELECT * FROM dbo.CovidVaccinations ORDER BY 3,4;
Select Location, date, total_cases, new_cases, total_deaths, population from dbo.CovidDeaths order by 1,2;

--show likelihood of dying in India if contact with covid 

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage from dbo.CovidDeaths where Location = 'India' order by 1,2;

--Total case vs total population

Select Location, date, total_cases, population,(total_cases/population)*100 as Percentpopulationinfected from dbo.CovidDeaths where Location = 'India' order by 1,2;

--Country with highest infection rate compare with the population

Select Location,population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as Percentpopulationinfected from dbo.CovidDeaths group by Location,population order by Percentpopulationinfected desc;

--countries with highest death count per population

 Select Location, max(cast(total_deaths as int)) as totaldeathcount from dbo.CovidDeaths where continent is not null group by Location,population order by totaldeathcount desc;

 --continent with highest death count per population

  Select Location, max(cast(total_deaths as int)) as totaldeathcount from dbo.CovidDeaths where continent is null group by Location order by totaldeathcount desc;

  --Global number

  Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage from dbo.CovidDeaths where continent is not null order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From dbo.CovidDeaths dea Join dbo.CovidVaccinations vac On dea.location = vac.location and dea.date = vac.date where dea.continent is not null order by 2,3

--USE CTE

With PopvsVac ( continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From dbo.CovidDeaths dea Join dbo.CovidVaccinations vac On dea.location = vac.location and dea.date = vac.date where dea.continent is not null --order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
ROllingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From dbo.CovidDeaths dea Join dbo.CovidVaccinations vac On dea.location = vac.location and dea.date = vac.date --where dea.continent is not null --order by 2,3

Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Create View for visualization 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From dbo.CovidDeaths dea Join dbo.CovidVaccinations vac On dea.location = vac.location and dea.date = vac.date where dea.continent is not null 
--order by 2,3
