using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace CommonLib.Utility.Properties
{
    public partial class AppSettingsBase
    {
        public static String AppRoot
        {
            get;
            private set;
        } = Path.GetFullPath(AppDomain.CurrentDomain.BaseDirectory);

        static JObject _Settings;

        static List<AppSettingsBase> _Instances = [];

        public AppSettingsBase()
        {
            _Instances.Add(this);
        }

        protected static String CheckStoredPath(String fullPath)
        {
            if (!Directory.Exists(fullPath))
            {
                Directory.CreateDirectory(fullPath);
            }
            return fullPath;
        }


        protected static T Initialize<T>(String propertyName, bool reload = false)
            where T : AppSettingsBase, new()
        {
            T currentSettings;
            //String fileName = $"{Assembly.GetExecutingAssembly().GetName()}.settings.json";
            lock (typeof(AppSettingsBase))
            {
                if (_Settings == null || reload)
                {
                    String fileName = "App.settings.json";
                    String filePath = Path.Combine(CheckStoredPath(Path.Combine(AppRoot, "App_Data")), fileName);
                    if (File.Exists(filePath))
                    {
                        _Settings = (JObject)JsonConvert.DeserializeObject(File.ReadAllText(filePath));
                    }
                    else
                    {
                        _Settings = new JObject();
                    }

                    //File.WriteAllText(filePath, JsonConvert.SerializeObject(_Settings));
                }
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
                currentSettings.Save();
            }

            return currentSettings;
        }

        public static JObject AllSettings => _Settings;

        public static void Reload<T>(ref T instance, String propertyName)
            where T : AppSettingsBase, new()
        {
            instance = Initialize<T>(propertyName, true);
        }


        public void Save()
        {
            String fileName = "App.settings.json";
            String filePath = Path.Combine(CheckStoredPath(Path.Combine(AppRoot, "App_Data")), fileName);
            String propertyName = this.GetType().Namespace;
            _Settings[propertyName] = JObject.FromObject(this);
            File.WriteAllText(filePath, _Settings.ToString());
        }

        public static void SaveAll()
        {
            if (_Instances.Any())
            {
                foreach (var instance in _Instances)
                {
                    instance.Save();
                }
            }
            String fileName = "App.settings.json";
            String filePath = Path.Combine(CheckStoredPath(Path.Combine(AppRoot, "App_Data")), fileName);
            File.WriteAllText(filePath, _Settings.ToString());
        }


    }

}
