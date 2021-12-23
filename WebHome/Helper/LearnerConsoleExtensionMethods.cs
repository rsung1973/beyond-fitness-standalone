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
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using CommonLib.DataAccess;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;


namespace WebHome.Helper
{
    public static class LearnerConsoleExtensionMethods
    {

        public static IQueryable<UserProfile> PromptLearnerByName(this String userName, GenericManager<BFDataContext> models, bool includeTrial = false)
                
        {
            var items = userName.PromptUserProfileByName(models, models.PromptLearner(includeTrial));
            return items;
        }


        public static IQueryable<UserProfile> PromptUserProfileByName(this String userName, GenericManager<BFDataContext> models, IQueryable<UserProfile> items = null)
                
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

        public static String PreparePreivew(this Models.DataEntity.Attachment item, String previewStore)
        {
            if (item != null)
            {
                if (System.IO.File.Exists(item.StoredPath))
                {
                    previewStore.CheckStoredPath();
                    String fileName = $"{Path.GetFileNameWithoutExtension(item.StoredPath)}.jpg";

                    using (Bitmap img = new Bitmap(item.StoredPath))
                    {
                        using (Bitmap m = new Bitmap(img, new Size(Startup.Properties.GetValue<int>("ResourceMaxWidth"), img.Height * Startup.Properties.GetValue<int>("ResourceMaxWidth") / img.Width)))
                        {
                            m.Save(Path.Combine(previewStore, fileName), ImageFormat.Jpeg);
                        }
                    }
                    return fileName;
                }
            }
            return null;
        }

    }
}