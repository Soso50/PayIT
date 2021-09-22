using System;

namespace TypeLibrary.Models
{
    public class UserPermission
    {
        public int UserPermissionID { get; set; }
        public int Permission { get; set; }
        public int UserID { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime DeletedAt { get; set; }
    }
}
