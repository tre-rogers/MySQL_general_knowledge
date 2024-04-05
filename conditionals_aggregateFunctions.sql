SELECT * FROM employees;
SELECT 
    dept_no
FROM
    departments;
    SELECT 
    *
FROM
    employees
WHERE
    first_name = 'Elvis';
    
-- AND statements
SELECT * FROM employees
WHERE first_name = 'Kellie' AND gender = 'F';

-- OR statements
SELECT * FROM employees
WHERE first_name = 'Kellie' OR first_name = 'Aruna';

-- Logical Ordering for AND/OR
SELECT * FROM employees
WHERE gender = 'F' AND (first_name = 'Kellie' OR first_name = 'Aruna');

-- IN/NOT IN
SELECT * FROM employees
WHERE first_name IN ('Denis','Elvis');
SELECT * FROM employees
WHERE first_name NOT IN ('John', 'Mark','Jacob');

-- LIKE/NOT LIKE
SELECT * FROM employees
WHERE first_name LIKE ('Mark%');
SELECT * FROM employees
WHERE hire_date LIKE ('2000%');
SELECT * FROM employees
WHERE emp_no LIKE ('1000_');

-- Wildcard Characters
SELECT * FROM employees
WHERE first_name LIKE ('%Jack%');
SELECT * FROM employees
WHERE first_name NOT LIKE ('%Jack%');

-- BETWEEN.. AND..
SELECT * FROM salaries;
SELECT * FROM salaries
WHERE salary BETWEEN 66000 AND 70000;
SELECT * FROM employees
WHERE emp_no NOT BETWEEN '10004' AND '10012';
SELECT dept_name FROM departments
WHERE dept_no BETWEEN 'd003' AND 'd006';

-- IS/IS NOT NULL
SELECT dept_name FROM departments
WHERE dept_no IS NOT NULL;

-- Other comparison operators
SELECT * FROM employees
WHERE gender = 'F' AND hire_date >= '2000-01-01';
SELECT * FROM salaries
WHERE salary > 150000;

-- SELECT DISTINCT
SELECT DISTINCT hire_date FROM employees
LIMIT 1000;

-- Aggregate Functions
SELECT COUNT(emp_no) FROM salaries
WHERE salary >= 100000;
SELECT COUNT(*) FROM dept_manager;

-- ORDER BY
SELECT * FROM employees
ORDER BY hire_date DESC;

-- Aliases/AS statement
SELECT salary, COUNT(emp_no) AS emps_with_same_salary FROM salaries
WHERE salary > 80000
GROUP BY salary
ORDER BY salary ASC;

-- HAVING (HAVING can include conditions with aggregate functions, while WHERE cannot)
SELECT emp_no, AVG(salary) FROM salaries
GROUP BY emp_no
HAVING AVG(salary) > 120000
ORDER BY emp_no;

-- WHERE vs. HAVING
SELECT first_name, COUNT(first_name) FROM employees
WHERE hire_date > '1999-01-01'
GROUP BY first_name
HAVING COUNT(first_name) < 200
ORDER BY first_name;

-- Applying COUNT()
SELECT COUNT(DISTINCT dept_no) FROM dept_emp;

-- Applying SUM()
SELECT SUM(salary) FROM salaries
WHERE from_date > '1997-01-01';

-- Applying MIN() and MAX()
SELECT MIN(emp_no), MAX(emp_no) FROM employees;

-- Applying AVG()
SELECT AVG(salary) FROM salaries
WHERE from_date > '1997-01-01';

-- Applying ROUND() syntax -> ROUND(#, decimal places)
SELECT ROUND(AVG(salary), 2) FROM salaries
WHERE from_date > '1997-01-01';