
CREATE OR REPLACE TABLE t_lukas_rumlena_project_SQL_primary_final AS
SELECT 
	cp.category_code,
	cp.value value1,
	cp.date_from,
	cp.region_code,
	cpay.value,
	cpay.payroll_year,
	cpay.industry_branch_code,
	cpay.value_type_code,
	cpayib.name name1,
	cpc.name,
	cpc.price_unit 
FROM czechia_price cp
JOIN czechia_payroll cpay
	ON YEAR(cp.date_from) = cpay.payroll_year 
	AND   cpay.value_type_code = 5958
LEFT JOIN czechia_payroll_industry_branch cpayib
	ON cpayib.code = cpay.industry_branch_code
LEFT JOIN czechia_price_category cpc
ON cp.category_code = cpc.code
;


--question 1--


CREATE OR REPLACE VIEW v_czechia_payroll_year AS
(
SELECT cp.payroll_year AS `year`, ROUND(AVG(cp.value)) AS avgPay, cpib.name AS fieldName
FROM czechia_payroll cp
LEFT JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code
WHERE cp.value_type_code = 5958 AND cp.value IS NOT NULL AND cp.industry_branch_code IS NOT NULL AND cp.calculation_code = 100
GROUP BY `year`, fieldName
ORDER BY cp.payroll_year)
;

SELECT a.`year`, ROUND((100 * (a.avgPay - cpb.avgPay)/cpb.avgPay),2) AS yearChange, cpb.fieldName
FROM v_czechia_payroll_by_field_year cpb
RIGHT JOIN v_czechia_payroll_by_field_year a ON cpb.`year` = a.`year` - 1 AND cpb.fieldName = a.fieldName
WHERE a.`year` != 2000
ORDER BY yearChange, a.`year`, cpb.fieldName
;


--question 2--

CREATE OR REPLACE VIEW v_czechia_price_category_category_code AS
SELECT 
	category_code,
	name,
	value1,
	price_unit,
	YEAR (date_from) YEAR1
FROM t_lukas_rumlena_project_SQL_primary_final 
WHERE region_code IS NULL AND category_code IN (111301,114201)
GROUP BY
	YEAR (date_from), name
ORDER BY
	name, date_from DESC
;
	
SELECT 
	czp.payroll_year Observed_year,
	cpc.category_code Goods,
	cpc.name Name_of_goods,
	czp.value Salary,
	cpc.value1,
	ROUND (czp.value / cpc.value1,0) Quantity_per_salary,
	cpc.price_unit
FROM czechia_payroll czp
JOIN v_czechia_price_category_category_code cpc
ON czp.payroll_year  = cpc.YEAR1 
WHERE czp.value_type_code  = 5958 AND czp.payroll_year IN (2006,2018)
GROUP BY czp.payroll_year, cpc.name
;


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

--question 5--

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