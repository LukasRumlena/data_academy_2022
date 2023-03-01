-- question 3--

CREATE OR REPLACE VIEW v_food_prices AS
SELECT 
	YEAR (date_from),
	category_code,
	name,
	value1,
	LEAD (value1,1) OVER (PARTITION BY category_code ORDER BY category_code, YEAR (date_from)) next_value,
	ROUND ((((LEAD (value1,1) OVER (PARTITION BY category_code  ORDER BY category_code, YEAR (date_from))) - value1) / value1) * 100,2) price_growth
FROM t_lukas_rumlena_project_SQL_primary_final
WHERE region_code IS NULL
GROUP BY category_code, YEAR (date_from)
;
			
SELECT 
	category_code, 
	name, 
	SUM (price_growth), 
	AVG (price_growth)
FROM v_food_prices
GROUP BY category_code
ORDER BY AVG (price_growth)
;
