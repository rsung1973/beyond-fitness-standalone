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
    }
}