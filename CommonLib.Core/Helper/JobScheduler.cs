using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.IO;
using CommonLib.Utility;
using System.Xml;
using Microsoft.Extensions.Configuration;

namespace CommonLib.Core.Helper
{
    public partial class JobScheduler : IDisposable
    {
        private static JobScheduler _instance;
        private static String _JobFileName;

        private Timer _timer;
        private List<JobItem> _jobItems;

        static JobScheduler()
        {
            _JobFileName = Path.Combine(CommonLib.Core.Utility.FileLogger.Logger.LogPath, "JobScheduler.xml");
        }

        private JobScheduler(int period)
        {
            initialize();
            if (Startup.Properties.GetValue<bool>("EnableJobScheduler"))
            {
                _timer = new Timer(run, null, period, period);
            }
        }

        private void initialize()
        {
            try
            {
                if (File.Exists(_JobFileName))
                {
                    XmlDocument doc = new XmlDocument();
                    doc.Load(_JobFileName);
                    _jobItems = doc.ConvertTo<List<JobItem>>();
                }
            }
            catch(Exception ex)
            {
                CommonLib.Core.Utility.FileLogger.Logger.Error(ex);
            }

            if (_jobItems == null)
            {
                _jobItems = new List<JobItem>();
            }

        }

        private void run(Object state)
        {
            DateTime now = DateTime.Now;
            bool changed = false;
            for (int i = 0; i < _jobItems.Count; i++)
            {
                var item = _jobItems[i];
                if (item.Schedule <= now)
                {
                    try
                    {
                        doJob(item);
                        item.LastError = null;
                    }
                    catch (Exception ex)
                    {
                        CommonLib.Core.Utility.FileLogger.Logger.Error(ex);
                        item.LastError = ex.ToString();
                    }
                    changed = true;
                }
            }
            if (changed)
            {
                saveJob();
            }
        }

        private void saveJob()
        {
            _jobItems.ConvertToXml().Save(_JobFileName);
        }

        private void doJob(JobItem item, bool nextSchedule = true)
        {
            if (item.Pending == true)
                return;

            var type = Type.GetType(item.AssemblyQualifiedName);
            if (type == null)
            {
                _jobItems.Remove(item);
            }
            else
            {
                IJob job = (IJob)type.Assembly.CreateInstance(type.FullName);
                job.DoJob();
                if (nextSchedule)
                    item.Schedule = job.GetScheduleToNextTurn(item.Schedule);
                job.Dispose();
            }
        }

        public static void StartUp(int period = 5*60000)
        {
            lock (typeof(JobScheduler))
            {
                if (_instance == null)
                {
                    _instance = new JobScheduler(period);
                }
            }
        }

        public static JobItem LaunchJob(int? jobID)
        {
            JobItem item = _instance?._jobItems?.Where(j => j.JobID == jobID).FirstOrDefault();
            if (item != null)
            {
                try
                {
                    _instance.doJob(item);
                    item.LastError = null;
                }
                catch (Exception ex)
                {
                    CommonLib.Core.Utility.FileLogger.Logger.Error(ex);
                    item.LastError = ex.ToString();
                }
                _instance.saveJob();
            }

            return item;
        }

        public void Dispose()
        {
            _timer.Dispose();
            _jobItems.Clear();
        }

        public static void Reset()
        {
            lock (typeof(JobScheduler))
            {
                if (_instance != null)
                {
                    if(File.Exists(_JobFileName))
                    {
                        File.Delete(_JobFileName);
                    }
                    _instance.Dispose();
                    _instance = null;
                }
            }
        }

        public static bool AddJob(JobItem item)
        {
            if (_instance == null)
                StartUp();
            var type = Type.GetType(item.AssemblyQualifiedName);
            if (type.GetInterface("CommonLib.Core.Helper.IJob") != null)
            {
                _instance._jobItems.Add(item);
                _instance.saveJob();
                return true;
            }
            return false;
        }

        public static void RemoveJob(JobItem item)
        {
            if (_instance != null && _instance._jobItems.Remove(item))
            {
                _instance.saveJob();
            }
        }

        public static IEnumerable<JobItem> JobList
        {
            get
            {
                if (_instance != null)
                    return _instance._jobItems.AsEnumerable();
                return null;
            }
        }

        public static void LaunchJob(JobItem item)
        {
            if (_instance != null)
                _instance.doJob(item, false);
        }

        public static void LaunchImmediately()
        {
            if (_instance != null)
            {
                ThreadPool.QueueUserWorkItem(state =>
                {
                    foreach (var item in _instance._jobItems)
                    {
                        try
                        {
                            _instance.doJob(item);
                        }
                        catch (Exception ex)
                        {
                            CommonLib.Core.Utility.FileLogger.Logger.Error(ex);
                        }
                    }
                });
            }
        }

    }

    public class JobItem 
    {
        public int? JobID { get; set; }
        public DateTime Schedule { get; set; }
        public String? AssemblyQualifiedName { get; set; }
        public String? Description { get; set; }
        public String? LastError { get; set; }
        public bool? Pending { get; set; }
        public IJob CreateExecutionInstance()
        {
            var type = Type.GetType(this.AssemblyQualifiedName);
            if (type != null)
            {
                return (IJob)type.Assembly.CreateInstance(type.FullName);
            }

            return null;
        }
    }

    public interface IJob : IDisposable
    {
        DateTime GetScheduleToNextTurn(DateTime current);
        void DoJob();
    }
}
