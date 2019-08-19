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

        private IQueryable<LessonTime> _items;
        public IQueryable<LessonTime> LessonItems
        {
            get
            {
                return _items.Join(Achievement, l => l.LessonID, v => v.LessonID, (l, v) => l);
            }
            set
            {
                _items = value;
                SettlementFullAchievement = _items.Join(FullAchievementLesson, l => l.LessonID, v => v.LessonID, (l, v) => l);
                SettlementHalfAchievement = _items.Join(HalfAchievementLesson, l => l.LessonID, v => v.LessonID, (l, v) => l);
                SettlementHalfAchievementForShare = _items.Join(HalfAchievementLessonForShare, l => l.LessonID, v => v.LessonID, (l, v) => l);
                SettlementPILesson = _items.Join(PILesson, l => l.LessonID, v => v.LessonID, (l, v) => l);
            }
        }

        IQueryable<V_LessonTime> Achievement => models.GetTable<V_LessonTime>()
            .Where(l => l.PriceStatus != (int)Naming.LessonPriceStatus.教練PI)
            .Where(l => l.PriceStatus != (int)Naming.LessonPriceStatus.自由教練預約)
            .Where(l => l.CoachAttendance.HasValue || l.CompleteDate.HasValue);

        IQueryable<V_LessonTime> ExclusivePILesson => Achievement
                    .Where(l => l.PriceStatus != (int)Naming.LessonPriceStatus.自主訓練)
                    .Where(l => !l.ELStatus.HasValue || l.ELStatus != (int)Naming.LessonPriceStatus.自主訓練);

        IQueryable<V_LessonTime> FullAchievementLesson => ExclusivePILesson
            .Where(t => t.CoachAttendance.HasValue && t.CommitAttendance.HasValue);

        IQueryable<V_LessonTime> HalfAchievementLesson => Achievement
                    .Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練
                        || l.ELStatus == (int)Naming.LessonPriceStatus.自主訓練
                        || (!l.CommitAttendance.HasValue && l.CoachAttendance.HasValue)
                        || (l.CommitAttendance.HasValue && !l.CoachAttendance.HasValue));

        IQueryable<V_LessonTime> HalfAchievementLessonForShare => ExclusivePILesson
                    .Where(l => (!l.CommitAttendance.HasValue && l.CoachAttendance.HasValue)
                            || (l.CommitAttendance.HasValue && !l.CoachAttendance.HasValue));

        IQueryable<V_LessonTime> PILesson => Achievement
                    .Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練
                        || l.ELStatus == (int)Naming.LessonPriceStatus.自主訓練);

        public IQueryable<LessonTime> SettlementFullAchievement
        {
            get;
            private set;
        }

        public IQueryable<LessonTime> SettlementHalfAchievement
        {
            get;
            private set;
        }

        public IQueryable<LessonTime> SettlementHalfAchievementForShare
        {
            get;
            private set;
        }
        public IQueryable<LessonTime> SettlementPILesson
        {
            get;
            private set;
        }
    }
}