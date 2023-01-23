using System;
using CommonLib.Core.Helper;
using Microsoft.Extensions.Logging;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;

namespace WebHome.Helper.Jobs
{
    public class DailyJob : IJob
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
                    models.ExecuteCommand(@"UPDATE CourseContract
                            SET                Status = {0}
                            WHERE        (Status = {1}) AND (Expiration < {2})
                            AND (NOT EXISTS (SELECT NULL 
                               FROM CourseContractRevision
                               WHERE (CourseContract.ContractID = RevisionID)))",
                        (int)Naming.CourseContractStatus.已過期, (int)Naming.CourseContractStatus.已生效, DateTime.Today);

                    models.ExecuteCommand(@"UPDATE RegisterLesson
                            SET        Attended = {0} WHERE   (Expiration < {1})", (int)Naming.LessonStatus.課程結束, DateTime.Today);
                }
                catch (Exception ex)
                {
                    ApplicationLogging.CreateLogger<DailyJob>()
                        .LogError(ex, ex.Message);
                }
            }
        }

        public DateTime GetScheduleToNextTurn(DateTime current)
        {
            return current.Date.AddDays(1);
        }
    }
}