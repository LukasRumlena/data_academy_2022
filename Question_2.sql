--question 2--

CREATE OR REPLACE VIEW v_czechia_price_category_code AS
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
	cp.payroll_year Observed_year,
	cpc.category_code goods,
	cpc.name Name_of_goods,
	cp.value Salary,
	cpc.value1,
	ROUND (cp.value / cpc.value1,0) Quantity_per_salary,
	cpc.price_unit
FROM czechia_payroll cp
JOIN v_czechia_price_category_category_code cpc
ON cp.payroll_year  = cpc.YEAR1 
WHERE cp.value_type_code  = 5958 AND cp.payroll_year IN (2006,2018)
GROUP BY cp.payroll_year, cpc.name
;