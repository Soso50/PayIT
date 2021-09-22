using BLL;
using DAL;
using System;
using System.Windows;
using System.Windows.Controls;
using TypeLibrary.Interfaces;
using TypeLibrary.ViewModels;

namespace PayIT
{
    /// <summary>
    /// Interaction logic for frmInvoice.xaml
    /// </summary>
    public partial class frmInvoice : Window
    {
        IDBHandler db = new DBHandler();
        spAttendeesDisplay attendeesDisplay = new spAttendeesDisplay();

        public frmInvoice()
        {
            InitializeComponent();

            try
            {


                if (MainWindow.flagDate == true)
                {
                    if (MainWindow.firstname == "Cole Honey")
                    {
                        McDataGrid.DataContext = db.BLL_ColeHoneyInvoiceDisplayByDate(MainWindow.firstname, MainWindow.startDate);
                        lvDataBinding.ItemsSource = db.BLL_ColeHoneyInvoiceDisplayByDate(MainWindow.firstname, MainWindow.startDate);
                        MainWindow.totalSum = DBAccess.total;
                        txtIssueDate.Text = DateTime.Now.ToString();
                        txtTotal.Text = MainWindow.totalSum.ToString("C");
                    }
                    else if (MainWindow.firstname == "Kelsey Froneman" || MainWindow.firstname == "Mia Deacon" || MainWindow.firstname == "Andrea Ambler" || MainWindow.firstname == "Abby Cornel")
                    {
                        McDataGrid.DataContext = db.BLL_SpecialByDate(MainWindow.firstname, MainWindow.startDate);
                        lvDataBinding.ItemsSource = db.BLL_SpecialByDate(MainWindow.firstname, MainWindow.startDate);
                        MainWindow.totalSum = DBAccess.total;
                        txtIssueDate.Text = DateTime.Now.ToString();
                        txtTotal.Text = MainWindow.totalSum.ToString("C");
                    }
                    else
                    {
                        McDataGrid.DataContext = db.BLL_InvoiceSearchByDate(MainWindow.firstname, MainWindow.startDate);
                        lvDataBinding.ItemsSource = db.BLL_InvoiceSearchByDate(MainWindow.firstname, MainWindow.startDate);
                        MainWindow.totalSum = DBAccess.total;
                        txtIssueDate.Text = DateTime.Now.ToString();
                        txtTotal.Text = MainWindow.totalSum.ToString("C");
                    }
                }
                else if (MainWindow.flagName == true)
                {
                    if (MainWindow.firstname == "Cole Honey")
                    {
                        McDataGrid.DataContext = db.BLL_ColeHoneyInvoiceDisplay(MainWindow.firstname);
                        lvDataBinding.ItemsSource = db.BLL_ColeHoneyInvoiceDisplay(MainWindow.firstname);
                        MainWindow.totalSum = DBAccess.total;
                        txtIssueDate.Text = DateTime.Now.ToString();
                        txtTotal.Text = MainWindow.totalSum.ToString("C");
                    }
                    else if (MainWindow.firstname == "Kelsey Froneman" || MainWindow.firstname == "Mia Deacon" || MainWindow.firstname == "Andrea Ambler" || MainWindow.firstname == "Abby Cornel")
                    {
                        McDataGrid.DataContext = db.BLL_SpecialInvoice(MainWindow.firstname);
                        lvDataBinding.ItemsSource = db.BLL_SpecialInvoice(MainWindow.firstname);
                        MainWindow.totalSum = DBAccess.total;
                        txtIssueDate.Text = DateTime.Now.ToString();
                        txtTotal.Text = MainWindow.totalSum.ToString("C");
                    }
                    else
                    {
                        McDataGrid.DataContext = db.BLL_InvoiceSearch(MainWindow.firstname);
                        lvDataBinding.ItemsSource = db.BLL_InvoiceSearch(MainWindow.firstname);
                        MainWindow.totalSum = DBAccess.total;
                        txtIssueDate.Text = DateTime.Now.ToString();
                        txtTotal.Text = MainWindow.totalSum.ToString("C");
                    }

                }

            }
            catch (Exception ex)
            {

                MessageBox.Show(ex.Message);
            }

            txtDueDate.Text = DateHelper.GetLastDayOfMonth(DateTime.Now).ToString("dd/MM/yyyy");
            //dataGrid.DataContext = dt;
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {

            try
            {
                this.IsEnabled = false;
                PrintDialog printDialog = new PrintDialog();
                if (printDialog.ShowDialog() == true)
                {
                    printDialog.PrintVisual(print, "invoice");
                }
            }
            finally
            {
                this.IsEnabled = true;
            }
        }

        private void btnInvoice_Closed(object sender, EventArgs e)
        {
            DBAccess.total = 0;
            MainWindow.flagDate = false;
            MainWindow.flagName = false;
            MainWindow main = new MainWindow();
            this.Hide();
            main.Show();


        }

    }
}

