using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using CommonLib.Core.Utility;
using CommonLib.PlugInAdapter;

namespace CommonLib.Core.Helper
{
    public class PlugInHelper
    {
        private static PlugInHelper _instance;
        private IPdfUtility _pdfUtility;
        private ILogger _logger;
        
        static PlugInHelper() 
        {
            _instance = new PlugInHelper();
        }

        private PlugInHelper() 
        {
            try
            {
                if (!String.IsNullOrEmpty(Startup.Properties["IPdfUtilityImpl"]))
                {
                    FileLogger.Logger.Info("Pdf Utility intent type => " + Startup.Properties["IPdfUtilityImpl"]);

                    Type type = Type.GetType(Startup.Properties["IPdfUtilityImpl"]);
                    if (type!=null && type.GetInterface("CommonLib.PlugInAdapter.IPdfUtility") != null)
                    {
                        _pdfUtility = (IPdfUtility)type.Assembly.CreateInstance(type.FullName);
                        FileLogger.Logger.Info("Pdf Utility => " + _pdfUtility.GetType().FullName);
                    }
                    else
                    {
                        FileLogger.Logger.Warn("Pdf Utility intent type not found => " + Startup.Properties["IPdfUtilityImpl"]);
                    }
                }

                if (_pdfUtility == null)
                {
                    if (!String.IsNullOrEmpty(Startup.Properties["IPdfUtilityImplAssembly"]))
                    {
                        FileLogger.Logger.Info("Pdf Utility intent assembly => " + Startup.Properties["IPdfUtilityImplAssembly"]);

                        var assembly = Assembly.LoadFrom(Startup.Properties["IPdfUtilityImplAssembly"]);
                        if (assembly != null)
                        {
                            Type type = assembly.GetType(Startup.Properties["IPdfUtilityImplType"]);
                            if (type != null && type.GetInterface("CommonLib.PlugInAdapter.IPdfUtility") != null)
                            {
                                _pdfUtility = (IPdfUtility)assembly.CreateInstance(type.FullName);
                                FileLogger.Logger.Info("Pdf Utility => " + _pdfUtility.GetType().FullName);
                            }
                            else
                            {
                                FileLogger.Logger.Warn($"Pdf Utility intent type not found => {Startup.Properties["IPdfUtilityImplType"]},{Startup.Properties["IPdfUtilityImplAssembly"]}");
                            }
                        }
                    }
                }
            }
            catch(Exception ex)
            {
                FileLogger.Logger.Error(ex);
            }
        }

        public static IPdfUtility GetPdfUtility()
        {
            if (_instance._pdfUtility == null)
            {
                throw new Exception("未設定PDF輸出套件!!");
            }
            return _instance._pdfUtility;
        }

        public static ILogger GetLogger()
        {
            if (_instance._logger == null)
            {
                throw new Exception("未設定Logger!!");
            }
            return _instance._logger;
        }

    }
}
