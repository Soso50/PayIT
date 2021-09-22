using BLL;
using System.Windows;
using System.Windows.Controls;
using TypeLibrary.Interfaces;
using TypeLibrary.Models;

namespace PayIT.Pages
{
    /// <summary>
    /// Interaction logic for pgeCourse.xaml
    /// </summary>
    public partial class pgeCourse : Page
    {
        IDBHandler db = new DBHandler();
        Course course = new Course();
        public pgeCourse()
        {
            InitializeComponent();
            dgAddCourse.ItemsSource = db.BLL_ListAllCourses();
            //dgUpdateCourse.ItemsSource = db.BLL_ListAllCourses();
            //cmbCourseUpate.DataContext = db.BLL_ListAllCourses();
        }

        private void btnAddCourse_Click(object sender, RoutedEventArgs e)
        {
            course.CourseName = txtAddCourseName.Text;


            if (db.BLL_InsertCourse(course))
            {
                MessageBox.Show("Course has been added.");
                dgAddCourse.ItemsSource = db.BLL_ListAllCourses();
                //dgUpdateCourse.ItemsSource = db.BLL_ListAllCourses();
                //cmbCourseUpate.DataContext = db.BLL_ListAllCourses();
            }
            else
            {
                MessageBox.Show("Course has not been added.");
            }
        }

        //private void btnUpdateCourse_Click(object sender, RoutedEventArgs e)
        //{
        //    course.CourseNo = int.Parse(cmbCourseUpate.SelectedValue.ToString());
        //    course.CourseName = cmbCourseUpate.SelectedValue.ToString();

        //    if (db.BLL_EditCourse(course))
        //    {
        //        MessageBox.Show("Course has been updated.");
        //        dgAddCourse.ItemsSource = db.BLL_ListAllCourses();
        //        dgUpdateCourse.ItemsSource = db.BLL_ListAllCourses();
        //        cmbCourseUpate.DataContext = db.BLL_ListAllCourses();
        //    }
        //    else
        //    {
        //        MessageBox.Show("Course has not been updated.");
        //    }
        //}

    }
}
