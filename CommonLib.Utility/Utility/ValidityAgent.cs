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
    /// Summary description for ValueValidity.
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

            if (checkSum % 10 == 0)
                return true;

            if ((code % 100) / 10 == 7 && (checkSum + 1) % 10 == 0)
                return true;

            return false;

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

    }
}
