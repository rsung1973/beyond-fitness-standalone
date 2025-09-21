using System;
using System.Data;
using System.Xml;
using System.IO;

using CommonLib.Utility;
using CommonLib.PlugInAdapter;

namespace CommonLib.Security.UseCrypto
{
    /// <summary>
    /// CryptoLog 的摘要描述。
    /// </summary>
    internal class CryptoLog : ILogObject
    {
        DataRow _row;

        public CryptoLog(DataRow log)
        {
            //
            // TODO: 在此加入建構函式的程式碼
            //
            _row = log;
        }
        #region ILog 成員

        public override string ToString()
        {
            // TODO:  加入 CryptoLog.ToString 實作
            DataSet ds = _row.Table.DataSet;
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            StringWriter sw = new StringWriter(sb);
            ds.WriteXml(sw);

            sw.Flush();
            sw.Close();

            return sb.ToString();
        }

        public string Subject
        {
            get
            {
                // TODO:  加入 CryptoLog.Subject getter 實作
                return "驗簽記錄";
            }
        }

        #endregion
    }

    public partial class dsPKCS7 : ILogObject2
    {
        public XmlDocument XmlSignature { get; set; }

        #region ILog2 成員

        public virtual string GetFileName(string currentLogPath, string qName, ulong key)
        {
            string path = Path.Combine(currentLogPath, "ca_log");
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }

            if (XmlSignature != null && this.pkcs7Envelop!=null)
            {
                string sigFile = String.Format("{0}\\{1:000000000000}({3:HHmmssffff})-XmlSig.{2}.xml", path, key, qName, DateTime.Now);
                XmlSignature.Save(sigFile);
                this.pkcs7Envelop.DataSignature = sigFile;
            }

            return String.Format("{0}\\{1:000000000000}({3:HHmmssffff}).{2}.xml", path, key, qName, DateTime.Now);

        }

        #endregion

        #region ILog 成員

        public string Subject
        {
            get { return "驗簽記錄(PKCS#7)"; }
        }

        public override string ToString()
        {
            return this.GetXml();
        }

        #endregion
    }
}
