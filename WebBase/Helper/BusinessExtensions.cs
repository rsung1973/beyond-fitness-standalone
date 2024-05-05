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

    }
}
