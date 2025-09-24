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

-- total layoffs and average percentage layoffs per month and year
SELECT 
	MONTH(`date`) AS 'month', 
	YEAR(`date`) AS 'year', 
    SUM(total_laid_off) AS sum_total_laid_off, 
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY MONTH(`date`), YEAR(`date`)
ORDER BY 2, 1;

-- Layoffs when COVID-19 quarantine began in the U.S.
SELECT 
	`date`, 
    total_laid_off, 
    percentage_laid_off
FROM layoffs_staging2
WHERE YEAR(`date`) = 2020 AND MONTH(`date`) IN (3, 4) 
ORDER BY 2 DESC;

-- layoff frequency per month and year
SELECT 
	MONTH(`date`) as month, 
    YEAR(`date`) as year, 
    COUNT(*) as layoffs_frequency
from layoffs_staging2
GROUP BY MONTH(`date`), YEAR(`date`)
ORDER BY 3 DESC;

-- Inspect industry, country, and stage
-- total layoffs and average percentage layoffs per industry
SELECT 
	industry, 
	SUM(total_laid_off) AS sum_total_laid_off, 
	AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- total layoffs and average percentage layoffs per country
SELECT 
	country, 
    SUM(total_laid_off) AS sum_total_laid_off, 
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- total layoffs and average percentage layoffs per stage
SELECT 
	stage, 
    SUM(total_laid_off) AS sum_total_laid_off, 
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- rolling sum layoffs
WITH Rolling_Total AS
(
	SELECT 
		SUBSTRING(`date`,1,7) AS `month`, 
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

-- Rankings
-- Top 5 companies with the most layoffs per year
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

-- Top 5 stages with the most layoffs per year
WITH Stage_Year (stage, years, total_laid_off) AS
(
	SELECT 
		stage, 
		YEAR(`date`) AS `year`, 
		SUM(total_laid_off) AS sum_total_laid_off
	FROM layoffs_staging2
	GROUP BY stage, YEAR(`date`)
), Stage_Year_Rank AS
(
	SELECT 
		*, 
		DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
	FROM Stage_Year
	WHERE years IS NOT NULL
)
SELECT *
FROM Stage_Year_Rank
WHERE ranking <= 5
;

-- Top 5 industries with the most layoffs per year
WITH Industry_Year (industry, years, total_laid_off) AS
(
	SELECT 
		industry, 
		YEAR(`date`) AS `year`, 
		SUM(total_laid_off) AS sum_total_laid_off
	FROM layoffs_staging2
	GROUP BY industry, YEAR(`date`)
), Industry_Year_Rank AS
(
	SELECT 
		*, 
		DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
	FROM Industry_Year
	WHERE years IS NOT NULL
)
SELECT *
FROM Industry_Year_Rank
WHERE ranking <= 5
;

-- Top 5 countries with the most layoffs per year
WITH Country_Year (country, years, total_laid_off) AS
(
	SELECT 
		country, 
		YEAR(`date`) AS `year`, 
		SUM(total_laid_off) AS sum_total_laid_off
	FROM layoffs_staging2
	GROUP BY country, YEAR(`date`)
), Country_Year_Rank AS
(
	SELECT 
		*, 
		DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
	FROM Country_Year
	WHERE years IS NOT NULL
)
SELECT *
FROM Country_Year_Rank
WHERE ranking <= 5
;

-- Inspect date trends closer
-- Date with highest layoffs per country
WITH Date_Ranking AS (
	SELECT
		SUBSTRING(`date`,1,7) AS `date`,
        country,
        SUM(total_laid_off) AS sum_total_laid_off,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY SUM(total_laid_off) DESC)
        AS rn
	FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY country, SUBSTRING(`date`,1,7)
)
SELECT country, `date`, sum_total_laid_off
FROM Date_Ranking
WHERE rn = 1;



SELECT *
FROM layoffs_staging2;