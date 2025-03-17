-- Data Cleaning

select *
from layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null values or Blank values
-- 4. Remove unnecessary columns or rows (Caution /!\)


CREATE TABLE  layoffs_staging
LIKE layoffs;

select *
from layoffs_staging;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

-- 1. Remove Duplicates:
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) row_num
FROM layoffs_staging; 

WITH Duplicates_CTE as
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) row_num
FROM layoffs_staging
)
SELECT *
FROM Duplicates_CTE
WHERE row_num > 1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2;

INSERT layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off
, `date`, stage, country, funds_raised_millions) row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;


-- 2. Standardize the Data
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT(industry)
from layoffs_staging2
order by 1;

UPDATE layoffs_staging2
SET industry = "Crypto"
where industry LIKE 'Crypto%';

select *
from layoffs_staging2;

SELECT DISTINCT(location)
FROM layoffs_staging2
WHERE REGEXP_LIKE(location, 'Ã³|Ã¼|Ã¶');

-- Ó = Ã³
-- ü = Ã¼
-- ö = Ã¶

UPDATE layoffs_staging2
SET location = CASE
	WHEN location LIKE '%Ã³%' THEN REPLACE(location, 'Ã³','Ó')
	WHEN location LIKE '%Ã¼%' THEN REPLACE(location, 'Ã¼', 'ü')
    WHEN location LIKE '%Ã¶%' THEN REPLACE(location, 'Ã¶', 'ö')
    ELSE location
END
WHERE location REGEXP 'Ã³|Ã¼|Ã¶';

SELECT DISTINCT(location)
FROM layoffs_staging2
WHERE REGEXP_LIKE(location, 'Ã³|Ã¼|Ã¶');

SELECT DISTINCT(location)
FROM layoffs_staging2
order by 1;

SELECT DISTINCT(country)
FROM layoffs_staging2
order by 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
order by 1;

UPDATE layoffs_staging2
SET country=TRIM(TRAILING '.' FROM country);
 
SELECT DISTINCT(country)
FROM layoffs_staging2
order by 1;

SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT * 
FROM layoffs_staging2;

SELECT DISTINCT(stage)
from layoffs_staging2
order by 1;

-- 3. Null values or Blank values

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off is NULL;

SELECT * 
from layoffs_staging2
WHERE industry is NULL or industry = '';

SELECT *
from layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.company, t1.location, t1.industry,
t2.company, t2.location, t2.industry
From layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
WHERE (t1.industry is NULL or t1.industry='')
AND t2.industry IS NOT NULL and t2.industry !='';

UPDATE layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry is NULL or t1.industry = '')
AND t2.industry IS NOT NULL and t2.industry !='';

-- 4. Remove unnecessary columns or rows (Caution /!\)
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off is NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off is NULL;

Select *
from layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

Select *
from layoffs_staging2;

-- CONGRATS ! OUR DATASET IS CLEAN !