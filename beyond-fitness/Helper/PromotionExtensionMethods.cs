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
    public static class PromotionExtensionMethods
    {
        public static IQueryable<PDQGroup> GetBonusPromotion<TEntity>(this ModelSource<TEntity> models)
            where TEntity : class, new()
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