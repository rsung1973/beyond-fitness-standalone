using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using CommonLib.Core.Helper;
using CommonLib.Helper;
using CommonLib.Utility;
using Microsoft.Extensions.Logging;
using WebHome.Models.DataEntity;

namespace WebHome.Helper.Jobs
{
    public class MonthlyJob : IJob
    {
        public void Dispose()
        {
            
        }

        public void DoJob()
        {
            using (ModelSource<UserProfile> models = new ModelSource<UserProfile>())
            {
                try
                {
                    models.RegisterMonthlyGiftLesson();
                }
                catch (Exception ex)
                {
                    ApplicationLogging.CreateLogger<MonthlyJob>()
                        .LogError(ex, ex.Message);
                }
            }

            using (ModelSource<UserProfile> models = new ModelSource<UserProfile>())
            {
                try
                {
                    models.ClearUnpaidOverdueContract();
                }
                catch (Exception ex)
                {
                    ApplicationLogging.CreateLogger<MonthlyJob>()
                        .LogError(ex, ex.Message);
                }
            }
        }

        public DateTime GetScheduleToNextTurn(DateTime current)
        {
            return (new DateTime(current.Year, current.Month, 1)).AddMonths(1);
        }
    }
}