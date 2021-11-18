using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CommonLib.Core.Utility
{
    public class DailySequence
    {
        private static DailySequence _instance = new DailySequence();

        private long _dailyTimer = -1;
        private int _sequence = 0;
        private String _savedFile;

        private DailySequence()
        {
            _savedFile = Path.Combine(FileLogger.Logger.LogPath, "DailySequence.txt");
            try
            {
                if (File.Exists(_savedFile))
                {
                    var data = File.ReadAllLines(_savedFile);
                    long.TryParse(data[0], out _dailyTimer);
                    int.TryParse(data[1], out _sequence);
                }
            }
            catch(Exception ex)
            {
                FileLogger.Logger.Error(ex);
            }
        }

        public static int NextSequenceNo
        {
            get
            {
                lock(_instance)
                {
                    _instance.adjustSequence();
                }
                return _instance._sequence;
            }
        }

        private void adjustSequence()
        {
            if(_dailyTimer<DateTime.Now.Ticks)
            {
                _dailyTimer = DateTime.Today.AddDays(1).Ticks;
                _sequence = 0;
            }

            _sequence++;

            try
            {
                File.WriteAllText(_savedFile, String.Concat(_dailyTimer, "\r\n", _sequence));
            }
            catch(Exception ex)
            {
                FileLogger.Logger.Error(ex);
            }
        }
    }
}
