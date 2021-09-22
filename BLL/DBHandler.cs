using DAL;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using TypeLibrary.Interfaces;
using TypeLibrary.Models;
using TypeLibrary.ViewModels;

namespace BLL
{
    public class DBHandler : IDBHandler
    {
        IDBAccess dB;
        public DBHandler()
        {
            dB = new DBAccess();
        }
        #region Edit Items

        public bool BLL_EditAttendance(Attendance attendance)
        {
            return dB.EditAttendance(attendance);
        }

        public bool BLL_EditCourse(Course course)
        {
            return dB.EditCourse(course);
        }

        public bool BLL_EditStudent(Student student)
        {
            return dB.EditStudent(student);
        }

        public bool BLL_EditUser(Users users)
        {
            return dB.EditUser(users);
        }

        #endregion

        #region Add Items
        public bool BLL_InsertAttendance(Attendance attendance)
        {
            return dB.InsertAttendance(attendance);
        }

        public bool BLL_InsertCourse(Course course)
        {
            return dB.InsertCourse(course);
        }

        public bool BLL_InsertStudent(Student student)
        {
            return dB.InsertStudent(student);
        }

        public bool BLL_InsertUser(Users users)
        {
            return dB.InsertUser(users);
        }

        #endregion

        #region List Items

        public List<spListTotalAttendees> BLL_ListTotalAttendees()
        {
            return dB.ListTotalAttendees();
        }

        public List<spAllCourses> BLL_ListAllCourses()
        {
            return dB.ListAllCourses();
        }

        public List<spListStudents> BLL_ListStudents()
        {
            return dB.ListStudents();
        }

        public List<spAllCourses> BLL_SearchCourses(string course)
        {
            throw new NotImplementedException();
        }

        public List<spListStudents> BLL_SearchStudents(string student)
        {
            return dB.SearchStudents(student);
        }

        public List<spInvoiceDisplay> BLL_InvoiceDisplay()
        {
            return dB.InvoiceDisplay();
        }

        public List<spInvoiceDisplay> BLL_InvoiceSearch(string firstname)
        {
            return dB.InvoiceSearch(firstname);
        }

        public object BLL_Login(string userName, string password)
        {
            return dB.Login(userName, password);
        }

        public List<spAttendanceDisplay> BLL_AttendeesDisplay()
        {
            return dB.AttendeesDisplay();
        }

        public List<spEmailAddress> BLL_EmailDisplay()
        {
            return dB.EmailDisplay();
        }

        public List<spAttendeesDisplay> BLL_AttendanceDisplay(string stdID)
        {
            return dB.AttendanceDisplay(stdID);
        }

        public List<spAttendanceDisplay> BLL_AttendanceDisplay()
        {
            return dB.AttendanceDisplay();
        }

        public List<spInvoiceDisplay> BLL_InvoiceSearchByDate(string firstname, DateTime startDate)
        {
            return dB.InvoiceSearchByDate(firstname, startDate);
        }

        public ObservableCollection<spListStudents> BLL_ListStudentsPages()
        {
            return dB.ListStudentsPages();
        }

        public ObservableCollection<spListStudents> BLL_SearchForStudent(string student)
        {
            return dB.SearchForStudent(student);
        }

        public object BLL_IsUserExist(string userName)
        {
            return dB.IsUserExist(userName);
        }

        public List<spListUsers> BLL_ListUsers()
        {
            return dB.ListUsers();
        }

        public List<spListUsers> BLL_SearchUsers(string firstname)
        {
            return dB.SearchUsers(firstname);
        }

        public object BLL_IsAttendanceExist(DateTime timeSlot, int studentID, int noOfHours)
        {
            return dB.IsAttendanceExist(timeSlot, studentID, noOfHours);
        }

        public object BLL_IsStudentExist(string studentName, string lastName)
        {
            return dB.IsStudentExist(studentName, lastName);
        }

        public bool BLL_DeleteAttendance(Attendance attendance)
        {
            return dB.DeleteAttendance(attendance);
        }

        public async Task<bool> BLL_InsertCourseAsync(Course course)
        {
            return await dB.InsertCourseAsync(course);
        }

        public async Task<bool> BLL_InsertStudentAsync(Student student)
        {
            return await dB.InsertStudentAsync(student);
        }

        public async Task<bool> BLL_InsertUserAsync(Users tutor)
        {
            return await dB.InsertUserAsync(tutor);
        }

        public async Task<bool> BLL_InsertAttendanceAsync(Attendance attendance)
        {
            return await dB.InsertAttendanceAsync(attendance);
        }

        public bool BLL_DeleteStudent(Student student)
        {
            return dB.DeleteStudent(student);
        }

        public List<spExportData> BLL_ExportData(DateTime startDate, DateTime endDate, int paraName)
        {
            return dB.ExportData(startDate, endDate, paraName);
        }
        public List<spExportData> BLL_ExportData()
        {
            return dB.ExportData();
        }

        public List<spExportData> BLL_MonthlyTotals(DateTime startDate, DateTime endDate)
        {
            return dB.MonthlyTotals(startDate, endDate);
        }

        public List<spColeHoneyInvoice> BLL_ColeHoneyInvoiceDisplay(string firstname)
        {
            return dB.ColeHoneyInvoiceDisplay(firstname);
        }

        public List<spColeHoneyInvoice> BLL_ColeHoneyInvoiceDisplayByDate(string firstname, DateTime startDate)
        {
            return dB.ColeHoneyInvoiceDisplayByDate(firstname, startDate);
        }

        public List<spColeHoneyInvoice> BLL_SpecialByDate(string firstname, DateTime startDate)
        {
            return dB.SpecialByDate(firstname, startDate);
        }

        public List<spColeHoneyInvoice> BLL_SpecialInvoice(string firstname)
        {
            return dB.SpecialInvoice(firstname);
        }

        public List<spExportData> BLL_SpecialStudents(DateTime startDate, DateTime endDate, int paraName)
        {
            return dB.SpecialStudents(startDate, endDate, paraName);
        }
        public List<spExportData> BLL_SpecialStudent(DateTime startDate, DateTime endDate, int paraName)
        {
            return dB.SpecialStudent(startDate, endDate, paraName);
        }


        #endregion

    }
}
