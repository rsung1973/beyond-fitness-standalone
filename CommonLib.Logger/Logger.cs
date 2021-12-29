using System;
using System.Collections;
using System.Threading;
using System.IO;
using System.Text;
using CommonLib.Logger.Properties;
using System.Collections.Generic;
using CommonLib.PlugInAdapter;
using CommonLib.Utility;

namespace CommonLib.Logger
{
    /// <summary>
    /// Logger 的摘要描述。
    /// </summary>
    public class Logger : IDisposable , ILogger
    {

        private bool _disposed = false;
        private string _path;
        private long _fileID = 0;

        private LogWriter _err, _nfo, _dbg, _wrn, _tra;
        private TextWriter _output;


        public Logger()
        {
            //
            // TODO: 在此加入建構函式的程式碼
            //
            if (!String.IsNullOrEmpty(Settings.Default.LogPath))
                _path = Settings.Default.LogPath;
            else
                _path = Path.Combine(Path.GetFullPath(AppDomain.CurrentDomain.BaseDirectory), "logs");

            if (!Directory.Exists(_path))
                Directory.CreateDirectory(_path);

            _dbg = new LogWriter(this, "SystemLog.dbg");
            _err = new LogWriter(this, "SystemLog.err");
            _nfo = new LogWriter(this, "SystemLog.nfo");
            _wrn = new LogWriter(this, "SystemLog.wrn");
            _tra = new LogWriter(this, "SystemLog.trace");
        }

        public TextWriter OutputWriter
        {
            get => _output;
            set
            {
                _output = value;
                if (value != null)
                {
                    _dbg.AppendantWriter.Add(value);
                    _err.AppendantWriter.Add(value);
                    _nfo.AppendantWriter.Add(value);
                    _wrn.AppendantWriter.Add(value);
                }
            }
        }

        public void Error(object obj)
        {
            String log = GetLogContent(obj, "err");
            if (log != null)
            {
                _err.WriteLog(log);
            }
        }

        public void Info(object obj)
        {
            String log = GetLogContent(obj, "nfo");
            if (log != null)
            {
                _nfo.WriteLog(log);
            }
        }


        public void Warn(object obj)
        {
            String log = GetLogContent(obj, "wrn");
            if (log != null)
            {
                _wrn.WriteLog(log);
            }
        }

        public void Debug(object obj)
        {
            String log = GetLogContent(obj, "dbg");
            if (log != null)
            {
                _dbg.WriteLog(log);
            }
        }

        public void Trace(object obj)
        {
            String log = GetLogContent(obj, "err");
            if (log != null)
            {
                _tra.WriteLog(log);
            }
        }

        public string LogPath
        {
            get
            {
                return _path;
            }
        }
        
        public string LogDailyPath
        {
            get
            {
                string filePath = _path.GetDateStylePath();
                if (!Directory.Exists(filePath))
                    Directory.CreateDirectory(filePath);
                return filePath;
            }
        }

        private String GetLogContent(object obj, String qName)
        {
            if (obj == null)
                return null;

            String result = null;
            if (obj is ILogObject)
            {
                string filePath;
                if (obj is ILogObject2)
                {
                    filePath = ((ILogObject2)obj).GetFileName(LogDailyPath, qName, (ulong)Interlocked.Increment(ref _fileID));
                    File.WriteAllText(filePath, obj.ToString(), Encoding.UTF8);
                    return null;
                }
                else
                {
                    filePath = Path.Combine(LogDailyPath, String.Format("{0:000000000000}_({2}).{1}",  Interlocked.Increment(ref _fileID), qName, ((ILogObject)obj).Subject));
                    result = obj.ToString();

                    File.AppendAllText(filePath, $"{DateTime.Now:yyyy/MM/dd HH:mm:ss}\r\n", Encoding.UTF8);
                    File.AppendAllText(filePath, result, Encoding.UTF8);
                }
            }
            else
            {
                result = obj.ToString();
            }

            return result;
        }


        #region IDisposable 成員

        public void Dispose()
        {
            // TODO:  加入 Logger.Dispose 實作
            dispose(true);
        }

        #endregion

        protected void dispose(bool disposing)
        {
            if (!_disposed)
            {
                if (disposing)
                {
                    Console.WriteLine("Object is disposing now ...");
                }
                else
                {
                    Console.WriteLine("May destructor run ...");
                }

                _dbg.Dispose();
                _err.Dispose();
                _nfo.Dispose();
                _wrn.Dispose();

            }
            _disposed = true;
        }

        ~Logger()
        {
            dispose(false);
        }

    }
}
