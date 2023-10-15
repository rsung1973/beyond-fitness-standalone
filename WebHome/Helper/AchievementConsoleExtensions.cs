using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using Microsoft.EntityFrameworkCore;
using CommonLib.DataAccess;
using Microsoft.Extensions.Logging;

namespace WebHome.Helper
{
    public static class AchievementConsoleExtensions
    {
        public static IQueryable<MonthlyCoachRevenueIndicator> InquireData(this MonthlyIndicatorQueryViewModel viewModel, GenericManager<BFDataContext> models, out IQueryable<MonthlyIndicator> indicators)
        {
            IQueryable<MonthlyCoachRevenueIndicator> items = models.GetTable<MonthlyCoachRevenueIndicator>();

            Settlement lastItem = models.GetTable<Settlement>()
                .OrderByDescending(s => s.SettlementID).FirstOrDefault();

            indicators = models.GetTable<MonthlyIndicator>()
                .Where(m => m.StartDate >= viewModel.DateFrom)
                .Where(m => m.StartDate < viewModel.DateTo);

            if(lastItem != null)
            {
                indicators = indicators.Where(m => m.StartDate < lastItem.EndExclusiveDate);
            }

            items = indicators
                .Join(items,
                    m => m.PeriodID, c => c.PeriodID, (m, c) => c);

            if (viewModel.BranchID.HasValue)
            {
                items = items.Where(c => c.BranchID == viewModel.BranchID);
            }
            return items;
        }

        public static IQueryable<MonthlyCoachRevenueIndicator> InquireDataForCoachRanking(this MonthlyIndicatorQueryViewModel viewModel, GenericManager<BFDataContext> models, out IQueryable<MonthlyIndicator> indicators)
        {
            var items = viewModel.InquireData(models, out indicators);
            if (items.Any())
            {
                var lastIndicator = indicators.OrderByDescending(i=>i.PeriodID).First();
                var coachID = models.GetTable<MonthlyCoachRevenueIndicator>().Where(c => c.PeriodID == lastIndicator.PeriodID)
                                .Where(c => models.GetTable<ProfessionalLevelReview>().Any(r => c.LevelID == r.LevelID))
                                .Select(c => c.CoachID);
                items = items.Where(m => coachID.Any(c => m.CoachID == c));
            }
            return items;
        }

    }
}
