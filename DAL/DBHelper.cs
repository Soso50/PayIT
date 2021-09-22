using MySql.Data.MySqlClient;
using System.Configuration;
using System.Data;
using System.Threading.Tasks;

namespace DAL
{
    internal class DBHelper
    {
        private static string connString = ConfigurationManager.ConnectionStrings["payItCon"].ConnectionString;

        #region ParamSelect()
        internal static DataTable ParamSelect(string commandName, CommandType cmdType,
            MySqlParameter[] pars)
        {
            DataTable table = new DataTable();
            using (MySqlConnection con = new MySqlConnection(connString))
            {
                using (MySqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandType = cmdType;
                    cmd.CommandText = commandName;
                    cmd.Parameters.AddRange(pars);

                    try
                    {
                        if (con.State != ConnectionState.Open)
                        {
                            con.Open();
                        }
                        using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                        {
                            da.Fill(table);
                        }
                    }
                    catch
                    {
                        throw;
                    }
                }
            }
            return table;
        }
        #endregion ParamSelect()

        #region NonQuery()
        public static bool NonQuery(string commandName, CommandType cmdType,
            MySqlParameter[] pars)
        {
            int result = 0;
            using (MySqlConnection con = new MySqlConnection(connString))
            {
                using (MySqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandType = cmdType;
                    cmd.CommandText = commandName;
                    cmd.Parameters.AddRange(pars);

                    try
                    {
                        if (con.State != ConnectionState.Open)
                        {
                            con.Open();
                        }
                        result = cmd.ExecuteNonQuery();
                    }
                    catch
                    {
                        throw;
                    }
                }
            }
            return result > 0;
        }

        public static async Task<bool> NonQueryAsync(string commandName, CommandType cmdType,
           MySqlParameter[] pars)
        {
            int result = 0;
            using (MySqlConnection con = new MySqlConnection(connString))
            {
                using (MySqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandType = cmdType;
                    cmd.CommandText = commandName;
                    cmd.Parameters.AddRange(pars);

                    try
                    {
                        if (con.State != ConnectionState.Open)
                        {
                            await con.OpenAsync();
                        }
                        result = await cmd.ExecuteNonQueryAsync();
                    }
                    catch
                    {
                        throw;
                    }
                }
            }
            return result > 0;
        }
        public static bool NonQuery(string commandName, CommandType cmdType
           )
        {
            int result = 0;
            using (MySqlConnection con = new MySqlConnection(connString))
            {
                using (MySqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandType = cmdType;
                    cmd.CommandText = commandName;


                    try
                    {
                        if (con.State != ConnectionState.Open)
                        {
                            con.Open();
                        }
                        result = cmd.ExecuteNonQuery();
                    }
                    catch
                    {
                        throw;
                    }
                }
            }
            return result > 0;
        }

        #endregion NonQuery()

        #region Select()
        public static DataTable Select(string commandName, CommandType cmdType)
        {
            DataTable table = null;
            using (MySqlConnection con = new MySqlConnection(connString))
            {
                using (MySqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandType = cmdType;
                    cmd.CommandText = commandName;

                    try
                    {
                        if (con.State != ConnectionState.Open)
                        {
                            con.Open();
                        }
                        using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                        {
                            table = new DataTable();
                            da.Fill(table);
                        }
                    }
                    catch
                    {
                        throw;
                    }
                }
            }
            return table;
        }
        #endregion Select()

        #region Reader
        //public static DataTable SearchSelect(string commandName, CommandType cmdType)
        //{
        //    DataTable table = null;
        //    using (MySqlConnection con = new MySqlConnection(connString))
        //    {
        //        using (MySqlCommand cmd = con.CreateCommand())
        //        {
        //            cmd.CommandType = cmdType;
        //            cmd.CommandType = cmdType;
        //            cmd.CommandText = commandName;

        //            try
        //            {
        //                if (con.State != ConnectionState.Open)
        //                {
        //                    con.Open();
        //                }
        //                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
        //                {
        //                    table = new DataTable();
        //                    da.Fill(table);
        //                }
        //            }
        //            catch
        //            {
        //                throw;
        //            }
        //        }
        //    }
        //    return table;
        //}
        #endregion
        //begin
        #region NonQuery()

        public static object Scalar(string commandName, CommandType cmdType,
            MySqlParameter[] pars)
        {
            int result = 0;
            object scalarResult;
            using (MySqlConnection con = new MySqlConnection((connString)))
            {
                using (MySqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandType = cmdType;
                    cmd.CommandText = commandName;
                    cmd.Parameters.AddRange(pars);

                    try
                    {
                        if (con.State != ConnectionState.Open)
                        {
                            con.Open();
                        }

                        scalarResult = cmd.ExecuteScalar();


                    }
                    catch
                    {
                        throw;
                    }
                }
            }

            return scalarResult;
        }
        #endregion NonQuery()
        //close
    }
}
