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

using CommonLib.Utility;
using System.Runtime.ConstrainedExecution;

namespace CommonLib.Security.UseCrypto
{
	/// <summary>
	/// PKCS7 的摘要描述。
	/// </summary>
	public class CryptoBase
	{
        internal static X509Certificate IssuerCert;

		protected X509Certificate2 _cert ;
        protected dsPKCS7 _ds;
        protected dsPKCS7Pkcs7Envelop _log;

        public Func<X509Certificate2, bool> CheckCertificateTrusted
        {
            get;
            set;
        }

        protected CryptoBase()
		{
            //
            // TODO: 在此加入建構函式的程式碼
            //

            if (_ds == null)
            {
                _ds = new dsPKCS7();
            }

            if (_ds.pkcs7Envelop == null)
            {
                _ds.pkcs7Envelop = new dsPKCS7Pkcs7Envelop { };
            }
            _log = _ds.pkcs7Envelop;

        }

        protected bool isCertTrusted(X509Certificate2 certificate)
        {
            if (CheckCertificateTrusted != null)
            {
                return CheckCertificateTrusted(certificate);
            }

            bool bResult = false;

            if (null != IssuerCert)
            {
                bResult = IssuerCert.Subject.Equals(certificate.Issuer);
            }

            if (bResult)
                return true;

            #region 從Certificate Store取得信任的憑證

            X509Store store = new X509Store(StoreName.CertificateAuthority, StoreLocation.LocalMachine);
            store.Open(OpenFlags.OpenExistingOnly | OpenFlags.ReadOnly);

            foreach(X509Certificate2 cert in  store.Certificates)
            {
                if (cert.Subject.Equals(certificate.Issuer))
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

//		protected bool isCertTrusted(IntPtr pCert)
//		{
//			bool bResult = false;

//			if(null!=IssuerCert)
//			{
//                bResult = IssuerCert.Subject.Equals(_cert.Issuer);
//			}

//			if(bResult)
//				return true;

//			#region 從Certificate Store取得信任的憑證

//            IntPtr hCertStore = Win32.Win32.CertOpenSystemStore(IntPtr.Zero, "CA");
//			if(IntPtr.Zero == hCertStore)
//			{
//                _log.Message = Win32.Win32.ShowWin32Error(Marshal.GetLastWin32Error());
//				return false;
//			}

//			IntPtr issuer = IntPtr.Zero;
//			uint dwCheck;

//            while ((issuer = Win32.Win32.CertEnumCertificatesInStore(hCertStore, issuer)) != IntPtr.Zero)
//			{
//                dwCheck = Win32.Win32.CERT_STORE_SIGNATURE_FLAG;
//                bResult = Win32.Win32.CertVerifySubjectCertificateContext(pCert, issuer, ref dwCheck) && (dwCheck == 0);
//				if(bResult)
//				{
//                    Win32.Win32.CERT_CONTEXT certCtx = (Win32.Win32.CERT_CONTEXT)Marshal.PtrToStructure(issuer, typeof(Win32.Win32.CERT_CONTEXT));
//					byte[] certBytes = new byte[certCtx.cbCertEncoded];
//					Marshal.Copy(certCtx.pbCertEncoded,certBytes,0,certBytes.Length);

//					IssuerCert = new X509Certificate(certBytes);
//					//底下這行語法正確,但是此處不能這樣用,需要cert context複製出來
////					IssuerCert = new X509Certificate(issuer);

//                    Win32.Win32.CertFreeCertificateContext(issuer);
//					break;
//				}
//			}

//            Win32.Win32.CertCloseStore(hCertStore, Win32.Win32.CERT_CLOSE_STORE_FORCE_FLAG);

//			#endregion

//			return bResult;
//		}

		public dsPKCS7Pkcs7Envelop CA_Log
		{
			get
			{
				return _log;
			}
		}

        public dsPKCS7 PKCS7Log
        {
            get
            {
                return _ds;
            }
        }

        protected void beforeVerify(string dataToSign, string dataSignature, X509Certificate2 cert2)
        {
            _log.DataToSign = dataToSign;
            _log.DataSignature = dataSignature;
            _log.ActionTime = DateTime.Now;
            _log.Issuer = cert2.Issuer;
            _log.NotAfter = cert2.NotAfter.ToString();
            _log.NotBefore = cert2.NotBefore.ToString();
            _log.Subject = cert2.Subject;
            _log.UniqueID = cert2.SerialNumber;
        }

        protected void beforeVerify(XmlDocument xmlSignature, X509Certificate2 cert2)
        {
            _ds.XmlSignature = xmlSignature;
            _log.ActionTime = DateTime.Now;
            _log.Issuer = cert2.Issuer;
            _log.NotAfter = cert2.NotAfter.ToString();
            _log.NotBefore = cert2.NotBefore.ToString();
            _log.Subject = cert2.Subject;
            _log.UniqueID = cert2.SerialNumber;
        }


        protected virtual bool verifySignerCertificate(X509Certificate2 cert2)
        {
            bool result = false;

            #region 檢查憑證是否被信任

            if (isCertTrusted(cert2))
            {
                #region 檢查憑證是否已撤銷
                X509CrlUtility crlUtil = new X509CrlUtility(cert2);

                if (crlUtil.IsNotRevoked())
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
                    _log.Message = crlUtil.ErrorMessage;
                }

                #endregion

            }
            else
            {
                _log.Message = "憑證是由未被信任的發證單位所發出!";
            }


            #endregion
            return result;
        }


        public X509Certificate2 SignerCertificate
        {
            get
            {
                return _cert;
            }
        }
	}
}
