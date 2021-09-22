using System;

namespace TypeLibrary.ViewModels
{
    public class spMonthlyTotals
    {
        public string FullName { get; set; }

        public int Grade { get; set; }
        public DateTime AttendedDate { get; set; }

        public int Hours { get; set; }
        public double Rate { get; set; }
        public double AmountDue { get { return Rate * Hours; } }
        // public double AmountDue { get; set; }
    }
}
