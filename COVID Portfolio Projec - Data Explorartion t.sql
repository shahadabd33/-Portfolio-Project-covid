-- Data Explorartion   
-- we used: join, CTE, TMP table, Case when , Windows Functions, Creating view, aggregate Functions,Converting Data Types.


Select *
From protfolioproject..CovidDeaths1
Where continent is   null 
order by 1

select*
from  protfolioproject.. CovidVaccination
where continent = ''
order by 1;

-- Update empty strings to NULL in specified columns 

SELECT * FROM protfolioproject..CovidDeaths1; 
UPDATE protfolioproject..CovidDeaths1
SET population = CASE WHEN population= '' THEN NULL ELSE population  END,
continent= CASE WHEN continent = '' THEN NULL ELSE continent END,
people_vaccinated = CASE WHEN people_vaccinated= '' THEN NULL ELSE people_vaccinated END,
new_cases = CASE WHEN new_cases = '' THEN NULL ELSE new_cases END,
new_deaths = CASE WHEN new_deaths = '' THEN NULL ELSE new_deaths END



 select location,date,total_cases,new_cases,total_deaths,population
from protfolioproject..CovidDeaths1
order by 1,2 ;



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from protfolioproject..covidDeaths1
Where continent != ''
--where location like '%Iraq%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


Select Location, date, Population, total_cases,(population/NULLIF(CONVERT(float, total_cases),0))*100  as  PercentPopulationInfected
from protfolioproject..CovidDeaths1
Where continent is not null 
--where location like '%Iraq%'
order by 1

-- Countries with Highest Infection Rate compared to Population

Select Location,Population,MAX( total_cases)as HightInfactionCount,MAX(population/NULLIF(CONVERT(float, total_cases),0))*100  as  PercentPopulationInfected
from protfolioproject..CovidDeaths1
Where continent != '' 
--where location like '%Iraq%'
group by Location,Population
order by PercentPopulationInfected desc
 
 -- Countries with Highest Death Count per Population

 Select Location, MAX(cast(Total_deaths as int) ) as TotalDeathCount
From protfolioproject..CovidDeaths1
Where continent != ''
--where location like '%Iraq%'
Group by Location
order by TotalDeathCount desc

-- Break things down by continent 
--  1)Showing contintents with the highest death count per population

 Select continent, max(cast(total_deaths as int) ) as TotalDeathCount
From protfolioproject..CovidDeaths1
Where continent != ''
--where location like '%Iraq%'
Group by continent
order by TotalDeathCount desc


-- 2) Showing contintents with the highest death count per population
      --this is more Accurate

Select continent, sum(cast(new_deaths as int) ) as TotalDeathCount
From protfolioproject..CovidDeaths1
Where continent != ''
--where location like '%Iraq%'
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS (total cases_, total_ deaths) 

Select  SUM(CAST(new_cases AS float)) as total_cases  ,
SUM(CAST(new_deaths AS int)) as total_deaths ,
(SUM(CAST(new_deaths AS int)) /SUM(CAST(new_cases AS float))) * 100  as DeathPercentage
From protfolioproject..covidDeaths1
--where location like '%Iraq%'
where  continent is not Null
--group by date
order by 1,2

-- GLOBAL NUMBERS( with date breaking it )
Select date,SUM(CAST(new_cases AS float)) as total_cases  ,
SUM(CAST(new_deaths AS int)) as total_deaths ,
(SUM(CAST(new_deaths AS int)) /SUM(CAST(new_cases AS float))) * 100  as DeathPercentage
From protfolioproject..covidDeaths1
--where location like '%Iraq%'
where  continent is not Null
group by date
order by 1,2




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated


From protfolioproject..CovidDeaths1 dea
join protfolioproject..CovidVaccination vac 
   on dea.location= vac.location
    and dea.date= vac.date
where dea.continent!= ''
order by 2,3

--With CTE
with popvsvac(continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From protfolioproject..CovidDeaths1 dea
join protfolioproject..CovidVaccination  vac 
   on dea.location= vac.location
    and dea.date= vac.date
where dea.continent!= ''
--order by 2,3
) select*, ( Population /NULLIF(RollingPeopleVaccinated,0))* 100 
from popvsvac
 

 --TMP TABLE
 drop table if exists #PercentPopulationVaccinated
create TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population varchar (225),
New_vaccinations numeric  ,
RollingPeopleVaccinated numeric 
)
 insert into #PercentPopulationVaccinated

 Select dea.continent, dea.location, dea.date,dea.population , vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From protfolioproject..CovidDeaths1 dea
join protfolioproject..CovidVaccination  vac 
   on dea.location= vac.location
    and dea.date= vac.date
--where dea.continent!= ''
--order by 2,3
select*,(RollingPeopleVaccinated /Population )* 100  

from #PercentPopulationVaccinated;


--create 
 create  view  
PercentPopulationVaccinated  as
Select dea.continent, dea.location, dea.date,dea.population , vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From protfolioproject..CovidDeaths1 dea
join protfolioproject..CovidVaccination  vac 
   on dea.location= vac.location
    and dea.date= vac.date
where dea.continent!= ''
--order by 2,3


    select*
	from PercentPopulationVaccinated 
