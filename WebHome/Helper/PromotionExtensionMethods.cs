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
    public static class PromotionExtensionMethods
    {
        public static IQueryable<PDQGroup> GetBonusPromotion(this GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<PDQGroup>().Join(
                    models.GetTable<PDQQuestion>().Join(
                            models.GetTable<PDQQuestionExtension>()
                                .Where(x => x.AwardingAction.HasValue),
                            q => q.QuestionID, x => x.QuestionID, (q, x) => q),
                        g => g.GroupID, q => q.GroupID, (g, q) => g);
        }

    }
}