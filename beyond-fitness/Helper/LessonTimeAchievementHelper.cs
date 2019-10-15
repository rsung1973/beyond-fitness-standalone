using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Mvc;

using CommonLib.DataAccess;
using MessagingToolkit.QRCode.Codec;
using Utility;
using WebHome.Controllers;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;

namespace WebHome.Helper
{
    public class LessonTimeAchievementHelper<TEntity>
            where TEntity : class, new()
    {
        private readonly ModelSource<TEntity> models;
        public LessonTimeAchievementHelper(ModelSource<TEntity> models)
        {
            this.models = models;
        }

        public IQueryable<V_Tuition> LessonItems { get; set; }


        public IQueryable<V_Tuition> ExclusivePILesson => LessonItems
                    .Where(l => l.PriceStatus != (int)Naming.LessonPriceStatus.自主訓練)
                    .Where(l => !l.ELStatus.HasValue || l.ELStatus != (int)Naming.LessonPriceStatus.自主訓練);

        public IQueryable<V_Tuition> SettlementFullAchievement => ExclusivePILesson
            .Where(t => t.CoachAttendance.HasValue && t.CommitAttendance.HasValue);

        public IQueryable<V_Tuition> SettlementHalfAchievement => LessonItems
                    .Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練
                        || l.ELStatus == (int)Naming.LessonPriceStatus.自主訓練
                        || (!l.CommitAttendance.HasValue && l.CoachAttendance.HasValue)
                        || (l.CommitAttendance.HasValue && !l.CoachAttendance.HasValue));

        public IQueryable<V_Tuition> SettlementHalfAchievementForShare => ExclusivePILesson
                    .Where(l => (!l.CommitAttendance.HasValue && l.CoachAttendance.HasValue)
                            || (l.CommitAttendance.HasValue && !l.CoachAttendance.HasValue));

        public IQueryable<V_Tuition> SettlementPILesson => LessonItems
                    .Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練
                        || l.ELStatus == (int)Naming.LessonPriceStatus.自主訓練);

        public IQueryable<V_Tuition> PerformanceCountableLesson => LessonItems
                    .Where(l => l.CoachAttendance.HasValue
                        || (!l.CoachAttendance.HasValue && !(l.PriceStatus==(int)Naming.LessonPriceFeature.體驗課程 || l.ELStatus == (int)Naming.LessonPriceFeature.體驗課程)));

    }
}