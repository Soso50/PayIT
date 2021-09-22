using System;
using System.Collections;
using System.Net;
using System.Net.Mail;
using System.Net.Mime;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;
namespace BLL
{
    public class EmailHelper
    {
        public static void EmailInvoice()
        {
            var smtpClient = new SmtpClient("mail.k2maths.co.za")
            {
                Port = 587,
                Credentials = new NetworkCredential("chelseapatterson@k2maths.co.za", "Zk1^{i3xw{?G"),
                EnableSsl = true,
            };

            string bodyText = "<p>**PLEASE DO NOT RESPOND TO THIS E-MAIL**</p>" + "<p1>Dear Customer </p1>" + "<p>Kindly find your lastest invoice in the attachments.</p>" + "<p>Kind Regards<br/>Low Key IT Team</p>";

            var mailMessage = new MailMessage
            {
                From = new MailAddress("chelseapatterson@k2maths.co.za"),
                Subject = "Invoice",
                Body = bodyText,
                IsBodyHtml = true,
            };

            var attachment = new Attachment(@"C:\Users\AJAX\Desktop\Invoice.pdf", MediaTypeNames.Application.Pdf);
            mailMessage.Attachments.Add(attachment);

            mailMessage.To.Add("ajax45@live.com");

            smtpClient.Send(mailMessage);

        }
        /// <summary>
        /// Transmit an email message with
        /// attachments
        /// </summary>
        /// <param name="sendTo">Recipient Email Address</param>
        /// <param name="sendFrom">Sender Email Address</param>
        /// <param name="sendSubject">Subject Line Describing Message</param>
        /// <param name="sendMessage">The Email Message Body</param>
        /// <param name="attachments">A string array pointing to the location of each attachment</param>
        /// <returns>Status Message as String</returns>
        /// 

        public static string SendMessage(string sendTo, string sendFrom,
         string sendSubject, string sendMessage, string fname)
        {
            try
            {
                // validate the email address
                bool bTest = ValidateEmailAddress(sendTo);

                // if the email address is bad, return message
                if (bTest == false)
                    return "Invalid recipient email address: " + sendTo;
                string messageText = String.Format("Dear {0} <br/><br/>Please see attached your latest invoice from K<sup>2</sup> Maths. <br/><br/>Kind Regards<br/>Chelsea Patterson<br/>K<sup>2</sup> Maths<br/>(Receptionist)", fname);

                // create the email message 
                //MailMessage message = new MailMessage(
                //   sendFrom,
                //   sendTo,
                //   sendSubject,
                //   sendMessage);
                var message = new MailMessage
                {
                    From = new MailAddress("chelseapatterson@k2maths.co.za"),
                    Subject = "Invoice",
                    Body = messageText,
                    IsBodyHtml = true,
                };
                // create smtp client at mail server location
                ////SmtpClient client = new SmtpClient("smtp.lowkeyit.co.za");

                ////client.DeliveryMethod = SmtpDeliveryMethod.Network;
                ////client.UseDefaultCredentials = true;
                ////client.EnableSsl = true;
                ////client.Host = "smtp.lowkeyit.co.za";
                ////client.Port = 587;
                ////client.Credentials = new NetworkCredential("info@lowkeyit.co.za", "447X5ZgIKLMYxO6g.");

                // add credentials
                //client.UseDefaultCredentials = false;

                // send message
                var client = new SmtpClient("smtp.lowkeyit.co.za")
                {
                    Port = 587,
                    Credentials = new NetworkCredential("info@lowkeyit.co.za", "447X5ZgIKLMYxO6g"),
                    EnableSsl = true,
                };
                client.Send(message);

                return "Message sent to " + sendTo + " at " + DateTime.Now.ToString() + ".";
            }
            catch (Exception ex)
            {
                return ex.Message.ToString();
            }
        }

        public static async Task SendMessages(string SendTo, string fname)
        {
            string SendFrom = "chelseapatterson@k2maths.co.za";
            string message = "";
            ArrayList alAttachments;



            message = String.Format("Dear {0} <br/><br/>Please see attached your latest invoice from K<sup>2</sup> Maths. <br/><br/>Kind Regards<br/>Chelsea Patterson<br/>K<sup>2</sup> Maths<br/>(Receptionist)", fname);

            var mailMessage = new MailMessage
            {
                From = new MailAddress("chelseapatterson@k2maths.co.za"),
                Subject = "Invoice",
                Body = message,
                IsBodyHtml = true,
            };

            string txtAttachments = String.Format(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + @"\PayIT\{0}.pdf", fname);
            string[] arr = txtAttachments.Split(';');
            alAttachments = new ArrayList();

            for (int j = 0; j < arr.Length; j++)
            {
                if (!String.IsNullOrEmpty(arr[j].ToString().Trim()))
                {
                    alAttachments.Add(arr[j].ToString().Trim());
                }
            }

            string result = await EmailHelper.SendMessageWithAttachment(SendTo, SendFrom, "Invoice", message, alAttachments);
            MessageBox.Show(result, "Email Transmittal");


        }

        public static async Task<string> SendMessageWithAttachment(string sendTo, string sendFrom, string sendSubject, string sendMessage, ArrayList attachments)
        {
            try
            {
                // validate email address
                bool bTest = ValidateEmailAddress(sendTo);

                if (bTest == false)
                    return "Invalid recipient email address: " + sendTo;

                // Create the basic message
                var message = new MailMessage
                {
                    From = new MailAddress(sendFrom),

                    Subject = sendSubject,
                    Body = sendMessage,
                    IsBodyHtml = true,
                };
                message.To.Add(sendTo);
                // The attachments arraylist should point to a file location where
                // the attachment resides - add the attachments to the message
                foreach (string attach in attachments)
                {
                    Attachment attached = new Attachment(attach, MediaTypeNames.Application.Octet);
                    message.Attachments.Add(attached);
                }

                // create smtp client at mail server location
                var client = new SmtpClient("mail.k2maths.co.za")
                {
                    Port = 587,
                    Credentials = new NetworkCredential("chelseapatterson@k2maths.co.za", "Zk1^{i3xw{?G"),
                    EnableSsl = true,
                };

                // send message
                await Task.Run(() => client.Send(message));

                return await Task.Run(() => "Message sent to " + sendTo + " at " + DateTime.Now.ToString() + ".");
            }
            catch (Exception ex)
            {
                return await Task.Run(() => ex.Message.ToString());
            }
        }

        /// <summary>
        /// Confirm that an email address is valid
        /// in format
        /// </summary>
        /// <param name="emailAddress">Full email address to validate</param>
        /// <returns>True if email address is valid</returns>
        public static bool ValidateEmailAddress(string emailAddress)
        {
            try
            {
                string TextToValidate = emailAddress;
                Regex expression = new Regex(@"\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}");

                // test email address with expression
                if (expression.IsMatch(TextToValidate))
                {
                    // is valid email address
                    return true;
                }
                else
                {
                    // is not valid email address
                    return false;
                }
            }
            catch (Exception)
            {
                throw;
            }
        }
    }
}
