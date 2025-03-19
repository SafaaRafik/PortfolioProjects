-- Exploratory Data Analysis

 SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off) as Max_layoffs, MAX(percentage_laid_off) Max_percentage
from layoffs_staging2;
-- percentage_laid_off = 1 means 100% of the employees got laid off !

 SELECT *
FROM layoffs_staging2
Where percentage_laid_off =1
order by total_laid_off DESC
;

 SELECT *
FROM layoffs_staging2
Where percentage_laid_off =1
order by funds_raised_millions DESC
;

 SELECT YEAR(`date`), company, total_laid_off, percentage_laid_off,country, location, funds_raised_millions
FROM layoffs_staging2
order by YEAR(`date`) DESC, total_laid_off DESC
;

SELECT company, sum(total_laid_off)
FROM layoffs_staging2
group by company
order by 2 DESC
;

select min(`date`), max(`date`)
from layoffs_staging2;
-- min date: 2020-03-11 (right after the pandemic has started)
-- max date: 2023-03-06 (The dataset covers kinda up to three years)

Select sum(total_laid_off) Layoffs_20_23
from layoffs_staging2;
-- 383659 employees got laid-off from March 2020 to March 2023

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 DESC;
-- Whitin the TOP 10 : Consumer, Retail, Transportation, Food, Travel, Education 
-- (Logical since those industries shut down during the pandemic)

 SELECT *
FROM layoffs_staging2;

SELECT country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 DESC;
-- TOP 5 : US (256559), India (35993), Netherlands, Sweden, Brazil

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 DESC;
-- Companies in the stage of Post-IPO are the ones who laid most employees off (which are the most sable ones)

Select YEAR(`date`) as `YEAR` ,sum(total_laid_off) layoffs_per_month
from layoffs_staging2
group by  `YEAR`
order by  `YEAR` DESC
;
-- 2022 was the worst year, where up to 160661 employees got laid-off in the whole world.
-- And what's more surprising is that the year 2023 recorded up to 125k layoffs in the world while the records only covered three months of the year (only till March), which is immense !


Select substr(`date`,1,7) as MONTH_OF_YEAR ,sum(total_laid_off) layoffs_per_month
from layoffs_staging2
where  substr(`date`,1,7) is not null
group by MONTH_OF_YEAR
order by MONTH_OF_YEAR
;

with rolling_total as
(
Select substr(`date`,1,7) as MONTH_OF_YEAR ,sum(total_laid_off) as total_off
from layoffs_staging2
where  substr(`date`,1,7) is not null
group by MONTH_OF_YEAR
order by MONTH_OF_YEAR
)
select MONTH_OF_YEAR, total_off, sum(total_off) over(order by MONTH_OF_YEAR)
from rolling_total;

with company_year as
(
SELECT company, YEAR(`date`) as years, sum(total_laid_off) total_off
FROM layoffs_staging2
group by company,  YEAR(`date`)
),
company_year_rank as
(
select company, years, 
dense_rank() over(partition by years order by total_off desc) as ranking
from company_year
where years is not null
)
select *
from company_year_rank
where ranking <= 5
;
-- TOP 5 companies that laid employees off the most, partitioned by years

select * 
from layoffs_staging2;

with funds_country_layoff as
(
select country, sum(funds_raised_millions) total_funds_country, sum(total_laid_off) total_off
from layoffs_staging2
group by country
)
select country, total_funds_country, dense_rank() over(order by total_funds_country desc) as ranking_funds, total_off,
dense_rank() over(order by total_off desc) as ranking_layoffs
from funds_country_layoff;
-- Comparing the countries based on their funds and their total layoffs




