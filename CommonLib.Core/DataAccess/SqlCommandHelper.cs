using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace CommonLib.DataAccess
{
    public static class SqlCommandHelper
    {
        /// <summary>
        /// 將 SqlCommand 轉換為可執行的 SQL 語句
        /// </summary>
        public static string ToExecutableSql(this SqlCommand cmd)
        {
            var sb = new StringBuilder();

            // 先輸出 DECLARE + SET，每個參數都完整還原
            foreach (SqlParameter p in cmd.Parameters)
            {
                string sqlType = GetSqlDbTypeDeclaration(p);
                string value = GetSqlValueLiteral(p);

                sb.AppendLine($"DECLARE {p.ParameterName} {sqlType};");
                sb.AppendLine($"SET {p.ParameterName} = {value};");
            }

            sb.AppendLine();
            sb.AppendLine(cmd.CommandText);

            return sb.ToString();
        }

        private static string GetSqlDbTypeDeclaration(SqlParameter p)
        {
            // 根據 SqlDbType 建立變數型別定義
            switch (p.SqlDbType)
            {
                case SqlDbType.NVarChar:
                case SqlDbType.VarChar:
                case SqlDbType.NChar:
                case SqlDbType.Char:
                    string size = p.Size > 0 ? (p.Size == -1 ? "(MAX)" : $"({p.Size})") : "";
                    return $"{p.SqlDbType}{size}";

                case SqlDbType.Decimal:
                    return $"{p.SqlDbType}({p.Precision},{p.Scale})";
                case SqlDbType.Float:
                    return $"{p.SqlDbType}({p.Precision})";

                default:
                    return p.SqlDbType.ToString();
            }
        }

        private static string GetSqlValueLiteral(SqlParameter p)
        {
            if (p.Value == null || p.Value == DBNull.Value)
                return "NULL";

            switch (p.SqlDbType)
            {
                case SqlDbType.Bit:
                    return (Convert.ToBoolean(p.Value)) ? "1" : "0";

                case SqlDbType.Int:
                case SqlDbType.BigInt:
                case SqlDbType.SmallInt:
                case SqlDbType.TinyInt:
                case SqlDbType.Float:
                case SqlDbType.Real:
                case SqlDbType.Decimal:
                case SqlDbType.Money:
                case SqlDbType.SmallMoney:
                    return Convert.ToString(p.Value, System.Globalization.CultureInfo.InvariantCulture)!;

                case SqlDbType.Date:
                case SqlDbType.DateTime:
                case SqlDbType.DateTime2:
                case SqlDbType.SmallDateTime:
                case SqlDbType.Time:
                case SqlDbType.DateTimeOffset:
                    return $"'{Convert.ToDateTime(p.Value):yyyy-MM-dd HH:mm:ss.fff}'";

                case SqlDbType.UniqueIdentifier:
                    return $"'{p.Value}'";

                case SqlDbType.NVarChar:
                case SqlDbType.VarChar:
                case SqlDbType.NChar:
                case SqlDbType.Char:
                case SqlDbType.NText:
                case SqlDbType.Text:
                case SqlDbType.Xml:
                    return $"N'{p.Value.ToString()!.Replace("'", "''")}'";

                case SqlDbType.Binary:
                case SqlDbType.VarBinary:
                case SqlDbType.Image:
                    byte[] bytes = (byte[])p.Value;
                    return "0x" + BitConverter.ToString(bytes).Replace("-", "");

                default:
                    // 預設直接轉字串
                    return $"'{p.Value.ToString()!.Replace("'", "''")}'";
            }
        }
    }
}
