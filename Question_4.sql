-- question 4--

CREATE OR REPLACE VIEW v_food_vs_wage_year_to_year AS
SELECT
	payroll_year basic_year,
	payroll_year+1 next_year,
	value basic_value,
	LEAD (value,1) OVER (ORDER BY payroll_year) next_value,
	round ((((LEAD (value,1) OVER (ORDER BY payroll_year)) - value) / value) * 100,2) payroll_growth
FROM t_lukas_rumlena_project_SQL_primary_final  
WHERE value_type_code = 5958
GROUP BY payroll_year
;

SELECT 
	yty.basic_year measure_period,
	yty.next_year average_wage,
	ROUND (AVG (fp.price_growth),2) average_price_food,	
	ROUND (AVG (fp.price_growth),2) - payroll_growth grown_food_price_value 
FROM v_food_vs_wage_year_to_year yty
RIGHT JOIN	v_food_prices fp
ON yty.basic_year  = fp.`YEAR (date_from)` 
GROUP BY yty.basic_year 
ORDER BY grown_food_price_value DESC
;