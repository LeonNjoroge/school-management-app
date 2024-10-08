-- Create DEPARTMENT table first
CREATE TABLE DEPARTMENT (
    DEPARTMENT_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    DEPARTMENT_NAME VARCHAR2(20) NOT NULL,
    CONSTRAINT DEPARTMENT_PK PRIMARY KEY (DEPARTMENT_ID)
);

-- Create COURSE table second
CREATE TABLE COURSE (
    COURSE_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    COURSE_NAME VARCHAR2(20) NOT NULL,
    DEPARTMENT_ID NUMBER(10),
    CONSTRAINT COURSE_PK PRIMARY KEY (COURSE_ID),
    CONSTRAINT DEPARTMENT_FK FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENT (DEPARTMENT_ID)
);

-- Create UNIT table third
CREATE TABLE UNIT (
    UNIT_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    UNIT_NAME VARCHAR2(20) NOT NULL,
    COURSE_ID NUMBER(10),
    CONSTRAINT UNIT_PK PRIMARY KEY (UNIT_ID),
    CONSTRAINT UNIT_FK FOREIGN KEY (COURSE_ID) REFERENCES COURSE (COURSE_ID)
);

-- Create STUDENT table fourth
CREATE TABLE STUDENT (
    STUDENT_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    FIRST_NAME VARCHAR2(20) NOT NULL,
    LAST_NAME VARCHAR2(20) NOT NULL,
    COURSE_ID NUMBER(10),
    UNIT_ID NUMBER(10),
    USERNAME VARCHAR2(20) NOT NULL UNIQUE,
    PASSWORD VARCHAR2(50) NOT NULL;
    CONSTRAINT STUDENTS_PK PRIMARY KEY (STUDENT_ID),
    CONSTRAINT STUDENT_FK FOREIGN KEY (COURSE_ID) REFERENCES COURSE (COURSE_ID),
    CONSTRAINT STUDENT_FK2 FOREIGN KEY (UNIT_ID) REFERENCES UNIT (UNIT_ID)
);

-- Create EXAM table fifth
CREATE TABLE EXAM (
    EXAM_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    EXAM_NAME VARCHAR2(20) NOT NULL,
    UNIT_ID NUMBER(10) NOT NULL,
    CONSTRAINT EXAM_PK PRIMARY KEY (EXAM_ID),
    CONSTRAINT EXAM_FK FOREIGN KEY (UNIT_ID) REFERENCES UNIT (UNIT_ID)
);

-- Create LECTURER table sixth
CREATE TABLE LECTURER (
    LECTURER_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    LECTURER_NAME VARCHAR2(20) NOT NULL,
    UNIT_ID NUMBER(10),
    DEPARTMENT_ID NUMBER(10),
    CONSTRAINT LECTURER_PK PRIMARY KEY (LECTURER_ID),
    CONSTRAINT LEC_FK FOREIGN KEY (UNIT_ID) REFERENCES UNIT (UNIT_ID),
    CONSTRAINT LEC_DEPT_FK FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENT (DEPARTMENT_ID)
);

-- Create RESULTS table seventh
CREATE TABLE RESULTS (
    RESULTS_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    STUDENT_ID NUMBER NOT NULL,
    EXAM_ID NUMBER,
    CAT_1 NUMBER(10),
    CAT_2 NUMBER(10),
    CAT_3 NUMBER(10),
    EXAM_MARKS NUMBER(10),
    GRADE VARCHAR2(20),
    CONSTRAINT RESULTS_PK PRIMARY KEY (RESULTS_ID),
    CONSTRAINT STUD_FK FOREIGN KEY (STUDENT_ID) REFERENCES STUDENT(STUDENT_ID),
    CONSTRAINT STUD_FK2 FOREIGN KEY (EXAM_ID) REFERENCES EXAM(EXAM_ID)
);

-- Create Trigger for GET_GRADE
CREATE OR REPLACE TRIGGER GET_GRADE
AFTER INSERT OR UPDATE ON RESULTS
FOR EACH ROW
DECLARE
    MARKS NUMBER(10);
BEGIN
    MARKS := ( :NEW.CAT_1 + :NEW.CAT_2 + :NEW.CAT_3 + :NEW.EXAM_MARKS ) / 4;

    IF MARKS < 100 AND MARKS >= 70 THEN
        :NEW.GRADE := 'A';
    ELSIF MARKS < 70 AND MARKS >= 60 THEN
        :NEW.GRADE := 'B';
    ELSIF MARKS < 60 AND MARKS >= 50 THEN
        :NEW.GRADE := 'C';
    ELSIF MARKS < 50 AND MARKS >= 40 THEN
        :NEW.GRADE := 'D';
    ELSIF MARKS < 40 AND MARKS >= 1 THEN
        :NEW.GRADE := 'E';
    ELSE
        :NEW.GRADE := 'F'; -- Handle case for 0 or invalid marks
    END IF;
END;

-- Create View for STUDENT_RESULTS
CREATE OR REPLACE VIEW STUDENT_RESULTS (USERNAME, FIRST_NAME, UNIT_ID, CAT_1, CAT_2, CAT_3, EXAM_MARKS, GRADE)
AS 
SELECT S.USERNAME, S.FIRST_NAME, S.UNIT_ID, R.CAT_1, R.CAT_2, R.CAT_3, R.EXAM_MARKS, R.GRADE
FROM STUDENT S 
JOIN RESULTS R ON S.STUDENT_ID = R.STUDENT_ID
ORDER BY S.STUDENT_ID;