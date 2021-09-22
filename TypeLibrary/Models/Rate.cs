using System;

namespace TypeLibrary.Models
{
    public class Rate
    {
        public int RateID { get; set; }
        public double PriceRate { get; set; }
        public int CatergoryID { get; set; }
        public int GroupID { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime DeletedAt { get; set; }
    }
}
