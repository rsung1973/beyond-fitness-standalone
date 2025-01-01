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
    public static class ContractConsoleExtensionMethods
    {

        public static IQueryable<CourseContractRevision> PromptContractCauseForEnding(this UserProfile profile,  GenericManager<BFDataContext> models,out IQueryable<CourseContract> unpaidOverdueItems, DateTime? dateFrom = null, DateTime? dateTo = null)
        {
            IQueryable<CourseContract> contracts = models.GetTable<CourseContract>();

            if (profile.IsSysAdmin() || profile.IsAssistant() || profile.IsOfficer())
            {

            }
            else if (profile.IsManager() || profile.IsViceManager())
            {
                contracts = contracts
                    .Join(models.GetTable<CourseContractExtension>()
                        .Join(models.GetTable<BranchStore>()
                            .Where(b => b.ManagerID == profile.UID || b.ViceManagerID == profile.UID),
                        c => c.BranchID, b => b.BranchID, (c, b) => c),
                    c => c.ContractID, e => e.ContractID, (c, e) => c);
            }
            else
            {
                contracts = contracts.Where(c => false);
            }

            unpaidOverdueItems = contracts
                .Where(c => c.Status == (int)Naming.CourseContractStatus.已終止)
                .Where(c => c.Subject == "已自動終止");


            IQueryable<CourseContract> items = models.GetTable<CourseContract>()
                .Where(c => c.EffectiveDate.HasValue);
            if(dateFrom.HasValue)
            {
                items = items.Where(c => c.EffectiveDate >= dateFrom);
                unpaidOverdueItems = unpaidOverdueItems.Where(c => c.ValidTo >= dateFrom);
            }
            if(dateTo.HasValue)
            {
                items = items.Where(c => c.EffectiveDate < dateTo);
                unpaidOverdueItems = unpaidOverdueItems.Where(c => c.ValidTo < dateTo);
            }


            var revision = models.GetTable<CourseContractRevision>()
                .Where(r => r.Reason == "終止")
                .Where(r => r.CauseForEnding.HasValue)
                    .Join(items, r => r.RevisionID, c => c.ContractID, (r, c) => r)
                    .Join(contracts, r => r.OriginalContract, c => c.ContractID, (r, c) => r);

            return revision;
        }

    }
}