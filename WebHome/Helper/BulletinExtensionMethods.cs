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

using CommonLib.DataAccess;

using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;


namespace WebHome.Helper
{
    public static class BulletinExtensionMethods
    {
        public static void InitializeSystemAnnouncement(this UserProfile profile, GenericManager<BFDataContext> models)
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