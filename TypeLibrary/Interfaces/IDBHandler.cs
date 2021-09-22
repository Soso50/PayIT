using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using TypeLibrary.Models;
using TypeLibrary.ViewModels;

namespace TypeLibrary.Interfaces
{
    public interface IDBHandler
    {
        bool BLL_InsertCourse(Course course);
        bool BLL_InsertStudent(Student student);
        bool BLL_InsertUser(Users tutor);
        bool BLL_InsertAttendance(Attendance attendance);

        Task<bool> BLL_InsertCourseAsync(Course course);
        Task<bool> BLL_InsertStudentAsync(Student student);
        Task<bool> BLL_InsertUserAsync(Users tutor);
        Task<bool> BLL_InsertAttendanceAsync(Attendance attendance);

        bool BLL_EditCourse(Course course);
        bool BLL_EditStudent(Student student);
        bool BLL_EditUser(Users users);
        bool BLL_EditAttendance(Attendance attendance);

        bool BLL_DeleteAttendance(Attendance attendance);

        List<spListTotalAttendees> BLL_ListTotalAttendees();
        List<spAllCourses> BLL_ListAllCourses();
        List<spListStudents> BLL_ListStudents();
        List<spListUsers> BLL_ListUsers();
        List<spListUsers> BLL_SearchUsers(string firstname);
        List<spAttendanceDisplay> BLL_AttendeesDisplay();
        List<spAttendanceDisplay> BLL_AttendanceDisplay();

        List<spAllCourses> BLL_SearchCourses(string course);
        List<spListStudents> BLL_SearchStudents(string student);
        List<spInvoiceDisplay> BLL_InvoiceDisplay();
        List<spInvoiceDisplay> BLL_InvoiceSearch(string firstname);
        List<spInvoiceDisplay> BLL_InvoiceSearchByDate(string firstname, DateTime startDate);
        List<spEmailAddress> BLL_EmailDisplay();
        List<spAttendeesDisplay> BLL_AttendanceDisplay(string stdID);
        List<spExportData> BLL_ExportData(DateTime startDate, DateTime endDate, int paraName);
        List<spExportData> BLL_ExportData();
        List<spExportData> BLL_MonthlyTotals(DateTime startDate, DateTime endDate);
        List<spExportData> BLL_SpecialStudents(DateTime startDate, DateTime endDate, int paraName);
        List<spExportData> BLL_SpecialStudent(DateTime startDate, DateTime endDate, int ParaName);
        List<spColeHoneyInvoice> BLL_ColeHoneyInvoiceDisplay(string firstname);
        List<spColeHoneyInvoice> BLL_ColeHoneyInvoiceDisplayByDate(string firstname, DateTime startDate);
        List<spColeHoneyInvoice> BLL_SpecialByDate(string firstname, DateTime startDate);
        List<spColeHoneyInvoice> BLL_SpecialInvoice(string firstname);
        object BLL_Login(string userName, string password);
        object BLL_IsUserExist(string userName);
        object BLL_IsStudentExist(string studentName, string lastName);
        object BLL_IsAttendanceExist(DateTime timeSlot, int studentID, int noOfHours);
        ObservableCollection<spListStudents> BLL_ListStudentsPages();
        ObservableCollection<spListStudents> BLL_SearchForStudent(string student);

        bool BLL_DeleteStudent(Student student);
    }
}
