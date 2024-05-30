using CommonLib.DataAccess;
using WebHome.Models.DataEntity;

namespace WebHome.Helper
{
    public static class BusinessExtensions
    {
        public static UserProfile LoadInstance(this UserProfile profile, GenericManager<BFDataContext> models)
        {
            return models.GetTable<UserProfile>().Where(u => u.UID == profile.UID).First();
        }

        public static String CreatePIN()
        {
            var pinCode = DateTime.Now.Ticks % 1000000;
            return $"{(char)('A' + (pinCode % 26))}{(char)('A' + (pinCode % 1000 % 26))}-{pinCode:000000}";
        }
        
        public static string CutString(this string input,char separator)
        {
            // 檢查輸入字串是否包含'-'字符
            int index = input.IndexOf(separator);

            // 如果包含'-'字符
            if (index != -1)
            {
                // 回傳'-'之前的內容
                return input.Substring(0, index);
            }
            else
            {
                // 如果不包含'-'字符，回傳整個字串
                return input;
            }
        }
    }
}
