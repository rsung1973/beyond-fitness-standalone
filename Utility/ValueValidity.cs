using System;
using System.Data;
using System.IO;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Web.UI;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Xml;
using System.Net;
using System.Threading;
using System.Globalization;

namespace Utility
{
    /// <summary>
    /// Summary description for ValueValidity.
    /// </summary>
    public static class ValueValidity
    {

        private static string[] strArrayNum = { "零", "壹", "貳", "參", "肆", "伍", "陸", "柒", "捌", "玖" };
        private static string[] strArrayUnit1 = { "", "拾", "佰", "仟" };
        private static string[] strArrayUnit2 = { "元整", "萬", "億", "兆" };
        public static char[] __CHINESE_NUM_CHAR = { '零', '壹', '貳', '參', '肆', '伍', '陸', '柒', '捌', '玖' };


        public static char[] HELFWIDTH_CODE = {
												  '1','2','3','4','5','6','7','8','9','0','-','=','q','w','e','r','t','y','u','i','o','p','[',']',
												  '\\','a','s','d','f','g','h','j','k','l',';','\'','z','x','c','v','b','n','m',',','.','/','!','@',
												  '#','$','%','^','&','*','(',')','_','+','Q','W','E','R','T','Y','U','I','O','P','{','}','|','A',
												  'S','D','F','G','H','J','K','L',':','"','Z','X','C','V','B','N','M','<','>','?','~',' '
											  };
        public static char[] FULLWIDTH_CODE = {
												  '１','２','３','４','５','６','７','８','９','０','－','＝','ｑ','ｗ','ｅ','ｒ','ｔ','ｙ','ｕ','ｉ',
												  'ｏ','ｐ','〔','〕','＼','ａ','ｓ','ｄ','ｆ','ｇ','ｈ','ｊ','ｋ','ｌ','；','’','ｚ','ｘ','ｃ','ｖ',
												  'ｂ','ｎ','ｍ','，','．','／','！','＠','＃','＄','％','︿','＆','＊','（','）','＿','＋','Ｑ','Ｗ',
												  'Ｅ','Ｒ','Ｔ','Ｙ','Ｕ','Ｉ','Ｏ','Ｐ','｛','｝','｜','Ａ','Ｓ','Ｄ','Ｆ','Ｇ','Ｈ','Ｊ','Ｋ','Ｌ',
												  '：','”','Ｚ','Ｘ','Ｃ','Ｖ','Ｂ','Ｎ','Ｍ','＜','＞','？','～','　'
											  };
        public static char[] DISCERNIBLE_CODE = {'2', '3', '4', '5', '6', '8', 
                                    '9', 'A', 'B', 'C', 'D', 'E', 
                                    'F', 'G', 'H', 'J', 'K', 'L', 
                                    'M', 'N', 'P', 'R', 'S', 'T', 
                                    'W', 'X', 'Y'};
        public static char[] NUMERIC_STRING = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' };


        public static bool IsSignificantString(object obj)
        {
            if (obj != null && (obj is string))
            {
                return ((string)obj).Length > 0;
            }
            return false;
        }

        public static void CheckAndCreatePath(string path)
        {
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
        }


        public static void AppendEMailAddr(IList list, object emailAddr)
        {
            if (IsSignificantString(emailAddr))
            {
                string[] email = emailAddr.ToString().Split(',', ';', ' ', '\r', '\n');
                foreach (string s in email)
                {
                    list.Add(s);
                }
            }
        }

        public static string SaveUploadFile(System.Web.HttpPostedFile file, string storePath, string ext)
        {
            if (file != null)
            {
                string fileName = System.Guid.NewGuid().ToString() + ext;
                file.SaveAs(storePath + "\\" + fileName);
                return fileName;
            }
            return null;
        }

        public static void ResetHtmlInputText(ControlCollection controls)
        {
            foreach (Control control in controls)
            {
                if (control is HtmlInputText)
                {
                    ((HtmlInputText)control).Value = "";
                }
            }
        }

        public static string GetDateStylePath(this string prefix)
        {
            return GetDateStylePath(prefix, DateTime.Now);
        }

        public static string GetDateStylePath(this string prefix, DateTime date)
        {
            string path = Path.Combine(prefix,String.Format("{0:yyyy}\\{0:MM}\\{0:dd}", date));

            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);

            return path;
        }


        #region ConvertChineseDate

        /// <summary>
        /// 將日期轉成民國紀元
        /// </summary>
        /// <param name="dateTime"></param>
        /// <returns></returns>
        /// 
        public static string ConvertChineseDate(object dateTime)
        {
            if (dateTime != null && dateTime is DateTime)
            {
                DateTime dt = (DateTime)dateTime;
                return String.Format("{0}.{1:00}.{2:00}", dt.Year - 1911, dt.Month, dt.Day);
            }

            return null;

        }


        public static string ConvertChineseDate(object dateTime, string strAsNull)
        {
            if (dateTime != null && dateTime is DateTime)
            {
                DateTime dt = (DateTime)dateTime;
                return String.Format("{0}.{1:00}.{2:00}", dt.Year - 1911, dt.Month, dt.Day);
            }

            return strAsNull;

        }


        #endregion

        #region ConvertChineseDateString
        public static string ConvertChineseDateString(object dateTime)
        {
            if (dateTime != null && dateTime is DateTime)
            {

                DateTime dt = (DateTime)dateTime;
                return String.Format("{0}年{1}月{2}日", dt.Year - 1911, dt.Month, dt.Day);
            }
            return null;
        }

        #endregion


        public static string ConvertChineseDateTimeString(object dateTime)
        {
            if (dateTime != null && dateTime is DateTime)
            {

                DateTime dt = (DateTime)dateTime;
                return String.Format("{0}年{1}月{2}日{3}時{4}分{5}秒",
                    dt.Year - 1911, dt.Month, dt.Day, dt.Hour, dt.Minute, dt.Second);
            }
            return null;
        }

        #region MoneyShow

        public static string MoneyShow(object numValue)
        {
            string strMoney = Convert.ToInt64(numValue).ToString();
            if (strMoney.Length > 15) return strMoney; //百兆以上不處理

            #region 變數宣告
            int intUnit2;
            int intUnit1;

            string[] strAnser = new string[4];
            int intLength = strMoney.Length - 1;
            string strTemp = "";
            int intTemp;
            string strResult = "";
            #endregion

            try
            {
                #region 數字轉換
                for (int i = 0; i <= intLength; i++)
                {
                    intUnit1 = i % 4;
                    intUnit2 = i / 4;
                    strTemp = strMoney.Substring(intLength - i, 1);
                    intTemp = int.Parse(strTemp);
                    if (intTemp == 0)
                        strAnser[intUnit2] = strArrayNum[intTemp] + strAnser[intUnit2];
                    else
                        strAnser[intUnit2] = strArrayNum[intTemp] + strArrayUnit1[intUnit1] + strAnser[intUnit2];
                }
                #endregion


                #region 寫入單位與零之顯示
                for (int i = 0; i <= (intLength / 4); i++)
                {
                    if ((i > 0) && strAnser[i].Length > 3)
                    {
                        if ((strAnser[i].Substring((strAnser[i].Length - 3), 3) == "零零零"
                            && ((strAnser[i].Substring(0, 1) != "零"))))
                        {
                            strAnser[i] = strAnser[i].Replace("零零零", "");
                            strAnser[i] = strAnser[i] + strArrayUnit2[i] + "零";
                        }
                        else
                        {
                            strAnser[i] = strAnser[i].Replace("零零零零", "零");
                            strAnser[i] = strAnser[i].Replace("零零零", "零");
                            strAnser[i] = strAnser[i].Replace("零零", "零");
                            if (strAnser[i].Substring((strAnser[i].Length - 1), 1) == "零")
                                strAnser[i] = strAnser[i].Substring(0, (strAnser[i].Length - 1)) + strArrayUnit2[i] + "零";
                            else
                                strAnser[i] = strAnser[i] + strArrayUnit2[i];
                        }
                    }
                    else
                    {
                        strAnser[i] = strAnser[i].Replace("零零零零", "零");
                        strAnser[i] = strAnser[i].Replace("零零零", "零");
                        strAnser[i] = strAnser[i].Replace("零零", "零");
                        if (strAnser[i].Substring((strAnser[i].Length - 1), 1) == "零")
                            strAnser[i] = strAnser[i].Substring(0, (strAnser[i].Length - 1)) + strArrayUnit2[i] + "零";
                        else
                            strAnser[i] = strAnser[i] + strArrayUnit2[i];
                    }
                }
                #endregion

                strResult = strAnser[3] + strAnser[2] + strAnser[1] + strAnser[0];

                #region 其它處理
                strResult = strResult.Replace("兆億萬", "兆");
                strResult = strResult.Replace("兆億", "兆");
                strResult = strResult.Replace("億萬", "億零");
                strResult = strResult.Replace("零兆", "零");
                strResult = strResult.Replace("零億", "零");
                strResult = strResult.Replace("零萬", "零");
                strResult = strResult.Replace("零零零", "零");
                strResult = strResult.Replace("零零", "零");
                strResult = strResult.Replace("零元整", "元整");
                if (strResult.Substring(0, 1) == "零")
                    strResult = strResult.Substring(1, (strResult.Length - 1));
                if (strResult.Substring(strResult.Length - 1, 1) == "零")
                    strResult = strResult.Substring(0, (strResult.Length - 1));
                #endregion

                return strResult;
            }
            catch
            {
                return strMoney;
            }
        }

        #endregion

        #region ConvertToFullWidthString 轉成全形字串
        public static char ConvertToFullWidthChar(this char ch)
        {
            for (int i = 0; i < HELFWIDTH_CODE.Length; i++)
            {
                if (HELFWIDTH_CODE[i] == ch)
                    return FULLWIDTH_CODE[i];
            }
            return ch;
        }

        public static string ConvertToFullWidthString(this string str)
        {
            if (!String.IsNullOrEmpty(str))
            {
                return new String(str.Where(c => c != '\r' && c != '\n' && c != '\t')
                    .Select(c => c.ConvertToFullWidthChar()).ToArray());
            }

            return str;
        }
        #endregion

        public static char ConvertToHalfWidthChar(this char ch)
        {
            for (int i = 0; i < HELFWIDTH_CODE.Length; i++)
            {
                if (FULLWIDTH_CODE[i] == ch)
                    return HELFWIDTH_CODE[i];
            }
            return ch;
        }

        public static string ConvertToHalfWidthString(this string str)
        {
            if (!String.IsNullOrEmpty(str))
            {
                StringBuilder builder = new StringBuilder(str);
                for (int i = 0; i < builder.Length; i++)
                {
                    builder[i] = ConvertToHalfWidthChar(builder[i]);
                }
                return builder.ToString();
            }

            return str;
        }


        #region ConvertMoneyToCNShow

        public static string ConvertMoneyToCNShow(object numValue)
        {

            string strMoney = numValue.ToString();
            int i;
            int intZeroCount;
            int intLength;
            bool boolStart = false;
            string[] strArrayNum = new string[10] { "零", "壹", "貳", "參", "肆", "伍", "陸", "柒", "捌", "玖" };
            string[] strArrayUnit = new string[13] { "", "拾", "佰", "仟", "萬", "拾", "佰", "仟", "億", "拾", "百", "仟", "兆" };
            string strAnswer = "";
            string strAnswreTemp = "";
            string strTemp = "";
            string strZero = "";
            intZeroCount = 0;
            int intTemp = 0;
            int intDecIndex;
            string strMoneyInt;
            string strMoneyDec;

            intDecIndex = strMoney.IndexOf(".");
            strMoneyInt = strMoney.Substring(0, intDecIndex);
            strMoneyDec = strMoney.Substring((intDecIndex + 1), (strMoney.Length - intDecIndex - 1));
            intLength = strMoneyInt.Length - 1;

            for (i = 0; i <= intLength; i++)
            {
                strTemp = strMoneyInt.Substring(intLength - i, 1);
                intTemp = int.Parse(strTemp);
                //boolStart True:補零 False:不補零

                if (intTemp > 0)
                {
                    if ((i == 5) || (i == 9))
                        if (intZeroCount >= 1)
                        {
                            if (boolStart == true)
                                strAnswer = strArrayNum[intTemp] + strArrayUnit[i] + strArrayUnit[i - 1] + strArrayNum[0] + strAnswer;
                            else
                                strAnswer = strArrayNum[intTemp] + strArrayUnit[i] + strArrayUnit[i - 1] + strAnswer;
                            intZeroCount = 0;
                        }
                        else
                            //							if (i >5 )
                            strAnswer = strArrayNum[intTemp] + strArrayUnit[i] + strAnswer;
                    //							else 
                    //								strAnswer = strArrayNum[intTemp] + strArrayUnit[i] + strArrayUnit[i-1] + strAnswer;
                    else
                    {
                        if (intZeroCount >= 1)
                        {
                            if (boolStart == true)
                                strAnswer = strArrayNum[intTemp] + strArrayUnit[i] + strArrayNum[0] + strAnswreTemp + strAnswer;
                            else
                                if (i >= 3)
                                    strAnswer = strArrayNum[intTemp] + strArrayUnit[i] + strAnswreTemp + strArrayNum[0] + strAnswer;
                                else
                                    strAnswer = strArrayNum[intTemp] + strArrayUnit[i] + strAnswreTemp + strAnswer;
                            intZeroCount = 0;
                            strAnswreTemp = "";

                        }
                        else
                            strAnswer = strArrayNum[intTemp] + strArrayUnit[i] + strAnswer;
                    }
                    strZero = "";
                    boolStart = true;
                }
                else
                {
                    if ((i == 5) || (i == 9))
                    {
                        strAnswreTemp = strArrayUnit[i - 1];         //萬與億是單位,既使是零也要寫入
                        boolStart = false;                         //不能補零
                    }
                    intZeroCount = intZeroCount + 1;
                    strZero = strArrayNum[0];
                }
            }
            //例外處理
            if (strAnswer.Substring(strAnswer.Length - 1, 1) == "零")     //尾數為零時刪除靈
                strAnswer = strAnswer.Substring(0, strAnswer.Length - 1);
            if (strAnswer.Length > 2)
                if (strAnswer.Substring(strAnswer.Length - 2, 2) == "億萬")   //尾數為億萬時刪除萬
                    strAnswer = strAnswer.Substring(0, strAnswer.Length - 1);
            //尾數加"元整"
            strAnswer = strAnswer + "元整";
            return strAnswer;

        }

        #endregion

        #region "檢測八位統一編號"
        public static bool CheckRegno(this string strNo)
        {
            if (strNo == null)
                return false;
            String receiptNo = strNo.Trim();
            if (receiptNo.Length != 8)
                return false;

            int code;
            if(!int.TryParse(receiptNo,out code))
            {
                return false;
            }

            Func<int, int> digitSum = d =>
            {
                return (d / 10) + (d % 10);
            };
            //1,2,1,2,1,2,4,1
            int checkSum = (code / 10000000) +
                digitSum(((code % 10000000) / 1000000) * 2) +
                ((code % 1000000) / 100000) +
                digitSum(((code % 100000) / 10000) * 2) +
                ((code % 10000) / 1000) +
                digitSum(((code % 1000) / 100) * 2) +
                digitSum(((code % 100) / 10) * 4) +
                (code % 10);

            if (checkSum % 10 == 0)
                return true;

            if ((code % 100) / 10 == 7 && (checkSum + 1) % 10 == 0)
                return true;

            return false;

        }
        #endregion

        #region HasAtLeastOneRow
        public static bool HasAtLeastOneRow(DataSet ds)
        {
            return (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0);
        }

        #endregion


        public static void AssignRowValue(DataRow srcRow, DataRow targetRow)
        {
            DataColumnCollection srcCols = srcRow.Table.Columns;
            DataColumnCollection targetCols = targetRow.Table.Columns;
            foreach (DataColumn targetCol in targetCols)
            {
                DataColumn srcCol = srcCols[targetCol.ColumnName];
                if ((null != srcCol) && !DBNull.Value.Equals(srcRow[srcCol]))
                {
                    if (srcCol.DataType.Equals(typeof(String)))
                    {
                        targetRow[targetCol] = Convert.ChangeType(((string)srcRow[srcCol]).Trim(), targetCol.DataType);
                    }
                    else
                    {
                        targetRow[targetCol] = Convert.ChangeType(srcRow[srcCol], targetCol.DataType);
                    }
                }
            }
        }

        public static byte[] GetFileBytes(String filename)
        {
            if (!File.Exists(filename))
                return null;
            Stream stream = new FileStream(filename, FileMode.Open, FileAccess.Read, FileShare.Read);
            int datalen = (int)stream.Length;
            byte[] filebytes = new byte[datalen];
            stream.Seek(0, SeekOrigin.Begin);
            stream.Read(filebytes, 0, datalen);
            stream.Close();
            return filebytes;
        }

        public static string MakePassword(string password)
        {
            MD5 md5 = MD5.Create();
            return String.Join("", md5.ComputeHash(Encoding.Default.GetBytes(password)).Select(i => String.Format("{0:X02}", i)));
        }

        public static Boolean CheckIDNo(this string id)
        {
            int value = 0;
            string sId;
            if (String.IsNullOrEmpty(id) || id.Length != 10)
            {
                return false;
            }
            else
            {
                sId = id.ToUpper();
                switch (sId[0])
                {
                    case 'A': value = 10; break;
                    case 'B': value = 11; break;
                    case 'C': value = 12; break;
                    case 'D': value = 13; break;
                    case 'E': value = 14; break;
                    case 'F': value = 15; break;
                    case 'G': value = 16; break;
                    case 'H': value = 17; break;
                    case 'I': value = 34; break;
                    case 'J': value = 18; break;
                    case 'K': value = 19; break;
                    case 'L': value = 20; break;
                    case 'M': value = 21; break;
                    case 'N': value = 22; break;
                    case 'O': value = 35; break;
                    case 'P': value = 23; break;
                    case 'Q': value = 24; break;
                    case 'R': value = 25; break;
                    case 'S': value = 26; break;
                    case 'T': value = 27; break;
                    case 'U': value = 28; break;
                    case 'V': value = 29; break;
                    case 'W': value = 32; break;
                    case 'X': value = 30; break;
                    case 'Y': value = 31; break;
                    case 'Z': value = 33; break;
                }

                if (value < 10 || value > 35)
                    return false;

            }

            long suffix;
            if (!long.TryParse(sId.Substring(1), out suffix))
                return false;

            value = value / 10 + (value % 10) * 9 +
            (sId[1] - '0') * 8 +
            (sId[2] - '0') * 7 +
            (sId[3] - '0') * 6 +
            (sId[4] - '0') * 5 +
            (sId[5] - '0') * 4 +
            (sId[6] - '0') * 3 +
            (sId[7] - '0') * 2 +
            (sId[8] - '0') +
            (sId[9] - '0');
            value = value % 10;
            if (value != 0)
            {
                return false;
            }

            return true;


        }

        public static string CreateRandomStringCode(this int codeLength)
        {
            //驗證碼的字元集，去掉了一些容易混淆的字元
            Thread.Sleep(1);
            Random oRnd = new Random();
            char[] sCode = new char[codeLength];

            //生成驗證碼字串
            for (int n = 0; n < codeLength; n++)
            {
                sCode[n] = DISCERNIBLE_CODE[oRnd.Next(DISCERNIBLE_CODE.Length)];
            }
            return new String(sCode);
        }

        public static string GenerateRandomCode(this int codeLength)
        {
            //驗證碼的字元集，去掉了一些容易混淆的字元
            Thread.Sleep(1);
            Random oRnd = new Random();
            char[] sCode = new char[codeLength];

            //生成驗證碼字串
            for (int n = 0; n < codeLength; n++)
            {
                sCode[n] = NUMERIC_STRING[oRnd.Next(NUMERIC_STRING.Length)];
            }
            return new String(sCode);
        }


        public static char[] GetChineseNumberSeries(this int number,int length)
        {
            char[] result = new char[length];
            for (int i = 0; i < length; i++)
            {
                result[i] = __CHINESE_NUM_CHAR[number % 10];
                number /= 10;
            }
            return result;
        }

        public static byte[] UploadData(this XmlNode data, String url)
        {
            using (WebClient client = new WebClient())
            {
                Encoding utf8 = new UTF8Encoding();
                client.Encoding = utf8;
                return client.UploadData(url, utf8.GetBytes(data.OuterXml));
            }
        }

        public static XmlDocument UploadDocument(this XmlNode data, String url)
        {
            byte[] result = data.UploadData(url);
            if (result != null)
            {
                using (MemoryStream ms = new MemoryStream(result))
                {
                    XmlDocument doc = new XmlDocument();
                    doc.Load(ms);
                    return doc;
                }
            }
            return null;
        }

        public static void SaveAs(this byte[] buf, String fileName)
        {
            using (FileStream fs = new FileStream(fileName, FileMode.Create, FileAccess.Write))
            {
                fs.Write(buf, 0, buf.Length);
                fs.Flush();
                fs.Close();
            }
        }

        public static T NullDefault<T>(this Nullable<T> val)
            where T : struct
        {
            return val.HasValue ? val.Value : default(T);
        }


        #region "驗証輸入的字串"
        /// 
        /// 判斷輸入的字串類型。　
        /// 
        /// 輸入的字串。(string) 
        /// 要驗証的類型，可選擇之類型如下列表。(int)         
        /// 驗証通過則傳回 True，反之則為 False。
        public static bool ValidateString(String _value, int _kind)
        {
            string RegularExpressions = null;
            CompareValidator cv = new CompareValidator();
            switch (_kind)
            {
                case 1:
                    //由26個英文字母組成的字串
                    RegularExpressions = "^[A-Za-z]+$";
                    break;
                case 2:
                    //正整數 
                    RegularExpressions = "^[0-9]*[1-9][0-9]*$";
                    break;
                case 3:
                    //非負整數（正整數 + 0)
                    RegularExpressions = "^\\d+$";
                    break;
                case 4:
                    //非正整數（負整數 + 0）
                    RegularExpressions = @"^((-\\d+)|(0+))$";
                    break;
                case 5:
                    //負整數 
                    RegularExpressions = @"^-[0-9]*[1-9][0-9]*$";
                    break;
                case 6:
                    //整數
                    RegularExpressions = @"^-?\\d+$";
                    break;
                case 7:
                    //非負浮點數（正浮點數 + 0）
                    RegularExpressions = @"^\\d+(\\.\\d+)?$";
                    break;
                case 8:
                    //正浮點數
                    RegularExpressions = @"^(([0-9]+\\.[0-9]*[1-9][0-9]*)|([0-9]*[1-9][0-9]*\\.[0-9]+)|([0-9]*[1-9][0-9]*))$";
                    break;
                case 9:
                    //非正浮點數（負浮點數 + 0）
                    RegularExpressions = @"^((-\\d+(\\.\\d+)?)|(0+(\\.0+)?))$";
                    break;
                case 10:
                    //負浮點數
                    RegularExpressions = @"^(-(([0-9]+\\.[0-9]*[1-9][0-9]*)|([0-9]*[1-9][0-9]*\\.[0-9]+)|([0-9]*[1-9][0-9]*)))$";
                    break;
                case 11:
                    //浮點數
                    RegularExpressions = @"^(-?\\d+)(\\.\\d+)?$";
                    break;
                case 12:
                    //由26個英文字母的大寫組成的字串
                    RegularExpressions = "^[A-Z]+$";
                    break;
                case 13:
                    //由26個英文字母的小寫組成的字串
                    RegularExpressions = "^[a-z]+$";
                    break;
                case 14:
                    //由數位和26個英文字母組成的字串
                    RegularExpressions = "^[A-Za-z0-9]+$";
                    break;
                case 15:
                    //由數位、26個英文字母或者下劃線組成的字串 
                    RegularExpressions = "^[0-9a-zA-Z_]+$";
                    break;
                case 16:
                    //email地址
                    RegularExpressions = "\\w+([-+.']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*";
                    break;
                case 17:
                    //url
                    RegularExpressions = "^[a-zA-z]+://(\\w+(-\\w+)*)(\\.(\\w+(-\\w+)*))*(\\?\\S*)?$";
                    break;
                case 18:
                    //只能輸入中文
                    RegularExpressions = "^[^\u4E00-\u9FA5]";
                    break;
                case 19:
                    //只能輸入0和非0打頭的數字
                    RegularExpressions = "^(0|[1-9][0-9]*)$";
                    break;
                case 20:
                    //只能輸入數字
                    RegularExpressions = "^[0-9]*$";
                    break;
                case 21:
                    //只能輸入數字加2位小數
                    RegularExpressions = "^[0-9]+(.[0-9]{1,2})?$";
                    break;
                case 22:
                    //只能輸入0和非0打頭的數字加2位小數
                    RegularExpressions = "^(0|[1-9]+)(.[0-9]{1,2})?$";
                    break;
                case 23:
                    //只能輸入0和非0打頭的數字加2位小數，但不匹配0.00
                    RegularExpressions = "^(0(.(0[1-9]|[1-9][0-9]))?|[1-9]+(.[0-9]{1,2})?)$";
                    break;
                //case 24:
                //    //驗證日期格式 YYYYMMDD, 範圍19000101~20991231
                //    RegularExpressions = "(19|20)\\d\\d+(0[1-9]|1[012])+(0[1-9]|[12][0-9]|3[01])$";
                //    break;
                //case 25:
                //    //驗證日期格式 MMDDYYYY
                //    RegularExpressions = "(0[1-9]|1[012])+(0[1-9]|[12][0-9]|3[01])+(19|20)\\d\\d$";
                //    break;
                //case 26:
                //    //驗證日期格式 YYYYMM
                //    RegularExpressions = "(19|20)\\d\\d+(0[1-9]|1[012])$";
                //    break;
                //case 27:
                //    //驗證日期格式 YYYYMMDD, 範圍00010101~99991231
                //    RegularExpressions = "(^0000|0001|9999|[0-9]{4})+(0[1-9]|1[0-2])+(0[1-9]|[12][0-9]|3[01])$";
                //    break; 

                case 28:  //驗證時間格式HH/MM/SS
                    RegularExpressions = @"([0-1][0-9]|2[0-3])\:[0-5][0-9]\:[0-5][0-9]";
                    break;

                case 29:  //驗證特殊字元
                    RegularExpressions = "(?=.*[@#$%^&+=])";
                    break;
                case 30: //驗證日期格式YYYY/MM/DD

                    cv.ControlToValidate = _value;
                    cv.Operator = ValidationCompareOperator.DataTypeCheck;
                    cv.Type = ValidationDataType.Date;
                    // RegularExpressions = "^((19|20)[0-9]{2}[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01]))$";
                    break;
                default:
                    break;
            }
            if (_kind < 30)
            {
                Match m = Regex.Match(_value, RegularExpressions);
                if (m.Success)
                    return true;
                else
                    return false;
            }
            else
            {

                return cv.IsValid;
            }
        }
        #endregion

        public static byte[] FromHexStringToBytes(this String data, int delimitSpace = 0)
        {
            int length = (data.Length + delimitSpace + 1) / (2 + delimitSpace);
            byte[] buf = new byte[length];
            for (int i = 0; i < length; i++)
            {
                buf[i] = Convert.ToByte(data.Substring(i * (2 + delimitSpace), 2), 16);
            }
            return buf;
        }

        public static byte[] HexToByteArray(this string hexString)
        {
            byte[] bytes = new byte[hexString.Length / 2];

            for (int i = 0; i < hexString.Length; i += 2)
            {
                string s = hexString.Substring(i, 2);
                bytes[i / 2] = byte.Parse(s, NumberStyles.HexNumber, null);
            }

            return bytes;
        }

        public static String ToHexString(this byte[] data, String delimiter = "")
        {
            return String.Join(delimiter, data.Select(b => b.ToString("X2")));
        }

    }
}
