using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace CommonLib.DataAccess
{
    public static class ExtensionMethods
    {
        public static DataTable ToDataTable<T>(this IEnumerable<T> query)
        {
            DataTable tbl = new DataTable();
            PropertyInfo[] props = null;
            Type t = typeof(T);
            props = t.GetProperties();
            foreach (PropertyInfo pi in props)
            {
                Type colType = pi.PropertyType;
                //針對Nullable<>特別處理
                if (colType.IsGenericType && colType.GetGenericTypeDefinition() == typeof(Nullable<>))
                {
                    colType = colType.GetGenericArguments()[0];
                }
                //建立欄位
                tbl.Columns.Add(pi.Name, colType);
            }

            foreach (T item in query)
            {
                //if (props == null) //尚未初始化
                //{
                //    Type t = item.GetType();
                //    props = t.GetProperties();
                //    foreach (PropertyInfo pi in props)
                //    {
                //        Type colType = pi.PropertyType;
                //        //針對Nullable<>特別處理
                //        if (colType.IsGenericType && colType.GetGenericTypeDefinition() == typeof(Nullable<>))
                //        {
                //            colType = colType.GetGenericArguments()[0];
                //        }
                //        //建立欄位
                //        tbl.Columns.Add(pi.Name, colType);
                //    }
                //}
                DataRow row = tbl.NewRow();
                foreach (PropertyInfo pi in props)
                {
                    row[pi.Name] = pi.GetValue(item, null) ?? DBNull.Value;
                }
                tbl.Rows.Add(row);
            }
            return tbl;
        }

    }
}
