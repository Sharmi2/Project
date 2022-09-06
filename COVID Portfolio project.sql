
SELECT *
FROM portfolioproject ..Covid_Deaths
ORDER by 3,4

--SELECT *
--FROM portfolioproject ..Covid_Vaccinations
--ORDER by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject ..Covid_Deaths
ORDER by 1,2

-- total cases vs total deaths countrywise
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM portfolioproject ..Covid_Deaths
ORDER by 1,2

--total cases vs population for India
SELECT location, date, population,total_cases, (total_cases/population)*100 AS Cases_Percentage
FROM portfolioproject ..Covid_Deaths
WHERE location like 'India'
ORDER by 1,2

SELECT location, population, MAX(total_cases) AS Highest_Cases_Count, MAX((total_cases/population)*100) AS Percentage_Infected
FROM portfolioproject ..Covid_Deaths
GROUP BY location, population
ORDER by Percentage_Infected desc

--Countries with Highest Death Count
SELECT location, population, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM portfolioproject ..Covid_Deaths
WHERE continent is not null
GROUP BY location, population
ORDER by TotalDeathCount desc

-- Displaying no of deaths in each continent
SELECT continent, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM portfolioproject ..Covid_Deaths
WHERE continent is not null
GROUP BY continent
ORDER by TotalDeathCount desc

--Global Data datewise
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS bigint)) AS total_deaths, SUM(cast(new_deaths AS bigint))/SUM(new_cases)*100 AS Death_Percentage
FROM portfolioproject ..Covid_Deaths
WHERE continent is not null
GROUP BY date
ORDER by 1,2

--Percentage of Covid Deaths till 3rd September 2022 globally
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS bigint)) AS total_deaths, SUM(cast(new_deaths AS bigint))/SUM(new_cases)*100 AS Death_Percentage
FROM portfolioproject ..Covid_Deaths
WHERE continent is not null
ORDER by 1,2

-- Displaying total population vs Vaccinations
SELECT codeath.continent, codeath.location, codeath.date, codeath.population, covacc.new_vaccinations, SUM(cast(covacc.new_vaccinations AS bigint))
OVER (PARTITION BY codeath.location ORDER BY codeath.location, codeath.date) AS Vax_Till_Date
FROM portfolioproject ..Covid_Deaths as codeath JOIN portfolioproject ..Covid_Vaccinations as covacc
ON codeath.location=covacc.location AND codeath.date=covacc.date
WHERE codeath.continent is not null
ORDER by 2,3

--Using CTE to calculate percentage of people vaccinated in India (The % is greater than 100 towards the end as double vaccinations have also been included in this data)
WITH PopulationVSVax(Continent, Location, Date, Population, New_Vaccinations, Vax_Till_Date)
as
(
SELECT codeath.continent, codeath.location, codeath.date, codeath.population, covacc.new_vaccinations, SUM(cast(covacc.new_vaccinations AS bigint))
OVER (PARTITION BY codeath.location ORDER BY codeath.location, codeath.date) AS Vax_Till_Date
FROM portfolioproject ..Covid_Deaths as codeath JOIN portfolioproject ..Covid_Vaccinations as covacc
ON codeath.location=covacc.location AND codeath.date=covacc.date
WHERE codeath.continent is not null
)
SELECT *, (Vax_Till_Date/Population)*100 AS VaxPercentage 
FROM PopulationVSVax
WHERE Location like 'INDIA'


-- Create a view to sotre data for later analysis
CREATE VIEW PopulationVSVax as 
SELECT codeath.continent, codeath.location, codeath.date, codeath.population, covacc.new_vaccinations, SUM(cast(covacc.new_vaccinations AS bigint))
OVER (PARTITION BY codeath.location ORDER BY codeath.location, codeath.date) AS Vax_Till_Date
FROM portfolioproject ..Covid_Deaths as codeath JOIN portfolioproject ..Covid_Vaccinations as covacc
ON codeath.location=covacc.location AND codeath.date=covacc.date
WHERE codeath.continent is not null
