using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Web;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace WebHome.Helper
{
    public sealed class AppResource
    {
        private static AppResource _instance = new AppResource();

        private ILogger _logger = ApplicationLogging.LoggerFactory.CreateLogger<AppResource>();
        class __KeyResource
        {
            public byte[] Key { get; set; }
            public byte[] IV { get; set; }
            public CipherMode Mode { get; set; }
        }

        public TripleDES CurrentTripleDES
        {
            get;
            private set;
        }

        private AppResource()
        {
            CurrentTripleDES = TripleDES.Create();
            InitializeKey();
        }

        public void InitializeKey(bool reset = false)
        {
            string keyFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "SystemKey.json");

            void saveKeyResource()
            {
                __KeyResource kr = new __KeyResource
                {
                    Key = CurrentTripleDES.Key,
                    IV = CurrentTripleDES.IV,
                    Mode = CurrentTripleDES.Mode,
                };
                File.WriteAllText(keyFile, JsonConvert.SerializeObject(kr));
            }

            if (reset)
            {
                CurrentTripleDES.Dispose();
                CurrentTripleDES = TripleDES.Create();
                saveKeyResource();
                return;
            }

            if (File.Exists(keyFile))
            {
                try
                {
                    var kr = JsonConvert.DeserializeObject<__KeyResource>(File.ReadAllText(keyFile));
                    CurrentTripleDES.Key = kr.Key;
                    CurrentTripleDES.IV = kr.IV;
                    CurrentTripleDES.Mode = kr.Mode;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, ex.Message);
                    saveKeyResource();
                }
            }
            else
            {
                saveKeyResource();
            }
        }

        public static AppResource Instance
        {
            get
            {
                return _instance;
            }
        }

        public byte[] Encrypt(byte[] data)
        {
            ICryptoTransform xfrm = CurrentTripleDES.CreateEncryptor();
            byte[] outBlock = xfrm.TransformFinalBlock(data, 0, data.Length);
            return outBlock;
        }

        public byte[] Decrypt(byte[] data)
        {
            ICryptoTransform xfrm = CurrentTripleDES.CreateDecryptor();
            byte[] outBlock = xfrm.TransformFinalBlock(data, 0, data.Length);
            return outBlock;
        }

        public byte[] EncryptSalted(byte[] data)
        {
            return Encrypt(data.Concat(BitConverter.GetBytes(DateTime.Now.Ticks)).ToArray());
        }

        public byte[] EncryptNormal(byte[] data)
        {
            return Encrypt(data.Concat(BitConverter.GetBytes(0L)).ToArray());
        }


        public byte[] DecryptSalted(byte[] data)
        {
            byte[] result = Decrypt(data);
            return result.Take(result.Length - 8).ToArray();
        }



    }
}