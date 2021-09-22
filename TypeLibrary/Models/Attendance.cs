using System;

namespace TypeLibrary.Models
{
    public class Attendance
    {
        public int AttendanceID { get; set; }
        public int StudentID { get; set; }
        public int CourseID { get; set; }
        public int InvoiceDetailsID { get; set; }

        public DateTime DateIssued { get; set; }
        public int GroupSession { get; set; }
        public int NoOfHours { get; set; }
        public DateTime TimeSlot { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime DeletedAt { get; set; }
    }
}
