using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.Json;
using Utility;

namespace CommonLib.Properties
{
    public class Settings
    {
        static Settings()
        {
            String filePath = Path.Combine(Logger.LogPath, "App.Settings.json");
            if (File.Exists(filePath))
            {
                _default = JsonSerializer.Deserialize<Settings>(File.ReadAllText(filePath));
            }
            else
            {
                _default = new Settings { };
            }

            File.WriteAllText(filePath, JsonSerializer.Serialize(_default));
        }

        private static Settings _default;
        public static Settings Default
        {
            get => _default;
        }

        public String IPdfUtilityImpl { get; set; } = "WKPdfWrapper.PdfUtility,WKPdfWrapper, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null";
        public bool SqlLog { get; set; } = true;
        public bool EnableJobScheduler { get; set; } = true;
        public String LogPath { get; set; }
    }
}
