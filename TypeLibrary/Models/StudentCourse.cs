using System;

namespace TypeLibrary.Models
{
    public class StudentCourse
    {
        public int InvoiceID { get; set; }
        public DateTime DateIssued { get; set; }
        public int StudentID { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime DeletedAt { get; set; }
    }
}
