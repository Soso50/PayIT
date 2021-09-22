using BLL;
using System.Windows;
using System.Windows.Controls;
using TypeLibrary.Interfaces;
using TypeLibrary.Models;
using TypeLibrary.ViewModels;

namespace PayIT
{
    /// <summary>
    /// Interaction logic for User.xaml
    /// </summary>
    public partial class pgeUser : Page
    {
        IDBHandler db = new DBHandler();
        Users user = new Users();
        spListUsers tutor = new spListUsers();
        public pgeUser()
        {
            InitializeComponent();
            dgAddTutor.ItemsSource = db.BLL_ListUsers();
            dgUpdateTutor.ItemsSource = db.BLL_ListUsers();
            dgViewTutor.ItemsSource = db.BLL_ListUsers();
        }

        private void btnAddTutor_Click(object sender, RoutedEventArgs e)
        {
            if (txtAddTutorUserName.Text != "" && txtAddTutorPassword.Password != "" && txtAddTutorName.Text != "" && txtAddTutorSurName.Text != "")
            {
                user.Username = txtAddTutorUserName.Text;
                user.Password = txtAddTutorPassword.Password;
                user.Firstname = txtAddTutorName.Text;
                user.Surname = txtAddTutorSurName.Text;

                if (db.BLL_IsUserExist(txtAddTutorUserName.Text) == null)
                {
                    //db.BLL_IsUserExist(txtAddTutorUserName.Text);

                    if (db.BLL_InsertUser(user))
                    {
                        MessageBox.Show("Tutor Has been added.");
                        dgAddTutor.ItemsSource = db.BLL_ListUsers();
                        dgUpdateTutor.ItemsSource = db.BLL_ListUsers();
                        dgViewTutor.ItemsSource = db.BLL_ListUsers();
                    }
                }
                else
                {
                    MessageBox.Show("This tutor already exists.");
                }
            }
            else
            {
                MessageBox.Show("All fields are required.");
            }

        }

        private void txtViewTutor_TextChanged(object sender, TextChangedEventArgs e)
        {
            dgViewTutor.ItemsSource = db.BLL_SearchUsers(txtViewTutor.Text);
        }


        private void btnUpdateTutor_Click(object sender, RoutedEventArgs e)
        {
            if (txtUpdateTutorUserName.Text != "" && txtUpdateTutorPassword.Password != "" && txtUpdateTutorName.Text != "" && txtUpdateTutorSurName.Text != "")
            {
                user.Username = txtUpdateTutorUserName.Text;
                user.Password = txtUpdateTutorPassword.Password;
                user.Firstname = txtUpdateTutorName.Text;
                user.Surname = txtUpdateTutorSurName.Text;

                if (db.BLL_EditUser(user))
                {
                    MessageBox.Show("Tutor Has been updated.");
                    dgAddTutor.ItemsSource = db.BLL_ListUsers();
                    dgUpdateTutor.ItemsSource = db.BLL_ListUsers();
                    dgViewTutor.ItemsSource = db.BLL_ListUsers();
                }
            }
            else
            {
                MessageBox.Show("All fields are required.");
            }


        }
    }
}
