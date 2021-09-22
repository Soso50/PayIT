using System;

namespace BLL
{
    public static class DateHelper
    {
        public static DateTime GetLastDayOfMonth(this DateTime dateTime)
        {
            return new DateTime(dateTime.Year, dateTime.Month, DateTime.DaysInMonth(dateTime.Year, dateTime.Month)).AddDays(5);
        }

        public static bool IsDateBeforeOrToday(DateTime pDate)
        {
            //DateTime pDate;
            if (pDate.Date <= DateTime.Now.Date)
            {
                return true;
            }
            else
            {
                return false;
            }

        }

    }
}
