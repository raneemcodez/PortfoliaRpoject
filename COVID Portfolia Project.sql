SELECT *
FROM coviddeaths
WHERE continent is NOT NULL
order by  3, 4 ;
#
# SELECT *
# FROM covidvaccinations
# order by 3 ,4

#Select data that we are going to be using
SELECT location , date , total_cases ,new_cases, total_deaths ,population
FROM PortfoliaProject.coviddeaths
order by 1 ,2 ;

#looking at total cases vs total deaths
#Show likelihood of dying if you contract covid in your city
SELECT location , date , total_cases, total_deaths , (total_deaths / total_cases)*100 as DeathPercentage
FROM PortfoliaProject.coviddeaths
WHERE location like '%states%'
AND continent is NOT NULL
ORDER BY 1, 2 DESC;




#looking at total cases vs population
#Shows what percentage of population got covid
SELECT location , date ,population, total_cases , (total_cases / population)*100 as PresentPopulationInfected
FROM PortfoliaProject.coviddeaths
#WHERE location like '%states%'
ORDER BY 1, 2;


#Looking at Countries with Highest Infection Rate Compare to population
SELECT location  ,population, Max(total_cases) as HighestInfectionCount , Max((total_cases / population))*100 as PresentPopulationInfected
FROM PortfoliaProject.coviddeaths
#WHERE location like '%syria%'
GROUP BY location , population
ORDER BY PresentPopulationInfected DESC ;

#Showing Countries with Highest Death count with population
SELECT location , MAX(cast( total_deaths as int )) as TotalDeathCount
FROM PortfoliaProject.coviddeaths
#WHERE location like '%syria%'
GROUP BY location
ORDER BY TotalDeathCount DESC ;



#Let's break things down by Continent
SELECT continent , MAX(cast( total_deaths as int )) as TotalDeathCount
FROM PortfoliaProject.coviddeaths
#WHERE location like '%syria%'
Where continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC ;

#Showing Continents with the highest death count with per population
SELECT continent , MAX(cast( total_deaths as int )) as TotalDeathCount
FROM PortfoliaProject.coviddeaths
#WHERE location like '%syria%'
Where continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC ;


#GLOBAL NUMBERS
SELECT  SUM(new_cases) AS TotalCases , SUM(new_deaths) AS TotalDeathes ,
        (SUM(new_cases) / SUM(new_deaths))*100 as DeathPercentage
FROM PortfoliaProject.coviddeaths
#WHERE location like '%states%'
WHERE continent is NOT NULL
#Group By date
ORDER BY 1, 2  ;


#Looking at Total population vs Vaccinations
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
       SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location ,
       dea.date) AS RollingPeopleVaccinated
FROM PortfoliaProject.coviddeaths AS dea
JOIN PortfoliaProject.covidvaccinations AS vac
     ON dea.date = vac.date
     AND dea.location = vac.location
WHERE dea.continent is NOT NULL
order by 2 ,3;



#USE CTE
With PopvsVac (continent , location , date , population , new_vaccinations , RollingPeopleVaccinated )
as (SELECT dea.continent,
           dea.location,
           dea.date,
           dea.population,
           vac.new_vaccinations,
           SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location ,
       dea.date) AS RollingPeopleVaccinated
    FROM PortfoliaProject.coviddeaths AS dea
             JOIN PortfoliaProject.covidvaccinations AS vac
                  ON dea.date = vac.date
                      AND dea.location = vac.location
    WHERE dea.continent is NOT NULL )
SELECT * , (RollingPeopleVaccinated/population)*100
From PopvsVac;


#Temp Table
DROP TABLE IF EXISTS PercentPopulationVaccenated
CREATE TEMPORARY TABLE PercentPopulationVaccenated
(
    continent nvarchar(255) ,
    location nvarchar(255),
    Date DATETIME ,
    Population numeric ,
    new_Vaccinations numeric,
    RollingPeopleVaccinated numeric
)
INSERT INTO PercentPopulationVaccenated
SELECT dea.continent,
           dea.location,
           dea.date,
           dea.population,
           vac.new_vaccinations,
           SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location ,
       dea.date) AS RollingPeopleVaccinated
    FROM PortfoliaProject.coviddeaths AS dea
             JOIN PortfoliaProject.covidvaccinations AS vac
                  ON dea.date = vac.date
                      AND dea.location = vac.location
    WHERE dea.continent is NOT NULL;

SELECT * , (RollingPeopleVaccinated/population)*100
From PercentPopulationVaccenated;


#Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccenated as
SELECT dea.continent,
           dea.location,
           dea.date,
           dea.population,
           vac.new_vaccinations,
           SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location ,
       dea.date) AS RollingPeopleVaccinated
    FROM PortfoliaProject.coviddeaths AS dea
             JOIN PortfoliaProject.covidvaccinations AS vac
                  ON dea.date = vac.date
                      AND dea.location = vac.location
    WHERE dea.continent is NOT NULL;

SELECT *
FROM PercentPopulationVaccenated




