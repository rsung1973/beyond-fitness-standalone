using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace Utility
{
    public class LogWritter : IDisposable
    {
        private bool _bDisposed = false;
        private StringBuilder _sb;
        private string _subject;
        private StringWriter _sw;

        public LogWritter(string subject)
            : this()
        {
            _subject = subject;
        }

        public LogWritter() 
        {
            _sb = new StringBuilder();
            _sw = new StringWriter(_sb);
        }

        public TextWriter Writter
        {
            get
            {
                return _sw;
            }
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
                _sw.Flush();
                _sw.Close();
                Logger.Info(_sb.ToString());

                if (disposing)
                {
                    _sw.Dispose();
                }

                _bDisposed = true;
            }
        }

        ~LogWritter()
        {
            dispose(false);
        }

        #endregion

    }
}
