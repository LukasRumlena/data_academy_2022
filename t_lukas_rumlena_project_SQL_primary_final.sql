
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
