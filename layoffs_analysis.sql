-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

-- Identify maxes
SELECT 
	MAX(total_laid_off) AS max_total_laid_off, 
    MAX(percentage_laid_off) AS max_percentage_laid_off
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- look at total layoffs per company
SELECT 
	company, 
    SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT 
	company, 
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Inspect date trends
SELECT 
	MIN(`date`) AS min_date,
	MAX(`date`) AS max_date
FROM layoffs_staging2;

SELECT 
	MONTH(`date`) AS 'month', 
	YEAR(`date`) AS 'year', 
    SUM(total_laid_off) AS sum_total_laid_off, 
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY MONTH(`date`), YEAR(`date`)
ORDER BY 1, 2;

SELECT 
	`date`, 
    total_laid_off, 
    percentage_laid_off
FROM layoffs_staging2
WHERE YEAR(`date`) = 2020 AND MONTH(`date`) IN (3, 4) -- COVID-19 quarantine start in the U.S.
ORDER BY 2 DESC;

SELECT 
	MONTH(`date`) as month, 
    YEAR(`date`) as year, 
    COUNT(*) as layoffs_frequency
from layoffs_staging2
GROUP BY MONTH(`date`), YEAR(`date`)
ORDER BY 3 DESC;

-- Inspect industry, country, and stage
SELECT 
	industry, 
	SUM(total_laid_off) AS sum_total_laid_off, 
	AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT 
	country, 
    SUM(total_laid_off) AS sum_total_laid_off, 
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT 
	stage, 
    SUM(total_laid_off) AS sum_total_laid_off, 
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- rolling sum layoffs
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `month`, 
SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT 
	`month`, 
    total_off,
	SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_Total;

SELECT 
	company, 
	YEAR(`date`) AS `year`, 
	SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT 
	company, 
    YEAR(`date`), 
    SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT 
	*, 
    DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5
;
