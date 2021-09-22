using TypeLibrary.ViewModels;
namespace BLL
{
    public class InvoiceHelper
    {
        spAttendeesDisplay attendance = new spAttendeesDisplay();
        public double CalculateTotal(double total)
        {
            return total += attendance.SubTotal;
        }
    }
}
