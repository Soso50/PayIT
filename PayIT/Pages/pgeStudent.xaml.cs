using BLL;
using DAL;
using MySql.Data.MySqlClient;
using System;
using System.Collections.ObjectModel;
using System.Configuration;
using System.Data;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using TypeLibrary.Interfaces;
using TypeLibrary.Models;
using TypeLibrary.ViewModels;

namespace PayIT
{
    /// <summary>
    /// Interaction logic for Student.xaml
    /// </summary>
    public partial class pgeStudent : Page
    {
        IDBHandler db = new DBHandler();
        Student student = new Student();
        private static string connString = ConfigurationManager.ConnectionStrings["payItCon"].ConnectionString;

        CollectionViewSource view = new CollectionViewSource();
        ObservableCollection<spListStudents> customers = new ObservableCollection<spListStudents>();
        int currentPageIndex = 0;
        int itemPerPage = 20;
        int totalPage = 0;
        int cat1 = 1, cat2 = 2, cat3 = 3;
        //int itemcount = 100;
        spListStudents listStudents = new spListStudents();
        public pgeStudent()
        {
            InitializeComponent();

        }

        private async void Window_Loaded(object sender, RoutedEventArgs e)
        {
            Paging();
            dgViewStudent.ItemsSource = db.BLL_ListStudents();
            txtAddStudentCategory.IsEnabled = false;
            txtUpdateStudentCategory.IsEnabled = false;
            updateDataGrid();
        }

        private void updateDataGrid()
        {
            using (MySqlConnection con = new MySqlConnection(connString))
            {
                con.Open();
                MySqlCommand cmd = con.CreateCommand();
                cmd.CommandText = "SELECT s.studentID as 'Student No.', s.FirstName Firstname, s.Surname Lastname, s.EmailAddress AS 'Email', s.Sponsor, s.grade as Grade FROM student s ORDER BY s.FirstName";
                cmd.CommandType = CommandType.Text;
                MySqlDataReader dr = cmd.ExecuteReader();
                DataTable dt = new DataTable();
                dt.Load(dr);
                dgUpdateStudent.ItemsSource = dt.DefaultView;
                dr.Close();
            }

        }
        void view_Filter(object sender, FilterEventArgs e)
        {
            int index = customers.IndexOf((spListStudents)e.Item);

            if (index >= itemPerPage * currentPageIndex && index < itemPerPage * (currentPageIndex + 1))
            {
                e.Accepted = true;
            }
            else
            {
                e.Accepted = false;
            }
        }

        private void btnFirst_Click(object sender, RoutedEventArgs e)
        {
            // Display the first page
            if (currentPageIndex != 0)
            {
                btnFirst.IsEnabled = false;
                btnPrev.IsEnabled = false;
                btnNext.IsEnabled = true;
                btnLast.IsEnabled = true;
                currentPageIndex = 0;
                view.View.Refresh();
            }
            else if (currentPageIndex == 0)
            {
                btnFirst.IsEnabled = false;
            }
            ShowCurrentPageIndex();
        }

        private void btnPrev_Click(object sender, RoutedEventArgs e)
        {
            // Display previous page
            if (currentPageIndex > 0)
            {
                btnNext.IsEnabled = true;
                btnLast.IsEnabled = true;
                currentPageIndex--;
                view.View.Refresh();
            }
            else
            {
                btnPrev.IsEnabled = false;
                btnFirst.IsEnabled = false;

            }
            ShowCurrentPageIndex();
        }

        private void btnNext_Click(object sender, RoutedEventArgs e)
        {
            // Display next page
            if (currentPageIndex < totalPage - 1)
            {
                currentPageIndex++;
                view.View.Refresh();
                btnPrev.IsEnabled = true;
            }
            else
            {
                btnNext.IsEnabled = false;
                btnLast.IsEnabled = false;

            }
            ShowCurrentPageIndex();
            btnFirst.IsEnabled = true;
        }

        private void btnLast_Click(object sender, RoutedEventArgs e)
        {
            // Display the last page
            if (currentPageIndex != totalPage - 1)
            {
                btnFirst.IsEnabled = true;
                btnPrev.IsEnabled = true;
                btnLast.IsEnabled = false;
                btnNext.IsEnabled = false;
                currentPageIndex = totalPage - 1;
                view.View.Refresh();
            }

            ShowCurrentPageIndex();
        }

        private void Paging()
        {
            customers = db.BLL_ListStudentsPages();
            // Calculate the total pages
            totalPage = DBAccess.countItems / itemPerPage;
            if (DBAccess.countItems % itemPerPage != 0)
            {
                totalPage += 1;
            }

            view.Source = customers;

            view.Filter += new FilterEventHandler(view_Filter);

            this.dgAddStudent.DataContext = view;
            //this.dgUpdateStudent.DataContext = view;
            ShowCurrentPageIndex();
            this.tbTotalPage.Text = totalPage.ToString();
            btnFirst.IsEnabled = false;
            btnPrev.IsEnabled = false;
        }

        private void ShowCurrentPageIndex()
        {
            this.tbCurrentPage.Text = (currentPageIndex + 1).ToString();
        }
        private void btnAddStudent_Click(object sender, RoutedEventArgs e)
        {
            try
            {

                if (txtAddStudentName.Text != "" && txtAddStudentSurName.Text != "" && txtAddStudentSponsor.Text != "" && txtAddStudentPhoneNum.Text != "" && txtAddStudentCategory.Text != "")
                {
                    student.FirstName = txtAddStudentName.Text;
                    student.Surname = txtAddStudentSurName.Text;

                    student.Sponsor = txtAddStudentSponsor.Text;

                    student.Grade = int.Parse(txtAddStudentPhoneNum.Text);

                    if (db.BLL_IsStudentExist(txtAddStudentName.Text, txtAddStudentSurName.Text) == null)
                    {
                        if (EmailHelper.ValidateEmailAddress(txtAddStudentEmail.Text) == true)
                        {
                            student.EmailAddress = txtAddStudentEmail.Text;

                            if (db.BLL_InsertStudent(student))
                            {
                                MessageBox.Show("Student has been added.");
                                Paging();
                                updateDataGrid();
                                dgViewStudent.ItemsSource = db.BLL_ListStudents();
                                //this.dgAddStudent.DataContext = MainWindow.view;
                            }
                            else
                            {
                                MessageBox.Show("Student has not been added.");
                            }
                        }
                        else
                        {
                            MessageBox.Show("Invalid email address.");
                        }
                    }
                    else
                    {
                        MessageBox.Show("Student already exists.");
                    }
                }
                else
                {
                    MessageBox.Show("All fields are required.");
                }
            }
            catch (Exception)
            {

                MessageBox.Show("Invalid input.");
            }


        }

        private void btnSearch_Click(object sender, RoutedEventArgs e)
        {
            dgViewStudent.ItemsSource = db.BLL_SearchStudents(txtViewCourse.Text);
        }

        private void txtAddStudentPhoneNum_ValueChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            txtAddStudentCategory.Items.Clear();
            if (int.Parse(txtAddStudentPhoneNum.Text) > 10 && int.Parse(txtAddStudentPhoneNum.Text) < 14)
            {
                txtAddStudentCategory.IsEnabled = true;
                txtAddStudentCategory.Items.Add("Grade 11 - Varsity");

                student.CategoryID = cat2;

            }
            else if (int.Parse(txtAddStudentPhoneNum.Text) < 11 && int.Parse(txtAddStudentPhoneNum.Text) >= 8)
            {
                txtAddStudentCategory.IsEnabled = true;
                //txtAddStudentCategory.IsEnabled = false;
                txtAddStudentCategory.Items.Add("Grade 8 - 10");
                student.CategoryID = cat1;
            }
            else if (int.Parse(txtAddStudentPhoneNum.Text) < 8)
            {
                txtAddStudentCategory.IsEnabled = true;
                //txtAddStudentCategory.IsEnabled = false;
                txtAddStudentCategory.Items.Add("Grade 6 - 7");
                student.CategoryID = cat3;
            }

        }

        private void dgUpdateStudent_Selected(object sender, RoutedEventArgs e)
        {

            DataGrid dg = sender as DataGrid;
            DataRowView dr = dg.SelectedItem as DataRowView;
            if (dr != null)
            {
                txtUpdateStudentName.Text = dr[1].ToString();
                txtUpdateStudentSurName.Text = dr[2].ToString();
                txtUpdateStudentEmail.Text = dr[3].ToString();
                txtUpdateStudentSponsor.Text = dr[4].ToString();
                txtUpdateStudentPhoneNum.Text = (dr[5].ToString());


                student.StudentID = int.Parse(dr[0].ToString());

            }
        }

        private void btnUpdateStudent_Click(object sender, RoutedEventArgs e)
        {
            try
            {

                if (txtUpdateStudentName.Text != "" && txtUpdateStudentSurName.Text != "" && txtUpdateStudentEmail.Text != "" && txtUpdateStudentSponsor.Text != "" && txtUpdateStudentCategory.Text != "")
                {
                    student.FirstName = txtUpdateStudentName.Text;
                    student.Surname = txtUpdateStudentSurName.Text;

                    student.Sponsor = txtUpdateStudentSponsor.Text;

                    student.Grade = int.Parse(txtUpdateStudentPhoneNum.Text);


                    if (EmailHelper.ValidateEmailAddress(txtUpdateStudentEmail.Text) == true)
                    {
                        student.EmailAddress = txtUpdateStudentEmail.Text;

                        if (db.BLL_EditStudent(student))
                        {
                            MessageBox.Show("Student has been updated.");
                            updateDataGrid();
                            dgViewStudent.ItemsSource = db.BLL_ListStudents();
                            Paging();
                            //this.dgAddStudent.DataContext = MainWindow.view;
                        }
                        else
                        {
                            MessageBox.Show("Student has not been updated.");
                        }
                    }
                    else
                    {
                        MessageBox.Show("Invalid email address.");
                    }
                }
                else
                {
                    MessageBox.Show("All fields are required.");
                }
            }
            catch (Exception)
            {

                MessageBox.Show("Invalid input.");
            }

        }

        private void txtUpdateStudentPhoneNum_ValueChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            txtUpdateStudentCategory.Items.Clear();
            if (int.Parse(txtUpdateStudentPhoneNum.Text) > 10 && int.Parse(txtUpdateStudentPhoneNum.Text) < 14)
            {
                txtUpdateStudentCategory.IsEnabled = true;
                txtUpdateStudentCategory.Items.Add("Grade 11 - Varsity");
                student.CategoryID = cat2;

            }
            else if (int.Parse(txtUpdateStudentPhoneNum.Text) < 11 && int.Parse(txtUpdateStudentPhoneNum.Text) >= 8)
            {
                txtUpdateStudentCategory.IsEnabled = true;
                //txtAddStudentCategory.IsEnabled = false;
                txtUpdateStudentCategory.Items.Add("Grade 8 - 10");
                student.CategoryID = cat1;
            }
            else if (int.Parse(txtUpdateStudentPhoneNum.Text) < 8)
            {
                txtUpdateStudentCategory.IsEnabled = true;
                //txtAddStudentCategory.IsEnabled = false;
                txtUpdateStudentCategory.Items.Add("Grade 6 - 7");
                student.CategoryID = cat3;
            }
        }
    }
}
