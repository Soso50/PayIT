using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using TypeLibrary.Interfaces;
using TypeLibrary.Models;
using TypeLibrary.ViewModels;

namespace DAL
{
    public class DBAccess : IDBAccess
    {
        static string message = null;
        public static int countI = 0;
        public static double sum = 0;
        public static double total = 0;
        #region Add Items
        public bool InsertAttendance(Attendance attendance)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
         {
              new MySqlParameter("Course_ID", attendance.CourseID),
             new MySqlParameter("Student_ID", attendance.StudentID),

                    new MySqlParameter("Time_Slot", attendance.TimeSlot),
                 new MySqlParameter("Group_Session", attendance.GroupSession),
                  new MySqlParameter("No_Of_Hours", attendance.NoOfHours)
         };
            return DBHelper.NonQuery("spInsertAttendance", CommandType.StoredProcedure, parameters);
        }

        public bool InsertCourse(Course course)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
           {
                new MySqlParameter("Course_Name", course.CourseName)
           };
            return DBHelper.NonQuery("spInsertCourse", CommandType.StoredProcedure, parameters);
        }

        public bool InsertUser(Users tutor)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
                     {
                new MySqlParameter("User_name", tutor.Username),
                new MySqlParameter("Password_Hash",HashPasswordHelper.HashPassword(tutor.Password)),
                 new MySqlParameter("First_Name", tutor.Firstname),
                  new MySqlParameter("Sur_name", tutor.Surname)
                     };
            return DBHelper.NonQuery("spInsertUser", CommandType.StoredProcedure, parameters);
        }

        public bool InsertStudent(Student student)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
           {
                new MySqlParameter("First_Name", student.FirstName),
                  new MySqlParameter("Sur_name", student.Surname),
                    new MySqlParameter("Email_Address", student.EmailAddress),
                      new MySqlParameter("Spon_sor", student.Sponsor),
                new MySqlParameter("gra_de", student.Grade),
                new MySqlParameter("catID", student.CategoryID)
           };
            return DBHelper.NonQuery("spInsertStudents", CommandType.StoredProcedure, parameters);
        }

        public async Task<bool> InsertAttendanceAsync(Attendance attendance)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
         {
              new MySqlParameter("Course_ID", attendance.CourseID),
             new MySqlParameter("Student_ID", attendance.StudentID),

                    new MySqlParameter("Time_Slot", attendance.TimeSlot),
                 new MySqlParameter("Group_Session", attendance.GroupSession),
                  new MySqlParameter("No_Of_Hours", attendance.NoOfHours)
         };
            return await DBHelper.NonQueryAsync("spInsertAttendance", CommandType.StoredProcedure, parameters);
        }

        public async Task<bool> InsertCourseAsync(Course course)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
           {
                new MySqlParameter("Course_Name", course.CourseName)
           };
            return await DBHelper.NonQueryAsync("spInsertCourse", CommandType.StoredProcedure, parameters);
        }

        public async Task<bool> InsertUserAsync(Users tutor)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
                     {
                new MySqlParameter("User_name", tutor.Username),
                new MySqlParameter("Password_Hash",HashPasswordHelper.HashPassword(tutor.Password)),
                 new MySqlParameter("First_Name", tutor.Firstname),
                  new MySqlParameter("Sur_name", tutor.Surname)
                     };
            return await DBHelper.NonQueryAsync("spInsertUser", CommandType.StoredProcedure, parameters);
        }

        public async Task<bool> InsertStudentAsync(Student student)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
           {
                new MySqlParameter("First_Name", student.FirstName),
                  new MySqlParameter("Sur_name", student.Surname),
                    new MySqlParameter("Email_Address", student.EmailAddress),
                      new MySqlParameter("Spon_sor", student.Sponsor),
                new MySqlParameter("gra_de", student.Grade),
                new MySqlParameter("catID", student.CategoryID)
           };
            return await DBHelper.NonQueryAsync("spInsertStudents", CommandType.StoredProcedure, parameters);
        }
        #endregion

        #region Edit Items
        public bool EditCourse(Course course)
        {

            MySqlParameter[] parameters = new MySqlParameter[]
           {
               new MySqlParameter("course_ID", course.CourseNo),
               new MySqlParameter("course_Name", course.CourseNo),
           };
            return DBHelper.NonQuery("spUpdateCourse", CommandType.StoredProcedure, parameters);
        }
        public bool EditStudent(Student student)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
           {
                new MySqlParameter("first_Name", student.FirstName),
                  new MySqlParameter("last_Name", student.Surname),
                    new MySqlParameter("e_mail", student.EmailAddress),
                      new MySqlParameter("spon_sor", student.Sponsor),
                           new MySqlParameter("catID", student.CategoryID),
                new MySqlParameter("gra_de", student.Grade),
                new MySqlParameter("stdID", student.StudentID)
           };
            return DBHelper.NonQuery("spUpdateStudent", CommandType.StoredProcedure, parameters);
        }

        public bool EditUser(Users users)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
          {
                new MySqlParameter("first_Name", users.Firstname),
                  new MySqlParameter("last_Name", users.Surname),
                    new MySqlParameter("User_name", users.Username),
                      new MySqlParameter("passCode",HashPasswordHelper.HashPassword(users.Password))
          };
            return DBHelper.NonQuery("spUpdateUser", CommandType.StoredProcedure, parameters);
        }

        public bool EditAttendance(Attendance attendance)
        {

            MySqlParameter[] parameters = new MySqlParameter[]
         {
             new MySqlParameter("Attendance_ID", attendance.AttendanceID),
                new MySqlParameter("Course_ID", attendance.CourseID),

                    new MySqlParameter("Time_Slot", attendance.TimeSlot),
                 new MySqlParameter("Group_Session", attendance.GroupSession),
                  new MySqlParameter("No_Of_Hours", attendance.NoOfHours)
         };
            return DBHelper.NonQuery("spUpdateAttendance", CommandType.StoredProcedure, parameters);
        }
        #endregion

        #region List Items
        public List<spAllCourses> ListAllCourses()
        {
            List<spAllCourses> list = new List<spAllCourses>();

            using (DataTable table = DBHelper.Select("spListAllCourses", CommandType.StoredProcedure))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spAllCourses listAllCourses = new spAllCourses
                        {

                            CourseNo = (int)row["courseID"],

                            Course = row["Course Name"].ToString()
                        };

                        list.Add(listAllCourses);
                    }
                }
            }
            return list;
        }
        public static int countItems = 0;
        public List<spListStudents> ListStudents()
        {
            List<spListStudents> list = new List<spListStudents>();

            using (DataTable table = DBHelper.Select("spListStudents", CommandType.StoredProcedure))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spListStudents listTotalAttendees = new spListStudents
                        {
                            StudentID = int.Parse(row["StudentID"].ToString()),
                            Fullname = row["Fullname"].ToString(),
                            EmailAddress = row["E-mail"].ToString(),
                            Grade = int.Parse(row["grade"].ToString()),
                            Sponsor = row["Sponsor"].ToString()

                        };
                        countItems++;
                        list.Add(listTotalAttendees);
                    }
                }
            }
            return list;
        }

        public ObservableCollection<spListStudents> ListStudentsPages()
        {
            ObservableCollection<spListStudents> list = new ObservableCollection<spListStudents>();

            using (DataTable table = DBHelper.Select("spListStudents", CommandType.StoredProcedure))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spListStudents listTotalAttendees = new spListStudents
                        {
                            StudentID = int.Parse(row["StudentID"].ToString()),
                            Fullname = row["Fullname"].ToString(),
                            EmailAddress = row["E-mail"].ToString(),
                            Sponsor = row["Sponsor"].ToString(),
                            Grade = int.Parse(row["grade"].ToString())

                        };

                        list.Add(listTotalAttendees);
                    }
                    countItems = table.Rows.Count;
                }
            }
            return list;
        }

        public List<spListTotalAttendees> ListTotalAttendees()
        {
            List<spListTotalAttendees> list = new List<spListTotalAttendees>();

            using (DataTable table = DBHelper.Select("spListTotalAttendees", CommandType.StoredProcedure))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spListTotalAttendees listTotalAttendees = new spListTotalAttendees
                        {
                            StudentID = Convert.ToInt32(row["StudentID"]),
                            CourseID = Convert.ToInt32(row["CourseID"]),
                            StudentName = row["Student Name"].ToString(),
                            CourseName = row["Course"].ToString(),

                        };

                        list.Add(listTotalAttendees);
                    }
                }
            }
            return list;
        }

        public List<spAllCourses> SearchCourses(string course)
        {
            throw new NotImplementedException();
        }

        public List<spListStudents> SearchStudents(string student)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
   {
               new MySqlParameter("First_Name", student),

   };
            List<spListStudents> list = new List<spListStudents>();

            using (DataTable table = DBHelper.ParamSelect("spStudentsSearch", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spListStudents listTotalAttendees = new spListStudents
                        {
                            StudentID = int.Parse(row["StudentID"].ToString()),
                            Fullname = row["Fullname"].ToString(),
                            EmailAddress = row["E-mail"].ToString(),
                            Sponsor = row["Sponsor"].ToString(),
                            Grade = int.Parse(row["grade"].ToString())

                        };

                        list.Add(listTotalAttendees);
                    }
                }
            }
            return list;
        }

        public ObservableCollection<spListStudents> SearchForStudent(string student)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
            {
               new MySqlParameter("First_Name", student),

            };
            ObservableCollection<spListStudents> list = new ObservableCollection<spListStudents>();

            using (DataTable table = DBHelper.ParamSelect("spStudentsSearch", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spListStudents listTotalAttendees = new spListStudents
                        {
                            StudentID = int.Parse(row["StudentID"].ToString()),
                            Fullname = row["Fullname"].ToString(),
                            EmailAddress = row["E-mail"].ToString(),
                            Sponsor = row["Sponsor"].ToString(),
                            Grade = int.Parse(row["grade"].ToString())

                        };

                        list.Add(listTotalAttendees);
                    }
                }
            }
            return list;
        }

        public List<spInvoiceDisplay> InvoiceDisplay()
        {

            List<spInvoiceDisplay> list = new List<spInvoiceDisplay>();

            using (DataTable table = DBHelper.Select("spInvoiceDisplay", CommandType.StoredProcedure))
            {
                if (table.Rows.Count > 0)
                {

                    foreach (DataRow row in table.Rows)
                    {
                        spInvoiceDisplay listTotalAttendees = new spInvoiceDisplay
                        {
                            DateIssued = Convert.ToDateTime(row["DateIssued"]),
                            InvoiceID = Convert.ToInt32(row["InvoiceDetailID"]),
                            Student = row["Full Name"].ToString(),
                            Grade = Convert.ToInt32(row["grade"]),
                            //PhoneNo = row["PhoneNo"].ToString(),
                            Email = row["EmailAddress"].ToString(),
                            Course = row["Course"].ToString(),
                            Rate = Convert.ToDouble(row["priceRate"]),
                            Slot = Convert.ToDateTime(row["TimeSlot"]),
                            Hours = Convert.ToInt32(row["Total Hours"]),
                            //SubTotal = Convert.ToDouble(row["SubTotal"]),

                        };

                        countI++;
                        list.Add(listTotalAttendees);
                    }
                }
            }
            return list;
        }

        public List<spInvoiceDisplay> InvoiceSearch(string firstname)
        {
            total = 0;
            MySqlParameter[] parameters = new MySqlParameter[]
       {
               new MySqlParameter("First_Name", firstname),

       };
            List<spInvoiceDisplay> list = new List<spInvoiceDisplay>();

            using (DataTable table = DBHelper.ParamSelect("spInvoiceSearch", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spInvoiceDisplay listTotalAttendees = new spInvoiceDisplay
                        {
                            DateIssued = Convert.ToDateTime(row["DateIssued"]),
                            InvoiceID = Convert.ToInt32(row["InvoiceDetailID"]),
                            Student = row["Full Name"].ToString(),
                            Grade = Convert.ToInt32(row["grade"]),
                            Email = row["EmailAddress"].ToString(),
                            Course = row["Course"].ToString(),
                            Rate = Convert.ToDouble(row["priceRate"]),
                            Slot = Convert.ToDateTime(row["TimeSlot"]),
                            Hours = Convert.ToInt32(row["Total Hours"]),

                        };
                        total = (listTotalAttendees.SubTotal + total);
                        list.Add(listTotalAttendees);
                    }
                }
                else
                {
                    message = "This cannot left empty.";
                }
            }
            return list;
        }
        public List<spInvoiceDisplay> InvoiceSearchByDate(string firstname, DateTime startDate)
        {
            total = 0;
            MySqlParameter[] parameters = new MySqlParameter[]
       {
               new MySqlParameter("First_Name", firstname),
                new MySqlParameter("Start_Date", startDate),

       };
            List<spInvoiceDisplay> list = new List<spInvoiceDisplay>();

            using (DataTable table = DBHelper.ParamSelect("spInvoiceSearchByDate", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spInvoiceDisplay listTotalAttendees = new spInvoiceDisplay
                        {
                            DateIssued = Convert.ToDateTime(row["DateIssued"]),
                            InvoiceID = Convert.ToInt32(row["InvoiceDetailID"]),
                            Student = row["Full Name"].ToString(),
                            Grade = Convert.ToInt32(row["grade"]),
                            Email = row["EmailAddress"].ToString(),
                            Course = row["Course"].ToString(),
                            Rate = Convert.ToDouble(row["priceRate"]),
                            Slot = Convert.ToDateTime(row["TimeSlot"]),
                            Hours = Convert.ToInt32(row["Total Hours"])


                        };

                        list.Add(listTotalAttendees);
                        total = (listTotalAttendees.SubTotal + total);
                    }
                }
            }
            return list;
        }
        public List<spAttendeesDisplay> AttendanceDisplay(string stdID)
        {

            MySqlParameter[] parameters = new MySqlParameter[]
            {
                new MySqlParameter("First_Name", stdID),

            };

            List<spAttendeesDisplay> list = new List<spAttendeesDisplay>();

            using (DataTable table = DBHelper.ParamSelect("spAttandanceDisplay", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spAttendeesDisplay listTotalAttendees = new spAttendeesDisplay
                        {
                            DateIssued = Convert.ToDateTime(row["DateIssued"]),
                            InvoiceID = Convert.ToInt32(row["InvoiceDetailID"]),
                            Student = row["FullName"].ToString(),
                            PhoneNo = row["PhoneNo"].ToString(),
                            Email = row["EmailAddress"].ToString(),
                            Course = row["Course"].ToString(),
                            Rate = Convert.ToDouble(row["priceRate"]),
                            Slot = Convert.ToDateTime(row["Slot"]),
                            Hours = Convert.ToInt32(row["No Of Hours"]),
                            Group = Convert.ToInt32(row["Group Session"]),

                        };

                        list.Add(listTotalAttendees);
                        sum = (listTotalAttendees.SubTotal + sum);
                    }
                }
            }
            return list;
        }

        public List<spAttendanceDisplay> AttendeesDisplay()
        {
            List<spAttendanceDisplay> list = new List<spAttendanceDisplay>();

            using (DataTable table = DBHelper.Select("spAttendeesDisplay", CommandType.StoredProcedure))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spAttendanceDisplay listTotalAttendees = new spAttendanceDisplay
                        {
                            Group = Convert.ToInt32(row["Group Session"]),
                            Slot = Convert.ToDateTime(row["Slot"]),
                            Hours = Convert.ToInt32(row["No Of Hours"]),
                            Student = row["Student Name"].ToString(),
                            Course = row["Course"].ToString(),

                        };

                        list.Add(listTotalAttendees);
                    }
                }
            }
            return list;
        }
        #endregion
        public static string HashPassword(string password)
        {
            SHA1CryptoServiceProvider sha1 = new SHA1CryptoServiceProvider();
            byte[] passwordByte = Encoding.ASCII.GetBytes(password);
            byte[] crypted = sha1.ComputeHash(passwordByte);
            return Convert.ToBase64String(crypted);
        }
        public object Login(string userName, string password)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
             {
                new MySqlParameter("user_name", userName),
                new MySqlParameter("pass_word",  HashPassword(password)),

             };

            var result = DBHelper.Scalar("spLogin", CommandType.StoredProcedure, parameters);
            return result;
        }
        public List<spEmailAddress> EmailDisplay()
        {
            List<spEmailAddress> list = new List<spEmailAddress>();

            using (DataTable table = DBHelper.Select("spEmailAddress", CommandType.StoredProcedure))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spEmailAddress listTotalAttendees = new spEmailAddress
                        {

                            EmailAddress = row["EmailAddress"].ToString(),
                            Sponsor = row["Sponsor"].ToString(),

                        };

                        list.Add(listTotalAttendees);
                    }
                }
            }
            return list;
        }
        public List<spAttendanceDisplay> AttendanceDisplay()
        {
            List<spAttendanceDisplay> list = new List<spAttendanceDisplay>();

            using (DataTable table = DBHelper.Select("spAttendeesDisplay", CommandType.StoredProcedure))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spAttendanceDisplay listTotalAttendees = new spAttendanceDisplay
                        {
                            Group = Convert.ToInt32(row["Group Session"]),
                            Slot = Convert.ToDateTime(row["Slot"]),
                            Hours = Convert.ToInt32(row["No Of Hours"]),
                            Student = row["Student Name"].ToString(),
                            Course = row["Course"].ToString(),

                        };

                        list.Add(listTotalAttendees);
                    }
                }
            }
            return list;
        }
        public object IsUserExist(string userName)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
             {
                new MySqlParameter("user_name", userName),

             };

            var result = DBHelper.Scalar("spIsUserExist", CommandType.StoredProcedure, parameters);
            return result;
        }
        public List<spListUsers> ListUsers()
        {
            List<spListUsers> list = new List<spListUsers>();

            using (DataTable table = DBHelper.Select("spListUsers", CommandType.StoredProcedure))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spListUsers listAllUsers = new spListUsers
                        {

                            Username = (string)row["Username"],

                            Fullname = row["Full Name"].ToString()
                        };

                        list.Add(listAllUsers);
                    }
                }
            }
            return list;
        }

        public List<spListUsers> SearchUsers(string firstname)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
{
               new MySqlParameter("search_Name", firstname),

};

            List<spListUsers> list = new List<spListUsers>();

            using (DataTable table = DBHelper.ParamSelect("spSearchUser", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spListUsers listAllUsers = new spListUsers
                        {

                            Username = row["Username"].ToString(),

                            Fullname = row["Full Name"].ToString()
                        };

                        list.Add(listAllUsers);
                    }
                }
            }
            return list;
        }

        public object IsAttendanceExist(DateTime timeSlot, int studentID, int noOfHours)
        {

            MySqlParameter[] parameters = new MySqlParameter[]
            {
                   new MySqlParameter("time_slot", timeSlot),
                     new MySqlParameter("std_ID", studentID),
                        new MySqlParameter("no_OfHours", noOfHours),

           };

            var result = DBHelper.Scalar("spIsAttendanceExist", CommandType.StoredProcedure, parameters);
            return result;
        }

        public object IsStudentExist(string studentName, string lastName)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
             {
                new MySqlParameter("First_Name", studentName),
                  new MySqlParameter("Sur_name", lastName),
             };

            var result = DBHelper.Scalar("spIsStudentExist", CommandType.StoredProcedure, parameters);
            return result;
        }

        public bool DeleteAttendance(Attendance attendance)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
           {
               new MySqlParameter("attID", attendance.AttendanceID),
           };
            return DBHelper.NonQuery("spDeleteAttendance", CommandType.StoredProcedure, parameters);
        }

        public bool DeleteStudent(Student student)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
          {
               new MySqlParameter("stdID", student.StudentID),
          };
            return DBHelper.NonQuery("spDeleteStudent", CommandType.StoredProcedure, parameters);
        }

        //export data ===========================================================================================================================
        public List<spExportData> ExportData(DateTime startDate, DateTime endDate, int paraName)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
          {
               new MySqlParameter("startDate", startDate),
               new MySqlParameter("endDate", endDate),
               new MySqlParameter("paraName", paraName),

          };


            List<spExportData> list = new List<spExportData>();

            using (DataTable table = DBHelper.ParamSelect("spExportData", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spExportData listTotalAttendees = new spExportData
                        {

                            FullName = row["Full Name"].ToString(),

                            Grade = Convert.ToInt32(row["Grade"]),
                            AttendedDate = Convert.ToDateTime(row["Attended Date"]),
                            AmountDue = Convert.ToDouble(row["Amount Due"]),


                        };

                        list.Add(listTotalAttendees);
                    }
                }
            }
            return list;
        }

        public List<spColeHoneyInvoice> ColeHoneyInvoiceDisplay(string firstname)
        {
            total = 0;
            MySqlParameter[] parameters = new MySqlParameter[]
           {
                   new MySqlParameter("First_Name", firstname),

           };
            List<spColeHoneyInvoice> list = new List<spColeHoneyInvoice>();

            using (DataTable table = DBHelper.ParamSelect("spColeHoneyInvoice", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spColeHoneyInvoice listTotalAttendees = new spColeHoneyInvoice
                        {
                            DateIssued = Convert.ToDateTime(row["DateIssued"]),
                            InvoiceID = Convert.ToInt32(row["InvoiceDetailID"]),
                            Student = row["Full Name"].ToString(),
                            Grade = Convert.ToInt32(row["grade"]),
                            Email = row["EmailAddress"].ToString(),
                            Course = row["Course"].ToString(),
                            Rate = Convert.ToDouble(row["priceRate"]),
                            Slot = Convert.ToDateTime(row["TimeSlot"]),
                            Hours = Convert.ToInt32(row["Total Hours"]),

                        };
                        total = (listTotalAttendees.SubTotal + total);
                        list.Add(listTotalAttendees);
                    }
                }
                else
                {
                    message = "This cannot left empty.";
                }
            }
            return list;
        }

        public List<spColeHoneyInvoice> ColeHoneyInvoiceDisplayByDate(string firstname, DateTime startDate)
        {
            total = 0;
            MySqlParameter[] parameters = new MySqlParameter[]
           {
                   new MySqlParameter("First_Name", firstname),
                   new MySqlParameter("Start_Date", startDate),

           };
            List<spColeHoneyInvoice> list = new List<spColeHoneyInvoice>();

            using (DataTable table = DBHelper.ParamSelect("spColeHoneyInvoiceSearchByDate", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spColeHoneyInvoice listTotalAttendees = new spColeHoneyInvoice
                        {
                            DateIssued = Convert.ToDateTime(row["DateIssued"]),
                            InvoiceID = Convert.ToInt32(row["InvoiceDetailID"]),
                            Student = row["Full Name"].ToString(),
                            Grade = Convert.ToInt32(row["grade"]),
                            Email = row["EmailAddress"].ToString(),
                            Course = row["Course"].ToString(),
                            Rate = Convert.ToDouble(row["priceRate"]),
                            Slot = Convert.ToDateTime(row["TimeSlot"]),
                            Hours = Convert.ToInt32(row["Total Hours"]),

                        };
                        total = (listTotalAttendees.SubTotal + total);
                        list.Add(listTotalAttendees);
                    }
                }
                else
                {
                    message = "This cannot left empty.";
                }
            }
            return list;
        }

        public List<spColeHoneyInvoice> SpecialByDate(string firstname, DateTime startDate)
        {
            total = 0;
            MySqlParameter[] parameters = new MySqlParameter[]
           {
                   new MySqlParameter("First_Name", firstname),
                   new MySqlParameter("Start_Date", startDate),

           };
            List<spColeHoneyInvoice> list = new List<spColeHoneyInvoice>();

            using (DataTable table = DBHelper.ParamSelect("spSpecialByDate", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spColeHoneyInvoice listTotalAttendees = new spColeHoneyInvoice
                        {
                            DateIssued = Convert.ToDateTime(row["DateIssued"]),
                            InvoiceID = Convert.ToInt32(row["InvoiceDetailID"]),
                            Student = row["Full Name"].ToString(),
                            Grade = Convert.ToInt32(row["grade"]),
                            Email = row["EmailAddress"].ToString(),
                            Course = row["Course"].ToString(),
                            Rate = Convert.ToDouble(row["priceRate"]),
                            Slot = Convert.ToDateTime(row["TimeSlot"]),
                            Hours = Convert.ToInt32(row["Total Hours"]),
                        };
                        total = (listTotalAttendees.SubTotal + total);
                        list.Add(listTotalAttendees);
                    }
                }
                else
                {
                    message = "This cannot left empty.";
                }
            }
            return list;
        }

        public List<spColeHoneyInvoice> SpecialInvoice(string firstname)
        {
            total = 0;
            MySqlParameter[] parameters = new MySqlParameter[]
           {
                   new MySqlParameter("First_Name", firstname),

           };
            List<spColeHoneyInvoice> list = new List<spColeHoneyInvoice>();

            using (DataTable table = DBHelper.ParamSelect("spSpecialInvoice", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spColeHoneyInvoice listTotalAttendees = new spColeHoneyInvoice
                        {
                            DateIssued = Convert.ToDateTime(row["DateIssued"]),
                            InvoiceID = Convert.ToInt32(row["InvoiceDetailID"]),
                            Student = row["Full Name"].ToString(),
                            Grade = Convert.ToInt32(row["grade"]),
                            Email = row["EmailAddress"].ToString(),
                            Course = row["Course"].ToString(),
                            Rate = Convert.ToDouble(row["priceRate"]),
                            Slot = Convert.ToDateTime(row["TimeSlot"]),
                            Hours = Convert.ToInt32(row["Total Hours"]),

                        };
                        total = (listTotalAttendees.SubTotal + total);
                        list.Add(listTotalAttendees);
                    }
                }
                else
                {
                    message = "This cannot left empty.";
                }
            }
            return list;
        }
        public List<spExportData> ExportData()
        {



            List<spExportData> list = new List<spExportData>();

            using (DataTable table = DBHelper.Select("spExportDataAll", CommandType.StoredProcedure))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spExportData listTotalAttendees = new spExportData
                        {

                            FullName = row["Full Name"].ToString(),

                            Grade = Convert.ToInt32(row["Grade"]),
                            AttendedDate = Convert.ToDateTime(row["Attended Date"]),
                            AmountDue = Convert.ToDouble(row["Amount Due"]),


                        };

                        list.Add(listTotalAttendees);
                    }
                }
            }
            return list;
        }

        public List<spExportData> MonthlyTotals(DateTime startDate, DateTime endDate)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
           {
               new MySqlParameter("startDate", startDate),
               new MySqlParameter("endDate", endDate),
           };


            List<spExportData> list = new List<spExportData>();

            using (DataTable table = DBHelper.ParamSelect("spMonthlyTotals", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spExportData listTotalAttendees = new spExportData
                        {

                            FullName = row["Full Name"].ToString(),

                            Grade = Convert.ToInt32(row["Grade"]),
                            AttendedDate = Convert.ToDateTime(row["Attended Date"]),
                            AmountDue = Convert.ToDouble(row["Amount Due"]),


                        };

                        list.Add(listTotalAttendees);
                    }
                }
            }
            return list;
        }

        public List<spExportData> SpecialStudents(DateTime startDate, DateTime endDate, int paraName)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
          {
               new MySqlParameter("startDate", startDate),
               new MySqlParameter("endDate", endDate),
               new MySqlParameter("paraName", paraName),

          };


            List<spExportData> list = new List<spExportData>();

            using (DataTable table = DBHelper.ParamSelect("spSpecialStudents", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spExportData listTotalAttendees = new spExportData
                        {

                            FullName = row["Full Name"].ToString(),

                            Grade = Convert.ToInt32(row["Grade"]),
                            AttendedDate = Convert.ToDateTime(row["Attended Date"]),
                            AmountDue = Convert.ToDouble(row["Amount Due"]),


                        };

                        list.Add(listTotalAttendees);
                    }
                }
            }
            return list;
        }

        public List<spExportData> SpecialStudent(DateTime startDate, DateTime endDate, int paraName)
        {
            MySqlParameter[] parameters = new MySqlParameter[]
          {
               new MySqlParameter("startDate", startDate),
               new MySqlParameter("endDate", endDate),
               new MySqlParameter("paraName", paraName),
          };


            List<spExportData> list = new List<spExportData>();

            using (DataTable table = DBHelper.ParamSelect("spSpecialStudent", CommandType.StoredProcedure, parameters))
            {
                if (table.Rows.Count > 0)
                {
                    foreach (DataRow row in table.Rows)
                    {
                        spExportData listTotalAttendees = new spExportData
                        {

                            FullName = row["Full Name"].ToString(),

                            Grade = Convert.ToInt32(row["Grade"]),
                            AttendedDate = Convert.ToDateTime(row["Attended Date"]),
                            AmountDue = Convert.ToDouble(row["Amount Due"]),


                        };

                        list.Add(listTotalAttendees);
                    }
                }
            }
            return list;
        }
    }
}
