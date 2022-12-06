CREATE OR REPLACE table t_lukas_rumlena_project_SQL_secondary_final AS
SELECT
	country,
	`year` bacic_year,
	`year` + 1 next_year,
	GDP basic_GDP,
	LEAD (GDP,1) OVER (PARTITION BY country ORDER BY country, `year`) next_GDP,
	round((((LEAD (GDP,1) OVER (PARTITION BY country ORDER BY country, `year`))-GDP) / GDP ) * 100,2) GDP_growth
FROM 
	economies
WHERE
	GDP is not NULL
ORDER BY
	country , `year`;