using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.IO;
using System.Text.RegularExpressions;
using System.Xml;
using System.Text;
using System.Collections;

namespace Utility
{
    public class CodingHelper
    {
        public CodingHelper()
        {

        }

        public static void WriteContent(DataSet ds, Stream outStream)
        {
            Regex regex = new Regex("&amp;#\\d+;");
            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.LoadXml(regex.Replace(ds.GetXml(), new MatchEvaluator(ConvertFromUTFEncode)));
            xmlDoc.Save(outStream);
        }

        public static void WriteContent(DataSet ds, TextWriter writer)
        {
            Regex regex = new Regex("&amp;#\\d+;");
            string content = regex.Replace(ds.GetXml(), new MatchEvaluator(ConvertFromUTFEncode));
            writer.Write(content);
        }


        public static string ConvertFromUTFEncode(Match match)
        {
            int codeValue = int.Parse(match.Value.Substring(6, match.Value.Length - 7));
            return char.ConvertFromUtf32(codeValue);
        }

        public static string ConvertToUTF16Encode(Match match)
        {
            StringBuilder sb = new StringBuilder();
            foreach (char ch in match.Value.ToCharArray())
            {
                sb.Append(String.Format("&amp;#{0};", (int)ch));
            }
            return sb.ToString();
        }

        public static void WriteContentToMS950WithUTF16(XmlDocument xmlDoc, TextWriter writer, string stringCodeToConvert)
        {
            string content = toHtmlMS950Visible(xmlDoc);
            writer.Write(content);
        }

        public static void WriteContentToUTF8WithUTF16(XmlDocument xmlDoc, TextWriter writer, string stringCodeToConvert)
        {
            XmlDeclaration decl;
            if (xmlDoc.FirstChild is XmlDeclaration)
            {
                decl = (XmlDeclaration)xmlDoc.FirstChild;
                decl.Encoding = "utf-8";
            }
            else
            {
                decl = xmlDoc.CreateXmlDeclaration("1.0", "utf-8", null);
                xmlDoc.InsertBefore(decl, xmlDoc.DocumentElement);
            }

            string content = toHtmlMS950Visible(xmlDoc);
            Regex regex = new Regex(stringCodeToConvert);
            content = regex.Replace(content, new MatchEvaluator(ConvertToUTF16Encode));
            writer.Write(content);
        }


        private static string toHtmlMS950Visible(XmlDocument xmlDoc)
        {
            string content = xmlDoc.InnerXml;

            Encoding big5 = Encoding.GetEncoding(950);

            char[] srcArray = xmlDoc.InnerXml.ToCharArray();
            char[] destArray = big5.GetString(big5.GetBytes(content)).ToCharArray();

            ArrayList al = new ArrayList();
            for (int i = 0; i < srcArray.Length && i < destArray.Length; i++)
            {
                if (srcArray[i] != destArray[i])
                    al.Add(i);
            }

            if (al.Count > 0)
            {
                int start = 0;
                StringBuilder sb = new StringBuilder();
                foreach (int index in al)
                {
                    sb.Append(new string(srcArray, start, index - start));
                    start = index + 1;
                    sb.Append(String.Format("&amp;#{0};", (int)srcArray[index]));
                }

                if (start < srcArray.Length)
                {
                    sb.Append(new string(srcArray, start, srcArray.Length - start));
                }
                content = sb.ToString();
            }
            return content;
        }


        public static void WriteContentToBig5WithUTF16(XmlDocument xmlDoc, TextWriter writer, string stringCodeToConvert)
        {
            string content = toHtmlMS950Visible(xmlDoc);

            Regex regex = new Regex(stringCodeToConvert);
            content = regex.Replace(content, new MatchEvaluator(ConvertToUTF16Encode));
            writer.Write(content);
        }

        public static string WriteContentToBig5WithUTF16(XmlDocument xmlDoc, string stringCodeToConvert)
        {
            string content = toHtmlMS950Visible(xmlDoc);

            Regex regex = new Regex(stringCodeToConvert);
            content = regex.Replace(content, new MatchEvaluator(ConvertToUTF16Encode));
            return content;
        }


    }

}
