using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Security.Cryptography.X509Certificates;
using System.IO;
using System.Net;
using System.Runtime.InteropServices;

using CommonLib.Utility;
using CommonLib.Core.Properties;

namespace CommonLib.Security.UseCrypto
{
    public class X509CrlUtility
    {

        private X509Certificate2 _cert;
        private string _crlUrl;
        private string _errMsg = null;

        public String ErrorMessage
        {
            get
            {
                return _errMsg;
            }
        }

        public X509CrlUtility(X509Certificate2 cert)
        {
            _cert = cert;
            _crlUrl = ExtractCRLUrlFromCertificate(_cert);
        }

        public bool IsNotRevoked()
        {
            if (AppSettings.Default.IgnoreCertificateRevoked)
                return true;

            //IntPtr pCert = IntPtr.Zero;

            bool bResult = false;

            //IntPtr pCrlContext = buildCrl();

            //if (pCrlContext != IntPtr.Zero)
            //{
            //    IntPtr pCrlEntry = IntPtr.Zero;

            //    bResult = Win32.Win32.CertFindCertificateInCRL(_cert.Handle, pCrlContext, 0, IntPtr.Zero, ref pCrlEntry);
            //    if (bResult)
            //    {
            //        if (IntPtr.Zero != pCrlEntry)
            //        {
            //            _errMsg = "憑證已撤銷!";
            //            bResult = false;
            //        }
            //    }

            //    Win32.Win32.CertFreeCRLContext(pCrlContext);
            //}

            return bResult;

        }

        //private IntPtr buildCrl()
        //{
        //    string crlCache = prepareCrlCache();

        //    if (crlCache == null)
        //        return IntPtr.Zero;

        //    IntPtr pCrlContext = openCRL(crlCache);
        //    if (IntPtr.Zero == pCrlContext)
        //    {
        //        _errMsg = Win32.Win32.ShowWin32Error(Marshal.GetLastWin32Error());
        //        return IntPtr.Zero;
        //    }

        //    Win32.Win32.CRL_CONTEXT crlContext = (Win32.Win32.CRL_CONTEXT)Marshal.PtrToStructure(pCrlContext, typeof(Win32.Win32.CRL_CONTEXT));
        //    Win32.Win32.CRL_INFO crlInfo = (Win32.Win32.CRL_INFO)Marshal.PtrToStructure(crlContext.pCrlInfo, typeof(Win32.Win32.CRL_INFO));
        //    DateTime crlUpdate = DateTime.FromFileTime(((long)crlInfo.NextUpdate.dwHighDateTime << 32) + (long)crlInfo.NextUpdate.dwLowDateTime);

        //    if (crlUpdate < DateTime.Now)
        //    {
        //        Win32.Win32.CertFreeCRLContext(pCrlContext);
        //        NetTool.CacheUrlResource(_crlUrl, crlCache);

        //        if (!File.Exists(crlCache))
        //        {
        //            _errMsg = String.Format("無法讀取載憑證廢止清單=>{0}", crlCache);
        //            return IntPtr.Zero;
        //        }

        //        pCrlContext = openCRL(crlCache);
        //        if (IntPtr.Zero == pCrlContext)
        //        {
        //            _errMsg = Win32.Win32.ShowWin32Error(Marshal.GetLastWin32Error());
        //            return IntPtr.Zero;
        //        }
        //    }

        //    return pCrlContext;
        //}

        //private string prepareCrlCache()
        //{
        //    string crlCache;

        //    if (String.IsNullOrEmpty(_crlUrl))
        //    {
        //        return null;
        //    }


        //    Uri uri = new Uri(_crlUrl);
        //    crlCache = Path.Combine(Logger.LogPath, Uri.UnescapeDataString(uri.Segments[uri.Segments.Length - 1]));


        //    if (!File.Exists(crlCache))
        //    {
        //        NetTool.CacheUrlResource(_crlUrl, crlCache);
        //    }

        //    if (!File.Exists(crlCache))
        //    {
        //        _errMsg = String.Format("無法下載憑證廢止清單=>{0}", _crlUrl);
        //        return null;
        //    }

        //    return crlCache;
        //}

        //private IntPtr openCRL(string crl)
        //{

        //    FileStream fs = new FileStream(crl, FileMode.Open, FileAccess.Read);
        //    byte[] crlBuf = new byte[fs.Length];
        //    fs.Read(crlBuf, 0, (int)fs.Length);
        //    fs.Close();

        //    uint cbLen = (uint)crlBuf.Length;
        //    return Win32.Win32.CertCreateCRLContext(MY_ENCODING_TYPE, crlBuf, cbLen);

        //}



        public static string ExtractCRLUrlFromCertificate(X509Certificate2 cert)
        {
            string[] separator = new string[] { "\r\n" };

            foreach (X509Extension ext in cert.Extensions)
            {
                string[] extData = ext.Format(true).Split(separator, StringSplitOptions.RemoveEmptyEntries);
                if (extData[0].IndexOf("CRL Distribution Point") >= 0)
                {
                    for (int i = 1; i < extData.Length; i++)
                    {
                        int urlAt = extData[i].IndexOf("URL=");
                        if (urlAt >= 0)
                        {
                            return extData[i].Substring(urlAt + 4);
                        }
                    }
                }
            }

            return null;
        }



    }
}
