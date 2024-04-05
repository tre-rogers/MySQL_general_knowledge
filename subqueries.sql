 -- Subqueries/Nested Queries
 SELECT * FROM dept_manager;
 -- Select the first and last name from the 'employees' table for the same
 -- employee numbers that can be found in the 'dept_manager' table
 SELECT e.first_name, e.last_name
 FROM employees e
 WHERE
	e.emp_no IN (SELECT
		dm.emp_no
	FROM
		dept_manager dm);
        
SELECT * FROM dept_manager dm
WHERE 
	dm.emp_no IN (SELECT e.emp_no
		FROM employees e
        WHERE hire_date BETWEEN '1990-01-01' AND '1995-01-01'
        );
        
-- SQL subqueries with EXISTS/NOT EXISTS Nested inside WHERE
 SELECT e.first_name, e.last_name
 FROM employees e
 WHERE
	EXISTS(SELECT *
    FROM
		dept_manager dm
	WHERE
		dm.emp_no = e.emp_no)
	ORDER BY emp_no; -- more professional to apply ORDER BY in outer query
    
SELECT *
FROM employees e
WHERE
	EXISTS(SELECT *
    FROM
		titles t
	WHERE 
		t.emp_no = e.emp_no AND
		title = 'Assistant Engineer')
    ORDER BY emp_no;

-- SQL subqueries nested in SELECT and FROM

INSERT INTO emp_manager
SELECT
	U.*
    FROM
(SELECT 
    A.*
FROM
    (SELECT 
        e.emp_no AS employee_ID,
            MIN(de.dept_no) AS dept_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110022) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no <= 10020
    GROUP BY e.emp_no
    ORDER BY e.emp_no) AS A 
UNION SELECT 
    B.*
FROM
    (SELECT 
        e.emp_no AS employee_ID,
            MIN(de.dept_no) AS dept_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110039) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no > 10020
    GROUP BY e.emp_no
    ORDER BY e.emp_no
    LIMIT 20) AS B 
UNION SELECT 
    C.*
FROM
    (SELECT 
        e.emp_no AS employee_ID,
            MIN(de.dept_no) AS dept_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110022) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no = 110039
    GROUP BY e.emp_no
    ORDER BY e.emp_no) AS C 
UNION SELECT 
    D.*
FROM
    (SELECT 
        e.emp_no AS employee_ID,
            MIN(de.dept_no) AS dept_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110039) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no = 110022
    GROUP BY e.emp_no
    ORDER BY e.emp_no) AS D)
    AS U;
    
SELECT * FROM emp_manager;


    
-- Subquery Exercise
DROP TABLE IF EXISTS emp_manager;

CREATE TABLE emp_manager (
   emp_no INT NOT NULL,
   dept_no CHAR(4) NULL,
   manager_no INT NOT NULL
);
        
-- NOTE: EXISTS is better for large amounts of data, as it *tests* each row.
-- IN is better for small data sets, as it *searches* among values
