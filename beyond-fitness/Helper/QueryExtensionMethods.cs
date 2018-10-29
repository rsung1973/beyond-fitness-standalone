using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web;
using Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using WebHome.Properties;

namespace WebHome.Helper
{
    public static class QueryExtensionMethods
    {
        public static DataSet GetDataSetResult<TEntity>(this ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return models.GetDataSetResult(models.Items);
        }

        public static ClosedXML.Excel.XLWorkbook GetExcelResult<TEntity>(this ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return models.GetExcelResult(models.Items);
        }

        public static DataSet GetDataSetResult<TEntity>(this ModelSource<TEntity> models, IQueryable items)
            where TEntity : class, new()
        {
            using (SqlCommand sqlCmd = (SqlCommand)models.GetCommand(items))
            {
                sqlCmd.Connection = (SqlConnection)models.GetDataContext().Connection;
                using (SqlDataAdapter adapter = new SqlDataAdapter(sqlCmd))
                {
                    DataSet ds = new DataSet();
                    adapter.Fill(ds);
                    return ds;
                }
            }
        }

        public static DataSet GetDataSetResult<TEntity>(this ModelSource<TEntity> models, IQueryable items, DataTable table)
            where TEntity : class, new()
        {
            using (SqlCommand sqlCmd = (SqlCommand)models.GetCommand(items))
            {
                sqlCmd.Connection = (SqlConnection)models.GetDataContext().Connection;
                using (SqlDataAdapter adapter = new SqlDataAdapter(sqlCmd))
                {
                    int colCount = table.Columns.Count;
                    adapter.Fill(table);
                    if (colCount > 0)
                    {
                        while (table.Columns.Count > colCount)
                        {
                            table.Columns.RemoveAt(table.Columns.Count - 1);
                        }
                    }
                    return table.DataSet;
                }
            }
        }

        public static ClosedXML.Excel.XLWorkbook GetExcelResult<TEntity>(this ModelSource<TEntity> models, IQueryable items, String tableName = null)
            where TEntity : class, new()
        {
            using (DataSet ds = models.GetDataSetResult(items))
            {
                if (tableName != null)
                    ds.Tables[0].TableName = ds.DataSetName = tableName;
                return ConvertToExcel(ds);
            }
        }

        public static ClosedXML.Excel.XLWorkbook ConvertToExcel(this DataSet ds)
        {
            ClosedXML.Excel.XLWorkbook xls = new ClosedXML.Excel.XLWorkbook();
            xls.Worksheets.Add(ds);
            return xls;
        }


    }
}