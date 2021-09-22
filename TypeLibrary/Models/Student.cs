using System;

namespace TypeLibrary.Models
{
    public class Student
    {
        public int StudentID { get; set; }
        public string FirstName { get; set; }
        public string Surname { get; set; }
        public string EmailAddress { get; set; }
        public string Sponsor { get; set; }

        public int Grade { get; set; }
        public int CategoryID { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime DeletedAt { get; set; }
    }
}
