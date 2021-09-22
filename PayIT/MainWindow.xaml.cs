using BLL;
using ClosedXML.Excel;
using System;
using System.Configuration;
using System.Data;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using TypeLibrary.Interfaces;
using TypeLibrary.Models;
using MySqlCommand = MySqlConnector.MySqlCommand;
using MySqlConnection = MySqlConnector.MySqlConnection;
using MySqlDataReader = MySqlConnector.MySqlDataReader;
using static PayIT.ExportDataClass;


namespace PayIT
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        readonly IDBHandler db = new DBHandler();
        public static string firstname;
        public static DateTime startDate;
        public static bool flagDate = false;
        public static bool flagName = false;
        private static string connString = ConfigurationManager.ConnectionStrings["payItCon"].ConnectionString;
        int studentId, attendanceID;
        Attendance attendance = new Attendance();
        public static double totalSum = 0;

        public MainWindow()
        {
            InitializeComponent();
            dgTotalAttendance.DataContext = db.BLL_AttendanceDisplay();
            //dataGrid.DataContext = db.BLL_ListTotalAttendees();
            dataGrid.ItemsSource = db.BLL_InvoiceDisplay().AsQueryable().OrderByDescending(x => x.Slot);
            //Invoice student list
            cmbStudentName.DataContext = db.BLL_ListStudents();
            //Add Student list
            cmbAddStudent.DataContext = db.BLL_ListStudents();
            cmbAddCourse.DataContext = db.BLL_ListAllCourses();

            //Update Student list
            cmbUpdateStudentFullName.DataContext = db.BLL_ListTotalAttendees();
            cmbUpdateCourseName.DataContext = db.BLL_ListAllCourses();

            dpStartDate.IsEnabled = false;
            //dgTotalUpdateAttendance.ItemsSource = db.BLL_AttendeesDisplay();
            updateDataGridAsync();

            //btnEportDB.IsEnabled = false;
        }

        private void btnInvoice_Click(object sender, RoutedEventArgs e)
        {
            try
            {

                if (rbSearchDate.IsChecked == false && cmbStudentName.Text != "")
                {
                    firstname = cmbStudentName.Text;
                    flagName = true;
                    totalSum = 0;
                    //dataGrid.DataContext = db.BLL_InvoiceSearch(firstname);
                    frmInvoice main = new frmInvoice();
                    this.Hide();
                    main.Show();
                }
                else if (rbSearchDate.IsChecked == true && cmbStudentName.Text != "")
                {
                    firstname = cmbStudentName.Text;
                    startDate = DateTime.Parse(dpStartDate.Text);

                    flagDate = true;

                    frmInvoice main = new frmInvoice();
                    this.Close();
                    main.Show();
                }
                else
                {
                    MessageBox.Show("Select at least one option");
                }
            }
            catch (Exception ex)
            {

                MessageBox.Show(ex.Message);
            }

        }

        private async Task updateDataGridAsync()
        {
            using (MySqlConnection con = new MySqlConnection(connString))
            {
                await con.OpenAsync();
                MySqlCommand cmd = con.CreateCommand();
                cmd.CommandText = "SELECT DISTINCT a.AttendanceID AS 'Attendance No.', CONCAT(s.FirstName,' ' ,s.Surname) as 'Student', c.courseName as 'Course', a.TimeSlot as 'Slot',a.NoOfHours as 'No Of Hours', a.GroupSession AS 'Group Session',a.StudentID as 'Student No.', a.CourseID ' Course No.'  FROM student s , course c, attendance a WHERE s.studentID = a.studentID AND c.courseID = a.courseID AND a.DeletedAt IS NULL GROUP By a.AttendanceID ORDER BY s.FirstName";
                cmd.CommandType = CommandType.Text;
                MySqlDataReader dr = cmd.ExecuteReader();
                DataTable dt = new DataTable();
                dt.Load(dr);
                dgTotalUpdateAttendance.ItemsSource = await Task.Run(() => dt.DefaultView);
                dgTotalDeleteAttendance.ItemsSource = await Task.Run(() => dt.DefaultView);
                dr.Close();
            }

        }

        private async void btnAddAttendance_Click(object sender, RoutedEventArgs e)
        {
            try
            {

                Attendance att = new Attendance
                {
                    StudentID = int.Parse(cmbAddStudent.SelectedValue.ToString()),
                    CourseID = int.Parse(cmbAddCourse.SelectedValue.ToString()),
                    NoOfHours = int.Parse(txtNumberOfHours.Text),
                    TimeSlot = DateTime.Parse(dpTimeSlot.Text),
                    GroupSession = int.Parse(rbGroup.Text)
                };

                //if (db.BLL_IsAttendanceExist(DateTime.Parse(dpTimeSlot.Text), int.Parse(cmbAddStudent.SelectedValue.ToString()), int.Parse(txtNumberOfHours.Text)) == null)
                //{
                if (DateHelper.IsDateBeforeOrToday(DateTime.Parse(dpTimeSlot.Text)) == true)
                {
                    await db.BLL_InsertAttendanceAsync(att);

                    MessageBox.Show("Attendance record has been added.");
                    dgTotalAttendance.DataContext = db.BLL_AttendanceDisplay();
                }
                else
                {
                    MessageBox.Show("Booking cannot be a future date.");
                }


                //}
                ////else
                //{
                //    MessageBox.Show("Booking already exists.");
                //}

            }
            catch (Exception)
            {

                MessageBox.Show("Invaild input. Please enter correct details.");
            }

        }

        private async void btnEditAttendace_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                attendance = new Attendance
                {
                    AttendanceID = attendanceID,
                    CourseID = int.Parse(cmbUpdateCourseName.SelectedValue.ToString()),
                    NoOfHours = int.Parse(txtNoOfHours.Text),
                    TimeSlot = DateTime.Parse(dpSlot.Text),
                    GroupSession = int.Parse(rbGroupSession.Text)
                };

                if (db.BLL_EditAttendance(attendance))
                    MessageBox.Show("Attendance has been updated.");
                dgTotalAttendance.DataContext = db.BLL_AttendanceDisplay();
                //dgTotalUpdateAttendance.ItemsSource = db.BLL_AttendeesDisplay();
                await updateDataGridAsync();


            }
            catch (Exception)
            {

                MessageBox.Show("Invaild input. Please enter correct details.");
            }
        }

        private void CmbStudentFullName_Onloaded(object sender, RoutedEventArgs e)
        {
            //dgTotalAttendance.DataContext = db.BLL_ListTotalAttendees();
            //dataGrid.DataContext = db.BLL_InvoiceDisplay();

            //Total Attendance
            dgTotalAttendance.DataContext = db.BLL_AttendeesDisplay();

            //Invoice student list
            cmbStudentName.DataContext = db.BLL_ListTotalAttendees();
            //Add Student list
            cmbAddStudent.DataContext = db.BLL_ListStudents();
            cmbAddCourse.DataContext = db.BLL_ListAllCourses();

            //Update Student list
            cmbUpdateStudentFullName.DataContext = db.BLL_ListTotalAttendees();
            cmbUpdateCourseName.DataContext = db.BLL_ListAllCourses();

            dgTotalUpdateAttendance.DataContext = db.BLL_AttendeesDisplay();

            //if (Login.adminUser == "admin")
            //{
            //    btnEportDB.IsEnabled = true;
            //}
            //else
            //{
            //    btnEportDB.IsEnabled = false;
            //}
        }

        private void btnAttach_Click(object sender, RoutedEventArgs e)
        {
            frmSendInvoice sendInvoice = new frmSendInvoice();
            sendInvoice.Show();
        }

        private void btnStudent_Click(object sender, RoutedEventArgs e)
        {
            frmManage.Content = new pgeStudent();
        }

        private void btnTutor_Click(object sender, RoutedEventArgs e)
        {
            frmManage.Content = new pgeUser(); // User = Tutor.
        }

        private void btnCourse_Click(object sender, RoutedEventArgs e)
        {
            frmManage.Content = new Pages.pgeCourse();
        }

        private void rbSearchDate_Checked(object sender, RoutedEventArgs e)
        {
            dpStartDate.IsEnabled = true;
        }

        private void dgTotalUpdateAttendance_Selected(object sender, SelectionChangedEventArgs e)
        {
            DataGrid dg = sender as DataGrid;
            DataRowView dr = dg.SelectedItem as DataRowView;
            if (dr != null)
            {
                attendance.AttendanceID = int.Parse(dr[0].ToString());
                cmbUpdateStudentFullName.Text = dr[1].ToString();
                cmbUpdateCourseName.Text = dr[2].ToString();
                dpSlot.Text = dr[3].ToString();
                txtNoOfHours.Text = dr[4].ToString();
                rbGroupSession.Text = dr[5].ToString();

                attendance.CourseID = int.Parse(dr[7].ToString());


                studentId = int.Parse(dr[6].ToString());
                attendanceID = int.Parse(dr[0].ToString());
            }


        }

        private void dgTotalDeleteAttendance_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            DataGrid dg = sender as DataGrid;
            DataRowView dr = dg.SelectedItem as DataRowView;
            if (dr != null)
            {
                attendance.AttendanceID = int.Parse(dr[0].ToString());
                cmbDeleteStudentFullName.Text = dr[1].ToString();
                attendanceID = int.Parse(dr[0].ToString());
            }
        }
        //Export SQL to Excel on button click -------------------------------------------------------------------------------------------------



        private void btnEportDB_Click(object sender, RoutedEventArgs e)
        {



            try
            {
                if (dpStartDate.Text != null && dpEndDate.Text != null)
                {
                    //FilePath and filename
                    string folderPath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + @"\";
                    string fileName = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + @"\K2_App_Export.xlsx";
                    ExportDataClass bc = new ExportDataClass();

                    if (!Directory.Exists(folderPath))
                    {
                        Directory.CreateDirectory(folderPath);
                    }
                    if (!File.Exists(fileName))
                    {
                        //Create Workbook
                        var wb = new XLWorkbook();

                        //Total Due Sheet

                        bc.TotalsSheet(dpStartDate.Text, dpEndDate.Text);

                        //Special Students
                        bc.SpecialStudentsSheet(dpStartDate.Text, dpEndDate.Text);

                        //Grades Sheet
                        bc.GradesSheet(dpStartDate.Text, dpEndDate.Text);

                        //Saving workbook
                        bc.SaveAndOpenWB(folderPath);

                    }
                    else
                    {
                        //open work book by initializing it.
                        var wb = new XLWorkbook(fileName);
                        for (int d = 8; d >= 1; d--)
                        {
                            wb.Worksheets.Delete(d);
                        }

                        //Total Due Sheet

                        bc.TotalsSheet(dpStartDate.Text, dpEndDate.Text);

                        //Special Students
                        bc.SpecialStudentsSheet(dpStartDate.Text, dpEndDate.Text);

                        //Grades Sheet
                        bc.GradesSheet(dpStartDate.Text, dpEndDate.Text);

                        //Saving workbook
                        bc.SaveAndOpenWB(folderPath);


                    }
                }
                else
                {
                    MessageBox.Show("Enter a start date and end date!");
                }
            }

            catch (Exception)
            {
                //MessageBox.Show("Please ensure excel is closed before exporting. ");
                throw;
            }




        }



        private async void btnDeleteAttendance_Click(object sender, RoutedEventArgs e)
        {
            try
            {

                attendance = new Attendance
                {
                    AttendanceID = attendanceID,
                };
                if (MessageBox.Show("Are you sure you want to delete record?", "Confirmation", MessageBoxButton.YesNo) == MessageBoxResult.Yes)
                {

                    db.BLL_DeleteAttendance(attendance);

                    MessageBox.Show("Attendance record has been deleted.");
                    dgTotalAttendance.DataContext = db.BLL_AttendanceDisplay();
                    //dgTotalUpdateAttendance.ItemsSource = db.BLL_AttendeesDisplay();
                    //dgTotalDeleteAttendance.ItemsSource = db.BLL_AttendeesDisplay();
                    await updateDataGridAsync();

                }
                else
                {
                    MessageBox.Show("Attendance record could not be deleted.");
                }
            }
            catch (Exception)
            {

                MessageBox.Show("Invaild input. Please enter correct details.");
            }
        }
    }
}



