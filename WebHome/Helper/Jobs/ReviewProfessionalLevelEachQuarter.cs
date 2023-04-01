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
    public class ReviewProfessionalLevelEachQuarter : IJob
    {
        public void Dispose()
        {
            
        }

        public void DoJob()
        {
            using (ModelSource<UserProfile> models = new ModelSource<UserProfile>())
            {
                foreach (var item in models.PromptEffectiveCoach())
                {
                    try
                    {
                        models.CheckProfessionalLevel2023(item);
                    }
                    catch(Exception ex)
                    {
                        ApplicationLogging.CreateLogger<ReviewProfessionalLevelEachQuarter>()
                            .LogError(ex, ex.Message);
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