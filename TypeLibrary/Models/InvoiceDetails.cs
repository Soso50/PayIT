using System;

namespace TypeLibrary.Models
{
    public class InvoiceDetails
    {
        public int InvoiceDetailsID { get; set; }
        public int CourseID { get; set; }
        public int AttendanceID { get; set; }
        public int StudentID { get; set; }
        public DateTime DateIssued { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime DeletedAt { get; set; }
    }
}
