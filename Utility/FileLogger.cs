using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CommonLib.Core.Utility
{
    public class FileLogger : ILogger
    {
        private static CommonLib.Logger.Logger _Logger;

        static FileLogger()
        {
            _Logger = new CommonLib.Logger.Logger();
        }

        public static CommonLib.Logger.Logger Logger => _Logger;

        public IDisposable BeginScope<TState>(TState state)
        {
            return new LoggerScope();
        }

        public bool IsEnabled(LogLevel logLevel)
        {
            return true;
        }

        public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, Exception exception, Func<TState, Exception, string> formatter)
        {
            String result = formatter(state, exception);
            switch(logLevel)
            {
                case LogLevel.Critical:
                case LogLevel.Error:
                    _Logger.Error(exception);
                    break;
                case LogLevel.Debug:
                    _Logger.Debug(result);
                    break;
                case LogLevel.Warning:
                    _Logger.Warn(result);
                    break;
                case LogLevel.Information:
                    _Logger.Info(result);
                    break;
                case LogLevel.Trace:
                    _Logger.Trace(result);
                    break;
                case LogLevel.None:
                    break;
                default:
                    _Logger.Info(result);
                    break;
            }
        }
    }

    internal class LoggerScope : IDisposable
    {
        private bool disposedValue;

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    // TODO: dispose managed state (managed objects)
                }

                // TODO: free unmanaged resources (unmanaged objects) and override finalizer
                // TODO: set large fields to null
                disposedValue = true;
            }
        }

        // // TODO: override finalizer only if 'Dispose(bool disposing)' has code to free unmanaged resources
        // ~LoggerScope()
        // {
        //     // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
        //     Dispose(disposing: false);
        // }

        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }
    }
}
