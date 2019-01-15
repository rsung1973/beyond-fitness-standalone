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
using Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;

namespace WebHome.Helper
{
    public static class LessonConsoleExtensionMethods
    {
        public static IQueryable<RegisterLesson> PromptMemberExerciseRegisterLesson<TEntity>(this ModelSource<TEntity> models, IQueryable<RegisterLesson> items = null)
                where TEntity : class, new()
        {
            if (items == null)
                items = models.GetTable<RegisterLesson>();

            items = items.Join(models.GetTable<LessonPriceType>()
                            .Where(p => p.Status == (int)Naming.LessonPriceStatus.教練PI || p.IsWelfareGiftLesson != null),
                            r => r.ClassLevel, p => p.PriceID, (r, p) => r);

            return items;
        }

        public static IQueryable<LessonTime> PromptMemberExerciseLessons<TEntity>(this ModelSource<TEntity> models,IQueryable<RegisterLesson> items = null)
                where TEntity : class, new()
        {
            return models.PromptMemberExerciseRegisterLesson(items)
                .TotalLessons(models);
        }

        public static IQueryable<LessonTime> FilterByUserRoleScope<TEntity>(this IQueryable<LessonTime> items, ModelSource<TEntity> models, UserProfile profile)
                where TEntity : class, new()
        {
            if (profile.IsAssistant())
            {
                return items;
            }
            else if (profile.IsManager() || profile.IsViceManager())
            {
                return items.Join(profile.GetServingCoachInSameStore(models), 
                    l => l.AttendingCoach, s => s.CoachID, (l, s) => l);
            }
            else if (profile.IsCoach())
            {
                return items.Where(c => c.AttendingCoach == profile.UID);
            }
            else
            {
                return items.Where(c => false);
            }
        }

    }
}