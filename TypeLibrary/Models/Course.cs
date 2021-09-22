using System;

namespace TypeLibrary.Models
{
    public class Course
    {
        public int CourseNo { get; set; }
        public string CourseName { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime DeletedAt { get; set; }
    }
}
