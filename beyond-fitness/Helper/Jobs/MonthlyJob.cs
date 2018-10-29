using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using CommonLib.Helper;
using Utility;
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
                    Logger.Error(ex);
                }
            }
        }

        public DateTime GetScheduleToNextTurn(DateTime current)
        {
            return (new DateTime(current.Year, current.Month, 1)).AddMonths(1);
        }
    }
}