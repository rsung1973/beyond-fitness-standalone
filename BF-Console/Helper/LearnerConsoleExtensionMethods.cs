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
    public static class LearnerConsoleExtensionMethods
    {

        public static IQueryable<UserProfile> PromptLearnerWithBirthday<TEntity>(this ServingCoach coach,  ModelSource<TEntity> models,int incomingDays = 14)
                where TEntity : class, new()
        {
            IQueryable<UserProfile> items = models.GetTable<UserProfile>();
            if (coach != null)
            {
                items = items.Join(models.GetTable<LearnerFitnessAdvisor>().Where(a => a.CoachID == coach.CoachID),
                                    u => u.UID, a => a.UID, (u, a) => u);
            }
            else
            {
                return items.Where(u => false);
            }

            int startDay = DateTime.Today.Month * 100 + DateTime.Today.Day;
            var endDate = DateTime.Today.AddDays(incomingDays);
            int endDay = endDate.Month * 100 + endDate.Day;
            if (startDay < endDay)
            {
                return items.Where(u => u.BirthdateIndex >= startDay
                        && u.BirthdateIndex <= endDay)
                    .OrderBy(u => u.BirthdateIndex);
            }
            else
            {
                return items
                        .Where(u => u.BirthdateIndex >= startDay)
                        .OrderBy(u => u.BirthdateIndex)
                        .Union(items
                            .Where(u => u.BirthdateIndex <= endDay)
                            .OrderBy(u => u.BirthdateIndex));
            }
        }

        public static IQueryable<UserProfile> PromptLearnerByName<TEntity>(this String userName, ModelSource<TEntity> models, bool includeTrial = false)
                where TEntity : class, new()
        {
            IQueryable<UserRole> roleItems = models.GetTable<UserRole>();
            IQueryable<UserRoleAuthorization> authItems = models.GetTable<UserRoleAuthorization>();
            if (includeTrial)
            {
                roleItems = roleItems.Where(r => r.RoleID == (int)Naming.RoleID.Learner
                        || r.RoleID == (int)Naming.RoleID.Preliminary
                        || r.RoleID == (int)Naming.RoleID.Assistant);
                authItems = authItems.Where(r => r.RoleID == (int)Naming.RoleID.Learner
                        || r.RoleID == (int)Naming.RoleID.Preliminary
                        || r.RoleID == (int)Naming.RoleID.Assistant);
            }
            else
            {
                roleItems = roleItems.Where(r => r.RoleID == (int)Naming.RoleID.Learner);
                authItems = authItems.Where(r => r.RoleID == (int)Naming.RoleID.Learner);
            }

            var items = models.GetTable<UserProfile>()
                    .Where(l => (l.RealName.Contains(userName) || l.Nickname.Contains(userName))
                        && (l.UserProfileExtension != null))
                    .Where(l => roleItems.Any(r => r.UID == l.UID)
                        || authItems.Any(r => r.UID == l.UID));

            return items;
        }


    }
}