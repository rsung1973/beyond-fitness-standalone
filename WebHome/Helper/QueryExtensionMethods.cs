using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using Microsoft.EntityFrameworkCore;
using CommonLib.DataAccess;
using Microsoft.Extensions.Logging;

namespace WebHome.Helper
{
    public static class QueryExtensionMethods
    {


        public static DataSet GetDataSetResult(this GenericManager<BFDataContext> models, IQueryable items)
            
        {
            using (SqlCommand sqlCmd = (SqlCommand)models.GetCommand(items))
            {
                //sqlCmd.Connection = (SqlConnection)models.DataContext.Database.GetDbConnection();
                sqlCmd.Connection = (SqlConnection)models.DataContext.Connection;
                using (SqlDataAdapter adapter = new SqlDataAdapter(sqlCmd))
                {
                    DataSet ds = new DataSet();
                    adapter.Fill(ds);
                    return ds;
                }
            }
        }

        public static DataSet GetDataSetResult(this GenericManager<BFDataContext> models, IQueryable items, DataTable table)
            
        {
            using (SqlCommand sqlCmd = (SqlCommand)models.GetCommand(items))
            {
                //sqlCmd.Connection = (SqlConnection)models.DataContext.Database.GetDbConnection();
                sqlCmd.Connection = (SqlConnection)models.DataContext.Connection;
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

        public static ClosedXML.Excel.XLWorkbook GetExcelResult(this GenericManager<BFDataContext> models, IQueryable items, String tableName = null)
            
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
            try
            {
                for (int i = 0; i < ds.Tables.Count; i++)
                {
                    ds.Tables[i].TableName = $"_{ds.Tables[i].TableName}";
                }
                xls.Worksheets.Add(ds);
            }
            catch(Exception ex)
            {
                ApplicationLogging.CreateLogger("QueryExtensionMethods").LogError(ex, ex.Message);
            }
            return xls;
        }


    }
}