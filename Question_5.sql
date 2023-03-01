
SELECT
	payroll.basic_year year_of_measurement,
	payroll.payroll_growth average_payroll_grow,
	ROUND (AVG (price.price_growth),2) average_price_food_grow,
 	gdp.GDP_growth 
FROM 
	v_food_vs_wage_year_to_year payroll
RIGHT JOIN 
	v_food_prices  price
ON 
	payroll.basic_year  = price.`YEAR (date_from)`
LEFT JOIN 
	t_lukas_rumlena_project_SQL_secondary_final GDP
ON 
	payroll.basic_year = GDP.bacic_year
WHERE 
	gdp.country = 'Czech republic' AND 
	gdp.basic_GDP IS NOT NULL
GROUP BY basic_year;