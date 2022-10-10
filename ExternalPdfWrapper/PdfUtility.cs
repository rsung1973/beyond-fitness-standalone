using CommonLib.PlugInAdapter;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace ExternalPdfWrapper
{
    public class PdfUtility : IPdfUtility
    {

        public void ConvertHtmlToPDF(string htmlFile, string pdfFile, double timeOutInMinute, string[] args)
        {
            ProcessStartInfo info = new ProcessStartInfo
            {
                FileName = AppSettings.Default.Command,
                Arguments = String.Concat(" ",
                                String.Format(AppSettings.Default.ConvertPattern, pdfFile, htmlFile),
                                args != null && args.Length > 0 ? String.Join(" ", args) : ""),
                CreateNoWindow = true,
                //UseShellExecute = false,
                WindowStyle = ProcessWindowStyle.Hidden,
                //WorkingDirectory = AppDomain.CurrentDomain.RelativeSearchPath,
            };

            Process proc = new Process();
            proc.EnableRaisingEvents = true;
            //proc.Exited += new EventHandler(proc_Exited);

            //if (null != _eventHandler)
            //{
            //    proc.Exited += new EventHandler(_eventHandler);
            //}
            proc.StartInfo = info;
            proc.Start();
            proc.WaitForExit((int)timeOutInMinute * 60000);

        }

        public void ConvertHtmlToPDF(string htmlFile, string pdfFile, double timeOutInMinute)
        {
            ConvertHtmlToPDF(htmlFile, pdfFile, timeOutInMinute, null);
        }
    }

    public partial class AppSettings : IDisposable
    {
        public static String AppRoot
        {
            get;
            private set;
        } = Path.GetFullPath(AppDomain.CurrentDomain.BaseDirectory);

        static JObject _Settings;

        static AppSettings()
        {
            _default = Initialize<AppSettings>(typeof(AppSettings).Namespace);
        }

        public AppSettings()
        {

        }

        protected void Save()
        {
            String fileName = "App.settings.json";
            String filePath = Path.Combine(AppRoot, "App_Data", fileName);
            String propertyName = typeof(AppSettings).Namespace;
            _Settings[propertyName] = JObject.FromObject(this);
            File.WriteAllText(filePath, _Settings.ToString());
        }

        protected static T Initialize<T>(String propertyName)
            where T : AppSettings, new()
        {
            T currentSettings;
            //String fileName = $"{Assembly.GetExecutingAssembly().GetName()}.settings.json";
            String fileName = "App.settings.json";
            String filePath = Path.Combine(AppRoot, "App_Data", fileName);
            if (File.Exists(filePath))
            {
                _Settings = (JObject)JsonConvert.DeserializeObject(File.ReadAllText(filePath));
            }
            else
            {
                _Settings = new JObject();
            }

            //String propertyName = Assembly.GetExecutingAssembly().GetName().Name;
            if (_Settings[propertyName] != null)
            {
                currentSettings = _Settings[propertyName].ToObject<T>();
            }
            else
            {
                currentSettings = new T();
                _Settings[propertyName] = JObject.FromObject(currentSettings);
            }

            File.WriteAllText(filePath, _Settings.ToString());
            return currentSettings;
        }

        public void Dispose()
        {
            dispose(true);
        }

        bool _disposed;
        protected void dispose(bool disposing)
        {
            if (!_disposed)
            {
                this.Save();
            }
            _disposed = true;
        }

        ~AppSettings()
        {
            dispose(false);
        }

        static AppSettings _default;

        public static AppSettings Default => _default;

        public String Command { get; set; } = "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe";
        public String ConvertPattern { get; set; } = "--headless --disable-gpu --run-all-compositor-stages-before-draw --print-to-pdf-no-header  --print-to-pdf={0} {1}";
        //"--headless --disable-gpu --run-all-compositor-stages-before-draw --print-to-pdf-no-header  --print-to-pdf={0} file://{1}";
        public String Args { get; set; }
    }
}
