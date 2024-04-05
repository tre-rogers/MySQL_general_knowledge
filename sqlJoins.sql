-- JOINS


-- BASELINE CREATION
USE employees;

DROP TABLE IF EXISTS departments_dup;
CREATE TABLE departments_dup (
dept_no CHAR(4) NULL,
dept_name VARCHAR(40) NULL);
INSERT INTO departments_dup (
dept_no,
dept_name)
SELECT * FROM departments;
INSERT INTO departments_dup(dept_name)
VALUES ('Public Relations');

SET SQL_SAFE_UPDATES = 0;

DELETE FROM departments_dup
WHERE dept_no = 'd002';
INSERT INTO departments_dup(dept_no)
VALUES ('d010'), ('d011');

DROP TABLE IF EXISTS dept_manager_dup;
CREATE TABLE dept_manager_dup (
emp_no INT(11) NOT NULL,
dept_no CHAR(4) NULL,
from_date date NOT NULL,
to_date date NULL);
INSERT INTO dept_manager_dup
SELECT * FROM dept_manager;
INSERT INTO dept_manager_dup(emp_no, from_date)
VALUES (999904, '2017-01-01'),
		(999905, '2017-01-01'),
        (999906, '2017-01-01'),
        (999907, '2017-01-01');
DELETE FROM dept_manager_dup
WHERE dept_no = 'd001';
        
        
-- BEGINNING OF LESSON

-- INNER JOINS
SELECT m.emp_no, m.dept_no, d.dept_name
FROM dept_manager_dup m
	INNER JOIN
		departments_dup d ON m.dept_no = d.dept_no
	ORDER BY m.dept_no;
    
SELECT m.emp_no, e.first_name, e.last_name, m.dept_no, e.hire_date
FROM dept_manager m 
INNER JOIN
employees e ON m.emp_no = e.emp_no
ORDER BY m.emp_no;

SELECT m.emp_no, e.first_name, e.last_name, m.dept_no, e.hire_date
FROM dept_manager m 
INNER JOIN
employees e ON m.emp_no = e.emp_no
ORDER BY m.emp_no;

-- Dealing with Duplicate Records (GROUP BY field that differs most among records)

INSERT INTO dept_manager_dup
VALUES ('110228','d003','1992-03-21','9999-01-01');
INSERT INTO departments_dup
VALUES ('d009', 'Customer Service');
SELECT m.dept_no, m.emp_no, d.dept_name
FROM dept_manager_dup m
	JOIN
		departments_dup d ON m.dept_no = d.dept_no
	GROUP BY m.emp_no
	ORDER BY m.dept_no;
    
DELETE FROM dept_manager_dup
WHERE emp_no = '110228';

DELETE FROM departments_dup
WHERE dept_no = 'd009';

-- Adding back initial records
INSERT INTO dept_manager_dup
VALUES ('110228','d003','1992-03-21','9999-01-01');
INSERT INTO departments_dup
VALUES ('d009', 'Customer Service');
-- LEFT JOIN
SELECT m.dept_no, m.emp_no, d.dept_name
FROM dept_manager_dup m
	LEFT JOIN
		departments_dup d ON m.dept_no = d.dept_no
	GROUP BY m.emp_no
	ORDER BY m.dept_no;
    
SELECT e.emp_no, e.first_name, e.last_name, m.dept_no, m.from_date
FROM employees e
	LEFT JOIN
		dept_manager m ON e.emp_no = m.emp_no
	WHERE e.last_name = 'Markovitch'
    ORDER BY m.dept_no DESC, e.emp_no;
    
-- RIGHT JOINS -> Same as reversing order of tables in LEFT JOIN (NOT USED OFTEN)
SELECT m.dept_no, m.emp_no, d.dept_name
FROM dept_manager_dup m
	RIGHT JOIN
		departments_dup d ON m.dept_no = d.dept_no
	ORDER BY m.dept_no;

-- Using JOIN and WHERE together
SELECT e.emp_no, e.first_name, e.last_name, s.salary
FROM employees e
INNER JOIN
	salaries s ON e.emp_no = s.emp_no
WHERE salary > 145000;

-- Preventing Error Code 1055
set @@global.sql_mode := replace(@@global.sql_mode, 'ONLY_FULL_GROUP_BY', '');

SELECT e.first_name, e.last_name, e.hire_date, t.title
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
WHERE first_name = 'Margareta' AND last_name = 'Markovitch'
ORDER BY e.emp_no;

-- CROSS JOIN
SELECT dm.*, d.*
FROM dept_manager dm
CROSS JOIN departments d
ORDER BY dm.emp_no, d.dept_no;

SELECT dm.*, d.*
FROM dept_manager dm,
	departments d
ORDER BY dm.emp_no, d.dept_no;

SELECT dm.*, d.*
FROM dept_manager dm
	JOIN
		departments d
ORDER BY dm.emp_no, d.dept_no;

-- Using WHERE with CROSS JOIN
SELECT dm.*, d.*
FROM dept_manager dm
CROSS JOIN departments d
WHERE d.dept_no <> dm.dept_no
ORDER BY dm.emp_no, d.dept_no;

-- Combining CROSS JOIN with INNER JOIN
SELECT e.*, d.*
FROM dept_manager dm
	CROSS JOIN departments d
    JOIN employees e ON e.emp_no = dm.emp_no
WHERE d.dept_no <> dm.dept_no
ORDER BY dm.emp_no, d.dept_no;

-- More CROSS JOIN
SELECT dm.*, d.*
FROM dept_manager dm
CROSS JOIN
departments d
WHERE 
dm.dept_no = 'd009'
ORDER BY dept_name;

SELECT e.*, d.*
FROM employees e
CROSS JOIN
	departments d
WHERE 
	e.emp_no < 10011
ORDER BY e.emp_no, d.dept_name;

-- Using aggregate functions with JOINs
SELECT e.gender, AVG(s.salary) AS average_salary
FROM
	employees e
		JOIN
	salaries s ON e.emp_no = s.emp_no
GROUP BY gender;

-- JOIN more than two tables
SELECT
	e.first_name,
    e.last_name,
    e.hire_date,
    dm.from_date,
    d.dept_name
FROM employees e
JOIN dept_manager dm ON e.emp_no = dm.emp_no
JOIN departments d ON dm.dept_no = d.dept_no
;

SELECT 
    e.first_name,
    e.last_name,
    e.hire_date,
    t.title,
    dm.from_date,
    d.dept_name
FROM
    employees e
        JOIN
    dept_manager dm ON e.emp_no = dm.emp_no
        JOIN
    titles t ON dm.emp_no = t.emp_no
        JOIN
    departments d ON dm.dept_no = d.dept_no
ORDER BY e.emp_no;

-- Tips and Tricks for JOINs (Shortcut for joining not directly related tables in the relational schema)
SELECT d.dept_name, AVG(salary) AS average_salary
FROM
	departments d
		JOIN
	dept_manager m ON d.dept_no = m.dept_no
		JOIN
	salaries s ON m.emp_no = s.emp_no
GROUP BY dept_name
ORDER BY average_salary DESC;

SELECT e.gender, COUNT(DISTINCT e.emp_no)
FROM employees e
JOIN dept_manager dm ON e.emp_no = dm.emp_no
GROUP BY gender;

-- UNION vs. UNION ALL

-- creating employees_dup
DROP TABLE IF EXISTS employees_dup;
CREATE TABLE employees_dup (
	emp_no INT,
    birth_date DATE,
    first_name VARCHAR(14),
    last_name VARCHAR(16),
    gender ENUM('M','F'),
    hire_date date
    );

-- duplicating the structure of the 'employees' table
INSERT INTO employees_dup
SELECT e.*
FROM employees e
LIMIT 20;
SELECT * FROM employees_dup;

-- Insert duplicate of the first row
INSERT INTO employees_dup VALUES
('10001','1953-09-02','Georgi','Facello','M','1986-06-26');

-- Adding NULL AS columns to comply with condition that each table must have same column number and column names
-- UNION ALL
SELECT
	e.emp_no,
    e.first_name,
    e.last_name,
    NULL AS dept_no,
    NULL AS from_date
FROM employees_dup e
WHERE e.emp_no = 10001
UNION ALL SELECT
	NULL AS emp_no,
    NULL AS first_name,
    NULL AS last_name,
    m.dept_no,
    m.from_date
FROM dept_manager m;

-- UNION
SELECT
	e.emp_no,
    e.first_name,
    e.last_name,
    NULL AS dept_no,
    NULL AS from_date
FROM employees_dup e
WHERE e.emp_no = 10001
UNION SELECT
	NULL AS emp_no,
    NULL AS first_name,
    NULL AS last_name,
    m.dept_no,
    m.from_date
FROM dept_manager m;

 -- REMEMBER -> UNION ELIMINATES DUPLICATES, UNION ALL KEEPS ALL DUPLICATES
 