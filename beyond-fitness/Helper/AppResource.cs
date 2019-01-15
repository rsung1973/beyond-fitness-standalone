using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Web;

namespace WebHome.Helper
{
    public sealed class AppResource
    {
        private static AppResource _instance = new AppResource();

        public TripleDES CurrentTripleDES
        {
            get;
            private set;
        }

        private AppResource()
        {
            CurrentTripleDES = TripleDES.Create();
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

        public byte[] DecryptSalted(byte[] data)
        {
            byte[] result = Decrypt(data);
            return result.Take(result.Length - 8).ToArray();
        }



    }
}