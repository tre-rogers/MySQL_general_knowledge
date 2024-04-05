-- Window Functions in SQL

-- ROW_NUMBER() Ranking Window Function
USE employees;

SELECT
	emp_no,
    salary,
    ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salary DESC) AS row_num  -- Breaks row_num into partitions for each emp_no, if OVER() is left blank, there is a single partition, hence increments through entire table
FROM
	salaries;
    
SELECT
	emp_no,
    dept_no,
    ROW_NUMBER() OVER (ORDER BY emp_no) AS row_num  -- Can use only an ORDER BY statement in OVER clause
FROM dept_manager
ORDER BY emp_no;

SELECT
	e.first_name,
    e.last_name,
    ROW_NUMBER() OVER(PARTITION BY first_name ORDER BY last_name) AS row_num
FROM
	employees e;
    
-- Using Several Window Functions in a Query
SELECT
	emp_no,
    salary,
    ROW_NUMBER() OVER () AS row_num1,
    ROW_NUMBER() OVER (PARTITION BY emp_no) AS row_num2,
    ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salary DESC) AS row_num3,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num4
FROM
	salaries
ORDER BY emp_no, salary;

-- Exercise 1
SELECT
	dm.emp_no,
    s.salary,
    ROW_NUMBER() OVER() AS row_num,
    ROW_NUMBER() OVER(PARTITION BY dm.emp_no) AS salary_rank
FROM
	dept_manager dm
    JOIN
		salaries s ON dm.emp_no = s.emp_no
ORDER BY row_num, salary;

-- Exercise 2
SELECT
	dm.emp_no,
    s.salary,
    ROW_NUMBER() OVER(PARTITION BY dm.emp_no) AS salary_rank,
	ROW_NUMBER() OVER(PARTITION BY dm.emp_no ORDER BY salary DESC) AS salary_rank
FROM
	dept_manager dm
    JOIN
		salaries s ON dm.emp_no = s.emp_no;
        
-- MySQL Window Functions Syntax - Specifying the window to replace the OVER arguments, same as before but () is assigned to a Window with an alias
-- This is NOT the best way professionally, as it is redundant
-- BEST USED WHEN: query employing several window functions, need to refer to the same window specification multiple times throughout a query
SELECT
	emp_no,
    salary,
    ROW_NUMBER() OVER w AS row_num
FROM
	salaries
WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC);

-- Exercise
SELECT
	emp_no,
    first_name,
    last_name,
    ROW_NUMBER() OVER w AS row_num
FROM
	employees
WINDOW w AS (PARTITION BY first_name ORDER BY emp_no);

-- PARTITION BY vs. GROUP BY Clause

-- THIS METHOD IS PREFERABLE WHEN YOU WANT TO FIND A SPECIFIC RANK FOR THE EMPLOYEES, e.g Second-Highest Salary
SELECT
	a.emp_no,
	a.salary AS min_salary
    FROM (
    SELECT
		emp_no, salary, ROW_NUMBER() OVER w AS row_num
	FROM salaries
	WINDOW w AS (PARTITION BY emp_no ORDER BY salary)) AS a   -- Derived table must have an Alias, in this case 'a' that is
																-- referred to in the original select statement, as this is where
																-- we are grabbing information from
WHERE a.row_num = 1;

-- OR

SELECT
	a.emp_no,
    MIN(a.salary) AS min_salary
    FROM (
	SELECT emp_no, salary, ROW_NUMBER() OVER(PARTITION BY emp_no ORDER BY salary) AS row_num
    FROM salaries) AS a
    GROUP BY emp_no;
    
-- OR

SELECT
	emp_no,
    MIN(salary) AS min_salary
    FROM (
		SELECT emp_no, salary
        FROM salaries) AS a
	GROUP BY emp_no;
    
-- OR

SELECT
	a.emp_no,
    MIN(salary) AS min_salary
    FROM (
    SELECT emp_no, salary, ROW_NUMBER() OVER w AS row_num
    FROM
		salaries
	WINDOW w AS (PARTITION BY emp_no ORDER BY salary)) a
    GROUP BY emp_no;
    
    
-- RANK()
SELECT
	emp_no,
    salary,
    ROW_NUMBER() OVER w AS row_num
FROM
	salaries
WHERE emp_no = 11839
WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC);

-- For when you may have, say, an employee who has signed two or more contracts with the same salary value
SELECT
	emp_no, (COUNT(salary) - COUNT(DISTINCT salary)) as diff
FROM
	salaries
GROUP BY emp_no
HAVING diff > 0  -- Use HAVING because we have aggregate functions in the SELECT statement
ORDER BY emp_no;

SELECT
	*
FROM
	salaries
WHERE
	emp_no = 11839;
    
SELECT
	emp_no,
    salary,
	RANK() OVER w AS rank_num  -- Using rank here creates table with the same number rank for those records containing the same salary
FROM
	salaries
WHERE emp_no = 11839
WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC);

-- The above gives ranks with two '3' records, then skips to 5 (The second '3' record is counted as 4), augmenting the rank column
-- To obtain a column where the next entry is 4 after the two '3's, we must use DENSE_RANK()

-- DENSE_RANK()
SELECT
	emp_no,
    salary,
	DENSE_RANK() OVER w AS rank_num  -- Using rank here creates table with the same number rank for those records containing the same salary
FROM
	salaries
WHERE emp_no = 11839
WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC);

-- NOTE: RANK() AND DENSE_RANK() ARE ONLY USEFUL WHEN APPLIED TO ORDERED PARTITIONS

-- Exercise 1
SELECT
	emp_no,
    salary,
    ROW_NUMBER() OVER(ORDER BY salary DESC) AS row_num
FROM
	salaries
WHERE emp_no = 10560;

-- Exercise 2
SELECT
	dm.emp_no,
    COUNT(salary) AS no_contracts
FROM
	dept_manager dm
    JOIN
		salaries s ON dm.emp_no = s.emp_no
GROUP BY emp_no
ORDER BY emp_no;

-- Exercise 3 -> RANK()
SELECT
	emp_no,
    salary,
    RANK() OVER w AS rank_num
FROM
	salaries
WHERE emp_no = 10560
WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC);

-- Exercise 4 -> DENSE_RANK()
SELECT
	emp_no,
    salary,
    DENSE_RANK() OVER w AS rank_num
FROM
	salaries
WHERE emp_no = 10560
WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC);


-- Using Ranking Window Functions and JOINS together
SELECT
	dm.dept_no,
    d.dept_name,
    dm.emp_no,
    RANK() OVER w AS dept_salary_ranking,
    s.salary,
    s.from_date AS salary_from_date,
    s.to_date AS salary_to_date,
    dm.from_date AS dept_manager_from_date,
    dm.to_date AS dept_manager_to_date
FROM
		dept_manager dm
	JOIN
		salaries s ON dm.emp_no = s.emp_no
        AND s.from_date BETWEEN dm.from_date AND dm.to_date  -- THIS ENSURES THAT THE MANAGER WAS WORKING IN THE SPECIFIED DEPARTMENT WHILE
															-- THE SALARY CONTRACT WAS MADE
        AND s.to_date BETWEEN dm.from_date AND dm.to_date
	JOIN
		departments d ON dm.dept_no = d.dept_no
WINDOW w AS (PARTITION BY dm.dept_no ORDER BY s.salary DESC);

-- Exercise 1
SELECT
	e.emp_no,
    e.first_name,
    e.last_name,
    s.salary,
    RANK() OVER w AS salary_rank
FROM
	employees e
    JOIN
		salaries s ON e.emp_no = s.emp_no
	WHERE e.emp_no BETWEEN 10500 AND 10600
WINDOW w AS (ORDER BY salary DESC);


-- Exercise 2
SELECT
	e.emp_no,
    e.first_name,
    e.last_name,
    s.salary,
    DENSE_RANK() OVER w AS salary_rank,
    e.hire_date,
    s.from_date,
    (YEAR(s.from_date) - YEAR(e.hire_date)) AS years_from_start
FROM
	employees e
    JOIN
		salaries s ON e.emp_no = s.emp_no
        AND YEAR(s.from_date) - YEAR(e.hire_date) > 4
	WHERE e.emp_no BETWEEN 10500 AND 10600
WINDOW w AS (ORDER BY salary DESC);

-- LAG() and LEAD() Value Window Functions -> as opposed to ranking window functions, value window functions return a value
-- that can be found within the database
SELECT
	emp_no,
    salary,
    LAG(salary) OVER w AS previous_salary,
    LEAD(salary) OVER w AS next_salary,
    salary - LAG(salary) OVER w AS diff_salary_current_previous,
    LEAD(salary) OVER w - salary AS diff_salary_next_current
FROM
	salaries
WHERE emp_no = 10001
WINDOW w AS (ORDER BY salary); 

-- Exercise 1
SELECT
	e.emp_no,
    e.first_name,
    e.last_name,
    s.salary,
    RANK() OVER w AS salary_rank,
    LAG(s.salary) OVER w AS prev_salary,
    LEAD(s.salary) OVER w AS next_salary,
    s.salary - LAG(s.salary) OVER w AS diff_prev_curr,
    LEAD(s.salary) OVER w - s.salary AS diff_next_curr
FROM
	employees e
    JOIN
		salaries s ON e.emp_no = s.emp_no
	WHERE e.emp_no BETWEEN 10500 AND 10600
    AND s.salary > 80000
WINDOW w AS (PARTITION BY emp_no ORDER BY salary);

-- Exercise 2
SELECT
	emp_no,
    salary,
    LAG(salary) OVER w AS prev_salary,
    LAG(salary, 2) OVER w AS two_year_prev,
    LEAD(salary) OVER w AS next_salary,
    LEAD(salary, 2) OVER w AS two_years_subs
FROM
	salaries
WINDOW w AS (PARTITION BY emp_no ORDER BY salary)
LIMIT 1000;

-- Aggregate Window Functions
SELECT
	s1.emp_no, s.salary, s.from_date, s.to_date
FROM
	salaries s
		JOIN
	(SELECT
		emp_no, MAX(from_date) AS from_date
	FROM
		salaries
	GROUP BY emp_no) s1 ON s.emp_no = s1.emp_no
WHERE
	s.to_date > SYSDATE()
		AND s.from_date = s1.from_date;
    
    
-- Exercise 1
SELECT
	s1.emp_no,
    s.salary,
    s.from_date,
    s.to_date
FROM
	salaries s
JOIN
	(SELECT
		emp_no, MIN(from_date) AS from_date
	FROM
		salaries
	GROUP BY emp_no) s1 ON s.emp_no = s1.emp_no
WHERE
	s.from_date = s1.from_date;   -- THIS IS AN IMPORTANT STEP, DO NOT FORGET
    
-- Actual Lesson Start for Aggregate Functions in Window Functions
SELECT
	de.emp_no, de.dept_no, de.from_date, de.to_date
FROM
	dept_emp de
		JOIN
	(SELECT
		emp_no, MAX(from_date) AS from_date
	FROM
		dept_emp
	GROUP BY emp_no) de1 ON de1.emp_no = de.emp_no
WHERE
	de.to_date > SYSDATE()
		AND de1.from_date = de.from_date;
        
        
-- ENTIRE QUERY
SELECT de2.emp_no, d.dept_name, s2.salary, AVG(s2.salary) OVER w AS average_salary_per_department
FROM
	(SELECT
    de.emp_no, de.dept_no, de.from_date, de.to_date
    FROM dept_emp de
		JOIN
	(SELECT
		emp_no, MAX(from_date) AS from_date
	FROM
		dept_emp
	GROUP BY emp_no) de1 ON de1.emp_no = de.emp_no
WHERE de.to_date > SYSDATE()
	AND de.from_date = de1.from_date) de2
	JOIN
    (SELECT
		s1.emp_no, s.salary, s.from_date, s.to_date
	FROM
		salaries s
	JOIN
    (SELECT
		emp_no, MAX(from_date) AS from_date
	FROM salaries
    GROUP BY emp_no) s1 ON s.emp_no = s1.emp_no
    WHERE
		s.to_date > SYSDATE()
			AND s.from_date = s1.from_date) s2 
	ON s2.emp_no = de2.emp_no
				JOIN
			departments d ON d.dept_no = de2.dept_no
	GROUP BY de2.emp_no, d.dept_name
    WINDOW w AS (PARTITION BY de2.dept_no)
    ORDER BY de2.emp_no;
    
-- Exercise 2
SELECT
	s2.emp_no, s2.to_date, de2.to_date, AVG(s2.salary) OVER w AS avg_salary_per_department
FROM (
	SELECT
		s.emp_no,
        s.salary,
        s.to_date
	FROM
		salaries s
	JOIN
    (SELECT
		emp_no,
		MAX(to_date) AS to_date
	FROM salaries s
    GROUP BY emp_no) s1 ON s.emp_no = s1.emp_no
    WHERE s.from_date > '2000-01-01' AND s.to_date < '2002-01-01'
    AND s.to_date = s1.to_date) s2
    JOIN
		(SELECT
			de.emp_no,
            de.dept_no,
            de.to_date
		FROM
			dept_emp de
		JOIN
			(SELECT
				emp_no,
                MAX(to_date) AS to_date
			FROM
				dept_emp
			GROUP BY emp_no) de1 ON de.emp_no = de1.emp_no
		WHERE de.from_date > '2000-01-01' AND de.to_date < '2002-01-01'
        AND de.to_date = de1.to_date) de2
	ON de2.emp_no = s2.emp_no
    GROUP BY de2.dept_no, s2.emp_no
    WINDOW w AS (PARTITION BY de2.dept_no)
    ORDER BY s2.emp_no, salary;
    


    
-- In summary, use window functions when you don't want to reduce the number of records
-- in your resulting table; GROUP BY will reduce the number of records inherently