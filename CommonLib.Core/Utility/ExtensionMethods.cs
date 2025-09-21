using CommonLib.Core.Helper;
using CommonLib.PlugInAdapter;
using CommonLib.Utility;
using DocumentFormat.OpenXml.Bibliography;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.WebUtilities;
using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.Serialization;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Xml;
using System.Xml.Linq;
using System.Xml.Serialization;
using System.Xml.XPath;

namespace CommonLib.Core.Utility
{
    public static class ExtensionMethods
    {
        public static void ConvertHtmlToPDF(this String htmlFile, String pdfFile, double timeOutInMinute)
        {
            lock (typeof(ExtensionMethods))
            {
                PlugInHelper.GetPdfUtility().ConvertHtmlToPDF(htmlFile, pdfFile, timeOutInMinute);
            }
        }

        public static void SaveAs(this IFormFile formFile,String path)
        {
            using FileStream stream = new(path, FileMode.Create);
            formFile.CopyTo(stream);
        }

        public static async Task SaveAsAsync(this HttpRequest Request, String? path = null,bool includeHeader = true)
        {
            //Request.EnableBuffering();
            //Request.Body.Position = 0;
            //using var streamReader = new StreamReader(Request.Body);
            //string bodyContent = await streamReader.ReadToEndAsync();

            Request.Body.Position = 0;
            if(path != null)
            {
                using (FileStream fs = System.IO.File.Create(path))
                {
                    if (includeHeader)
                    {
                        using (StreamWriter writer = new StreamWriter(fs, leaveOpen: true))
                        {
                            foreach (var h in Request.Headers)
                            {
                                writer.WriteLine($"{h.Key}: {h.Value}");
                            }
                            writer.WriteLine();
                        }
                    }
                    await Request.Body.CopyToAsync(fs);
                }
            }
            else
            {
                StringBuilder sb = new StringBuilder();
                if (includeHeader)
                {
                    foreach (var h in Request.Headers)
                    {
                        sb.AppendLine($"{h.Key}: {h.Value}");
                    }
                    sb.AppendLine();
                }

                sb.AppendLine(await Request.GetRequestBodyAsync());
                FileLogger.Logger.Debug(sb.ToString());
            }

                Request.Body.Position = 0;
        }

        public static async Task<byte[]> GetRequestBytesAsync(this HttpRequest Request)
        {
            Request.Body.Position = 0;
            using (MemoryStream fs = new MemoryStream())
            {
                await Request.Body.CopyToAsync(fs);
                Request.Body.Position = 0;
                return fs.ToArray();
            }
        }

        public static async Task<MemoryStream> GetRequestStreamAsync(this HttpRequest Request)
        {
            Request.Body.Position = 0;
            MemoryStream fs = new MemoryStream();

            await Request.Body.CopyToAsync(fs);
            Request.Body.Position = 0;
            fs.Seek(0, SeekOrigin.Begin);
            return fs;
        }

        public static async Task<String> GetRequestBodyAsync(this HttpRequest Request)
        {
            Request.Body.Position = 0;
            StreamReader reader = new StreamReader(Request.Body);
            var data = await reader.ReadToEndAsync();
            Request.Body.Position = 0;
            return data;
        }

        public static async Task WriteFileAsDownloadAsync(this HttpResponse Response, string fileName)
        {
            await Response.WriteFileAsDownloadAsync(fileName, null, false);
        }

        public static async Task WriteFileAsDownloadAsync(this HttpResponse response, string fileName, string? outputName, bool deleteAfterDownload, string contentType = "application/octet-stream")
        {
            // 檢查檔案是否存在
            if (!File.Exists(fileName))
            {
                response.StatusCode = StatusCodes.Status404NotFound;
                await response.WriteAsync("File not found.");
                return;
            }

            // 設定回應的 Content-Type
            response.ContentType = contentType;

            // 設定 Content-Disposition 標頭以下載檔案
            var contentDisposition = new System.Net.Mime.ContentDisposition
            {
                FileName = outputName,
                Inline = false // 設定為 false 以下載檔案
            };
            response.Headers.Append("Content-Disposition", contentDisposition.ToString());

            // 將檔案內容寫入回應流
            using (var fileStream = new FileStream(fileName, FileMode.Open, FileAccess.Read))
            {
                await fileStream.CopyToAsync(response.Body);
            }

            // 如果設定為下載後刪除檔案，則刪除檔案
            if (deleteAfterDownload)
            {
                File.Delete(fileName);
            }
        }

        public static async void DumpFileAsDownloadAsync(this HttpResponse Response, string fileName, String outputName)
        {
            await Response.WriteFileAsDownloadAsync(fileName, outputName, false);
        }

        public static async void DumpFileAsDownloadAsync(this HttpResponse Response, string fileName, String outputName, bool deleteAfterDownload)
        {
            await Response.WriteFileAsDownloadAsync(fileName, outputName, deleteAfterDownload);
        }

        public static async Task CsvDownloadAsync(this HttpResponse Response, IEnumerable<Object> items, String outputName, Encoding? encoding = null, String contentType = "application/octet-stream")
        {
            Response.Clear();
            Response.Headers.Clear();
            Response.Headers.Append("Cache-control", "max-age=1");
            Response.ContentType = String.IsNullOrEmpty(contentType) ? "application/octet-stream" : contentType;
            Response.Headers.Append("Content-Disposition", String.Format("attachment;filename={0}", HttpUtility.UrlEncode(!String.IsNullOrEmpty(outputName) ? outputName : DateTime.Today.ToString("yyyy-MM-dd") + ".csv")));

            using (FileBufferingWriteStream output = new FileBufferingWriteStream())
            {
                Csv.Serialization.CsvSerializer<Object> serializer = new Csv.Serialization.CsvSerializer<object>(items.First(), false)
                {
                    UseLineNumbers = false,
                    UseTextQualifier = false,
                    CsvEncodig = encoding ?? Encoding.UTF8,
                };
                serializer.Serialize(output, items);
                await output.DrainBufferAsync(Response.Body);
            }
        }

        public static async void CsvDownloadAsync(this HttpResponse Response, IEnumerable<Object> items, String outputName, String contentType = "application/octet-stream")
        {
            await CsvDownloadAsync(Response, items, outputName, null, contentType);
        }

        public static void RunForever(this Action doSomething, int milliSeconds, bool runImmediately = true)
        {
            Task t;
            if (runImmediately)
            {
                t = Task.Run(() =>
                {
                    doSomething();
                });

            }
            else
            {
                t = Task.Delay(milliSeconds).ContinueWith(ts1 =>
                {
                    doSomething();
                });
            }

            t = t.ContinueWith(ts =>
            {
                if (ts.IsFaulted)
                {
                    FileLogger.Logger.Error(ts.Exception);
                }

                Task.Delay(milliSeconds).ContinueWith(ts1 =>
                {
                    doSomething.RunForever(milliSeconds);
                });
            });
        }

        public static Nullable<T> GetData<T>(this DataRow row, String columnName)
            where T : struct
        {
            if (row.IsNull(columnName))
            {
                return new Nullable<T>();
            }
            else if (row[columnName] is T)
            {
                return (T)row[columnName];
            }
            else
            {
                try
                {
                    if (row[columnName] is String)
                    {
                        String val = (row[columnName] as String).GetEfficientString();
                        if (val == null)
                        {
                            return new Nullable<T>();
                        }
                        else
                        {
                            return (T)Convert.ChangeType(val, typeof(T));
                        }
                    }
                    return (T)Convert.ChangeType(row[columnName], typeof(T));
                }
                catch (Exception ex)
                {
                    FileLogger.Logger.Error(ex);
                    return new Nullable<T>();
                }
            }
        }

        public static Nullable<T> GetData<T>(this DataRow row, int index)
            where T : struct
        {
            if (row.IsNull(index))
            {
                return new Nullable<T>();
            }
            else if (row[index] is T)
            {
                return (T)row[index];
            }
            else
            {
                try
                {
                    if (row[index] is String)
                    {
                        String val = (row[index] as String).GetEfficientString();
                        if (val == null)
                        {
                            return new Nullable<T>();
                        }
                        else
                        {
                            return (T)Convert.ChangeType(val, typeof(T));
                        }
                    }
                    return (T)Convert.ChangeType(row[index], typeof(T));
                }
                catch (Exception ex)
                {
                    FileLogger.Logger.Error(ex);
                    return new Nullable<T>();
                }
            }
        }
        public static bool CanReadFile(this string filePath)
        {
            if (File.Exists(filePath))
            {
                try
                {
                    using (FileStream fileStream = File.OpenRead(filePath))
                    {
                        fileStream.Close();
                        return true;
                    }
                }
                catch (Exception ex)
                {
                    FileLogger.Logger.Error(ex);
                }
            }
            return false;
        }
        public static string? SaveUploadFile(this IFormFile file, string storePath, string ext)
        {
            if (file != null)
            {
                string fileName = $"{System.Guid.NewGuid()}{ext}";
                file.SaveAs(Path.Combine(storePath, fileName));
                return fileName;
            }
            return null;
        }

        public static Bitmap GetCode39(this string strSource, bool printCode, int? wide = null, int? narrow = null, int? height = null, int? margin = null)
        {
            int x = margin ?? 5; //左邊界 
            int y = 0; //上邊界 
            int WidLength = wide ?? 2; //粗BarCode長度 
            int NarrowLength = narrow ?? 1; //細BarCode長度 
            int BarCodeHeight = height ?? 24; //BarCode高度 
            int intSourceLength = strSource.Length;
            string strEncode = "010010100"; //編碼字串 初值為 起始符號 * 

            string AlphaBet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*"; //Code39的字母 

            string[] Code39 = //Code39的各字母對應碼 
            { 
                 /**//* 0 */ "000110100",   
                 /**//* 1 */ "100100001",   
                 /**//* 2 */ "001100001",   
                 /**//* 3 */ "101100000", 
                 /**//* 4 */ "000110001",   
                 /**//* 5 */ "100110000",   
                 /**//* 6 */ "001110000",   
                 /**//* 7 */ "000100101", 
                 /**//* 8 */ "100100100",   
                 /**//* 9 */ "001100100",   
                 /**//* A */ "100001001",   
                 /**//* B */ "001001001", 
                 /**//* C */ "101001000",   
                 /**//* D */ "000011001",   
                 /**//* E */ "100011000",   
                 /**//* F */ "001011000", 
                 /**//* G */ "000001101",   
                 /**//* H */ "100001100",   
                 /**//* I */ "001001100",   
                 /**//* J */ "000011100", 
                 /**//* K */ "100000011",   
                 /**//* L */ "001000011",   
                 /**//* M */ "101000010",   
                 /**//* N */ "000010011", 
                 /**//* O */ "100010010",   
                 /**//* P */ "001010010",   
                 /**//* Q */ "000000111",   
                 /**//* R */ "100000110", 
                 /**//* S */ "001000110",   
                 /**//* T */ "000010110",   
                 /**//* U */ "110000001",   
                 /**//* V */ "011000001", 
                 /**//* W */ "111000000",   
                 /**//* X */ "010010001",   
                 /**//* Y */ "110010000",   
                 /**//* Z */ "011010000", 
                 /**//* - */ "010000101",   
                 /**//* . */ "110000100",   
                 /**//*' '*/ "011000100", 
                 /**//* $ */ "010101000", 
                 /**//* / */ "010100010",   
                 /**//* + */ "010001010",   
                 /**//* % */ "000101010",   
                 /**//* * */ "010010100"
            };
            strSource = strSource.ToUpper();
            //實作圖片 
            Bitmap objBitmap = printCode ? new Bitmap(
              ((WidLength * 3 + NarrowLength * 7) * (intSourceLength + 2)) + (x * 2),
              BarCodeHeight + (y * 2) + SystemFonts.DefaultFont.Height + 2) :
                      new Bitmap(
                      ((WidLength * 3 + NarrowLength * 7) * (intSourceLength + 2)) + (x * 2),
                      BarCodeHeight + (y * 2));
            Graphics objGraphics = Graphics.FromImage(objBitmap); //宣告GDI+繪圖介面 
            //填上底色 
            objGraphics.FillRectangle(Brushes.White, 0, 0, objBitmap.Width, objBitmap.Height);

            for (int i = 0; i < intSourceLength; i++)
            {
                //檢查是否有非法字元 
                if (AlphaBet.IndexOf(strSource[i]) == -1 || strSource[i] == '*')
                {
                    objGraphics.DrawString("含有非法字元",
                      SystemFonts.DefaultFont, Brushes.Red, x, y);
                    return objBitmap;
                }
                //查表編碼 
                strEncode = string.Format("{0}0{1}", strEncode,
                 Code39[AlphaBet.IndexOf(strSource[i])]);
            }

            strEncode = string.Format("{0}0010010100", strEncode); //補上結束符號 * 

            int intEncodeLength = strEncode.Length; //編碼後長度 
            int intBarWidth;

            for (int i = 0; i < intEncodeLength; i++) //依碼畫出Code39 BarCode 
            {
                intBarWidth = strEncode[i] == '1' ? WidLength : NarrowLength;
                objGraphics.FillRectangle(i % 2 == 0 ? Brushes.Black : Brushes.White,
                 x, y, intBarWidth, BarCodeHeight);
                x += intBarWidth;
            }
            if (printCode)
                objGraphics.DrawString(strSource, SystemFonts.DefaultFont, Brushes.Black, 5, BarCodeHeight + 2);
            return objBitmap;
        }

        public static String GetCode39ImageSrc(this string code, bool printCode, float dpi)
        {
            using (Bitmap img = code.GetCode39(printCode))
            {
                using (MemoryStream buffer = new MemoryStream())
                {
                    img.SetResolution(dpi, dpi);
                    img.Save(buffer, System.Drawing.Imaging.ImageFormat.Png);
                    StringBuilder sb = new StringBuilder("data:image/png;base64,");
                    sb.Append(Convert.ToBase64String(buffer.ToArray()));
                    return sb.ToString();
                }
            }
        }

        public static DataSet ImportExcelXLS(this string FileName, bool hasHeaders = true)
        {
            string HDR = hasHeaders ? "Yes" : "No";
            string strConn;
            if (FileName.ToLower().EndsWith(".xlsx"))
                strConn = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + FileName + ";Extended Properties=\"Excel 12.0;HDR=" + HDR + ";IMEX=0\"";
            else
                strConn = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + FileName + ";Extended Properties=\"Excel 8.0;HDR=" + HDR + ";IMEX=0\"";

            DataSet output = new DataSet();

            using (OleDbConnection conn = new OleDbConnection(strConn))
            {
                conn.Open();

                DataTable dt = conn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, new object[] { null, null, null, "TABLE" });

                //                foreach (DataRow row in dt.Rows)
                for (int idx = dt.Rows.Count - 1; idx >= 0; idx--)
                {
                    var row = dt.Rows[idx];
                    string sheet = row["TABLE_NAME"].ToString();

                    OleDbCommand cmd = new OleDbCommand($"SELECT * FROM [{sheet}]", conn);
                    cmd.CommandType = CommandType.Text;

                    DataTable outputTable = new DataTable(sheet);
                    output.Tables.Add(outputTable);
                    new OleDbDataAdapter(cmd).Fill(outputTable);
                }
            }
            return output;
        }

        public static string ToQueryString(this object obj)
        {
            if (obj == null)
                return string.Empty;

            var properties = obj.GetType().GetProperties(BindingFlags.Public | BindingFlags.Instance)
                .Where(p => p.GetValue(obj, null) != null)
                .Select(p => $"{HttpUtility.UrlEncode(p.Name)}={HttpUtility.UrlEncode(p.GetValue(obj, null).ToString())}");

            return string.Join("&", properties);
        }


    }
}
