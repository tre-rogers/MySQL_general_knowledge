-- Temporary Tables -> For use in the SAME SESSION it is created in

SELECT
	s.emp_no,
    MAX(s.salary) AS max_salary
FROM
	salaries s 											-- Out of this query, we can create a temporary table, more efficient for further use
JOIN
employees e ON e.emp_no =  s.emp_no AND e.gender = 'F'
GROUP BY emp_no;

-- Creating a temporary table
CREATE TEMPORARY TABLE f_highest_salaries
SELECT
	s.emp_no,
    MAX(s.salary) AS max_salary
FROM
	salaries s 											-- Out of this query, we can create a temporary table, more efficient for further use
JOIN
employees e ON e.emp_no =  s.emp_no AND e.gender = 'F'
GROUP BY emp_no;

SELECT * FROM f_highest_salaries;

-- Exercise 1
CREATE TEMPORARY TABLE male_max_salaries
SELECT
	s.emp_no,
    MAX(s.salary)
FROM
	salaries s
JOIN
	employees e ON e.emp_no = s.emp_no AND e.gender = 'M'
GROUP BY s.emp_no;

SELECT * FROM male_max_salaries;

DROP TABLE IF EXISTS f_highest_salaries;

CREATE TEMPORARY TABLE f_highest_salaries
SELECT
	s.emp_no,
    MAX(s.salary) AS max_salary
FROM
	salaries s 											-- Out of this query, we can create a temporary table, more efficient for further use
JOIN
employees e ON e.emp_no =  s.emp_no AND e.gender = 'F'
GROUP BY emp_no
LIMIT 10;

-- NOTE: Temporary tables can not be invoked twice within a query, cannot be used to JOIN or UNION on itself
-- There is a workaround using CTEs as below:

WITH CTE AS (SELECT
	s.emp_no,
    MAX(s.salary) AS max_salary
FROM
	salaries s
JOIN
employees e ON e.emp_no =  s.emp_no AND e.gender = 'F'
GROUP BY emp_no
LIMIT 10)
SELECT * FROM f_highest_salaries f1 JOIN cte c;

WITH cte AS (SELECT
	s.emp_no,
    MAX(s.salary) AS max_salary
FROM
	salaries s
JOIN
employees e ON e.emp_no =  s.emp_no AND e.gender = 'F'
GROUP BY emp_no
LIMIT 10)
SELECT * FROM f_highest_salaries UNION ALL SELECT * FROM cte;

CREATE TEMPORARY TABLE dates
SELECT
	NOW() AS current_date_time,
    DATE_SUB(NOW(), INTERVAL 1 MONTH) AS a_month_earlier,    -- Good note on how to obtain dates and sub dates
    DATE_SUB(NOW(), INTERVAL 1 YEAR) AS a_year_earlier;
    
SELECT * FROM dates;

SELECT
	*
FROM
	dates d1             -- THIS WILL GIVE AN ERROR (Self-UNION)
UNION SELECT
	*
FROM
	dates d2;
    
-- Workaround with CTEs
WITH cte AS (SELECT
	NOW() AS current_date_time,
    DATE_SUB(NOW(), INTERVAL 1 MONTH) AS a_month_earlier,
    DATE_SUB(NOW(), INTERVAL 1 YEAR) AS a_year_earlier)
SELECT * FROM dates d1 JOIN cte;

WITH cte AS (SELECT
	NOW() AS current_date_time,
    DATE_SUB(NOW(), INTERVAL 1 MONTH) AS a_month_earlier,
    DATE_SUB(NOW(), INTERVAL 1 YEAR) AS a_year_earlier)
SELECT * FROM dates d1 UNION ALL SELECT * FROM cte;

DROP TABLE IF EXISTS f_highest_salaries;
DROP TABLE IF EXISTS dates;

-- Exercise 1
CREATE TEMPORARY TABLE dates
SELECT
	NOW() AS current_date_time,
    DATE_SUB(NOW(), INTERVAL 2 MONTH) AS two_months_earlier,
    DATE_SUB(NOW(), INTERVAL 2 YEAR) AS two_years_earlier;
    
SELECT * FROM dates;

WITH cte AS (SELECT
	NOW() AS current_date_time,
    DATE_SUB(NOW(), INTERVAL 2 MONTH) AS two_months_earlier,
    DATE_SUB(NOW(), INTERVAL 2 YEAR) AS two_years_earlier)
SELECT * FROM dates JOIN cte;

WITH cte AS (SELECT
	NOW() AS current_date_time,
    DATE_SUB(NOW(), INTERVAL 2 MONTH) AS two_months_earlier,
    DATE_SUB(NOW(), INTERVAL 2 YEAR) AS two_years_earlier)
SELECT * FROM dates UNION ALL SELECT * FROM cte;

DROP TABLE IF EXISTS male_max_salaries;
DROP TABLE IF EXISTS dates;
