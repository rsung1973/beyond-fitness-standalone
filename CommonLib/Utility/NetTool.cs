using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Net.Sockets;
using System.Runtime.Serialization;
using System.Text;
using System.Xml;

using CommonLib.Properties;

namespace Utility
{
    /// <summary>
    /// NetTool 的摘要描述。
    /// </summary>
    public class NetTool
    {
        private NetTool()
        {
            //
            // TODO: 在此加入建構函式的程式碼
            //
        }

        public static HttpWebResponse GetUrlResponse(string url)
        {
            HttpWebRequest wr = (HttpWebRequest)WebRequest.Create(url);
            wr.Method = "GET";

            return (HttpWebResponse)wr.GetResponse();
        }


        public static Stream GetUrlResource(string url)
        {
            return GetUrlResponse(url).GetResponseStream();
        }

        public static void CacheUrlResource(string url, string fileName)
        {
            Stream stream = GetUrlResource(url);

            FileStream output = new FileStream(fileName, FileMode.Create, FileAccess.Write);
            stream.WriteTo(output);

            output.Flush();
            output.Close();

        }

        public static HttpStatusCode InvokeUrl(string url)
        {
            try
            {
                HttpWebResponse webResponse = GetUrlResponse(url);
                long contentLength = webResponse.ContentLength;

                return webResponse.StatusCode;

            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.WriteLine(ex);
            }

            return HttpStatusCode.BadRequest;
        }

        public static HttpStatusCode InvokeUrl(string url, out string responseText)
        {
            try
            {
                HttpWebResponse webResponse = GetUrlResponse(url);

                StreamReader sr = new StreamReader(webResponse.GetResponseStream());
                responseText = sr.ReadToEnd();
                sr.Close();

                return webResponse.StatusCode;

            }
            catch (Exception ex)
            {
                responseText = null;
                System.Diagnostics.Trace.WriteLine(ex);
            }

            return HttpStatusCode.BadRequest;
        }

        public static String SerializeDataContract(object target)
        {
            if (target != null)
            {
                DataContractSerializer serializer = new DataContractSerializer(target.GetType());
                StringBuilder sb = new StringBuilder();
                StringWriter sw = new StringWriter(sb);
                XmlTextWriter xtw = new XmlTextWriter(sw);
                serializer.WriteObject(xtw, target);
                xtw.Flush();
                xtw.Close();
                sw.Flush();
                sw.Close();
                return sb.ToString();
            }
            return null;
        }

        public static object DeserializeDataContract(Type type, String serialized)
        {
            if (serialized != null)
            {
                DataContractSerializer serializer = new DataContractSerializer(type);
                using (StringReader sr = new StringReader(serialized))
                {
                    XmlTextReader xtr = new XmlTextReader(sr);
                    object result = serializer.ReadObject(xtr);
                    xtr.Close();
                    sr.Close();
                    return result;
                }
            }
            return null;
        }

        public static TEntity DeserializeDataContract<TEntity>(String serialized)
        {
            return (TEntity)DeserializeDataContract(typeof(TEntity), serialized);
        }

        public static bool SendEmailFileBySmtp(string smtpHost,MailMessage mail,string emlFile,string mailDomain,bool useAuth,string authMech,string pid,string password)
        {
            using (TcpClient smtp = new TcpClient(smtpHost, 25))
            {
                NetworkStream ns = smtp.GetStream();
                using (StreamReader sr = new StreamReader(ns))
                {
                    using (StreamWriter sw = new StreamWriter(ns))
                    {
                        sw.WriteLine();
                        sw.Flush();

                        string data = sr.ReadLine();

                        if (useAuth)
                        {
                            sw.WriteLine(String.Format("ehlo {0}", mailDomain));
                            sw.Flush();
                            data = sr.ReadLine();
                            sw.WriteLine(String.Format("auth {0}", authMech));
                            sw.Flush();
                            data = sr.ReadLine();

                            sw.WriteLine(pid);
                            sw.Flush();
                            data = sr.ReadLine();

                            sw.WriteLine(password);
                            sw.Flush();
                            data = sr.ReadLine();
                            if (data.IndexOf("235") < 0)
                            {
                                return false;
                            }
                        }

                        sw.WriteLine(String.Format("helo {0}", mailDomain));
                        sw.Flush();
                        data = sr.ReadLine();
                        //mail sender
                        sw.WriteLine(String.Format("mail from:<{0}>", mail.From));
                        sw.Flush();
                        data = sr.ReadLine();

                        //mail receiptors
                        foreach (var mailTo in mail.To)
                        {
                            sw.WriteLine(String.Format("rcpt to:<{0}>", mailTo));
                            sw.Flush();
                            data = sr.ReadLine();
                        }

                        sw.WriteLine("data");
                        sw.Flush();
                        data = sr.ReadLine();
                        sw.Write("Subject: ");

                        //修正MAIL主旨編碼錯誤
                        byte[] _Bytes = System.Text.Encoding.UTF8.GetBytes(mail.Subject);
                        mail.Subject = ("=?utf-8?B?" + (Convert.ToBase64String(_Bytes) + "?="));

                        sw.WriteLine(mail.Subject);
                        sw.Write("To: ");
                        sw.Flush();

                        foreach (var mailTo in mail.To)
                        {
                            sw.Write(mailTo.ToString());
                            sw.Write(";");
                        }
                        sw.WriteLine();
                        sw.Flush();

                        if (File.Exists(emlFile))
                        {
                            FileStream fs = new FileStream(emlFile, FileMode.Open, FileAccess.Read);
                            fs.WriteTo(ns);
                            fs.Close();
                        }
                        sw.Flush();
                        sw.WriteLine();
                        sw.WriteLine(".");
                        sw.Flush();
                        data = sr.ReadLine();
                        sw.WriteLine("quit");
                        sw.Flush();
                        data = sr.ReadLine();
                        sw.Flush();
                        sw.Close();
                    }
                    sr.Close();
                }

                ns.Flush();
                ns.Close();
                smtp.Close();
            }

            return true;
        }
    }
}
