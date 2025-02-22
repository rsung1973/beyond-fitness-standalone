using CommonLib.PlugInAdapter;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V132;
using OpenQA.Selenium.DevTools.V132.Page;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace ExternalPdfWrapper
{
    public class PdfUtility : IPdfUtility
    {
        static PdfUtility()
        {
            if (AppSettings.Default.UseSelenium)
            {
                ChromeOptions options = new ChromeOptions();
                options.AddArgument("--headless");
                options.AddArgument("--disable-gpu");
                options.AddArgument("--no-sandbox");
                options.AddArgument("--disable-dev-shm-usage");
                //options.AddArgument("--remote-debugging-port=9222");
                //options.AddArgument("--disable-extensions");
                //options.AddArgument("--disable-infobars");
                //options.AddArgument("--disable-popup-blocking");
                //options.AddArgument("--disable-background-networking");
                //options.AddArgument("--disable-sync");
                //options.AddArgument("--disable-default-apps");
                //options.AddArgument("--disable-translate");
                //options.AddArgument("--disable-extensions");
                //options.AddArgument("--disable-background-timer-throttling");
                //options.AddArgument("--disable-renderer-backgrounding");
                //options.AddArgument("--disable-device-discovery-notifications");
                //options.AddArgument("--disable-software-rasterizer");
                //options.AddArgument("--disable-features=TranslateUI");
                //options.AddArgument("--disable-features=Translate");
                //options.AddArgument("--disable-features=NetworkService");
                //options.AddArgument("--disable-features=NetworkServiceInProcess");

                var printOptions = new Dictionary<string, object>
                {
                    { "landscape", false },
                    { "displayHeaderFooter", false },
                    { "printBackground", true },
                    { "preferCSSPageSize", true },
                    //{ "scale", 1 },
                    //{ "paperWidth", 8.27 }, // A4 纸宽度（英寸）
                    //{ "paperHeight", 11.69 } // A4 纸高度（英寸）
                };

                var driver = new ChromeDriver(options);
                __Navigation = driver.Navigate();
                __DevToolsSession = driver.GetDevToolsSession();
            }

        }

        static INavigation __Navigation;
        static DevToolsSession __DevToolsSession;
        static PrintToPDFCommandSettings __PrintCommand { get; } = 
            new PrintToPDFCommandSettings
            {
                Landscape = false,
                DisplayHeaderFooter = false,
                PrintBackground = true,
                MarginBottom = 0,
                MarginTop = 0,
                MarginLeft = 0,
                MarginRight = 0,
                //Scale = 1,
                //PaperWidth = 8.27,
                //PaperHeight = 11.69
            };

        public static bool AssertFile(String pdfFile, double maxWaitInMilliSeconds = 0)
        {
            var t = Task.Run(() =>
            {
                bool checking = true;
                DateTime start = DateTime.Now;
                while (checking)
                {
                    try
                    {
                        using (var fs = File.OpenRead(pdfFile))
                        {
                            fs.Close();
                            checking = false;
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.ToString());
                        Thread.Sleep(100);
                        if (maxWaitInMilliSeconds > 0 && (DateTime.Now - start).TotalMilliseconds > maxWaitInMilliSeconds)
                        {
                            checking = false;
                        }
                    }
                }
            });

            t.Wait();
            return true;
        }

        public async Task UseSeleniumConvertHtmlToPDF(string htmlSource, string pdfFile, double timeOutInMinute, string[] args)
        {
            // 设置 Chrome 选项
            var chromeOptions = new ChromeOptions();
            chromeOptions.AddArgument("--headless"); // 启用 headless 模式
            chromeOptions.AddArgument("--disable-gpu");
            chromeOptions.AddArgument("--no-sandbox");
            chromeOptions.AddArgument("--disable-dev-shm-usage");

            // 设置打印选项
            var printOptions = new Dictionary<string, object>
        {
            { "landscape", false },
            { "displayHeaderFooter", false },
            { "printBackground", true },
            { "preferCSSPageSize", true },
            //{ "scale", 1 },
            //{ "paperWidth", 8.27 }, // A4 纸宽度（英寸）
            //{ "paperHeight", 11.69 } // A4 纸高度（英寸）
        };

            // 启动 Chrome 浏览器
            using (var driver = new ChromeDriver(chromeOptions))
            {
                // 导航到目标网页
                driver.Navigate().GoToUrl(htmlSource);

                // 等待页面加载完成（可以根据需要调整等待逻辑）
                //await Task.Delay(2000); // 简单等待 2 秒

                // 使用 Chrome DevTools Protocol 生成 PDF
                var printCommand = new PrintToPDFCommandSettings
                {
                    Landscape = false,
                    DisplayHeaderFooter = false,
                    PrintBackground = true,
                    MarginBottom = 0,
                    MarginTop = 0,
                    MarginLeft = 0,
                    MarginRight = 0,
                    //Scale = 1,
                    //PaperWidth = 8.27,
                    //PaperHeight = 11.69
                };

                var devToolsSession = driver.GetDevToolsSession();
                // 启用 Page 域
                //await devToolsSession.Page.Enable();
                PrintToPDFCommandResponse printResponse = (PrintToPDFCommandResponse)await devToolsSession.SendCommand(printCommand);

                // 将生成的 PDF 保存到文件
                var pdfBytes = Convert.FromBase64String(printResponse.Data);
                File.WriteAllBytes(pdfFile, pdfBytes);

                //Console.WriteLine("PDF 已成功生成并保存为 output.pdf");
            }
        }

        private async Task UseChromeConvertHtmlToPDF(string htmlSource, string pdfFile, double timeOutInMinute, string[] args)
        {
            __Navigation.GoToUrl(htmlSource);
            PrintToPDFCommandResponse printResponse = (PrintToPDFCommandResponse)await __DevToolsSession.SendCommand(__PrintCommand);
            var pdfBytes = Convert.FromBase64String(printResponse.Data);
            File.WriteAllBytes(pdfFile, pdfBytes);
        }


        public void ConvertHtmlToPDF(string htmlFile, string pdfFile, double timeOutInMinute, string[] args)
        {
            if (AppSettings.Default.UseRunBatch != null)
            {
                String batchPath = Path.Combine(AppSettings.Default.UseRunBatch, $"{Guid.NewGuid()}.bat");
                File.WriteAllText(batchPath, $"\"{AppSettings.Default.Command}\"{String.Concat(" ",
                                    String.Format(AppSettings.Default.ConvertPattern, pdfFile, htmlFile),
                                    args != null && args.Length > 0 ? String.Join(" ", args) : "")}");
                AssertFile(pdfFile, timeOutInMinute * 60000);
            }
            else if (AppSettings.Default.UseSelenium)
            {
                //UseSeleniumConvertHtmlToPDF(htmlSource, pdfFile, timeOutInMinute, args).Wait();
                UseChromeConvertHtmlToPDF(htmlFile, pdfFile, timeOutInMinute, args).Wait();
            }
            else
            {
                ProcessStartInfo info = new ProcessStartInfo
                {
                    FileName = AppSettings.Default.Command,
                    Arguments = String.Concat(" ",
                                    String.Format(AppSettings.Default.ConvertPattern, pdfFile, htmlFile),
                                    args != null && args.Length > 0 ? String.Join(" ", args) : ""),
                    CreateNoWindow = false,
                    //UseShellExecute = false,
                    WindowStyle = ProcessWindowStyle.Normal,
                    //WorkingDirectory = AppDomain.CurrentDomain.RelativeSearchPath,
                };

                if (AppSettings.Default.UserName != null)
                {
                    info.UserName = AppSettings.Default.UserName;
                    if (AppSettings.Default.Password != null)
                    {
                        SecureString pwd = new SecureString();
                        for (int i = 0; i < AppSettings.Default.Password.Length; i++)
                        {
                            pwd.AppendChar(AppSettings.Default.Password[i]);
                        }
                        pwd.MakeReadOnly();
                        info.Password = pwd;
                    }
                }

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
        public String UserName { get; set; }
        public String Password { get; set; }
        public String UseRunBatch { get; set; }
        public bool UseSelenium { get; set; } = false;
    }
}
