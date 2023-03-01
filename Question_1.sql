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
