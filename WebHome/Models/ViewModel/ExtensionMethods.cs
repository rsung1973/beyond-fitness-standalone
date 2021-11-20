using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using CommonLib.Utility;
using WebHome.Helper;

namespace WebHome.Models.ViewModel
{
    public static class ExtensionMethods
    {
        public static byte[] DecryptKey(this QueryViewModel viewModel)
        {
            return AppResource.Instance.DecryptSalted(Convert.FromBase64String(viewModel.KeyID));
        }

        public static byte[] DecryptHexKey(this QueryViewModel viewModel)
        {
            return AppResource.Instance.DecryptSalted(viewModel.HKeyID.HexToByteArray());
        }

        public static int DecryptKeyValue(this QueryViewModel viewModel)
        {
            return BitConverter.ToInt32(viewModel.DecryptKey(), 0);
        }

        public static int DecryptKeyValue(this String keyID)
        {
            return BitConverter.ToInt32(keyID.DecryptData(), 0);
        }

        public static int DecryptHexKeyValue(this QueryViewModel viewModel)
        {
            return BitConverter.ToInt32(viewModel.DecryptHexKey(), 0);
        }


        public static void EncryptKey(this QueryViewModel viewModel, byte[] data)
        {
            viewModel.KeyID = Convert.ToBase64String(AppResource.Instance.EncryptSalted(data));
        }

        public static void EncryptHexKey(this QueryViewModel viewModel, byte[] data)
        {
            viewModel.HKeyID = AppResource.Instance.EncryptSalted(data).ToHexString();
        }


        public static String EncryptKey(this byte[] data)
        {
            return Convert.ToBase64String(AppResource.Instance.EncryptSalted(data));
        }


        public static String EncryptHexKey(this byte[] data)
        {
            return AppResource.Instance.EncryptSalted(data).ToHexString();
        }


        public static String EncryptKey(this int keyID)
        {
            return BitConverter.GetBytes(keyID).EncryptKey();
        }
        public static String EncryptHexKey(this int keyID)
        {
            return BitConverter.GetBytes(keyID).EncryptHexKey();
        }

        public static String EncryptKey(this String keyID)
        {
            return Encoding.Default.GetBytes(keyID).EncryptKey();
        }
        public static String DecryptKey(this String data)
        {
            return Encoding.Default.GetString(AppResource.Instance.DecryptSalted(Convert.FromBase64String(data)));
        }
        public static byte[] DecryptData(this String data)
        {
            return AppResource.Instance.DecryptSalted(Convert.FromBase64String(data));
        }

    }

}