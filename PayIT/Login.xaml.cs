using BLL;
using System;
using System.IO;
using System.Windows;

namespace PayIT
{
    /// <summary>
    /// Interaction logic for Login.xaml
    /// </summary>
    public partial class Login : Window
    {
        DBHandler bll = new DBHandler();
        public static string adminUser = "admin".ToLower();
        public Login()
        {
            InitializeComponent();
            if (!Directory.Exists(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + @"\PayIT"))
            {
                Directory.CreateDirectory(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + @"\PayIT");

            }
            else
            {
                return;
            }
        }

        private void Login_Click(object sender, RoutedEventArgs e)
        {


            if (bll.BLL_Login(txtUsername.Text, txtPassword.Password) != null)
            {
                
              
                    adminUser = txtUsername.Text;
                    MainWindow n = new MainWindow();
                    n.btnEportDB.IsEnabled = true;
                    this.Close();
                    n.Show();
               
                

            }
            else
            {
                MessageBox.Show("Credentials are incorrect or does not exist");
            }



        }


    }
}
