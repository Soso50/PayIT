using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using TypeLibrary.Models;
using TypeLibrary.ViewModels;

namespace TypeLibrary.Interfaces
{
    public interface IDBAccess
    {
        bool InsertCourse(Course course);
        bool InsertStudent(Student student);
        bool InsertUser(Users tutor);
        bool InsertAttendance(Attendance attendance);
        Task<bool> InsertCourseAsync(Course course);
        Task<bool> InsertStudentAsync(Student student);
        Task<bool> InsertUserAsync(Users tutor);
        Task<bool> InsertAttendanceAsync(Attendance attendance);

        bool EditCourse(Course course);
        bool EditStudent(Student student);
        bool EditUser(Users users);
        bool EditAttendance(Attendance attendance);

        bool DeleteAttendance(Attendance attendance);
        List<spListTotalAttendees> ListTotalAttendees();
        List<spAttendanceDisplay> AttendeesDisplay();
        List<spAttendanceDisplay> AttendanceDisplay();
        List<spAllCourses> ListAllCourses();
        List<spListStudents> ListStudents();
        List<spListUsers> ListUsers();
        List<spListUsers> SearchUsers(string firstname);
        List<spAllCourses> SearchCourses(string course);
        List<spListStudents> SearchStudents(string student);
        List<spInvoiceDisplay> InvoiceDisplay();
        List<spColeHoneyInvoice> ColeHoneyInvoiceDisplay(string firstname);
        List<spColeHoneyInvoice> ColeHoneyInvoiceDisplayByDate(string firstname, DateTime startDate);
        List<spColeHoneyInvoice> SpecialByDate(string firstname, DateTime startDate);
        List<spColeHoneyInvoice> SpecialInvoice(string firstname);
        List<spInvoiceDisplay> InvoiceSearch(string firstname);
        List<spEmailAddress> EmailDisplay();
        List<spAttendeesDisplay> AttendanceDisplay(string stdID);
        List<spInvoiceDisplay> InvoiceSearchByDate(string firstname, DateTime startDate);
        List<spExportData> ExportData(DateTime startDate, DateTime endDate, int paraName);
        List<spExportData> ExportData();
        List<spExportData> MonthlyTotals(DateTime startDate, DateTime endDate);
        List<spExportData> SpecialStudents(DateTime startDate, DateTime endDate, int paraName);
        List<spExportData> SpecialStudent(DateTime startDate, DateTime endDate, int ParaName);
        object Login(string userName, string password);
        object IsUserExist(string userName);
        object IsStudentExist(string studentName, string lastName);
        object IsAttendanceExist(DateTime timeSlot, int studentID, int noOfHours);
        ObservableCollection<spListStudents> ListStudentsPages();
        ObservableCollection<spListStudents> SearchForStudent(string student);

        bool DeleteStudent(Student student);
    }
}
