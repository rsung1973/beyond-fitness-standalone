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
    public static class CourseContractExtensionMethods
    {
        public static IQueryable<CourseContract> PromptExpiringContract<TEntity>(this ModelSource<TEntity> models)
                where TEntity : class, new()
        {
            var revisionID = models.GetTable<CourseContractRevision>().Where(r => r.Reason == "展延")
                .Select(r => r.RevisionID);
            var items = models.GetTable<CourseContract>()
                .Where(c => !c.RegisterLessonContract.Any(r => r.RegisterLesson.Attended == (int)Naming.LessonStatus.課程結束))
                .Where(c => c.Expiration < DateTime.Today.AddMonths(1))
                .Where(c => !revisionID.Any(r => r == c.ContractID));
            return items;
        }

        public static IQueryable<CourseContract> PromptEffectiveContract<TEntity>(this ModelSource<TEntity> models)
                where TEntity : class, new()
        {
            var revisionID = models.GetTable<CourseContractRevision>().Where(r => r.Reason == "展延")
                .Select(r => r.RevisionID);
            var items = models.GetTable<CourseContract>()
                .Where(c => !c.RegisterLessonContract.Any(r => r.RegisterLesson.Attended == (int)Naming.LessonStatus.課程結束))
                .Where(c => !revisionID.Any(r => r == c.ContractID));
            return items;
        }

        public static IQueryable<CourseContractRevision> PromptEffectiveRevision<TEntity>(this ModelSource<TEntity> models, DateTime? dateFrom, DateTime? dateTo)
                where TEntity : class, new()
        {
            IQueryable<CourseContract> items = models.GetTable<CourseContract>();
            if (dateFrom.HasValue)
                items = items.Where(c => c.EffectiveDate >= dateFrom);
            if (dateTo.HasValue)
                items = items.Where(c => c.EffectiveDate < dateTo);
            return models.GetTable<CourseContractRevision>()
                .Join(items, r => r.RevisionID, c => c.ContractID, (r, c) => r);
        }


        public static IQueryable<CourseContract> FilterByExpiringContract<TEntity>(this IQueryable<CourseContract> items, ModelSource<TEntity> models)
                where TEntity : class, new()
        {
            var revisionID = models.GetTable<CourseContractRevision>().Where(r => r.Reason == "展延")
                .Select(r => r.RevisionID);
            return items
                    .Where(c => !c.RegisterLessonContract.Any(r => r.RegisterLesson.Attended == (int)Naming.LessonStatus.課程結束))
                    .Where(c => c.Expiration < DateTime.Today.AddMonths(1))
                    .Where(c => !revisionID.Any(r => r == c.ContractID));
        }

        public static IQueryable<CourseContract> FilterByUserRoleScope<TEntity>(this IQueryable<CourseContract> items, ModelSource<TEntity> models, UserProfile profile)
                where TEntity : class, new()
        {
            if (profile.IsAssistant() || profile.IsOfficer())
            {
                return items;
            }
            else if (profile.IsManager() || profile.IsViceManager())
            {
                return models.FilterByBranchStoreManager(items, profile);
            }
            else if (profile.IsCoach())
            {
                return items.Where(c => c.FitnessConsultant == profile.UID);
            }
            else
            {
                return items.Where(c => false);
            }
        }

        public static IQueryable<CourseContractRevision> FilterByUserRoleScope<TEntity>(this IQueryable<CourseContractRevision> items, ModelSource<TEntity> models, UserProfile profile)
                where TEntity : class, new()
        {
            if (profile.IsManager() || profile.IsViceManager())
            {
                items = items.Join(models.FilterByBranchStoreManager(models.GetTable<CourseContract>(), profile),
                    r => r.OriginalContract, c => c.ContractID, (r, c) => r);
            }
            else if (profile.IsAssistant() || profile.IsOfficer())
            {

            }
            else if (profile.IsCoach())
            {
                items = items.Where(c => c.CourseContract.FitnessConsultant == profile.UID);
            }
            else
            {
                items = items.Where(c => false);
            }

            return items;
        }

        public static IQueryable<CourseContract> FilterByExpired<TEntity>(this IQueryable<CourseContract> items, ModelSource<TEntity> models)
                where TEntity : class, new()
        {
            return items.Where(c => c.Expiration < DateTime.Today);
        }

    }
}