using ClosedXML.Excel;
using CommonLib.Core.Utility;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Linq.Expressions;
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
            PropertyInfo[]? props = BuildDataColumns(query, tbl);

            if (props != null)
            {
                foreach (T item in query)
                {

                    DataRow row = tbl.NewRow();
                    foreach (PropertyInfo pi in props)
                    {
                        row[pi.Name] = pi.GetValue(item, null) ?? DBNull.Value;
                    }
                    tbl.Rows.Add(row);
                }
            }

            return tbl;
        }

        public static DataTable ToDataTable<T>(this IEnumerable<T> query, DataTable tbl)
        {
            Type t = typeof(T);
            PropertyInfo[]? props = null;
            props = t.GetProperties();

            foreach (T item in query)
            {
                DataRow row = tbl.NewRow();
                foreach (PropertyInfo pi in props)
                {
                    if (tbl.Columns.Contains(pi.Name))
                    {
                        row[pi.Name] = pi.GetValue(item, null) ?? DBNull.Value;
                    }
                }
                tbl.Rows.Add(row);
            }
            return tbl;
        }

        public static PropertyInfo[]? BuildDataColumns<T>(this IEnumerable<T> query, DataTable table)
        {
            PropertyInfo[]? props = null;
            if (props == null) //尚未初始化
            {
                var item = query.FirstOrDefault();
                Type t = item?.GetType() ?? typeof(T);
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
                    table.Columns.Add(pi.Name, colType);
                }
            }

            return props;
        }

        public static PropertyInfo[] BuildDataColumns<T>(this IQueryable<T> query, DataTable table)
        {
            PropertyInfo[]? props = null;
            if (props == null) //尚未初始化
            {
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
                    table.Columns.Add(pi.Name, colType);
                }
            }

            return props;
        }

        public static IQueryable<TSource> OrderBy<TSource, TKey>(this IQueryable<TSource> source, Expression<Func<TSource, TKey>> keySelector, int? order, bool isOrdered = false)
        {
            if (order == 0)
                return source;

            if (isOrdered || source.Expression.ToString().Contains("OrderBy"))
            {
                IOrderedQueryable<TSource> items = (IOrderedQueryable<TSource>)source;
                return order > 0
                    ? items.ThenBy(keySelector)
                    : items.ThenByDescending(keySelector);
            }
            else
            {
                return order > 0
                    ? source.OrderBy(keySelector)
                    : source.OrderByDescending(keySelector);
            }
        }

        public static XLWorkbook ConvertToExcel(this DataSet ds)
        {
            XLWorkbook excel = new XLWorkbook();
            excel.Worksheets.Add(ds);
            return excel;
        }

        public static void PrepareExcelDownload<T>(this IEnumerable<T> items, string resultFile, Action<DataTable>? revise = null)
        {
            Task.Run(() =>
            {
                try
                {
                    using (DataSet ds = new DataSet())
                    {
                        DataTable dataTable = items.ToDataTable<T>();
                        if (revise != null)
                            revise(dataTable);
                        ds.Tables.Add(dataTable);
                        using (XLWorkbook excel = ds.ConvertToExcel())
                            excel.SaveAs(resultFile);
                    }
                }
                catch (Exception ex)
                {
                    CommonLib.Core.Utility.Logger.Error((object)ex);
                }
            });
        }

    }

}
