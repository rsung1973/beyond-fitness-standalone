using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using System.Web.UI.WebControls;
using CommonLib.DataAccess;
using DocumentFormat.OpenXml.Spreadsheet;
using Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;

namespace WebHome.Helper
{
    public static class LearnerConsoleExtensionMethods
    {

        public static IQueryable<UserProfile> PromptLearnerByName<TEntity>(this String userName, ModelSource<TEntity> models, bool includeTrial = false)
                where TEntity : class, new()
        {
            var items = userName.PromptUserProfileByName(models, models.PromptLearner());
            return items;
        }


        public static IQueryable<UserProfile> PromptUserProfileByName<TEntity>(this String userName, ModelSource<TEntity> models, IQueryable<UserProfile> items = null)
                where TEntity : class, new()
        {
            if (items == null)
            {
                items = models.GetTable<UserProfile>();
            }

            return items.Where(l => (l.RealName.Contains(userName) || l.Nickname.Contains(userName))
                        && (l.UserProfileExtension != null));

        }


    }
}