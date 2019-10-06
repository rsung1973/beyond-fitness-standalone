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
    public static class UserProfileExtensions
    {

        public static IQueryable<UserProfile> FilterByLearner<TEntity>(this IQueryable<UserProfile> items,  ModelSource<TEntity> models,bool includePreliminary = false)
                where TEntity : class, new()
        {
            if (includePreliminary == true)
            {
                return items.Where(l => l.UserRole.Any(r => r.RoleID == (int)Naming.RoleID.Learner
                            || r.RoleID == (int)Naming.RoleID.Preliminary)
                        || l.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Learner));
            }
            else
            {
                return items.Where(l => l.UserRole.Any(r => r.RoleID == (int)Naming.RoleID.Learner)
                        || l.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Learner));
            }
        }

        public static IQueryable<ServingCoach> PromptEffectiveCoach<TEntity>(this ModelSource<TEntity> models)
                where TEntity : class, new()
        {
            return models.GetTable<ServingCoach>()
                    .Where(c => c.LevelID > (int)Naming.ProfessionLevelDefinition.Preliminary)
                    .Join(models.GetTable<UserProfile>()
                            .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked),
                        c => c.CoachID, u => u.UID, (c, u) => c);
        }

        public static IQueryable<UserProfile> PromptLearnerAboutToBirth<TEntity>(this ModelSource<TEntity> models,int days = 14)
            where TEntity : class, new()
        {
            DateTime start = DateTime.Today;
            DateTime end = DateTime.Today.AddDays(days);
            int startIdx = start.Month * 100 + start.Day;
            int endIdx = end.Month * 100 + end.Day;
            if (startIdx < endIdx)
            {
                return models.GetTable<UserProfile>().Where(u => u.Birthday.HasValue
                            && u.BirthdateIndex >= startIdx
                                && u.BirthdateIndex <= endIdx);
            }
            else
            {
                return models.GetTable<UserProfile>().Where(u => u.Birthday.HasValue
                            && ((u.BirthdateIndex >= startIdx
                                    && u.BirthdateIndex <= 1231)
                                || u.BirthdateIndex <= endIdx));

            }
        }


    }
}