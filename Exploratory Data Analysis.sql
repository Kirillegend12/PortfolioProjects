-- In this section we are goind to select the data we are going to explore.

-- During the exploration of the dataset, it turned out, that Location was also standing as a continent, where continent is NUll 

-- Let's transform the continent missing values, from Blank to NULL

UPDATE covid_deaths 
SET continent = NULL 
WHERE continent = '';

SELECT Location, continent, `date`, new_cases,total_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NULL
ORDER BY location ,`date` ASC;


-- Likelyhood of dying in Poland, as of 2020-2021 
SELECT location, `date`, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as percentage_of_deaths
FROM covid_deaths
WHERE location like 'Poland';


-- Looking at Total Cases vs Population 

SELECT location, `date`, total_cases, total_deaths, population, ROUND((total_cases/population)*100,2) as Infected_percentage
FROM covid_deaths
WHERE location like 'Poland';

-- Which countries has the highest infection rates 

SELECT location, population, MAX(total_cases) as Highest_cases_count, ROUND(MAX((total_cases/population) * 100),2) as PercentageInfected
FROM covid_deaths
GROUP BY location, population
ORDER BY ROUND(MAX((total_cases/population)),2) DESC;


-- Let's break things down by continet 

SELECT continent, SUM(total_deaths) as total_count_deaths
FROM covid_deaths 
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY SUM(total_deaths) DESC;

SELECT location, MAX(total_deaths) as total_count_deaths
FROM covid_deaths 
WHERE continent IS  NULL
GROUP BY location 
ORDER BY MAX(total_deaths) DESC;


-- Showing countries with the highest death count per population  !!!!

SELECT location, MAX(total_deaths) as Total_count
FROM covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY MAX(total_deaths) DESC;

-- Checking if the World = equals other continents sum 

with cte as (
SELECT location, MAX(total_deaths) as total_count, (SELECT MAX(total_deaths) from covid_deaths WHERE location = 'World' and continent is null) as world_total, 
(SELECT MAX(total_deaths) from covid_deaths WHERE location = 'International' and continent is null) as international_total
FROM covid_deaths 
WHERE continent is null
and location != 'World'  and location != 'European Union'
GROUP BY location
)
SELECT SUM(total_count) as Total_Continent, MAX(world_total) as World_
FROM cte;


-- More polished version of the query above 

WITH continent_totals AS (
    SELECT 
        location,
        MAX(total_deaths) AS total_count
    FROM covid_deaths
    WHERE continent IS NULL
      AND location NOT IN ('World', 'European Union')
    GROUP BY location
)

SELECT 
    SUM(total_count) AS total_continents,
    
    (SELECT MAX(total_deaths) 
     FROM covid_deaths 
     WHERE location = 'World' 
       AND continent IS NULL)
       
       
    AS world_plus_international
FROM continent_totals;




-- The most deaths per continent 

SELECT continent, MAX(total_deaths) as Total_count
FROM covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY MAX(total_deaths) DESC;


-- Showing continents with the highest deaths count per population 

SELECT continent, MAX(total_deaths)/MAX(population) * 100 as death_percentage
FROM covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY MAX(total_deaths)/MAX(population) * 100 DESC;


-- Global Numbers 

SELECT `date`, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, ROUND(SUM(new_deaths)/SUM(new_cases) * 100,2) as death_percentage
FROM covid_deaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2;


-- Looking at total population vs vacination 

SELECT dea.continent,SUM(dea.population) as global_population, MAX(vac.total_vaccinations) as total_vacinations
FROM covid_deaths dea
join covid_vacination vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.continent;


-- Total amount of cases 

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM covid_deaths dea
join covid_vacination vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null and dea.location = 'Canada'
ORDER BY 1,2,3;

-- USE CTE 

with PopvsVac (Continent, Location,Date,  Population, New_Vaccinations, Rolling_people_vaccinated)
 as
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM covid_deaths dea
join covid_vacination vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 1,2,3
)
SELECT *, Rolling_people_vaccinated/Population * 100 as percentage_of_vaccinated_population
FROM PopvsVac;


-- Nested SELECT Statements 

SELECT *, rolling_people_vaccinated/population * 100 as percentage_of_vaccinated_population 
FROM 
(
SELECT dea.continent, dea.location, dea.date,dea.population as population, vac.new_vaccinations,
SUM(vac.new_vaccinations)OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM covid_deaths dea
join covid_vacination vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
) as PopvsVac;


-- Temp Table 

-- IN case you want to freely update the table

DROP TABLE if exists PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Continent VARCHAR(255),
 Location VARCHAR(255),
 Date date,  
 Population int, 
 New_Vaccinations int, 
 Rolling_people_vaccinated int
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population as population, vac.new_vaccinations,
SUM(vac.new_vaccinations)OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM covid_deaths dea
join covid_vacination vac
ON dea.location = vac.location
and dea.date = vac.date;
-- WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT *, Rolling_people_vaccinated/Population * 100 as percentage_of_vaccinated_population
FROM PercentPopulationVaccinated;


-- Creating View to store data for visualizations

CREATE VIEW PopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date,dea.population as population, vac.new_vaccinations,
SUM(vac.new_vaccinations)OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM covid_deaths dea
join covid_vacination vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null;
-- ORDER BY 2,3


CREATE VIEW Deaths_by_Continent as 
SELECT continent, SUM(total_deaths) as total_count_deaths
FROM covid_deaths 
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY SUM(total_deaths) DESC;


CREATE VIEW Vaccinated_Population as
SELECT dea.continent,SUM(dea.population) as global_population, MAX(vac.total_vaccinations) as total_vacinations
FROM covid_deaths dea
join covid_vacination vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.continent;

CREATE VIEW Deaths_by_date as
SELECT `date`, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, ROUND(SUM(new_deaths)/SUM(new_cases) * 100,2) as death_percentage
FROM covid_deaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2;