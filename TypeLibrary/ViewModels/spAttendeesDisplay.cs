using System;

namespace TypeLibrary.ViewModels
{
    public class spAttendeesDisplay
    {
        public int StudentID { get; set; }
        public int CourseID { get; set; }
        public string Student { get; set; }
        public string Course { get; set; }
        public DateTime Slot { get; set; }
        public int Group { get; set; }
        public int Hours { get; set; }
        public double Rate { get; set; }
        public int InvoiceID { get; set; }
        public string PhoneNo { get; set; }
        public string Email { get; set; }
        public DateTime DateIssued { get; set; }
        public string DateAttendedString { get { return Slot.ToString(); } }
        public string DateIssuedString { get { return DateIssued.ToString(); } }
        public string CourseRateString { get { return Rate.ToString("C"); } }

        public double SubTotal { get { return Rate * Hours; } }
        public string SubTotalString { get { return SubTotal.ToString("C"); } }

        public double Total { get; set; }
        public string TotalString { get { return Total.ToString("C"); } }


    }
}
