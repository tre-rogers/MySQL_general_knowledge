-- Common Table Expressions -> Used for obtaining a temporary result set that exists within the
-- execution of a given query

-- How many salary contracts signed by female employees have been valued above the all-time
-- average contract salary value of the company
USE employees;

SELECT
	AVG(salary) as avg_salary 		-- By doing this, you won't necessarily have to store the avg_salary value
									-- in a seperate data table, and can use a CTE instead
FROM	
	salaries;
    
WITH cte AS (
SELECT AVG(salary) AS avg_salary FROM salaries)
SELECT
SUM(CASE WHEN s.salary > c.avg_salary THEN 1 ELSE 0 END) AS no_f_salaries_above_avg,   -- Must give CTE an alias to reference c.avg_salary here
COUNT(s.salary) AS total_no_of_salary_contracts
FROM
	salaries s
		JOIN
	employees e ON s.emp_no = e.emp_no AND e.gender = 'F'
		CROSS JOIN   -- Can also use just JOIN, as SQL interprets JOIN without ON as a CROSS JOIN
	cte c;      -- CROSS JOIN here adds the column for our CTE for average salary company-wide
    
-- OR

WITH cte AS (
SELECT AVG(salary) AS avg_salary FROM salaries)
SELECT
SUM(CASE WHEN s.salary > c.avg_salary THEN 1 ELSE 0 END) AS no_f_salaries_above_avg_w_sum,  
COUNT(CASE WHEN s.salary > c.avg_salary THEN s.salary ELSE NULL END) AS no_f_salaries_above_avg_w_count,  -- Notice CTEs can be referenced multiple times within a mySQL statement
COUNT(s.salary) AS total_no_of_salary_contracts
FROM
	salaries s
		JOIN
	employees e ON s.emp_no = e.emp_no AND e.gender = 'F'
		CROSS JOIN   
	cte c;
    
-- Exercise 1 (Using SUM())
WITH cte AS
(SELECT AVG(salary) AS avg_salary FROM salaries)
SELECT
	SUM(CASE WHEN s.salary < c.avg_salary THEN 1 ELSE 0 END) AS no_m_salary_below_avg,
    COUNT(s.salary) AS total_no_contracts
FROM
	salaries s
JOIN
	employees e ON s.emp_no = e.emp_no AND e.gender = 'M'
CROSS JOIN
	cte c;
    
-- Exercise 2 (Using COUNT())
WITH cte AS
(SELECT AVG(salary) AS avg_salary FROM salaries)
SELECT
	COUNT(CASE WHEN s.salary < c.avg_salary THEN s.salary ELSE NULL END) AS no_salary_below_avg,
    COUNT(s.salary) AS total_no_contracts
FROM
	salaries s
JOIN
	employees e ON s.emp_no = e.emp_no AND e.gender = 'M'
CROSS JOIN
	cte c;
    
-- Exercise 3
SELECT
	COUNT(CASE WHEN s.salary < c.avg_salary THEN s.salary ELSE NULL END) AS no_salary_below_avg,
    COUNT(s.salary) AS total_no_contracts
FROM
	salaries s
JOIN
	employees e ON s.emp_no = e.emp_no AND e.gender = 'M'
CROSS JOIN
	(SELECT AVG(salary) AS avg_salary FROM salaries) AS c;

-- Using multiple Subclauses in a WITH clause

-- Subclause #1
SELECT
	AVG(salary) AS avg_salary
FROM
	salaries;
    
-- Subclause #2
SELECT
	s.emp_no, MAX(s.salary) AS highest_salary
FROM
	salaries s
		JOIN
	employees e ON s.emp_no = e.emp_no AND e.gender = 'F'
GROUP BY s.emp_no;

-- NOTE: It is illegal to try to use two or more WITH clauses on the same level
-- so we just use a comma to seperate CTEs as below:

WITH cte1 AS (
SELECT
	AVG(salary) AS avg_salary
FROM
	salaries),
cte2 AS 
(SELECT
	s.emp_no, MAX(s.salary) AS f_highest_salary
FROM
	salaries s
		JOIN
	employees e ON s.emp_no = e.emp_no AND e.gender = 'F'
GROUP BY s.emp_no)
SELECT
	SUM(CASE WHEN c2.f_highest_salary > c1.avg_salary THEN 1 ELSE 0 END) AS no_f_above_avg,
    COUNT(e.emp_no) AS total_no_contracts_f
FROM
	employees e
		JOIN
	cte2 c2 ON c2.emp_no = e.emp_no
		CROSS JOIN
	cte1 c1;

-- More on Multiple Subclauses (Finding percentage from two outputs of previous)
WITH cte1 AS (
SELECT
	AVG(salary) AS avg_salary
FROM
	salaries),
cte2 AS 
(SELECT
	s.emp_no, MAX(s.salary) AS f_highest_salary
FROM
	salaries s
		JOIN
	employees e ON s.emp_no = e.emp_no AND e.gender = 'F'
GROUP BY s.emp_no)
SELECT
	SUM(CASE WHEN c2.f_highest_salary > c1.avg_salary THEN 1 ELSE 0 END) AS no_f_above_avg,
    COUNT(e.emp_no) AS total_no_contracts_f,
    CONCAT(ROUND((SUM(CASE WHEN c2.f_highest_salary > c1.avg_salary THEN 1 ELSE 0 END) / COUNT(e.emp_no)) * 100, 2), '%') AS perc,   -- CANNOT USE ALIASES HERE, MUST USE FULL EXPRESSION for SUM() and COUNT()
    CONCAT(ROUND((COUNT(CASE WHEN c2.f_highest_salary > c1.avg_salary THEN e.emp_no ELSE NULL END) / COUNT(e.emp_no)) * 100, 2), '%') AS perc_count -- Just rounding to 2 decimal places and concatenating a '%' on the end
FROM
	employees e
		JOIN
	cte2 c2 ON c2.emp_no = e.emp_no
		CROSS JOIN
	cte1 c1;

-- Exercise 1
WITH cte1 AS 
(SELECT
	AVG(salary) AS avg_salary
FROM
	salaries),
cte2 AS 
(SELECT
	s.emp_no, MAX(salary) AS highest_salary
FROM salaries s
JOIN
	employees e ON e.emp_no = s.emp_no AND e.gender = 'M'
GROUP BY s.emp_no)
SELECT
	SUM(CASE WHEN c2.highest_salary < c1.avg_salary THEN 1 ELSE 0 END) AS no_m_below_avg,
    COUNT(c2.emp_no) AS total_no_m_contracts
FROM
	employees e
		JOIN
	cte2 c2 ON c2.emp_no = e.emp_no
		JOIN
	cte1 c1;
    
-- Exercise 2
WITH cte1 AS 
(SELECT
	AVG(salary) AS avg_salary
FROM
	salaries),
cte2 AS 
(SELECT
	s.emp_no, MAX(salary) AS highest_salary
FROM salaries s
JOIN
	employees e ON e.emp_no = s.emp_no AND e.gender = 'M'
GROUP BY s.emp_no)
SELECT
	COUNT(CASE WHEN c2.highest_salary < c1.avg_salary THEN c2.highest_salary ELSE NULL END) AS no_m_below_avg,
    COUNT(c2.emp_no) AS total_no_m_contracts
FROM
	employees e
		JOIN
	cte2 c2 ON c2.emp_no = e.emp_no
		JOIN
	cte1 c1;
    
-- Referring to CTE within a WITH clause -> CAN refer to a CTE defined earlier within a WITH clause.
-- CANNOT refer to a CTE that has been defined AFTER within a with clause
WITH emp_hired_from_jan_2000 AS (
SELECT * FROM employees WHERE hire_date > '2000-01-01'
),
highest_contract_salary_values AS (
SELECT e.emp_no, MAX(s.salary) FROM salaries s
JOIN
	emp_hired_from_jan_2000 e ON e.emp_no = s.emp_no  -- Here, emp_hired_from_jan_2000 is defined before this CTE
    GROUP BY s.emp_no)
SELECT * FROM highest_contract_salary_values;

-- Example of referencing a CTE before it is defined
WITH highest_contract_salary_values AS (
SELECT e.emp_no, MAX(s.salary) FROM salaries s
JOIN
	emp_hired_from_jan_2000 e ON e.emp_no = s.emp_no  -- Here, emp_hired_from_jan_2000 is defined after this CTE (ERROR)
    GROUP BY s.emp_no),
emp_hired_from_jan_2000 AS (
SELECT * FROM employees WHERE hire_date > '2000-01-01'
)
SELECT * FROM highest_contract_salary_values;