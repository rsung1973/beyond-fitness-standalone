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
            var items = userName.PromptUserProfileByName(models, models.PromptLearner(includeTrial));
            return items;
        }


        public static IQueryable<UserProfile> PromptUserProfileByName<TEntity>(this String userName, ModelSource<TEntity> models, IQueryable<UserProfile> items = null)
                where TEntity : class, new()
        {
            if (items == null)
            {
                items = models.GetTable<UserProfile>();
            }

            return items
                    .Where(l => l.UserProfileExtension != null)
                    .Where(l => l.RealName.Contains(userName)
                        || l.Nickname.Contains(userName)
                        || l.Phone == userName);

        }

        public static String PreparePreivew(this Models.DataEntity.Attachment item,String previewStore)
        {
            if (item != null)
            {
                if (System.IO.File.Exists(item.StoredPath))
                {
                    previewStore = previewStore.CheckStoredPath();
                    String fileName = $"{Path.GetFileNameWithoutExtension(item.StoredPath)}.jpg";

                    using (Bitmap img = new Bitmap(item.StoredPath))
                    {
                        using (Bitmap m = new Bitmap(img, new Size(Settings.Default.ResourceMaxWidth, img.Height * Settings.Default.ResourceMaxWidth / img.Width)))
                        {
                            m.Save(Path.Combine(previewStore,fileName), ImageFormat.Jpeg);
                        }
                    }
                    return fileName;
                }
            }
            return null;
        }
    }
}