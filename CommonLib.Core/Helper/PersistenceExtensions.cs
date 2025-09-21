using CommonLib.Core.Utility;
using CommonLib.Utility;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace CommonLib.Core.Helper
{
    public static class PersistenceExtensions
    {
        public static void Push(this object data, string? objectName = null, string? storedPath = null)
        {
            if (data == null)
            {
                return;
            }

            storedPath = Path.Combine(storedPath ?? FileLogger.Logger.LogPath, data.GetType().Name).CheckStoredPath();
            string fileName = Path.Combine(storedPath, objectName ?? Guid.NewGuid().ToString());
            if (File.Exists(fileName))
            {
                return;
            }

            File.WriteAllText(fileName, JsonConvert.SerializeObject(data));

        }

        public static T? Popup<T>(this string intentName, string? storedPath = null, bool popupIfAny = true)
        {
            string stored = Path.Combine(storedPath ?? FileLogger.Logger.LogPath, typeof(T).Name).CheckStoredPath();
            string? objectContent = null;

            string? popupContent(string objectPath)
            {
                lock (typeof(PersistenceExtensions))
                {
                    string? content = null;
                    if (File.Exists(objectPath))
                    {
                        content = File.ReadAllText(objectPath);
                        File.Delete(objectPath);
                    }
                    return content;
                }
            }

            intentName = intentName.GetEfficientString();
            if (intentName != null)
            {
                intentName = Path.Combine(stored, intentName);
                objectContent = popupContent(intentName);
            }

            if (objectContent != null)
                return JsonConvert.DeserializeObject<T>(objectContent);

            if (!popupIfAny)
                return default;

            foreach (var fileName in Directory.EnumerateFiles(stored))
            {
                objectContent = popupContent(fileName);
            }

            if (objectContent != null)
                return JsonConvert.DeserializeObject<T>(objectContent);

            return default;

        }
    }

}
