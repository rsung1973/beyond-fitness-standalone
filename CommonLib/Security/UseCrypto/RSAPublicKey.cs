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


namespace CommonLib.Security.UseCrypto
{
	/// <summary>
	/// RSAPublicKey 的摘要描述。
	/// </summary>
	public class RSAPublicKey
	{
		const uint X509_ASN_ENCODING 		= 0x00000001;
		const uint PKCS_7_ASN_ENCODING 	= 0x00010000;

		const uint RSA_CSP_PUBLICKEYBLOB	= 19;
		const uint X509_PUBLIC_KEY_INFO	= 8;

		const int  AT_KEYEXCHANGE		= 1;  //keyspec values
		const int  AT_SIGNATURE		= 2;
		static uint ENCODING_TYPE 		= PKCS_7_ASN_ENCODING | X509_ASN_ENCODING ;

		const byte PUBLICKEYBLOB	= 	0x06;
		const byte CUR_BLOB_VERSION	= 	0x02;
		const ushort reserved 		= 	0x0000;
		const uint CALG_RSA_KEYX 	= 	0x0000a400;
		const uint CALG_RSA_SIGN 	= 	0x00002400;

		public byte[] _keyBlob;
		public byte[] keyModulus;	// big-Endian 
		public byte[] keyExponent;	// big-Endian
		public byte[] publicKeyBlob;	//Microsoft PUBLICKEYBLOB format
		public uint keySize;		//modulus size in bits


		public Win32.Win32.PUBKEYBLOBHEADERS pkheaders;

		public RSAPublicKey(byte[] rsaKey)
		{
			//
			// TODO: 在此加入建構函式的程式碼
			//
			_keyBlob = rsaKey;
			initialize();
		}

		private void initialize()
		{
			if(!decodeRSAPublicKey(_keyBlob))
				throw new Exception("Invalidate Public Key !");
		}

		private bool decodeRSAPublicKey(byte[] encodedpubkey)
		{
			byte[] publickeyblob ;

			uint blobbytes=0;
			if(Win32.Win32.CryptDecodeObject(ENCODING_TYPE, RSA_CSP_PUBLICKEYBLOB, encodedpubkey, (uint)encodedpubkey.Length, 0, null, ref blobbytes))
			{
				publickeyblob = new byte[blobbytes];
				Win32.Win32.CryptDecodeObject(ENCODING_TYPE, RSA_CSP_PUBLICKEYBLOB, encodedpubkey, (uint)encodedpubkey.Length, 0, publickeyblob, ref blobbytes);
			}
			else
			{
				return false;
			}
			this.publicKeyBlob = publickeyblob;
			return decodeMSPublicKeyBlob(publickeyblob);
		}

		//-----  Microsoft PUBLICKEYBLOB format  ----
		private bool decodeMSPublicKeyBlob(byte[] publickeyblob)
		{
            pkheaders = new Win32.Win32.PUBKEYBLOBHEADERS();
			int headerslength = Marshal.SizeOf(pkheaders);
			IntPtr buffer = Marshal.AllocHGlobal( headerslength);
			Marshal.Copy( publickeyblob, 0, buffer, headerslength );
            pkheaders = (Win32.Win32.PUBKEYBLOBHEADERS)Marshal.PtrToStructure(buffer, typeof(Win32.Win32.PUBKEYBLOBHEADERS));
			Marshal.FreeHGlobal( buffer );

			//-----  basic sanity check of PUBLICKEYBLOB fields ------------
			if(pkheaders.bType 	!= PUBLICKEYBLOB)
				return false;
			if(pkheaders.bVersion 	!= CUR_BLOB_VERSION)
				return false;
			if(pkheaders.aiKeyAlg 	!= CALG_RSA_KEYX &&  pkheaders.aiKeyAlg != CALG_RSA_SIGN)
				return false;

			//-----  Get public key size in bits -------------
			this.keySize = pkheaders.bitlen;

			//-----  Get public exponent -------------
			byte[] exponent = BitConverter.GetBytes(pkheaders.pubexp); //little-endian ordered
			Array.Reverse(exponent);    //convert to big-endian order
			this.keyExponent = exponent;

			//-----  Get modulus  -------------
			int modulusbytes = (int)pkheaders.bitlen/8 ;
			byte[] modulus = new byte[modulusbytes];
			try
			{
				Array.Copy(publickeyblob, headerslength, modulus, 0, modulusbytes);
				Array.Reverse(modulus);   //convert from little to big-endian ordering.
				this.keyModulus = modulus;
			}
			catch(Exception)
			{
				Console.WriteLine("Problem getting modulus from publickeyblob");
				return false;
			}
			return true;
		}



	}
}
