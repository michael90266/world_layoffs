-- Data Cleaning
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns or Rows

SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Identify duplicates
SELECT 
	*, 
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, 
	percentage_laid_off, `date`, stage, country, 
	funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
	(
    SELECT *, 
		ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, 
		percentage_laid_off, `date`, stage, country, 
		funds_raised_millions) AS row_num
	FROM layoffs_staging
	)
SELECT *
FROM duplicate_cte
WHERE row_num > 1
;

-- Copy and paste create statement from `layoffs_staging` to create `layoffs_staging2` and add 'row_num' column.
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

INSERT INTO layoffs_staging2
SELECT 
	*, 
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, 
	percentage_laid_off, `date`, stage, country, 
	funds_raised_millions) AS row_num
FROM layoffs_staging
;

-- Remove duplicates
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing Data
-- Identify and adjust discrepancies in `company` column
SELECT 
	company, 
    TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Identify and adjust discrepancies in `industry` column
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Search for discrepancies in `location` column
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

-- Identify and adjust discrepancies in `country` column
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT 
	DISTINCT country, 
    TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Format `date` column
SELECT 
	`date`,
	STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Identify NULL values in `industry` column
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Update empty cells in `industry` column to match non-empty cells conditioned when company and location are the same
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Consolidate by setting blanks to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Investigate one NULL remaining
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';
-- Only 1 row; no industry to match

-- Locate and delete NULL cells in both `total_laid_off` and `percentage_laid_off` columns
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Drop the `row_num` column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;