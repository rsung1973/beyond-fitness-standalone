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
using Microsoft.AspNetCore.Mvc;

using CommonLib.DataAccess;
//using MessagingToolkit.QRCode.Codec;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using DocumentFormat.OpenXml.Wordprocessing;


namespace WebHome.Helper
{
    public class LessonTimeAchievementHelper
            
    {
        private readonly GenericManager<BFDataContext> models;
        public LessonTimeAchievementHelper(GenericManager<BFDataContext> models)
        {
            this.models = models;
        }

        public IQueryable<V_Tuition> LessonItems { get; set; }


        public IQueryable<V_Tuition> ExclusivePILesson => LessonItems
                    .Where(l => l.PriceStatus != (int)Naming.LessonPriceStatus.自主訓練)
                    .Where(l => !l.ELStatus.HasValue || l.ELStatus != (int)Naming.LessonPriceStatus.自主訓練);

        public IQueryable<V_Tuition> PILesson => LessonItems
                    .Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練
                        || l.ELStatus == (int)Naming.LessonPriceStatus.自主訓練);

        //public IQueryable<V_Tuition> SRSession
        //{
        //    get
        //    {
        //        IQueryable<LessonPriceProperty> SR = models.GetTable<LessonPriceProperty>().Where(p => p.PropertyID == (int)Naming.LessonPriceFeature.運動恢復課程);
        //        return LessonItems
        //            .Where(v => SR.Any(p => p.PriceID == v.PriceID));
        //    }
        //}

        //public IQueryable<V_Tuition> SDSession
        //{
        //    get
        //    {
        //        IQueryable<LessonPriceProperty> SD = models.GetTable<LessonPriceProperty>().Where(p => p.PropertyID == (int)Naming.LessonPriceFeature.營養課程);
        //        return LessonItems
        //            .Where(v => SD.Any(p => p.PriceID == v.PriceID));
        //    }
        //}

        public IQueryable<V_Tuition> SettlementFullAchievement => ExclusivePILesson
            .Where(t => t.CoachAttendance.HasValue && t.CommitAttendance.HasValue);

        public IQueryable<V_Tuition> SettlementHalfAchievement => LessonItems
                    .Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練
                        || l.ELStatus == (int)Naming.LessonPriceStatus.自主訓練
                        || (!l.CommitAttendance.HasValue && l.CoachAttendance.HasValue)
                        || (l.CommitAttendance.HasValue && !l.CoachAttendance.HasValue));

        public IQueryable<V_Tuition> SettlementVainAchievement => LessonItems
                    .Where(l => !l.CommitAttendance.HasValue)
                    .Where(l => !l.CoachAttendance.HasValue);

        public IQueryable<V_Tuition> SettlementHalfAchievementForShare => ExclusivePILesson
                    .Where(l => (!l.CommitAttendance.HasValue && l.CoachAttendance.HasValue)
                            || (l.CommitAttendance.HasValue && !l.CoachAttendance.HasValue));

        public IQueryable<V_Tuition> SettlementPILesson => LessonItems
                    .Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練
                        || l.ELStatus == (int)Naming.LessonPriceStatus.自主訓練);

        public IQueryable<V_Tuition> PerformanceCountableLesson => LessonItems
                    .Where(l => l.CoachAttendance.HasValue
                        || (!l.CoachAttendance.HasValue && !(l.PriceStatus==(int)Naming.LessonPriceFeature.體驗課程 || l.ELStatus == (int)Naming.LessonPriceFeature.體驗課程)));

        public IQueryable<V_Tuition> PTSession => LessonItems
                    .Where(t => BusinessConsoleExtensions.SessionScopeForComleteLessonCount.Contains(t.PriceStatus)
                            || BusinessConsoleExtensions.SessionScopeForComleteLessonCount.Contains(t.ELStatus));

        public IQueryable<V_TuitionCoach> PTTuitionCoach => PTSession.Join(models.GetTable<V_TuitionCoach>(), p => p.LessonID, t => t.LessonID, (p, t) => t);

        public IQueryable<V_Tuition> HSSession => LessonItems
            .Where(t => BusinessConsoleExtensions.HSSessionScope.Contains(t.PriceStatus));

        public IQueryable<V_Tuition> ContractPTSession => LessonItems
                    .Where(t => BusinessConsoleExtensions.SessionScopeForComleteLessonCount.Contains(t.PriceStatus));

        public IQueryable<V_Tuition> EnterprisePTSession => LessonItems
                    .Where(t => BusinessConsoleExtensions.SessionScopeForComleteLessonCount.Contains(t.ELStatus));

        public IQueryable<V_Tuition> FilterByWholeOne(IQueryable<V_Tuition> items)
        {
            IQueryable<LessonPriceProperty> halfCount = models.GetTable<LessonPriceProperty>().Where(p => p.PropertyID == (int)Naming.LessonPriceFeature.半堂計算);
            return items.Where(v => !halfCount.Any(p => p.PriceID == v.PriceID));
        }

        public IQueryable<V_Tuition> FilterByHalfCount(IQueryable<V_Tuition> items)
        {
            IQueryable<LessonPriceProperty> halfCount = models.GetTable<LessonPriceProperty>().Where(p => p.PropertyID == (int)Naming.LessonPriceFeature.半堂計算);
            return items.Where(v => halfCount.Any(p => p.PriceID == v.PriceID));
        }

        public IQueryable<V_Tuition> FilterByBonusExchangedSRSession(IQueryable<V_Tuition> items)
        {
            IQueryable<LessonPriceProperty> SR = models.GetTable<LessonPriceProperty>().Where(p => p.PropertyID == (int)Naming.LessonPriceFeature.運動恢復課程);
            return items
                .Where(v => v.PriceStatus == (int)Naming.LessonPriceStatus.點數兌換課程)
                .Where(v => SR.Any(p => p.PriceID == v.PriceID));
        }

        public int?[] SessionScopeForPrimary { get; } = new int?[]
        {
                    (int)Naming.LessonPriceStatus.一般課程,
                    (int)Naming.LessonPriceStatus.已刪除,
                    (int)Naming.LessonPriceStatus.點數兌換課程,
                    (int)Naming.LessonPriceStatus.員工福利課程,
                    (int)Naming.LessonPriceStatus.團體學員課程,
                    (int)Naming.LessonPriceStatus.自主訓練,
                    (int)Naming.LessonPriceStatus.體驗課程,
        };

        public int?[] ExclusivePropertiesFromSessionScopeForPrimary { get; } = new int?[]
        {
                    (int)Naming.LessonPriceFeature.營養課程,
                    (int)Naming.LessonPriceFeature.運動防護課程,
                    (int)Naming.LessonPriceFeature.運動恢復課程,
        };

        public IQueryable<V_Tuition> SessionForPrimaryCoach
        {
            get
            {
                IQueryable<LessonPriceProperty> exclusive = models.GetTable<LessonPriceProperty>()
                        .Where(p => ExclusivePropertiesFromSessionScopeForPrimary.Contains(p.PropertyID));

                return LessonItems.Where(t => SessionScopeForPrimary.Contains(t.PriceStatus)
                                            || SessionScopeForPrimary.Contains(t.ELStatus))
                                    .Where(t => !exclusive.Any(p => p.PriceID == t.PriceID));
            }
        }


    }
}