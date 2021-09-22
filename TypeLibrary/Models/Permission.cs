using System;

namespace TypeLibrary.Models
{
    public class Permission
    {
        public int PermissionID { get; set; }
        public string PermissionName { get; set; }

        public bool CreateTutor { get; set; }
        public bool ModifyTutor { get; set; }
        public bool RemoveTutor { get; set; }

        public bool CreateStudent { get; set; }
        public bool ModifyStudent { get; set; }
        public bool RemoveStudent { get; set; }

        public bool CreateCourse { get; set; }
        public bool ModifyCourse { get; set; }
        public bool RemoveCourse { get; set; }

        public bool CreateInvoice { get; set; }
        public bool ModifyInvoice { get; set; }
        public bool RemoveInvoice { get; set; }

        public bool CreateAttendance { get; set; }
        public bool ModifyAttendance { get; set; }
        public bool RemoveAttendance { get; set; }

        public bool CreateAdmin { get; set; }
        public bool ModifyAdmin { get; set; }
        public bool RemoveAdmin { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime DeletedAt { get; set; }
    }
}
