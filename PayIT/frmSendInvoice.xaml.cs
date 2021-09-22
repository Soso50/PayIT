using BLL;
using Microsoft.Win32;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Windows;
using TypeLibrary.Interfaces;
using TypeLibrary.ViewModels;

namespace PayIT
{
    /// <summary>
    /// Interaction logic for frmSendInvoice.xaml
    /// </summary>
    public partial class frmSendInvoice : Window
    {
        ArrayList alAttachments;
        OpenFileDialog openFileDialog = new OpenFileDialog();
        string SendFrom = "chelseapatterson@k2maths.co.za";
        string message = "";
        IDBHandler db = new DBHandler();
        public frmSendInvoice()
        {
            InitializeComponent();
            cmbEmail.DataContext = db.BLL_EmailDisplay();
        }

        private async void btnSend_Click(object sender, RoutedEventArgs e)
        {
            if (String.IsNullOrEmpty(cmbEmail.Text))
            {
                MessageBox.Show("Missing recipient address.", "Email Error");
                return;
            }

            if (String.IsNullOrEmpty(SendFrom))
            {
                MessageBox.Show("Missing sender address.", "Email Error");
                return;
            }

            if (String.IsNullOrEmpty("Invoice"))
            {
                MessageBox.Show("Missing subject line.", "Email Error");
                return;
            }



            string[] arr = txtAttachments.Text.Split(';');
            alAttachments = new ArrayList();
            for (int i = 0; i < arr.Length; i++)
            {
                if (!String.IsNullOrEmpty(arr[i].ToString().Trim()))
                {
                    alAttachments.Add(arr[i].ToString().Trim());
                }
            }

            // if there are attachments, send message with 
            // SendMessageWithAttachment call, else use the
            // standard SendMessage call

            message = String.Format("Dear {0} <br/><br/>Please see attached your latest invoice from K<sup>2</sup> Maths. <br/><br/>Kind Regards<br/>Chelsea Patterson<br/>K<sup>2</sup> Maths<br/>(Receptionist)", "Parent/Guardian");
            if (alAttachments.Count > 0)
            {
                string result = await EmailHelper.SendMessageWithAttachment(cmbEmail.Text,
                    SendFrom, "Invoice", message, alAttachments);

                MessageBox.Show(result, "Email Transmittal");
            }
            else
            {
                string result = await EmailHelper.SendMessageWithAttachment(cmbEmail.Text,
                     SendFrom, "Invoice", "testing",
                     alAttachments);

                MessageBox.Show("Email Transmittal");
            }
        }

        private void btnAttachment_Click(object sender, RoutedEventArgs e)
        {
            if (openFileDialog.ShowDialog() == true)
            {
                try
                {
                    string[] arr = openFileDialog.FileNames;
                    alAttachments = new ArrayList();
                    txtAttachments.Text = string.Empty;
                    alAttachments.AddRange(arr);

                    foreach (string s in alAttachments)
                    {
                        txtAttachments.Text += s + "; ";
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message, "Error");
                }
            }
        }

        private void btnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Hide();
        }

        private async void btnSend_Batch_Click(object sender, RoutedEventArgs e)
        {
            #region MyRegion
            IDBHandler dBHandler = new DBHandler();
            spEmailAddress spEmail = new spEmailAddress();
            List<spListStudents> list = dBHandler.BLL_ListStudents();
            string email;

            foreach (spListStudents item in dBHandler.BLL_ListStudents())
            {
                if (String.Format(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + @"\PayIT\{0}.pdf", item.Fullname) != null)
                {
                    //Console.WriteLine("Full name: {0} \nEmail: {1}\n\n", item.Fullname, item.EmailAddress);
                    email = item.EmailAddress;
                    await EmailHelper.SendMessages(email, item.Fullname);
                }
                else
                {
                    break;
                }
            }
            #endregion
        }
    }
}
