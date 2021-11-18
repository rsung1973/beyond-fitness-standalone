using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using CommonLib.Helper;
using CommonLib.PlugInAdapter;

namespace CommonLib.Logger
{
    public class LoggerBase : IDisposable
    {
        protected QueuedProcessHandler _writer;
        protected Object locker = new object();
        protected StringBuilder _sb;
        protected StringBuilder _standBy;
        protected string _subject;
        protected ILogger _logger;

        private LoggerBase _chainedLogger;
        private bool _bDisposed = false;

        public LoggerBase(ILogger logger)
        {
            _sb = new StringBuilder();
            _standBy = new StringBuilder();
            _logger = logger;

            _writer = new QueuedProcessHandler(logger)
            {
                Process = () =>
                {
                    FlushLog();
                }
            };
            _chainedLogger = this;
        }

        protected virtual void DoFlushLog()
        {

        }

        public void FlushLog()
        {
            lock (locker)
            {
                var tmp = _sb;
                _sb = _standBy;
                _standBy = tmp;
            }

            DoFlushLog();
            _standBy.Clear();

            if (Appendant != null)
            {
                Appendant.FlushLog();
            }
        }

        public void WriteLog(String log)
        {
            //if (String.IsNullOrEmpty(log))
            //{
            //    return;
            //}

            lock (locker)
            {
                _sb.Append($"{DateTime.Now:yyyy/MM/dd HH:mm:ss}");
                _sb.Append(Environment.NewLine);
                _sb.Append(log);
                _sb.Append(Environment.NewLine);
            }

            _writer.Notify();

            if (Appendant != null)
            {
                Appendant.WriteLog(log);
            }
        }

        public void AppendLogger(LoggerBase logger)
        {
            while (_chainedLogger.Appendant != null)
            {
                _chainedLogger = _chainedLogger.Appendant;
            }

            _chainedLogger.Appendant = logger;
            _chainedLogger = logger;
        }

        public LoggerBase Appendant
        {
            get; 
            private set;
        }

        #region IDisposable 成員
        public void Dispose()
        {
            dispose(true);
            GC.SuppressFinalize(this);
        }

        private void dispose(bool disposing)
        {
            if (!_bDisposed)
            {
                if (_sb.Length > 0)
                {
                    FlushLog();
                }
                _bDisposed = true;
            }
        }

        ~LoggerBase()
        {
            dispose(false);
        }

        #endregion


    }
}
