using CommonLib.PlugInAdapter;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace CommonLib.Helper
{
    public class QueuedProcessHandler
    {
        private int _busyCount = 0;
        private readonly ILogger _logger;
        private int _readyCount = 0;

        public Action Process { get; set; }

        public int? MaxWaitingCount { get; set; }
        public int? PeriodInMinutes { get => MilliSecondsWait / 60000; set => MilliSecondsWait = value * 60000; }
        public int? MilliSecondsWait { get; set; }

        public QueuedProcessHandler(ILogger logger)
        {
            _logger = logger;
        }

        public void Notify()
        {
            if (MaxWaitingCount.HasValue && _busyCount >= MaxWaitingCount)
                return;

            if (Interlocked.Increment(ref _busyCount) == 1)
            {
                //while (_busyCount > 0)
                //{
                //    var t1 = Task.Run(Process);
                //    var t2 = t1.ContinueWith(ts =>
                //    {
                //        Interlocked.Decrement(ref _busyCount);
                //    });
                //}
                ThreadPool.QueueUserWorkItem(t =>
                {
                    do
                    {
                        try
                        {
                            Process();
                        }
                        catch (Exception ex)
                        {
                            _logger?.Error(ex);
                        }
                    } while (Interlocked.Decrement(ref _busyCount) > 0);

                    if(MilliSecondsWait.HasValue)
                    {
                        if (Interlocked.Increment(ref _readyCount) == 1)
                        {
                            Task.Delay(MilliSecondsWait.Value).ContinueWith(ts =>
                            {
                                Interlocked.Exchange(ref this._readyCount, 0);
                                this.Notify();
                            });
                        }
                    }
                });
            }

        }

        public int ResetBusyCount()
        {
            return Interlocked.Exchange(ref _busyCount, 0);
        }
    }
}
