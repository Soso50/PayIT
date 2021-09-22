using BLL;
using ClosedXML.Excel;
using System;
using System.Configuration;
using System.Data;
using System.Linq;
using TypeLibrary.Interfaces;
using TypeLibrary.Models;

namespace PayIT
{
    public class ExportDataClass
    {

        public IDBHandler db = new DBHandler();
        private static string connString = ConfigurationManager.ConnectionStrings["payItCon"].ConnectionString;
        public string folderPath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + @"\";
        public string fileName = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + @"\K2_App_Export.xlsx";
        XLWorkbook wb = new XLWorkbook();


        //Total Due Sheet
        public void TotalsSheet(string dpStartDate, string dpEndDate)
        {
            var tp = wb.Worksheets.Add("Total Amounts Due");
            var newTable1 = tp.Cell(1, 1).InsertTable(db.BLL_MonthlyTotals(Convert.ToDateTime(dpStartDate), Convert.ToDateTime(dpEndDate)).AsEnumerable());
            newTable1.Cell("A1").Value = "Name";
            newTable1.Cell("B1").Value = "Grade";
            newTable1.Cell("C1").Value = "Attendance Date";
            newTable1.Cell("D1").Value = "Amount Due";
            for (int i = 6; i <= 12; i++)
            {
                newTable1.AppendData(db.BLL_SpecialStudents(Convert.ToDateTime(dpStartDate), Convert.ToDateTime(dpEndDate), i).AsEnumerable());
            }

            newTable1.ShowTotalsRow = true;
            newTable1.Field(3).TotalsRowFunction = XLTotalsRowFunction.Sum;
            newTable1.Field(0).TotalsRowLabel = "Total Income";
            tp.Column("D").Style.NumberFormat.Format = "R #,###.00";
            tp.Columns().AdjustToContents();

        }

        //Special Students

        public void SpecialStudentsSheet(string dpStartDate, string dpEndDate)
        {
            var tp = wb.Worksheets.Add("Special Students");
            var newTable1 = tp.Cell(1, 1).InsertTable(db.BLL_SpecialStudents(Convert.ToDateTime(dpStartDate), Convert.ToDateTime(dpEndDate), 6).AsEnumerable());
            newTable1.Cell("A1").Value = "Name";
            newTable1.Cell("B1").Value = "Grade";
            newTable1.Cell("C1").Value = "Attendance Date";
            newTable1.Cell("D1").Value = "Amount Due";
            for (int i = 7; i <= 12; i++)
            {
                newTable1.AppendData(db.BLL_SpecialStudents(Convert.ToDateTime(dpStartDate), Convert.ToDateTime(dpEndDate), i).AsEnumerable());
            }

            newTable1.ShowTotalsRow = true;
            newTable1.Field(3).TotalsRowFunction = XLTotalsRowFunction.Sum;
            newTable1.Field(0).TotalsRowLabel = "Total Income";
            tp.Column("D").Style.NumberFormat.Format = "R #,###.00";
            tp.Columns().AdjustToContents();

        }
        //Grades Sheet
        public void GradesSheet(string dpStartDate, string dpEndDate)
        {
            for (int i = 6; i <= 12; i++)
            {
                var tp = wb.Worksheets.Add("Grade " + i.ToString());
                var newTable1 = tp.Cell(1, 1).InsertTable(db.BLL_ExportData(Convert.ToDateTime(dpStartDate), Convert.ToDateTime(dpEndDate), i).AsEnumerable());
                newTable1.Cell("A1").Value = "Name";
                newTable1.Cell("B1").Value = "Grade";
                newTable1.Cell("C1").Value = "Attendance Date";
                newTable1.Cell("D1").Value = "Amount Due";
                newTable1.AppendData(db.BLL_SpecialStudent(Convert.ToDateTime(dpStartDate), Convert.ToDateTime(dpEndDate), i).AsEnumerable());
                newTable1.AppendData(db.BLL_SpecialStudents(Convert.ToDateTime(dpStartDate), Convert.ToDateTime(dpEndDate), i).AsEnumerable());
                newTable1.ShowTotalsRow = true;
                newTable1.Field(3).TotalsRowFunction = XLTotalsRowFunction.Sum;
                newTable1.Field(0).TotalsRowLabel = "Total Income";
                tp.Column("D").Style.NumberFormat.Format = "R #,###.00";
                tp.Columns().AdjustToContents();
            }


        }

        //Saving workbook
        public void SaveAndOpenWB(string folderPath)
        {

            wb.SaveAs(folderPath + "K2_App_Export.xlsx");
            System.Diagnostics.Process.Start(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + @"\K2_App_Export.xlsx");
        }

        //Deleting All old sheets
        

        //Set Colum Header Names
        
        //Formatting the cells
        

    }
}
