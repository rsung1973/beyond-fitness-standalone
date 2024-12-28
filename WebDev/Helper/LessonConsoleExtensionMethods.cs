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
    public static class LessonConsoleExtensionMethods
    {
        public static IQueryable<RegisterLesson> PromptMemberExerciseRegisterLesson(this GenericManager<BFDataContext> models, IQueryable<RegisterLesson> items = null)
                
        {
            if (items == null)
            {
                items = models.GetTable<RegisterLesson>();
            }

            var staff = models.GetTable<UserRoleAuthorization>().Where(a => Naming.StaffRole.Contains(a.RoleID));

            items = items.Where(r => staff.Any(s => s.UID == r.UID));
            //items = items.Join(models.GetTable<LessonPriceType>()
            //                .Where(p => p.Status == (int)Naming.LessonPriceStatus.教練PI || p.IsWelfareGiftLesson != null),
            //                r => r.ClassLevel, p => p.PriceID, (r, p) => r);

            return items;
        }

        public static IQueryable<LessonTime> PromptMemberExerciseLessons(this GenericManager<BFDataContext> models,IQueryable<RegisterLesson> items = null)
                
        {
            return models.PromptMemberExerciseRegisterLesson(items)
                .TotalRegisterLessonItems(models);
        }

        public static IQueryable<LessonTime> FilterByUserRoleScope(this IQueryable<LessonTime> items, GenericManager<BFDataContext> models, UserProfile profile)
                
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

        public static String PowerAbliityCss(this PersonalExercisePurpose item, String append = null)
        {
            String css = "col-red";
            if (item != null && item.PowerAbility != null)
            {
                css = item.PowerAbility.Contains("初")
                           ? "col-amber"
                           : item.PowerAbility.Contains("中")
                               ? "col-green"
                               : "col-red";
            }
            return append == null ? css : $"{css} {append}";
        }

        public static String PowerAbliityCss(this Naming.PowerAbilityLevel? item, String append = null)
        {
            String css = item == Naming.PowerAbilityLevel.初階
                        ? "col-green"
                        : item == Naming.PowerAbilityLevel.中階
                            ? "col-amber"
                            : item == Naming.PowerAbilityLevel.高階
                                ? "col-red"
                                : "col-red";
            return append == null ? css : $"{css} {append}";
        }

    }
}