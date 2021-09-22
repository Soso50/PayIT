using System;
using System.Security.Cryptography;
using System.Text;

namespace BLL
{
    public class HashPasswordHelper
    {
        public static string HashPassword(string password)
        {
            SHA1CryptoServiceProvider sha1 = new SHA1CryptoServiceProvider();
            byte[] passwordByte = Encoding.ASCII.GetBytes(password);
            byte[] crypted = sha1.ComputeHash(passwordByte);
            return Convert.ToBase64String(crypted);
        }
    }
}
