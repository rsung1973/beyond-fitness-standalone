using System;
using System.IO;
using System.Runtime.InteropServices;
using System.ComponentModel;
using System.Reflection;
using System.Text;
using System.Net;
using System.Xml;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Security.Cryptography.Xml;
using System.Security.Cryptography.X509Certificates;
using System.Security.Cryptography.Pkcs;
using System.Collections.Generic;

using Utility;


namespace CommonLib.Security.UseCrypto
{
	/// <summary>
	/// PKCS7 的摘要描述。
	/// </summary>
	public class PKCS7
	{

        static uint MY_ENCODING_TYPE = Win32.Win32.PKCS_7_ASN_ENCODING | Win32.Win32.X509_ASN_ENCODING;
		private X509Certificate _cert ;
		private dsPKCS7 _ds;
		private dsPKCS7.pkcs7EnvelopRow _log;

		private static X509Certificate IssuerCert;



		public PKCS7()
		{
			//
			// TODO: 在此加入建構函式的程式碼
			//
			_ds = new dsPKCS7();
		}

        private DateTime FileTimeToDateTime(Win32.FILETIME ft)
		{
			return DateTime.FromFileTime(((long)ft.dwHighDateTime<<32) + (long)ft.dwLowDateTime);
		}

        private bool verify(byte[] dataToSign, byte[] dataSignature)
        {
            #region 建立驗簽記錄檔
            _log = _ds.pkcs7Envelop.Newpkcs7EnvelopRow();
            _ds.pkcs7Envelop.Addpkcs7EnvelopRow(_log);

            _log.DataToSign = System.Text.Encoding.Default.GetString(dataToSign);
            _log.DataSignature = Convert.ToBase64String(dataSignature);
            _log.ActionTime = DateTime.Now;

            #endregion
            bool result = false;
            ContentInfo contentInfo = new ContentInfo(dataToSign);

            // Create a new, detached SignedCms message.

            SignedCms signedCms = new SignedCms(contentInfo, true);

            //解密文
            signedCms.Decode(dataSignature);
            // 驗證資料完整性
            signedCms.CheckHash();

            //取得密文中的第一張憑證
            _cert = signedCms.Certificates[0];
            X509Certificate2 cert2 = new X509Certificate2(_cert);

            _log.Issuer = cert2.Issuer;
            _log.NotAfter = cert2.NotAfter.ToString();
            _log.NotBefore = cert2.NotBefore.ToString();
            _log.Subject = cert2.Subject;
            _log.UniqueID = cert2.SerialNumber;

            IntPtr pCertCtx = IntPtr.Zero;
            pCertCtx = Win32.Win32.CertCreateCertificateContext(MY_ENCODING_TYPE, _cert.GetRawCertData(), _cert.GetRawCertData().Length);

            #region 驗簽

            try
            {

                signedCms.CheckSignature(true);
                #region 檢查憑證是否被信任

                if (isCertTrusted())
                {
                    #region 檢查憑證是否已撤銷
                    if (isCertNotRevoked(pCertCtx, getCertCRLUrl(cert2)))
                    {
                        #region 檢查憑證是否過期
                        if (cert2.NotAfter >= DateTime.Now)
                        {
                            result = true;
                        }
                        else
                        {
                            _log.Message = "憑證已過期!";
                        }

                        #endregion

                    }
                    else
                    {
                        _log.Message = "憑證已撤銷!";
                    }

                    #endregion

                }
                else
                {
                    _log.Message = "憑證是由未被信任的發證單位所發出!";
                }


                #endregion

            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                _log.Message = "簽章驗證失敗:" + ex.Message;
            }

            #endregion

            if (pCertCtx != IntPtr.Zero)
                Win32.Win32.CertFreeCertificateContext(pCertCtx);

            if (result)
                Logger.Info(_ds);
            else
                Logger.Warn(_ds);

            return result;
        }


        private string getCertCRLUrl(X509Certificate2 cert)
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


        private bool isCertTrusted()
        {
            bool bResult = false;

            if (null != IssuerCert)
            {
                bResult = IssuerCert.Subject.Equals(_cert.Issuer);
            }

            if (bResult)
                return true;

            #region 從Certificate Store取得信任的憑證

            X509Store store = new X509Store(StoreName.CertificateAuthority, StoreLocation.LocalMachine);
            store.Open(OpenFlags.OpenExistingOnly | OpenFlags.ReadOnly);

            foreach(X509Certificate2 cert in  store.Certificates)
            {
                if (cert.Subject.Equals(_cert.Issuer))
                {
                    bResult = true;
                    IssuerCert = cert;
                    break;
                }
            }

            store.Close();

            #endregion

            return bResult;
        }




		private bool isCertTrusted(IntPtr pCert)
		{
			bool bResult = false;

			if(null!=IssuerCert)
			{
                bResult = IssuerCert.Subject.Equals(_cert.Issuer);
			}

			if(bResult)
				return true;

			#region 從Certificate Store取得信任的憑證

            IntPtr hCertStore = Win32.Win32.CertOpenSystemStore(IntPtr.Zero, "CA");
			if(IntPtr.Zero == hCertStore)
			{
				ShowWin32Error(Marshal.GetLastWin32Error());
				return false;
			}

			IntPtr issuer = IntPtr.Zero;
			uint dwCheck;

            while ((issuer = Win32.Win32.CertEnumCertificatesInStore(hCertStore, issuer)) != IntPtr.Zero)
			{
                dwCheck = Win32.Win32.CERT_STORE_SIGNATURE_FLAG;
                bResult = Win32.Win32.CertVerifySubjectCertificateContext(pCert, issuer, ref dwCheck) && (dwCheck == 0);
				if(bResult)
				{
                    Win32.Win32.CERT_CONTEXT certCtx = (Win32.Win32.CERT_CONTEXT)Marshal.PtrToStructure(issuer, typeof(Win32.Win32.CERT_CONTEXT));
					byte[] certBytes = new byte[certCtx.cbCertEncoded];
					Marshal.Copy(certCtx.pbCertEncoded,certBytes,0,certBytes.Length);

					IssuerCert = new X509Certificate(certBytes);
					//底下這行語法正確,但是此處不能這樣用,需要cert context複製出來
//					IssuerCert = new X509Certificate(issuer);

                    Win32.Win32.CertFreeCertificateContext(issuer);
					break;
				}
			}

            Win32.Win32.CertCloseStore(hCertStore, Win32.Win32.CERT_CLOSE_STORE_FORCE_FLAG);

			#endregion

			return bResult;
		}

		public dsPKCS7.pkcs7EnvelopRow CA_Log
		{
			get
			{
				return _log;
			}
		}

		public bool VerifyPKCS7File(string dataPath,string signaturePath)
		{

			if(!File.Exists(dataPath))
			{
				Trace.WriteLine("File '{0}' not found. ", dataPath);
				return false;
			}

			byte[] dataToSign = ValueValidity.GetFileBytes(dataPath);

			if(!File.Exists(signaturePath))
			{
				Trace.WriteLine("File '{0}' not found. ", signaturePath);
				return false;
			}

			//------- Get encoded enveloped data from file -----
            byte[] envdata = ValueValidity.GetFileBytes(signaturePath);

			string b64str = (new ASCIIEncoding()).GetString(envdata); // possibly b64 file
			envdata = Convert.FromBase64String(b64str);

			return verify(dataToSign,envdata);

		}

		public bool VerifyPKCS7(string dataToSign,string b64DataSignature)
		{
			return verify(System.Text.Encoding.Default.GetBytes(dataToSign),
				Convert.FromBase64String(b64DataSignature));
		}

		public bool VerifyPKCS7(byte[] dataToSign,byte[] dataSignature)
		{
			return verify(dataToSign,dataSignature);
		}

        public X509Certificate SignerCertificate
        {
            get
            {
                return _cert;
            }
        }

        private bool isCertNotRevoked(IntPtr pCert, string crlUrl)
        {
            if (String.IsNullOrEmpty(crlUrl))
            {
                return false;
            }

            bool bResult = false;
            string crlCache;

            Uri uri = new Uri(crlUrl);

            crlCache = Path.Combine(Logger.LogPath, Uri.UnescapeDataString(uri.Segments[uri.Segments.Length - 1]));


            if (!File.Exists(crlCache))
            {
                downloadCRL(crlUrl, crlCache);
            }

            if (!File.Exists(crlCache))
            {
                _log.Message = String.Format("無法下載憑證廢止清單=>{0}", crlUrl);
                return false;
            }


            IntPtr pCrlContext;

            #region 取得憑證廢止清單

            pCrlContext = openCRL(crlCache);
            if (IntPtr.Zero == pCrlContext)
            {
                _log.Message = ShowWin32Error(Marshal.GetLastWin32Error());
                return false;
            }

            Win32.Win32.CRL_CONTEXT crlContext = (Win32.Win32.CRL_CONTEXT)Marshal.PtrToStructure(pCrlContext, typeof(Win32.Win32.CRL_CONTEXT));
            Win32.Win32.CRL_INFO crlInfo = (Win32.Win32.CRL_INFO)Marshal.PtrToStructure(crlContext.pCrlInfo, typeof(Win32.Win32.CRL_INFO));
            DateTime crlUpdate = DateTime.FromFileTime(((long)crlInfo.NextUpdate.dwHighDateTime << 32) + (long)crlInfo.NextUpdate.dwLowDateTime);

            if (crlUpdate < DateTime.Now)
            {
                Win32.Win32.CertFreeCRLContext(pCrlContext);
                downloadCRL(crlUrl, crlCache);

                if (!File.Exists(crlCache))
                {
                    _log.Message = String.Format("無法讀取載憑證廢止清單=>{0}", crlCache);
                    return false;
                }

                pCrlContext = openCRL(crlCache);
                if (IntPtr.Zero == pCrlContext)
                {
                    _log.Message = ShowWin32Error(Marshal.GetLastWin32Error());
                    return false;
                }

            }
            #endregion

            IntPtr pCrlEntry = IntPtr.Zero;

            bResult = Win32.Win32.CertFindCertificateInCRL(pCert, pCrlContext, 0, IntPtr.Zero, ref pCrlEntry);
            if (bResult)
            {
                if (IntPtr.Zero != pCrlEntry)
                {
                    _log.Message = "憑證已撤銷!";
                    bResult = false;
                }
            }

            Win32.Win32.CertFreeCRLContext(pCrlContext);

            return bResult;

        }


		private IntPtr openCRL(string crl)
		{

			FileStream fs = new FileStream(crl,FileMode.Open,FileAccess.Read);
			byte[] crlBuf = new byte[fs.Length];
			fs.Read(crlBuf,0,(int)fs.Length);
			fs.Close();

			uint cbLen = (uint)crlBuf.Length;
            return Win32.Win32.CertCreateCRLContext(MY_ENCODING_TYPE, crlBuf, cbLen);

		}


		private bool downloadCRL(string crlUrl,string saveTo)
		{
			bool bResult = false;

			try
			{
				HttpWebRequest webRequest = (HttpWebRequest)WebRequest.Create(crlUrl);
				webRequest.Method = "GET";

				HttpWebResponse webResponse = (HttpWebResponse)webRequest.GetResponse();
				long contentLength = webResponse.ContentLength;
				Stream input = webResponse.GetResponseStream();
				byte[] buf = new byte[4096];
				int nRead;

				FileStream fs = new FileStream(saveTo,FileMode.Create,FileAccess.Write);
				while((nRead=input.Read(buf,0,4096))>0)
				{
					fs.Write(buf,0,nRead);
				}
				fs.Flush();
				fs.Close();

				input.Close();
				bResult = true;
			}
			catch(Exception ex)
			{
				System.Diagnostics.Trace.WriteLine(ex);
			}

			return bResult;

		}

		public static string ShowWin32Error(int errorcode)
		{
			Win32Exception myEx=new Win32Exception(errorcode);
            string msg = String.Format("Error message: {0}  (Code: 0x{1:X})", myEx.Message, myEx.ErrorCode);
            return msg;
		}
	}
}
