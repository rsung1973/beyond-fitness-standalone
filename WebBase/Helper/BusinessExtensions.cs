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

    }
}
