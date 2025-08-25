SET SERVEROUTPUT ON;

DECLARE

	subj_rec s_subject%ROWTYPE;
	
	v_subject_code s_subject.subj_code%type := '&SUBJECTCODE';
	v_hasA_prereq s_subject.prereq%type;
	v_subject_name s_subject.subj_name%type;
	v_cost_fee s_subject.subj_fee%type;
BEGIN
	
	SELECT *
	INTO subj_rec
	FROM s_subject 
	WHERE subj_code = v_subject_code;
		
		IF subj_rec.prereq IS NOT NULL THEN
			DBMS_OUTPUT.PUT_LINE('Subject Details :'||CHR(10));
			DBMS_OUTPUT.PUT_LINE('================================================');
			DBMS_OUTPUT.PUT_LINE('Subject name :' ||v_subject_code||'-'||subj_rec.subj_name);
			DBMS_OUTPUT.PUT_LINE('Cost :'||TO_CHAR(subj_rec.subj_fee,'fmL99,999'));
			DBMS_OUTPUT.PUT_LINE('Prerequisite  : Yes');
			
		ELSE 
			DBMS_OUTPUT.PUT_LINE('Subject Details :'||CHR(10));
			DBMS_OUTPUT.PUT_LINE('================================================');
			DBMS_OUTPUT.PUT_LINE('Subject name :' ||v_subject_code||'-'||subj_rec.subj_name);
			DBMS_OUTPUT.PUT_LINE('Cost :'||TO_CHAR(subj_rec.subj_fee,'fmL99,999,99'));
			DBMS_OUTPUT.PUT_LINE('Prerequisite  :NO');
		END IF;
			
END;
/




-- INSERTING MULTIPLE KNOWN(give) COLUMNS per ROW without A PROMT(AN ARRAY FROM)

SET SERVEROUTPUT ON;
DECLARE
    c_countryID locations.country_id%TYPE := 'CA';
    v_last_location_index locations.location_id%TYPE;
    v_new_city locations.city%TYPE;
    v_counter NUMBER := 1;

    TYPE type_city_table IS TABLE OF locations.city%TYPE;
    v_city_list type_city_table := type_city_table('Ohio Taxes', 'Ceathtal', 'Kos Anngesl');

	
BEGIN
    SELECT MAX(location_id) 
    INTO v_last_location_index
    FROM locations  
    WHERE country_id = c_countryID;
    
    FOR i IN 1..3 LOOP
        v_new_city := v_city_list(i);
        
        INSERT INTO locations(location_id, city, country_id)
        VALUES (v_last_location_index + v_counter, v_new_city, c_countryID);
        
        v_counter := v_counter + 1;
    END LOOP;
    
    IF SQL%ROWCOUNT > 0 THEN 
        DBMS_OUTPUT.PUT_LINE('New locations added successfully: Montreal, Toronto, Vancouver.');
    END IF;
END;
/

-- single row assocciative record [Define an associative array to hold an entire row from a table]
SET SERVEROUTPUT ON;
DECLARE
    TYPE dept_table_type IS TABLE OF departments%ROWTYPE
    INDEX BY PLS_INTEGER;
    dept_table dept_table_type;
BEGIN
    SELECT * INTO dept_table(1) -- specify the row 
    FROM departments;
    
	FOR i IN dept_table.FIRST..dept_table.LAST Loop
		    dbms_output.put_line(dept_table(1).department_id||' works at(as) '||dept_table(1).department_name||' office is at section '||dept_table(1).location_id);
	END LOOP;
END;
/



-- multiple row assocciative array record to hold an entire row from table

SET SERVEROUTPUT ON;
DECLARE
    TYPE emp_table_type IS TABLE OF employees%ROWTYPE 
	INDEX BY PLS_INTEGER;
    emp_table emp_table_type;
	
    v_starting_index_empID employees.employee_id%TYPE := 100;
    v_termination_number employees.employee_id%TYPE := 104;
    v_email employees.email%TYPE;
	
BEGIN
    -- Fetch employee records from 100 to 104
    FOR i IN v_starting_index_empID..v_termination_number LOOP
        SELECT * INTO emp_table(i)
        FROM employees
        WHERE employee_id = i;
    END LOOP;
    
    FOR i IN emp_table.FIRST..emp_table.LAST LOOP
        v_email := emp_table(i).email;  -- Corrected this line
        DBMS_OUTPUT.PUT_LINE('Email :' || i || ' is ' || CONCAT(v_email, '@gmail.com'));
    END LOOP;
END;
/

-- Cursors's select JOIN statement which  

DECLARE
    -- Define the cursor to select data from employees and departments
    CURSOR emp_dept_cursor IS
        SELECT e.employee_id, e.first_name, e.last_name, d.department_name
        FROM employees e
        JOIN departments d ON e.department_id = d.department_id;
    
    -- Declare variables to hold the data fetched from the cursor
    v_employee_id employees.employee_id%TYPE;
    v_first_name employees.first_name%TYPE;
    v_last_name employees.last_name%TYPE;
    v_department_name departments.department_name%TYPE;
BEGIN
    -- Open the cursor and fetch data
    OPEN emp_dept_cursor;
    
    -- Loop through the cursor and display results
    LOOP
        FETCH emp_dept_cursor INTO v_employee_id, v_first_name, v_last_name, v_department_name;
        EXIT WHEN emp_dept_cursor%NOTFOUND;
        
        -- Display employee details along with department name
        DBMS_OUTPUT.PUT_LINE('Employee ID: ' || v_employee_id ||  ', Name: ' || v_first_name || ' ' || v_last_name || ', Department: ' || v_department_name);
    END LOOP;
    
    -- Close the cursor
    CLOSE emp_dept_cursor;
END;
/


-- CT@ QUESTION 1


SET SERVEROUTPUT ON;

DECLARE
    -- Declare a variable to store user input for author's ID
    v_author bk_author.authorid%TYPE := '&authorID';  

    -- Define a cursor that accepts an author's ID as a parameter
    CURSOR book_cursor (p_author_id bk_author.authorid%TYPE) IS 
        SELECT 
            a.authorid, a.lname, a.fname, 
            b.isbn, b.title, b.category, b.pubdate, 
            p.name AS publisher_name, c.retail
        FROM bk_author a
        JOIN bk_books b ON a.authorid = b.authorid
        JOIN bk_publisher p ON b.pubid = p.pubid
        JOIN bk_cost c ON c.isbn = b.isbn
        WHERE a.authorid = p_author_id
        ORDER BY b.isbn DESC;

    -- Declare a record variable to hold each fetched row
    v_book_rec book_cursor%ROWTYPE;

    -- Declare a flag to control the WHILE loop
    v_done BOOLEAN := FALSE;

BEGIN
    -- Check if the cursor is already open
    IF NOT book_cursor%ISOPEN THEN
        OPEN book_cursor(v_author);  -- Open the cursor with the provided author ID
    END IF;

    FETCH book_cursor INTO v_book_rec;
    
    -- If no records are found, display a message
    IF book_cursor%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('No books found for author ID: ' || v_author);
        CLOSE book_cursor;
        RETURN;
    END IF;

    -- Start the WHILE loop to iterate through the cursor
    WHILE NOT v_done LOOP
        -- Display book details in the required format
        DBMS_OUTPUT.PUT_LINE('======================================================================');
        DBMS_OUTPUT.PUT_LINE(v_book_rec.authorid || ' ' || INITCAP(v_book_rec.lname) || ' ' || INITCAP(v_book_rec.fname));
        DBMS_OUTPUT.PUT_LINE(v_book_rec.isbn || ' - ' || INITCAP(v_book_rec.title) || ' ' || INITCAP(v_book_rec.category) ||
                            ' published on ' || TO_CHAR(v_book_rec.pubdate, 'DD Month YYYY') ||
                            ' published by: ' || UPPER(v_book_rec.publisher_name) ||
                            ' sold for ' || TO_CHAR(v_book_rec.retail, 'L9999.99'));
        DBMS_OUTPUT.PUT_LINE('======================================================================');

        -- Fetch the next record
        FETCH book_cursor INTO v_book_rec;

        -- Check if no more records exist
        IF book_cursor%NOTFOUND THEN
            v_done := TRUE;  -- Exit loop when all records are processed
        END IF;
    END LOOP;

    -- Close the cursor
    CLOSE book_cursor;
END;
/

SET SERVEROUTPUT ON;
DECLARE
    v_author bk_author%TYPE := '&authorID';
    CURSOR book_cursor (v_author) IS 
    SELECT 
BEGIN
    
END;
/

-- Option 2

SET SERVEROUTPUT ON;
DECLARE
    -- Declare the author ID variable
    v_author bk_author.authorid%TYPE := '&authorID';

    -- Declare the cursor with the authorID passed as a parameter
    CURSOR book_cursor (v_author IN bk_author.authorid%TYPE) IS
        SELECT
            a.authorid, a.lname, a.fname,
            b.isbn, b.title, b.category, b.pubdate,
            p.name, c.retail
        FROM bk_author a
        JOIN bk_books b ON a.authorid = b.authorid
        JOIN bk_publisher p ON b.pubid = p.pubid
        JOIN bk_cost c ON c.isbn = b.isbn
        WHERE a.authorid = v_author
        ORDER BY b.isbn DESC;

    -- Declare the record structure for the cursor
    v_book_rec book_cursor%ROWTYPE;

BEGIN
    -- Check if the cursor is not already open
    IF NOT book_cursor%ISOPEN THEN
        OPEN book_cursor(v_author);
    END IF;
 
    -- Loop through the cursor results
    IF book_cursor%FOUND THEN
        LOOP
            FETCH book_cursor INTO v_book_rec;
            EXIT WHEN book_cursor%NOTFOUND;

            -- Output the book details using DBMS_OUTPUT
            DBMS_OUTPUT.PUT_LINE('======================================================================');
            DBMS_OUTPUT.PUT_LINE(v_book_rec.authorid || ' ' || INITCAP(v_book_rec.lname) || ' ' || INITCAP(v_book_rec.fname));
            DBMS_OUTPUT.PUT_LINE(v_book_rec.isbn || ' - ' || INITCAP(v_book_rec.title) || ' ' || INITCAP(v_book_rec.category) ||
                                 ' published on ' || TO_CHAR(v_book_rec.pubdate, 'DD Month YYYY') ||
                                 ' published by: ' || UPPER(v_book_rec.name) ||
                                 ' sold for ' || TO_CHAR(v_book_rec.retail, '$99.99'));
            DBMS_OUTPUT.PUT_LINE('======================================================================');
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No books found for the given author ID.');
    END IF;

    -- Close the cursor
    CLOSE book_cursor;
END;
/

-- QUESTION 2 CT2

SET SERVEROUTPUT ON;
DECLARE
    -- Define an associative array (indexed table) to store retail prices
    TYPE retail_prices_table_type IS TABLE OF bk_cost.retail%TYPE
    INDEX BY PLS_INTEGER;

    r_prices retail_prices_table_type;  -- Variable to store prices
    v_index PLS_INTEGER := 1;           -- Counter for indexing
    v_category bk_books.category%TYPE := UPPER('COMPUTER');  -- Category to filter books

BEGIN
    -- Fetch retail prices for books in the given category
    FOR book_rec IN (SELECT c.retail 
                     FROM bk_cost c 
                     JOIN bk_books b ON c.isbn = b.isbn 
                     WHERE b.category = v_category) 
    LOOP
        -- Store the price in the array
        r_prices(v_index) := book_rec.retail;

        -- Display the price correctly
    DBMS_OUTPUT.PUT_LINE('Book ' || v_index || ' Price: ' || TO_CHAR(r_prices(v_index), '$99.99'));

        -- Increment the index
        v_index := v_index + 1;
    END LOOP;
END;
/
-- USING A IMPLICIT CURSORS(DEFAULT) as record(container to hold values of SELECT STATEMN)
-- ALOSO USINH SELECT staement as for LOOP codition(Starting and ending)
-- cursor temporaty(in=implice record aslo hold by column names to retieve these values you can say dot (.column name)


SET SERVEROUTPUT ON;
DECLARE
    -- Define an associative array (indexed table) to store retail prices
    TYPE retail_prices_table_type IS TABLE OF bk_cost.retail%TYPE
    INDEX BY PLS_INTEGER;

    r_prices retail_prices_table_type;  -- Variable to store prices
    v_index PLS_INTEGER := 1;           -- Counter for indexing
    v_category bk_books.category%TYPE := UPPER('COMPUTER');  -- Category to filter books

BEGIN
    -- Fetch retail prices for books in the given category
    FOR book_rec IN (SELECT c.retail 
                     FROM bk_cost c 
                     JOIN bk_books b ON c.isbn = b.isbn 
                     WHERE b.category = v_category) 
    LOOP
        -- Store the price in the array
        r_prices(v_index) := book_rec.retail;

        -- Display the price correctly
    DBMS_OUTPUT.PUT_LINE('Book ' || v_index || ' Price: ' || TO_CHAR(r_prices(v_index), '$99.99'));

        -- Increment the index
        v_index := v_index + 1;
    END LOOP;
END;
/

--- looping rhtough all the values on the table's column base on a condition

SET SERVEROUTPUT ON;
DECLARE
    v_authorID bk_books.authorid%type  := '&AUthor_ID';
    v_category bk_books.category%type;
    
BEGIN
    FOR implicit_rec IN (SELECT category INTO v_category FROM bk_books b
        WHERE authorid = v_authorID ) LOOP
            IF implicit_rec.category = 'FITNESS' THEN
                DBMS_OUTPUT.PUT_LINE('A healthy choice!');
            ELSIF implicit_rec.category = 'COMPUTER' THEN
                DBMS_OUTPUT.PUT_LINE('Tech knowledge at your fingertips!');
            ELSE 
              DBMS_OUTPUT.PUT_LINE('Check out this book!');
        END IF;
    END LOOP;
    
END;
/

-- POPULTAYIN AN ASSOSCIATIVE INDEX BY TABLE(ARRAY )A DN FINDING THE MAX RETAIL PRICE 

SET SERVEROUTPUT ON;
DECLARE
    v_index PLS_INTEGER := 1;
    v_total_retail bk_costs.retail%TYPE := 0;
    v_max_price NUMBER := 0;

    -- Declare associative arrays (INDEX BY tables)
    TYPE isbn_table_type IS TABLE OF bk_books.isbn%TYPE 
	INDEX BY PLS_INTEGER;
	rec_isbn isbn_table_type;
	
    TYPE retail_table_type IS TABLE OF bk_costs.retail%TYPE 
	INDEX BY PLS_INTEGER;
    rec_retail retail_table_type;
	
	
    v_length PLS_INTEGER;

BEGIN
    -- Populate associative arrays by looping through the query result
    FOR i IN (SELECT c.retail, b.isbn
              FROM bk_books b
              JOIN bk_costs c ON c.isbn = b.isbn
              WHERE b.category = 'COOKING') 
    LOOP
        rec_isbn(v_index) := i.isbn;     -- Store ISBN values
        rec_retail(v_index) := i.retail; -- Store retail values
        
        v_total_retail := v_total_retail + i.retail;

        DBMS_OUTPUT.PUT_LINE('ID NUMBER ' || rec_isbn(v_index) || ' is under the COOKING category');
        
        v_index := v_index + 1;
    END LOOP;
    
    -- ✅ FIX: Use a proper number format
    DBMS_OUTPUT.PUT_LINE('Total retail value of COOKING BOOKS: ' || TO_CHAR(v_total_retail, 'FM9999999.99'));

    -- Find the max price in the retail associative array
    v_length := v_index - 1;  -- Store the last used index

    FOR i IN 1..v_length LOOP
        IF rec_retail(i) > v_max_price THEN
            v_max_price := rec_retail(i);
        END IF;
    END LOOP;

    -- ✅ FIX: Use correct formatting for max price
    DBMS_OUTPUT.PUT_LINE('Maximum Retail Price: ' || TO_CHAR(v_max_price, 'FM9999999.99'));

END;
/

SET SERVEROUTPUT ON;
DECLARE
    TYPE book_record_type IS RECORD (
        isbn bk_books.isbn%TYPE,
        title bk_books.title%TYPE,
        retail bk_costs.retail%TYPE
    );

    book_rec book_record_type;
    CURSOR book_cur IS 
        SELECT b.isbn, b.title, c.retail
        FROM bk_books b
        JOIN bk_costs c ON b.isbn = c.isbn
        WHERE b.category = 'SCIENCE';

BEGIN
    OPEN book_cur;
    LOOP
        FETCH book_cur INTO book_rec;
        EXIT WHEN book_cur%NOTFOUND; -- Exit when no more records
        
        DBMS_OUTPUT.PUT_LINE('ISBN: ' || book_rec.isbn || ', Title: ' || book_rec.title || ', Price: ' || book_rec.retail);
    END LOOP;
    CLOSE book_cur;
END;
/


SET SERVEROUTPUT ON;
DECLARE
    TYPE books_record_type IS RECORD (
        isbn  bk_books.isbn%type,
        title bk_books.title%type,
        retail bk_costs.retail%type
    );   
    
    book_rec books_record_type;
     CURSOR book_cur IS 
        SELECT b.isbn, b.title, c.retail
        FROM bk_books b
        JOIN bk_costs c ON b.isbn = c.isbn
        WHERE b.category = 'COMPUTER';
        
BEGIN
    OPEN book_cur;
    LOOP
        FETCH book_cur INTO book_rec;
        EXIT WHEN book_cur%NOTFOUND; 
        DBMS_OUTPUT.PUT_LINE('ISBN: ' || book_rec.isbn || ', Title: ' || book_rec.title || ', Retail Price: ' || TO_CHAR(book_rec.retail, 'FM9999.99'));
    END LOOP;
    CLOSE book_cur;
    
END;
/





SET SERVEROUTPUT ON;
DECLARE 
	v_mark NUMBER := &mark
	v_result VARCHAR2(4);
BEGIN
	IF 	v_mark > 90 THEN
		v_result := 'A'
		ELSIF v_mark >= 80 THEN
			v_result := 'B'
		ELSIF v_mark >= 70 THEN
			v_result := 'C'
		ELSIF v_mark >= 60 THEN
			v_result := 'D'
		ELSIF v_mark >= 50 THEN
			v_result := 'E'	
		ELSE
			v_result := 'Fail'
		
	END IF;	
	DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

SET SERVEROUTPUT ON;
DECLARE 
	v_mark NUMBER := &mark;
	v_result VARCHAR2(4);
BEGIN
	v_result := 
	CASE
			WHEN v_mark >= 90 THEN 'A'
			WHEN v_mark >= 80 THEN 'B'
			WHEN v_mark >= 70 THEN 'C'
			WHEN v_mark >= 60 THEN 'D'
			WHEN v_mark >= 50 THEN 'E'
		ELSE 'FAIL'
	END;
	DBMS_OUTPUT.PUT_LINE(v_result);
END;
/



SET SERVEROUTPUT ON;

DECLARE 
	v_num_hours NUMBER := &hours;
	v_val_rate NUMBER := &rate;
	v_monthy_gross NUMBER(5,2);
	v_tax NUMBER(7,2);
	v_net_pay NUMBER(7,2) ;
	v_annual_salary NUMBER(7,2);
	g_rate NUMBER(5,2) := 0.28;
	
BEGIN
	v_monthy_gross := v_num_hours * v_val_rate;
	v_tax := v_monthy_gross * g_rate;
	v_net_pay := v_monthy_gross - v_tax;
	v_annual_salary := v_monthy_gross * 12;
	
	DBMS_OUTPUT.PUT_LINE('THe gross pay is '|| TO_CHAR(v_monthy_gross,'fmL99,99999'));
	DBMS_OUTPUT.PUT_LINE('The total tax is '|| TO_CHAR(v_tax,'fmL99,99,999'));
	DBMS_OUTPUT.PUT_LINE('The Net pay is '|| TO_CHAR(v_net_pay,'fmL99,99,999'));
	DBMS_OUTPUT.PUT_LINE('The annual salary is '|| TO_CHAR(v_annual_salary,'fmL99999'));

END;
/

SET SERVEROUTPUT ON;

BEGIN
	
	DELETE FROM s_student
	WHERE studnr = 98004556;
	
	IF SQL%ROWCOUNT > 0 THEN
		DBMS_OUTPUT.PUT_LINE('Record(s) sucessfully deleted.');
	END IF;	
END;
/

SET SERVEROUTPUT ON;

DECLARE

	TYPE subj_table_type IS TABLE OF s_subject%ROWTYPE
	INDEX BY PLS_INTEGER;
	v_iterator NUMBER := 1;
	subj_rec subj_table_type;	
	v_subject_code s_subject.subj_code%type := '&SUBJECTCODE';
BEGIN
	
	FOR i IN (SELECT subj_name ,PREREQ,subj_fee
			INTO subj_rec(i)
			FROM s_subject 
			WHERE subj_code = v_subject_code
	) LOOP 
	END LOOP;
	
	FOR i IN (SELECT * FROM subj_rec) LOOP
		IF subj_rec(v_iterator).PREREQ(i) IS NOT NULL THEN
			DBMS_OUTPUT.PUT_LINE('Subject Details');
			DBMS_OUTPUT.PUT_LINE('================================================');
			DBMS_OUTPUT.PUT_LINE('Subject name :' ||subj_code||'-'||subj_rec(i).subj_name);
			DBMS_OUTPUT.PUT_LINE('Cost :'||TO_CHAR(subj_rec(i).subj_fee,'fmL99,999,99'));
			DBMS_OUTPUT.PUT_LINE('Prerequisite  :' ||'Yes');
			
		ELSE 
			DBMS_OUTPUT.PUT_LINE('Subject Details')THEN 
			DBMS_OUTPUT.PUT_LINE('Subject Details');
			DBMS_OUTPUT.PUT_LINE('================================================');
			DBMS_OUTPUT.PUT_LINE('Subject name :' ||subj_code||'-'||subj_rec(i).subj_name);
			DBMS_OUTPUT.PUT_LINE('Cost :'||TO_CHAR(subj_rec(i).subj_fee,'fmL99,999,99'));
			DBMS_OUTPUT.PUT_LINE('Prerequisite  :' ||'NO');
		END IF;
		v_iterator := v_iterator + 1	
	
	END LOOP;
END;
/

-- NAother solution 


SET SERVEROUTPUT ON;

DECLARE
    TYPE subj_table_type IS TABLE OF s_subject%ROWTYPE INDEX BY PLS_INTEGER;
    subj_rec subj_table_type;    
    v_iterator PLS_INTEGER := 0;
    v_subject_code s_subject.subj_code%TYPE := '&SUBJECTCODE';
    v_row s_subject%ROWTYPE;  -- Explicit record variable to hold row data
BEGIN
    -- Fetch data into collection
    FOR rec IN (SELECT * FROM s_subject WHERE subj_code = v_subject_code) LOOP
        v_iterator := v_iterator + 1;
        
        -- Assign fields manually
        v_row.subj_code := rec.subj_code;
        v_row.subj_name := rec.subj_name;
        v_row.PREREQ := rec.PREREQ;
        v_row.subj_fee := rec.subj_fee;
        
        subj_rec(v_iterator) := v_row;  -- Assign the record to the collection
    END LOOP;

    -- Check if records exist
    IF subj_rec.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No subject found for the given code: ' || v_subject_code);
    ELSE
        -- Loop through the collection
        v_iterator := subj_rec.FIRST;
        WHILE v_iterator IS NOT NULL LOOP
            DBMS_OUTPUT.PUT_LINE('Subject Details');
            DBMS_OUTPUT.PUT_LINE('================================================');
            DBMS_OUTPUT.PUT_LINE('Subject name: ' || subj_rec(v_iterator).subj_code || ' - ' || subj_rec(v_iterator).subj_name);
            DBMS_OUTPUT.PUT_LINE('Cost: ' || TO_CHAR(subj_rec(v_iterator).subj_fee, 'fmL99,999,99'));

            IF subj_rec(v_iterator).PREREQ IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('Prerequisite: Yes');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Prerequisite: No');
            END IF;

            v_iterator := subj_rec.NEXT(v_iterator);  -- Move to the next index
        END LOOP;
    END IF;
END;
/

SET SERVEROUTPUT ON;
--DEFINE student_number = 96445566
DECLARE
	 TYPE student_details_type IS RECORD (
        studnr  s_student.studnr%type,
		surname s_student.surname%type,
        initials s_student.initials%type,
		num_subj_name NUMBER(3),
		dip_name  s_diploma.dip_name%type,
		fac_name s_faculty.fac_name%type,
		v_amount_due s_subject.subj_fee%type
    );
	student_details_rec student_details_type;
	
	CURSOR cur_stud_details IS 
	SELECT stud.studnr,stud.surname,stud.initials,COUNT(subj.subj_name),dip.dip_name,fac.fac_name,SUM(subj.subj_fee)
	FROM s_student stud
	JOIN s_registration reg ON stud.studnr = reg.studnr
	JOIN s_subject subj ON reg.subj_code = subj.subj_code
	JOIN s_diploma dip ON subj.dip_code = dip.dip_code
	JOIN s_faculty fac ON dip.fac_code = fac.fac_code
	WHERE stud.studnr  = 97003455
	GROUP by stud.studnr,stud.surname,stud.initials,dip.dip_name,fac.fac_name;
	
BEGIN
	OPEN cur_stud_details;
		LOOP
			FETCH cur_stud_details INTO student_details_rec;
			EXIT WHEN cur_stud_details%NOTFOUND;
		
			DBMS_OUTPUT.PUT_LiNE('Student Details');
			DBMS_OUTPUT.PUT_LiNE('=========================================');
			DBMS_OUTPUT.PUT_LiNE('Faculty :'||UPPER(student_details_rec.fac_name));
			DBMS_OUTPUT.PUT_LiNE('Diploma :'||UPPER(student_details_rec.dip_name));
			DBMS_OUTPUT.PUT_LiNE('Number of subjencts :'||student_details_rec.num_subj_name);
			DBMS_OUTPUT.PUT_LiNE('Total amount due :'||TO_CHAR(student_details_rec.v_amount_due,'fmL99,999'));
		END LOOP;
	
	CLOSE cur_stud_details;
	
END;
/


 -- CHATGBT Question paper
 --Question 1
SET SERVEROUTPUT ON;

DECLARE
	CURSOR student_cur IS 
	SELECT surname ,birthdate
	FROM s_student;
	
	stud_details_rec student_cur%ROWTYPE;
BEGIN
 
	OPEN student_cur;
	LOOP 
		FETCH student_cur INTO stud_details_rec;
		EXIT WHEN student_cur%NOTFOUND;
		
		DBMS_OUTPUT.PUT_LINE('Student : '||stud_details_rec.surname||CHR(10)||'Bithdate : '||TO_CHAR(stud_details_rec.birthdate,'YYYY-MM-DD'));
	END LOOP;
	CLOSE student_cur;
END;
/

--- Question 2

SET SERVEROUTPUT ON;

DECLARE
    -- Define an associative array type storing full faculty records
    TYPE fac_table_type IS TABLE OF s_faculty%ROWTYPE INDEX BY PLS_INTEGER;
    
    -- Declare a variable to hold faculty records
    fac_rec fac_table_type;
    
    -- Declare a record type to hold a single row temporarily
    faculty_record s_faculty%ROWTYPE;
    
    i PLS_INTEGER := 1;
BEGIN
    -- Populate the array
    FOR faculty_row IN (SELECT fac_code, fac_name FROM s_faculty WHERE fac_code IN ('CS', 'EN')) LOOP
        -- Assign values to the declared record first
       faculty_record.fac_code := faculty_row.fac_code;
       faculty_record.fac_name := faculty_row.fac_name;
        
        -- Store the record into the associative array
        fac_rec(i) := faculty_record;
        
        i := i + 1;  -- Increment counter
    END LOOP;
    
    -- Iterate over the associative array and display results
    FOR j IN fac_rec.FIRST..fac_rec.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Faculty Code: ' || fac_rec(j).fac_code || CHR(10) ||
                             'Faculty Name: ' || fac_rec(j).fac_name);
    END LOOP;
END;
/




SET SERVEROUTPUT ON;
DECLARE
    TYPE dept_table_type IS TABLE OF departments%ROWTYPE
    INDEX BY PLS_INTEGER;
    dept_table dept_table_type;
BEGIN
    SELECT * INTO dept_table(1) -- specify the row 
    FROM departments
    WHERE department_id = 10;
    
    dbms_output.put_line(dept_table(1).department_id||' works at(as) '||dept_table(1).department_name||' office is at section '||dept_table(1).location_id);
END;
/

--Question 2
SET SERVEROUTPUT ON;

DECLARE
    TYPE fac_table_type IS TABLE OF s_faculty%ROWTYPE INDEX BY PLS_INTEGER;
    
    fac_rec fac_table_type;  -- Associative array
    fac_record s_faculty%ROWTYPE;
    
    i PLS_INTEGER := 1;
BEGIN
=    FOR rec IN (SELECT fac_code, fac_name FROM s_faculty WHERE fac_code IN ('CS', 'EN')) LOOP
        -- Assign values to the record explicitly
        fac_record.fac_code := rec.fac_code;
        fac_record.fac_name := rec.fac_name;
        
        -- Store the record in the associative array
        fac_rec(i) := fac_record;
        
        i := i + 1;  -- Increment counter
    END LOOP;
    
    -- Iterate over the associative array and display results
    FOR j IN fac_rec.FIRST .. fac_rec.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Faculty Code: ' || fac_rec(j).fac_code || CHR(10) ||
                             'Faculty Name: ' || fac_rec(j).fac_name);
    END LOOP;
END;
/

-- Question 3
SET SERVEROUTPUT ON;
	
DECLARE
	v_student_number s_registration.studnr%type := &Student_number_input;
	v_total_amount_due s_subject.subj_fee%type;
	
BEGIN
	SELECT SUM(subj.subj_fee)
	INTO v_total_amount_due
	FROM s_registration reg
	JOIN s_subject subj ON subj.subj_code = reg.subj_code
	WHERE reg.studnr = v_student_number;
	
	DBMS_OUTPUT.PUT_LINE('Toatal fess due '||TO_CHAR(v_total_amount_due ,'fmL99,999,99'));
END;
/


-- Question 4
SET SERVEROUTPUT ON;

DECLARE 

	diploma_rec s_diploma%ROWTYPE;
BEGIN
	SELECT * INTO diploma_rec 
	FROM s_diploma
	WHERE fac_code = 'IT';
	
	DBMS_OUTPUT.PUT_LiNE('Diploma Code :'||diploma_rec.dip_code||CHR(10)||'Diploma Name :'||diploma_rec.dip_name||CHR(10)||'Facaulty Code :'||diploma_rec.fac_code);
END;

/


--Question 5

SET SERVEROUTPUT ON;

DECLARE 

BEGIN

	INSERT INTO s_student
	VALUES(98005000,'Ntlanagniso','SA','M',SYSDATE);
	
	IF SQL%ROWCOUNT > 0 THEN
		DBMS_OUTPUT.PUT_LiNE('Row successfully added on the table');
	END IF;	
END;
/

--QUESTION 6


SET SERVEROUTPUT ON;

DECLARE 

	TYPE subj_record_type IS record
	(
		initials s_student.initials%type,
		surname s_student.surname%type,
		dip_name s_diploma.dip_name%type
	);
	student_rec subj_record_type;
	
	CURSOR stud_cur IS 
		SELECT stud.initials , stud.surname ,dip.dip_name
		FROM s_student stud
		JOIN s_registration reg ON stud.studnr  = reg.studnr
		JOIN s_subject subj ON reg.subj_code = subj.subj_code
		JOIN s_diploma dip ON dip.dip_code = subj.dip_code;
	
BEGIN
	OPEN stud_cur;
	LOOP 
		FETCH stud_cur INTO student_rec;
		EXIT WHEN stud_cur%NOTFOUND;
		
		DBMS_OUTPUT.PUT_LINE('Student name: '|| student_rec.initials||' '||student_rec.surname||CHR(10)||'Diploma :'|| student_rec.dip_name);
	
	END LOOP;
	
	CLOSE stud_cur;
END;
/
SET SERVEROUTPUT ON;

DECLARE 
    -- Define a record type for storing fetched student information
    TYPE subj_record_type IS RECORD
    (
        initials s_student.initials%TYPE,
        surname s_student.surname%TYPE,
        dip_name s_diploma.dip_name%TYPE
    );
    
    -- Declare a variable of the record type
    student_rec subj_record_type;
    
    -- Define a cursor to fetch student data
    CURSOR stud_cur IS 
        SELECT stud.initials, stud.surname, dip.dip_name
        FROM s_student stud
        JOIN s_registration reg ON stud.studnr = reg.studnr
        JOIN s_subject subj ON reg.subj_code = subj.subj_code
        JOIN s_diploma dip ON dip.dip_code = subj.dip_code;
    
BEGIN
    -- Open the cursor and start looping through the results
    OPEN stud_cur;

    LOOP 
        FETCH stud_cur INTO student_rec; 
        EXIT WHEN stud_cur%NOTFOUND; -- Exit the loop when no more rows are found
        
        -- Output the student's details using DBMS_OUTPUT
        DBMS_OUTPUT.PUT_LINE('Student name: ' || student_rec.initials || ' ' || student_rec.surname || CHR(10) || 'Diploma: ' || student_rec.dip_name);
    END LOOP;
    
    -- Close the cursor after processing
    CLOSE stud_cur;
END;
/


-- Question 8
SET SERVEROUTPUT ON;

DECLARE
	
	TYPE faculty_record_type IS RECORD(
		fac_name s_faculty.fac_name%type,
		v_num_of_dip NUMBER(3)
	);
	fac_rec faculty_record_type;
	v_fac_code s_faculty.fac_code%type := '&faculty_code';

BEGIN
	SELECT fac.fac_name, COUNT(dip.dip_name)
	INTO fac_rec
	FROM s_faculty fac
	JOIN s_diploma dip ON fac.fac_code = dip.fac_code
	WHERE fac_code =  v_fac_code;
	
	LOOP
		DBMS_OUTPUT.PUT_LINE('Faculty Name :'||fac_rec.fac_name||CHR(10)||'Number Of Diplomas :'||fac_rec.v_num_of_dip);
		EXIT WHEN fac_rec%NOTFOUND;
	END LOOP;
END;
/

SET SERVEROUTPUT ON;

DECLARE
    TYPE faculty_record_type IS RECORD (
        fac_name s_faculty.fac_name%TYPE,
        v_num_of_dip NUMBER(3)
    );

    fac_rec faculty_record_type;
    v_fac_code s_faculty.fac_code%TYPE := '&faculty_code';

BEGIN
    SELECT fac.fac_name, COUNT(dip.dip_name)
    INTO fac_rec.fac_name, fac_rec.v_num_of_dip
    FROM s_faculty fac
    LEFT JOIN s_diploma dip ON fac.fac_code = dip.fac_code
    WHERE fac.fac_code = v_fac_code
    GROUP BY fac.fac_name;

    DBMS_OUTPUT.PUT_LINE('Faculty Name: ' || fac_rec.fac_name);
    DBMS_OUTPUT.PUT_LINE('Number Of Diplomas: ' || fac_rec.v_num_of_dip);

END;
/
-- QUEstion 10

SET SERVEROUTPUT ON;

DECLARE
    TYPE faculty_record_type IS RECORD (
        fac_name s_faculty.fac_name%TYPE,
        v_num_of_dip NUMBER(3)
    );

    fac_rec faculty_record_type;
    v_fac_code s_faculty.fac_code%TYPE := '&faculty_code';

BEGIN
    SELECT fac.fac_name, COUNT(dip.dip_name)
    INTO fac_rec.fac_name, fac_rec.v_num_of_dip
    FROM s_faculty fac
    JOIN s_diploma dip ON fac.fac_code = dip.fac_code
    WHERE fac.fac_code = v_fac_code
    GROUP BY fac.fac_name;

    DBMS_OUTPUT.PUT_LINE('Faculty Name: ' || fac_rec.fac_name);
    DBMS_OUTPUT.PUT_LINE('Number Of Diplomas: ' || fac_rec.v_num_of_dip);

END;
/

SET SERVEROUTPUT ON;

	v_surname s_student.surname%type;
	v_subject_code s_registration.subj_code%type;
BEGIN
    SELECT stud.surname,reg.subj_code
    INTO v_surname,v_subject_code
    FROM s_student stud
    INNER JOIN s_registration reg ON stud.studnr = reg.studnr
    WHERE subj_code IN('IA1','QT1')
    GROUP BY reg.subj_code;

    DBMS_OUTPUT.PUT_LINE('Student Name: ' || v_surname);
    DBMS_OUTPUT.PUT_LINE('Subject code : ' || v_subject_code);

END;
/



SET SERVEROUTPUT ON;

DECLARE
    -- Declare a cursor for fetching multiple records
    CURSOR student_cur IS
        SELECT stud.surname, reg.subj_code
        FROM s_student stud
        INNER JOIN s_registration reg ON stud.studnr = reg.studnr
        WHERE reg.subj_code IN ('IA1', 'QT1');

    -- Declare variables to hold fetched data
	
	
    v_surname s_student.surname%TYPE;
    v_subject_code s_registration.subj_code%TYPE;
    
BEGIN
    -- Open the cursor and fetch rows
    OPEN student_cur;
    
    LOOP
        FETCH student_cur INTO v_surname, v_subject_code;
        EXIT WHEN student_cur%NOTFOUND;
        
        -- Print output for each student
        DBMS_OUTPUT.PUT_LINE('Student Name: ' || v_surname);
        DBMS_OUTPUT.PUT_LINE('Subject Code: ' || v_subject_code);
    END LOOP;
    
    -- Close the cursor
    CLOSE student_cur;
END;
/


DECLARE 
	v_betwwen_date s_student.birthdate%type := '01/01/00';
	
	CURSOR stud_cur IS 
	SELECT studnr ,surname ,birthdate
	FROM s_student
	WHERE studnr IN (96445566,95665432) 
	FOR UPDATE OF surname NOWAIT;
	
	
BEGIN
	FOR rec IN stud_cur loop
		IF rec.birthdate < TO_DATE(v_betwwen_date,'DD/MM/YY') THEN 
			UPDATE s_student
			SET surname = INITCAP(rec.surname)
			WHERE CURRENT OF stud_cur;
		END IF;	
	END LOOP;
END;
/

--QUESTION 1
DECLARE 
    v_between_date DATE := TO_DATE('01-JAN-2000', 'DD-MON-YYYY');
	
	v_stud_number s_student.studnr%type;
	v_surname s_student.surname%type;
	v_birthdate s_student.birthdate%type;
	
    CURSOR stud_cur IS 
    SELECT studnr, surname, birthdate
    FROM s_student
    WHERE birthdate < v_between_date 
    FOR UPDATE OF birthdate NOWAIT;

BEGIN
	OPEN stud_cur;
    LOOP
		FETCH stud_cur INTO v_stud_number,v_surname,v_birthdate;
		EXIT WHEN stud_cur%NOTFOUND;
		
        UPDATE s_student
        SET birthdate = TO_DATE(TO_CHAR(v_birthdate,'DD-MON-YYYY'))
        WHERE CURRENT OF stud_cur;
        
        DBMS_OUTPUT.PUT_LINE('Student ' || v_stud_number || ' surname updated to ' || UPPER(v_surname) || ' born on ' ||TO_CHAR(v_birthdate,'DD-MON-YYYY'));
    END LOOP;
	CLOSE stud_cur;
END;
/


--Question 2

SET SERVEROUTPUT ON;

DECLARE

	TYPE student_record_type IS RECORD(
		studnr s_student.studnr%type,
		surname s_student.surname%type,
		initials s_student.initials%type
		
	);
	subject_rec student_record_type;
	
	p_subj_code s_registration.subj_code%type := 'SP1';
	
    CURSOR subject_cursor IS
	SELECT stud.studnr,stud.surname,stud.initials
	FROM s_student stud
	JOIN s_registration reg ON stud.studnr  = reg.studnr
	WHERE subj_code = p_subj_code;

BEGIN
	OPEN subject_cursor;
	LOOP
		
		FETCH subject_cursor INTO subject_rec;
		EXIT WHEN subject_cursor%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('STUDENT :'||subject_rec.studnr||CHR(10)||'SURNAME :'||subject_rec.surname||' '||subject_rec.initials);
	
	END LOOP;
	
	CLOSE subject_cursor;
END;
/

--parameterized argumnent of cusrsors 

SET SERVEROUTPUT ON;

DECLARE

    TYPE student_record_type IS RECORD (
        studnr  s_student.studnr%type,
        surname s_student.surname%type,
        initials s_student.initials%type
    );

    subject_rec student_record_type;
    p_subj_code s_registration.subj_code%type := 'SP1'; 

    CURSOR subject_cursor(p_subj_code IN s_registration.subj_code%type) IS
        SELECT stud.studnr, stud.surname, stud.initials
        FROM s_student stud
        JOIN s_registration reg ON stud.studnr = reg.studnr
        WHERE reg.subj_code = p_subj_code;  -- Use the passed parameter for filtering

BEGIN
    OPEN subject_cursor(p_subj_code);
    LOOP
        FETCH subject_cursor INTO subject_rec;
        EXIT WHEN subject_cursor%NOTFOUND;  -- Exit the loop when no more rows are fetched

        DBMS_OUTPUT.PUT_LINE('Student: ' || subject_rec.studnr || 
                             ', Surname: ' || subject_rec.surname || 
                             ', Initials: ' || subject_rec.initials);
    END LOOP;
    CLOSE subject_cursor;
END;
/

-- QUestion 3

SET SERVEROUTPUT ON;

DECLARE
	TYPE tution_table_type IS TABLE OF s_subject%ROWTYPE
	INDEX BY PLS_INTEGER;
	
	tution_rec tution_table_type;
	subj_rec s_subject%ROWTYPE;
	
	i PLS_INTEGER := 1;
BEGIN
	FOR rec IN (SELECT subj_code,subj_fee
				FROM s_subject
				WHERE subj_code IN('DS2','IS2')
	) LOOP
		subj_rec.subj_code := rec.subj_code;
		subj_rec.subj_fee := rec.subj_fee;
		
		tution_rec(i) := subj_rec;
		i:= i + 1;
	END LOOP;
	
	FOR j IN tution_rec.FIRST..tution_rec.LAST loop
		DBMS_OUTPUT.PUT_LINE('STUDENT '||tution_rec(j).subj_code ||'FEES :'||tution_rec(j).subj_fee);
	END LOOP;
END;
/

-- Question 4
SET SERVEROUTPUT ON;
DECLARE 
	
	
	TYPE faculty_table_type IS TABLE OF s_faculty%ROWTYPE
	INDEX BY PLS_INTEGER;
	fac_rec faculty_table_type;
	
	record_fac s_faculty%ROWTYPE;
	n PLS_INTEGER := 1;
	
BEGIN
	
	FOR rec IN (SELECT * FROM s_faculty) LOOP
		record_fac.fac_name := rec.fac_name;
		
		fac_rec(n):= record_fac;
		n := n + 1;
	END LOOP;
	
	FOR i IN fac_rec.FIRST..fac_rec.LAST loop
		DBMS_OUTPUT.PUT_LINE('Faculty :'||fac_rec(i).fac_name);
	END LOOP;

END;
/

-- Question 1 AWM

SET SERVEROUTPUT ON;
DECLARE 
	TYPE job_service_record IS RECORD (
        job_card_no JobCard.JobCardNo%TYPE,
        start_date JobCard.DateJobTBD%TYPE,
        finish_date JobCard.DateJobFin%TYPE,
        service_desc Service.SDesc%TYPE,
        service_rate Service.SRate%TYPE,
        service_hours Service.serviceHours%TYPE
    );
	rec job_service_record;
	
	v_job_card_no Jobcard.JobCardNo%type := &jobcardno;
	v_total NUMBER := 0;
	
	CURSOR amw_cur IS
        SELECT job_c.JobCardNo, job_c.DateJobTBD, job_c.DateJobFin,serv.SDesc, serv.SRate, serv.serviceHours
        FROM JobCard job_c
        JOIN JobService job_s ON job_c.JobCardNo = job_s.JobCardNo
        JOIN Service serv ON serv.SCode = job_s.SCode
        WHERE SDesc LIKE '%_km%';
		
		
BEGIN
	
	OPEN amw_cur;
	DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------');

	LOOP
		FETCH amw_cur INTO rec;
		EXIT WHEN amw_cur%NOTFOUND;
		v_total := rec.service_hours * rec.service_rate;
		
		DBMS_OUTPUT.PUT_LINE('Job Card: ' || rec.job_card_no || ' | ' ||'Start Date: ' || TO_CHAR(rec.start_date, 'DD/MM/YYYY') || ' | ' ||'End Date: ' || TO_CHAR(rec.finish_date, 'DD/MM/YYYY') || ' | ' ||
                      'Service Description: ' || rec.service_desc || ' | ' ||
                      'Service Rates: ' || rec.service_rate || ' | ' ||
                      'Service Hours: ' || rec.service_hours || ' | ' ||
                      'Total Cost: ' || v_total);

	DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------');

	END LOOP;
	CLOSE amw_cur;
END;
/

--Question 2
SET SERVEROUTPUT ON;

DECLARE
    v_initial_bankbalance NUMBER(7,2) := 5000.98;
    v_security_alert VARCHAR2(100);
    v_amount NUMBER := 0;
    v_user_option NUMBER := 0;
    continue_loop BOOLEAN := TRUE;  -- ✅ Added Boolean to control the loop
BEGIN
    WHILE continue_loop LOOP
        -- Display ATM Menu
        DBMS_OUTPUT.PUT_LINE('---------------- ATM MENU ----------------');
        DBMS_OUTPUT.PUT_LINE('1 - Deposit Cash');
        DBMS_OUTPUT.PUT_LINE('2 - Withdraw Cash');
        DBMS_OUTPUT.PUT_LINE('3 - Check Balance');
        DBMS_OUTPUT.PUT_LINE('4 - Exit');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------');

        -- Get user input
        v_user_option := &option;

        -- Handle different cases using IF statements
        IF v_user_option = 1 THEN
            DBMS_OUTPUT.PUT_LINE('Enter deposit amount:');
            v_amount := &deposite_amount;
            v_initial_bankbalance := v_initial_bankbalance + v_amount;
            DBMS_OUTPUT.PUT_LINE('✅ Deposit successful! New balance: ' || v_initial_bankbalance);
            continue_loop := FALSE;  -- ✅ Stop the loop after execution

        ELSIF v_user_option = 2 THEN
            DBMS_OUTPUT.PUT_LINE('Enter withdrawal amount:');
            v_amount := &widrawal_amount;

            IF v_amount > v_initial_bankbalance THEN
                DBMS_OUTPUT.PUT_LINE('❌ Insufficient funds! Try an amount within your available balance.');
            ELSIF v_amount > 1200 THEN
                v_security_alert := '⚠️ Warning: You are withdrawing a large sum of money. Be careful!';
                DBMS_OUTPUT.PUT_LINE(v_security_alert);
                v_initial_bankbalance := v_initial_bankbalance - v_amount;
                DBMS_OUTPUT.PUT_LINE('✅ Withdrawal successful! New balance: ' || v_initial_bankbalance);
            ELSE
                v_initial_bankbalance := v_initial_bankbalance - v_amount;
                DBMS_OUTPUT.PUT_LINE('✅ Withdrawal successful! New balance: ' || v_initial_bankbalance);
            END IF;

            continue_loop := FALSE;  -- ✅ Stop the loop after execution

        ELSIF v_user_option = 3 THEN
            DBMS_OUTPUT.PUT_LINE('🔎 Checking Balance...');
            DBMS_OUTPUT.PUT_LINE('💰 Available balance: ' || v_initial_bankbalance);
            continue_loop := FALSE;  -- ✅ Stop the loop after execution

        ELSIF v_user_option = 4 THEN
            DBMS_OUTPUT.PUT_LINE('🚪 Exiting...');
            DBMS_OUTPUT.PUT_LINE('👋 Thank you for using the ATM. Program will now terminate.');
            continue_loop := FALSE;  -- ✅ Properly exit the loop

        ELSE
            DBMS_OUTPUT.PUT_LINE('❌ Invalid option! Please select a valid number (1-4).');
            continue_loop := FALSE;  -- ✅ Prevent infinite looping on invalid input
        END IF;
	
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('✅ Successfully logged out of the program!');
END;
/






CASE
			WHEN v_mark >= 90 THEN 'A'
			WHEN v_mark >= 80 THEN 'B'
			WHEN v_mark >= 70 THEN 'C'
			WHEN v_mark >= 60 THEN 'D'
			WHEN v_mark >= 50 THEN 'E'
		ELSE 'FAIL'
	END;





SET SERVEROUTPUT ON;

DECLARE
    v_initial_bankbalance NUMBER(7,2) := 5000.98;
    v_security_alert VARCHAR2(100);
    v_amount NUMBER := 0;
    v_user_option NUMBER := 0;
BEGIN
    LOOP
        -- Display ATM Menu
        DBMS_OUTPUT.PUT_LINE('---------------- ATM MENU ----------------');
        DBMS_OUTPUT.PUT_LINE('1 - Deposit Cash');
        DBMS_OUTPUT.PUT_LINE('2 - Withdraw Cash');
        DBMS_OUTPUT.PUT_LINE('3 - Check Balance');
        DBMS_OUTPUT.PUT_LINE('4 - Exit');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------');

        -- Get user input
        v_user_option := &option;

        -- Handle different cases using IF statements
        IF v_user_option = 1 THEN
            DBMS_OUTPUT.PUT_LINE('Enter deposit amount:');
            v_amount := &deposite_amount;
            v_initial_bankbalance := v_initial_bankbalance + v_amount;
            DBMS_OUTPUT.PUT_LINE('Deposit successful. Your new balance is: ' || v_initial_bankbalance);

        ELSIF v_user_option = 2 THEN
            DBMS_OUTPUT.PUT_LINE('Enter withdrawal amount:');
            v_amount := &withdraw_amount;

            IF v_amount > v_initial_bankbalance THEN
                DBMS_OUTPUT.PUT_LINE('Insufficient funds. Try an amount within your available balance.');
            ELSIF v_amount > 1200 THEN
                v_security_alert := 'You are withdrawing a large sum of money. Be careful!';
                DBMS_OUTPUT.PUT_LINE(v_security_alert);
                v_initial_bankbalance := v_initial_bankbalance - v_amount;
                DBMS_OUTPUT.PUT_LINE('Your new balance is: ' || v_initial_bankbalance);
            ELSE
                v_initial_bankbalance := v_initial_bankbalance - v_amount;
                DBMS_OUTPUT.PUT_LINE('Your new balance is: ' || v_initial_bankbalance);
            END IF;

        ELSIF v_user_option = 3 THEN
            DBMS_OUTPUT.PUT_LINE('Checking Balance...');
            DBMS_OUTPUT.PUT_LINE('Available balance: ' || v_initial_bankbalance);

        ELSIF v_user_option = 4 THEN
            DBMS_OUTPUT.PUT_LINE('Exiting...');
            DBMS_OUTPUT.PUT_LINE('Thank you for using the ATM. Program will now terminate.');
            EXIT;  -- ✅ Properly exits the loop when option 4 is chosen.

        ELSE
            DBMS_OUTPUT.PUT_LINE('Invalid option chosen. Please select a valid option.');
        END IF;

        DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Successfully logged out of the program!');
END;
/


--Question 3


SET SERVEROUTPUT ON;

DECLARE 
	
	TYPE dev_subject_table IS TABLE OF s_subject%ROWTYPE
	INDEX BY PLS_INTEGER;
	TYPE DS_subj_table_type IS RECORD
	(	
		subject_code s_subject.subj_code%type,
		subject_name s_subject.subj_name%type
	);
	ds_rec DS_subj_table_type;
	
	dev_table_rec dev_subject_table;
	v_index PLS_INTEGER := 0;
	
BEGIN
	
		DBMS_OUTPUT.PUT_LiNE('DEVELOPMENT SOFTWARE SUBJECT CLUSTER');
		DBMS_OUTPUT.PUT_LiNE('=======================================');
	FOR i IN (SELECT subj_code,subj_name
		FROM s_subject
		WHERE dip_code = 'IT' AND subj_code IN ('DSI','DS2','DS2')) LOOP
		
		ds_rec.subj_code := i.subj_code;
		ds_rec.subj_name := i.subj_name;
		
		dev_table_rec(v_index) := i;
		
			
		DBMS_OUTPUT.PUT_LiNE(dev_table_rec(v_index).subject_code ||' - '||dev_table_rec(v_index).subject_name);
		v_index := v_index + 1;		
	END LOOP;	
	
END;
/

--Question 3
SET SERVEROUTPUT ON;

DECLARE 
    TYPE dev_subject_table IS TABLE OF s_subject%ROWTYPE
    INDEX BY PLS_INTEGER;


    dev_table_rec dev_subject_table;
    v_index PLS_INTEGER := 1;  -- Start with 1

BEGIN
    DBMS_OUTPUT.PUT_LINE('DEVELOPMENT SOFTWARE SUBJECT CLUSTER');
    DBMS_OUTPUT.PUT_LINE('=======================================');

    FOR i IN (SELECT subj_code, subj_name
              FROM s_subject
              WHERE subj_code IN ('DS1','DS2','DS3')) LOOP

        -- Assign values to the associative array
        dev_table_rec(v_index).subj_code := i.subj_code;
        dev_table_rec(v_index).subj_name := i.subj_name;
        
        -- Print the values
        DBMS_OUTPUT.PUT_LINE(dev_table_rec(v_index).subj_code || ' - ' || dev_table_rec(v_index).subj_name);
        
        v_index := v_index + 1;        
    END LOOP;

END;
/

--Question 4

SET SERVEROUTPUT ON;

DECLARE 
   
	TYPE CM_subj_table_type IS TABLE OF s_subject%ROWTYPE
	INDEX BY PLS_INTEGER;
	
	cm_rec CM_subj_table_type;
	v_year PLS_INTEGER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('COST AND MANAGEMENT SUBJECT CLUSTER');
    DBMS_OUTPUT.PUT_LINE('=======================================');
	
	FOR rec IN (SELECT subj_code, subj_name
              FROM s_subject
              WHERE subj_code IN ('CM1','CM2','CM3')) LOOP
		
		cm_rec(v_year).subj_code:= rec.subj_code;
		cm_rec(v_year).subj_name:= rec.subj_name;
		
		DBMS_OUTPUT.PUT_LINE(cm_rec(v_year).subj_code || ' - ' || cm_rec(v_year).subj_name);
		v_year:= v_year + 1;
	END LOOP;
END;
/


--============================================ Exceptions ============================================================

SET SERVEROUTPUT ON;
DECLARE

	v_lname VARCHAR2(15);
 
BEGIN

	 SELECT last_name INTO v_lname 
	 FROM employees
	 WHERE first_name='John' AND ROWNUM  = 2; 
	 DBMS_OUTPUT.PUT_LINE ('John''s last name is :' ||v_lname);
	 
END;
/

-- non predefined only code(IMPLICIT)

SET SERVEROUTPUT ON;
DECLARE
	e_overwhelming_data_excep EXCEPTION;
	v_lname VARCHAR2(15);
	PRAGMA EXCEPTION_INIT(e_overwhelming_data_excep, -01422);

BEGIN

	 SELECT last_name INTO v_lname 
	 FROM employees
	 WHERE first_name='John'; 
	 DBMS_OUTPUT.PUT_LINE ('John''s last name is :' ||v_lname);
	 
	 Exception 
	 WHEN e_overwhelming_data_excep THEN
	 DBMS_OUTPUT.PUT_LINE('Your select statemnet retrieved multiple rows .Condiser a cursor');
END;
/


-- use defined (explicit)
SET SERVEROUTPUT ON;
DECLARE
	e_insert_excep EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_insert_excep, -01400);
BEGIN
	INSERT INTO departments 
	(department_id, department_name) VALUES (280, NULL);
	
EXCEPTION
	WHEN e_insert_excep THEN
	DBMS_OUTPUT.PUT_LINE('INSERT OPERATION FAILED');
	DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/	


SET SERVEROUTPUT ON;

DECLARE 

	v_name VARCHAR2(20) := 'Testing';
	e_integrity EXCEPTION;
	e_unique_constraint_violation EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_integrity, -42292);
	PRAGMA EXCEPTION_INIT(e_unique_constraint_violation, -00001);
	e_invalid_department EXCEPTION;
	
BEGIN
	Update departments
	SEt department_id  = 120
	Where department_id  = 130;
	
	IF SQL%NOTFOUND THEN 
		RAISE e_invalid_department;
	END IF;
	
EXCEPTION 
		WHEN e_invalid_department THEN
		DBMS_OUTPUT.PUT_LiNE('No such department id');
		
		WHEN e_unique_constraint_violation THEN
		DBMS_OUTPUT.PUT_LiNE('Error code '|| SQLCODE);
		DBMS_OUTPUT.PUT_LiNE('Error message '|| SQLERRM);
		
		WHEN e_integrity THEN
		DBMS_OUTPUT.PUT_LiNE('Error code '|| SQLCODE);
		DBMS_OUTPUT.PUT_LiNE('Error message '|| SQLERRM);
END;
/

SET SERVEROUTPUT ON;
DECLARE 

	CURSOR sal_cursor IS 
		SELECT e.department_id, employee_id, last_name, salary 
		FROM employees e, departments d 
		WHERE d.department_id = e.department_id
		and d.department_id = 60
		FOR UPDATE OF salary NOWAIT;
	
BEGIN
	
	FOR emp_record IN sal_cursor LOOP 
	
		IF emp_record.salary < 5000 THEN 
			UPDATE employees 
			SET salary = emp_record.salary * 1.10 
			WHERE CURRENT OF sal_cursor; 
		END IF; 
	END LOOP;

END;
/


SET SERVEROUTPUT ON;

DECLARE
	p_authors_ID  bk_author.authorid%type := '&author_id';
	TYPE book_record_type IS RECORD
	(
		book_isbn bk_author.authorid%type,
		book_fname bk_author.fname%type,
		book_lname bk_author.lname%type,
		book_title bk_books.title%type,
		book_category bk_books.category%type,
		book_pubdate bk_books.pubdate%type,
		book_cost bk_costs.cost%type
	);
	rec book_record_type;
	
	CURSOR book_cursor(p_authors_ID IN bk_author.authorid%type) IS 
		SELECT authr.authorid,authr.fname,authr.lname,bks.title,bks.category,bks.pubdate,cst.cost
		FROM bk_author authr
		JOIN bk_books bks ON bks.isbn = authr.authorid
		JOIN bk_costs cst ON cst.isbn = bks.isbn
		WHERE isbn = 'S100';
		

BEGIN	
	IF NOT book_cursor%ISOPEN THEN 
		OPEN book_cursor(p_authors_ID);
	END IF;
	
	WHILE book_cursor%FOUND LOOP
		FETCH book_cursor INTO rec;
		EXIT WHEN book_cursor%NOTFOUND;
		
		DBMS_OUTPUT.PUT_LINE(p_authors_ID||'  '|| rec.book_fname || ' '|| rec.book_lname ||rec.book_isbn|| ' - '|| rec.book_title ||' published on '|| TO_CHAR(rec.book_pubdate,'DD/Month/YYYY') || ' published by : '||rec.book_category || ' sold for '|| TO_CHAR(rec.book_cost,'fmL99999'));
	END LOOP;
	
	CLOSE book_cursor;
END;
/
SET SERVEROUTPUT ON;
DECLARE
	v_category bk_books.category%type := 'Category';
	books_rec bk_books%ROWTYPE;
	
	CURSOR book_cur IS 
		SELECT bks.title, bks.category, auth.lname, auth.fname, pub.name
        FROM bk_author auth
        JOIN bk_books bks ON auth.authorid = bks.authorid
        JOIN bk_publisher pub ON pub.pubid = bks.pubid
        WHERE LOWER(bks.category) = v_category;
		
		e_too_many_rows EXCEPTION;
		PRAGMA EXCEPTION_INIT(e_too_many_rows, -04112);
		
		v_count NUMBER := 0;
		
BEGIN
	FOR books_rec IN book_cur loop
		
		v_count := v_count + 1;

        IF v_count > 1 THEN
            RAISE e_too_many_rows;
        END IF;
		DBMS_OUTPUT.PUT_LiNE('The book '||books_rec.title ||' was written by '||books_rec.fname||'-'||books_rec.lname||' publish by '||books_rec.name ||' under '||books_rec.category ||' category');
	END LOOP;
	
	IF v_count = 0 THEN
        RAISE NO_DATA_FOUND;
    END IF;
	
EXCEPTION
	WHEN NO_DATA_FOUND  THEN 
		DBMS_OUTPUT.PUT_LINE('Unknown error');
	
	WHEN e_too_many_rows THEN 
		DBMS_OUTPUT.PUT_LINE('There are uncountable books and author in this classification.');
	WHEN OTHERS THEN
	    DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
	    DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON;
DECLARE
	
	v_surname s_staff.surname%type;
	v_initials s_staff.initials%type;
	v_fac_code s_faculty.fac_code%type;
	v_fac_name s_faculty.fac_name%type;
	v_job s_staff.job%type;
	
	v_diplomaCode s_diploma.dip_code%type;
	v_dipName s_diploma.dip_name%type;
	
	CURSOR dean_cur IS
	SELECT staff.surname, staff.initials ,staff.job,fac.fac_code,fac.fac_name
	FROM s_staff staff
	JOIN s_faculty fac ON fac.fac_head = staff.staffnr
	WHERE fac.fac_head = staff.staffnr ;
	
	
	CURSOR dip_cur(p_fac_code IN s_faculty.fac_code%type) IS
	SELECT dip.dip_code , dip.dip_name 
	FROM s_diploma dip ,s_faculty fac 
	WHERE fac.fac_head = dip.dip_head;
	
BEGIN
	IF NOT dean_cur%ISOPEN THEN
		OPEN dean_cur;
	END IF;
	
	LOOP
			FETCH dean_cur INTO v_surname ,v_initials,v_job,v_fac_code,v_fac_name;
			EXIT WHEN dean_cur%NOTFOUND;
			
			DBMS_OUTPUT.PUT_LINE(v_job ||' '||v_initials ||'-'||v_surname ||' heads the faculty of :'|| v_fac_code||' - '||v_fac_name ||' having the following diplomas :');
		
			IF NOT dip_cur%ISOPEN THEN
				OPEN dip_cur(v_fac_code);
			END IF;
			
			LOOP
				FETCH dip_cur INTO  v_diplomaCode,v_dipName;
				DBMS_OUTPUT.PUT_LINE(v_job ||' '||v_initials ||'-'||v_surname ||' heads the faculty of :'|| v_fac_code||' - '||v_fac_name ||' having the following diplomas :'||v_diplomaCode ||' - '||v_dipName);
			
			
			EXIT WHEN dean_cur%NOTFOUND;
				END LOOP;
			END LOOP;
		CLOSE dip_cur;
		
SET SERVEROUTPUT ON;
DECLARE
    v_surname s_staff.surname%type;
    v_initials s_staff.initials%type;
    v_fac_code s_faculty.fac_code%type;
    v_fac_name s_faculty.fac_name%type;
    v_job s_staff.job%type;
    
    v_diplomaCode s_diploma.dip_code%type;
    v_dipName s_diploma.dip_name%type;
    
    CURSOR dean_cur IS
        SELECT staff.surname, staff.initials, staff.job, fac.fac_code, fac.fac_name
        FROM s_staff staff
        JOIN s_faculty fac ON fac.fac_head = staff.staffnr;
    
    CURSOR dip_cur(p_fac_code IN s_faculty.fac_code%type) IS
        SELECT dip.dip_code, dip.dip_name 
        FROM s_diploma dip 
        WHERE dip.fac_code = p_fac_code;  -- fixed this line

BEGIN
	IF NOT dean_cur%ISOPEN THEN
		OPEN dean_cur;
	END IF;
    LOOP
        FETCH dean_cur INTO v_surname, v_initials, v_job, v_fac_code, v_fac_name;
        EXIT WHEN dean_cur%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(v_job || ' ' || v_initials || '- ' || v_surname ||' heads the faculty of: ' || v_fac_code || ' - ' || v_fac_name ||' having the following diplomas:');
        IF NOT dip_cur%ISOPEN THEN
				OPEN dip_cur(v_fac_code);
		END IF;
        LOOP
            FETCH dip_cur INTO v_diplomaCode, v_dipName;
            EXIT WHEN dip_cur%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_diplomaCode || ' - ' || v_dipName);
        END LOOP;
        CLOSE dip_cur;
    END LOOP;
    CLOSE dean_cur;
END;
/
SET SERVEROUTPUT ON;
DECLARE
	
	TYPE DS_subj_table_type IS TABLE OF s_subject%ROWTYPE
	INDEX BY BINARY_INTEGER;
	ds_subj_table DS_subj_table_type;
	
BEGIN
	FOR i IN 1..3 LOOP
	
		SELECT * INTO ds_subj_table(i)
		FROM s_subject
		WHERE subj_code LIKE 'DS%' AND SUBSTR(subj_code,-1) = i;
		
		
	END LOOP;
			DBMS_OUTPUT.PUT_LINE('DEVELOPMENT SOFTWARE SUBJECT CLUSTER');
			DBMS_OUTPUT.PUT_LINE('=====================================');
	
	FOR i IN ds_subj_table.first..ds_subj_table.last LOOP

			DBMS_OUTPUT.PUT_LINE(ds_subj_table(i).subj_code|| '- '||ds_subj_table(i).subj_name);
	END LOOP;	
END;
/


SET SERVEROUTPUT ON;
DECLARE
    TYPE ds_subj_table_type IS TABLE OF s_subject%ROWTYPE INDEX BY BINARY_INTEGER;
    ds_subj_table ds_subj_table_type;
    idx INTEGER := 0;
BEGIN
    FOR i IN 1..3 LOOP
        BEGIN
            SELECT *
            INTO ds_subj_table(i)
            FROM s_subject
            WHERE SUBSTR(subj_code, 1, 2) = 'DS'
              AND TO_NUMBER(SUBSTR(subj_code, -1)) = i;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL; -- skip if no matching subject
            WHEN TOO_MANY_ROWS THEN
                DBMS_OUTPUT.PUT_LINE('More than one subject found for DS code ending in ' || i);
        END;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('DEVELOPMENT SOFTWARE SUBJECT CLUSTER');
    DBMS_OUTPUT.PUT_LINE('===================================');

    FOR i IN ds_subj_table.FIRST..ds_subj_table.LAST LOOP
        IF ds_subj_table.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(ds_subj_table(i).subj_code || ' - ' || ds_subj_table(i).subj_name);
        END IF;
    END LOOP;
END;
/


SET SERVEROUTPUT ON;
DECLARE
    
	TYPE CM_subj_table_type IS TABLE OF s_subject%rowtype
	INDEX BY BINARY_INTEGER;
	
	cm_subj_table CM_subj_table_type;

BEGIN
	For i IN 1..3 LOOP
		Select * INTO cm_subj_table(i)
		from s_subject
		WHERE subj_code Like 'CM%' AND SUBSTR(subj_code,-1) = i;
		
	END LOOP;
		DBMS_OUTPUT.PUT_LINE('COST AND MANAGEMENT SUBJECT CLUSTER');
		DBMS_OUTPUT.PUT_LINE('===================================');

	FOR i IN cm_subj_table.first..cm_subj_table.last LOOP
		IF cm_subj_table.EXISTS(i) THEN 
			DBMS_OUTPUT.PUT_LINE(cm_subj_table(i).subj_code|| ' - '||cm_subj_table(i).subj_name);
		END IF;
	END LOOP;
END;
/


-- PL/SQL Test - Question Paper

SET SERVEROUTPUT ON;
DECLARE
    
	CURSOR stud_cur IS
		SELECT surname FROM s_student
		WHERE UPPER(surname) = 'MASHILE'
		FOR UPDATE NOWAIT;

	
BEGIN
	FOR i IN stud_cur loop
		
		UPDATE s_student
		SET gender = 'F'
		WHERE CURRENT OF stud_cur;
	END LOOP;
		COMMIT;
		DBMS_OUTPUT.PUT_LINE('All male students updated successfully.');
	EXCEPTION
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE(('Error: ' || SQLERRM);
			
END;
/

--====================================== DBP ST2 ========================================
--Question 1
SET SERVEROUTPUT ON;

DECLARE
	v_asterisk VARCHAR2(10) := '*';
	v_isEVEN VARCHAR2(4) := 'Even' ;
	v_isOdd VARCHAR2(3) := 'Odd' ;
BEGIN
	FOR i IN 1..10 LOOP
		
		IF MOD(i,2) = 0 AND i <> 5 THEN
			
			DBMS_OUTPUT.PUT_LiNE(i ||' '|| LPAD('*',i ,'*') ||' '|| v_isEVEN);	
		END IF;
		IF i = 5 THEN 
			DBMS_OUTPUT.PUT_LiNE(' ');
		END IF;
		IF NOT MOD(i,2) = 0 AND i <> 5  THEN

			DBMS_OUTPUT.PUT_LiNE(i ||' '|| LPAD('*',i ,'*') ||' '|| v_isOdd);
		END IF;
	
	END LOOP;

END;
/

-- Question 2

SET SERVEROUTPUT ON;

DECLARE
	TYPE DS_subj_table_type IS TABLE OF s_subject%ROWTYPE
	INDEX BY PLS_INTEGER;
	
	ds_table_rec DS_subj_table_type;
BEGIN
	FOR i IN 1..3 LOOP
		select *
		into ds_table_rec(i)
		from s_subject
		Where SUBSTR(subj_code,-1) = i AND LOWER(subj_name) Like '%dev%';
		
	END LOOP;	
	DBMS_OUTPUT.PUT_LiNE('DEVELOPMENT SOFTWARE SUBJECT CLUSTER');
	DBMS_OUTPUT.PUT_LiNE('====================================');
	
	For j IN ds_table_rec.FIRST..ds_table_rec.LAST loop
		DBMS_OUTPUT.PUT_LINE(ds_table_rec(j).subj_code ||' - '||ds_table_rec(j).subj_name);
	END LOOP;

END;
/


-- Question 3

SET SERVEROUTPUT ON;

DECLARE
	CURSOR subj_cur IS
	select s.subj_code ,s.subj_name ,s.prereq
	from s_subject s,s_diploma d
	where SUBSTR(subj_code , -1) IN ('1','2','3') AND s.dip_code = d.dip_code
	AND d.dip_code ='CM';
	
	CURSOR prereq_cur(p_prereq IN s_subject.prereq%type) IS
	SELECT s.subj_code,s.subj_name 
	FROM s_subject s ,s_subject p 
	WHERE s.prereq = p.subj_code 
	AND s.prereq IS NOT NULL 
	AND s.prereq = p_prereq;

	
BEGIN
	FOR subj_rec IN subj_cur LOOP
		DBMS_OUTPUT.PUT_LINE('Subject : '||subj_rec.subj_code ||' - '||subj_rec.subj_name);
		FOR prereq_rec IN  prereq_cur(subj_rec.prereq) LOOP

			DBMS_OUTPUT.PUT_LINE('Perquisite :' ||prereq_rec.subj_code ||' - '||prereq_rec.subj_name);
			DBMS_OUTPUT.PUT_LINE('--------------------------'||CHR(10));

		END LOOP;
	END LOOP;
END;
/


SELECT s.subj_code,s.subj_name
FROM s_subject s ,s_subject p 
WHERE s.prereq = p.subj_code AND s.prereq IS NOT NULL;
AND p.prereq = s.subj_code;


-- Question 4
SET SERVEROUTPUT ON;

DECLARE
	v_initials s_staff.initials%type;
	v_surname s_staff.surname%type;
	v_old_salary s_staff.salary%type;
	v_salary_increase s_staff.salary%type;
BEGIN
	Select initials ,surname ,salary,
	DECODE(job,'CLEANER' ,salary * 1.15,
			   'LIBRARIAN', salary * 1.20,
			   'ARTISAN',salary * 1.10
	) salary
	---into v_initials, v_surname ,v_old_salary,v_salary_increase
	from s_staff
	where job  IN('CLEANER','LIBRARIAN','ARTISAN');
	
	DBMS_OUTPUT.PUT_LINE(v_initials||' - '||v_surname ||' had a salary increase from '||v_old_salary ||' to new salalry of '||v_salary_increase);
END;
/
SET SERVEROUTPUT ON;

DECLARE
   v_isbn bk_costs.isbn%type;
   v_cost bk_costs.cost%type;
   v_retail_price bk_costs.retail%type;

   --- here is the compared R30.00 price
   v_compared_price bk_costs.retail%type := 30.0;
   CURSOR retail_cur IS
      Select isbn , cost, retail
      From bk_costs
      For update of retail nowait;
BEGIN
   Open retail_cur;
   LOOP
      FETCH retail_cur INTO v_isbn,v_cost,v_retail_price;
      EXIT WHEN retail_cur%NOTFOUND;

      IF v_retail_price > v_compared_price THEN
         Update bk_costs
         set retail = v_retail_price * 1.15
         WHERE CURRENT OF retail_cur;
      END IF;

      DBMS_OUTPUT.PUT_LINE('The books ISBN No :'||v_isbn ||' cost R'||TO_CHAR(v_cost,'fm99,999.99') ||
      'and has retail price of R'||TO_CHAR(v_retail_price,'fm99,999.99'));
   END LOOP;
   Close retail_cur;
END;
/

--********************************* PL/SQL Test -QUestion Papaer *******************************

--Question 1

SET SERVEROUTPUT ON;


DECLARE 

	CURSOR dean_cur IS 
	Select staff.staffnr,staff.initials,staff.surname ,fac.fac_code , fac.fac_name
	From s_staff staff , s_faculty fac
	Where fac.fac_head  = staff.staffnr;
	
	CURSOR dip_cur(p_fac_code IN s_faculty.fac_code%type) IS 
	Select dip.dip_code ,dip.dip_name ,dip.dip_head ,fclty.fac_code  
	from s_diploma dip , s_faculty fclty
	Where dip.fac_code = fclty.fac_code 
	AND fclty.fac_code = p_fac_code;
	
	i BINARY_INTEGER := 1;1sw
BEGIN
		
	FOR d_record IN dean_cur LOOP
		
			DBMS_OUTPUT.PUT_LINE(i||'.)'||'The Dean  '||d_record.staffnr ||' goes by '||d_record.initials ||' - '||d_record.surname||' works at faculty  of ' || d_record.fac_name||'['||d_record.fac_code||']');
		FOR dip_record IN  dip_cur(d_record.fac_code) LOOP
			DBMS_OUTPUT.PUT_LINE('Lectures '||dip_record.dip_name ||'('||dip_record.dip_code||')'||' registered as '||dip_record.dip_head||' for '|| '['||dip_record.fac_code||']');  
		END LOOP;
		DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------');  

		i := i + 1;
		
	END LOOP;
END;
/




--- ------ -----
-- Question 2 [A]

SET SERVEROUTPUT ON;


DECLARE 
	TYPE subjects_table_type IS TABLE OF s_subject%rowtype
	INDEX BY BINARY_INTEGER;
	
	subjects_rec subjects_table_type;	
	i BINARY_INTEGER := 0;
BEGIN
	
	FOR rec IN (select * from s_subject)LOOP 
		subjects_rec(i) := rec;
		i:= i + 1;
	END LOOP;
	
	FOR j IN subjects_rec.FIRST..subjects_rec.LAST loop
		DBMS_OUTPUT.PUT_LINE('('||subjects_rec(j).subj_code ||')'|| ' - '||subjects_rec(j).subj_name ||CHR(10) ||'Tution fees are :R'||TO_CHAR(subjects_rec(j).subj_fee,'fm99,999.99' )||CHR(10) ||'Depeartment ID '|| subjects_rec(j).headnr);
	END LOOP;
	
END;
/


-- Question 2 [B]



SET SERVEROUTPUT ON;


DECLARE 
	TYPE software_dev_table_type IS TABLE OF s_subject%rowtype
	INDEX BY BINARY_INTEGER;
	
	dev_rec software_dev_table_type;	
	i BINARY_INTEGER := 1;
BEGIN
	
	FOR i IN 1..3 LOOP
		select *
		into dev_rec(i)
		from s_subject
		Where SUBSTR(subj_code,-1) = i AND LOWER(subj_name) Like '%dev%';
		
	END LOOP;	
	
	FOR j IN dev_rec.FIRST..dev_rec.LAST loop
		DBMS_OUTPUT.PUT_LINE('('||dev_rec(j).subj_code ||')'|| ' - '||dev_rec(j).subj_name ||CHR(10) ||'Tution fees are :R'||TO_CHAR(dev_rec(j).subj_fee,'fm99,999.99' )||CHR(10) ||'Depeartment ID '|| dev_rec(j).headnr);
	END LOOP;
	
END;
/


-- Question 2 [C]

SET SERVEROUTPUT ON;
DECLARE 
	
	TYPE cm_table_type IS TABLE OF s_subject%rowtype
	INDEX BY BINARY_INTEGER;
	
	cm_rec cm_table_type;
	
	i BINARY_INTEGER := 1;
	
BEGIN

	FOR rec IN (Select * From s_subject Where SUBSTR(subj_code,-1) IN ('1','2','3') And dip_Code = 'CM' AND UPPER(subj_name) Like '%COST%') LOOP
		cm_rec(i) := rec;
		i := i + 1;
	END LOOP;
	
	FOR j IN cm_rec.FIRST..cm_rec.LAST loop
		DBMS_OUTPUT.PUT_LINE('('||cm_rec(j).subj_code ||')'|| ' - '||cm_rec(j).subj_name ||CHR(10) ||'Tution fees are :R'||TO_CHAR(cm_rec(j).subj_fee,'fm99,999.99' )||CHR(10) ||'Depeartment ID '|| cm_rec(j).headnr);

	END LOOP;
END;
/

-- Question 3 [A]

SET SERVEROUTPUT ON;

DECLARE 

	CURSOR lectures_cur IS 
	Select staffnr, surname ,initials ,salary ,bonus
	from s_staff
	For update of salary nowait;
	
	v_staff_number s_staff.staffnr%type;
	v_surname s_staff.surname%type;
	v_initials s_staff.initials%type;
	v_salary s_staff.salary%type;
	v_bonus s_staff.bonus%type;
	
BEGIN

	open lectures_cur;
	LOOP 
		Fetch lectures_cur INTO v_staff_number,v_surname,v_initials,v_salary,v_bonus;
		EXIT WHEN lectures_cur%NOTFOUND ;
		
		DBMS_OUTPUT.PUT_LINE(v_bonus);
		IF v_bonus > 100000 THEN
			UPDATE s_staff
			Set bonus = (v_bonus * 0.15) + v_bonus
			Where current of lectures_cur;
		
		END IF;

	END LOOP;
	close lectures_cur;

END ;
/


UPDATE s_staff
Set bonus = (bonus * 0.15) + bonus
Where staffnr = 900003;


-- Question 3 [B]

SET SERVEROUTPUT ON;
DECLARE

	
BEGIN

END;
/

CREATE OR REPLACE PROCEDURE query_emp
  2  (p_id IN employees.employee_id%TYPE,
  3  p_name OUT employees.last_name%TYPE,
  4  p_salary OUT employees.salary%TYPE,
  5  p_comm OUT employees.commission_pct%TYPE)
  6  IS
  7  BEGIN
  8  SELECT last_name, salary, commission_pct
  9  INTO p_name, p_salary, p_comm
 10  FROM employees
 11  WHERE employee_id = p_id;
 12  END query_emp;
 13  /
 
VARIABLE g_name VARCHAR2(25)
VARIABLE g_sal NUMBER
VARIABLE g_comm NUMBER
EXECUTE query_emp(171, :g_name, :g_sal, :g_comm)
PRINT g_name



	CREATE OR REPLACE PROCEDURE test_procedure IS

	BEGIN 
		DBMS_OUTPUT.PUT_LINE('GOD please help me!!!');
	END ;
	/
	
-- Recompile the corrected procedure
CREATE OR REPLACE PROCEDURE emp_proc
(
	p_id      IN  employee.employeeid%TYPE,
	p_name    OUT employee.fname%TYPE,
	p_salary  OUT employee.salary%TYPE,
	p_com     OUT employee.commission%TYPE
) IS
BEGIN
	SELECT fname, salary, commission
	INTO   p_name, p_salary, p_com
	FROM   employee
	WHERE  employeeid = p_id;
END emp_proc;
/

-- Declare bind variables
VARIABLE g_name VARCHAR2(25)
VARIABLE g_sal NUMBER
VARIABLE g_commission NUMBER

-- Call the procedure
EXEC emp_proc(433, :g_name, :g_sal, :g_commission)

-- Print the output
PRINT g_name
PRINT g_sal
PRINT g_commission


CREATE OR REPLACE PROCEDURE emp_pro(
	p_id IN 
	p_name OUT 
	p_pub_date OUT

) IS 
BEGIN 

	select into // the out variables
	
end proceduer
/

VARIB E G_NAne Unber


EXECUTE (433,:g_name ,: ,:)

-- Section 3 Quetion [A]

SET SERVEROUTPUT ON;
	v_surname s_student.surname%type;
	v_initials s_student.initials%type;
	v_sex s_student.sex%type;
	v_birth_date s_student.birthdate%type;
	v_student_number s_student.studnr%type;
	
	v_student_id s_student.studnr%type := &student_number;
DECLARE 
	Select studnr, surname , initials ,sex,birthdate
	Into v_student_number ,v_surname ,v_initials,v_sex ,v_birth_date
	from s_student 
	where studnr = v_student_id;
BEGIN
	DBMS_OUTPUT.PUT_LINE( v_student_number||CHR(10) ||v_surname ||CHR(10) || v_initials||CHR(10) ||v_sex ||CHR(10) || v_birth_date);
EXCEPTION NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('No data found.');
EXCEPTION TOO_MANY_ROWS THEN
	DBMS_OUTPUT.PUT_LINE('Too many rows selected.');
EXCEPTION OTHERS THEN
	DBMS_OUTPUT.PUT_LINE('Something went wrong '||SQLCODE);
	DBMS_OUTPUT.PUT_LINE('Something went wrong '||SQLERRM);
END;
/

--- 
SET SERVEROUTPUT ON;

DECLARE
    v_surname s_student.surname%TYPE;
    v_initials s_student.initials%TYPE;
    v_sex s_student.sex%TYPE;
    v_birth_date s_student.birthdate%TYPE;
    v_student_number s_student.studnr%TYPE;
    v_student_id s_student.studnr%TYPE := &student_number;
BEGIN
    SELECT studnr, surname, initials, sex, birthdate
    INTO v_student_number, v_surname, v_initials, v_sex, v_birth_date
    FROM s_student
    WHERE studnr = v_student_id;

    DBMS_OUTPUT.PUT_LINE('Student Number: ' || v_student_number);
    DBMS_OUTPUT.PUT_LINE('Surname: ' || v_surname);
    DBMS_OUTPUT.PUT_LINE('Initials: ' || v_initials);
    DBMS_OUTPUT.PUT_LINE('Sex: ' || v_sex);
    DBMS_OUTPUT.PUT_LINE('Birthdate: ' || TO_CHAR(v_birth_date, 'YYYY-MM-DD'));

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No student found with the given ID.');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Multiple students found with that ID. Please refine your search.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error occurred. Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Message: ' || SQLERRM);
END;
/


--question 1
SET SERVEROUTPUT ON;

DECLARE
	TYPE numeric_table_type IS TABLE OF VARCHAR2(6)
	INDEX BY BINARY_INTEGER;
	numeric_arr numeric_table_type;
BEGIN
	FOR i IN 1..10 loop
		numeric_arr(1):= 'one';
		numeric_arr(2):= 'two';
		numeric_arr(3):= 'three';
		numeric_arr(4):= 'four';
		numeric_arr(5):= 'five';
		numeric_arr(6):= 'six';
		numeric_arr(7):= 'seven';
		numeric_arr(8):= 'eight';
		numeric_arr(9):= 'nine';
		numeric_arr(10):= 'ten';
	END LOOP;
	FOR i IN 1..10 loop
		
		IF numeric_arr(i) ='one' THEN
			DBMS_OUTPUT.PUT_LINE(1||' '||numeric_arr(1));
		END IF;
	END LOOP;
END;
/
LPAD(

SET SERVEROUTPUT ON;

DECLARE
	v_message VARCHAR2(6);
	v_remeainder Number;
	TYPE numeric_table_type IS TABLE OF VARCHAR2(7)
	INDEX BY BINARY_INTEGER;
	numeric_arr numeric_table_type;
BEGIN
	FOR i IN 1..10 loop
		numeric_arr(1):= 'one';
		numeric_arr(2):= 'two';
		numeric_arr(3):= 'three';
		numeric_arr(4):= 'four';
		numeric_arr(5):= 'five';
		numeric_arr(6):= 'six';
		numeric_arr(7):= 'seven';
		numeric_arr(8):= 'eight';
		numeric_arr(9):= 'nine';
		numeric_arr(10):= 'ten';
		
	END LOOP;
	FOR j IN 1..10 loop

		v_remeainder := MOD(j,2);
		
		IF v_remeainder = 0 AND  j <> 5 AND j <> 8 THEN
			v_message:= 'Even';
			DBMS_OUTPUT.PUT_LINE(j||' '||numeric_arr(j)||' '|| LPAD('*',j ,'*')||' ' ||v_message);
		END IF;
		IF v_remeainder <> 0 AND j <> 5 AND j <> 8 THEN
			v_message:= 'Odd';
			DBMS_OUTPUT.PUT_LINE(j||' '||numeric_arr(j)||' '|| LPAD('*',j ,'*')||' ' ||v_message);
		END IF;
		
	END LOOP;
END;
/

-- 

Create OR Replace Procedure raise_sal_proc(
	p_staff_number IN s_staff.staffnr%type,
	p_new_salary OUT s_staffnr.salary%type
) IS
BEGIN 
	Update s_staff
	set salary  = salary * 1.10
	where staffnr = p_staff_number;

END raise_sal_proc;
/

VARIABLE g_salary Number(7,2)
Execute (800116 ,:g_salary)
Print g_salary

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE author_books_proc(p_authorid IN bk_author.authorid%TYPE)IS 
    CURSOR book_cursers IS
    SELECT title
    FROM bk_books
    WHERE authorid = p_authorid;
    v_title bk_books.title%TYPE;
BEGIN
    IF NOT book_cursers%ISOPEN THEN
        OPEN book_cursers;
    END IF;
    DBMS_OUTPUT.PUT_LINE('-------These are the books of the author----------');
    LOOP
        FETCH book_cursers INTO v_title;
        EXIT WHEN book_cursers%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(v_title);
    END LOOP;
      DBMS_OUTPUT.PUT_LINE('The total number of books: '||author_total_books(p_authorid));
END author_books_proc;
/
VARIABLE g_a VARCHAR2

Execute author_books_proc('A100')


SET SERVEROUTPUT ON;
Create Or replace function countTotalBooks(p_authorid IN bk_author.authorid%TYPE)
	return Number IS 
	v_count Number;
BEGIN
	Select count(isbn) INTO v_count
	from bk_books
	where authorid = p_authorid;
	return v_count;
	

ENd countTotalBooks;
/	

Execute countTotalBooks(0132149871)

SET SERVEROUTPUT ON
DECLARE
    
BEGIN
    DBMS_OUTPUT.PUT_LINE(' THe number of books : '||countTotalBooks('S100'));
END;
/


SET SERVEROUTPUT ON;
	
DECLARE 
	TYPE summary_bk_record_type IS RECORD(
		book_title bk_books.title%type,
		book_publication_year bk_books.pubdate%type,
		book_lname bk_author.lname%type,
		book_fname bk_author.fname%type,
		book_publisher bk_publisher.name%type,
		book_retail_price bk_costs.retail%type
	
	);
	book_rec summary_bk_record_type;
	
	v_user_input_isbn bk_books.isbn%type:= '&isbn';
	v_vat_rate bk_costs.retail%type:= 15.5;
	v_vat_ammount bk_costs.retail%type:= 0;
	v_retail_VAT_EXCL bk_costs.retail%type := 0;
	v_retail_VAT_INC bk_costs.retail%type:= 0;
	
	
	CURSOR book_cur is
	SELECT bks.title ,bks.pubdate ,auth.lname,auth.fname,publ.name,cost.retail
	from bk_books bks
	Join bk_publisher publ On bks.pubid = publ.pubid
	Join bk_costs cost On bks.isbn = cost.isbn
	Join bk_author auth On auth.authorid = bks.authorid
	Where isbn = v_user_input_isbn;
	
BEGIN
	Open book_cur;
	
	Loop
		fetch book_cur into book_rec; -- fetched into the record instead of Selecting into "The recors' individual variables" beacause there was no specification
		exit when book_cur%notfound;
		
		v_retail_VAT_EXCL:= book_rec.book_retail_price; --1.) which is lettearlly a  varaible in record
		v_vat_ammount := v_retail_VAT_EXCL * (v_vat_rate/100); --2.)  correct caculation here
		v_retail_VAT_INC := v_vat_ammount + v_retail_VAT_EXCL; --3.) 
		
		DBMS_OUTPUT.PUT_LINE(book_rec.book_title || ' '); -- book_title is a declared recors value
		DBMS_OUTPUT.PUT_LINE('By :'|| SUBSTR(book_rec.book_fname,1,1) || '.' ||book_rec.book_lname ||'('|| book_rec.book_fname ||')');
		DBMS_OUTPUT.PUT_LINE('Published by '|| book_rec.book_publisher);
		DBMS_OUTPUT.PUT_LINE('IN the year :' || TO_CHAR(book_rec.book_publication_year ,'YYYY'));
		DBMS_OUTPUT.PUT_LINE('Price excluding vat R:'|| v_retail_VAT_EXCL); --calculateed value a 1
		DBMS_OUTPUT.PUT_LINE('Vat amount R'|| v_vat_ammount);
		DBMS_OUTPUT.PUT_LINE('Price including vat  R'|| v_retail_VAT_INC);
	End Loop;
	
	Close book_cur;
END;
/

--- isbn to enter 8843172113  and isbn to  2147428890


--Question 1

SET SERVEROUTPUT ON;

DECLARE
	
	v_isNumberEven BOOLEAN := true;
	v_message VARCHAR2(6) ;
	v_remainder NUMBER := 0;
	
	TYPE numeric_table_type IS TABLE OF VARCHAR2(6)
	INDEX BY BINARY_INTEGER;
	numeric_arr numeric_table_type;
	
BEGIN
		numeric_arr(1):= 'one';
		numeric_arr(2):= 'two';
		numeric_arr(3):= 'three';
		numeric_arr(4):= 'four';
		numeric_arr(5):= 'five';
		numeric_arr(6):= 'six';
		numeric_arr(7):= 'seven';
		numeric_arr(8):= 'eight';
		numeric_arr(9):= 'nine';
		numeric_arr(10):= 'ten';
		
	FOR i IN 1..10 LOOP
		
		v_remainder := MOD(i,2);
		
		IF  v_remainder = 0  AND i <> 5 AND i <> 8 THEN
			v_message := 'Even';
			DBMS_OUTPUT.PUT_LiNE(i ||' '||numeric_arr(i)||' '||LPAD('*',i ,'*')||' '||v_message);
		END  IF;
		IF v_remainder <> 0  AND i <> 5 AND i <> 8 THEN
			v_message := 'Odd';
			DBMS_OUTPUT.PUT_LiNE(i ||' '||numeric_arr(i)||' '||LPAD('*',i ,'*')||' '||v_message);
		END IF;
	END LOOP;
	
END;
/


--Question 2


SET SERVEROUTPUT on;

DECLARE
	
	v_title bk_books.title%type;
	v_first_name bk_author.lname%type;
	v_last_name bk_author.lname%type;
	v_category bk_books.category%type;
	v_publiser_name bk_publisher.name%type;
	
	
	v_users_category bk_books.category%type := '&category';
	CURSOR publication_rec IS
	SELECT bks.title,auth.fname ,auth.lname ,pub.name ,bks.category
	FROM bk_books bks
	JOIN bk_author auth ON bks.authorid = auth.authorid
	JOIN bk_publisher pub ON pub.pubid = bks.pubid
	WHERE bks.category = v_users_category;
	
	e_too_many_rows EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_too_many_rows,-04112) ;
	
BEGIN
	IF NOT publication_rec%ISOPEN THEN
		open publication_rec;
	END IF;
	
	LOOP 
		FETCH publication_rec INTO v_title,v_first_name,v_last_name,v_publiser_name,v_category;
		EXIT WHEN publication_rec%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('The book '||v_title ||' was written by '||v_first_name ||'-'||v_last_name ||' published by '|| v_publiser_name ||' category ');
		
		IF SQL%ROWCOUNT > 1 THEN
			RAISE e_too_many_rows;
		END IF;
		IF SQL%NOTFOUND THEN 
			RAISE NO_DATA_FOUND;
		END IF;
	END LOOP;
	
	EXCEPTION
		WHEN e_too_many_rows THEN
		DBMS_OUTPUT.PUT_LINE('There are uncountable books and author in this classification');
		
		
		WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Error code '|| SQLCODE);
		DBMS_OUTPUT.PUT_LINE('Error message '|| SQLERRM);
		
		WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error code '|| SQLCODE);
		DBMS_OUTPUT.PUT_LINE('Error message '|| SQLERRM);
	
	close publication_rec;
end;
/


--WHERE bks.pubid = 1 AND bks.authorid = 'W100';

SET SERVEROUTPUT ON;

DECLARE
	v_title bk_books.title%type;
	v_first_name bk_author.lname%type;
	v_last_name bk_author.lname%type;
	v_category bk_books.category%type;
	v_publiser_name bk_publisher.name%type;
    v_input_category bk_books.category%TYPE := '&Enter_value_for_category';

    e_too_many_rows EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_too_many_rows, -4112);  

   
    CURSOR publication_rec IS
        SELECT bks.title, auth.fname, auth.lname, pub.name, bks.category
        FROM bk_books bks
        JOIN bk_author auth ON bks.authorid = auth.authorid
        JOIN bk_publisher pub ON bks.pubid = pub.pubid
        WHERE LOWER(bks.category) = LOWER(v_input_category);

BEGIN
    IF NOT publication_rec%ISOPEN THEN
		open publication_rec;
	END IF;
	LOOP 
		FETCH publication_rec INTO v_title,v_first_name,v_last_name,v_publiser_name,v_category;
		EXIT WHEN publication_rec%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('The book '||v_title ||' was written by '||v_first_name ||'-'||v_last_name ||' published by '|| v_publiser_name ||' category ');
		
	END LOOP;
	close publication_rec;
	
	IF SQL%NOTFOUND THEN 
		RAISE NO_DATA_FOUND;
	END IF;
	IF SQL%ROWCOUNT > 1 AND v_input_category IN ('cooking','computer') THEN
		RAISE e_too_many_rows;
	END IF;
	
EXCEPTION
		WHEN e_too_many_rows THEN
			DBMS_OUTPUT.PUT_LINE('There are uncountable books and author in this classification');
		
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Error code '|| SQLCODE);
			DBMS_OUTPUT.PUT_LINE('Error message '|| SQLERRM);
		
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Error code '|| SQLCODE);
			DBMS_OUTPUT.PUT_LINE('Error message '|| SQLERRM);
END;
/

-- Question 1

SET SERVEROUTPUT ON;
DECLARE
    v_title           bk_books.title%TYPE;
    v_first_name      bk_author.fname%TYPE;
    v_last_name       bk_author.lname%TYPE;
    v_category        bk_books.category%TYPE;
    v_publiser_name   bk_publisher.name%TYPE;
    v_input_category  bk_books.category%TYPE := '&Enter_value_for_category';
    
    e_too_many_rows EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_too_many_rows, -4112);

    CURSOR publication_rec IS
        SELECT bks.title, auth.fname, auth.lname, pub.name, bks.category
        FROM bk_books bks
        JOIN bk_author auth ON bks.authorid = auth.authorid
        JOIN bk_publisher pub ON bks.pubid = pub.pubid
        WHERE LOWER(bks.category) = LOWER(v_input_category);
    
    v_count INTEGER := 0;
BEGIN
    OPEN publication_rec;
    
    LOOP
        FETCH publication_rec INTO v_title, v_first_name, v_last_name, v_publiser_name, v_category;
        EXIT WHEN publication_rec%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('The book ' || v_title || ' was written by ' ||
                             v_last_name || ', ' || v_first_name || ' publish by ' ||
                             v_publiser_name || CHR(10) || ' under ' ||
                             UPPER(v_category) || ' category.');
        v_count := v_count + 1;
    END LOOP;

    CLOSE publication_rec;

    IF v_count = 0 OR LOWER(v_input_category) IN ('ict', 'database') THEN
        RAISE NO_DATA_FOUND;
    ELSIF v_count > 1 AND LOWER(v_input_category) IN ('cooking', 'computer') THEN
        RAISE e_too_many_rows;
    END IF;

EXCEPTION
    WHEN e_too_many_rows THEN
        DBMS_OUTPUT.PUT_LINE('There are uncountable books and author in this classification.');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No books in this category.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unknown error. Error Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
END;
/

-- question 2


SET SERVEROUTPUT ON;


DECLARE	
	
	v_last_name bk_author.lname%type;
	v_first_name bk_author.fname%type;
	v_isbn bk_books.isbn%type;
	v_title bk_books.title%type;
	v_category bk_books.category%type;
	v_pubdate bk_books.pubdate%type;
	v_name bk_publisher.name%type;
	v_cost bk_costs.cost%type;
	
	p_authorid bk_books.authorid%type := '&AUTHOR_ID';
	
	CURSOR book_cursor(p_authorid IN bk_books.authorid%type) IS 
	SELECT author.lname , author.fname ,books.isbn ,books.title ,books.category ,books.pubdate , pub.name ,cost.cost
	FROM bk_author author
	JOIN bk_books books ON author.authorid = books.authorid
	JOIN bk_publisher pub ON pub.pubid = books.pubid
	JOIN bk_costs cost ON cost.isbn = books.isbn
	WHERE author.authorid = p_authorid;
	
	condition  Boolean := TRUE;
	
BEGIN
	IF NOT book_cursor%ISOPEN THEN
		OPEN book_cursor(p_authorid) ;
	END IF;
	WHILE condition LOOP
		FETCH book_cursor INTO v_last_name,v_first_name,v_isbn,v_title,v_category,v_pubdate,v_name,v_cost;
		EXIT WHEN book_cursor%NOTFOUND ;
		
		DBMS_OUTPUT.PUT_LINE(v_isbn||' '||v_title ||' published on the '|| TO_DATE(v_pubdate,'DD Month YYYY') ||' published by :'||v_name ||' sold for '||TO_CHAR(v_cost,'$999.99'));
	END LOOP;
		CLOSE book_cursor;
END;
/


-- Mostc orrect number 2 

SET SERVEROUTPUT ON;

DECLARE    
    -- Individual variables for each field
    v_last_name bk_author.lname%TYPE;
    v_first_name bk_author.fname%TYPE;
    v_isbn bk_books.isbn%TYPE;
    v_title bk_books.title%TYPE;
    v_category bk_books.category%TYPE;
    v_pubdate bk_books.pubdate%TYPE;
    v_name bk_publisher.name%TYPE;
    v_cost bk_costs.cost%TYPE;
    
    -- Prompt for author ID at runtime
    p_authorid bk_books.authorid%TYPE := '&AUTHOR_ID';
    
    -- Cursor with parameter
    CURSOR book_cursor(p_authorid IN bk_books.authorid%TYPE) IS 
        SELECT author.lname, author.fname, books.isbn, books.title, 
               books.category, books.pubdate, pub.name, cost.cost
        FROM bk_author author
        JOIN bk_books books ON author.authorid = books.authorid
        JOIN bk_publisher pub ON pub.pubid = books.pubid
        JOIN bk_costs cost ON cost.isbn = books.isbn
        WHERE author.authorid = p_authorid;
    
    -- Loop control variable
    v_more_data BOOLEAN := TRUE;
    
BEGIN
    -- Check if cursor is open before opening
    IF NOT book_cursor%ISOPEN THEN
        OPEN book_cursor(p_authorid);
    END IF;
    
    -- Process data using WHILE loop
    WHILE v_more_data LOOP
        FETCH book_cursor INTO v_last_name, v_first_name, v_isbn, v_title, 
                              v_category, v_pubdate, v_name, v_cost;
        
        -- Exit condition
        IF book_cursor%NOTFOUND THEN
            v_more_data := FALSE;
        ELSE
            -- Display book information
				DBMS_OUTPUT.PUT_LINE(v_isbn||' '||v_title ||' published on the '|| TO_DATE(v_pubdate,'DD Month YYYY') ||' published by :'||v_name ||' sold for '||TO_CHAR(v_cost,'$999.99'));

        END IF;
    END LOOP;
    
    -- Close cursor
    IF book_cursor%ISOPEN THEN
        CLOSE book_cursor;
    END IF;
    
    -- Check if no data was found
    IF book_cursor%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No books found for author ID: ' || p_authorid);
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        -- Ensure cursor is closed if an error occurs
        IF book_cursor%ISOPEN THEN
            CLOSE book_cursor;
        END IF;
END;
/


--Question 2 

SET SERVEROUTPUT ON;

DECLARE

	TYPE author_royalty_type IS RECORD( 
		v_surname bk_author.lname%type,
		v_name bk_author.fname%type,
		v_title bk_books.title%type,
		v_accumulated_royalties bk_costs.cost%type,
		v_numberOfBooks bk_costs.cost%type
	);
	author_royalty_rec author_royalty_type;
    v_order_id bk_orders.ORDER#%type := &order_number;
    v_royalty_percentage NUMBER(5,2) := 0.10;
    v_total_royalty NUMBER(10,2) := 0;

	CURSOR author_cursor IS
	SELECT auth.lname ,auth.fname,book.title,cst.cost,COUNT(*)
	FROM bk_author auth ,bk_books book ,bk_orders orders ,bk_orderitems order_items , bk_costs cst
	WHERE auth.authorid = book.authorid AND order_items.item# = book.pubid AND order_items.ORDER# = v_order_id 
	GROUP BY auth.lname ,auth.fname,book.title,orders.ORDER#,cst.cost;
BEGIN
	OPEN author_cursor;
	DBMS_OUTPUT.PUT_LINE('Author Royalties per order');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------');
	LOOP
		FETCH author_cursor INTO author_royalty_rec;
		EXIT WHEN author_cursor%NOTFOUND;
		
		 v_total_royalty := author_royalty_rec.v_accumulated_royalties * author_royalty_rec.v_numberOfBooks * v_royalty_percentage;
        
        DBMS_OUTPUT.PUT_LINE('Order Number: ' || v_order_id);
        DBMS_OUTPUT.PUT_LINE('Author: ' || author_royalty_rec.v_name || ' ' || author_royalty_rec.v_surname);
        DBMS_OUTPUT.PUT_LINE(author_royalty_rec.v_numberOfBooks || ' copies of the book named: ' || 
                            author_royalty_rec.v_title || ' were ordered.');
        DBMS_OUTPUT.PUT_LINE('Royalties accumulated: R' || TO_CHAR(v_total_royalty, '990.99'));
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------');
		
		END LOOP;
		
	CLOSE author_cursor;
	
	IF author_cursor%ROWCOUNT  = 0 THEN
		RAISE NO_DATA_FOUND;
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Order does not exist.');
	WHEN TOO_MANY_ROWS THEN
		DBMS_OUTPUT.PUT_LINE('Duplication of orders.');
	WHEN OTHERS THEN	
		DBMS_OUTPUT.PUT_LINE('Invalid input.');	
END;
/

-- Question 3

SET SERVEROUTPUT ON;
DECLARE
	
	v_customer_# bk_customers.CUSTOMER#%type;
	v_lastname bk_customers.lastname%type;
	v_firstname bk_customers.firstname%type;
	v_order_date bk_orders.orderdate%type;
	v_isbn bk_books.isbn%type;
	v_title bk_books.title%type;
	v_number_of_Books NUMBER := 0;
	
	CURSOR customer_cursor IS
	SELECT * FROM bk_customers;
	
	CURSOR book_cursor(p_customer_number IN bk_customers.CUSTOMER#) IS
	SELECT cust.CUSTOMER#, cust.lastname, cust.firstname, orders_.orderdate, bks.isbn, bks.title, COUNT(*) AS number_Of_books
	FROM bk_books bks 
	JOIN bk_orderitems order_items ON bks.isbn = order_items.isbn
	JOIN bk_orders orders_ ON orders_.order# = order_items.order#
	JOIN bk_customers cust ON cust.CUSTOMER# = orders_.CUSTOMER#
	WHERE cust.CUSTOMER# = p_customer_number
	GROUP BY cust.CUSTOMER#, cust.lastname, cust.firstname, orders_.orderdate, bks.isbn, bks.title;
	
BEGIN
	IF NOT book_cursor%ISOPEN OR NOT customer_cursor%ISOPEN THEN
		OPEN book_cursor(p_customer_number);
	END IF;
	
	FOR cust_rec IN customer_cursor Loop
	
		DBMS_OUTPUT.PUT_LINE('==========================================================================');
		DBMS_OUTPUT.PUT_LINE('Customer details: '|| cust_rec.CUSTOMER# ||'- '|| cust_rec.lastname ||' '|| cust_rec.firstname);
		DBMS_OUTPUT.PUT_LINE('==========================================================================');
		LOOP
			FETCH book_cursor(cust_rec.CUSTOMER#) INTO v_customer_#,v_lastname,v_firstname,v_order_date ,v_isbn ,v_title ,v_number_of_Books;
			EXIT WHEN author_cursor%NOTFOUND;
			
			DBMS_OUTPUT.PUT_LINE('Order number '|| v_customer_# ||' Order Date '||v_order_date);
			DBMS_OUTPUT.PUT_LINE('Book ordered '||v_isbn ||' - '||v_title ||'  Number of books '||v_number_of_Books);
		END LOOP;
	END LOOP;	

END;
/

SELECT cust.CUSTOMER#, cust.lastname, cust.firstname, orders_.orderdate, bks.isbn, bks.title, COUNT(*) AS book_count
FROM   bk_books bks 
JOIN bk_orderitems order_items ON bks.isbn = order_items.isbn
JOIN bk_orders orders_ ON orders_.order# = order_items.order#
JOIN bk_customers cust ON cust.CUSTOMER# = orders_.CUSTOMER#
GROUP BY cust.CUSTOMER#, cust.lastname, cust.firstname, orders_.orderdate, bks.isbn, bks.title;


SET SERVEROUTPUT ON;
DECLARE
    v_customer_# bk_customers.CUSTOMER#%type;
    v_lastname bk_customers.lastname%type;
    v_firstname bk_customers.firstname%type;
    v_order_date bk_orders.orderdate%type;
    v_isbn bk_books.isbn%type;
    v_title bk_books.title%type;
    v_number_of_Books NUMBER := 0;
    
    CURSOR customer_cursor IS
    SELECT * FROM bk_customers;
    
    CURSOR book_cursor(p_customer_number IN bk_customers.CUSTOMER#%type) IS
    SELECT cust.CUSTOMER#, cust.lastname, cust.firstname, orders_.orderdate, 
           bks.isbn, bks.title, COUNT(*) AS number_Of_books
    FROM bk_books bks 
    JOIN bk_orderitems order_items ON bks.isbn = order_items.isbn
    JOIN bk_orders orders_ ON orders_.order# = order_items.order#
    JOIN bk_customers cust ON cust.CUSTOMER# = orders_.CUSTOMER#
    WHERE cust.CUSTOMER# = p_customer_number
    GROUP BY cust.CUSTOMER#, cust.lastname, cust.firstname, orders_.orderdate, bks.isbn, bks.title;
    
BEGIN
    FOR cust_rec IN customer_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('==========================================================================');
        DBMS_OUTPUT.PUT_LINE('Customer details: '|| cust_rec.CUSTOMER# ||'- '|| cust_rec.lastname ||' '|| cust_rec.firstname);
        DBMS_OUTPUT.PUT_LINE('==========================================================================');
        
        FOR book_rec IN book_cursor(cust_rec.CUSTOMER#) LOOP
            DBMS_OUTPUT.PUT_LINE('Order Date: '||book_rec.orderdate);
            DBMS_OUTPUT.PUT_LINE('Book ordered: '||book_rec.isbn ||' - '||book_rec.title || 
                                '  Number of books: '||book_rec.number_Of_books);
            DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        END LOOP;
        

    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: '||SQLERRM);
END;
/


--Question 4
SET SERVEROUTPUT ON;
DECLARE
	e_nonpredefinederror EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_nonpredefinederror, -01400);
    
BEGIN
	INSERT INTO bk_publisher(pubid,name,contact,phone)
	VALUES(null,'SYSTEM',null,null);
	
	IF SQL%NOTFOUND THEN 
		RAISE e_nonpredefinederror;
	END IF;
EXCEPTION
	WHEN e_nonpredefinederror THEN
	DBMS_OUTPUT.PUT_LINE('PUBLISHER INSERT OPERATION FAILED'||CHR(10) ||SQLCODE ||' '||SQLERRM);
END;
/
 

--QUestion 1

SET SERVEROUTPUT ON;

DECLARE
	v_student_mark NUMBER := &mark;
	v_message VARCHAR2(6);
	v_symbol CHAR(1);
BEGIN
	
	v_symbol := 
		CASE
				WHEN v_student_mark >= 90 THEN 'A'
				WHEN v_student_mark >= 80 THEN 'B'
				WHEN v_student_mark >= 70 THEN 'C'
				WHEN v_student_mark >= 60 THEN 'D'
				WHEN v_student_mark >= 50 THEN 'E'
				WHEN v_student_mark < 50  THEN 'F'
			ELSE 'invalid symbol'
		END;
		
		
		IF v_symbol IN ('A','B','C','D' ,'E') THEN
			v_message := 'PASSED';
		ELSIF v_symbol NOT IN ('A','B','C','D','E') THEN
			v_message := 'FAILED';
		END IF;
		
		
		DBMS_OUTPUT.PUT_LINE(v_student_mark||' YOu have '||v_message||' with a symmbol of '|| v_symbol);
END;
/


--

	-