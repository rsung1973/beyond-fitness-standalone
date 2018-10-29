using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using WebHome.Helper;

namespace WebHome.Models.ViewModel
{
    public static class ExtensionMethods
    {
        public static byte[] DecryptKey(this QueryViewModel viewModel)
        {
            return AppResource.Instance.DecryptSalted(Convert.FromBase64String(viewModel.KeyID));
        }

        public static int DecryptKeyValue(this QueryViewModel viewModel)
        {
            return BitConverter.ToInt32(viewModel.DecryptKey(), 0);
        }

        public static void EncryptKey(this QueryViewModel viewModel, byte[] data)
        {
            viewModel.KeyID = Convert.ToBase64String(AppResource.Instance.EncryptSalted(data));
        }

        public static String EncryptKey(this byte[] data)
        {
            return Convert.ToBase64String(AppResource.Instance.EncryptSalted(data));
        }

        public static String EncryptKey(this int keyID)
        {
            return BitConverter.GetBytes(keyID).EncryptKey();
        }

        public static String EncryptKey(this String keyID)
        {
            return Encoding.Default.GetBytes(keyID).EncryptKey();
        }
        public static String DecryptKey(this String data)
        {
            return Encoding.Default.GetString(AppResource.Instance.DecryptSalted(Convert.FromBase64String(data)));
        }

    }

}