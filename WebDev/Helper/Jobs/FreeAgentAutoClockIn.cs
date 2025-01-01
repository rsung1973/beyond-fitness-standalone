using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using CommonLib.Core.Helper;
using CommonLib.Helper;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;

namespace WebHome.Helper.Jobs
{
    public class FreeAgentAutoClockIn : IJob
    {
        public void Dispose()
        {
            
        }

        public void DoJob()
        {
            using (ModelSource<UserProfile> models = new ModelSource<UserProfile>())
            {
                var items = models.GetTable<LessonTime>()
                    .Where(l=>l.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自由教練預約)
                    .Where(l => l.ClassTime <= DateTime.Now)
                    .Where(l => l.LessonAttendance == null);

                if (items.Count() > 0)
                {
                    foreach (var lesson in items)
                    {
                        lesson.LessonAttendance = new LessonAttendance
                        {
                            CompleteDate = DateTime.Now
                        };
                    }
                    models.SubmitChanges();
                }
            }
        }

        public DateTime GetScheduleToNextTurn(DateTime current)
        {
            return current.AddHours(1);
        }
    }

    public static class JobLauncher
    {
        public static void StartUp()
        {
            Console.WriteLine("Daemon Job launches ...");

            JobScheduler.StartUp();

            var jobList = JobScheduler.JobList;
            //if (jobList == null || !jobList.Any(j => j.AssemblyQualifiedName == typeof(FreeAgentAutoClockIn).AssemblyQualifiedName))
            //{
            //    JobScheduler.AddJob(new JobItem
            //    {
            //        AssemblyQualifiedName = typeof(FreeAgentAutoClockIn).AssemblyQualifiedName,
            //        Description = "自由教練打卡",
            //        Schedule = DateTime.Today.Add(new TimeSpan(0, 0, 0))
            //    });
            //}

            //if (jobList == null || !jobList.Any(j => j.AssemblyQualifiedName == typeof(ReviewProfessionalLevelEachQuarter).AssemblyQualifiedName))
            //{
            //    JobScheduler.AddJob(new JobItem
            //    {
            //        AssemblyQualifiedName = typeof(ReviewProfessionalLevelEachQuarter).AssemblyQualifiedName,
            //        Description = "檢查教練等級",
            //        Schedule = (new DateTime(DateTime.Today.Year, (DateTime.Today.Month - 1) / 3 * 3 + 1, 16)).AddMonths(3).Add(new TimeSpan(0, 10, 0)),
            //        Pending = true,
            //    });
            //}

            if (jobList == null || !jobList.Any(j => j.AssemblyQualifiedName == typeof(CheckInvoiceDispatch).AssemblyQualifiedName))
            {
                JobScheduler.AddJob(new JobItem
                {
                    AssemblyQualifiedName = typeof(CheckInvoiceDispatch).AssemblyQualifiedName,
                    Description = "檢查電子發票傳送大平台LOG",
                    Schedule = DateTime.Today.Add(new TimeSpan(0, 0, 0))
                });
            }

            if (jobList == null || !jobList.Any(j => j.AssemblyQualifiedName == typeof(MonthlyJob).AssemblyQualifiedName))
            {
                JobScheduler.AddJob(new JobItem
                {
                    AssemblyQualifiedName = typeof(MonthlyJob).AssemblyQualifiedName,
                    Description = "每月登錄員工福利課",
                    Schedule = DateTime.Today.Add(new TimeSpan(0, 0, 0))
                });
            }

            if (jobList == null || !jobList.Any(j => j.AssemblyQualifiedName == typeof(DailyJob).AssemblyQualifiedName))
            {
                JobScheduler.AddJob(new JobItem
                {
                    AssemblyQualifiedName = typeof(DailyJob).AssemblyQualifiedName,
                    Description = "每日檢查過期合約",
                    Schedule = DateTime.Today.Add(new TimeSpan(0, 0, 0))
                });
            }

        }
    }
}