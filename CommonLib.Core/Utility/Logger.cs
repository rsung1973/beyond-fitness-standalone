using System;

namespace CommonLib.Core.Utility
{
    public static class Logger
    {
        public static void Error(object ex)
        {
            FileLogger.Logger.Error(ex);
        }

        public static void Warn(object ex)
        {
            FileLogger.Logger.Warn(ex);
        }

        public static void Info(object ex)
        {
            FileLogger.Logger.Info(ex);
        }

        public static void Debug(object ex)
        {
            FileLogger.Logger.Debug(ex);
        }

        public static string LogPath => FileLogger.Logger.LogPath;

        public static string LogDailyPath => FileLogger.Logger.LogDailyPath;

    }
}
