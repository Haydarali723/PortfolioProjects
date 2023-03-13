SELECT * FROM CovidVaccinations
SELECT * FROM CovidDeaths
SELECT  C.NAME AS SCHEMANAME,
    A.NAME AS TBL, 
    B.NAME AS CLM FROM sys.tables
A INNER JOIN sys.columns B
ON A.object_id=B.object_id
INNER JOIN sys.schemas C
ON A.schema_id=C.schema_id
WHERE B.name LIKE '%death%'

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
where location like '%uzb%'
order by 1,2

SELECT location,date,population,total_cases,(total_cases/population)*100 as InfectionPercantage
FROM CovidDeaths
where location like '%uzb%'
order by 1,2

select  location,MAX(cast(total_deaths as int)) as TotalDeath
from CovidDeaths
where continent is not null
group by location
order by TotalDeath desc


select location,
MAX(cast(total_deaths as int)) as TotalDeath
from CovidDeaths
where continent is null
group by location


select DATE,
SUM(new_cases) as NewCases,
SUM(cast(new_deaths as int)) as Death,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS GlobalDeathPercentage
from CovidDeaths
where continent is null and new_cases!=0
group by date
order by 1,2

select
SUM(new_cases) as NewCases,
SUM(cast(new_deaths as int)) as Death,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS GlobalDeathPercentage
from CovidDeaths  
where continent is null and new_cases!=0
order by 1,2


with PopVsVac(Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(v.new_vaccinations) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from CovidVaccinations v
join CovidDeaths d 
on v.date=d.date
and v.location=d.location
where d.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100
from PopVsVac

create view vw_PopVsVac
as 
with PopVsVac(Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(v.new_vaccinations) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from CovidVaccinations v
join CovidDeaths d 
on v.date=d.date
and v.location=d.location
where d.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100
from PopVsVac
)
