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

using WebHome.Helper.BusinessOperation;
using WebHome.Controllers;
using LineMessagingAPISDK.Models;

namespace WebHome.Helper
{
    public static class CoachConsoleExtensions
    {
        public static IQueryable<CoachCertificate> CoachCertificateToApprove(this UserProfile profile, GenericManager<BFDataContext> models)

        {
            var items = models.GetTable<CoachCertificate>()
                            .Where(c=>c.Status == (int)CoachCertificate.CertificateStatusDefinition.待審核);

            if (profile.IsAssistant() || profile.IsOfficer())
            {

            }
            else
            {
                var branches = models.GetTable<BranchStore>().Where(b => b.ManagerID == profile.UID || b.ViceManagerID == profile.UID);
                var workPlace = models.GetTable<CoachWorkplace>().Where(w => branches.Any(b => b.BranchID == w.BranchID));
                items = items.Where(c => workPlace.Any(w => w.CoachID == c.CoachID));
            }
            return items;
        }

        public static IQueryable<CoachCertificate> CoachCertificateToApproveByBranch(this int? branchID, GenericManager<BFDataContext> models)
        {
            var items = models.GetTable<CoachCertificate>()
                            .Where(c => c.Status == (int)CoachCertificate.CertificateStatusDefinition.待審核);

            if (branchID.HasValue)
            {
                var branches = models.GetTable<BranchStore>().Where(b => b.BranchID == branchID);
                var workPlace = models.GetTable<CoachWorkplace>().Where(w => branches.Any(b => b.BranchID == w.BranchID));
                items = items.Where(c => workPlace.Any(w => w.CoachID == c.CoachID));
            }

            return items;
        }
    }
}
