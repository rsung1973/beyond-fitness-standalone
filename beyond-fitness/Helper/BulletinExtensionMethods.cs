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

using CommonLib.DataAccess;
using MessagingToolkit.QRCode.Codec;
using Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;

namespace WebHome.Helper
{
    public static class BulletinExtensionMethods
    {
        public static void InitializeSystemAnnouncement<TEntity>(this UserProfile profile, ModelSource<TEntity> models)
                    where TEntity : class, new()
        {
            models.ExecuteCommand(@"INSERT INTO UserEvent
                                    (UID, Title, StartDate, EndDate, SystemEventID)
                        SELECT  {0}, Title, StartDate, EndDate, EventID
                        FROM     SystemEventBulletin 
                        where EndDate >= {1} And (EventID NOT IN
                           (SELECT  SystemEventID
                           FROM     UserEvent
                           WHERE   (UID = {0})))", profile.UID, DateTime.Today);
        }

    }
}