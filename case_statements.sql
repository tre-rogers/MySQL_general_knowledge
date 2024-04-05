-- CASE Statements -> Used within a select statement when you want to return a specific
-- value based on some condition

-- NOTE: THE BIG KEY HERE IS THAT THE CASE VALUE IS USED WITHIN A SELECT STATEMENT

USE employees;

SELECT
	emp_no,
    first_name,
    last_name,
    CASE
		WHEN gender = 'M' THEN 'Male'
        ELSE 'Female'
	END AS gender
FROM
	employees;
    
SELECT
	emp_no,
    first_name,
    last_name,
    CASE gender    -- Added column name after CASE, returns same results
		WHEN gender = 'M' THEN 'Male'
        ELSE 'Female'
	END AS gender
FROM
	employees;
    
SELECT
	e.emp_no,
    e.first_name,
    e.last_name,
    CASE  					-- CANNOT INCLUDE dm.emp_no HERE AND REMOVE FROM WHEN PORTION, MUST HAVE THIS SYNTAX
		WHEN dm.emp_no IS NOT NULL THEN 'Manager'
        ELSE 'Employee'
	END AS is_manager
FROM
	employees e
		LEFT JOIN
	dept_manager dm ON dm.emp_no = e.emp_no
WHERE
	e.emp_no > 109990;

-- Using IF instead
SELECT
	emp_no,
    first_name,
    last_name,
    IF(gender = 'M', 'Male','Female') AS gender  -- SYNTAX for this is (v = condition, value returned if true, value returned if false)
FROM
	employees;
    
-- NOTE: With IF, you can only have one conditional expression. With CASE, you can have multiple
-- Example
SELECT
	dm.emp_no,
    e.first_name,
    e.last_name,
    MAX(s.salary) - MIN(s.salary) AS salary_difference,
    CASE
		WHEN MAX(s.salary) - MIN(s.salary) >30000 THEN 'Salary was raised by more than $30,000'
        WHEN MAX(s.salary) - MIN(s.salary) BETWEEN 20000 AND 30000 THEN 'Salary was raised by more than $20,000, but less than $30,000'
        ELSE 'Salary was raised by less than $20,000'
	END AS salary_increase
FROM dept_manager dm
	JOIN
		salaries s ON dm.emp_no = s.emp_no
	JOIN
		employees e ON dm.emp_no = e.emp_no
GROUP BY s.emp_no;

-- Exercise 1
SELECT
	e.emp_no,
    e.first_name,
    e.last_name,
    CASE
		WHEN dm.emp_no IS NOT NULL THEN 'Manager'
        ELSE 'Employee'
	END AS is_manager
FROM employees e
	LEFT JOIN     -- We use LEFT JOIN here because we want ALL employees who are above emp_no 109990 to be included in our result set
		dept_manager dm ON e.emp_no = dm.emp_no
	WHERE e.emp_no > 109990;
    
-- Exercise 2
SELECT
	e.emp_no,
    e.first_name,
    e.last_name,
    (MAX(s.salary) - MIN(s.salary)) AS salary_diff,
    CASE
		WHEN MAX(s.salary) - MIN(s.salary) > 30000 THEN 'Salary raise greater than $30,000'
        ELSE 'Less than $30,000'
	END AS is_greater_than
FROM
	employees e
    JOIN
		dept_manager dm ON e.emp_no = dm.emp_no
	JOIN
		salaries s ON e.emp_no = s.emp_no
GROUP BY s.emp_no;

-- Same as above, but using an IF statement, as there is only one boolean condition to fullfill
SELECT
	e.emp_no,
    e.first_name,
    e.last_name,
    (MAX(s.salary) - MIN(s.salary)) AS salary_diff,
	IF (MAX(s.salary) - MIN(s.salary) > 30000, 'Salary raise greater than $30,000', 'Less than $30,000') AS is_greater_than
FROM
	employees e
    JOIN
		dept_manager dm ON e.emp_no = dm.emp_no
	JOIN
		salaries s ON e.emp_no = s.emp_no
GROUP BY s.emp_no;

-- Exercise 3
SELECT
	e.emp_no,
    e.first_name,
    e.last_name,
    CASE
		WHEN MAX(de.to_date) > SYSDATE() THEN 'Is still employed'  -- NOTE: SYSDATE() is the current date and time on the system
																	-- Use MAX in case for some reason an employee was hired twice after a break, removes dups
        ELSE 'Not an employee anymore'
	END AS current_employee
FROM
	employees e
    JOIN
		dept_emp de ON e.emp_no = de.emp_no
GROUP BY de.emp_no
LIMIT 100;