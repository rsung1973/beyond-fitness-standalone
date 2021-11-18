using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using Utility;

namespace CommonLib.Utility
{
    public class LogTraceListener : TraceListener
    {
        public LogTraceListener(String initData)
        { 

        }

        public LogTraceListener() { }

        public override void Write(string message)
        {
            global::Utility.Logger.Info(message);
        }

        public override void WriteLine(string message)
        {
            global::Utility.Logger.Info(message);
        }
    }
}
