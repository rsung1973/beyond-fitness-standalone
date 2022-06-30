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
    public static class UserProfileExtensions
    {

        public static IQueryable<UserProfile> FilterByLearner(this IQueryable<UserProfile> items, GenericManager<BFDataContext> models, bool includePreliminary = false)
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

        public static IQueryable<ServingCoach> PromptEffectiveCoach(this GenericManager<BFDataContext> models, IQueryable<UserProfile> items = null)
        {
            if (items == null)
            {
                items = models.GetTable<UserProfile>();
            }

            items = items.Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked);
            return models.GetTable<ServingCoach>()
                    .Where(c => c.LevelID > (int)Naming.ProfessionLevelDefinition.Preliminary)
                    .Join(items, c => c.CoachID, u => u.UID, (c, u) => c);
        }

        public static IQueryable<UserProfile> PromptEffectiveEmployee(this GenericManager<BFDataContext> models, IQueryable<UserProfile> items = null)
        {
            if (items == null)
            {
                items = models.GetTable<UserProfile>();
            }

            items = items.Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked);
            return models.GetTable<ForEmployee>()
                    .Join(items, c => c.UID, u => u.UID, (c, u) => u);
        }

        public static IQueryable<UserProfile> PromptLearnerAboutToBirth(this GenericManager<BFDataContext> models, int days = 14)
        {
            DateTime start = DateTime.Today;
            DateTime end = DateTime.Today.AddDays(days);
            //int startIdx = start.Month * 100 + start.Day;
            //int endIdx = end.Month * 100 + end.Day;
            //if (startIdx < endIdx)
            //{
            //    return models.GetTable<UserProfile>().Where(u => u.Birthday.HasValue
            //                && u.BirthdateIndex >= startIdx
            //                    && u.BirthdateIndex <= endIdx);
            //}
            //else
            //{
            //    return models.GetTable<UserProfile>().Where(u => u.Birthday.HasValue
            //                && ((u.BirthdateIndex >= startIdx
            //                        && u.BirthdateIndex <= 1231)
            //                    || u.BirthdateIndex <= endIdx));

            //}

            return models.PromptLearner(true).FilterLearnerWithBirthday(start, end);
        }

        public static IQueryable<UserProfile> PromptLearnerWithBirthday(this ServingCoach coach, GenericManager<BFDataContext> models, int incomingDays = 14)
        {
            return coach.PromptLearnerWithBirthday(models, DateTime.Today, DateTime.Today.AddDays(incomingDays));
        }

        public static IQueryable<UserProfile> PromptLearnerWithBirthdayThisWeek(this ServingCoach coach, GenericManager<BFDataContext> models)
        {
            DateTime start = DateTime.Today.FirstDayOfWeek();
            return coach.PromptLearnerWithBirthday(models, start, start.AddDays(7));
        }

        public static IQueryable<UserProfile> PromptLearnerWithBirthday(this ServingCoach coach, GenericManager<BFDataContext> models, DateTime startDate, DateTime endDate)
        {
            IQueryable<UserProfile> items = coach.PromptLearnerByAdvisor(models);
            return items.FilterLearnerWithBirthday(startDate, endDate);
        }

        public static IQueryable<UserProfile> PromptLearnerByAdvisor(this ServingCoach coach, GenericManager<BFDataContext> models)
        {
            IQueryable<UserProfile> items = models.PromptLearner();
            return items.FilterLearnerByAdvisor(coach, models);
        }

        public static IQueryable<UserProfile> FilterLearnerByAdvisor(this IQueryable<UserProfile> items, ServingCoach coach, GenericManager<BFDataContext> models)
        {
            if (coach != null)
            {
                items = items.Join(models.GetTable<LearnerFitnessAdvisor>().Where(a => a.CoachID == coach.CoachID),
                                    u => u.UID, a => a.UID, (u, a) => u);
            }
            else
            {
                return items.Where(u => false);
            }

            return items;
        }

        public static IQueryable<UserProfile> FilterLearnerWithBirthday(this IQueryable<UserProfile> items, DateTime startDate, DateTime endDate)
        {

            int startDay = startDate.Month * 100 + startDate.Day;
            int endDay = endDate.Month * 100 + endDate.Day;
            if (startDay < endDay)
            {
                return items.Where(u => u.BirthdateIndex >= startDay
                        && u.BirthdateIndex <= endDay)
                    .OrderBy(u => u.BirthdateIndex);
            }
            else if (startDay == endDay)
            {
                return items.Where(u => u.BirthdateIndex == startDay);
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

        public static IQueryable<UserProfile> PromptLearner(this GenericManager<BFDataContext> models, bool includeTrial = false)
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
                    .Where(l => roleItems.Any(r => r.UID == l.UID)
                        || authItems.Any(r => r.UID == l.UID));

            return items;
        }

    }
}