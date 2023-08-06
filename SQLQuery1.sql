select *
from coviddeaths
where continent is not null
order by 3,4

--select *
--from covidvacsination
--order by 3,4

-- select the data that we are going to be using 

select location, date ,total_cases ,new-cases, total_deaths , population
from coviddeaths
order by 1,2

-- looking at the total cases vs total deaths 
-- shows likelihood of dying if you contract covid in your country
select location, date ,total_cases , total_deaths , (total_deaths/total_cases)*100 as Deathpresentage
from coviddeaths
where location like '%egypt%'
and continent is not null 
order by 1,2


-- looking at the total cases vs the population 
-- shows what percentage of populatopn got in covid
select location, date ,population , total_cases , (total_cases/population)*100 as percentageofpopulationinfected
from coviddeaths
where location like '%egypt%'
order by 1,2


-- looking at countries with higher infection rate compared to population 

select location, population , max(total_cases) highestinfectioncount , MAX((total_cases/population))*100 as percentageofpopulationinfected
from coviddeaths
--where location like '%egy%'
group by location, population
order by percentageofpopulationinfected desc


-- showing countries with the highest death count per population 

select location , max(total_deaths) as totaldeathcount
--where location like '%egy%'
from coviddeaths
where continent is not null
group by location
order by totaldeathcount desc

-- let's break things down by continent

select continent , max(total_deaths) as totaldeathcount
--where location like '%egy%'
from coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc

-- showing the continent with the highest death count 

select continent , max(total_deaths) as totaldeathcount
--where location like '%egy%'
from coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc

-- Global numbers 

select  sum(new_cases)as totalcases, sum(new_deaths) as totaldeaths, sum(new_deaths)/sum(new_cases)*100  as dathpersentage -- total_deaths , (total_deaths/total_cases)*100 as Deathpresentage
from coviddeaths
-- where location like '%egypt%'
where continent is not null and new_cases <> 0 
-- group by date
order by 1,2


-- looking at total population vs total vaccinations

select cd.continent, cd.location , cd.date, cd.population , cv.new_vaccinations, sum(convert(float,new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as rolling_ppl_vaccinations
--,(rolling_ppl_vaccinations/population)*100
from coviddeaths cd
join covidvacsination cv
     on cd.location =cv.location
     and cd.date = cv.date
where cd.continent is not null 
order by 2,3


-- CTE 

with popvsvac (continent,location,date,population,new_vaccinations,rolling_ppl_vaccinations)
as
(
select cd.continent, cd.location , cd.date, cd.population , cv.new_vaccinations, sum(convert(float,new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as rolling_ppl_vaccinations
--,(rolling_ppl_vaccinations/population)*100
from coviddeaths cd
join covidvacsination cv
     on cd.location =cv.location
     and cd.date = cv.date
where cd.continent is not null 
--order by 2,3
)
select *,(rolling_ppl_vaccinations/population)*100
from popvsvac

-- temp table 
drop table if exists #percentpopulationvaccinaated
create table #percentpopulationvaccinaated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_ppl_vaccinations numeric 
)

insert into  #percentpopulationvaccinaated
select cd.continent, cd.location , cd.date, cd.population , cv.new_vaccinations, sum(convert(float,new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as rolling_ppl_vaccinations
--,(rolling_ppl_vaccinations/population)*100
from coviddeaths cd
join covidvacsination cv
     on cd.location =cv.location
     and cd.date = cv.date
--where cd.continent is not null 
--order by 2,3

select *,(rolling_ppl_vaccinations/population)*100 as total_vaccination_percentage
from  #percentpopulationvaccinaated


-- create view to store data for later visualizatioms

create view percentpopulationvaccinaated as
select cd.continent, cd.location , cd.date, cd.population , cv.new_vaccinations, sum(convert(float,new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as rolling_ppl_vaccinations
--,(rolling_ppl_vaccinations/population)*100
from coviddeaths cd
join covidvacsination cv
     on cd.location =cv.location
     and cd.date = cv.date
where cd.continent is not null 
--order by 2,3

select *
from percentpopulationvaccinaated