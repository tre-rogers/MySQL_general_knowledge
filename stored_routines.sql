-- STORED ROUTINES
USE employees;

-- Stored Procedures
DROP PROCEDURE IF EXISTS select_employees;

DELIMITER $$

CREATE PROCEDURE select_employees()
	BEGIN
		SELECT * FROM employees
        LIMIT 1000;
	END$$
DELIMITER ;

-- Three ways to invoke stored procedures (One is to click the lightning next to the procedure in schema tab,
-- click wrench to immediately edit stored procedure
CALL employees.select_employees();
CALL select_employees(); -- If you have specified the database in the USE as above

DROP PROCEDURE IF EXISTS avg_salary;

DELIMITER $$
CREATE PROCEDURE avg_salary()
BEGIN
	SELECT AVG(salary) FROM salaries;
END$$
DELIMITER ;

CALL employees.avg_salary();

-- You can create stored procedures in the Workbench interface by right clicking in the
-- stored procedures tab in schemas > create stored procedureselect_salaries

-- Creating stored procedures with an input parameter
DROP PROCEDURE IF EXISTS emp_salary;

DELIMITER $$
CREATE PROCEDURE emp_salary(IN p_emp_no INTEGER)
BEGIN
	SELECT
		e.first_name, e.last_name, s.salary, s.from_date, s.to_date
	FROM
		employees e
	JOIN
		salaries s on e.emp_no = s.emp_no
	WHERE e.emp_no = p_emp_no; -- Defines how your input value corresponds to the 5 columns you have selected
END$$

DELIMITER ;

-- Procedures with one input parameter CAN be used with aggregate functions too
DROP PROCEDURE IF EXISTS emp_avg_salary;

DELIMITER $$
CREATE PROCEDURE emp_avg_salary(IN p_emp_no INTEGER)
BEGIN
	SELECT
		e.first_name, e.last_name, AVG(s.salary)
	FROM
		employees e
	JOIN
		salaries s on e.emp_no = s.emp_no
	WHERE e.emp_no = p_emp_no; -- Defines how your input value corresponds to the 5 columns you have selected
END$$

DELIMITER ;

CALL employees.emp_avg_salary(11300);

-- Create stored procedures with an Output Parameter (MUST USE SELECT-INTO STRUCTURE)
USE employees;
DROP PROCEDURE IF EXISTS emp_avg_salary_out;

DELIMITER $$
CREATE PROCEDURE emp_avg_salary_out(IN p_emp_no INTEGER, OUT p_avg_salary DECIMAL(10,2))
BEGIN
	SELECT AVG(s.salary)
	INTO p_avg_salary 			-- Inserts this value into out parameter stored
    FROM
		employees e
        JOIN
			salaries s ON e.emp_no = s.emp_no
		WHERE e.emp_no = p_emp_no;
END$$

DELIMITER ;

-- Exercise
USE employees;
DROP PROCEDURE IF EXISTS emp_info;

DELIMITER $$
CREATE PROCEDURE emp_info(IN nameFirst VARCHAR(14), IN nameLast VARCHAR(16), OUT p_emp_no INTEGER)
BEGIN
	SELECT e.emp_no
    INTO p_emp_no
    FROM employees e
    WHERE e.first_name = nameFirst AND e.last_name = nameLast
    GROUP BY e.first_name;
END$$

DELIMITER ;

-- SQL Variables (Dealing with out parameters)
SET @v_avg_salary = 0;
CALL employees.emp_avg_salary_out(11300, @v_avg_salary);
SELECT @v_avg_salary;

SET @v_emp_no = 0;
CALL employees.emp_info('Aruna','Journel', @v_emp_no);
SELECT @v_emp_no;

-- User-defined functions in MySQL
USE employees;
DROP FUNCTION IF EXISTS f_emp_avg_salary;

DELIMITER $$
CREATE FUNCTION f_emp_avg_salary(p_emp_no INTEGER) RETURNS DECIMAL(10,2)
DETERMINISTIC    -- Avoids error based on mySQL version type
BEGIN
	DECLARE v_avg_salary DECIMAL(10,2);
    SELECT
		AVG(s.salary)
	INTO v_avg_salary
    FROM employees e
		JOIN
	salaries s ON e.emp_no = s.emp_no
    WHERE e.emp_no = p_emp_no;
RETURN v_avg_salary;
END$$

DELIMITER ;

SELECT f_emp_avg_salary(11300);  -- CANNOT call a function, must use select

USE employees;
DROP FUNCTION IF EXISTS emp_info;

DELIMITER $$
CREATE FUNCTION emp_info(p_first_name VARCHAR(20), p_last_name VARCHAR(20)) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE v_salary DECIMAL(10,2);
    DECLARE v_max_from_date DATE;
    
	SELECT MAX(from_date)
		INTO v_max_from_date   -- storing the v_max_from_date variable to be used in the next SELECT statement
	FROM salaries s
		JOIN
			employees e ON e.emp_no = s.emp_no
		WHERE e.first_name = p_first_name AND e.last_name = p_last_name;
	
    SELECT s.salary
    INTO v_salary
    FROM
		employees e
	JOIN
		salaries s ON e.emp_no = s.emp_no
	WHERE e.first_name = p_first_name
    AND e.last_name = p_last_name
    AND s.from_date = v_max_from_date;
	RETURN v_salary;
END$$

DELIMITER ;
		
SELECT emp_info('Aruna','Journel');

-- Difference between Stored Procedures and Functions
-- Stored procedures can have multiple OUT parameters, functions can only have one
-- Stored procedures can make us of INSERT, UPDATE, and DELETE functions to modify data in database

-- Can use a function as one of the columns in a SELECT statement, as it uses the SELECT function
SET @v_emp_no = 11300;
SELECT
	emp_no,
    first_name,
    last_name,
    f_emp_avg_salary(@v_emp_no) AS avg_salary
FROM
	employees
WHERE emp_no = @v_emp_no; -- COME BACK AND SEE WHY THIS IS RETURNING 'ARUNA JOURNEL' INSTEAD OF emp_no 11300

