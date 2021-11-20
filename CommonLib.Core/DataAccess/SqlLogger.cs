using System;
using System.Data;
using System.Linq;
using System.Data.Linq;
using System.Collections.Generic;
using System.Data.Common;
using System.IO;
using System.Linq.Expressions;
using System.Collections;
using System.Text;

using CommonLib.Utility;
using System.Threading.Tasks;
using CommonLib.Logger;
using CommonLib.Core.Utility;

namespace CommonLib.DataAccess
{
    public class SqlLogger : TextWriter
    {
        private StringBuilder _tmp, _log;
        public SqlLogger() : base() 
        {
            _tmp = new StringBuilder();
            _log = new StringBuilder();
        }

        static LogWriter __Writer;
        static SqlLogger() 
        {
            __Writer = new LogWriter(FileLogger.Logger, "SqlTrace.log");
        }

        public bool IgnoreSelect { get; set; }

        public override Encoding Encoding => Encoding.Unicode;

        public override void Write(char value)
        {
            _tmp.Append(value);
        }

        public override void WriteLine()
        {
            base.WriteLine();

            var sql = _tmp.ToString();
            _tmp.Clear();
            if(IgnoreSelect && sql.StartsWith("SELECT"))
            {

            }
            else
            {
                _log.Append(sql);
                __Writer.WriteLog(sql);
            }
        }

        public StringBuilder Logger => _log;

        public override string ToString()
        {
            return _log.ToString();
        }

        //public override void WriteLine(string value)
        //{
        //    base.WriteLine(value);
        //}
    }

}
