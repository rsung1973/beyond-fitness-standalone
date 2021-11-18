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
//using MessagingToolkit.QRCode.Codec;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;


namespace WebHome.Helper
{
    public static class UserEventExtensionMethods
    {
        public static IQueryable<UserEvent> PromptMemberEvents(this GenericManager<BFDataContext> models,UserProfile profile)
                
        {
            return models.GetTable<UserEvent>()
                .Where(e => e.EventType == 1)
                .Where(t => t.UID == profile.UID
                    || t.GroupEvent.Any(g => g.UID == profile.UID));
        }
    }
}