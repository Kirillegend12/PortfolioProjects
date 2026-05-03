## Loading Data

# As the data was not loading trough regular 'Import' option, we created a separate Table and uploaded data using LOAD DATA LOCAL in order to do this

# Tip: regulary this option is restricted, in order to enable it, use: 'SET GLOBAL local_infile = 1'

CREATE TABLE covid_deaths 
(
iso_code TEXT,
continent TEXT,
location TEXT,
`date`  DATE,	
population	INT,
total_cases	INT,
new_cases INT,
new_cases_smoothed	INT,
total_deaths INT,	
new_deaths	INT,
new_deaths_smoothed	FLOAT,
total_cases_per_million	FLOAT,
new_cases_per_million	FLOAT,
new_cases_smoothed_per_million	FLOAT,
total_deaths_per_million	FLOAT,
new_deaths_per_million	FLOAT,
new_deaths_smoothed_per_million	FLOAT,
reproduction_rate	FLOAT,
icu_patients	FLOAT,
icu_patients_per_million	FLOAT,
hosp_patients	FLOAT,
hosp_patients_per_million	FLOAT,
weekly_icu_admissions	FLOAT,
weekly_icu_admissions_per_million	FLOAT,
weekly_hosp_admissions	FLOAT,
weekly_hosp_admissions_per_million FLOAT

);


LOAD DATA LOCAL INFILE 'C:/Users/Kiril/Desktop/SQL/Guided Project/CovidDeaths.csv'
INTO TABLE covid_deaths
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SET GLOBAL local_infile = 1;

SELECT COUNT(*)
FROM covid_deaths;

CREATE TABLE covid_vacination
(
iso_code TEXT,	
continent	TEXT,
location	TEXT,
`date`	TEXT,
new_tests INT,
total_tests INT,
total_tests_per_thousand FLOAT,
new_tests_per_thousand	FLOAT,
new_tests_smoothed	INT,
new_tests_smoothed_per_thousand	FLOAT,
positive_rate FLOAT,
tests_per_case	FLOAT,
tests_units TEXT,
total_vaccinations	INT,
people_vaccinated	INT,
people_fully_vaccinated	INT,
new_vaccinations	INT,
new_vaccinations_smoothed	INT,
total_vaccinations_per_hundred	INT,
people_vaccinated_per_hundred	FLOAT,
people_fully_vaccinated_per_hundred	FLOAT,
new_vaccinations_smoothed_per_million	INT,
stringency_index FLOAT,
population_density	FLOAT,
median_age	FLOAT,
aged_65_older	FLOAT,
aged_70_older	FLOAT,
gdp_per_capita	FLOAT,
extreme_poverty	FLOAT,
cardiovasc_death_rate	FLOAT,
diabetes_prevalence	FLOAT,
female_smokers	FLOAT,
male_smokers	FLOAT,
handwashing_facilities	FLOAT,
hospital_beds_per_thousand	FLOAT,
life_expectancy	FLOAT,
human_development_index FLOAT

);

LOAD DATA LOCAL INFILE "C:/Users/Kiril/Desktop/SQL/Guided Project/Covid Vacinations.csv"
INTO TABLE covid_vacination
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE covid_deaths;

TRUNCATE TABLE covid_vacination;


# Accidentaly created a table with inproper naming, so let's change it.

RENAME TABLE covid_vacations TO covid_vacination;

## The data was successfully uploaded to the Database 

SELECT * 
FROM covid_deaths
ORDER BY 3,4;

SELECT * 
FROM covid_vacination;

ALTER TABLE covid_deaths
MODIFY `date` TEXT;

ALTER TABLE covid_vacination
MODIFY `date` TEXT;



-- During the uploading process, I have faced issues with the 'Date` column. When was converted to Date format is was strangly translated, and was not representing the exact date.

-- In order to solve this issue, we need to change the format and use the commamd STR_TO_DATE(you_date, your_format) in order to deal with it.


SELECT STR_TO_DATE(`date`, '%d.%m.%Y')
FROM covid_deaths;

ALTER TABLE covid_deaths
ADD COLUMN date2 DATE;

ALTER TABLE covid_vacination 
ADD COLUMN date2 DATE;


UPDATE covid_deaths 
SET date2 = STR_TO_DATE(`date`, '%d.%m.%Y');

UPDATE covid_vacination
SET date2 = STR_TO_DATE(`date`, '%d.%m.%Y');

ALTER TABLE covid_vacination
DROP COLUMN `date`;

ALTER TABLE covid_deaths
DROP COLUMN `date`;

SELECT `date`, date2
FROM covid_vacination;

ALTER TABLE covid_deaths
RENAME COLUMN date2 to `date`;

ALTER TABLE covid_vacination 
RENAME COLUMN date2 to `date`;

ALTER TABLE covid_vacination
RENAME COLUMN date2 to `date`;

-- The problem with the date is fixed 


