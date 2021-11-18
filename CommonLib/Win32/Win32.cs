using System;
using System.IO;
using System.Text;
using System.Security;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Runtime.InteropServices;
using System.ComponentModel;

using CRYPT_OBJID_BLOB = Win32.Win32._CRYPTOAPI_BLOB;
using CERT_NAME_BLOB = Win32.Win32._CRYPTOAPI_BLOB;
using CRYPT_INTEGER_BLOB = Win32.Win32._CRYPTOAPI_BLOB;
using HCERTSTORE = System.IntPtr;
using DWORD	= System.UInt32;


	//--- P/Invoke CryptoAPI wrapper classes -----
namespace Win32
{
    public class Win32
    {
        public static string ShowWin32Error(int errorcode)
        {
            Win32Exception myEx = new Win32Exception(errorcode);
            string msg = String.Format("Error message: {0}  (Code: 0x{1:X})", myEx.Message, myEx.ErrorCode);
            return msg;
        }


        [DllImport("crypt32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern IntPtr CertOpenSystemStore(
            IntPtr hCryptProv,
            string storename);

        [DllImport("crypt32.dll", SetLastError = true)]
        public static extern bool CertCloseStore(
            IntPtr hCertStore,
            uint dwFlags);


        [DllImport("crypt32.dll", SetLastError = true)]
        public static extern IntPtr CryptMsgOpenToDecode(
            uint dwMsgEncodingType,
            uint dwFlags,
            uint dwMsgType,
            IntPtr hCryptProv,
            IntPtr pRecipientInfo,
            IntPtr pStreamInfo
            );


        [DllImport("crypt32.dll", SetLastError = true)]
        public static extern bool CryptMsgUpdate(
            IntPtr hCryptMsg,
            byte[] pbData,
            int cbData,
            bool fFinal
            );

        [DllImport("crypt32.dll", SetLastError = true)]
        public static extern bool CryptMsgClose(
            IntPtr hCryptMsg
            );



        [DllImport("crypt32.dll", SetLastError = true)]
        public static extern bool CryptMsgGetParam(
            IntPtr hCryptMsg,
            uint dwParamType,
            int dwIndex,
            IntPtr pvData,
            ref uint pcbData
            );

        [DllImport("crypt32.dll", SetLastError = true)]
        public static extern bool CryptMsgGetParam(
            IntPtr hCryptMsg,
            uint dwParamType,
            int dwIndex,
            ref uint pvData,
            ref uint pcbData
            );


        [DllImport("crypt32.dll")]
        public static extern bool CryptDecodeObject(
            uint CertEncodingType,
            uint lpszStructType,
            byte[] pbEncoded,
            int cbEncoded,
            uint flags,
            IntPtr pvStructInfo,
            ref int cbStructInfo
            );



        [DllImport("crypt32.dll", SetLastError = true)]
        public static extern IntPtr CryptFindOIDInfo(
            uint dwKeyType,
            [MarshalAs(UnmanagedType.LPStr)] String szOID,
            uint dwGroupId
            );


        [DllImport("crypt32.dll", SetLastError = true)]
        public static extern bool CryptDecodeObject(
            uint CertEncodingType,
            uint lpszStructType,
            byte[] pbEncoded,
            uint cbEncoded,
            uint flags,
            [In, Out] byte[] pvStructInfo,
            ref uint cbStructInfo);


        [DllImport("crypt32.dll", SetLastError = true)]
        public static extern bool CryptDecodeObject(
            uint CertEncodingType,
            uint lpszStructType,
            byte[] pbEncoded,
            uint cbEncoded,
            uint flags,
            IntPtr pvStructInfo,
            ref uint cbStructInfo);

        [DllImport("Crypt32.DLL", EntryPoint = "CertCreateCertificateContext",
             SetLastError = true, CharSet = CharSet.Unicode, ExactSpelling = false,
             CallingConvention = CallingConvention.StdCall)]
        public static extern IntPtr CertCreateCertificateContext(
            uint dwCertEncodingType,
            byte[] pbCertEncoded,
            int cbCertEncoded);

        [DllImport("CRYPT32.DLL", SetLastError = true)]
        public static extern IntPtr CertCreateCRLContext(
            uint dwCertEncodingType,
            [In] byte[] pbCrlEncoded,
            [In, Out] uint cbCrlEncoded);

        [DllImport("crypt32.dll", SetLastError = true)]
        public static extern bool CertFreeCRLContext(IntPtr pCrlContext);

        [DllImport("crypt32.dll", SetLastError = true)]
        public static extern bool CertFreeCertificateContext(IntPtr pCertContext);

        [DllImport("crypt32.dll", SetLastError = true)]
        public static extern bool CertFindCertificateInCRL(
            IntPtr pCert,
            IntPtr pCrlContext,
            uint dwFlags,
            IntPtr pvReserved,
            [In, Out] ref IntPtr ppCrlEntry);

        [DllImport("CRYPT32.DLL", EntryPoint = "CertEnumCertificatesInStore", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern IntPtr CertEnumCertificatesInStore(IntPtr storeProvider, IntPtr prevCertContext);

        [DllImport("crypt32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern bool CertVerifySubjectCertificateContext(
            IntPtr pSubject,
            IntPtr pIssuer,
            [In, Out] ref uint pdwFlags);


        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
        public struct CERT_NAME_INFO
        {
            public int cRDN;
            public IntPtr rgRDN; //PCERT_RDN
        }
        [StructLayout(LayoutKind.Sequential)]
        public struct CRL_CONTEXT
        {
            public uint dwCertEncodingType;
            IntPtr pbCrlEncoded;
            public uint cbCrlEncoded;
            public IntPtr pCrlInfo;
            public IntPtr hCertStore;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct _CRYPTOAPI_BLOB
        {
            public uint cbData;
            public IntPtr pbData;
        }
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
        public struct CERT_RDN
        {
            public int cRDNAttr;
            public IntPtr rgRDNAttr;
        }
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
        public struct CERT_RDN_ATTR
        {
            public IntPtr pszObjId;
            public int dwValueType;
            public int cbData;
            public IntPtr pbData;
        }
        [StructLayout(LayoutKind.Sequential)]
        public struct CRYPT_ALGORITHM_IDENTIFIER
        {
            [MarshalAs(UnmanagedType.LPStr)]
            public String pszObjID;
            public uint cbData;     //CRYPT_OBJID_BLOB Parameters blob
            public IntPtr pbData;   //CRYPT_OBJID_BLOB Parameters blob
        }
        [StructLayout(LayoutKind.Sequential)]
        public struct CRYPT_RC2_CBC_PARAMETERS
        {
            public int dwVersion;
            public bool fIV;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
            public byte[] rgbIV;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct CRYPT_BIT_BLOB
        {
            public uint cbData;
            public IntPtr pbData;
            public uint cUnusedBits;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct CERT_INFO
        {
            public uint dwVersion;
            public CRYPT_INTEGER_BLOB SerialNumber;
            public CRYPT_ALGORITHM_IDENTIFIER SignatureAlgorithm;
            public CERT_NAME_BLOB Issuer;
            public FILETIME NotBefore;
            public FILETIME NotAfter;
            public CERT_NAME_BLOB Subject;
            public CERT_PUBLIC_KEY_INFO SubjectPublicKeyInfo;
            public CRYPT_BIT_BLOB IssuerUniqueId;
            public CRYPT_BIT_BLOB SubjectUniqueId;
            public uint cExtension;
            IntPtr rgExtension;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct CERT_CONTEXT
        {
            public uint dwCertEncodingType;
            public IntPtr pbCertEncoded;
            public uint cbCertEncoded;
            public IntPtr pCertInfo;
            public IntPtr hCertStore;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct CRL_INFO
        {
            public uint dwVersion;
            public CRYPT_ALGORITHM_IDENTIFIER SignatureAlgorithm;
            public CERT_NAME_BLOB Issuer;
            public FILETIME ThisUpdate;
            public FILETIME NextUpdate;
            public uint cCRLEntry;
            public IntPtr rgCRLEntry;
            public uint cExtension;
            public IntPtr rgExtension;
        }
        [StructLayout(LayoutKind.Sequential)]
        public struct PUBKEYBLOBHEADERS
        {
            public byte bType;	//BLOBHEADER
            public byte bVersion;	//BLOBHEADER
            public short reserved;	//BLOBHEADER
            public uint aiKeyAlg;	//BLOBHEADER
            public uint magic;	//RSAPUBKEY
            public uint bitlen;	//RSAPUBKEY
            public uint pubexp;	//RSAPUBKEY
        }


        [StructLayout(LayoutKind.Sequential)]
        public struct CERT_PUBLIC_KEY_INFO
        {
            public IntPtr SubjPKIAlgpszObjId;
            public int SubjPKIAlgParameterscbData;
            public IntPtr SubjPKIAlgParameterspbData;
            public int PublicKeycbData;
            public IntPtr PublicKeypbData;
            public int PublicKeycUnusedBits;
        }

        public const uint PKCS_7_ASN_ENCODING = 0x00010000;
        public const uint X509_ASN_ENCODING = 0x00000001;
        public const uint PKCS_RC2_CBC_PARAMETERS = 41;
        public const uint X509_NAME = 7;
        public const uint CRYPT_OID_INFO_OID_KEY = 1;

        public const int CERT_RDN_PRINTABLE_STRING = 4;
        public const int CERT_RDN_TELETEX_STRING = 5;
        public const int CERT_RDN_T61_STRING = 5;
        public const int CERT_RDN_IA5_STRING = 7;
        public const int CERT_RDN_GENERAL_STRING = 10;
        public const int CERT_RDN_UNICODE_STRING = 12;

        public const int CMSG_TYPE_PARAM = 1;
        public const int CMSG_CONTENT_PARAM = 2;
        public const int CMSG_BARE_CONTENT_PARAM = 3;
        public const int CMSG_INNER_CONTENT_TYPE_PARAM = 4;
        public const int CMSG_SIGNER_COUNT_PARAM = 5;
        public const int CMSG_SIGNER_INFO_PARAM = 6;
        public const int CMSG_SIGNER_CERT_INFO_PARAM = 7;
        public const int CMSG_SIGNER_HASH_ALGORITHM_PARAM = 8;
        public const int CMSG_SIGNER_AUTH_ATTR_PARAM = 9;
        public const int CMSG_SIGNER_UNAUTH_ATTR_PARAM = 10;
        public const int CMSG_CERT_COUNT_PARAM = 11;
        public const int CMSG_CERT_PARAM = 12;
        public const int CMSG_CRL_COUNT_PARAM = 13;
        public const int CMSG_CRL_PARAM = 14;
        public const int CMSG_ENVELOPE_ALGORITHM_PARAM = 15;
        public const int CMSG_RECIPIENT_COUNT_PARAM = 17;
        public const int CMSG_RECIPIENT_INDEX_PARAM = 18;
        public const int CMSG_RECIPIENT_INFO_PARAM = 19;
        public const int CMSG_HASH_ALGORITHM_PARAM = 20;
        public const int CMSG_HASH_DATA_PARAM = 21;
        public const int CMSG_COMPUTED_HASH_PARAM = 22;
        public const int CMSG_ENCRYPT_PARAM = 26;
        public const int CMSG_ENCRYPTED_DIGEST = 27;
        public const int CMSG_ENCODED_SIGNER = 28;
        public const int CMSG_ENCODED_MESSAGE = 29;
        public const int CMSG_VERSION_PARAM = 30;
        public const int CMSG_ATTR_CERT_COUNT_PARAM = 31;
        public const int CMSG_ATTR_CERT_PARAM = 32;
        public const int CMSG_CMS_RECIPIENT_COUNT_PARAM = 33;
        public const int CMSG_CMS_RECIPIENT_INDEX_PARAM = 34;
        public const int CMSG_CMS_RECIPIENT_ENCRYPTED_KEY_INDEX_PARAM = 35;
        public const int CMSG_CMS_RECIPIENT_INFO_PARAM = 36;
        public const int CMSG_UNPROTECTED_ATTR_PARAM = 37;
        public const int CMSG_SIGNER_CERT_ID_PARAM = 38;
        public const int CMSG_CMS_SIGNER_INFO_PARAM = 39;

        public const uint CERT_CLOSE_STORE_FORCE_FLAG = 1;
        public const uint CERT_CLOSE_STORE_CHECK_FLAG = 2;

        public const uint CERT_STORE_SIGNATURE_FLAG = 0x00000001;
        public const uint CERT_STORE_TIME_VALIDITY_FLAG = 0x00000002;
        public const uint CERT_STORE_REVOCATION_FLAG = 0x00000004;
        public const uint CERT_STORE_NO_CRL_FLAG = 0x00010000;
        public const uint CERT_STORE_NO_ISSUER_FLAG = 0x00020000;

        public const uint CERT_STORE_BASE_CRL_FLAG = 0x00000100;
        public const uint CERT_STORE_DELTA_CRL_FLAG = 0x00000200;


        public const int CRYPT_RC2_40BIT_VERSION = 160;
        public const int CRYPT_RC2_56BIT_VERSION = 52;
        public const int CRYPT_RC2_64BIT_VERSION = 120;
        public const int CRYPT_RC2_128BIT_VERSION = 58;

        public const string szOID_RSA_RC2CBC = "1.2.840.113549.3.2";
        public const string szOID_RSA_RC4 = "1.2.840.113549.3.4";
        public const string szOID_RSA_DES_EDE3_CBC = "1.2.840.113549.3.7";
        public const string szOID_RSA_RC5_CBCPad = "1.2.840.113549.3.9";

    }

    public struct RECT
    {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }
    public struct POINT
    {
        public int x;
        public int y;
    }
    public struct SIZE
    {
        public int cx;
        public int cy;
    }
    public struct FILETIME
    {
        public int dwLowDateTime;
        public int dwHighDateTime;
    }
    public struct SYSTEMTIME
    {
        public short wYear;
        public short wMonth;
        public short wDayOfWeek;
        public short wDay;
        public short wHour;
        public short wMinute;
        public short wSecond;
        public short wMilliseconds;
    }



}