using System;
using System.Collections.Generic;
//using System.Deployment.Internal.CodeSigning;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Security;
using System.Security.Cryptography;
using System.Security.Cryptography.Pkcs;
using System.Security.Cryptography.X509Certificates;
using System.Security.Cryptography.Xml;
using System.Text;
using System.Xml;
using CommonLib.Core.Properties;
using CommonLib.Core.Utility;
using CommonLib.Utility;

namespace CommonLib.Security.UseCrypto
{
    public partial class CryptoUtility : CryptoBase
    {
        static CryptoUtility()
        {
            //CryptoConfig.AddAlgorithm(
            //            typeof(RSAPKCS1SHA256SignatureDescription),
            //            "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256");
        }

        public CryptoUtility() : base() { }

        public bool VerifySignatureOnly { get; set; }

        public bool VerifyPKCS7File(string dataPath, string signaturePath)
        {
            if (!File.Exists(dataPath))
            {
                FileLogger.Logger.Error(String.Format("File '{0}' not found. ", dataPath));
                return false;
            }

            byte[] dataToSign = File.ReadAllBytes(dataPath);

            if (!File.Exists(signaturePath))
            {
                FileLogger.Logger.Error(String.Format("File '{0}' not found. ", signaturePath));
                return false;
            }

            //------- Get encoded enveloped data from file -----
            byte[] envdata = File.ReadAllBytes(signaturePath);

            string b64str = (new ASCIIEncoding()).GetString(envdata); // possibly b64 file
            envdata = Convert.FromBase64String(b64str);

            return verify(dataToSign, envdata);

        }

        public bool VerifyEnvelopedPKCS7(byte[] p7bData, out byte[] dataToSign)
        {
            SignedCms signedCms = new SignedCms();
            //解密文
            signedCms.Decode(p7bData);
            // 驗證資料完整性
            signedCms.CheckHash();

            dataToSign = signedCms.ContentInfo.Content;

            return verifySignedCms(p7bData, signedCms);
        }


        private bool verify(byte[] dataToSign, byte[] dataSignature)
        {
            ContentInfo contentInfo = new ContentInfo(dataToSign);

            // Create a new, detached SignedCms message.

            SignedCms signedCms = new SignedCms(contentInfo, true);
            //解密文
            signedCms.Decode(dataSignature);
            // 驗證資料完整性
            signedCms.CheckHash();

            return verifySignedCms(dataSignature, signedCms);
        }

        private bool verifySignedCms(byte[] dataSignature, SignedCms signedCms)
        {
            bool result = false;

            //取得首張簽章者憑證
            _cert = signedCms.SignerInfos[0].Certificate;
            X509Certificate2 cert2 = signedCms.SignerInfos[0].Certificate;  // new X509Certificate2(_cert);

            if (dataSignature != null)
            {
                beforeVerify("base64:" + Convert.ToBase64String(signedCms.ContentInfo.Content), Convert.ToBase64String(dataSignature), cert2);
            }
            else
            {
                beforeVerify("base64:" + Convert.ToBase64String(signedCms.ContentInfo.Content), String.Empty, cert2);
            }

            #region 驗簽

            try
            {

                signedCms.CheckSignature(true);
                if (VerifySignatureOnly)
                    result = true;
                else
                    result = verifySignerCertificate(cert2);

            }
            catch (Exception ex)
            {
                FileLogger.Logger.Error(ex);
                _log.Message = "簽章驗證失敗:" + ex.Message;
            }

            #endregion

            if (result)
                FileLogger.Logger.Info(_ds);
            else
                FileLogger.Logger.Warn(_ds);

            return result;
        }

        protected override bool verifySignerCertificate(X509Certificate2 cert2)
        {
            if (CheckCertificateTrusted != null)
            {
                if (CheckCertificateTrusted(cert2))
                    return true;
                else
                    _log.Message = "檢查憑證信任失敗";
                return false;
            }
            else
            {
                X509Chain chain = new X509Chain(true);
                if (AppSettings.Default.IgnoreCertificateRevoked)
                {
                    chain.ChainPolicy.RevocationMode = X509RevocationMode.NoCheck;
                }
                if (chain.Build(cert2))
                {
                    return true;
                }
                else
                {
                    _log.Message = String.Join("", chain.ChainStatus.Select(s => s.StatusInformation));
                }
                return false;
            }
        }


        public bool VerifyPKCS7(string dataToSign, string b64DataSignature)
        {
            return verify(System.Text.Encoding.Default.GetBytes(dataToSign),
                Convert.FromBase64String(b64DataSignature));
        }

        public bool VerifyPKCS7(byte[] dataToSign, byte[] dataSignature)
        {
            return verify(dataToSign, dataSignature);
        }

        public bool VerifyXmlSignature(string xmlSignature)
        {
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(xmlSignature);
            return VerifyXmlSignature(doc);
        }

        public bool VerifyXmlSignature(XmlNode xmlSignature)
        {
            XmlDocument doc = new XmlDocument();
            using (XmlNodeReader xnr = new XmlNodeReader(xmlSignature))
            {
                doc.Load(xnr);
            }
            return VerifyXmlSignature(doc);
        }


        public bool VerifyXmlSignature(XmlDocument doc)
        {
            bool result = false;


            #region 驗簽

            try
            {
                _ds.XmlSignature = doc;
                SignedXml signedXml = new SignedXml(doc);

                XmlElement elmt = (XmlElement)doc.GetElementsByTagName("Signature", "http://www.w3.org/2000/09/xmldsig#")[0];
                signedXml.LoadXml(elmt);

                // 確保 KeyInfo 包含有效的證書
                var certNode = signedXml.KeyInfo.GetXml().GetElementsByTagName("X509Certificate")[0];
                if (certNode == null)
                {
                    throw new InvalidOperationException("X509Certificate element not found in KeyInfo.");
                }
                _cert = new X509Certificate2(Convert.FromBase64String(certNode.InnerText));
                
                // 確保 SigningKey 正確設置
                //signedXml.SigningKey = _cert.PublicKey.Key;

                //_cert = new X509Certificate2(Convert.FromBase64String(signedXml.KeyInfo.GetXml().GetElementsByTagName("X509Certificate")[0].InnerText));
                //X509Certificate2 cert2 = new X509Certificate2(_cert);
                beforeVerify(doc, _cert);

                if (signedXml.CheckSignatureReturningKey(out AsymmetricAlgorithm? key))
                {
                    if (VerifySignatureOnly)
                        result = true;
                    else
                        result = verifySignerCertificate(_cert);
                }
            }
            catch (Exception ex)
            {
                FileLogger.Logger.Error(ex);
                _log.Message = "簽章驗證失敗:" + ex.Message;
            }

            #endregion

            if (result)
                FileLogger.Logger.Info(_ds);
            else
                FileLogger.Logger.Warn(_ds);

            return result;
        }

        //public bool VerifyRSASignature(X509Certificate signerCert, byte[] dataToSign, byte[] signature)
        //{
        //    bool bResult = false;

        //    byte[] keyBlob = signerCert.GetPublicKey();
        //    RSAPublicKey rsaPK = new RSAPublicKey(keyBlob);

        //    BigInteger exponent = new BigInteger(rsaPK.keyExponent);
        //    BigInteger modulus = new BigInteger(rsaPK.keyModulus);
        //    BigInteger sig = new BigInteger(signature);

        //    BigInteger decrypt = sig.modPow(exponent, modulus);
        //    byte[] sigBytes = decrypt.getBytes();

        //    byte[] sigDecrypted = new byte[20];
        //    Array.Copy(sigBytes, 107, sigDecrypted, 0, 20);

        //    SHA1CryptoServiceProvider sha1 = new SHA1CryptoServiceProvider();
        //    //SHA1 sha1 = new SHA1Managed();
        //    byte[] hashBytes = sha1.ComputeHash(dataToSign);

        //    if (sigDecrypted.Length == hashBytes.Length)
        //    {
        //        int i;
        //        for (i = 0; i < sigDecrypted.Length && sigDecrypted[i] == hashBytes[i]; i++) ;
        //        if (i == sigDecrypted.Length)
        //        {
        //            bResult = true;
        //        }
        //    }
        //    return bResult;
        //}


        public static bool SignXml(XmlDocument docMsg, String cspName, String keyStorePhrass, X509Certificate2 signerCert, String referenceUri = "")
        {

            try
            {
                if (!String.IsNullOrEmpty(cspName))
                {

                    // Generate a signing key.
                    CspParameters csp = new CspParameters(1, cspName);
                    csp.Flags = CspProviderFlags.UseDefaultKeyContainer;
                    csp.KeyNumber = (int)KeyNumber.Signature;

                    if (!String.IsNullOrEmpty(keyStorePhrass))
                    {
                        csp.KeyPassword = new SecureString();
                        foreach (var ch in keyStorePhrass.ToCharArray())
                        {
                            csp.KeyPassword.AppendChar(ch);
                        }
                    }

                    RSACryptoServiceProvider Key = new RSACryptoServiceProvider(csp);
                }

                SignedXml signedXml = new SignedXml(docMsg);
                signedXml.SigningKey = signerCert.PrivateKey;

                Reference reference = new Reference();
                reference.Uri = referenceUri;

                //Add an enveloped transformation to the reference.
                XmlDsigEnvelopedSignatureTransform env = new XmlDsigEnvelopedSignatureTransform();
                reference.AddTransform(env);

                // Add the reference to the SignedXml object.
                signedXml.AddReference(reference);

                // Add an RSAKeyValue KeyInfo (optional; helps recipient find key to validate).
                KeyInfo keyInfo = new KeyInfo();
                keyInfo.AddClause(new KeyInfoX509Data(signerCert));
                signedXml.KeyInfo = keyInfo;

                signedXml.ComputeSignature();
                XmlElement xmlDigitalSignature = signedXml.GetXml();

                // Append the element to the XML document.
                docMsg.DocumentElement.AppendChild(docMsg.ImportNode(xmlDigitalSignature, true));

                return true;

            }
            catch (Exception e)
            {
                FileLogger.Logger.Error(e);
            }

            return false;
        }

        public static bool SignXmlSHA256(XmlDocument docMsg, String cspName, String keyStorePhrass, X509Certificate2 signerCert, String referenceUri = "")
        {

            try
            {
                if (!String.IsNullOrEmpty(cspName))
                {

                    // Generate a signing key.
                    CspParameters csp = new CspParameters(1, cspName);
                    csp.Flags = CspProviderFlags.UseDefaultKeyContainer;
                    csp.KeyNumber = (int)KeyNumber.Signature;

                    if (!String.IsNullOrEmpty(keyStorePhrass))
                    {
                        csp.KeyPassword = new SecureString();
                        foreach (var ch in keyStorePhrass.ToCharArray())
                        {
                            csp.KeyPassword.AppendChar(ch);
                        }
                    }

                    RSACryptoServiceProvider Key = new RSACryptoServiceProvider(csp);
                }

                SignedXml signedXml = new SignedXml(docMsg);
                signedXml.SigningKey = signerCert.PrivateKey;

                Reference reference = new Reference();
                reference.Uri = referenceUri;
                reference.DigestMethod = "http://www.w3.org/2001/04/xmlenc#sha256";

                //Add an enveloped transformation to the reference.
                XmlDsigEnvelopedSignatureTransform env = new XmlDsigEnvelopedSignatureTransform();
                reference.AddTransform(env);
                reference.AddTransform(new XmlDsigExcC14NTransform());

                // Add the reference to the SignedXml object.
                signedXml.AddReference(reference);

                // Add an RSAKeyValue KeyInfo (optional; helps recipient find key to validate).
                KeyInfo keyInfo = new KeyInfo();
                keyInfo.AddClause(new KeyInfoX509Data(signerCert));
                signedXml.KeyInfo = keyInfo;

                signedXml.SignedInfo.SignatureMethod = "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256";
                //signedXml.SignedInfo.CanonicalizationMethod = SignedXml.XmlDsigEnvelopedSignatureTransformUrl;
                signedXml.ComputeSignature();
                XmlElement xmlDigitalSignature = signedXml.GetXml();

                // Append the element to the XML document.
                docMsg.DocumentElement.AppendChild(docMsg.ImportNode(xmlDigitalSignature, true));

                return true;

            }
            catch (Exception e)
            {
                FileLogger.Logger.Error(e);
            }

            return false;
        }

    }
}
