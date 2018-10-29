using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using CommonLib.Helper;
using Utility;
using WebHome.Models.DataEntity;

namespace WebHome.Helper.Jobs
{
    public class ReviewProfessionalLevelEachQuarter : IJob
    {
        public void Dispose()
        {
            
        }

        public void DoJob()
        {
            using (ModelSource<UserProfile> models = new ModelSource<UserProfile>())
            {
                foreach (var item in models.GetTable<ServingCoach>())
                {
                    try
                    {
                        models.CheckProfessionalLeve(item);
                    }
                    catch(Exception ex)
                    {
                        Logger.Error(ex);
                    }
                }
            }
        }

        public DateTime GetScheduleToNextTurn(DateTime current)
        {
            DateTime quarterStart = (new DateTime(DateTime.Today.Year, (DateTime.Today.Month - 1) / 3 * 3 + 1, 1)).AddMonths(3);
            return quarterStart;
        }
    }
}