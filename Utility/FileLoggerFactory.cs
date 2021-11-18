using System;
using System.Collections;
using System.Threading;
using System.IO;
using System.Text;

using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Console;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CommonLib.Core.Utility
{
    /// <summary>
    /// Logger ªººK­n´y­z¡C
    /// </summary>
    /// 
    public class FileLoggerFactory : ILoggerFactory
    {

        public void AddProvider(ILoggerProvider provider)
        {
            
        }

        public ILogger CreateLogger(string categoryName)
        {
            return new FileLogger();
        }

        public void Dispose()
        {

        }
    }
}
