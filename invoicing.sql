-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Sep 18, 2021 at 02:14 PM
-- Server version: 8.0.21
-- PHP Version: 7.4.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `invoicing`
--

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `spAttandanceDisplay`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spAttandanceDisplay` (IN `First_Name` VARCHAR(255))  NO SQL
SELECT DISTINCT id.InvoiceDetailID, CONCAT(s.FirstName,' ' ,s.Surname) as 'Full Name', s.EmailAddress, c.courseName as Course, a.TimeSlot as 'Slot', a.NoOfHours as 'No Of Hours', a.GroupSession as 'Group Session',id.DateIssued
FROM student s , course c , attendance a, invoicedetails id
WHERE a.studentID = s.studentID AND a.courseID = c.courseID and a.attendanceID =id.attendanceID AND CONCAT(s.FirstName, ' ', s.Surname) LIKE  CONCAT('%', First_Name,'%') AND a.DeletedAt is null
ORDER BY c.courseName, s.StudentID$$

DROP PROCEDURE IF EXISTS `spAttendeesDisplay`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spAttendeesDisplay` ()  NO SQL
SELECT DISTINCT CONCAT(s.FirstName,' ' ,s.Surname) as 'Student Name', c.courseName as 'Course', a.TimeSlot as 'Slot',a.NoOfHours as 'No Of Hours', a.GroupSession as 'Group Session' 
FROM student s , course c, attendance a  
WHERE s.studentID = a.studentID AND c.courseID = a.courseID AND a.DeletedAt is null
GROUP By s.studentID, c.CourseID
ORDER BY s.FirstName$$

DROP PROCEDURE IF EXISTS `spColeHoneyInvoice`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spColeHoneyInvoice` (IN `First_Name` VARCHAR(255))  NO SQL
SELECT
    id.DateIssued,
    id.InvoiceDetailID,
    CONCAT(s.FirstName, ' ', s.Surname) AS 'Full Name',
    s.EmailAddress,
    c.courseName AS 'Course',
    ((r.priceRate - r.priceRate) +100) AS 'priceRate',
    a.TimeSlot,s.grade,
    SUM(a.NoOfHours) AS 'Total Hours',
    (
        ((r.priceRate - r.priceRate) +100) * SUM(a.NoOfHours)
    ) AS 'SubTotal'
FROM
    student s,
    course c,
    invoicedetails id,
    attendance a,
    rate r,
    category cat
WHERE
    s.studentID = id.studentID AND c.courseID = id.courseID AND a.attendanceID = id.attendanceID AND r.CategoryID = cat.CategoryID AND s.CategoryID = cat.CategoryID AND r.GroupID = a.GroupSession AND CONCAT(s.FirstName, ' ', s.Surname) LIKE CONCAT('%', First_Name, '%') AND id.DeletedAt IS NULL
GROUP BY
    id.InvoiceDetailID$$

DROP PROCEDURE IF EXISTS `spColeHoneyInvoiceSearchByDate`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spColeHoneyInvoiceSearchByDate` (IN `Start_Date` DATETIME, IN `First_Name` VARCHAR(255))  NO SQL
SELECT
    id.DateIssued,
    id.InvoiceDetailID,
    CONCAT(s.FirstName, ' ', s.Surname) AS 'Full Name',
    s.EmailAddress,
    c.courseName AS 'Course',
    ((r.priceRate - r.priceRate) +100) AS 'priceRate',
    a.TimeSlot, s.grade,
    SUM(a.NoOfHours) AS 'Total Hours',
    (
        ((r.priceRate - r.priceRate) +100) * SUM(a.NoOfHours)
    ) AS 'SubTotal'
FROM
    student s,
    course c,
    invoicedetails id,
    attendance a,
    rate r,
    category cat
WHERE
    s.studentID = id.studentID AND c.courseID = id.courseID AND a.attendanceID = id.attendanceID AND r.CategoryID = cat.CategoryID AND s.CategoryID = cat.CategoryID AND r.GroupID = a.GroupSession AND CONCAT(s.FirstName, ' ', s.Surname) LIKE CONCAT('%', First_Name, '%') AND a.TimeSlot >= Start_Date AND id.DeletedAt IS NULL
GROUP BY
    id.InvoiceDetailID$$

DROP PROCEDURE IF EXISTS `spCoursesStudentSearch`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spCoursesStudentSearch` (IN `Last_Name` VARCHAR(255))  NO SQL
SELECT c.courseName as course
FROM course c , attendance a , student s
WHERE c.courseID = a.courseID AND
s.studentID = a.studentID AND
s.Surname = Last_Name AND s.DeletedAt is NULL AND c.DeleteAt is NULL
ORDER BY s.FirstName$$

DROP PROCEDURE IF EXISTS `spDeleteAttendance`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spDeleteAttendance` (IN `attID` INT)  NO SQL
BEGIN
START TRANSACTION;
  UPDATE attendance
     SET DeletedAt = CURRENT_TIMESTAMP
     WHERE AttendanceID =attID;

   UPDATE invoicedetails 
     SET DeletedAt = CURRENT_TIMESTAMP
     WHERE AttendanceID =attID;
COMMIT;
END$$

DROP PROCEDURE IF EXISTS `spDeleteCourse`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spDeleteCourse` (IN `cID` INT)  NO SQL
UPDATE `course` 
SET `DeletedAt` =CURRENT_TIMESTAMP
WHERE courseID = cID$$

DROP PROCEDURE IF EXISTS `spDeleteStudent`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spDeleteStudent` (IN `stdID` INT)  NO SQL
BEGIN
START TRANSACTION;
UPDATE student s
SET s.DeletedAt =CURRENT_TIMESTAMP
WHERE studentID = stdID;

 UPDATE invoicedetails id
    SET id.DeletedAt = CURRENT_TIMESTAMP
    WHERE id.studentID = stdID;

    UPDATE attendance a
    SET a.DeletedAt = CURRENT_TIMESTAMP
    WHERE a.studentID = stdID;

COMMIT;
END$$

DROP PROCEDURE IF EXISTS `spDeleteUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spDeleteUser` (IN `user_ID` INT)  NO SQL
UPDATE `users` 
SET `DeletedAt` =CURRENT_TIMESTAMP
WHERE UserID = user_ID$$

DROP PROCEDURE IF EXISTS `spEmailAddress`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spEmailAddress` ()  NO SQL
SELECT DISTINCT s.studentID, s.EmailAddress, s.Sponsor 
FROM student s, course c, invoicedetails id , attendance a
WHERE s.studentID = a.studentID
and c.courseID = a.courseID and s.DeletedAt is NULL
GROUP BY s.EmailAddress$$

DROP PROCEDURE IF EXISTS `spExportData`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spExportData` (IN `startDate` DATETIME, IN `endDate` DATETIME, IN `paraName` INT)  NO SQL
SELECT DISTINCT
    CONCAT(s.FirstName, ' ', s.Surname) AS 'Full Name',
    
    s.grade AS 'Grade',
    a.TimeSlot AS 'Attended Date',
    vt.SubTotal	 AS 'Amount Due'
FROM
    student s,
    course c,
    invoicedetails id,
    attendance a,
    rate r,
    category cat,
    vinvoicewithoutspecial vt
WHERE
    s.studentID = id.studentID AND c.courseID = id.courseID AND a.attendanceID = id.attendanceID AND r.CategoryID = cat.CategoryID AND s.CategoryID = cat.CategoryID AND id.studentID = vt.StudentID AND r.GroupID = a.GroupSession AND a.DeletedAt IS NULL AND s.grade = paraName AND a.TimeSlot >= startDate AND a.TimeSlot <= endDate  AND CONCAT(s.FirstName, ' ', s.Surname)NOT IN('Abby Cornel','Kelsey Froneman','Andrea Ambler','Mia Deacon','Cole Honey')
GROUP BY
    s.StudentID$$

DROP PROCEDURE IF EXISTS `spExportDataAll`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spExportDataAll` ()  NO SQL
SELECT DISTINCT
    CONCAT(s.FirstName, ' ', s.Surname) AS 'Full Name',
    c.courseName AS 'Course',
    s.grade AS 'Grade',
    a.TimeSlot AS 'Attended Date',
    (r.priceRate * SUM(a.NoOfHours)) AS 'Amount Due'
FROM
    student s,
    course c,
    invoicedetails id,
    attendance a,
    rate r,
    category cat
WHERE
    s.studentID = id.studentID AND c.courseID = id.courseID AND a.attendanceID = id.attendanceID AND r.CategoryID = cat.CategoryID AND s.CategoryID = cat.CategoryID AND r.GroupID = a.GroupSession AND a.DeletedAt IS NULL AND CONCAT(s.FirstName, ' ', s.Surname)NOT IN('Abby Cornel','Kelsey Froneman','Andrea Ambler','Mia Deacon','Cole Honey') 
GROUP BY
    id.InvoiceDetailID$$

DROP PROCEDURE IF EXISTS `spInsertAttendance`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsertAttendance` (IN `Group_Session` INT, IN `No_Of_Hours` INT, IN `Time_Slot` DATETIME, IN `Student_ID` INT(11), IN `Course_ID` INT(11))  NO SQL
BEGIN
START TRANSACTION;
   INSERT INTO attendance(courseID, studentID, GroupSession, NoOfHours, TimeSlot) 
     VALUES(Course_ID, Student_ID, Group_Session, No_Of_Hours, Time_Slot);

   INSERT INTO invoicedetails (courseID, studentID, attendanceID, DateIssued) 
     VALUES(Course_ID, Student_ID, LAST_INSERT_ID(), CURRENT_TIMESTAMP);
COMMIT;
END$$

DROP PROCEDURE IF EXISTS `spInsertCourse`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsertCourse` (IN `course_Name` VARCHAR(255))  NO SQL
INSERT INTO `course` (`courseID`, `courseName`, `CreatedAt`, `DeleteAt`) 
VALUES (NULL, course_Name, current_timestamp(), NULL)$$

DROP PROCEDURE IF EXISTS `spInsertStudents`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsertStudents` (IN `First_Name` VARCHAR(255), IN `Sur_name` VARCHAR(255), IN `gra_de` INT(11), IN `catID` INT(11), IN `Email_Address` VARCHAR(255), IN `Spon_sor` VARCHAR(255))  NO SQL
INSERT INTO `student`(
    `FirstName`,
    `Surname`,
    `grade`,
    `CategoryID`,
    `EmailAddress`,
    `Sponsor`,
    `CreatedAt`,
    `DeletedAt`
)
VALUES(
    First_Name,
    Sur_name,
    gra_de,
    catID,
    Email_Address,
    Spon_sor,
    CURRENT_TIMESTAMP,
    NULL
)$$

DROP PROCEDURE IF EXISTS `spInsertUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spInsertUser` (IN `User_name` VARCHAR(255), IN `Password_Hash` VARCHAR(255), IN `First_Name` VARCHAR(255), IN `Sur_name` VARCHAR(255))  NO SQL
INSERT INTO `users` (`UserID`, `Username`, `Password`, `FirstName`, `Surname`, `Active`) 
VALUES (NULL, User_name, Password_Hash, First_Name,Sur_name, 1 )$$

DROP PROCEDURE IF EXISTS `spInvoiceDisplay`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spInvoiceDisplay` ()  NO SQL
SELECT id.DateIssued, id.InvoiceDetailID, CONCAT(s.FirstName, ' ' ,s.Surname) AS 'Full Name', s.EmailAddress, c.courseName AS 'Course', r.priceRate,a.TimeSlot, s.grade, SUM(a.NoOfHours) as 'Total Hours' , (r.priceRate * SUM(a.NoOfHours)) as 'SubTotal' 
FROM student s, course c, invoicedetails id , attendance a, rate r, category cat
WHERE s.studentID = id.studentID and c.courseID = id.courseID AND a.attendanceID = id.attendanceID AND r.CategoryID=cat.CategoryID AND s.CategoryID= cat.CategoryID  AND r.GroupID = a.GroupSession AND  a.DeletedAt is null
GROUP by id.InvoiceDetailID$$

DROP PROCEDURE IF EXISTS `spInvoiceSearch`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spInvoiceSearch` (IN `First_Name` VARCHAR(255))  NO SQL
SELECT DISTINCT id.DateIssued, id.InvoiceDetailID, CONCAT(s.FirstName, ' ' ,s.Surname) AS 'Full Name',S.grade, s.EmailAddress, c.courseName AS 'Course', r.priceRate,a.TimeSlot , SUM(a.NoOfHours) as 'Total Hours' , (r.priceRate * SUM(a.NoOfHours)) as 'SubTotal' 
FROM student s, course c, invoicedetails id , attendance a, rate r, category cat
WHERE  s.studentID = id.studentID AND c.courseID = id.courseID AND a.attendanceID = id.attendanceID AND r.CategoryID = cat.CategoryID AND s.CategoryID = cat.CategoryID AND r.GroupID = a.GroupSession AND CONCAT(s.FirstName, ' ', s.Surname) LIKE CONCAT('%', First_Name,'%') AND id.DeletedAt is NULL
GROUP By id.InvoiceDetailID$$

DROP PROCEDURE IF EXISTS `spInvoiceSearchByDate`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spInvoiceSearchByDate` (IN `Start_Date` DATETIME, IN `First_Name` VARCHAR(255))  NO SQL
SELECT id.DateIssued, id.InvoiceDetailID, CONCAT(s.FirstName, ' ' ,s.Surname) AS 'Full Name',s.grade, s.EmailAddress, c.courseName AS 'Course', r.priceRate,a.TimeSlot , SUM(a.NoOfHours) as 'Total Hours' , (r.priceRate * SUM(a.NoOfHours)) as 'SubTotal' 
FROM student s, course c, invoicedetails id , attendance a, rate r, category cat
WHERE s.studentID = id.studentID and c.courseID = id.courseID AND a.attendanceID = id.attendanceID AND r.CategoryID=cat.CategoryID AND s.CategoryID= cat.CategoryID  AND r.GroupID = a.GroupSession AND CONCAT(s.FirstName, ' ', s.Surname) LIKE CONCAT('%', First_Name,'%') AND a.TimeSlot >= Start_Date AND id.DeletedAt is NULL
GROUP by id.InvoiceDetailID$$

DROP PROCEDURE IF EXISTS `spIsAttendanceExist`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spIsAttendanceExist` (IN `std_ID` INT(11), IN `time_slot` DATETIME, IN `no_OfHours` INT)  NO SQL
SELECT CONCAT(s.FirstName, ' ' ,s.Surname) AS 'Full Name', a.TimeSlot, ADDTIME(a.TimeSlot, (SEC_TO_TIME(a.NoOfHours*60*60)))  as 'Duration'
FROM attendance a, student s
WHERE a.StudentID = std_ID AND s.StudentID= std_ID AND s.StudentID = a.StudentID 
AND (
   	 time_slot BETWEEN (a.TimeSlot) AND ADDTIME(a.TimeSlot,	    (SEC_TO_TIME(a.NoOfHours*60*60))) 
		OR ADDTIME(time_slot, (SEC_TO_TIME(no_OfHours*60*60))) BETWEEN (a.TimeSlot) AND ADDTIME(a.TimeSlot, (SEC_TO_TIME(a.NoOfHours*60*60)))
	)$$

DROP PROCEDURE IF EXISTS `spIsCourseExist`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spIsCourseExist` (IN `course_name` VARCHAR(255))  NO SQL
SELECT c.CourseID
FROM course c
WHERE c.CourseName = course_name AND c.DeleteAt is NULL$$

DROP PROCEDURE IF EXISTS `spIsStudentExist`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spIsStudentExist` (IN `First_Name` VARCHAR(255), IN `Sur_name` VARCHAR(255))  NO SQL
SELECT s.StudentID
FROM student s
WHERE s.`FirstName` = First_Name AND s.`Surname`=Sur_name
AND s.DeletedAt is NULL$$

DROP PROCEDURE IF EXISTS `spIsUserExist`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spIsUserExist` (IN `user_name` VARCHAR(255))  NO SQL
SELECT u.UserID
FROM users u
WHERE u.Username = user_name AND u.DeletedAt is NULL$$

DROP PROCEDURE IF EXISTS `spListAllcourses`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spListAllcourses` ()  NO SQL
SELECT c.courseID,  c.courseName as 'Course Name'
FROM course c
WHERE c.DeleteAt is NULL
ORDER BY c.courseName$$

DROP PROCEDURE IF EXISTS `spListStudents`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spListStudents` ()  NO SQL
SELECT s.studentID, CONCAT(s.FirstName, ' ',s.Surname) AS 'Fullname', s.EmailAddress AS 'E-mail', s.Sponsor, s.grade
FROM student s
WHERE s.DeletedAt is NULL
ORDER BY s.FirstName$$

DROP PROCEDURE IF EXISTS `spListTotalAttendees`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spListTotalAttendees` ()  NO SQL
SELECT s.studentID,c.courseID, CONCAT(s.FirstName,' ' ,s.Surname) as 'Student Name', c.courseName as 'Course'
FROM student s , course c, attendance a  
WHERE s.studentID = a.studentID AND c.courseID = a.courseID AND a.DeletedAt is NULL
GROUP BY s.studentID
ORDER BY s.FirstName$$

DROP PROCEDURE IF EXISTS `spListUsers`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spListUsers` ()  NO SQL
SELECT u.Username, CONCAT(u.FirstName, ' ', u.Surname) as 'Full Name'
FROM users u
WHERE u.DeletedAt is NULL$$

DROP PROCEDURE IF EXISTS `spLogin`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spLogin` (IN `user_name` VARCHAR(255), IN `pass_word` VARCHAR(255))  NO SQL
SELECT u.UserID
FROM users u
WHERE u.Username = user_name and u.Password = pass_word AND u.DeletedAt IS NULL$$

DROP PROCEDURE IF EXISTS `spMonthlyTotals`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spMonthlyTotals` (IN `startDate` DATETIME, IN `endDate` DATETIME)  NO SQL
SELECT DISTINCT
    CONCAT(s.FirstName, ' ', s.Surname) AS 'Full Name',
    
    s.grade AS 'Grade',
    a.TimeSlot AS 'Attended Date',
    vt.SubTotal	 AS 'Amount Due'
FROM
    student s,
    course c,
    invoicedetails id,
    attendance a,
    rate r,
    category cat,
    vinvoicewithoutspecial vt
WHERE
    s.studentID = id.studentID AND c.courseID = id.courseID AND a.attendanceID = id.attendanceID AND r.CategoryID = cat.CategoryID AND s.CategoryID = cat.CategoryID AND id.studentID = vt.StudentID AND r.GroupID = a.GroupSession AND a.DeletedAt IS NULL AND a.TimeSlot >= startDate AND a.TimeSlot <= endDate  AND CONCAT(s.FirstName, ' ', s.Surname)NOT IN('Abby Cornel','Kelsey Froneman','Andrea Ambler','Mia Deacon','Cole Honey') 
GROUP BY
    s.StudentID$$

DROP PROCEDURE IF EXISTS `spSearchUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spSearchUser` (IN `search_Name` VARCHAR(255))  NO SQL
SELECT u.Username, CONCAT(u.FirstName, ' ', u.Surname) as 'Full Name'
FROM users u
WHERE  CONCAT(u.Username, ' ', u.FirstName, ' ', u.Surname) LIKE  CONCAT('%', search_Name,'%') AND u.DeletedAt is NULL$$

DROP PROCEDURE IF EXISTS `spSpecialByDate`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spSpecialByDate` (IN `Start_Date` DATETIME, IN `First_Name` VARCHAR(255))  NO SQL
SELECT
    id.DateIssued,
    id.InvoiceDetailID,
    CONCAT(s.FirstName, ' ', s.Surname) AS 'Full Name',
    s.EmailAddress,
    c.courseName AS 'Course',
    ((r.priceRate - r.priceRate) +150) AS 'priceRate',
    a.TimeSlot,s.grade,
    SUM(a.NoOfHours) AS 'Total Hours',
    (
        ((r.priceRate - r.priceRate) +150) * SUM(a.NoOfHours)
    ) AS 'SubTotal'
FROM
    student s,
    course c,
    invoicedetails id,
    attendance a,
    rate r,
    category cat
WHERE
    s.studentID = id.studentID AND c.courseID = id.courseID AND a.attendanceID = id.attendanceID AND r.CategoryID = cat.CategoryID AND s.CategoryID = cat.CategoryID AND r.GroupID = a.GroupSession AND CONCAT(s.FirstName, ' ', s.Surname) LIKE CONCAT('%', First_Name, '%') AND a.TimeSlot >= Start_Date AND id.DeletedAt IS NULL
GROUP BY
    id.InvoiceDetailID$$

DROP PROCEDURE IF EXISTS `spSpecialInvoice`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spSpecialInvoice` (IN `First_Name` VARCHAR(255))  NO SQL
SELECT
    id.DateIssued,
    id.InvoiceDetailID,
    CONCAT(s.FirstName, ' ', s.Surname) AS 'Full Name',
    s.EmailAddress,
    c.courseName AS 'Course',
    ((r.priceRate - r.priceRate) +150) AS 'priceRate',
    a.TimeSlot,s.grade,
    SUM(a.NoOfHours) AS 'Total Hours',
    (
        ((r.priceRate - r.priceRate) +150) * SUM(a.NoOfHours)
    ) AS 'SubTotal'
FROM
    student s,
    course c,
    invoicedetails id,
    attendance a,
    rate r,
    category cat
WHERE
    s.studentID = id.studentID AND c.courseID = id.courseID AND a.attendanceID = id.attendanceID AND r.CategoryID = cat.CategoryID AND s.CategoryID = cat.CategoryID AND r.GroupID = a.GroupSession AND CONCAT(s.FirstName, ' ', s.Surname) LIKE CONCAT('%', First_Name, '%') AND id.DeletedAt IS NULL
GROUP BY
    id.InvoiceDetailID$$

DROP PROCEDURE IF EXISTS `spSpecialStudent`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spSpecialStudent` (IN `startDate` DATETIME, IN `endDate` DATETIME, IN `paraName` INT)  NO SQL
SELECT
    CONCAT(s.FirstName, ' ', s.Surname) AS 'Full Name',
    s.grade as 'Grade',a.TimeSlot as 'Attended Date',
    (
        ((r.priceRate - r.priceRate) +100) * SUM(a.NoOfHours)) AS 'Amount Due'
FROM
    student s,
    course c,
    invoicedetails id,
    attendance a,
    rate r,
    category cat
WHERE
    s.studentID = id.studentID AND c.courseID = id.courseID AND a.attendanceID = id.attendanceID AND r.CategoryID = cat.CategoryID AND s.CategoryID = cat.CategoryID AND r.GroupID = a.GroupSession AND CONCAT(s.FirstName, ' ', s.Surname) IN('Cole Honey') AND id.DeletedAt IS NULL AND a.TimeSlot >= startDate AND a.TimeSlot <=endDate AND s.grade = paraName
GROUP BY
    s.StudentID$$

DROP PROCEDURE IF EXISTS `spSpecialStudents`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spSpecialStudents` (IN `startDate` DATETIME, IN `endDate` DATETIME, IN `paraName` INT)  NO SQL
SELECT
    CONCAT(s.FirstName, ' ', s.Surname) AS 'Full Name',
    s.grade as 'Grade',a.TimeSlot as 'Attended Date',
    (
        ((r.priceRate - r.priceRate) +150) * SUM(a.NoOfHours)) AS 'Amount Due'
FROM
    student s,
    course c,
    invoicedetails id,
    attendance a,
    rate r,
    category cat
WHERE
    s.studentID = id.studentID AND c.courseID = id.courseID AND a.attendanceID = id.attendanceID AND r.CategoryID = cat.CategoryID AND s.CategoryID = cat.CategoryID AND r.GroupID = a.GroupSession AND CONCAT(s.FirstName, ' ', s.Surname) IN('Abby Cornel','Kelsey Froneman','Andrea Ambler','Mia Deacon') AND id.DeletedAt IS NULL AND a.TimeSlot >= startDate AND a.TimeSlot <=endDate AND s.grade = paraName
GROUP BY
    s.StudentID$$

DROP PROCEDURE IF EXISTS `spStudentAttendance`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spStudentAttendance` (IN `student_ID` INT)  NO SQL
SELECT s.studentID, CONCAT(s.FirstName,' ',s.Surname) as 'Student Fullname'
FROM student s JOIN studentcourse a ON s.studentID = a.studentID 
WHERE s.studentID = student_ID
ORDER BY s.FirstName$$

DROP PROCEDURE IF EXISTS `spStudentsSearch`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spStudentsSearch` (IN `First_Name` VARCHAR(255))  NO SQL
SELECT s.studentID, CONCAT(s.FirstName, ' ',s.Surname) AS Fullname, s.grade, s.EmailAddress AS 'E-mail', s.Sponsor, S.PhoneNo
FROM student s
WHERE  CONCAT(s.FirstName, '  ',s.Surname)  LIKE CONCAT('%', First_Name,'%') AND s.DeletedAt is NULL$$

DROP PROCEDURE IF EXISTS `spUpdateAttendance`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUpdateAttendance` (IN `Course_ID` INT, IN `Group_Session` INT, IN `No_Of_Hours` INT, IN `Time_Slot` DATETIME, IN `Attendance_ID` INT)  NO SQL
BEGIN
START TRANSACTION;
UPDATE attendance
SET GroupSession=Group_Session, NoOfHours=No_Of_Hours, TimeSlot=Time_Slot, CourseID=course_ID
 WHERE AttendanceID= attendance_ID;

 UPDATE invoicedetails
    SET CourseID = course_ID
    WHERE AttendanceID =attendance_ID;
COMMIT;
END$$

DROP PROCEDURE IF EXISTS `spUpdateCourse`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUpdateCourse` (IN `course_ID` INT, IN `course_Name` VARCHAR(255))  NO SQL
UPDATE course c
SET c.CourseName = course_Name 
WHERE c.CourseID = course_ID$$

DROP PROCEDURE IF EXISTS `spUpdateStudent`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUpdateStudent` (IN `stdID` INT(11), IN `first_Name` VARCHAR(255), IN `last_Name` VARCHAR(255), IN `e_mail` VARCHAR(255), IN `spon_sor` VARCHAR(255), IN `catID` INT, IN `gra_de` INT)  NO SQL
UPDATE student s
SET s.FirstName = first_Name, s.Surname= last_Name, s.EmailAddress = e_mail,s.grade =gra_de, s.Sponsor= spon_sor,  s.CategoryID = catID
WHERE s.studentID = stdID$$

DROP PROCEDURE IF EXISTS `spUpdateUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUpdateUser` (IN `User_name` VARCHAR(255), IN `passCode` VARCHAR(255), IN `first_Name` VARCHAR(255), IN `last_Name` VARCHAR(255))  NO SQL
UPDATE users u
SET u.Username = User_name, u.Password= passCode, u.FirstName = first_Name, u.Surname=last_Name
WHERE u.Username = User_name$$

DROP PROCEDURE IF EXISTS `uspInvoiceSearch`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `uspInvoiceSearch` (IN `StdID` INT(11))  NO SQL
SELECT a.attendanceID, a.studentID,a.courseID, a.GroupSession, a.NoOfHours, a.CreatedAt, a.DeletedAt, c.courseRate, SUM(a.NoOfHours) as 'Total Hours' 
FROM attendance a, course c, invoicedetails id
WHERE id.studentID=stdID AND id.courseID=c.courseID AND id.attendanceID=a.attendanceID
GROUP by a.attendanceID$$

DROP PROCEDURE IF EXISTS `uspTotalDue`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `uspTotalDue` (IN `StdID` INT(11))  NO SQL
SELECT s.studentID, CONCAT(s.FirstName, ' ' ,s.Surname) AS 'Full Name', c.courseName, SUM(a.NoOfHours) as 'Total Hours', (r.priceRate * SUM(a.NoOfHours)) as 'Total Due' 
FROM attendance a, course c, student s, invoicedetails id, rate r, category cat
WHERE id.studentID=stdID AND id.courseID= c.courseID AND id.studentID=s.studentID AND id.attendanceID=a.attendanceID AND r.CategoryID=cat.CategoryID AND s.CategoryID= cat.CategoryID  AND r.GroupID = a.GroupSession AND a.DeletedAt IS NULL
GROUP BY c.courseID$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
CREATE TABLE IF NOT EXISTS `attendance` (
  `AttendanceID` int NOT NULL AUTO_INCREMENT,
  `CourseID` int NOT NULL,
  `StudentID` int NOT NULL,
  `TimeSlot` datetime NOT NULL,
  `NoOfHours` int NOT NULL,
  `GroupSession` int NOT NULL,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DeletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`AttendanceID`),
  KEY `CourseID` (`CourseID`,`StudentID`),
  KEY `StudentID` (`StudentID`)
) ENGINE=InnoDB AUTO_INCREMENT=616 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `attendance`
--

INSERT INTO `attendance` (`AttendanceID`, `CourseID`, `StudentID`, `TimeSlot`, `NoOfHours`, `GroupSession`, `CreatedAt`, `DeletedAt`) VALUES
(1, 1, 2, '2021-02-01 14:00:00', 1, 2, '2021-02-08 16:50:05', NULL),
(2, 1, 3, '2021-02-01 14:00:00', 1, 2, '2021-02-08 17:56:28', NULL),
(3, 1, 4, '2021-02-08 15:00:00', 1, 1, '2021-02-08 17:58:09', '2021-02-15 16:45:33'),
(4, 1, 5, '2021-02-01 16:00:00', 1, 1, '2021-02-08 17:59:54', NULL),
(5, 1, 6, '2021-02-05 11:00:00', 1, 1, '2021-02-08 18:14:48', '2021-02-15 16:46:46'),
(6, 1, 1, '2021-02-14 12:58:40', 1, 2, '2021-02-09 13:34:20', '2021-03-02 18:34:41'),
(7, 1, 7, '2021-02-01 18:00:00', 1, 1, '2021-02-09 16:21:28', NULL),
(8, 1, 9, '2021-02-01 16:00:00', 1, 4, '2021-02-09 16:23:52', NULL),
(9, 1, 10, '2021-02-08 16:00:00', 1, 3, '2021-02-09 16:24:32', NULL),
(10, 1, 11, '2021-02-01 16:00:00', 1, 4, '2021-02-09 16:26:13', NULL),
(11, 1, 12, '2021-02-01 16:00:00', 1, 4, '2021-02-09 16:26:32', NULL),
(12, 1, 31, '2021-02-01 17:00:00', 1, 4, '2021-02-09 16:36:31', NULL),
(13, 1, 14, '2021-02-01 17:00:00', 1, 4, '2021-02-09 16:36:49', NULL),
(14, 1, 15, '2021-02-01 17:00:00', 1, 4, '2021-02-09 16:37:39', NULL),
(15, 1, 16, '2021-02-01 17:00:00', 1, 4, '2021-02-09 16:37:47', NULL),
(16, 1, 17, '2021-02-01 17:00:00', 1, 4, '2021-02-09 16:37:58', NULL),
(17, 1, 18, '2021-02-01 18:00:00', 1, 4, '2021-02-09 16:38:19', NULL),
(18, 1, 19, '2021-02-01 18:00:00', 1, 4, '2021-02-09 16:38:37', NULL),
(19, 1, 20, '2021-02-22 18:00:00', 1, 4, '2021-02-09 16:38:49', NULL),
(20, 1, 21, '2021-02-01 18:00:00', 1, 4, '2021-02-09 16:38:56', NULL),
(21, 1, 26, '2021-02-04 14:00:00', 1, 1, '2021-02-09 17:17:57', '2021-03-01 10:47:45'),
(22, 1, 27, '2021-02-09 13:00:00', 1, 1, '2021-02-09 17:19:20', NULL),
(23, 1, 22, '2021-02-02 14:00:00', 1, 1, '2021-02-09 17:19:44', NULL),
(24, 1, 29, '2021-02-09 14:00:00', 1, 1, '2021-02-11 12:22:27', NULL),
(25, 1, 42, '2021-02-02 18:00:00', 1, 1, '2021-02-11 12:24:39', NULL),
(26, 1, 53, '2021-02-02 16:00:00', 1, 1, '2021-02-11 12:26:48', NULL),
(27, 1, 54, '2021-02-02 17:00:00', 1, 4, '2021-02-11 12:27:12', NULL),
(28, 1, 55, '2021-02-02 17:00:00', 1, 4, '2021-02-11 12:27:38', NULL),
(29, 1, 56, '2021-02-02 17:00:00', 1, 4, '2021-02-11 12:30:26', NULL),
(30, 1, 57, '2021-02-02 17:00:00', 1, 4, '2021-02-11 12:30:48', NULL),
(31, 1, 58, '2021-02-02 18:00:00', 1, 1, '2021-02-11 12:31:18', NULL),
(32, 1, 45, '2021-02-03 12:00:00', 1, 1, '2021-02-11 12:33:14', NULL),
(33, 1, 62, '2021-02-03 13:00:00', 1, 1, '2021-02-11 12:38:22', NULL),
(34, 1, 6, '2021-02-05 11:00:00', 1, 1, '2021-02-11 12:38:54', '2021-02-15 16:46:51'),
(35, 1, 63, '2021-02-03 15:00:00', 1, 1, '2021-02-11 12:40:25', NULL),
(36, 1, 64, '2021-02-03 16:00:00', 1, 1, '2021-02-11 12:41:51', NULL),
(37, 1, 65, '2021-02-03 18:00:00', 1, 3, '2021-02-11 12:46:01', NULL),
(38, 1, 66, '2021-02-03 18:00:00', 1, 3, '2021-02-11 12:46:29', NULL),
(39, 1, 67, '2021-02-03 18:00:00', 1, 3, '2021-02-11 12:46:49', NULL),
(40, 1, 68, '2021-02-03 19:00:00', 1, 1, '2021-02-11 12:47:13', NULL),
(41, 1, 70, '2021-02-03 16:00:00', 1, 4, '2021-02-11 12:59:52', NULL),
(42, 1, 28, '2021-02-09 16:00:00', 1, 7, '2021-02-11 13:27:20', '2021-02-28 10:53:03'),
(43, 1, 67, '2021-02-17 18:00:00', 1, 7, '2021-02-11 13:27:34', NULL),
(44, 1, 32, '2021-02-09 16:00:00', 1, 7, '2021-02-11 13:27:55', '2021-02-28 11:10:10'),
(45, 1, 33, '2021-02-02 16:00:00', 1, 7, '2021-02-11 13:28:12', '2021-02-28 10:59:55'),
(46, 2, 34, '2021-02-07 11:00:00', 1, 1, '2021-02-11 13:28:31', NULL),
(47, 1, 36, '2021-02-09 16:00:00', 1, 7, '2021-02-11 13:28:53', NULL),
(48, 1, 13, '2021-02-09 16:00:00', 1, 7, '2021-02-11 13:29:06', '2021-02-27 20:36:49'),
(49, 1, 37, '2021-02-09 17:00:00', 1, 6, '2021-02-11 13:29:46', NULL),
(50, 1, 47, '2021-02-09 17:00:00', 1, 6, '2021-02-11 13:29:56', NULL),
(51, 1, 39, '2021-02-09 17:00:00', 1, 6, '2021-02-11 13:30:07', NULL),
(52, 1, 41, '2021-02-02 17:00:00', 1, 5, '2021-02-11 13:30:17', NULL),
(53, 1, 40, '2021-02-09 17:00:00', 1, 6, '2021-02-11 13:30:32', NULL),
(54, 1, 26, '2021-02-04 14:00:00', 1, 1, '2021-02-11 13:31:03', '2021-03-01 10:47:49'),
(55, 1, 31, '2021-02-02 17:00:00', 1, 5, '2021-02-11 13:52:19', '2021-02-26 12:10:30'),
(56, 1, 14, '2021-02-22 17:00:00', 1, 5, '2021-02-11 13:52:31', NULL),
(57, 1, 15, '2021-02-22 17:00:00', 1, 5, '2021-02-11 13:52:44', NULL),
(58, 1, 16, '2021-02-22 17:00:00', 1, 5, '2021-02-11 13:52:55', NULL),
(59, 1, 17, '2021-02-22 17:00:00', 1, 5, '2021-02-11 13:53:07', NULL),
(60, 1, 18, '2021-02-22 18:00:00', 1, 4, '2021-02-11 13:53:33', NULL),
(61, 1, 19, '2021-02-02 18:00:00', 1, 4, '2021-02-11 13:53:45', '2021-02-26 12:53:25'),
(62, 1, 20, '2021-02-08 18:00:00', 1, 4, '2021-02-11 13:53:56', NULL),
(63, 1, 21, '2021-02-22 18:00:00', 1, 4, '2021-02-11 13:54:06', NULL),
(64, 1, 50, '2021-02-03 17:00:00', 1, 6, '2021-02-11 13:55:07', NULL),
(65, 1, 20, '2021-02-01 18:00:00', 1, 4, '2021-02-11 15:10:05', NULL),
(66, 1, 43, '2021-02-02 15:00:00', 1, 6, '2021-02-11 15:15:09', NULL),
(67, 1, 46, '2021-02-02 15:00:00', 1, 6, '2021-02-11 15:15:28', NULL),
(68, 1, 48, '2021-02-02 15:00:00', 1, 6, '2021-02-11 15:15:37', NULL),
(69, 1, 49, '2021-02-02 15:00:00', 1, 6, '2021-02-11 15:16:00', NULL),
(70, 1, 52, '2021-02-02 15:00:00', 1, 6, '2021-02-11 15:16:15', NULL),
(71, 1, 71, '2021-02-03 17:00:00', 1, 6, '2021-02-11 15:17:22', NULL),
(72, 1, 72, '2021-02-03 17:00:00', 1, 6, '2021-02-11 15:18:04', NULL),
(73, 1, 35, '2021-02-03 17:00:00', 1, 6, '2021-02-11 15:18:22', NULL),
(74, 1, 51, '2021-02-03 17:00:00', 1, 6, '2021-02-11 15:18:36', NULL),
(75, 1, 38, '2021-02-03 17:00:00', 1, 6, '2021-02-11 15:18:48', NULL),
(76, 1, 69, '2021-02-03 15:00:00', 1, 2, '2021-02-11 15:24:30', NULL),
(77, 1, 73, '2021-02-03 15:00:00', 1, 2, '2021-02-11 15:27:43', NULL),
(78, 1, 74, '2021-02-03 16:00:00', 1, 4, '2021-02-11 15:28:25', NULL),
(79, 1, 75, '2021-02-03 16:00:00', 1, 4, '2021-02-11 15:28:43', NULL),
(80, 1, 76, '2021-02-03 16:00:00', 1, 4, '2021-02-11 15:29:39', NULL),
(81, 1, 77, '2021-02-03 17:00:00', 1, 3, '2021-02-11 15:30:27', NULL),
(82, 1, 78, '2021-02-03 17:00:00', 1, 3, '2021-02-11 15:30:38', NULL),
(83, 1, 79, '2021-02-03 17:00:00', 1, 3, '2021-02-11 15:30:49', NULL),
(84, 1, 80, '2021-02-04 16:00:00', 1, 2, '2021-02-11 15:34:00', '2021-02-25 15:24:50'),
(85, 1, 81, '2021-02-04 16:00:00', 1, 2, '2021-02-11 15:36:11', NULL),
(86, 1, 82, '2021-02-04 17:00:00', 1, 1, '2021-02-11 15:37:43', NULL),
(87, 1, 83, '2021-02-04 12:00:00', 1, 1, '2021-02-11 15:44:14', NULL),
(88, 1, 26, '2021-02-04 14:00:00', 1, 1, '2021-02-11 15:44:48', '2021-03-01 10:47:54'),
(89, 1, 22, '2021-02-04 14:00:00', 1, 1, '2021-02-11 15:45:27', NULL),
(90, 1, 44, '2021-02-04 15:00:00', 1, 1, '2021-02-11 15:45:58', NULL),
(91, 1, 42, '2021-02-04 16:00:00', 1, 1, '2021-02-11 15:46:23', NULL),
(92, 1, 84, '2021-02-04 17:00:00', 1, 1, '2021-02-11 16:10:41', NULL),
(93, 1, 85, '2021-02-04 18:00:00', 1, 3, '2021-02-11 16:11:16', NULL),
(94, 1, 86, '2021-02-04 18:00:00', 1, 3, '2021-02-11 16:12:23', NULL),
(95, 1, 33, '2021-02-04 18:00:00', 1, 3, '2021-02-11 16:12:36', NULL),
(96, 1, 87, '2021-02-05 15:00:00', 1, 1, '2021-02-11 16:21:07', NULL),
(97, 1, 88, '2021-02-05 16:00:00', 1, 1, '2021-02-11 16:21:33', NULL),
(98, 1, 90, '2021-02-06 10:00:00', 1, 1, '2021-02-11 16:31:30', NULL),
(99, 1, 89, '2021-02-06 12:00:00', 1, 1, '2021-02-11 16:36:32', NULL),
(100, 1, 93, '2021-02-07 11:00:00', 1, 1, '2021-02-11 16:49:12', NULL),
(101, 1, 94, '2021-02-07 12:00:00', 1, 2, '2021-02-11 17:09:43', NULL),
(102, 1, 95, '2021-02-07 13:00:00', 1, 4, '2021-02-11 17:10:14', NULL),
(103, 1, 96, '2021-02-07 13:00:00', 1, 4, '2021-02-11 17:10:27', NULL),
(104, 1, 97, '2021-03-14 13:00:00', 1, 3, '2021-02-11 17:10:39', '2021-02-28 13:02:56'),
(105, 1, 98, '2021-02-07 13:00:00', 1, 4, '2021-02-11 17:10:50', NULL),
(106, 1, 7, '2021-02-07 15:00:00', 1, 3, '2021-02-11 17:11:12', NULL),
(107, 1, 99, '2021-02-07 15:00:00', 1, 3, '2021-02-11 17:11:44', NULL),
(108, 1, 100, '2021-02-07 15:00:00', 1, 3, '2021-02-11 17:11:54', NULL),
(109, 1, 102, '2021-02-07 10:00:00', 1, 3, '2021-02-11 17:12:23', NULL),
(110, 1, 101, '2021-02-07 10:00:00', 1, 3, '2021-02-11 17:12:35', NULL),
(111, 1, 103, '2021-02-07 10:00:00', 1, 3, '2021-02-11 17:12:43', NULL),
(112, 1, 26, '2021-02-04 14:00:00', 1, 1, '2021-02-11 17:13:22', '2021-03-01 10:47:57'),
(113, 1, 27, '2021-02-23 10:15:00', 1, 1, '2021-02-11 17:13:36', NULL),
(114, 1, 29, '2021-02-16 08:15:00', 1, 1, '2021-02-11 17:13:53', NULL),
(115, 1, 28, '2021-02-09 16:00:00', 1, 7, '2021-02-11 17:14:49', '2021-02-28 10:52:59'),
(116, 1, 26, '2021-02-04 14:00:00', 1, 1, '2021-02-11 17:19:23', NULL),
(117, 1, 29, '2021-02-02 15:00:00', 1, 1, '2021-02-11 17:19:55', NULL),
(118, 1, 26, '2021-02-04 14:00:00', 1, 1, '2021-02-11 17:21:42', '2021-03-01 11:01:45'),
(119, 1, 26, '2021-02-02 12:00:00', 1, 1, '2021-02-11 17:24:25', NULL),
(120, 1, 26, '2021-02-09 12:00:00', 1, 1, '2021-02-11 17:25:48', NULL),
(121, 1, 27, '2021-02-02 13:00:00', 1, 1, '2021-02-11 17:26:38', NULL),
(122, 1, 4, '2021-02-08 15:00:00', 1, 1, '2021-02-11 17:28:42', '2021-02-15 16:45:41'),
(123, 1, 4, '2021-02-01 15:00:00', 1, 1, '2021-02-11 17:30:12', '2021-02-18 17:22:38'),
(124, 1, 5, '2021-02-08 16:00:00', 1, 1, '2021-02-11 17:31:07', NULL),
(125, 3, 3, '2021-02-08 17:00:00', 1, 5, '2021-02-11 17:32:39', '2021-02-28 20:19:49'),
(126, 1, 2, '2021-02-08 17:00:00', 1, 5, '2021-02-11 17:33:04', '2021-02-23 15:42:00'),
(127, 1, 104, '2021-02-08 17:00:00', 1, 5, '2021-02-11 17:34:05', NULL),
(128, 1, 7, '2021-02-08 18:00:00', 1, 1, '2021-02-11 17:34:34', NULL),
(129, 1, 53, '2021-02-08 15:00:00', 1, 1, '2021-02-11 17:35:26', NULL),
(130, 1, 11, '2021-02-08 16:00:00', 1, 3, '2021-02-11 17:35:51', NULL),
(131, 1, 10, '2021-02-08 16:00:00', 1, 3, '2021-02-11 17:36:05', '2021-02-25 15:38:57'),
(132, 1, 12, '2021-02-08 16:00:00', 1, 3, '2021-02-11 17:36:15', NULL),
(133, 1, 31, '2021-02-08 17:00:00', 1, 6, '2021-02-11 17:36:56', NULL),
(134, 1, 14, '2021-02-08 17:00:00', 1, 6, '2021-02-11 17:37:05', NULL),
(135, 1, 15, '2021-02-08 17:00:00', 1, 6, '2021-02-11 17:37:18', NULL),
(136, 1, 16, '2021-02-08 17:00:00', 1, 6, '2021-02-11 17:37:28', NULL),
(137, 1, 17, '2021-02-08 17:00:00', 1, 6, '2021-02-11 17:37:41', NULL),
(138, 1, 56, '2021-02-08 17:00:00', 1, 6, '2021-02-11 17:37:54', NULL),
(139, 1, 18, '2021-02-08 18:00:00', 1, 4, '2021-02-11 17:38:28', NULL),
(140, 1, 19, '2021-02-08 18:00:00', 1, 4, '2021-02-11 17:38:39', NULL),
(141, 1, 21, '2021-02-08 18:00:00', 1, 4, '2021-02-11 17:38:49', NULL),
(142, 1, 60, '2021-02-08 15:00:00', 1, 1, '2021-02-11 17:39:51', NULL),
(143, 2, 24, '2021-02-08 16:00:00', 1, 1, '2021-02-11 17:40:16', NULL),
(144, 6, 25, '2021-02-08 17:00:00', 1, 1, '2021-02-11 17:40:38', NULL),
(145, 2, 23, '2021-02-08 18:00:00', 1, 1, '2021-02-11 17:40:58', NULL),
(146, 2, 22, '2021-02-08 19:00:00', 1, 1, '2021-02-11 17:41:16', NULL),
(147, 1, 28, '2021-02-09 16:00:00', 1, 7, '2021-02-11 17:43:26', NULL),
(148, 1, 30, '2021-02-09 16:00:00', 1, 7, '2021-02-11 17:45:06', NULL),
(149, 1, 32, '2021-02-09 16:00:00', 1, 7, '2021-02-11 17:45:17', NULL),
(150, 1, 33, '2021-02-09 15:00:00', 1, 7, '2021-02-11 17:45:30', '2021-02-28 11:00:55'),
(151, 1, 13, '2021-02-09 16:00:00', 1, 7, '2021-02-11 17:45:42', NULL),
(152, 1, 34, '2021-02-09 16:00:00', 1, 7, '2021-02-11 17:45:57', NULL),
(153, 1, 36, '2021-02-02 16:00:00', 1, 7, '2021-02-11 17:46:08', NULL),
(154, 1, 39, '2021-02-02 17:00:00', 1, 5, '2021-02-11 17:56:18', NULL),
(155, 1, 37, '2021-02-02 17:00:00', 1, 6, '2021-02-11 17:56:28', NULL),
(156, 1, 105, '2021-02-09 17:00:00', 1, 6, '2021-02-11 18:10:52', NULL),
(157, 1, 41, '2021-02-09 17:00:00', 1, 6, '2021-02-11 18:11:05', NULL),
(158, 1, 47, '2021-02-16 17:00:00', 1, 5, '2021-02-11 18:11:16', NULL),
(159, 1, 40, '2021-02-02 17:00:00', 1, 5, '2021-02-11 18:11:24', NULL),
(160, 1, 42, '2021-02-09 18:00:00', 1, 1, '2021-02-11 18:12:10', NULL),
(161, 1, 106, '2021-02-09 16:00:00', 1, 7, '2021-02-11 18:15:08', NULL),
(162, 1, 59, '2021-02-09 14:00:00', 1, 1, '2021-02-11 18:18:55', NULL),
(163, 1, 60, '2021-02-09 15:00:00', 1, 1, '2021-02-11 18:19:17', NULL),
(164, 1, 23, '2021-02-09 16:00:00', 1, 1, '2021-02-11 18:19:37', NULL),
(165, 1, 61, '2021-02-09 17:00:00', 1, 1, '2021-02-11 18:19:59', NULL),
(166, 1, 9, '2021-02-09 14:00:00', 1, 1, '2021-02-11 18:20:36', NULL),
(167, 1, 43, '2021-02-09 15:00:00', 1, 6, '2021-02-11 18:21:07', NULL),
(168, 1, 48, '2021-02-09 15:00:00', 1, 6, '2021-02-11 18:21:16', '2021-02-25 18:09:18'),
(169, 1, 46, '2021-02-09 15:00:00', 1, 6, '2021-02-11 18:21:25', NULL),
(170, 1, 49, '2021-02-25 18:15:52', 1, 6, '2021-02-11 18:21:54', '2021-02-25 18:16:31'),
(171, 1, 52, '2021-02-09 15:00:00', 1, 6, '2021-02-11 18:22:09', NULL),
(172, 1, 107, '2021-02-09 16:00:00', 1, 2, '2021-02-11 18:24:34', NULL),
(173, 1, 108, '2021-02-09 16:00:00', 1, 2, '2021-02-11 18:24:44', NULL),
(174, 1, 55, '2021-02-09 17:00:00', 1, 3, '2021-02-11 18:25:06', NULL),
(175, 1, 54, '2021-02-09 17:00:00', 1, 3, '2021-02-11 18:25:16', NULL),
(176, 1, 57, '2021-02-09 17:00:00', 1, 3, '2021-02-11 18:25:25', NULL),
(177, 1, 58, '2021-02-09 18:00:00', 1, 1, '2021-02-11 18:25:44', NULL),
(178, 1, 103, '2021-02-09 19:00:00', 1, 1, '2021-02-11 18:25:58', NULL),
(179, 1, 109, '2021-02-10 15:00:00', 1, 1, '2021-02-11 18:28:02', '2021-02-28 18:32:46'),
(180, 2, 106, '2021-02-10 16:00:00', 1, 1, '2021-02-11 18:28:27', NULL),
(181, 5, 1, '2021-02-01 11:00:00', 2, 2, '2021-02-14 12:55:22', '2021-03-02 18:34:41'),
(182, 5, 1, '2021-02-02 11:00:00', 2, 2, '2021-02-14 12:55:26', '2021-03-02 18:34:41'),
(183, 2, 1, '2021-02-14 12:56:58', 2, 1, '2021-02-14 13:17:51', '2021-03-02 18:34:41'),
(184, 4, 1, '2021-02-24 15:52:32', 6, 4, '2021-02-14 13:19:26', '2021-03-02 18:34:41'),
(185, 5, 1, '2021-02-15 13:00:06', 3, 5, '2021-02-14 13:28:05', '2021-03-02 18:34:41'),
(186, 1, 6, '2021-02-01 17:00:00', 1, 1, '2021-02-15 16:47:33', NULL),
(187, 1, 25, '2021-02-10 17:00:00', 1, 1, '2021-02-15 16:50:08', NULL),
(188, 2, 95, '2021-02-10 18:00:00', 1, 1, '2021-02-15 16:50:25', NULL),
(189, 1, 53, '2021-02-10 14:00:00', 1, 1, '2021-02-15 16:50:58', NULL),
(190, 1, 69, '2021-02-10 15:00:00', 1, 3, '2021-02-15 16:51:23', NULL),
(191, 1, 111, '2021-02-10 15:00:00', 1, 3, '2021-02-15 17:01:36', NULL),
(192, 1, 73, '2021-02-10 15:00:00', 1, 3, '2021-02-15 17:02:45', NULL),
(193, 1, 74, '2021-02-10 16:00:00', 1, 3, '2021-02-15 17:05:16', NULL),
(194, 1, 70, '2021-02-10 16:00:00', 1, 3, '2021-02-15 17:05:29', NULL),
(195, 1, 76, '2021-02-10 16:00:00', 1, 3, '2021-02-15 17:05:59', NULL),
(196, 1, 77, '2021-02-10 17:00:00', 1, 3, '2021-02-15 17:06:22', NULL),
(197, 1, 11, '2021-02-10 17:00:00', 1, 3, '2021-02-15 17:09:13', '2021-02-25 14:41:24'),
(198, 1, 79, '2021-02-10 17:00:00', 1, 3, '2021-02-15 17:09:28', NULL),
(199, 1, 6, '2021-02-10 12:00:00', 1, 1, '2021-02-15 17:09:51', NULL),
(200, 1, 62, '2021-02-10 13:00:00', 1, 1, '2021-02-15 17:10:07', NULL),
(201, 1, 63, '2021-02-10 14:00:00', 1, 1, '2021-02-15 17:10:30', NULL),
(202, 1, 88, '2021-02-10 15:00:00', 1, 1, '2021-02-15 17:10:43', NULL),
(203, 1, 112, '2021-02-10 16:00:00', 1, 1, '2021-02-15 17:13:54', NULL),
(204, 1, 51, '2021-02-10 17:00:00', 1, 6, '2021-02-15 17:14:19', NULL),
(205, 1, 50, '2021-02-10 17:00:00', 1, 6, '2021-02-15 17:14:28', NULL),
(206, 1, 71, '2021-02-10 17:00:00', 1, 6, '2021-02-15 17:14:39', NULL),
(207, 1, 38, '2021-02-10 17:00:00', 1, 6, '2021-02-15 17:14:49', NULL),
(208, 1, 35, '2021-02-10 17:00:00', 1, 6, '2021-02-15 17:15:06', NULL),
(209, 1, 72, '2021-02-10 17:00:00', 1, 6, '2021-02-15 17:15:26', NULL),
(210, 1, 7, '2021-02-10 18:00:00', 1, 5, '2021-02-15 17:15:51', NULL),
(211, 1, 100, '2021-02-10 18:00:00', 1, 5, '2021-02-15 17:15:59', NULL),
(212, 1, 65, '2021-02-10 18:00:00', 1, 5, '2021-02-15 17:16:14', NULL),
(213, 1, 66, '2021-02-10 18:00:00', 1, 5, '2021-02-15 17:16:27', NULL),
(214, 1, 67, '2021-02-10 18:00:00', 1, 5, '2021-02-15 17:16:36', NULL),
(215, 3, 113, '2021-02-11 16:00:00', 1, 1, '2021-02-15 17:18:52', NULL),
(216, 3, 114, '2021-02-11 17:00:00', 1, 1, '2021-02-15 17:19:05', NULL),
(217, 1, 83, '2021-02-11 12:00:00', 1, 1, '2021-02-15 17:19:38', NULL),
(218, 1, 26, '2021-02-11 13:00:00', 1, 1, '2021-02-15 17:19:52', NULL),
(219, 1, 44, '2021-02-11 14:00:00', 1, 1, '2021-02-15 17:20:05', NULL),
(220, 1, 22, '2021-02-11 15:00:00', 1, 1, '2021-02-15 17:20:16', NULL),
(221, 1, 42, '2021-02-11 16:00:00', 1, 1, '2021-02-15 17:20:31', NULL),
(222, 1, 84, '2021-02-11 17:00:00', 1, 1, '2021-02-15 17:20:46', NULL),
(223, 1, 95, '2021-02-11 18:00:00', 1, 4, '2021-02-15 17:21:04', NULL),
(224, 1, 39, '2021-02-16 17:00:00', 1, 4, '2021-02-15 17:21:12', NULL),
(225, 1, 33, '2021-02-11 18:00:00', 1, 4, '2021-02-15 17:21:21', NULL),
(226, 1, 85, '2021-02-11 18:00:00', 1, 4, '2021-02-15 17:21:29', NULL),
(227, 1, 89, '2021-02-11 19:00:00', 1, 1, '2021-02-15 17:21:53', NULL),
(228, 1, 115, '2021-02-11 15:00:00', 1, 1, '2021-02-15 17:25:00', NULL),
(229, 1, 81, '2021-02-11 16:00:00', 1, 3, '2021-02-15 17:25:24', NULL),
(230, 1, 80, '2021-02-11 16:00:00', 1, 3, '2021-02-15 17:25:49', NULL),
(231, 1, 116, '2021-02-11 16:00:00', 1, 3, '2021-02-15 17:28:14', NULL),
(232, 1, 82, '2021-02-11 17:00:00', 1, 1, '2021-02-15 17:28:36', NULL),
(233, 1, 58, '2021-02-11 18:00:00', 1, 1, '2021-02-15 17:28:49', NULL),
(234, 1, 103, '2021-02-11 19:00:00', 1, 1, '2021-02-15 17:29:00', NULL),
(235, 1, 87, '2021-02-12 15:00:00', 1, 1, '2021-02-15 17:29:37', NULL),
(236, 1, 91, '2021-02-13 10:00:00', 1, 1, '2021-02-15 17:30:28', NULL),
(237, 1, 92, '2021-02-13 12:00:00', 1, 1, '2021-02-15 17:30:46', NULL),
(238, 1, 90, '2021-02-13 10:00:00', 1, 1, '2021-02-15 17:31:05', NULL),
(239, 1, 117, '2021-02-14 10:00:00', 1, 1, '2021-02-15 17:34:15', NULL),
(240, 1, 102, '2021-02-14 10:00:00', 1, 4, '2021-02-15 17:35:17', NULL),
(241, 1, 75, '2021-02-14 10:00:00', 1, 4, '2021-02-15 17:35:28', NULL),
(242, 1, 101, '2021-02-14 10:00:00', 1, 4, '2021-02-15 17:35:37', NULL),
(243, 1, 118, '2021-02-14 10:00:00', 1, 4, '2021-02-15 17:37:31', NULL),
(244, 1, 119, '2021-02-14 11:00:00', 1, 1, '2021-02-15 17:39:18', NULL),
(245, 1, 94, '2021-02-14 12:00:00', 1, 3, '2021-02-15 17:39:58', NULL),
(246, 1, 65, '2021-02-17 18:00:00', 1, 5, '2021-02-15 17:40:10', NULL),
(247, 1, 97, '2021-02-21 13:00:00', 1, 3, '2021-02-15 17:40:41', NULL),
(248, 1, 98, '2021-02-14 13:00:00', 1, 3, '2021-02-15 17:42:30', NULL),
(249, 1, 96, '2021-02-14 13:00:00', 1, 3, '2021-02-15 17:42:42', NULL),
(250, 1, 7, '2021-02-14 14:00:00', 1, 4, '2021-02-15 17:43:00', NULL),
(251, 1, 99, '2021-02-14 14:00:00', 1, 4, '2021-02-15 17:43:14', NULL),
(252, 1, 105, '2021-02-14 14:00:00', 1, 4, '2021-02-15 17:43:29', NULL),
(253, 1, 100, '2021-02-14 14:00:00', 1, 4, '2021-02-15 17:43:37', NULL),
(254, 1, 4, '2021-02-15 15:00:00', 1, 2, '2021-02-15 17:44:20', NULL),
(255, 1, 120, '2021-02-15 15:00:00', 1, 2, '2021-02-15 17:45:56', NULL),
(256, 1, 5, '2021-02-15 16:00:00', 1, 1, '2021-02-15 17:46:14', NULL),
(257, 1, 3, '2021-02-15 17:00:00', 1, 5, '2021-02-15 17:46:31', NULL),
(258, 1, 2, '2021-02-15 17:00:00', 1, 5, '2021-02-15 17:46:41', NULL),
(259, 1, 104, '2021-02-15 17:00:00', 1, 5, '2021-02-15 17:46:53', NULL),
(260, 1, 7, '2021-02-15 18:00:00', 1, 1, '2021-02-15 17:47:17', NULL),
(261, 1, 88, '2021-02-15 18:00:00', 1, 1, '2021-02-15 17:47:28', NULL),
(262, 2, 24, '2021-02-15 16:00:00', 1, 1, '2021-02-15 17:49:04', NULL),
(263, 1, 25, '2021-02-17 17:00:00', 1, 1, '2021-02-15 17:49:23', NULL),
(264, 2, 23, '2021-02-15 18:00:00', 1, 1, '2021-02-15 17:49:40', NULL),
(265, 2, 28, '2021-02-15 19:00:00', 1, 1, '2021-02-15 17:50:00', NULL),
(266, 1, 31, '2021-02-15 17:00:00', 1, 5, '2021-02-15 17:50:31', NULL),
(267, 1, 14, '2021-02-15 17:00:00', 1, 5, '2021-02-15 17:50:41', NULL),
(268, 1, 15, '2021-02-15 17:00:00', 1, 5, '2021-02-15 17:50:57', NULL),
(269, 1, 16, '2021-02-15 17:00:00', 1, 5, '2021-02-15 17:51:11', NULL),
(270, 1, 17, '2021-02-15 17:00:00', 1, 5, '2021-02-15 17:51:23', NULL),
(271, 1, 18, '2021-02-15 18:00:00', 1, 5, '2021-02-15 17:51:42', NULL),
(272, 1, 19, '2021-02-15 18:00:00', 1, 5, '2021-02-15 17:51:53', NULL),
(273, 1, 20, '2021-02-15 18:00:00', 1, 5, '2021-02-15 17:52:01', NULL),
(274, 1, 21, '2021-02-15 18:00:00', 1, 5, '2021-02-15 17:52:09', NULL),
(275, 1, 121, '2021-02-15 18:00:00', 1, 5, '2021-02-15 17:53:44', NULL),
(276, 1, 34, '2021-02-14 11:00:00', 1, 1, '2021-02-18 16:01:15', '2021-02-27 20:25:57'),
(277, 1, 6, '2021-02-03 14:00:00', 1, 1, '2021-02-18 17:21:36', NULL),
(278, 1, 4, '2021-02-01 15:00:00', 1, 1, '2021-02-23 15:34:05', NULL),
(279, 1, 2, '2021-02-22 17:00:00', 1, 5, '2021-02-23 15:40:56', NULL),
(280, 1, 2, '2021-02-08 17:00:00', 1, 5, '2021-02-23 15:42:45', NULL),
(281, 1, 7, '2021-02-28 14:00:00', 1, 4, '2021-02-23 15:43:53', NULL),
(282, 1, 11, '2021-02-17 18:00:00', 1, 3, '2021-02-25 14:42:51', NULL),
(283, 1, 11, '2021-02-22 16:00:00', 1, 3, '2021-02-25 14:43:29', '2021-02-25 14:45:43'),
(284, 1, 11, '2021-02-22 16:00:00', 1, 3, '2021-02-25 14:44:59', NULL),
(285, 1, 11, '2021-02-22 16:00:00', 1, 3, '2021-02-25 14:45:03', '2021-02-25 14:45:57'),
(286, 1, 80, '2021-02-04 16:00:00', 1, 2, '2021-02-25 15:19:39', NULL),
(287, 1, 80, '2021-02-11 16:00:00', 1, 3, '2021-02-25 15:21:01', '2021-02-25 15:25:04'),
(288, 1, 80, '2021-02-25 16:00:00', 1, 3, '2021-02-25 15:22:50', NULL),
(289, 1, 10, '2021-02-08 17:00:00', 1, 6, '2021-02-25 15:32:56', '2021-02-25 15:38:42'),
(290, 1, 10, '2021-02-01 16:00:00', 1, 4, '2021-02-25 15:50:59', NULL),
(291, 1, 10, '2021-02-17 18:00:00', 1, 3, '2021-02-25 15:52:59', NULL),
(292, 1, 10, '2021-02-22 16:00:00', 1, 3, '2021-02-25 15:56:38', NULL),
(293, 1, 12, '2021-02-17 18:00:00', 1, 3, '2021-02-25 16:08:22', NULL),
(294, 1, 12, '2021-02-22 16:00:00', 1, 3, '2021-02-25 16:08:53', NULL),
(295, 1, 9, '2021-02-24 18:00:00', 1, 1, '2021-02-25 16:30:29', NULL),
(296, 1, 12, '2021-02-01 16:00:00', 1, 4, '2021-02-25 16:32:30', '2021-02-25 17:43:40'),
(297, 1, 43, '2021-02-17 19:00:00', 1, 6, '2021-02-25 16:37:17', NULL),
(298, 1, 43, '2021-02-23 15:00:00', 1, 6, '2021-02-25 16:38:23', NULL),
(299, 1, 46, '2021-02-17 19:00:00', 1, 6, '2021-02-25 16:41:00', NULL),
(300, 1, 46, '2021-02-23 15:00:00', 1, 6, '2021-02-25 16:46:34', NULL),
(301, 1, 48, '2021-02-09 15:00:00', 1, 6, '2021-02-25 16:47:12', NULL),
(302, 1, 48, '2021-02-17 19:00:00', 1, 6, '2021-02-25 16:47:44', NULL),
(303, 1, 48, '2021-02-23 15:00:00', 1, 6, '2021-02-25 16:48:02', NULL),
(304, 1, 49, '2021-03-09 15:00:00', 1, 6, '2021-02-25 16:48:54', '2021-02-25 18:16:13'),
(305, 1, 49, '2021-03-17 19:00:00', 1, 6, '2021-02-25 16:49:07', '2021-02-25 18:16:21'),
(306, 1, 49, '2021-02-23 15:00:00', 1, 6, '2021-02-25 16:49:17', NULL),
(307, 1, 52, '2021-02-09 15:00:00', 1, 6, '2021-02-25 16:49:40', '2021-02-25 18:14:20'),
(308, 1, 52, '2021-02-17 19:00:00', 1, 6, '2021-02-25 16:49:53', NULL),
(309, 1, 52, '2021-02-23 15:00:00', 1, 6, '2021-02-25 16:50:00', NULL),
(310, 1, 52, '2021-03-23 15:00:00', 1, 6, '2021-02-25 17:05:05', '2021-02-25 18:14:28'),
(311, 2, 122, '2021-02-25 10:00:00', 1, 1, '2021-02-25 17:27:09', '2021-03-02 18:33:12'),
(312, 1, 49, '2021-02-09 15:00:00', 1, 6, '2021-02-25 18:17:10', NULL),
(313, 1, 49, '2021-02-17 19:00:00', 1, 6, '2021-02-25 18:17:26', NULL),
(314, 1, 123, '2021-02-16 14:00:00', 1, 1, '2021-02-25 18:25:46', NULL),
(315, 1, 123, '2021-02-24 14:00:00', 1, 1, '2021-02-25 18:26:55', NULL),
(316, 1, 58, '2021-02-04 18:00:00', 1, 1, '2021-02-25 18:33:43', NULL),
(317, 1, 58, '2021-02-16 18:00:00', 1, 1, '2021-02-25 18:35:15', NULL),
(318, 1, 58, '2021-02-18 18:00:00', 1, 1, '2021-02-25 18:35:38', NULL),
(319, 1, 58, '2021-02-23 18:00:00', 1, 1, '2021-02-25 18:36:01', NULL),
(320, 1, 31, '2021-02-22 17:00:00', 1, 5, '2021-02-26 12:12:50', NULL),
(321, 1, 115, '2021-02-18 15:00:00', 1, 1, '2021-02-26 12:28:42', NULL),
(322, 1, 115, '2021-02-25 15:00:00', 1, 1, '2021-02-26 12:29:02', NULL),
(323, 1, 61, '2021-02-02 17:00:00', 1, 1, '2021-02-26 12:40:04', NULL),
(324, 1, 61, '2021-02-16 17:00:00', 1, 1, '2021-02-26 12:41:57', NULL),
(325, 1, 61, '2021-02-23 17:00:00', 1, 1, '2021-02-26 12:42:38', NULL),
(326, 1, 19, '2021-02-22 18:00:00', 1, 5, '2021-02-26 12:51:54', NULL),
(327, 1, 56, '2021-02-16 17:00:00', 1, 4, '2021-02-26 14:21:31', NULL),
(328, 1, 56, '2021-02-23 17:00:00', 1, 4, '2021-02-26 14:21:47', NULL),
(329, 1, 107, '2021-02-16 16:00:00', 1, 2, '2021-02-26 14:28:39', NULL),
(330, 1, 107, '2021-02-23 16:00:00', 1, 2, '2021-02-26 14:29:00', NULL),
(331, 1, 124, '2021-02-20 13:00:00', 1, 1, '2021-02-26 14:49:18', NULL),
(332, 1, 57, '2021-02-23 17:00:00', 1, 5, '2021-02-26 15:01:29', NULL),
(333, 1, 57, '2021-02-16 17:00:00', 1, 5, '2021-02-26 15:01:43', NULL),
(334, 1, 54, '2021-02-16 17:00:00', 1, 5, '2021-02-26 15:06:53', NULL),
(335, 1, 54, '2021-02-23 17:00:00', 1, 5, '2021-02-26 15:07:21', NULL),
(336, 1, 55, '2021-02-16 17:00:00', 1, 5, '2021-02-26 15:10:50', NULL),
(337, 1, 55, '2021-02-23 17:00:00', 1, 5, '2021-02-26 15:11:05', NULL),
(338, 1, 69, '2021-02-17 15:00:00', 1, 3, '2021-02-26 15:22:19', NULL),
(339, 1, 69, '2021-02-24 15:00:00', 1, 3, '2021-02-26 15:22:43', NULL),
(340, 1, 121, '2021-02-22 18:00:00', 1, 5, '2021-02-26 15:28:33', NULL),
(341, 6, 25, '2021-02-01 17:00:00', 1, 1, '2021-02-26 15:32:30', NULL),
(342, 1, 25, '2021-02-03 17:00:00', 1, 1, '2021-02-26 15:39:39', NULL),
(343, 6, 25, '2021-02-15 17:00:00', 1, 1, '2021-02-26 15:44:17', NULL),
(344, 6, 25, '2021-02-22 17:00:00', 1, 1, '2021-02-26 15:44:48', NULL),
(345, 1, 25, '2021-02-24 17:00:00', 1, 1, '2021-02-26 15:45:21', NULL),
(346, 1, 73, '2021-02-17 15:00:00', 1, 3, '2021-02-26 16:47:41', NULL),
(347, 1, 73, '2021-02-24 15:00:00', 1, 3, '2021-02-26 16:47:51', NULL),
(348, 1, 53, '2021-02-16 15:00:00', 1, 1, '2021-02-26 18:08:08', NULL),
(349, 1, 53, '2021-02-22 15:00:00', 1, 1, '2021-02-26 18:08:34', NULL),
(350, 1, 82, '2021-02-18 17:00:00', 1, 1, '2021-02-26 18:14:32', NULL),
(351, 1, 82, '2021-02-25 17:00:00', 1, 1, '2021-02-26 18:14:54', NULL),
(352, 1, 111, '2021-02-17 15:00:00', 1, 3, '2021-02-26 18:23:49', NULL),
(353, 1, 111, '2021-02-24 15:00:00', 1, 3, '2021-02-26 18:24:08', NULL),
(354, 1, 125, '2021-02-21 12:00:00', 1, 1, '2021-02-26 18:28:32', NULL),
(355, 1, 125, '2021-02-23 17:00:00', 1, 5, '2021-02-26 18:29:20', NULL),
(356, 1, 77, '2021-02-17 17:00:00', 1, 3, '2021-02-26 21:32:37', NULL),
(357, 1, 77, '2021-02-24 17:00:00', 1, 3, '2021-02-26 21:32:48', NULL),
(358, 1, 44, '2021-02-17 09:15:00', 1, 1, '2021-02-26 21:37:48', NULL),
(359, 1, 44, '2021-02-24 09:00:00', 1, 1, '2021-02-26 21:38:23', NULL),
(360, 1, 29, '2021-02-23 08:15:00', 1, 1, '2021-02-26 21:49:57', NULL),
(361, 1, 62, '2021-02-18 10:15:00', 1, 1, '2021-02-26 21:54:05', NULL),
(362, 1, 62, '2021-02-22 10:15:00', 1, 1, '2021-02-26 21:54:57', NULL),
(363, 1, 70, '2021-02-17 16:00:00', 1, 3, '2021-02-26 21:58:24', NULL),
(364, 1, 70, '2021-02-24 16:00:00', 1, 3, '2021-02-26 21:58:49', NULL),
(365, 1, 74, '2021-02-17 16:00:00', 1, 3, '2021-02-27 16:16:31', NULL),
(366, 1, 74, '2021-02-24 16:00:00', 1, 3, '2021-02-27 16:16:38', NULL),
(367, 1, 79, '2021-02-17 17:00:00', 1, 3, '2021-02-27 16:20:50', NULL),
(368, 1, 79, '2021-02-24 17:00:00', 1, 3, '2021-02-27 16:21:00', NULL),
(369, 1, 81, '2021-02-25 16:00:00', 1, 3, '2021-02-27 16:24:53', NULL),
(370, 1, 81, '2021-02-25 16:00:00', 1, 3, '2021-02-27 16:25:35', '2021-02-27 16:26:18'),
(371, 2, 22, '2021-02-01 14:00:00', 1, 1, '2021-02-27 16:31:15', NULL),
(372, 2, 22, '2021-02-17 16:00:00', 1, 1, '2021-02-27 16:33:42', NULL),
(373, 1, 22, '2021-02-21 10:00:00', 1, 1, '2021-02-27 16:34:06', NULL),
(374, 1, 22, '2021-02-18 15:00:00', 1, 1, '2021-02-27 16:37:15', NULL),
(375, 2, 22, '2021-02-24 15:00:00', 1, 1, '2021-02-27 16:38:35', NULL),
(376, 1, 22, '2021-02-25 15:00:00', 1, 1, '2021-02-27 16:43:12', NULL),
(377, 1, 22, '2021-02-28 10:00:00', 1, 1, '2021-02-27 16:43:45', NULL),
(378, 1, 101, '2021-02-21 10:00:00', 1, 3, '2021-02-27 17:00:18', NULL),
(379, 1, 126, '2021-02-24 09:00:00', 1, 1, '2021-02-27 17:04:40', NULL),
(380, 1, 116, '2021-02-11 16:00:00', 1, 3, '2021-02-27 17:07:20', '2021-02-27 17:08:56'),
(381, 1, 116, '2021-02-25 16:00:00', 1, 3, '2021-02-27 17:07:35', NULL),
(382, 1, 127, '2021-02-24 10:00:00', 1, 1, '2021-02-27 17:12:24', NULL),
(383, 1, 128, '2021-02-17 15:00:00', 1, 1, '2021-02-27 17:20:42', NULL),
(384, 1, 103, '2021-02-28 10:00:00', 1, 4, '2021-02-27 17:49:11', NULL),
(385, 1, 102, '2021-02-28 10:00:00', 1, 4, '2021-02-27 17:49:20', NULL),
(386, 1, 75, '2021-02-28 10:00:00', 1, 4, '2021-02-27 17:49:31', NULL),
(387, 1, 101, '2021-02-28 10:00:00', 1, 4, '2021-02-27 17:49:40', NULL),
(388, 1, 102, '2021-02-21 10:00:00', 1, 3, '2021-02-27 17:53:54', NULL),
(389, 1, 59, '2021-02-02 14:00:00', 1, 1, '2021-02-27 17:57:44', NULL),
(390, 1, 59, '2021-02-16 19:00:00', 1, 1, '2021-02-27 17:58:18', NULL),
(391, 1, 59, '2021-02-23 19:00:00', 1, 1, '2021-02-27 17:58:53', NULL),
(392, 1, 75, '2021-02-21 10:00:00', 1, 3, '2021-02-27 18:02:56', NULL),
(393, 1, 76, '2021-02-17 16:00:00', 1, 3, '2021-02-27 18:14:13', NULL),
(394, 1, 76, '2021-02-24 16:00:00', 1, 3, '2021-02-27 18:14:20', NULL),
(395, 1, 78, '2021-02-10 17:00:00', 1, 3, '2021-02-27 19:51:33', NULL),
(396, 1, 78, '2021-02-20 17:00:00', 1, 3, '2021-02-27 19:51:54', '2021-02-27 19:54:50'),
(397, 1, 78, '2021-02-17 17:00:00', 1, 3, '2021-02-27 19:55:16', NULL),
(398, 1, 78, '2021-02-24 17:00:00', 1, 3, '2021-02-27 19:55:26', NULL),
(399, 1, 89, '2021-02-20 12:00:00', 1, 1, '2021-02-27 20:01:07', NULL),
(400, 1, 89, '2021-02-27 12:00:00', 1, 1, '2021-02-27 20:01:34', NULL),
(401, 1, 34, '2021-02-02 16:00:00', 1, 7, '2021-02-27 20:19:33', NULL),
(402, 1, 34, '2021-02-09 16:00:00', 1, 7, '2021-02-27 20:21:46', '2021-02-27 20:25:40'),
(403, 2, 34, '2021-02-14 11:00:00', 1, 1, '2021-02-27 20:22:54', NULL),
(404, 1, 34, '2021-02-16 18:00:00', 1, 4, '2021-02-27 20:26:49', NULL),
(405, 2, 34, '2021-02-21 11:00:00', 1, 1, '2021-02-27 20:27:26', NULL),
(406, 1, 34, '2021-02-23 09:15:00', 1, 6, '2021-02-27 20:28:06', NULL),
(407, 1, 13, '2021-02-02 16:00:00', 1, 7, '2021-02-27 20:37:28', NULL),
(408, 1, 13, '2021-02-16 16:00:00', 1, 7, '2021-02-27 20:37:41', NULL),
(409, 1, 13, '2021-02-23 16:00:00', 1, 7, '2021-02-27 20:37:52', NULL),
(410, 1, 71, '2021-02-17 17:00:00', 1, 6, '2021-02-27 20:41:20', NULL),
(411, 1, 71, '2021-02-24 17:00:00', 1, 6, '2021-02-27 20:41:29', NULL),
(412, 2, 95, '2021-02-17 18:00:00', 1, 1, '2021-02-27 20:45:21', NULL),
(413, 1, 95, '2021-02-18 18:00:00', 1, 4, '2021-02-27 20:45:54', NULL),
(414, 2, 95, '2021-02-24 18:00:00', 1, 1, '2021-02-27 20:46:35', NULL),
(415, 1, 95, '2021-02-25 18:00:00', 1, 4, '2021-02-27 20:47:05', NULL),
(416, 1, 129, '2021-02-03 17:00:00', 1, 6, '2021-02-27 20:51:44', NULL),
(417, 1, 129, '2021-02-10 17:00:00', 1, 6, '2021-02-27 20:52:18', NULL),
(418, 1, 129, '2021-02-17 17:00:00', 1, 5, '2021-02-27 20:52:40', NULL),
(419, 1, 129, '2021-02-24 17:00:00', 1, 4, '2021-02-27 20:53:08', '2021-02-27 20:55:42'),
(420, 1, 129, '2021-02-24 17:00:00', 1, 4, '2021-02-27 20:53:17', NULL),
(421, 1, 86, '2021-02-11 18:00:00', 1, 4, '2021-02-28 10:02:15', NULL),
(422, 1, 86, '2021-02-18 18:00:00', 1, 4, '2021-02-28 10:03:12', NULL),
(423, 1, 86, '2021-02-25 18:00:00', 1, 4, '2021-02-28 10:03:40', '2021-02-28 10:05:19'),
(424, 1, 86, '2021-02-25 18:00:00', 1, 4, '2021-02-28 10:03:43', NULL),
(425, 1, 27, '2021-02-16 10:15:00', 1, 1, '2021-02-28 10:32:38', NULL),
(426, 1, 51, '2021-02-17 17:00:00', 1, 5, '2021-02-28 10:35:13', NULL),
(427, 1, 51, '2021-02-24 17:00:00', 1, 4, '2021-02-28 10:35:44', NULL),
(428, 1, 35, '2021-02-16 17:00:00', 1, 4, '2021-02-28 10:39:02', NULL),
(429, 1, 35, '2021-02-23 18:00:00', 1, 3, '2021-02-28 10:39:31', NULL),
(430, 1, 50, '2021-02-17 17:00:00', 1, 4, '2021-02-28 10:49:06', NULL),
(431, 1, 50, '2021-02-23 18:00:00', 1, 3, '2021-02-28 10:49:17', NULL),
(432, 1, 28, '2021-02-02 16:00:00', 1, 7, '2021-02-28 10:53:47', NULL),
(433, 1, 28, '2021-02-16 18:00:00', 1, 4, '2021-02-28 10:55:14', NULL),
(434, 1, 33, '2021-02-18 18:00:00', 1, 4, '2021-02-28 11:01:45', NULL),
(435, 1, 33, '2021-02-25 18:00:00', 1, 4, '2021-02-28 11:04:17', NULL),
(436, 1, 32, '2021-02-02 16:00:00', 1, 7, '2021-02-28 11:20:39', NULL),
(437, 2, 32, '2021-03-07 12:00:00', 1, 7, '2021-02-28 11:23:52', '2021-02-28 11:31:13'),
(438, 2, 32, '2021-02-07 12:00:00', 1, 1, '2021-02-28 11:31:36', NULL),
(439, 1, 32, '2021-02-16 18:00:00', 1, 4, '2021-02-28 11:32:22', NULL),
(440, 2, 32, '2021-02-21 12:00:00', 1, 1, '2021-02-28 11:32:52', NULL),
(441, 1, 32, '2021-02-23 18:00:00', 1, 3, '2021-02-28 11:35:20', NULL),
(442, 2, 32, '2021-02-28 12:00:00', 1, 1, '2021-02-28 11:40:10', NULL),
(443, 2, 34, '2021-02-28 15:00:00', 1, 1, '2021-02-28 11:43:50', NULL),
(444, 1, 118, '2021-02-28 10:00:00', 1, 6, '2021-02-28 11:45:25', '2021-02-28 11:46:19'),
(445, 1, 118, '2021-02-28 10:00:00', 1, 6, '2021-02-28 11:45:46', NULL),
(446, 1, 130, '2021-02-28 10:00:00', 1, 6, '2021-02-28 11:49:29', NULL),
(447, 2, 23, '2021-02-01 15:00:00', 1, 1, '2021-02-28 11:55:39', NULL),
(448, 1, 23, '2021-02-02 16:00:00', 1, 1, '2021-02-28 11:55:55', NULL),
(449, 1, 23, '2021-02-16 08:15:00', 1, 1, '2021-02-28 11:59:25', NULL),
(450, 2, 23, '2021-02-22 18:00:00', 1, 1, '2021-02-28 12:00:04', NULL),
(451, 1, 23, '2021-02-23 08:15:00', 1, 1, '2021-02-28 12:01:03', NULL),
(452, 1, 85, '2021-02-18 18:00:00', 1, 4, '2021-02-28 12:09:19', NULL),
(453, 1, 85, '2021-02-25 18:00:00', 1, 4, '2021-02-28 12:09:53', NULL),
(454, 1, 60, '2021-02-02 15:00:00', 1, 1, '2021-02-28 12:11:46', NULL),
(455, 1, 60, '2021-02-04 14:30:00', 1, 1, '2021-02-28 12:12:10', NULL),
(456, 1, 60, '2021-02-16 09:15:00', 1, 1, '2021-02-28 12:13:03', NULL),
(457, 1, 60, '2021-02-17 09:15:00', 1, 1, '2021-02-28 12:13:28', NULL),
(458, 1, 60, '2021-02-23 09:15:00', 1, 1, '2021-02-28 12:13:58', NULL),
(459, 1, 60, '2021-02-24 09:00:00', 1, 1, '2021-02-28 12:14:26', NULL),
(460, 1, 131, '2021-02-06 11:00:00', 1, 1, '2021-02-28 12:28:22', NULL),
(461, 1, 131, '2021-02-13 11:00:00', 1, 1, '2021-02-28 12:28:38', NULL),
(462, 1, 131, '2021-02-18 19:00:00', 1, 1, '2021-02-28 12:29:15', NULL),
(463, 1, 131, '2021-02-27 11:00:00', 1, 1, '2021-02-28 12:29:41', NULL),
(464, 1, 91, '2021-02-06 10:00:00', 1, 1, '2021-02-28 12:37:06', NULL),
(465, 1, 91, '2021-02-20 11:00:00', 1, 1, '2021-02-28 12:37:26', NULL),
(466, 1, 91, '2021-02-27 10:00:00', 1, 1, '2021-02-28 12:37:50', NULL),
(467, 1, 91, '2021-02-28 10:00:00', 1, 1, '2021-02-28 12:38:02', NULL),
(468, 1, 45, '2021-02-17 08:15:00', 1, 1, '2021-02-28 12:42:07', NULL),
(469, 1, 45, '2021-02-24 08:00:00', 1, 1, '2021-02-28 12:42:33', NULL),
(470, 1, 106, '2021-02-02 16:00:00', 1, 7, '2021-02-28 12:46:33', NULL),
(471, 2, 106, '2021-02-03 16:00:00', 1, 1, '2021-02-28 12:47:36', NULL),
(472, 1, 106, '2021-02-16 09:15:00', 1, 4, '2021-02-28 12:49:14', NULL),
(473, 2, 106, '2021-02-17 10:15:00', 1, 1, '2021-02-28 12:49:46', NULL),
(474, 1, 106, '2021-02-23 09:15:00', 1, 6, '2021-02-28 12:50:24', NULL),
(475, 2, 106, '2021-02-23 10:15:00', 1, 1, '2021-02-28 12:51:26', NULL),
(476, 1, 30, '2021-02-02 16:00:00', 1, 7, '2021-02-28 12:55:49', NULL),
(477, 1, 30, '2021-02-16 09:15:00', 1, 4, '2021-02-28 12:56:31', NULL),
(478, 1, 30, '2021-02-23 09:15:00', 1, 5, '2021-02-28 12:57:10', NULL),
(479, 1, 97, '2021-02-07 13:00:00', 1, 4, '2021-02-28 13:07:22', NULL),
(480, 1, 97, '2021-03-14 13:00:00', 1, 3, '2021-02-28 13:08:01', '2021-02-28 13:09:16'),
(481, 1, 97, '2021-02-14 13:00:00', 1, 3, '2021-02-28 13:08:49', NULL),
(482, 1, 97, '2021-02-28 13:00:00', 1, 3, '2021-02-28 13:11:33', NULL),
(483, 1, 42, '2021-02-16 16:00:00', 1, 1, '2021-02-28 13:15:26', NULL),
(484, 1, 42, '2021-02-22 16:00:00', 1, 1, '2021-02-28 13:15:51', NULL),
(485, 1, 42, '2021-02-23 16:00:00', 1, 1, '2021-02-28 13:16:08', NULL),
(486, 1, 92, '2021-02-06 12:00:00', 1, 1, '2021-02-28 13:43:26', NULL),
(487, 1, 92, '2021-02-20 12:00:00', 1, 1, '2021-02-28 13:43:47', NULL),
(488, 1, 92, '2021-02-27 12:00:00', 1, 1, '2021-02-28 13:44:24', NULL),
(489, 1, 98, '2021-02-21 13:00:00', 1, 3, '2021-02-28 13:48:03', NULL),
(490, 1, 98, '2021-02-28 13:00:00', 1, 3, '2021-02-28 13:48:18', NULL),
(491, 1, 96, '2021-02-07 13:00:00', 1, 4, '2021-02-28 17:36:51', '2021-02-28 17:37:47'),
(492, 1, 96, '2021-02-21 13:00:00', 1, 3, '2021-02-28 17:38:31', NULL),
(493, 1, 96, '2021-02-28 13:00:00', 1, 3, '2021-02-28 17:38:42', NULL),
(494, 2, 24, '2021-02-01 16:00:00', 1, 1, '2021-02-28 17:45:54', NULL),
(495, 2, 24, '2021-02-25 09:00:00', 1, 1, '2021-02-28 17:46:50', NULL),
(496, 1, 36, '2021-02-16 09:15:00', 1, 4, '2021-02-28 18:11:12', NULL),
(497, 1, 36, '2021-02-23 09:15:00', 1, 5, '2021-02-28 18:11:39', NULL),
(498, 1, 132, '2021-02-03 17:00:00', 1, 6, '2021-02-28 18:16:37', NULL),
(499, 1, 132, '2021-02-10 17:00:00', 1, 6, '2021-02-28 18:17:03', NULL),
(500, 1, 132, '2021-02-17 17:00:00', 1, 6, '2021-02-28 18:17:24', NULL),
(501, 1, 132, '2021-02-24 17:00:00', 1, 6, '2021-02-28 18:17:54', NULL),
(502, 1, 133, '2021-02-06 11:00:00', 1, 1, '2021-02-28 18:22:15', NULL),
(503, 1, 133, '2021-02-13 11:00:00', 1, 1, '2021-02-28 18:22:35', NULL),
(504, 1, 133, '2021-02-20 11:00:00', 1, 1, '2021-02-28 18:22:55', NULL),
(505, 1, 133, '2021-02-27 11:00:00', 1, 1, '2021-02-28 18:23:18', NULL),
(506, 1, 109, '2021-02-10 15:00:00', 1, 1, '2021-02-28 18:33:25', NULL),
(507, 1, 109, '2021-02-18 15:00:00', 1, 1, '2021-02-28 18:33:46', NULL),
(508, 1, 109, '2021-02-25 15:00:00', 1, 1, '2021-02-28 18:34:09', NULL),
(509, 1, 112, '2021-02-18 16:00:00', 1, 1, '2021-02-28 18:36:46', NULL),
(510, 1, 112, '2021-02-25 16:00:00', 1, 1, '2021-02-28 18:37:13', NULL),
(511, 1, 117, '2021-02-21 10:00:00', 1, 1, '2021-02-28 18:45:19', NULL),
(512, 1, 117, '2021-02-28 11:00:00', 1, 1, '2021-02-28 18:45:41', NULL),
(513, 1, 134, '2021-02-23 15:00:00', 1, 1, '2021-02-28 19:04:50', NULL),
(514, 1, 134, '2021-02-25 16:00:00', 1, 1, '2021-02-28 19:05:17', NULL),
(515, 1, 4, '2021-02-08 15:00:00', 1, 1, '2021-02-28 19:13:56', NULL),
(516, 1, 120, '2021-02-22 15:00:00', 1, 1, '2021-02-28 20:18:03', NULL),
(517, 1, 3, '2021-02-01 14:00:00', 1, 2, '2021-02-28 20:18:27', '2021-02-28 20:19:30'),
(518, 1, 3, '2021-02-08 15:00:00', 1, 5, '2021-02-28 20:18:59', NULL),
(519, 1, 3, '2021-02-22 17:00:00', 1, 5, '2021-02-28 20:20:36', NULL),
(520, 1, 7, '2021-02-17 18:00:00', 1, 5, '2021-02-28 20:28:48', NULL),
(521, 1, 7, '2021-02-21 14:00:00', 1, 3, '2021-02-28 20:29:25', NULL),
(522, 3, 113, '2021-02-04 16:00:00', 1, 1, '2021-02-28 20:32:39', NULL),
(523, 3, 113, '2021-02-18 16:00:00', 1, 1, '2021-02-28 20:33:13', NULL),
(524, 3, 113, '2021-02-23 11:15:00', 1, 1, '2021-02-28 20:34:03', NULL),
(525, 1, 67, '2021-02-24 18:00:00', 1, 4, '2021-02-28 20:36:54', NULL),
(526, 1, 90, '2021-02-20 10:00:00', 1, 1, '2021-02-28 20:39:57', NULL),
(527, 1, 90, '2021-02-27 10:00:00', 1, 1, '2021-02-28 20:40:25', NULL),
(528, 1, 64, '2021-02-17 16:00:00', 1, 1, '2021-02-28 20:41:47', NULL),
(529, 1, 64, '2021-02-24 16:00:00', 1, 1, '2021-02-28 20:42:12', NULL),
(530, 1, 41, '2021-02-16 17:00:00', 1, 5, '2021-02-28 20:44:24', NULL),
(531, 1, 41, '2021-02-24 18:00:00', 1, 5, '2021-02-28 20:44:35', NULL),
(532, 1, 94, '2021-02-17 12:00:00', 1, 3, '2021-02-28 20:53:41', NULL),
(533, 1, 94, '2021-02-28 12:00:00', 1, 2, '2021-02-28 20:54:17', NULL),
(534, 1, 100, '2021-02-17 18:00:00', 1, 5, '2021-03-01 08:52:16', NULL),
(535, 1, 100, '2021-02-24 18:00:00', 1, 5, '2021-03-01 08:53:06', NULL),
(536, 1, 100, '2021-02-28 14:00:00', 1, 4, '2021-03-01 08:53:29', NULL),
(537, 1, 84, '2021-02-18 17:00:00', 1, 1, '2021-03-01 09:18:35', NULL),
(538, 1, 84, '2021-02-25 17:00:00', 1, 1, '2021-03-01 09:19:15', NULL),
(539, 1, 68, '2021-02-17 19:00:00', 1, 2, '2021-03-01 09:38:55', NULL),
(540, 1, 68, '2021-02-21 15:00:00', 1, 1, '2021-03-01 09:44:53', NULL),
(541, 1, 68, '2021-02-28 15:00:00', 1, 1, '2021-03-01 09:45:17', NULL),
(542, 1, 65, '2021-02-17 18:00:00', 1, 5, '2021-03-01 09:51:30', NULL),
(543, 1, 65, '2021-02-24 18:00:00', 1, 5, '2021-03-01 09:51:52', NULL),
(544, 1, 5, '2021-02-22 16:00:00', 1, 1, '2021-03-01 09:53:52', NULL),
(545, 1, 136, '2021-02-17 19:00:00', 1, 2, '2021-03-01 09:55:41', NULL),
(546, 1, 136, '2021-02-24 19:00:00', 1, 2, '2021-03-01 09:56:25', NULL),
(547, 1, 63, '2021-02-17 15:00:00', 1, 1, '2021-03-01 10:03:51', NULL),
(548, 1, 63, '2021-02-24 15:00:00', 1, 1, '2021-03-01 10:04:27', NULL),
(549, 1, 40, '2021-03-16 17:00:00', 1, 5, '2021-03-01 10:12:12', NULL),
(550, 1, 40, '2021-02-23 17:00:00', 1, 5, '2021-03-01 10:12:31', NULL),
(551, 1, 47, '2021-02-02 17:00:00', 1, 5, '2021-03-01 10:14:42', NULL),
(552, 1, 47, '2021-02-23 17:00:00', 1, 5, '2021-03-01 10:14:54', NULL),
(553, 1, 39, '2021-02-23 17:00:00', 1, 4, '2021-03-01 10:16:58', NULL),
(554, 1, 37, '2021-02-16 17:00:00', 1, 4, '2021-03-01 10:18:45', NULL),
(555, 1, 37, '2021-02-23 17:00:00', 1, 4, '2021-03-01 10:18:53', NULL),
(556, 1, 105, '2021-02-16 17:00:00', 1, 5, '2021-03-01 10:20:27', NULL),
(557, 1, 105, '2021-02-21 14:00:00', 1, 3, '2021-03-01 10:21:12', NULL),
(558, 1, 105, '2021-02-28 14:00:00', 1, 4, '2021-03-01 10:21:35', NULL),
(559, 1, 93, '2021-02-21 11:00:00', 1, 2, '2021-03-01 10:36:59', NULL),
(560, 1, 93, '2021-02-28 11:00:00', 1, 2, '2021-03-01 10:37:32', NULL),
(561, 1, 93, '2021-02-28 11:00:00', 1, 2, '2021-03-01 10:37:38', '2021-03-01 10:38:15'),
(562, 1, 6, '2021-02-05 11:00:00', 1, 1, '2021-03-01 10:45:37', NULL),
(563, 1, 26, '2021-02-16 11:15:00', 1, 1, '2021-03-01 11:03:08', NULL),
(564, 1, 26, '2021-02-18 11:15:00', 1, 1, '2021-03-01 11:03:34', NULL),
(565, 1, 26, '2021-02-23 11:15:00', 1, 1, '2021-03-01 11:04:01', NULL),
(566, 1, 26, '2021-02-25 11:15:00', 1, 1, '2021-03-01 11:04:33', NULL),
(567, 1, 87, '2021-02-26 15:00:00', 1, 1, '2021-03-01 11:07:14', NULL),
(568, 1, 104, '2021-02-22 17:00:00', 1, 5, '2021-03-01 11:09:19', NULL),
(569, 1, 135, '2021-02-07 12:00:00', 1, 2, '2021-03-01 11:46:43', NULL),
(570, 1, 135, '2021-02-14 12:00:00', 1, 3, '2021-03-01 11:47:26', NULL),
(571, 1, 135, '2021-02-21 12:00:00', 1, 3, '2021-03-01 11:49:10', NULL),
(572, 1, 135, '2021-02-28 12:00:00', 1, 2, '2021-03-01 11:49:40', NULL),
(573, 1, 135, '2021-02-28 12:00:00', 1, 2, '2021-03-01 11:49:48', '2021-03-01 11:50:51'),
(574, 3, 114, '2021-02-18 17:00:00', 1, 1, '2021-03-01 12:25:40', NULL),
(575, 3, 114, '2021-02-25 17:00:00', 1, 1, '2021-03-01 12:26:13', NULL),
(576, 1, 88, '2021-03-22 19:00:00', 1, 1, '2021-03-01 12:34:03', NULL),
(577, 1, 138, '2021-02-05 13:00:00', 1, 1, '2021-03-01 15:08:56', NULL),
(578, 1, 138, '2021-02-08 17:00:00', 1, 5, '2021-03-01 15:10:07', NULL),
(579, 1, 138, '2021-02-15 17:00:00', 1, 5, '2021-03-01 15:10:31', NULL),
(580, 1, 138, '2021-02-22 17:00:00', 1, 5, '2021-03-01 15:10:54', NULL),
(581, 1, 139, '2021-02-21 11:00:00', 1, 2, '2021-03-01 15:11:44', NULL),
(582, 1, 139, '2021-02-24 19:00:00', 1, 2, '2021-03-01 15:12:19', NULL),
(583, 1, 139, '2021-02-28 11:00:00', 1, 2, '2021-03-01 15:12:42', NULL),
(584, 1, 140, '2021-02-07 14:00:00', 1, 3, '2021-03-01 15:15:03', NULL),
(585, 1, 140, '2021-02-14 14:00:00', 1, 4, '2021-03-01 15:15:43', NULL),
(586, 1, 140, '2021-02-21 12:00:00', 1, 3, '2021-03-01 15:16:48', NULL),
(587, 1, 140, '2021-02-28 14:00:00', 1, 4, '2021-03-01 15:17:26', NULL),
(588, 1, 141, '2021-02-12 16:00:00', 1, 1, '2021-03-01 15:18:22', NULL),
(589, 1, 141, '2021-02-26 16:00:00', 1, 1, '2021-03-01 15:20:14', NULL),
(590, 1, 66, '2021-02-17 18:00:00', 1, 5, '2021-03-01 15:44:17', NULL),
(591, 1, 66, '2021-02-24 18:00:00', 1, 5, '2021-03-01 15:45:42', NULL),
(592, 1, 142, '2021-02-08 19:00:00', 1, 1, '2021-03-01 15:51:10', NULL),
(593, 1, 142, '2021-02-09 19:00:00', 1, 1, '2021-03-01 15:51:41', NULL),
(594, 1, 142, '2021-02-14 11:00:00', 1, 1, '2021-03-01 15:52:12', NULL),
(595, 1, 142, '2021-02-16 19:00:00', 1, 1, '2021-03-01 15:52:45', NULL),
(596, 1, 142, '2021-02-18 19:00:00', 1, 1, '2021-03-01 15:53:05', NULL),
(597, 1, 142, '2021-02-23 19:00:00', 1, 1, '2021-03-01 15:53:42', NULL),
(598, 1, 83, '2021-02-13 12:00:00', 1, 1, '2021-03-01 16:12:51', NULL),
(599, 1, 83, '2021-02-23 15:00:00', 1, 1, '2021-03-01 16:13:16', NULL),
(600, 1, 143, '2021-02-07 10:00:00', 1, 1, '2021-03-01 16:29:51', NULL),
(601, 1, 143, '2021-02-14 10:00:00', 1, 1, '2021-03-01 16:30:19', NULL),
(602, 1, 144, '2021-02-18 18:00:00', 1, 1, '2021-03-01 16:33:26', NULL),
(603, 1, 144, '2021-02-25 18:00:00', 1, 1, '2021-03-01 16:34:14', NULL),
(604, 1, 137, '2021-02-08 17:00:00', 1, 5, '2021-03-01 16:43:46', NULL),
(605, 1, 137, '2021-02-15 17:00:00', 1, 5, '2021-03-01 16:44:12', NULL),
(606, 1, 137, '2021-02-22 17:00:00', 1, 5, '2021-03-01 16:44:50', NULL),
(607, 1, 145, '2021-02-08 14:00:00', 1, 1, '2021-03-01 16:51:28', NULL),
(608, 1, 146, '2021-02-14 12:00:00', 1, 1, '2021-03-02 15:41:03', NULL),
(609, 1, 146, '2021-02-21 14:00:00', 1, 1, '2021-03-02 15:41:34', NULL),
(610, 1, 146, '2021-02-28 14:00:00', 1, 1, '2021-03-02 15:42:04', NULL),
(611, 3, 147, '2021-02-21 13:00:00', 1, 1, '2021-03-02 15:50:11', NULL),
(612, 3, 147, '2021-02-28 13:00:00', 1, 1, '2021-03-02 15:50:37', NULL),
(613, 1, 148, '2021-02-24 19:00:00', 1, 1, '2021-03-02 15:57:59', NULL),
(614, 5, 149, '2021-02-02 10:00:00', 1, 1, '2021-03-03 16:28:20', '2021-03-03 18:53:28'),
(615, 1, 149, '2021-02-15 15:00:00', 1, 1, '2021-03-03 18:52:58', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
CREATE TABLE IF NOT EXISTS `category` (
  `CategoryID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) NOT NULL,
  PRIMARY KEY (`CategoryID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`CategoryID`, `Name`) VALUES
(1, '8-10'),
(2, '11-12'),
(3, '6-7');

-- --------------------------------------------------------

--
-- Table structure for table `course`
--

DROP TABLE IF EXISTS `course`;
CREATE TABLE IF NOT EXISTS `course` (
  `CourseID` int NOT NULL AUTO_INCREMENT,
  `CourseName` varchar(255) NOT NULL,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DeleteAt` datetime DEFAULT NULL,
  PRIMARY KEY (`CourseID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `course`
--

INSERT INTO `course` (`CourseID`, `CourseName`, `CreatedAt`, `DeleteAt`) VALUES
(1, 'Maths', '2020-12-30 20:08:36', NULL),
(2, 'Accounting', '2020-12-30 21:24:08', NULL),
(3, 'Maths Lit', '2020-12-30 21:24:08', NULL),
(4, 'IT', '2020-12-30 21:24:08', NULL),
(5, 'CAT', '2020-12-30 21:24:08', NULL),
(6, 'EMS', '2020-12-30 21:24:08', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `invoice`
--

DROP TABLE IF EXISTS `invoice`;
CREATE TABLE IF NOT EXISTS `invoice` (
  `invoiceID` int NOT NULL AUTO_INCREMENT,
  `studentID` int NOT NULL,
  `invoicedetailID` int NOT NULL,
  `GrandTotal` double NOT NULL,
  PRIMARY KEY (`invoiceID`),
  KEY `invoiceID` (`invoiceID`,`studentID`,`invoicedetailID`),
  KEY `invoicedetailID` (`invoicedetailID`),
  KEY `studentID` (`studentID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `invoicedetails`
--

DROP TABLE IF EXISTS `invoicedetails`;
CREATE TABLE IF NOT EXISTS `invoicedetails` (
  `InvoiceDetailID` int NOT NULL AUTO_INCREMENT,
  `CourseID` int NOT NULL,
  `StudentID` int NOT NULL,
  `AttendanceID` int NOT NULL,
  `DateIssued` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DeletedAt` datetime DEFAULT NULL,
  `SubTotal` double NOT NULL,
  PRIMARY KEY (`InvoiceDetailID`),
  KEY `CourseID` (`CourseID`,`StudentID`),
  KEY `AttendanceID` (`AttendanceID`),
  KEY `StudentID` (`StudentID`)
) ENGINE=InnoDB AUTO_INCREMENT=616 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `invoicedetails`
--

INSERT INTO `invoicedetails` (`InvoiceDetailID`, `CourseID`, `StudentID`, `AttendanceID`, `DateIssued`, `CreatedAt`, `DeletedAt`, `SubTotal`) VALUES
(1, 1, 2, 1, '2021-02-08 16:50:05', '2021-02-08 16:50:05', NULL, 200),
(2, 1, 3, 2, '2021-02-08 17:56:28', '2021-02-08 17:56:28', NULL, 200),
(3, 1, 4, 3, '2021-02-08 17:58:09', '2021-02-08 17:58:09', '2021-02-15 16:45:33', 0),
(4, 1, 5, 4, '2021-02-08 17:59:54', '2021-02-08 17:59:54', NULL, 230),
(5, 1, 6, 5, '2021-02-08 18:14:48', '2021-02-08 18:14:48', '2021-02-15 16:46:46', 0),
(6, 5, 1, 6, '2021-02-09 13:34:20', '2021-02-09 13:34:20', '2021-03-02 18:34:41', 0),
(7, 1, 7, 7, '2021-02-09 16:21:28', '2021-02-09 16:21:28', NULL, 230),
(8, 1, 9, 8, '2021-02-09 16:23:52', '2021-02-09 16:23:52', NULL, 120),
(9, 1, 10, 9, '2021-02-09 16:24:32', '2021-02-09 16:24:32', NULL, 150),
(10, 1, 11, 10, '2021-02-09 16:26:13', '2021-02-09 16:26:13', NULL, 120),
(11, 1, 12, 11, '2021-02-09 16:26:32', '2021-02-09 16:26:32', NULL, 120),
(12, 1, 31, 12, '2021-02-09 16:36:31', '2021-02-09 16:36:31', NULL, 120),
(13, 1, 14, 13, '2021-02-09 16:36:49', '2021-02-09 16:36:49', NULL, 120),
(14, 1, 15, 14, '2021-02-09 16:37:39', '2021-02-09 16:37:39', NULL, 120),
(15, 1, 16, 15, '2021-02-09 16:37:47', '2021-02-09 16:37:47', NULL, 120),
(16, 1, 17, 16, '2021-02-09 16:37:58', '2021-02-09 16:37:58', NULL, 120),
(17, 1, 18, 17, '2021-02-09 16:38:19', '2021-02-09 16:38:19', NULL, 120),
(18, 1, 19, 18, '2021-02-09 16:38:37', '2021-02-09 16:38:37', NULL, 120),
(19, 1, 20, 19, '2021-02-09 16:38:49', '2021-02-09 16:38:49', NULL, 120),
(20, 1, 21, 20, '2021-02-09 16:38:56', '2021-02-09 16:38:56', NULL, 120),
(21, 1, 26, 21, '2021-02-09 17:17:57', '2021-02-09 17:17:57', '2021-03-01 10:47:45', 0),
(22, 1, 27, 22, '2021-02-09 17:19:20', '2021-02-09 17:19:20', NULL, 230),
(23, 1, 22, 23, '2021-02-09 17:19:44', '2021-02-09 17:19:44', NULL, 210),
(24, 1, 29, 24, '2021-02-11 12:22:27', '2021-02-11 12:22:27', NULL, 210),
(25, 1, 42, 25, '2021-02-11 12:24:39', '2021-02-11 12:24:39', NULL, 230),
(26, 1, 53, 26, '2021-02-11 12:26:48', '2021-02-11 12:26:48', NULL, 210),
(27, 1, 54, 27, '2021-02-11 12:27:12', '2021-02-11 12:27:12', NULL, 120),
(28, 1, 55, 28, '2021-02-11 12:27:38', '2021-02-11 12:27:38', NULL, 120),
(29, 1, 56, 29, '2021-02-11 12:30:26', '2021-02-11 12:30:26', NULL, 120),
(30, 1, 57, 30, '2021-02-11 12:30:48', '2021-02-11 12:30:48', NULL, 120),
(31, 1, 58, 31, '2021-02-11 12:31:18', '2021-02-11 12:31:18', NULL, 210),
(32, 1, 45, 32, '2021-02-11 12:33:14', '2021-02-11 12:33:14', NULL, 230),
(33, 1, 62, 33, '2021-02-11 12:38:22', '2021-02-11 12:38:22', NULL, 210),
(34, 1, 6, 34, '2021-02-11 12:38:54', '2021-02-11 12:38:54', '2021-02-15 16:46:51', 0),
(35, 1, 63, 35, '2021-02-11 12:40:25', '2021-02-11 12:40:25', NULL, 230),
(36, 1, 64, 36, '2021-02-11 12:41:51', '2021-02-11 12:41:51', NULL, 230),
(37, 1, 65, 37, '2021-02-11 12:46:01', '2021-02-11 12:46:01', NULL, 170),
(38, 1, 66, 38, '2021-02-11 12:46:29', '2021-02-11 12:46:29', NULL, 170),
(39, 1, 67, 39, '2021-02-11 12:46:49', '2021-02-11 12:46:49', NULL, 170),
(40, 1, 68, 40, '2021-02-11 12:47:13', '2021-02-11 12:47:13', NULL, 230),
(41, 1, 70, 41, '2021-02-11 12:59:52', '2021-02-11 12:59:52', NULL, 120),
(42, 1, 28, 42, '2021-02-11 13:27:20', '2021-02-11 13:27:20', '2021-02-28 10:53:03', 0),
(43, 1, 67, 43, '2021-02-11 13:27:34', '2021-02-11 13:27:34', NULL, 140),
(44, 1, 32, 44, '2021-02-11 13:27:55', '2021-02-11 13:27:55', '2021-02-28 11:10:10', 0),
(45, 1, 33, 45, '2021-02-11 13:28:12', '2021-02-11 13:28:12', '2021-02-28 10:59:55', 0),
(46, 2, 34, 46, '2021-02-11 13:28:31', '2021-02-11 13:28:31', NULL, 230),
(47, 1, 36, 47, '2021-02-11 13:28:53', '2021-02-11 13:28:53', NULL, 140),
(48, 1, 13, 48, '2021-02-11 13:29:06', '2021-02-11 13:29:06', '2021-02-27 20:36:49', 0),
(49, 1, 37, 49, '2021-02-11 13:29:46', '2021-02-11 13:29:46', NULL, 140),
(50, 1, 47, 50, '2021-02-11 13:29:56', '2021-02-11 13:29:56', NULL, 140),
(51, 1, 39, 51, '2021-02-11 13:30:07', '2021-02-11 13:30:07', NULL, 140),
(52, 1, 41, 52, '2021-02-11 13:30:17', '2021-02-11 13:30:17', NULL, 140),
(53, 1, 40, 53, '2021-02-11 13:30:32', '2021-02-11 13:30:32', NULL, 140),
(54, 1, 26, 54, '2021-02-11 13:31:03', '2021-02-11 13:31:03', '2021-03-01 10:47:49', 0),
(55, 1, 31, 55, '2021-02-11 13:52:19', '2021-02-11 13:52:19', '2021-02-26 12:10:30', 0),
(56, 1, 14, 56, '2021-02-11 13:52:31', '2021-02-11 13:52:31', NULL, 120),
(57, 1, 15, 57, '2021-02-11 13:52:44', '2021-02-11 13:52:44', NULL, 120),
(58, 1, 16, 58, '2021-02-11 13:52:55', '2021-02-11 13:52:55', NULL, 120),
(59, 1, 17, 59, '2021-02-11 13:53:07', '2021-02-11 13:53:07', NULL, 120),
(60, 1, 18, 60, '2021-02-11 13:53:33', '2021-02-11 13:53:33', NULL, 120),
(61, 1, 19, 61, '2021-02-11 13:53:45', '2021-02-11 13:53:45', '2021-02-26 12:53:25', 0),
(62, 1, 20, 62, '2021-02-11 13:53:56', '2021-02-11 13:53:56', NULL, 120),
(63, 1, 21, 63, '2021-02-11 13:54:06', '2021-02-11 13:54:06', NULL, 120),
(64, 1, 50, 64, '2021-02-11 13:55:07', '2021-02-11 13:55:07', NULL, 140),
(65, 1, 20, 65, '2021-02-11 15:10:05', '2021-02-11 15:10:05', NULL, 120),
(66, 1, 43, 66, '2021-02-11 15:15:09', '2021-02-11 15:15:09', NULL, 120),
(67, 1, 46, 67, '2021-02-11 15:15:28', '2021-02-11 15:15:28', NULL, 120),
(68, 1, 48, 68, '2021-02-11 15:15:37', '2021-02-11 15:15:37', NULL, 120),
(69, 1, 49, 69, '2021-02-11 15:16:00', '2021-02-11 15:16:00', NULL, 120),
(70, 1, 52, 70, '2021-02-11 15:16:15', '2021-02-11 15:16:15', NULL, 120),
(71, 1, 71, 71, '2021-02-11 15:17:22', '2021-02-11 15:17:22', NULL, 140),
(72, 1, 72, 72, '2021-02-11 15:18:04', '2021-02-11 15:18:04', NULL, 140),
(73, 1, 35, 73, '2021-02-11 15:18:22', '2021-02-11 15:18:22', NULL, 140),
(74, 1, 51, 74, '2021-02-11 15:18:36', '2021-02-11 15:18:36', NULL, 140),
(75, 1, 38, 75, '2021-02-11 15:18:48', '2021-02-11 15:18:48', NULL, 140),
(76, 1, 69, 76, '2021-02-11 15:24:30', '2021-02-11 15:24:30', NULL, 180),
(77, 1, 73, 77, '2021-02-11 15:27:43', '2021-02-11 15:27:43', NULL, 180),
(78, 1, 74, 78, '2021-02-11 15:28:25', '2021-02-11 15:28:25', NULL, 120),
(79, 1, 75, 79, '2021-02-11 15:28:43', '2021-02-11 15:28:43', NULL, 120),
(80, 1, 76, 80, '2021-02-11 15:29:39', '2021-02-11 15:29:39', NULL, 120),
(81, 1, 77, 81, '2021-02-11 15:30:27', '2021-02-11 15:30:27', NULL, 150),
(82, 1, 78, 82, '2021-02-11 15:30:38', '2021-02-11 15:30:38', NULL, 150),
(83, 1, 79, 83, '2021-02-11 15:30:49', '2021-02-11 15:30:49', NULL, 150),
(84, 1, 80, 84, '2021-02-11 15:34:00', '2021-02-11 15:34:00', '2021-02-25 15:24:50', 0),
(85, 1, 81, 85, '2021-02-11 15:36:11', '2021-02-11 15:36:11', NULL, 180),
(86, 1, 82, 86, '2021-02-11 15:37:43', '2021-02-11 15:37:43', NULL, 210),
(87, 1, 83, 87, '2021-02-11 15:44:14', '2021-02-11 15:44:14', NULL, 230),
(88, 1, 26, 88, '2021-02-11 15:44:48', '2021-02-11 15:44:48', '2021-03-01 10:47:54', 0),
(89, 1, 22, 89, '2021-02-11 15:45:27', '2021-02-11 15:45:27', NULL, 210),
(90, 1, 44, 90, '2021-02-11 15:45:58', '2021-02-11 15:45:58', NULL, 210),
(91, 1, 42, 91, '2021-02-11 15:46:23', '2021-02-11 15:46:23', NULL, 230),
(92, 1, 84, 92, '2021-02-11 16:10:41', '2021-02-11 16:10:41', NULL, 230),
(93, 1, 85, 93, '2021-02-11 16:11:16', '2021-02-11 16:11:16', NULL, 170),
(94, 1, 86, 94, '2021-02-11 16:12:23', '2021-02-11 16:12:23', NULL, 170),
(95, 1, 33, 95, '2021-02-11 16:12:36', '2021-02-11 16:12:36', NULL, 170),
(96, 1, 87, 96, '2021-02-11 16:21:07', '2021-02-11 16:21:07', NULL, 230),
(97, 1, 88, 97, '2021-02-11 16:21:33', '2021-02-11 16:21:33', NULL, 230),
(98, 1, 90, 98, '2021-02-11 16:31:30', '2021-02-11 16:31:30', NULL, 230),
(99, 1, 89, 99, '2021-02-11 16:36:32', '2021-02-11 16:36:32', NULL, 210),
(100, 1, 93, 100, '2021-02-11 16:49:12', '2021-02-11 16:49:12', NULL, 230),
(101, 1, 94, 101, '2021-02-11 17:09:43', '2021-02-11 17:09:43', NULL, 200),
(102, 1, 95, 102, '2021-02-11 17:10:14', '2021-02-11 17:10:14', NULL, 140),
(103, 1, 96, 103, '2021-02-11 17:10:27', '2021-02-11 17:10:27', NULL, 140),
(104, 1, 97, 104, '2021-02-11 17:10:39', '2021-02-11 17:10:39', '2021-02-28 13:02:56', 0),
(105, 1, 98, 105, '2021-02-11 17:10:50', '2021-02-11 17:10:50', NULL, 140),
(106, 1, 7, 106, '2021-02-11 17:11:12', '2021-02-11 17:11:12', NULL, 170),
(107, 1, 99, 107, '2021-02-11 17:11:44', '2021-02-11 17:11:44', NULL, 170),
(108, 1, 100, 108, '2021-02-11 17:11:54', '2021-02-11 17:11:54', NULL, 170),
(109, 1, 102, 109, '2021-02-11 17:12:23', '2021-02-11 17:12:23', NULL, 150),
(110, 1, 101, 110, '2021-02-11 17:12:35', '2021-02-11 17:12:35', NULL, 150),
(111, 1, 103, 111, '2021-02-11 17:12:43', '2021-02-11 17:12:43', NULL, 150),
(112, 1, 26, 112, '2021-02-11 17:13:22', '2021-02-11 17:13:22', '2021-03-01 10:47:57', 0),
(113, 1, 27, 113, '2021-02-11 17:13:36', '2021-02-11 17:13:36', NULL, 230),
(114, 1, 29, 114, '2021-02-11 17:13:53', '2021-02-11 17:13:53', NULL, 210),
(115, 1, 28, 115, '2021-02-11 17:14:49', '2021-02-11 17:14:49', '2021-02-28 10:52:59', 0),
(116, 1, 26, 116, '2021-02-11 17:19:23', '2021-02-11 17:19:23', NULL, 230),
(117, 1, 29, 117, '2021-02-11 17:19:55', '2021-02-11 17:19:55', NULL, 210),
(118, 1, 26, 118, '2021-02-11 17:21:42', '2021-02-11 17:21:42', '2021-03-01 11:01:45', 0),
(119, 1, 26, 119, '2021-02-11 17:24:25', '2021-02-11 17:24:25', NULL, 230),
(120, 1, 26, 120, '2021-02-11 17:25:48', '2021-02-11 17:25:48', NULL, 230),
(121, 1, 27, 121, '2021-02-11 17:26:38', '2021-02-11 17:26:38', NULL, 230),
(122, 1, 4, 122, '2021-02-11 17:28:42', '2021-02-11 17:28:42', '2021-02-15 16:45:41', 0),
(123, 1, 4, 123, '2021-02-11 17:30:12', '2021-02-11 17:30:12', '2021-02-18 17:22:38', 0),
(124, 1, 5, 124, '2021-02-11 17:31:07', '2021-02-11 17:31:07', NULL, 230),
(125, 3, 3, 125, '2021-02-11 17:32:39', '2021-02-11 17:32:39', '2021-02-28 20:19:49', 0),
(126, 3, 2, 126, '2021-02-11 17:33:04', '2021-02-11 17:33:04', '2021-02-23 15:42:00', 0),
(127, 1, 104, 127, '2021-02-11 17:34:05', '2021-02-11 17:34:05', NULL, 140),
(128, 1, 7, 128, '2021-02-11 17:34:34', '2021-02-11 17:34:34', NULL, 230),
(129, 1, 53, 129, '2021-02-11 17:35:26', '2021-02-11 17:35:26', NULL, 210),
(130, 1, 11, 130, '2021-02-11 17:35:51', '2021-02-11 17:35:51', NULL, 150),
(131, 1, 10, 131, '2021-02-11 17:36:05', '2021-02-11 17:36:05', '2021-02-25 15:38:57', 0),
(132, 1, 12, 132, '2021-02-11 17:36:15', '2021-02-11 17:36:15', NULL, 150),
(133, 1, 31, 133, '2021-02-11 17:36:56', '2021-02-11 17:36:56', NULL, 120),
(134, 1, 14, 134, '2021-02-11 17:37:05', '2021-02-11 17:37:05', NULL, 120),
(135, 1, 15, 135, '2021-02-11 17:37:18', '2021-02-11 17:37:18', NULL, 120),
(136, 1, 16, 136, '2021-02-11 17:37:28', '2021-02-11 17:37:28', NULL, 120),
(137, 1, 17, 137, '2021-02-11 17:37:41', '2021-02-11 17:37:41', NULL, 120),
(138, 1, 56, 138, '2021-02-11 17:37:54', '2021-02-11 17:37:54', NULL, 120),
(139, 1, 18, 139, '2021-02-11 17:38:28', '2021-02-11 17:38:28', NULL, 120),
(140, 1, 19, 140, '2021-02-11 17:38:39', '2021-02-11 17:38:39', NULL, 120),
(141, 1, 21, 141, '2021-02-11 17:38:49', '2021-02-11 17:38:49', NULL, 120),
(142, 1, 60, 142, '2021-02-11 17:39:51', '2021-02-11 17:39:51', NULL, 230),
(143, 2, 24, 143, '2021-02-11 17:40:16', '2021-02-11 17:40:16', NULL, 230),
(144, 6, 25, 144, '2021-02-11 17:40:38', '2021-02-11 17:40:38', NULL, 210),
(145, 2, 23, 145, '2021-02-11 17:40:58', '2021-02-11 17:40:58', NULL, 230),
(146, 2, 22, 146, '2021-02-11 17:41:16', '2021-02-11 17:41:16', NULL, 210),
(147, 1, 28, 147, '2021-02-11 17:43:26', '2021-02-11 17:43:26', NULL, 140),
(148, 1, 30, 148, '2021-02-11 17:45:06', '2021-02-11 17:45:06', NULL, 140),
(149, 1, 32, 149, '2021-02-11 17:45:17', '2021-02-11 17:45:17', NULL, 140),
(150, 1, 33, 150, '2021-02-11 17:45:30', '2021-02-11 17:45:30', '2021-02-28 11:00:55', 0),
(151, 1, 13, 151, '2021-02-11 17:45:42', '2021-02-11 17:45:42', NULL, 140),
(152, 1, 34, 152, '2021-02-11 17:45:57', '2021-02-11 17:45:57', NULL, 140),
(153, 1, 36, 153, '2021-02-11 17:46:08', '2021-02-11 17:46:08', NULL, 140),
(154, 1, 39, 154, '2021-02-11 17:56:18', '2021-02-11 17:56:18', NULL, 140),
(155, 1, 37, 155, '2021-02-11 17:56:28', '2021-02-11 17:56:28', NULL, 140),
(156, 1, 105, 156, '2021-02-11 18:10:52', '2021-02-11 18:10:52', NULL, 140),
(157, 1, 41, 157, '2021-02-11 18:11:05', '2021-02-11 18:11:05', NULL, 140),
(158, 1, 47, 158, '2021-02-11 18:11:16', '2021-02-11 18:11:16', NULL, 140),
(159, 1, 40, 159, '2021-02-11 18:11:24', '2021-02-11 18:11:24', NULL, 140),
(160, 1, 42, 160, '2021-02-11 18:12:10', '2021-02-11 18:12:10', NULL, 230),
(161, 1, 106, 161, '2021-02-11 18:15:08', '2021-02-11 18:15:08', NULL, 140),
(162, 1, 59, 162, '2021-02-11 18:18:55', '2021-02-11 18:18:55', NULL, 210),
(163, 1, 60, 163, '2021-02-11 18:19:17', '2021-02-11 18:19:17', NULL, 230),
(164, 1, 23, 164, '2021-02-11 18:19:37', '2021-02-11 18:19:37', NULL, 230),
(165, 1, 61, 165, '2021-02-11 18:19:59', '2021-02-11 18:19:59', NULL, 210),
(166, 1, 9, 166, '2021-02-11 18:20:36', '2021-02-11 18:20:36', NULL, 210),
(167, 1, 43, 167, '2021-02-11 18:21:07', '2021-02-11 18:21:07', NULL, 120),
(168, 1, 48, 168, '2021-02-11 18:21:16', '2021-02-11 18:21:16', '2021-02-25 18:09:18', 0),
(169, 1, 46, 169, '2021-02-11 18:21:25', '2021-02-11 18:21:25', NULL, 120),
(170, 1, 49, 170, '2021-02-11 18:21:54', '2021-02-11 18:21:54', '2021-02-25 18:16:31', 0),
(171, 1, 52, 171, '2021-02-11 18:22:09', '2021-02-11 18:22:09', NULL, 120),
(172, 1, 107, 172, '2021-02-11 18:24:34', '2021-02-11 18:24:34', NULL, 150),
(173, 1, 108, 173, '2021-02-11 18:24:44', '2021-02-11 18:24:44', NULL, 180),
(174, 1, 55, 174, '2021-02-11 18:25:06', '2021-02-11 18:25:06', NULL, 150),
(175, 1, 54, 175, '2021-02-11 18:25:16', '2021-02-11 18:25:16', NULL, 150),
(176, 1, 57, 176, '2021-02-11 18:25:25', '2021-02-11 18:25:25', NULL, 150),
(177, 1, 58, 177, '2021-02-11 18:25:44', '2021-02-11 18:25:44', NULL, 210),
(178, 1, 103, 178, '2021-02-11 18:25:58', '2021-02-11 18:25:58', NULL, 210),
(179, 1, 109, 179, '2021-02-11 18:28:02', '2021-02-11 18:28:02', '2021-02-28 18:32:46', 0),
(180, 2, 106, 180, '2021-02-11 18:28:27', '2021-02-11 18:28:27', NULL, 230),
(181, 5, 1, 181, '2021-02-14 12:55:22', '2021-02-14 12:55:22', '2021-03-02 18:34:41', 0),
(182, 5, 1, 182, '2021-02-14 12:55:26', '2021-02-14 12:55:26', '2021-03-02 18:34:41', 0),
(183, 2, 1, 183, '2021-02-14 13:17:51', '2021-02-14 13:17:51', '2021-03-02 18:34:41', 0),
(184, 4, 1, 184, '2021-02-14 13:19:26', '2021-02-14 13:19:26', '2021-03-02 18:34:41', 0),
(185, 5, 1, 185, '2021-02-14 13:28:05', '2021-02-14 13:28:05', '2021-03-02 18:34:41', 0),
(186, 1, 6, 186, '2021-02-15 16:47:33', '2021-02-15 16:47:33', NULL, 230),
(187, 1, 25, 187, '2021-02-15 16:50:08', '2021-02-15 16:50:08', NULL, 210),
(188, 2, 95, 188, '2021-02-15 16:50:25', '2021-02-15 16:50:25', NULL, 230),
(189, 1, 53, 189, '2021-02-15 16:50:58', '2021-02-15 16:50:58', NULL, 210),
(190, 1, 69, 190, '2021-02-15 16:51:23', '2021-02-15 16:51:23', NULL, 150),
(191, 1, 111, 191, '2021-02-15 17:01:36', '2021-02-15 17:01:36', NULL, 150),
(192, 1, 73, 192, '2021-02-15 17:02:45', '2021-02-15 17:02:45', NULL, 150),
(193, 1, 74, 193, '2021-02-15 17:05:16', '2021-02-15 17:05:16', NULL, 150),
(194, 1, 70, 194, '2021-02-15 17:05:29', '2021-02-15 17:05:29', NULL, 150),
(195, 1, 76, 195, '2021-02-15 17:05:59', '2021-02-15 17:05:59', NULL, 150),
(196, 1, 77, 196, '2021-02-15 17:06:22', '2021-02-15 17:06:22', NULL, 150),
(197, 1, 11, 197, '2021-02-15 17:09:13', '2021-02-15 17:09:13', '2021-02-25 14:41:24', 0),
(198, 1, 79, 198, '2021-02-15 17:09:28', '2021-02-15 17:09:28', NULL, 150),
(199, 1, 6, 199, '2021-02-15 17:09:51', '2021-02-15 17:09:51', NULL, 230),
(200, 1, 62, 200, '2021-02-15 17:10:07', '2021-02-15 17:10:07', NULL, 210),
(201, 1, 63, 201, '2021-02-15 17:10:30', '2021-02-15 17:10:30', NULL, 230),
(202, 1, 88, 202, '2021-02-15 17:10:43', '2021-02-15 17:10:43', NULL, 230),
(203, 1, 112, 203, '2021-02-15 17:13:54', '2021-02-15 17:13:54', NULL, 230),
(204, 1, 51, 204, '2021-02-15 17:14:19', '2021-02-15 17:14:19', NULL, 140),
(205, 1, 50, 205, '2021-02-15 17:14:28', '2021-02-15 17:14:28', NULL, 140),
(206, 1, 71, 206, '2021-02-15 17:14:39', '2021-02-15 17:14:39', NULL, 140),
(207, 1, 38, 207, '2021-02-15 17:14:49', '2021-02-15 17:14:49', NULL, 140),
(208, 1, 35, 208, '2021-02-15 17:15:06', '2021-02-15 17:15:06', NULL, 140),
(209, 1, 72, 209, '2021-02-15 17:15:26', '2021-02-15 17:15:26', NULL, 140),
(210, 1, 7, 210, '2021-02-15 17:15:51', '2021-02-15 17:15:51', NULL, 140),
(211, 1, 100, 211, '2021-02-15 17:15:59', '2021-02-15 17:15:59', NULL, 140),
(212, 1, 65, 212, '2021-02-15 17:16:14', '2021-02-15 17:16:14', NULL, 140),
(213, 1, 66, 213, '2021-02-15 17:16:27', '2021-02-15 17:16:27', NULL, 140),
(214, 1, 67, 214, '2021-02-15 17:16:36', '2021-02-15 17:16:36', NULL, 140),
(215, 3, 113, 215, '2021-02-15 17:18:52', '2021-02-15 17:18:52', NULL, 230),
(216, 3, 114, 216, '2021-02-15 17:19:05', '2021-02-15 17:19:05', NULL, 150),
(217, 1, 83, 217, '2021-02-15 17:19:38', '2021-02-15 17:19:38', NULL, 230),
(218, 1, 26, 218, '2021-02-15 17:19:52', '2021-02-15 17:19:52', NULL, 230),
(219, 1, 44, 219, '2021-02-15 17:20:05', '2021-02-15 17:20:05', NULL, 210),
(220, 1, 22, 220, '2021-02-15 17:20:16', '2021-02-15 17:20:16', NULL, 210),
(221, 1, 42, 221, '2021-02-15 17:20:31', '2021-02-15 17:20:31', NULL, 230),
(222, 1, 84, 222, '2021-02-15 17:20:46', '2021-02-15 17:20:46', NULL, 230),
(223, 1, 95, 223, '2021-02-15 17:21:04', '2021-02-15 17:21:04', NULL, 140),
(224, 1, 39, 224, '2021-02-15 17:21:12', '2021-02-15 17:21:12', NULL, 140),
(225, 1, 33, 225, '2021-02-15 17:21:21', '2021-02-15 17:21:21', NULL, 140),
(226, 1, 85, 226, '2021-02-15 17:21:29', '2021-02-15 17:21:29', NULL, 140),
(227, 1, 89, 227, '2021-02-15 17:21:53', '2021-02-15 17:21:53', NULL, 210),
(228, 1, 115, 228, '2021-02-15 17:25:00', '2021-02-15 17:25:00', NULL, 210),
(229, 1, 81, 229, '2021-02-15 17:25:24', '2021-02-15 17:25:24', NULL, 150),
(230, 1, 80, 230, '2021-02-15 17:25:49', '2021-02-15 17:25:49', NULL, 150),
(231, 1, 116, 231, '2021-02-15 17:28:14', '2021-02-15 17:28:14', NULL, 150),
(232, 1, 82, 232, '2021-02-15 17:28:36', '2021-02-15 17:28:36', NULL, 210),
(233, 1, 58, 233, '2021-02-15 17:28:49', '2021-02-15 17:28:49', NULL, 210),
(234, 1, 103, 234, '2021-02-15 17:29:00', '2021-02-15 17:29:00', NULL, 210),
(235, 1, 87, 235, '2021-02-15 17:29:37', '2021-02-15 17:29:37', NULL, 230),
(236, 1, 91, 236, '2021-02-15 17:30:28', '2021-02-15 17:30:28', NULL, 230),
(237, 1, 92, 237, '2021-02-15 17:30:46', '2021-02-15 17:30:46', NULL, 230),
(238, 1, 90, 238, '2021-02-15 17:31:05', '2021-02-15 17:31:05', NULL, 230),
(239, 1, 117, 239, '2021-02-15 17:34:15', '2021-02-15 17:34:15', NULL, 230),
(240, 1, 102, 240, '2021-02-15 17:35:17', '2021-02-15 17:35:17', NULL, 120),
(241, 1, 75, 241, '2021-02-15 17:35:28', '2021-02-15 17:35:28', NULL, 120),
(242, 1, 101, 242, '2021-02-15 17:35:37', '2021-02-15 17:35:37', NULL, 120),
(243, 1, 118, 243, '2021-02-15 17:37:31', '2021-02-15 17:37:31', NULL, 120),
(244, 1, 119, 244, '2021-02-15 17:39:18', '2021-02-15 17:39:18', NULL, 210),
(245, 1, 94, 245, '2021-02-15 17:39:58', '2021-02-15 17:39:58', NULL, 170),
(246, 1, 65, 246, '2021-02-15 17:40:10', '2021-02-15 17:40:10', NULL, 140),
(247, 1, 97, 247, '2021-02-15 17:40:41', '2021-02-15 17:40:41', NULL, 170),
(248, 1, 98, 248, '2021-02-15 17:42:30', '2021-02-15 17:42:30', NULL, 170),
(249, 1, 96, 249, '2021-02-15 17:42:42', '2021-02-15 17:42:42', NULL, 170),
(250, 1, 7, 250, '2021-02-15 17:43:00', '2021-02-15 17:43:00', NULL, 140),
(251, 1, 99, 251, '2021-02-15 17:43:14', '2021-02-15 17:43:14', NULL, 140),
(252, 1, 105, 252, '2021-02-15 17:43:29', '2021-02-15 17:43:29', NULL, 140),
(253, 1, 100, 253, '2021-02-15 17:43:37', '2021-02-15 17:43:37', NULL, 140),
(254, 1, 4, 254, '2021-02-15 17:44:20', '2021-02-15 17:44:20', NULL, 200),
(255, 1, 120, 255, '2021-02-15 17:45:56', '2021-02-15 17:45:56', NULL, 200),
(256, 1, 5, 256, '2021-02-15 17:46:14', '2021-02-15 17:46:14', NULL, 230),
(257, 1, 3, 257, '2021-02-15 17:46:31', '2021-02-15 17:46:31', NULL, 140),
(258, 1, 2, 258, '2021-02-15 17:46:41', '2021-02-15 17:46:41', NULL, 140),
(259, 1, 104, 259, '2021-02-15 17:46:53', '2021-02-15 17:46:53', NULL, 140),
(260, 1, 7, 260, '2021-02-15 17:47:17', '2021-02-15 17:47:17', NULL, 230),
(261, 1, 88, 261, '2021-02-15 17:47:28', '2021-02-15 17:47:28', NULL, 230),
(262, 2, 24, 262, '2021-02-15 17:49:04', '2021-02-15 17:49:04', NULL, 230),
(263, 1, 25, 263, '2021-02-15 17:49:23', '2021-02-15 17:49:23', NULL, 210),
(264, 2, 23, 264, '2021-02-15 17:49:40', '2021-02-15 17:49:40', NULL, 230),
(265, 2, 28, 265, '2021-02-15 17:50:00', '2021-02-15 17:50:00', NULL, 230),
(266, 1, 31, 266, '2021-02-15 17:50:31', '2021-02-15 17:50:31', NULL, 120),
(267, 1, 14, 267, '2021-02-15 17:50:41', '2021-02-15 17:50:41', NULL, 120),
(268, 1, 15, 268, '2021-02-15 17:50:57', '2021-02-15 17:50:57', NULL, 120),
(269, 1, 16, 269, '2021-02-15 17:51:11', '2021-02-15 17:51:11', NULL, 120),
(270, 1, 17, 270, '2021-02-15 17:51:23', '2021-02-15 17:51:23', NULL, 120),
(271, 1, 18, 271, '2021-02-15 17:51:42', '2021-02-15 17:51:42', NULL, 120),
(272, 1, 19, 272, '2021-02-15 17:51:53', '2021-02-15 17:51:53', NULL, 120),
(273, 1, 20, 273, '2021-02-15 17:52:01', '2021-02-15 17:52:01', NULL, 120),
(274, 1, 21, 274, '2021-02-15 17:52:09', '2021-02-15 17:52:09', NULL, 120),
(275, 1, 121, 275, '2021-02-15 17:53:44', '2021-02-15 17:53:44', NULL, 120),
(276, 1, 34, 276, '2021-02-18 16:01:15', '2021-02-18 16:01:15', '2021-02-27 20:25:57', 0),
(277, 1, 6, 277, '2021-02-18 17:21:36', '2021-02-18 17:21:36', NULL, 230),
(278, 1, 4, 278, '2021-02-23 15:34:05', '2021-02-23 15:34:05', NULL, 230),
(279, 1, 2, 279, '2021-02-23 15:40:56', '2021-02-23 15:40:56', NULL, 140),
(280, 1, 2, 280, '2021-02-23 15:42:45', '2021-02-23 15:42:45', NULL, 140),
(281, 1, 7, 281, '2021-02-23 15:43:53', '2021-02-23 15:43:53', NULL, 140),
(282, 1, 11, 282, '2021-02-25 14:42:51', '2021-02-25 14:42:51', NULL, 150),
(283, 1, 11, 283, '2021-02-25 14:43:29', '2021-02-25 14:43:29', '2021-02-25 14:45:43', 0),
(284, 1, 11, 284, '2021-02-25 14:44:59', '2021-02-25 14:44:59', NULL, 150),
(285, 1, 11, 285, '2021-02-25 14:45:03', '2021-02-25 14:45:03', '2021-02-25 14:45:57', 0),
(286, 1, 80, 286, '2021-02-25 15:19:39', '2021-02-25 15:19:39', NULL, 180),
(287, 1, 80, 287, '2021-02-25 15:21:01', '2021-02-25 15:21:01', '2021-02-25 15:25:04', 0),
(288, 1, 80, 288, '2021-02-25 15:22:50', '2021-02-25 15:22:50', NULL, 150),
(289, 1, 10, 289, '2021-02-25 15:32:56', '2021-02-25 15:32:56', '2021-02-25 15:38:42', 0),
(290, 1, 10, 290, '2021-02-25 15:50:59', '2021-02-25 15:50:59', NULL, 120),
(291, 1, 10, 291, '2021-02-25 15:52:59', '2021-02-25 15:52:59', NULL, 150),
(292, 1, 10, 292, '2021-02-25 15:56:38', '2021-02-25 15:56:38', NULL, 150),
(293, 1, 12, 293, '2021-02-25 16:08:22', '2021-02-25 16:08:22', NULL, 150),
(294, 1, 12, 294, '2021-02-25 16:08:53', '2021-02-25 16:08:53', NULL, 150),
(295, 1, 9, 295, '2021-02-25 16:30:29', '2021-02-25 16:30:29', NULL, 210),
(296, 1, 12, 296, '2021-02-25 16:32:30', '2021-02-25 16:32:30', '2021-02-25 17:43:40', 0),
(297, 1, 43, 297, '2021-02-25 16:37:17', '2021-02-25 16:37:17', NULL, 120),
(298, 1, 43, 298, '2021-02-25 16:38:23', '2021-02-25 16:38:23', NULL, 120),
(299, 1, 46, 299, '2021-02-25 16:41:00', '2021-02-25 16:41:00', NULL, 120),
(300, 1, 46, 300, '2021-02-25 16:46:34', '2021-02-25 16:46:34', NULL, 120),
(301, 1, 48, 301, '2021-02-25 16:47:12', '2021-02-25 16:47:12', NULL, 120),
(302, 1, 48, 302, '2021-02-25 16:47:44', '2021-02-25 16:47:44', NULL, 120),
(303, 1, 48, 303, '2021-02-25 16:48:02', '2021-02-25 16:48:02', NULL, 120),
(304, 1, 49, 304, '2021-02-25 16:48:54', '2021-02-25 16:48:54', '2021-02-25 18:16:13', 0),
(305, 1, 49, 305, '2021-02-25 16:49:07', '2021-02-25 16:49:07', '2021-02-25 18:16:21', 0),
(306, 1, 49, 306, '2021-02-25 16:49:17', '2021-02-25 16:49:17', NULL, 120),
(307, 1, 52, 307, '2021-02-25 16:49:40', '2021-02-25 16:49:40', '2021-02-25 18:14:20', 0),
(308, 1, 52, 308, '2021-02-25 16:49:53', '2021-02-25 16:49:53', NULL, 120),
(309, 1, 52, 309, '2021-02-25 16:50:00', '2021-02-25 16:50:00', NULL, 120),
(310, 1, 52, 310, '2021-02-25 17:05:05', '2021-02-25 17:05:05', '2021-02-25 18:14:28', 0),
(311, 2, 122, 311, '2021-02-25 17:27:09', '2021-02-25 17:27:09', '2021-03-02 18:33:12', 0),
(312, 1, 49, 312, '2021-02-25 18:17:10', '2021-02-25 18:17:10', NULL, 120),
(313, 1, 49, 313, '2021-02-25 18:17:26', '2021-02-25 18:17:26', NULL, 120),
(314, 1, 123, 314, '2021-02-25 18:25:47', '2021-02-25 18:25:47', NULL, 150),
(315, 1, 123, 315, '2021-02-25 18:26:55', '2021-02-25 18:26:55', NULL, 150),
(316, 1, 58, 316, '2021-02-25 18:33:43', '2021-02-25 18:33:43', NULL, 210),
(317, 1, 58, 317, '2021-02-25 18:35:15', '2021-02-25 18:35:15', NULL, 210),
(318, 1, 58, 318, '2021-02-25 18:35:38', '2021-02-25 18:35:38', NULL, 210),
(319, 1, 58, 319, '2021-02-25 18:36:01', '2021-02-25 18:36:01', NULL, 210),
(320, 1, 31, 320, '2021-02-26 12:12:50', '2021-02-26 12:12:50', NULL, 120),
(321, 1, 115, 321, '2021-02-26 12:28:42', '2021-02-26 12:28:42', NULL, 210),
(322, 1, 115, 322, '2021-02-26 12:29:02', '2021-02-26 12:29:02', NULL, 210),
(323, 1, 61, 323, '2021-02-26 12:40:04', '2021-02-26 12:40:04', NULL, 210),
(324, 1, 61, 324, '2021-02-26 12:41:57', '2021-02-26 12:41:57', NULL, 210),
(325, 1, 61, 325, '2021-02-26 12:42:38', '2021-02-26 12:42:38', NULL, 210),
(326, 1, 19, 326, '2021-02-26 12:51:54', '2021-02-26 12:51:54', NULL, 120),
(327, 1, 56, 327, '2021-02-26 14:21:31', '2021-02-26 14:21:31', NULL, 120),
(328, 1, 56, 328, '2021-02-26 14:21:47', '2021-02-26 14:21:47', NULL, 120),
(329, 1, 107, 329, '2021-02-26 14:28:39', '2021-02-26 14:28:39', NULL, 150),
(330, 1, 107, 330, '2021-02-26 14:29:00', '2021-02-26 14:29:00', NULL, 150),
(331, 1, 124, 331, '2021-02-26 14:49:18', '2021-02-26 14:49:18', NULL, 210),
(332, 1, 57, 332, '2021-02-26 15:01:29', '2021-02-26 15:01:29', NULL, 120),
(333, 1, 57, 333, '2021-02-26 15:01:43', '2021-02-26 15:01:43', NULL, 120),
(334, 1, 54, 334, '2021-02-26 15:06:53', '2021-02-26 15:06:53', NULL, 120),
(335, 1, 54, 335, '2021-02-26 15:07:21', '2021-02-26 15:07:21', NULL, 120),
(336, 1, 55, 336, '2021-02-26 15:10:50', '2021-02-26 15:10:50', NULL, 120),
(337, 1, 55, 337, '2021-02-26 15:11:05', '2021-02-26 15:11:05', NULL, 120),
(338, 1, 69, 338, '2021-02-26 15:22:19', '2021-02-26 15:22:19', NULL, 150),
(339, 1, 69, 339, '2021-02-26 15:22:43', '2021-02-26 15:22:43', NULL, 150),
(340, 1, 121, 340, '2021-02-26 15:28:33', '2021-02-26 15:28:33', NULL, 120),
(341, 6, 25, 341, '2021-02-26 15:32:30', '2021-02-26 15:32:30', NULL, 210),
(342, 1, 25, 342, '2021-02-26 15:39:39', '2021-02-26 15:39:39', NULL, 210),
(343, 6, 25, 343, '2021-02-26 15:44:17', '2021-02-26 15:44:17', NULL, 210),
(344, 6, 25, 344, '2021-02-26 15:44:48', '2021-02-26 15:44:48', NULL, 210),
(345, 1, 25, 345, '2021-02-26 15:45:21', '2021-02-26 15:45:21', NULL, 210),
(346, 1, 73, 346, '2021-02-26 16:47:41', '2021-02-26 16:47:41', NULL, 150),
(347, 1, 73, 347, '2021-02-26 16:47:51', '2021-02-26 16:47:51', NULL, 150),
(348, 1, 53, 348, '2021-02-26 18:08:08', '2021-02-26 18:08:08', NULL, 210),
(349, 1, 53, 349, '2021-02-26 18:08:34', '2021-02-26 18:08:34', NULL, 210),
(350, 1, 82, 350, '2021-02-26 18:14:32', '2021-02-26 18:14:32', NULL, 210),
(351, 1, 82, 351, '2021-02-26 18:14:54', '2021-02-26 18:14:54', NULL, 210),
(352, 1, 111, 352, '2021-02-26 18:23:49', '2021-02-26 18:23:49', NULL, 150),
(353, 1, 111, 353, '2021-02-26 18:24:08', '2021-02-26 18:24:08', NULL, 150),
(354, 1, 125, 354, '2021-02-26 18:28:32', '2021-02-26 18:28:32', NULL, 210),
(355, 1, 125, 355, '2021-02-26 18:29:20', '2021-02-26 18:29:20', NULL, 120),
(356, 1, 77, 356, '2021-02-26 21:32:37', '2021-02-26 21:32:37', NULL, 150),
(357, 1, 77, 357, '2021-02-26 21:32:48', '2021-02-26 21:32:48', NULL, 150),
(358, 1, 44, 358, '2021-02-26 21:37:48', '2021-02-26 21:37:48', NULL, 210),
(359, 1, 44, 359, '2021-02-26 21:38:23', '2021-02-26 21:38:23', NULL, 210),
(360, 1, 29, 360, '2021-02-26 21:49:57', '2021-02-26 21:49:57', NULL, 210),
(361, 1, 62, 361, '2021-02-26 21:54:05', '2021-02-26 21:54:05', NULL, 210),
(362, 1, 62, 362, '2021-02-26 21:54:57', '2021-02-26 21:54:57', NULL, 210),
(363, 1, 70, 363, '2021-02-26 21:58:24', '2021-02-26 21:58:24', NULL, 150),
(364, 1, 70, 364, '2021-02-26 21:58:49', '2021-02-26 21:58:49', NULL, 150),
(365, 1, 74, 365, '2021-02-27 16:16:31', '2021-02-27 16:16:31', NULL, 150),
(366, 1, 74, 366, '2021-02-27 16:16:38', '2021-02-27 16:16:38', NULL, 150),
(367, 1, 79, 367, '2021-02-27 16:20:50', '2021-02-27 16:20:50', NULL, 150),
(368, 1, 79, 368, '2021-02-27 16:21:00', '2021-02-27 16:21:00', NULL, 150),
(369, 1, 81, 369, '2021-02-27 16:24:53', '2021-02-27 16:24:53', NULL, 150),
(370, 1, 81, 370, '2021-02-27 16:25:35', '2021-02-27 16:25:35', '2021-02-27 16:26:18', 0),
(371, 2, 22, 371, '2021-02-27 16:31:15', '2021-02-27 16:31:15', NULL, 210),
(372, 2, 22, 372, '2021-02-27 16:33:42', '2021-02-27 16:33:42', NULL, 210),
(373, 1, 22, 373, '2021-02-27 16:34:06', '2021-02-27 16:34:06', NULL, 210),
(374, 1, 22, 374, '2021-02-27 16:37:15', '2021-02-27 16:37:15', NULL, 210),
(375, 2, 22, 375, '2021-02-27 16:38:35', '2021-02-27 16:38:35', NULL, 210),
(376, 1, 22, 376, '2021-02-27 16:43:12', '2021-02-27 16:43:12', NULL, 210),
(377, 1, 22, 377, '2021-02-27 16:43:45', '2021-02-27 16:43:45', NULL, 210),
(378, 1, 101, 378, '2021-02-27 17:00:18', '2021-02-27 17:00:18', NULL, 150),
(379, 1, 126, 379, '2021-02-27 17:04:40', '2021-02-27 17:04:40', NULL, 210),
(380, 1, 116, 380, '2021-02-27 17:07:20', '2021-02-27 17:07:20', '2021-02-27 17:08:56', 0),
(381, 1, 116, 381, '2021-02-27 17:07:35', '2021-02-27 17:07:35', NULL, 150),
(382, 1, 127, 382, '2021-02-27 17:12:24', '2021-02-27 17:12:24', NULL, 210),
(383, 1, 128, 383, '2021-02-27 17:20:42', '2021-02-27 17:20:42', NULL, 210),
(384, 1, 103, 384, '2021-02-27 17:49:11', '2021-02-27 17:49:11', NULL, 120),
(385, 1, 102, 385, '2021-02-27 17:49:20', '2021-02-27 17:49:20', NULL, 120),
(386, 1, 75, 386, '2021-02-27 17:49:31', '2021-02-27 17:49:31', NULL, 120),
(387, 1, 101, 387, '2021-02-27 17:49:40', '2021-02-27 17:49:40', NULL, 120),
(388, 1, 102, 388, '2021-02-27 17:53:54', '2021-02-27 17:53:54', NULL, 150),
(389, 1, 59, 389, '2021-02-27 17:57:44', '2021-02-27 17:57:44', NULL, 210),
(390, 1, 59, 390, '2021-02-27 17:58:18', '2021-02-27 17:58:18', NULL, 210),
(391, 1, 59, 391, '2021-02-27 17:58:53', '2021-02-27 17:58:53', NULL, 210),
(392, 1, 75, 392, '2021-02-27 18:02:56', '2021-02-27 18:02:56', NULL, 150),
(393, 1, 76, 393, '2021-02-27 18:14:13', '2021-02-27 18:14:13', NULL, 150),
(394, 1, 76, 394, '2021-02-27 18:14:20', '2021-02-27 18:14:20', NULL, 150),
(395, 1, 78, 395, '2021-02-27 19:51:33', '2021-02-27 19:51:33', NULL, 150),
(396, 1, 78, 396, '2021-02-27 19:51:54', '2021-02-27 19:51:54', '2021-02-27 19:54:50', 0),
(397, 1, 78, 397, '2021-02-27 19:55:16', '2021-02-27 19:55:16', NULL, 150),
(398, 1, 78, 398, '2021-02-27 19:55:26', '2021-02-27 19:55:26', NULL, 150),
(399, 1, 89, 399, '2021-02-27 20:01:07', '2021-02-27 20:01:07', NULL, 210),
(400, 1, 89, 400, '2021-02-27 20:01:34', '2021-02-27 20:01:34', NULL, 210),
(401, 1, 34, 401, '2021-02-27 20:19:33', '2021-02-27 20:19:33', NULL, 140),
(402, 1, 34, 402, '2021-02-27 20:21:46', '2021-02-27 20:21:46', '2021-02-27 20:25:40', 0),
(403, 2, 34, 403, '2021-02-27 20:22:54', '2021-02-27 20:22:54', NULL, 230),
(404, 1, 34, 404, '2021-02-27 20:26:49', '2021-02-27 20:26:49', NULL, 140),
(405, 2, 34, 405, '2021-02-27 20:27:26', '2021-02-27 20:27:26', NULL, 230),
(406, 1, 34, 406, '2021-02-27 20:28:06', '2021-02-27 20:28:06', NULL, 140),
(407, 1, 13, 407, '2021-02-27 20:37:28', '2021-02-27 20:37:28', NULL, 140),
(408, 1, 13, 408, '2021-02-27 20:37:41', '2021-02-27 20:37:41', NULL, 140),
(409, 1, 13, 409, '2021-02-27 20:37:52', '2021-02-27 20:37:52', NULL, 140),
(410, 1, 71, 410, '2021-02-27 20:41:20', '2021-02-27 20:41:20', NULL, 140),
(411, 1, 71, 411, '2021-02-27 20:41:29', '2021-02-27 20:41:29', NULL, 140),
(412, 2, 95, 412, '2021-02-27 20:45:21', '2021-02-27 20:45:21', NULL, 230),
(413, 1, 95, 413, '2021-02-27 20:45:54', '2021-02-27 20:45:54', NULL, 140),
(414, 2, 95, 414, '2021-02-27 20:46:35', '2021-02-27 20:46:35', NULL, 230),
(415, 1, 95, 415, '2021-02-27 20:47:05', '2021-02-27 20:47:05', NULL, 140),
(416, 1, 129, 416, '2021-02-27 20:51:44', '2021-02-27 20:51:44', NULL, 140),
(417, 1, 129, 417, '2021-02-27 20:52:18', '2021-02-27 20:52:18', NULL, 140),
(418, 1, 129, 418, '2021-02-27 20:52:40', '2021-02-27 20:52:40', NULL, 140),
(419, 1, 129, 419, '2021-02-27 20:53:08', '2021-02-27 20:53:08', '2021-02-27 20:55:42', 0),
(420, 1, 129, 420, '2021-02-27 20:53:17', '2021-02-27 20:53:17', NULL, 140),
(421, 1, 86, 421, '2021-02-28 10:02:15', '2021-02-28 10:02:15', NULL, 140),
(422, 1, 86, 422, '2021-02-28 10:03:12', '2021-02-28 10:03:12', NULL, 140),
(423, 1, 86, 423, '2021-02-28 10:03:40', '2021-02-28 10:03:40', '2021-02-28 10:05:19', 0),
(424, 1, 86, 424, '2021-02-28 10:03:43', '2021-02-28 10:03:43', NULL, 140),
(425, 1, 27, 425, '2021-02-28 10:32:38', '2021-02-28 10:32:38', NULL, 230),
(426, 1, 51, 426, '2021-02-28 10:35:13', '2021-02-28 10:35:13', NULL, 140),
(427, 1, 51, 427, '2021-02-28 10:35:44', '2021-02-28 10:35:44', NULL, 140),
(428, 1, 35, 428, '2021-02-28 10:39:02', '2021-02-28 10:39:02', NULL, 140),
(429, 1, 35, 429, '2021-02-28 10:39:31', '2021-02-28 10:39:31', NULL, 170),
(430, 1, 50, 430, '2021-02-28 10:49:06', '2021-02-28 10:49:06', NULL, 140),
(431, 1, 50, 431, '2021-02-28 10:49:17', '2021-02-28 10:49:17', NULL, 170),
(432, 1, 28, 432, '2021-02-28 10:53:47', '2021-02-28 10:53:47', NULL, 140),
(433, 1, 28, 433, '2021-02-28 10:55:14', '2021-02-28 10:55:14', NULL, 140),
(434, 1, 33, 434, '2021-02-28 11:01:45', '2021-02-28 11:01:45', NULL, 140),
(435, 1, 33, 435, '2021-02-28 11:04:17', '2021-02-28 11:04:17', NULL, 140),
(436, 1, 32, 436, '2021-02-28 11:20:39', '2021-02-28 11:20:39', NULL, 140),
(437, 2, 32, 437, '2021-02-28 11:23:52', '2021-02-28 11:23:52', '2021-02-28 11:31:13', 0),
(438, 2, 32, 438, '2021-02-28 11:31:36', '2021-02-28 11:31:36', NULL, 230),
(439, 1, 32, 439, '2021-02-28 11:32:22', '2021-02-28 11:32:22', NULL, 140),
(440, 2, 32, 440, '2021-02-28 11:32:52', '2021-02-28 11:32:52', NULL, 230),
(441, 1, 32, 441, '2021-02-28 11:35:20', '2021-02-28 11:35:20', NULL, 170),
(442, 2, 32, 442, '2021-02-28 11:40:10', '2021-02-28 11:40:10', NULL, 230),
(443, 2, 34, 443, '2021-02-28 11:43:50', '2021-02-28 11:43:50', NULL, 230),
(444, 1, 118, 444, '2021-02-28 11:45:25', '2021-02-28 11:45:25', '2021-02-28 11:46:19', 0),
(445, 1, 118, 445, '2021-02-28 11:45:46', '2021-02-28 11:45:46', NULL, 120),
(446, 1, 130, 446, '2021-02-28 11:49:29', '2021-02-28 11:49:29', NULL, 120),
(447, 2, 23, 447, '2021-02-28 11:55:39', '2021-02-28 11:55:39', NULL, 230),
(448, 1, 23, 448, '2021-02-28 11:55:55', '2021-02-28 11:55:55', NULL, 230),
(449, 1, 23, 449, '2021-02-28 11:59:25', '2021-02-28 11:59:25', NULL, 230),
(450, 2, 23, 450, '2021-02-28 12:00:04', '2021-02-28 12:00:04', NULL, 230),
(451, 1, 23, 451, '2021-02-28 12:01:03', '2021-02-28 12:01:03', NULL, 230),
(452, 1, 85, 452, '2021-02-28 12:09:19', '2021-02-28 12:09:19', NULL, 140),
(453, 1, 85, 453, '2021-02-28 12:09:53', '2021-02-28 12:09:53', NULL, 140),
(454, 1, 60, 454, '2021-02-28 12:11:46', '2021-02-28 12:11:46', NULL, 230),
(455, 1, 60, 455, '2021-02-28 12:12:10', '2021-02-28 12:12:10', NULL, 230),
(456, 1, 60, 456, '2021-02-28 12:13:03', '2021-02-28 12:13:03', NULL, 230),
(457, 1, 60, 457, '2021-02-28 12:13:28', '2021-02-28 12:13:28', NULL, 230),
(458, 1, 60, 458, '2021-02-28 12:13:58', '2021-02-28 12:13:58', NULL, 230),
(459, 1, 60, 459, '2021-02-28 12:14:26', '2021-02-28 12:14:26', NULL, 230),
(460, 1, 131, 460, '2021-02-28 12:28:22', '2021-02-28 12:28:22', NULL, 230),
(461, 1, 131, 461, '2021-02-28 12:28:38', '2021-02-28 12:28:38', NULL, 230),
(462, 1, 131, 462, '2021-02-28 12:29:15', '2021-02-28 12:29:15', NULL, 230),
(463, 1, 131, 463, '2021-02-28 12:29:41', '2021-02-28 12:29:41', NULL, 230),
(464, 1, 91, 464, '2021-02-28 12:37:06', '2021-02-28 12:37:06', NULL, 230),
(465, 1, 91, 465, '2021-02-28 12:37:26', '2021-02-28 12:37:26', NULL, 230),
(466, 1, 91, 466, '2021-02-28 12:37:50', '2021-02-28 12:37:50', NULL, 230),
(467, 1, 91, 467, '2021-02-28 12:38:02', '2021-02-28 12:38:02', NULL, 230),
(468, 1, 45, 468, '2021-02-28 12:42:07', '2021-02-28 12:42:07', NULL, 230),
(469, 1, 45, 469, '2021-02-28 12:42:33', '2021-02-28 12:42:33', NULL, 230),
(470, 1, 106, 470, '2021-02-28 12:46:33', '2021-02-28 12:46:33', NULL, 140),
(471, 2, 106, 471, '2021-02-28 12:47:36', '2021-02-28 12:47:36', NULL, 230),
(472, 1, 106, 472, '2021-02-28 12:49:14', '2021-02-28 12:49:14', NULL, 140),
(473, 2, 106, 473, '2021-02-28 12:49:46', '2021-02-28 12:49:46', NULL, 230),
(474, 1, 106, 474, '2021-02-28 12:50:24', '2021-02-28 12:50:24', NULL, 140),
(475, 2, 106, 475, '2021-02-28 12:51:26', '2021-02-28 12:51:26', NULL, 230),
(476, 1, 30, 476, '2021-02-28 12:55:49', '2021-02-28 12:55:49', NULL, 140),
(477, 1, 30, 477, '2021-02-28 12:56:31', '2021-02-28 12:56:31', NULL, 140),
(478, 1, 30, 478, '2021-02-28 12:57:10', '2021-02-28 12:57:10', NULL, 140),
(479, 1, 97, 479, '2021-02-28 13:07:22', '2021-02-28 13:07:22', NULL, 140),
(480, 1, 97, 480, '2021-02-28 13:08:01', '2021-02-28 13:08:01', '2021-02-28 13:09:16', 0),
(481, 1, 97, 481, '2021-02-28 13:08:49', '2021-02-28 13:08:49', NULL, 170),
(482, 1, 97, 482, '2021-02-28 13:11:33', '2021-02-28 13:11:33', NULL, 170),
(483, 1, 42, 483, '2021-02-28 13:15:26', '2021-02-28 13:15:26', NULL, 230),
(484, 1, 42, 484, '2021-02-28 13:15:51', '2021-02-28 13:15:51', NULL, 230),
(485, 1, 42, 485, '2021-02-28 13:16:08', '2021-02-28 13:16:08', NULL, 230),
(486, 1, 92, 486, '2021-02-28 13:43:26', '2021-02-28 13:43:26', NULL, 230),
(487, 1, 92, 487, '2021-02-28 13:43:47', '2021-02-28 13:43:47', NULL, 230),
(488, 1, 92, 488, '2021-02-28 13:44:24', '2021-02-28 13:44:24', NULL, 230),
(489, 1, 98, 489, '2021-02-28 13:48:03', '2021-02-28 13:48:03', NULL, 170),
(490, 1, 98, 490, '2021-02-28 13:48:18', '2021-02-28 13:48:18', NULL, 170),
(491, 1, 96, 491, '2021-02-28 17:36:51', '2021-02-28 17:36:51', '2021-02-28 17:37:47', 0),
(492, 1, 96, 492, '2021-02-28 17:38:31', '2021-02-28 17:38:31', NULL, 170),
(493, 1, 96, 493, '2021-02-28 17:38:42', '2021-02-28 17:38:42', NULL, 170),
(494, 2, 24, 494, '2021-02-28 17:45:54', '2021-02-28 17:45:54', NULL, 230),
(495, 2, 24, 495, '2021-02-28 17:46:50', '2021-02-28 17:46:50', NULL, 230),
(496, 1, 36, 496, '2021-02-28 18:11:12', '2021-02-28 18:11:12', NULL, 140),
(497, 1, 36, 497, '2021-02-28 18:11:39', '2021-02-28 18:11:39', NULL, 140),
(498, 1, 132, 498, '2021-02-28 18:16:37', '2021-02-28 18:16:37', NULL, 140),
(499, 1, 132, 499, '2021-02-28 18:17:03', '2021-02-28 18:17:03', NULL, 140),
(500, 1, 132, 500, '2021-02-28 18:17:24', '2021-02-28 18:17:24', NULL, 140),
(501, 1, 132, 501, '2021-02-28 18:17:54', '2021-02-28 18:17:54', NULL, 140),
(502, 1, 133, 502, '2021-02-28 18:22:15', '2021-02-28 18:22:15', NULL, 230),
(503, 1, 133, 503, '2021-02-28 18:22:35', '2021-02-28 18:22:35', NULL, 230),
(504, 1, 133, 504, '2021-02-28 18:22:55', '2021-02-28 18:22:55', NULL, 230),
(505, 1, 133, 505, '2021-02-28 18:23:18', '2021-02-28 18:23:18', NULL, 230),
(506, 1, 109, 506, '2021-02-28 18:33:25', '2021-02-28 18:33:25', NULL, 230),
(507, 1, 109, 507, '2021-02-28 18:33:46', '2021-02-28 18:33:46', NULL, 230),
(508, 1, 109, 508, '2021-02-28 18:34:09', '2021-02-28 18:34:09', NULL, 230),
(509, 1, 112, 509, '2021-02-28 18:36:46', '2021-02-28 18:36:46', NULL, 230),
(510, 1, 112, 510, '2021-02-28 18:37:13', '2021-02-28 18:37:13', NULL, 230),
(511, 1, 117, 511, '2021-02-28 18:45:19', '2021-02-28 18:45:19', NULL, 230),
(512, 1, 117, 512, '2021-02-28 18:45:41', '2021-02-28 18:45:41', NULL, 230),
(513, 1, 134, 513, '2021-02-28 19:04:50', '2021-02-28 19:04:50', NULL, 230),
(514, 1, 134, 514, '2021-02-28 19:05:17', '2021-02-28 19:05:17', NULL, 230),
(515, 1, 4, 515, '2021-02-28 19:13:56', '2021-02-28 19:13:56', NULL, 230),
(516, 1, 120, 516, '2021-02-28 20:18:03', '2021-02-28 20:18:03', NULL, 230),
(517, 1, 3, 517, '2021-02-28 20:18:27', '2021-02-28 20:18:27', '2021-02-28 20:19:30', 0),
(518, 1, 3, 518, '2021-02-28 20:18:59', '2021-02-28 20:18:59', NULL, 140),
(519, 1, 3, 519, '2021-02-28 20:20:36', '2021-02-28 20:20:36', NULL, 140),
(520, 1, 7, 520, '2021-02-28 20:28:48', '2021-02-28 20:28:48', NULL, 140),
(521, 1, 7, 521, '2021-02-28 20:29:25', '2021-02-28 20:29:25', NULL, 170),
(522, 3, 113, 522, '2021-02-28 20:32:39', '2021-02-28 20:32:39', NULL, 230),
(523, 3, 113, 523, '2021-02-28 20:33:13', '2021-02-28 20:33:13', NULL, 230),
(524, 3, 113, 524, '2021-02-28 20:34:03', '2021-02-28 20:34:03', NULL, 230),
(525, 1, 67, 525, '2021-02-28 20:36:54', '2021-02-28 20:36:54', NULL, 140),
(526, 1, 90, 526, '2021-02-28 20:39:57', '2021-02-28 20:39:57', NULL, 230),
(527, 1, 90, 527, '2021-02-28 20:40:25', '2021-02-28 20:40:25', NULL, 230),
(528, 1, 64, 528, '2021-02-28 20:41:47', '2021-02-28 20:41:47', NULL, 230),
(529, 1, 64, 529, '2021-02-28 20:42:12', '2021-02-28 20:42:12', NULL, 230),
(530, 1, 41, 530, '2021-02-28 20:44:24', '2021-02-28 20:44:24', NULL, 140),
(531, 1, 41, 531, '2021-02-28 20:44:35', '2021-02-28 20:44:35', NULL, 140),
(532, 1, 94, 532, '2021-02-28 20:53:41', '2021-02-28 20:53:41', NULL, 170),
(533, 1, 94, 533, '2021-02-28 20:54:17', '2021-02-28 20:54:17', NULL, 200),
(534, 1, 100, 534, '2021-03-01 08:52:16', '2021-03-01 08:52:16', NULL, 140),
(535, 1, 100, 535, '2021-03-01 08:53:06', '2021-03-01 08:53:06', NULL, 140),
(536, 1, 100, 536, '2021-03-01 08:53:29', '2021-03-01 08:53:29', NULL, 140),
(537, 1, 84, 537, '2021-03-01 09:18:35', '2021-03-01 09:18:35', NULL, 230),
(538, 1, 84, 538, '2021-03-01 09:19:15', '2021-03-01 09:19:15', NULL, 230),
(539, 1, 68, 539, '2021-03-01 09:38:55', '2021-03-01 09:38:55', NULL, 200),
(540, 1, 68, 540, '2021-03-01 09:44:53', '2021-03-01 09:44:53', NULL, 230),
(541, 1, 68, 541, '2021-03-01 09:45:17', '2021-03-01 09:45:17', NULL, 230),
(542, 1, 65, 542, '2021-03-01 09:51:30', '2021-03-01 09:51:30', NULL, 140),
(543, 1, 65, 543, '2021-03-01 09:51:52', '2021-03-01 09:51:52', NULL, 140),
(544, 1, 5, 544, '2021-03-01 09:53:52', '2021-03-01 09:53:52', NULL, 230),
(545, 1, 136, 545, '2021-03-01 09:55:41', '2021-03-01 09:55:41', NULL, 200),
(546, 1, 136, 546, '2021-03-01 09:56:25', '2021-03-01 09:56:25', NULL, 200),
(547, 1, 63, 547, '2021-03-01 10:03:51', '2021-03-01 10:03:51', NULL, 230),
(548, 1, 63, 548, '2021-03-01 10:04:27', '2021-03-01 10:04:27', NULL, 230),
(549, 1, 40, 549, '2021-03-01 10:12:12', '2021-03-01 10:12:12', NULL, 140),
(550, 1, 40, 550, '2021-03-01 10:12:31', '2021-03-01 10:12:31', NULL, 140),
(551, 1, 47, 551, '2021-03-01 10:14:42', '2021-03-01 10:14:42', NULL, 140),
(552, 1, 47, 552, '2021-03-01 10:14:54', '2021-03-01 10:14:54', NULL, 140),
(553, 1, 39, 553, '2021-03-01 10:16:58', '2021-03-01 10:16:58', NULL, 140),
(554, 1, 37, 554, '2021-03-01 10:18:45', '2021-03-01 10:18:45', NULL, 140),
(555, 1, 37, 555, '2021-03-01 10:18:53', '2021-03-01 10:18:53', NULL, 140),
(556, 1, 105, 556, '2021-03-01 10:20:27', '2021-03-01 10:20:27', NULL, 140),
(557, 1, 105, 557, '2021-03-01 10:21:12', '2021-03-01 10:21:12', NULL, 170),
(558, 1, 105, 558, '2021-03-01 10:21:35', '2021-03-01 10:21:35', NULL, 140),
(559, 1, 93, 559, '2021-03-01 10:36:59', '2021-03-01 10:36:59', NULL, 200),
(560, 1, 93, 560, '2021-03-01 10:37:32', '2021-03-01 10:37:32', NULL, 200),
(561, 1, 93, 561, '2021-03-01 10:37:38', '2021-03-01 10:37:38', '2021-03-01 10:38:15', 0),
(562, 1, 6, 562, '2021-03-01 10:45:37', '2021-03-01 10:45:37', NULL, 230),
(563, 1, 26, 563, '2021-03-01 11:03:08', '2021-03-01 11:03:08', NULL, 230),
(564, 1, 26, 564, '2021-03-01 11:03:34', '2021-03-01 11:03:34', NULL, 230),
(565, 1, 26, 565, '2021-03-01 11:04:01', '2021-03-01 11:04:01', NULL, 230),
(566, 1, 26, 566, '2021-03-01 11:04:33', '2021-03-01 11:04:33', NULL, 230),
(567, 1, 87, 567, '2021-03-01 11:07:14', '2021-03-01 11:07:14', NULL, 230),
(568, 1, 104, 568, '2021-03-01 11:09:19', '2021-03-01 11:09:19', NULL, 140),
(569, 1, 135, 569, '2021-03-01 11:46:43', '2021-03-01 11:46:43', NULL, 200),
(570, 1, 135, 570, '2021-03-01 11:47:26', '2021-03-01 11:47:26', NULL, 170),
(571, 1, 135, 571, '2021-03-01 11:49:10', '2021-03-01 11:49:10', NULL, 170),
(572, 1, 135, 572, '2021-03-01 11:49:40', '2021-03-01 11:49:40', NULL, 200),
(573, 1, 135, 573, '2021-03-01 11:49:48', '2021-03-01 11:49:48', '2021-03-01 11:50:51', 0),
(574, 3, 114, 574, '2021-03-01 12:25:40', '2021-03-01 12:25:40', NULL, 150),
(575, 3, 114, 575, '2021-03-01 12:26:13', '2021-03-01 12:26:13', NULL, 150),
(576, 1, 88, 576, '2021-03-01 12:34:03', '2021-03-01 12:34:03', NULL, 230),
(577, 1, 138, 577, '2021-03-01 15:08:56', '2021-03-01 15:08:56', NULL, 230),
(578, 1, 138, 578, '2021-03-01 15:10:07', '2021-03-01 15:10:07', NULL, 140),
(579, 1, 138, 579, '2021-03-01 15:10:31', '2021-03-01 15:10:31', NULL, 140),
(580, 1, 138, 580, '2021-03-01 15:10:54', '2021-03-01 15:10:54', NULL, 140),
(581, 1, 139, 581, '2021-03-01 15:11:44', '2021-03-01 15:11:44', NULL, 200),
(582, 1, 139, 582, '2021-03-01 15:12:19', '2021-03-01 15:12:19', NULL, 200),
(583, 1, 139, 583, '2021-03-01 15:12:42', '2021-03-01 15:12:42', NULL, 200),
(584, 1, 140, 584, '2021-03-01 15:15:03', '2021-03-01 15:15:03', NULL, 170),
(585, 1, 140, 585, '2021-03-01 15:15:43', '2021-03-01 15:15:43', NULL, 140),
(586, 1, 140, 586, '2021-03-01 15:16:48', '2021-03-01 15:16:48', NULL, 170),
(587, 1, 140, 587, '2021-03-01 15:17:26', '2021-03-01 15:17:26', NULL, 140),
(588, 1, 141, 588, '2021-03-01 15:18:22', '2021-03-01 15:18:22', NULL, 230),
(589, 1, 141, 589, '2021-03-01 15:20:14', '2021-03-01 15:20:14', NULL, 230),
(590, 1, 66, 590, '2021-03-01 15:44:17', '2021-03-01 15:44:17', NULL, 140),
(591, 1, 66, 591, '2021-03-01 15:45:42', '2021-03-01 15:45:42', NULL, 140),
(592, 1, 142, 592, '2021-03-01 15:51:10', '2021-03-01 15:51:10', NULL, 230),
(593, 1, 142, 593, '2021-03-01 15:51:41', '2021-03-01 15:51:41', NULL, 230),
(594, 1, 142, 594, '2021-03-01 15:52:12', '2021-03-01 15:52:12', NULL, 230),
(595, 1, 142, 595, '2021-03-01 15:52:45', '2021-03-01 15:52:45', NULL, 230),
(596, 1, 142, 596, '2021-03-01 15:53:05', '2021-03-01 15:53:05', NULL, 230),
(597, 1, 142, 597, '2021-03-01 15:53:42', '2021-03-01 15:53:42', NULL, 230),
(598, 1, 83, 598, '2021-03-01 16:12:51', '2021-03-01 16:12:51', NULL, 230),
(599, 1, 83, 599, '2021-03-01 16:13:16', '2021-03-01 16:13:16', NULL, 230),
(600, 1, 143, 600, '2021-03-01 16:29:51', '2021-03-01 16:29:51', NULL, 230),
(601, 1, 143, 601, '2021-03-01 16:30:19', '2021-03-01 16:30:19', NULL, 230),
(602, 1, 144, 602, '2021-03-01 16:33:26', '2021-03-01 16:33:26', NULL, 230),
(603, 1, 144, 603, '2021-03-01 16:34:14', '2021-03-01 16:34:14', NULL, 230),
(604, 1, 137, 604, '2021-03-01 16:43:46', '2021-03-01 16:43:46', NULL, 140),
(605, 1, 137, 605, '2021-03-01 16:44:12', '2021-03-01 16:44:12', NULL, 140),
(606, 1, 137, 606, '2021-03-01 16:44:50', '2021-03-01 16:44:50', NULL, 140),
(607, 1, 145, 607, '2021-03-01 16:51:28', '2021-03-01 16:51:28', NULL, 230),
(608, 1, 146, 608, '2021-03-02 15:41:03', '2021-03-02 15:41:03', NULL, 210),
(609, 1, 146, 609, '2021-03-02 15:41:34', '2021-03-02 15:41:34', NULL, 210),
(610, 1, 146, 610, '2021-03-02 15:42:04', '2021-03-02 15:42:04', NULL, 210),
(611, 3, 147, 611, '2021-03-02 15:50:11', '2021-03-02 15:50:11', NULL, 210),
(612, 3, 147, 612, '2021-03-02 15:50:37', '2021-03-02 15:50:37', NULL, 210),
(613, 1, 148, 613, '2021-03-02 15:57:59', '2021-03-02 15:57:59', NULL, 230),
(614, 5, 149, 614, '2021-03-03 16:28:20', '2021-03-03 16:28:20', '2021-03-03 18:53:28', 0),
(615, 1, 149, 615, '2021-03-03 18:52:58', '2021-03-03 18:52:58', NULL, 150);

-- --------------------------------------------------------

--
-- Table structure for table `permission`
--

DROP TABLE IF EXISTS `permission`;
CREATE TABLE IF NOT EXISTS `permission` (
  `PermissionID` int NOT NULL AUTO_INCREMENT,
  `PermissionName` varchar(50) NOT NULL,
  `CreateTutor` tinyint(1) NOT NULL DEFAULT '0',
  `ModifyTutor` tinyint(1) NOT NULL DEFAULT '0',
  `RemoveTutor` tinyint(1) NOT NULL DEFAULT '0',
  `CreateStudent` tinyint(1) NOT NULL DEFAULT '0',
  `ModifyStudent` tinyint(1) NOT NULL DEFAULT '0',
  `RemoveStudent` tinyint(1) NOT NULL DEFAULT '0',
  `CreateCourse` tinyint(1) NOT NULL DEFAULT '0',
  `ModifyCourse` tinyint(1) NOT NULL DEFAULT '0',
  `RemoveCourse` tinyint(1) NOT NULL DEFAULT '0',
  `CreateInvoice` tinyint(1) NOT NULL DEFAULT '0',
  `ModifyInvoice` tinyint(1) NOT NULL DEFAULT '0',
  `RemoveInvoice` tinyint(1) NOT NULL DEFAULT '0',
  `CreateAdmin` tinyint(1) NOT NULL DEFAULT '0',
  `ModifyAdmin` tinyint(1) NOT NULL DEFAULT '0',
  `RemoveAdmin` tinyint(1) NOT NULL DEFAULT '0',
  `CreateAttendance` tinyint(1) NOT NULL DEFAULT '0',
  `ModifyAttendance` tinyint(1) NOT NULL DEFAULT '0',
  `RemoveAttendance` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`PermissionID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `permission`
--

INSERT INTO `permission` (`PermissionID`, `PermissionName`, `CreateTutor`, `ModifyTutor`, `RemoveTutor`, `CreateStudent`, `ModifyStudent`, `RemoveStudent`, `CreateCourse`, `ModifyCourse`, `RemoveCourse`, `CreateInvoice`, `ModifyInvoice`, `RemoveInvoice`, `CreateAdmin`, `ModifyAdmin`, `RemoveAdmin`, `CreateAttendance`, `ModifyAttendance`, `RemoveAttendance`) VALUES
(1, 'Administrator', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(2, 'Tutor', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `rate`
--

DROP TABLE IF EXISTS `rate`;
CREATE TABLE IF NOT EXISTS `rate` (
  `rateID` int NOT NULL AUTO_INCREMENT,
  `priceRate` double NOT NULL,
  `CategoryID` int NOT NULL,
  `GroupID` int NOT NULL,
  PRIMARY KEY (`rateID`),
  KEY `GroupGrade` (`CategoryID`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `rate`
--

INSERT INTO `rate` (`rateID`, `priceRate`, `CategoryID`, `GroupID`) VALUES
(1, 210, 1, 1),
(2, 180, 1, 2),
(3, 150, 1, 3),
(4, 120, 1, 4),
(5, 230, 2, 1),
(6, 200, 2, 2),
(7, 170, 2, 3),
(8, 140, 2, 4),
(9, 120, 1, 5),
(10, 120, 1, 6),
(11, 120, 1, 7),
(12, 120, 1, 8),
(13, 120, 1, 9),
(14, 120, 1, 10),
(15, 120, 1, 11),
(16, 120, 1, 12),
(17, 120, 1, 13),
(18, 120, 1, 14),
(19, 140, 2, 5),
(20, 140, 2, 6),
(21, 140, 2, 7),
(22, 140, 2, 8),
(23, 140, 2, 9),
(24, 140, 2, 10),
(25, 140, 2, 11),
(26, 140, 2, 12),
(27, 140, 2, 13),
(28, 140, 2, 14),
(29, 150, 3, 1),
(30, 150, 3, 2),
(31, 150, 3, 3),
(32, 150, 3, 4),
(33, 150, 3, 5),
(34, 150, 3, 6),
(35, 150, 3, 7),
(36, 150, 3, 8),
(37, 150, 3, 9),
(38, 150, 3, 10),
(39, 150, 3, 11),
(40, 150, 3, 12),
(41, 150, 3, 13),
(42, 150, 3, 14),
(43, 150, 3, 15);

-- --------------------------------------------------------

--
-- Stand-in structure for view `specialstd`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `specialstd`;
CREATE TABLE IF NOT EXISTS `specialstd` (
`InvoiceDetailID` int
,`StudentID` int
,`SubTotal` double
,`Total Hours` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `stdupdate`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `stdupdate`;
CREATE TABLE IF NOT EXISTS `stdupdate` (
`Course` varchar(255)
,`DateIssued` datetime
,`EmailAddress` varchar(255)
,`Full Name` varchar(511)
,`grade` int
,`InvoiceDetailID` int
,`priceRate` double
,`SubTotal` double
,`TimeSlot` datetime
,`Total Hours` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Table structure for table `student`
--

DROP TABLE IF EXISTS `student`;
CREATE TABLE IF NOT EXISTS `student` (
  `StudentID` int NOT NULL AUTO_INCREMENT,
  `grade` int NOT NULL,
  `CategoryID` int NOT NULL,
  `FirstName` varchar(255) NOT NULL,
  `Surname` varchar(255) NOT NULL,
  `EmailAddress` varchar(255) DEFAULT NULL,
  `Sponsor` varchar(255) DEFAULT NULL,
  `PhoneNo` varchar(15) DEFAULT NULL,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DeletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`StudentID`),
  KEY `rateII` (`CategoryID`)
) ENGINE=InnoDB AUTO_INCREMENT=151 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `student`
--

INSERT INTO `student` (`StudentID`, `grade`, `CategoryID`, `FirstName`, `Surname`, `EmailAddress`, `Sponsor`, `PhoneNo`, `CreatedAt`, `DeletedAt`) VALUES
(1, 12, 2, 'Test', 'Student', 'chelseapatterson190@gmail.com ', 'Receptionist', '0712345678', '2021-02-07 20:24:54', '2021-03-02 18:34:41'),
(2, 12, 2, 'Grant ', 'Dickson', 'claudia@woyisa.co.za', 'Claudia', NULL, '2021-02-08 16:49:14', NULL),
(3, 12, 2, 'Connor', 'Ackerman', 'angelaack@gmail.com', 'Angela', NULL, '2021-02-08 17:33:16', NULL),
(4, 12, 2, 'Jenna', 'Jonker', 'olgajonker@outlook.com', 'Olga ', NULL, '2021-02-08 17:37:47', NULL),
(5, 12, 2, 'Amy ', 'Breedske', 'admin@bspholdings.co.za', 'Claire', NULL, '2021-02-08 17:38:29', NULL),
(6, 12, 2, 'Joshua', 'Peacock', 'lindsaypeacock299@gmail.com', 'Lindsay', NULL, '2021-02-08 17:39:51', NULL),
(7, 12, 2, 'Jono', 'Mayberry', 'chelseapatterson190@gmail.com', 'Sandre', NULL, '2021-02-08 17:40:24', NULL),
(8, 8, 1, 'Luke ', 'Young', 'lukeyoung@gmail.com', 'Mary - Ann Young', NULL, '2021-02-08 17:42:07', NULL),
(9, 8, 1, 'Reece ', 'Nawdish', 'kathy@scriptwise.co.za', 'Katherine', NULL, '2021-02-08 17:42:56', NULL),
(10, 8, 1, 'Tristan', 'Edmeades', 'edmeadesmark@gmail.com', 'Siobhan', NULL, '2021-02-08 17:43:58', NULL),
(11, 8, 1, 'Adam', 'Fourie', 'tamlyn.fourie@investec.co.za', 'Tamlyn', NULL, '2021-02-08 17:44:33', NULL),
(12, 8, 1, 'Luke', 'Tait', 'stellie.tait@gmail.com', 'Estelle', NULL, '2021-02-08 17:44:54', NULL),
(13, 11, 2, 'Josh', 'Rustenburg', 'bcstp@hotmail.com', 'Jacki', NULL, '2021-02-08 17:45:26', NULL),
(14, 9, 1, 'Oliver', 'Eckley', 's.eckley@rocketmail.com', 'Shannon', NULL, '2021-02-08 17:45:51', NULL),
(15, 9, 1, 'Thomas', 'Junger', 'junger@telkomsa.net', 'Janice', NULL, '2021-02-08 17:46:24', NULL),
(16, 9, 1, 'Luke', 'Silver', 'silver@vwsa.co.za', 'Melanie', NULL, '2021-02-08 17:46:50', NULL),
(17, 9, 1, 'Jesse', 'Engelbrecht', 'lindeng40@gmail.com', 'Linda', NULL, '2021-02-08 17:47:28', NULL),
(18, 9, 1, 'Matthew', 'Peters', 'charnepeters77@gmail.com', 'Charne', NULL, '2021-02-08 17:48:09', NULL),
(19, 9, 1, 'Troy', 'Hargreaves', 'tamleehargreaves@gmail.com', 'Tammy', NULL, '2021-02-08 17:48:43', NULL),
(20, 9, 1, 'Benjamin', 'Wessels', 'jkwest777@hotmail.com', 'Josie', NULL, '2021-02-08 17:49:20', NULL),
(21, 9, 1, 'Jordan', 'Strydom', 'jackiestrydom80@gmail.com', 'Jackie', NULL, '2021-02-08 17:50:01', NULL),
(22, 10, 1, 'Sophie ', 'Bradshaw', 'karen@bdlsattorneys.co.za', 'Karen', NULL, '2021-02-08 17:50:43', NULL),
(23, 11, 2, 'Julian', 'Schmidt', 'tanya@confpartner.co.za', 'Tanya', NULL, '2021-02-08 17:51:20', NULL),
(24, 11, 2, 'Jake', 'Barnes', 'peterbarnes25@gmail.com', 'Leigh - Anne', NULL, '2021-02-08 17:53:14', NULL),
(25, 9, 1, 'Kyrah', 'Flesch', 'devinf@jgs.co.za', 'Carla', NULL, '2021-02-08 17:54:59', NULL),
(26, 12, 2, 'Charleigh', 'Kotton', 'charlieghkotton@gmail.com', 'Mother Kotton', NULL, '2021-02-09 16:10:48', NULL),
(27, 11, 2, 'Cade ', 'Hoffman', 'cheramee@volcansales.co.za', 'Cheramee', NULL, '2021-02-09 16:11:24', NULL),
(28, 11, 2, 'Noah', 'Henen', 'candicehenen@gmail.com', 'Candice', NULL, '2021-02-09 16:12:04', NULL),
(29, 10, 1, 'Matthew', 'Barber', 'candicebarber01@gmail.com', 'Candice', NULL, '2021-02-09 16:12:41', NULL),
(30, 11, 2, 'Ethan', 'Engelbrecht', 'lindeng40@gmail.com', 'Linda', NULL, '2021-02-09 16:15:19', NULL),
(31, 9, 1, 'Tristan ', 'Stevens', 'andrea.pe@justresidential.co.za', 'Andrea', NULL, '2021-02-09 16:33:38', NULL),
(32, 11, 2, 'Ryan ', 'Casali', 'tweetypac@gmail.com', 'Paula', NULL, '2021-02-09 16:39:57', NULL),
(33, 11, 2, 'Daniel', 'Du Toit', 'peanutdutoit@gmail.com', 'Claire', NULL, '2021-02-09 16:40:29', NULL),
(34, 11, 2, 'Casey ', 'Keevy', 'keevys@mweb.co.za', 'Tracy', NULL, '2021-02-09 16:41:16', NULL),
(35, 11, 2, 'Callum', 'Oosthuizen', 'eagleseye@telkomsa.net', 'Nicky', NULL, '2021-02-09 16:42:02', NULL),
(36, 11, 2, 'Mitch', 'Johnston', 'toddlersinn@isat.co.za', 'Gretchen', NULL, '2021-02-09 16:42:48', NULL),
(37, 12, 2, 'Marnus ', 'Winter', 'winter@mweb.co.za', 'Sunet', NULL, '2021-02-09 16:43:53', NULL),
(38, 11, 2, 'Nicholas', 'Page', 'nicpage@gmail.com', 'Mother Page', NULL, '2021-02-09 16:45:26', NULL),
(39, 12, 2, 'James', 'Sutton', 'laurien.sutton@gmail.com', 'Laurien', NULL, '2021-02-09 16:50:53', NULL),
(40, 12, 2, 'Travis', 'Coleman', 'claire@dynaec.co.za', 'Claire', NULL, '2021-02-09 16:51:29', NULL),
(41, 12, 2, 'Shaun', 'Ford', 'tasjaford@gmail.com', 'Natasja', NULL, '2021-02-09 16:51:59', NULL),
(42, 11, 2, 'Kent', 'Orchard', 'dave@aseco.co.za', 'Dave', NULL, '2021-02-09 16:52:36', NULL),
(43, 8, 1, 'Alexa', 'van der Merwe', 'alison197410@gmail.com', 'Alison', NULL, '2021-02-09 16:53:43', NULL),
(44, 10, 1, 'Ryan', 'Baxter', 'anke.baxter@omwealth.co.za', 'Anke', NULL, '2021-02-09 16:54:44', NULL),
(45, 11, 2, 'Byron', 'Forward', 'crazychameleon33@gmail.com', 'Helen', NULL, '2021-02-09 16:57:26', NULL),
(46, 8, 1, 'Ella', 'Muller', 'georgeamuller38@gmail.com', 'Georgea', NULL, '2021-02-09 16:57:56', NULL),
(47, 12, 2, 'Devon', 'Jansen', 'train@addskilss.co.za', 'Hilary', NULL, '2021-02-09 17:07:34', NULL),
(48, 8, 1, 'Nicole', 'Wright', 'cjnblove@gmail.com', 'Mother Wright', NULL, '2021-02-09 17:08:09', NULL),
(49, 8, 1, 'Cara - Lea', 'Janse Van Rensburg', 'pennyjvr@gmail.com', 'Penny', NULL, '2021-02-09 17:08:46', NULL),
(50, 11, 2, 'Keagan', 'Fourie', 'info@designs.co.za', 'Leandra', NULL, '2021-02-09 17:08:51', NULL),
(51, 11, 2, 'Luke ', 'Muller', 'georgeamuller38@gmail.com', 'Georgea', NULL, '2021-02-09 17:10:15', NULL),
(52, 8, 1, 'Celsey', 'Janse Van Rensburg', 'pennyjvr@gmail.com', 'Penny', NULL, '2021-02-09 17:10:18', NULL),
(53, 9, 1, 'Skye', 'Wiblin', 'jacky.matthews@ninetyone.com', 'Jacky', NULL, '2021-02-09 17:10:56', NULL),
(54, 9, 1, 'Matthew', 'Froneman', 'donfron@webmail.co.za', 'Kirsty ', NULL, '2021-02-09 17:11:30', NULL),
(55, 9, 1, 'Tim ', 'Boltman', 'boltongb@gmail.com', 'Garth', NULL, '2021-02-09 17:12:00', NULL),
(56, 9, 1, 'Ethan ', 'Connet', 'merylc@just.property', 'Meryl', NULL, '2021-02-09 17:12:27', NULL),
(57, 9, 1, 'Keagan', 'Hoyle', 'jhhoyle@axxess.co.za', 'Joanne', NULL, '2021-02-09 17:12:56', NULL),
(58, 8, 1, 'James', 'Ring', 'lyndaring@gmail.com', 'Lynda', NULL, '2021-02-09 17:13:22', NULL),
(59, 10, 1, 'Cole', 'Honey', 'traceyh21@gmail.com', 'Tracey', NULL, '2021-02-09 17:13:56', NULL),
(60, 11, 2, 'Xander', 'Van Niekerk', 'madeleine@sweepa.com', 'Madelaine', NULL, '2021-02-09 17:14:29', NULL),
(61, 9, 1, 'Isabelle ', 'Jacobs', 'zet@jila.co.za', 'Lizette', NULL, '2021-02-09 17:14:59', NULL),
(62, 10, 1, 'Josh', 'Durrheim', 'LDKM@iafrica.com', 'Lauren ', NULL, '2021-02-11 12:37:26', NULL),
(63, 12, 2, 'Simon ', 'Baxter', 'anke.baxter@omwealth.co.za', 'Candice', NULL, '2021-02-11 12:39:53', NULL),
(64, 12, 2, 'Jenna ', 'Van Greunen', 'jeannined@outlook.com', 'Jeannine', NULL, '2021-02-11 12:41:13', NULL),
(65, 12, 2, 'Luke ', 'Johnson', 'pjohnson03@lear.com', 'Tracey', NULL, '2021-02-11 12:43:33', NULL),
(66, 12, 2, 'Drake ', 'Loubser', 'geneloubser@gmail.com', 'Gene ', NULL, '2021-02-11 12:44:23', NULL),
(67, 12, 2, 'Ethan', 'Heughes', 'les.hugs100@gmail.com', 'Lesley', NULL, '2021-02-11 12:44:53', NULL),
(68, 12, 2, 'Rebecca', 'Parker', 'ceri@metalman.co.za', 'Ceri', NULL, '2021-02-11 12:45:27', NULL),
(69, 9, 1, 'Hannah ', 'Stiglingh', 'a.stiglingh@stgeorges.co.za', 'Annaline', NULL, '2021-02-11 12:48:27', NULL),
(70, 10, 1, 'Jo ', 'Jacobs', 'zet@jila.co.za', 'Mother Jacobs', NULL, '2021-02-11 12:59:12', NULL),
(71, 11, 2, 'Nicholas', 'Junger', 'junger@telkomsa.net', 'Janice', NULL, '2021-02-11 13:55:55', NULL),
(72, 11, 2, 'Josh ', 'Muller', 'joshmuller@gmail.com', 'Mother Muller', NULL, '2021-02-11 13:56:41', NULL),
(73, 9, 1, 'Erin ', 'Petersen', 'lancedpetersen@gmail.com', 'Karen', NULL, '2021-02-11 15:19:56', NULL),
(74, 10, 1, 'Githe ', 'Fourie', 'info@designs.co.za', 'Leandra', NULL, '2021-02-11 15:20:54', NULL),
(75, 10, 1, 'Kayla', 'Preston', 'greenathome24@gmail.com', 'Debbie', NULL, '2021-02-11 15:21:21', NULL),
(76, 10, 1, 'chiara', 'van Zyl', 'jvanzyl46@gmail.com', 'joy', NULL, '2021-02-11 15:22:00', NULL),
(77, 10, 1, 'Ross', 'Hughes', 'les.hugs100@gmail.com', 'Lesley', NULL, '2021-02-11 15:22:33', NULL),
(78, 10, 1, 'Adam ', 'Brown', 'micellab@gmail.com', 'Micell', NULL, '2021-02-11 15:23:01', NULL),
(79, 10, 1, 'Jaimie', 'Crompton', 'heathertomscrompton@icloud.com', 'Heather', NULL, '2021-02-11 15:23:37', NULL),
(80, 10, 1, 'Matthew ', 'Fourie', 'tamlyn.fourie@investec.co.za', 'Tamlyn', NULL, '2021-02-11 15:31:59', NULL),
(81, 10, 1, 'Eashan ', 'Govender', 'naloshini.govender@investec.co.za', 'Nalo', NULL, '2021-02-11 15:32:30', NULL),
(82, 9, 1, 'Amber', 'Robertson', 'shanejanine@vodamail.co.za', 'Janine', NULL, '2021-02-11 15:33:03', NULL),
(83, 12, 2, 'Dean', 'Venter', 'pj.venter@outlook.com', 'Lindie', NULL, '2021-02-11 15:39:04', NULL),
(84, 12, 2, 'Madison', 'Page', 'benita@pagephotography.co.za', 'Benita', NULL, '2021-02-11 15:40:40', NULL),
(85, 11, 2, 'Luke', 'Page', 'benita@pagephotography.co.za', 'Benita', NULL, '2021-02-11 15:41:31', NULL),
(86, 11, 2, 'James', 'Smith', 'mtdj@mwebbiz.co.za', 'Tanya', NULL, '2021-02-11 15:42:19', NULL),
(87, 12, 2, 'Matthew', 'Andrews', 'matnich123@gmail.com', 'Evelyn', NULL, '2021-02-11 16:20:05', NULL),
(88, 12, 2, 'Ian ', 'Olivier', 'pauliolivier12@gmail.com', 'Pauli', NULL, '2021-02-11 16:20:40', NULL),
(89, 10, 1, 'Justine', 'Brown', 'construction.sidin@gmail.com', 'Sidney Brown', NULL, '2021-02-11 16:22:06', NULL),
(90, 12, 2, 'Nasreen', 'Kolanda', 'kolandah@gmail.com', 'Mureeda', NULL, '2021-02-11 16:22:09', NULL),
(91, 11, 2, 'Sebastian ', 'Eckley', 's.eckley@rocketmail.com', 'Shannon', NULL, '2021-02-11 16:23:44', NULL),
(92, 11, 2, 'Rheece', 'Blom', 'blom470@gmail.com', 'Lizelle', NULL, '2021-02-11 16:24:20', NULL),
(93, 12, 2, 'Alex', 'King', 'meganking73@hotmail.com', 'Megan', NULL, '2021-02-11 16:39:08', NULL),
(94, 12, 2, 'Kyle', 'van Jaarsveld', 'jacquesandlindy@vodamail.co.za', 'Lynda', NULL, '2021-02-11 16:40:37', NULL),
(95, 11, 2, 'Cullum', 'Rea', 'tamryn.rea@gmail.com', 'Tamryn', NULL, '2021-02-11 16:41:30', NULL),
(96, 11, 2, 'Valentino', 'Tistelli', 'dorita.t@gmail.com', 'Dorita', NULL, '2021-02-11 16:42:02', NULL),
(97, 11, 2, 'Cameron ', 'Edworthy', 'cheryledworthy@gmail.com', 'Cheryl', NULL, '2021-02-11 16:42:36', NULL),
(98, 11, 2, 'Liyema', 'Langa', 'truneli@sars.gov.za', 'Thami', NULL, '2021-02-11 16:43:16', NULL),
(99, 12, 2, 'Jean', 'Upman', 'jeanupman@gmail.com', 'Mother Upman', NULL, '2021-02-11 16:43:57', NULL),
(100, 12, 2, 'Chris', 'Bartie', 'michellebartieb@gmail.com', 'Michelle', NULL, '2021-02-11 16:45:23', NULL),
(101, 10, 1, 'Cait', 'De Beer', 'angus.debeer@dimensiondata.com', 'Joanne', NULL, '2021-02-11 16:47:07', NULL),
(102, 10, 1, 'Jorja', 'Ioannides', 'dianneioannides@gmail.com', 'Dianne', NULL, '2021-02-11 16:48:07', NULL),
(103, 10, 1, 'Erin', 'Ring', 'lyndaring@gmail.com', 'Lynda', NULL, '2021-02-11 16:48:38', NULL),
(104, 12, 2, 'Cait', 'Gerber', 'charlie.gerber0311@gmail.com', 'Charlotte', NULL, '2021-02-11 17:33:50', NULL),
(105, 12, 2, 'Keagan ', 'Pienaar', 'reana.pienaar@gmail.com', 'Reana', NULL, '2021-02-11 18:10:11', NULL),
(106, 11, 2, 'Daniel', 'Diedericks', 'nat.hudson@mweb.co.za', 'Natalie', NULL, '2021-02-11 18:14:20', NULL),
(107, 9, 1, 'Abby', 'Cornel', 'desiree@equinoxconsulting.co.za', 'Desire', NULL, '2021-02-11 18:23:03', NULL),
(108, 9, 1, 'Noah', 'Kruger', 'noahkruger@gmail.com', 'Mother Kruger', NULL, '2021-02-11 18:23:57', NULL),
(109, 11, 2, 'Kristel ', 'Visser', 'powervision@absamail.co.za', 'Eben', NULL, '2021-02-11 18:27:23', NULL),
(110, 9, 1, 'Example', 'Cornel', 'ab@gmail.com', 'Mother Cornel', NULL, '2021-02-14 13:04:48', NULL),
(111, 9, 1, 'Mia ', 'Jonker', 'careyjonker@telkomsa.net', 'Carey', NULL, '2021-02-15 16:52:10', NULL),
(112, 11, 2, 'Kyra', 'vd Berg', 'amanda.vandenberg9@gmail.com', 'Amanda', NULL, '2021-02-15 17:12:09', NULL),
(113, 12, 2, 'Mieke', 'Gerber', 'gerberezelle@gmail.com', 'Mother Gerber', NULL, '2021-02-15 17:17:24', NULL),
(114, 12, 2, 'Kelsey', 'Froneman', 'donfron@webmail.co.za', 'Kirsty ', NULL, '2021-02-15 17:18:01', NULL),
(115, 9, 1, 'Kaylee', 'Villet', 'cherylann1539@gmail.com', 'Mother Villet', NULL, '2021-02-15 17:22:37', NULL),
(116, 10, 1, 'Michael', 'Molenaar', 'molenaarm@greyjunior.co.za', 'Maarten', NULL, '2021-02-15 17:26:36', NULL),
(117, 11, 2, 'Seth', 'Whitfield', 'janice@comprehensivewealth.co.za', 'Janice', NULL, '2021-02-15 17:33:06', NULL),
(118, 10, 1, 'Sydnee ', 'Coleman', 'claire@dynaec.co.za', 'Claire', NULL, '2021-02-15 17:36:20', NULL),
(119, 10, 1, 'Madison', 'Bright', 'madib@gmail.com', 'Mother Bright', NULL, '2021-02-15 17:38:27', NULL),
(120, 12, 2, 'Farrah', 'Mahoud', 'lmohaud@me.com', 'Maarten', NULL, '2021-02-15 17:44:55', NULL),
(121, 9, 1, 'Kai', 'Whittaker', 'timanikai@gmail.com', 'Annie', NULL, '2021-02-15 17:52:46', NULL),
(122, 8, 1, 'bob', 'test', 'vxm79376@cuoly.com', 'ghfghgf', NULL, '2021-02-25 17:26:41', '2021-03-02 18:33:12'),
(123, 8, 1, 'Andrea', 'Ambler', 'hayley.hodgson@mandela.ac.za', 'Hayley', NULL, '2021-02-25 18:23:42', NULL),
(124, 9, 1, 'Amy ', 'Coltman', 'coltmankeith@gmail.com', 'Jill', NULL, '2021-02-26 14:47:48', NULL),
(125, 9, 1, 'Ethan', 'Maguire', 'michelle.maguire@investec.co.za', 'Michelle', NULL, '2021-02-26 18:26:47', NULL),
(126, 10, 1, 'Carter', 'Mahoud', 'lmohaud@me.com', 'Liesel', NULL, '2021-02-27 17:03:39', NULL),
(127, 10, 1, 'Danyll', 'Brunette', 'therocketseed@gmail.com', 'Lisa', NULL, '2021-02-27 17:11:13', NULL),
(128, 10, 1, 'Alex', 'Harmse', 'dyanne@thrifty.co.za', 'Dyanne', NULL, '2021-02-27 17:18:59', NULL),
(129, 11, 2, 'Josh', 'Matthews', 'jacky.matthews@ninetyone.com', 'Jacky', NULL, '2021-02-27 20:50:32', NULL),
(130, 10, 1, 'Lauren ', 'Venter', 'kventer@pg.co.za', 'Karen', NULL, '2021-02-28 11:48:59', NULL),
(131, 11, 2, 'Nkanyezi ', 'Buthelezi', 'butheln1@telkom.co.za', 'Eunice', NULL, '2021-02-28 12:27:15', NULL),
(132, 11, 2, 'Nicholas ', 'Peterson', 'lancedpetersen@gmail.com', 'Karen', NULL, '2021-02-28 18:15:21', NULL),
(133, 11, 2, 'Seyeshan', 'Govender', 'yugan.govender@vwsa.co.za', 'Yugan', NULL, '2021-02-28 18:20:37', NULL),
(134, 11, 2, 'Camilla', 'Kruger', 'mgmkruger@gmail.com', 'Iva', NULL, '2021-02-28 19:03:46', NULL),
(135, 12, 2, 'Thaiyen', 'Govender', 'naloshini.govender@investec.co.za', 'Nalo', NULL, '2021-03-01 09:08:24', NULL),
(136, 12, 2, 'kendal', 'Muzzell', 'mandy@seacode.com', 'Mandy', NULL, '2021-03-01 09:47:34', NULL),
(137, 12, 2, 'Jana', 'Bothe', 'tania@smfreight.co.za', 'Tania', NULL, '2021-03-01 12:11:57', NULL),
(138, 12, 2, 'Andy', 'Mfunda', 'fpmfunda@gmail.com', 'Moya', NULL, '2021-03-01 12:22:05', NULL),
(139, 12, 2, 'bridgette', 'Nel', 'info@oxwagoncamp.co.za', 'Katrina', NULL, '2021-03-01 12:30:48', NULL),
(140, 12, 2, 'Jean ', 'Pienaar', 'carmelitapienaar@gmail.com', 'Carmelita', NULL, '2021-03-01 12:31:52', NULL),
(141, 12, 2, 'Nigel', 'Rossouw', 'moya.rossouw@gmail.com', 'Moya', NULL, '2021-03-01 12:32:57', NULL),
(142, 12, 2, 'Holly', 'Bradford', 'kimbradford1972@gmail.com', 'Kim', NULL, '2021-03-01 15:49:49', NULL),
(143, 12, 2, 'Kamva', 'Maths', 'nigel@southsure.co.za', 'Nigel', NULL, '2021-03-01 16:17:10', NULL),
(144, 12, 2, 'Calvin', 'Volschenk', 'vanessa@praiaprawns.co.za', 'Vanessa', NULL, '2021-03-01 16:31:48', NULL),
(145, 12, 2, 'Adrian ', 'de Beer', 'mirindadebeer626@gmail.com', 'Mirinda', NULL, '2021-03-01 16:40:55', NULL),
(146, 10, 1, 'Erin', 'Slater', 'glynnslater2@gmail.com', 'Glynn', NULL, '2021-03-02 15:31:37', NULL),
(147, 10, 1, 'Thevana', 'Harts', 'rdullabh@compsol.co.za', 'Hart Family', NULL, '2021-03-02 15:48:27', NULL),
(148, 11, 2, 'Done', 'van Dyk', 'danevandyk9@gmail.com', 'Dane', NULL, '2021-03-02 15:55:53', NULL),
(149, 6, 3, 'Mia', 'Deacon', 'chevonne.deacon@za.sabmiller.com', 'Chevonne', NULL, '2021-03-02 19:18:19', NULL),
(150, 11, 2, 'test', 'student', 'chelseapatterson190@gmail.com', 'Chelsea', NULL, '2021-03-03 18:24:03', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `userpermission`
--

DROP TABLE IF EXISTS `userpermission`;
CREATE TABLE IF NOT EXISTS `userpermission` (
  `UserPermissionID` int NOT NULL AUTO_INCREMENT,
  `PermissionID` int NOT NULL,
  `UserID` int NOT NULL,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DeleteAt` datetime DEFAULT NULL,
  PRIMARY KEY (`UserPermissionID`),
  KEY `FK_UserID_UserPermission_Users` (`UserID`),
  KEY `FK_PermissionID_UserPermission_Permission` (`PermissionID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `Username` varchar(255) NOT NULL,
  `Password` varchar(55) NOT NULL,
  `FirstName` varchar(255) NOT NULL,
  `Surname` varchar(255) NOT NULL,
  `Active` tinyint(1) NOT NULL,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DeletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`UserID`, `Username`, `Password`, `FirstName`, `Surname`, `Active`, `CreatedAt`, `DeletedAt`) VALUES
(10, 'admin', 'cRDtpNCeBiql5KOQsKVyrA0sAiA=', 'Test', 'Student', 1, '2020-12-23 17:27:19', NULL),
(20, 'chelseapatterson', 'iqZuv8pokDySY1Jkc0s6nuZeS+4=', 'Chelsea', 'Patterson', 1, '2021-02-08 16:46:31', NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vinvoicespecial`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `vinvoicespecial`;
CREATE TABLE IF NOT EXISTS `vinvoicespecial` (
`InvoiceDetailID` int
,`StudentID` int
,`SubTotal` double
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vinvoicewithoutspecial`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `vinvoicewithoutspecial`;
CREATE TABLE IF NOT EXISTS `vinvoicewithoutspecial` (
`InvoiceDetailID` int
,`StudentID` int
,`SubTotal` double
);

-- --------------------------------------------------------

--
-- Structure for view `specialstd`
--
DROP TABLE IF EXISTS `specialstd`;

DROP VIEW IF EXISTS `specialstd`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `specialstd`  AS  select `id`.`StudentID` AS `StudentID`,`id`.`InvoiceDetailID` AS `InvoiceDetailID`,sum(`a`.`NoOfHours`) AS `Total Hours`,(((`r`.`priceRate` - `r`.`priceRate`) + 150) * sum(`a`.`NoOfHours`)) AS `SubTotal` from (((((`student` `s` join `course` `c`) join `invoicedetails` `id`) join `attendance` `a`) join `rate` `r`) join `category` `cat`) where ((`s`.`StudentID` = `id`.`StudentID`) and (`c`.`CourseID` = `id`.`CourseID`) and (`a`.`AttendanceID` = `id`.`AttendanceID`) and (`r`.`CategoryID` = `cat`.`CategoryID`) and (`s`.`CategoryID` = `cat`.`CategoryID`) and (`r`.`GroupID` = `a`.`GroupSession`) and (`id`.`DeletedAt` is null) and (`id`.`StudentID` in (107,114,123,150))) group by `id`.`InvoiceDetailID` ;

-- --------------------------------------------------------

--
-- Structure for view `stdupdate`
--
DROP TABLE IF EXISTS `stdupdate`;

DROP VIEW IF EXISTS `stdupdate`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `stdupdate`  AS  select `id`.`DateIssued` AS `DateIssued`,`id`.`InvoiceDetailID` AS `InvoiceDetailID`,concat(`s`.`FirstName`,' ',`s`.`Surname`) AS `Full Name`,`s`.`grade` AS `grade`,`s`.`EmailAddress` AS `EmailAddress`,`c`.`CourseName` AS `Course`,`r`.`priceRate` AS `priceRate`,`a`.`TimeSlot` AS `TimeSlot`,sum(`a`.`NoOfHours`) AS `Total Hours`,(`r`.`priceRate` * sum(`a`.`NoOfHours`)) AS `SubTotal` from (((((`student` `s` join `course` `c`) join `invoicedetails` `id`) join `attendance` `a`) join `rate` `r`) join `category` `cat`) where ((`s`.`StudentID` = `id`.`StudentID`) and (`c`.`CourseID` = `id`.`CourseID`) and (`a`.`AttendanceID` = `id`.`AttendanceID`) and (`r`.`CategoryID` = `cat`.`CategoryID`) and (`s`.`CategoryID` = `cat`.`CategoryID`) and (`r`.`GroupID` = `a`.`GroupSession`) and (`id`.`DeletedAt` is null) and (`id`.`StudentID` not in (107,114,123,150))) group by `id`.`InvoiceDetailID` ;

-- --------------------------------------------------------

--
-- Structure for view `vinvoicespecial`
--
DROP TABLE IF EXISTS `vinvoicespecial`;

DROP VIEW IF EXISTS `vinvoicespecial`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vinvoicespecial`  AS  select `id`.`StudentID` AS `StudentID`,`id`.`InvoiceDetailID` AS `InvoiceDetailID`,sum(`id`.`SubTotal`) AS `SubTotal` from (`invoicedetails` `id` join `specialstd` `st`) where ((`id`.`InvoiceDetailID` = `st`.`InvoiceDetailID`) and (`id`.`StudentID` in (107,114,123,150))) group by `id`.`StudentID` ;

-- --------------------------------------------------------

--
-- Structure for view `vinvoicewithoutspecial`
--
DROP TABLE IF EXISTS `vinvoicewithoutspecial`;

DROP VIEW IF EXISTS `vinvoicewithoutspecial`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vinvoicewithoutspecial`  AS  select `id`.`StudentID` AS `StudentID`,`id`.`InvoiceDetailID` AS `InvoiceDetailID`,sum(`id`.`SubTotal`) AS `SubTotal` from (`stdupdate` `st` join `invoicedetails` `id`) where ((`id`.`InvoiceDetailID` = `st`.`InvoiceDetailID`) and (`id`.`StudentID` not in (107,114,123,150))) group by `id`.`StudentID` order by `id`.`StudentID` ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `attendance`
--
ALTER TABLE `attendance`
  ADD CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`StudentID`) REFERENCES `student` (`StudentID`),
  ADD CONSTRAINT `attendance_ibfk_2` FOREIGN KEY (`CourseID`) REFERENCES `course` (`CourseID`);

--
-- Constraints for table `invoice`
--
ALTER TABLE `invoice`
  ADD CONSTRAINT `invoice_ibfk_1` FOREIGN KEY (`invoicedetailID`) REFERENCES `invoicedetails` (`InvoiceDetailID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `invoice_ibfk_2` FOREIGN KEY (`studentID`) REFERENCES `student` (`StudentID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `invoicedetails`
--
ALTER TABLE `invoicedetails`
  ADD CONSTRAINT `invoicedetails_ibfk_1` FOREIGN KEY (`AttendanceID`) REFERENCES `attendance` (`AttendanceID`);

--
-- Constraints for table `rate`
--
ALTER TABLE `rate`
  ADD CONSTRAINT `rate_ibfk_1` FOREIGN KEY (`CategoryID`) REFERENCES `category` (`CategoryID`);

--
-- Constraints for table `student`
--
ALTER TABLE `student`
  ADD CONSTRAINT `student_ibfk_1` FOREIGN KEY (`CategoryID`) REFERENCES `category` (`CategoryID`);

--
-- Constraints for table `userpermission`
--
ALTER TABLE `userpermission`
  ADD CONSTRAINT `userpermission_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`),
  ADD CONSTRAINT `userpermission_ibfk_2` FOREIGN KEY (`PermissionID`) REFERENCES `permission` (`PermissionID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
