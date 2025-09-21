using System;
using System.Data;
using System.IO;
using System.Web;
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

namespace CommonLib.Utility
{
    /// <summary>
    /// Summary description for ValidityAgent.
    /// </summary>
    public static class ValidityAgent
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

        public const string HEX_NUMBER = "0123456789ABCDEF";

        public static readonly Random RANDOM = new Random();
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

        #region ConvertChineseDate

        /// <summary>
        /// 將日期轉成民國紀元
        /// </summary>
        /// <param name="dateTime"></param>
        /// <returns></returns>
        /// 
        public static string ConvertChineseDate(this object dateTime)
        {
            if (dateTime != null && dateTime is DateTime)
            {
                DateTime dt = (DateTime)dateTime;
                return String.Format("{0}.{1:00}.{2:00}", dt.Year - 1911, dt.Month, dt.Day);
            }

            return null;

        }


        public static string ConvertChineseDate(this object dateTime, string strAsNull)
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
        public static string ConvertChineseDateString(this object dateTime)
        {
            if (dateTime != null && dateTime is DateTime)
            {

                DateTime dt = (DateTime)dateTime;
                return String.Format("{0}年{1}月{2}日", dt.Year - 1911, dt.Month, dt.Day);
            }
            return null;
        }

        #endregion


        public static string ConvertChineseDateTimeString(this object dateTime)
        {
            if (dateTime != null && dateTime is DateTime)
            {

                DateTime dt = (DateTime)dateTime;
                return String.Format("{0}年{1}月{2}日{3}時{4}分{5}秒",
                    dt.Year - 1911, dt.Month, dt.Day, dt.Hour, dt.Minute, dt.Second);
            }
            return null;
        }

        public static string MoneyShow(this object numValue)
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

        public static bool CheckRegno(this string strNo)
        {
            if (strNo == null)
                return false;
            String receiptNo = strNo.Trim();
            if (receiptNo.Length != 8)
                return false;

            const int checkCode = 5;  //  2023-4-1開始新規定
            int code;
            if (!int.TryParse(receiptNo, out code))
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

            if (checkSum % checkCode == 0)
                return true;

            if ((code % 100) / 10 == 7 && (checkSum + 1) % checkCode == 0)
                return true;

            return false;

        }

        public static string CreateRandomStringCode(this int codeLength)
        {
            //驗證碼的字元集，去掉了一些容易混淆的字元
            var seed = DateTime.Now.Ticks;
            char[] sCode = new char[codeLength];

            //生成驗證碼字串
            for (int n = 0; n < codeLength; n++)
            {
                sCode[n] = DISCERNIBLE_CODE[seed % DISCERNIBLE_CODE.Length];
                seed /= DISCERNIBLE_CODE.Length;
            }
            return new String(sCode);
        }

        public static string GenerateRandomCode(this int codeLength)
        {
            //驗證碼的字元集，去掉了一些容易混淆的字元
            Thread.Sleep(1);
            char[] sCode = new char[codeLength];

            //生成驗證碼字串
            for (int n = 0; n < codeLength; n++)
            {
                sCode[n] = NUMERIC_STRING[ValidityAgent.RANDOM.Next(NUMERIC_STRING.Length)];
            }
            return new String(sCode);
        }

        public static String GenerateHexCode(this int length)
        {
            StringBuilder sb = new StringBuilder(length);

            for (int i = 0; i < length; i++)
            {
                int index = ValidityAgent.RANDOM.Next(HEX_NUMBER.Length);
                sb.Append(HEX_NUMBER[index]);
            }

            return sb.ToString();
        }


        public static char[] GetChineseNumberSeries(this int number, int length)
        {
            char[] result = new char[length];
            for (int i = 0; i < length; i++)
            {
                result[i] = __CHINESE_NUM_CHAR[number % 10];
                number /= 10;
            }
            return result;
        }

        public static byte[] UploadData(this XmlNode data, String url, int timeout = 0)
        {
            using (WebClientEx client = new WebClientEx())
            {
                if (timeout > 0)
                {
                    client.Timeout = timeout;
                }
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

        public static string GetDateStylePath(this string prefix)
        {
            return GetDateStylePath(prefix, DateTime.Now);
        }

        public static string GetDateStylePath(this string prefix, DateTime date)
        {
            string path = Path.Combine(prefix, $"{date:yyyy}", $"{date:MM}", $"{date:dd}");

            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);

            return path;
        }

        public static String ToHexString(this byte[] data, String format = "X2", String delimiter = "")
        {
            return String.Join(delimiter, data.Select(b => b.ToString(format)));
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

        public static char ConvertToHalfWidthChar(this char ch)
        {
            for (int i = 0; i < HELFWIDTH_CODE.Length; i++)
            {
                if (FULLWIDTH_CODE[i] == ch)
                    return HELFWIDTH_CODE[i];
            }
            return ch;
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
        public static bool ValidateString(this String _value, int _kind)
        {
            string RegularExpressions = null;
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
                default:
                    break;
            }
            if (_kind < 29)
            {
                Match m = Regex.Match(_value, RegularExpressions);
                if (m.Success)
                    return true;
                else
                    return false;
            }
            else
            {

                return false;
            }
        }
        #endregion

        /// <summary>
        /// 驗證Email格式
        /// </summary>
        /// <param name="email"></param>
        /// <returns></returns>
        public static bool IsEmail(this string email)
        {
            var isEmail = Regex.IsMatch(email, @"^([\w-]+\.)*?[\w-]+@[\w-]+\.([\w-]+\.)*?[\w]+$");
            return isEmail;
        }


        /// <summary>
        /// 驗證手機格式
        /// </summary>
        /// <param name="mobilPhone"></param>
        /// <returns></returns>
        public static bool IsMobilPhone(this string mobilPhone)
        {
            return Regex.IsMatch(mobilPhone, @"^09[0-9]{8}$") && !Regex.IsMatch(mobilPhone, "(\\d)\\1{5,}");
        }

        /// <summary>
        /// 驗證電話格式
        /// </summary>
        /// <param name="tel"></param>
        /// <returns></returns>
        public static bool IsTel(this string tel)
        {
            var isTel = Regex.IsMatch(tel, @"^(\d{2,4}-)?\d{6,8}$");
            return isTel;
        }

        public static String MakePassword(this String password)
        {
            if (String.IsNullOrEmpty(password))
                return null;
            return Convert.ToBase64String(MD5.Create().ComputeHash(Encoding.Default.GetBytes(password)));
        }

        //public static string MakePassword(this string password)
        //{
        //    if (String.IsNullOrEmpty(password))
        //        return null;
        //    MD5 md5 = MD5.Create();
        //    return String.Join("", md5.ComputeHash(Encoding.Default.GetBytes(password)).Select(i => String.Format("{0:X02}", i)));
        //}

        public static string HashPassword(this string password)
        {
            MD5 md5 = MD5.Create();
            return String.Join("", md5.ComputeHash(Encoding.Default.GetBytes(password)).Select(i => String.Format("{0:X02}", i)));
        }


    }
}

