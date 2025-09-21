using System;
using System.Collections.Generic;
using System.Text;

namespace CommonLib.Utility
{
    public class CipherDecipherSrv
    {

        private int masqueradeLength;

        private int random(int rand)
        {
            if (rand < 1)
                return 0;

            Random random = new Random(DateTime.Now.Millisecond);
            return random.Next(rand);
        }


        public String cipher(string code)
        {
            return Convert.ToBase64String(cipherCode(Encoding.Default.GetBytes(code)));
        }


        public String decipher(string b64Code)
        {
            try
            {
                if (decipherCode(Convert.FromBase64String(b64Code)) != null)
                    return Encoding.Default.GetString(decipherCode(Convert.FromBase64String(b64Code)));
                else
                    return "";
            }
            catch (Exception ex)
            {
                return "";
            }
            finally
            {

            }
        }


        public byte[] cipherCode(byte[] code)
        {
            byte[] masquerade = masqueradeCode(code);
            if (masquerade == null)
                return null;

            if (masquerade.Length <= 0)
                return null;

            int ch, CypherCode, bufferChar;
            int len = masquerade.Length;
            byte[] buffer = new byte[len];
            CypherCode = (int)masquerade[len - 1];

            for (int i = 0; i < len - 1; i++)
            {
                bufferChar = (int)masquerade[i];
                bufferChar = bufferChar ^ i;
                ch = bufferChar & 0x000f;
                bufferChar = ((bufferChar >> 4) ^ ch) << 4;
                ch = (ch ^ CypherCode) & 0x000f;
                bufferChar |= ch;
                buffer[i] = (byte)bufferChar;
            }
            buffer[len - 1] = (byte)CypherCode;
            return buffer;
        }


        public byte[] decipherCode(byte[] cipher)
        {
            if (cipher == null)
                return null;
            int len = cipher.Length;
            int ch, CypherCode, bufferChar;
            byte[] s = new byte[len];
            CypherCode = cipher[len - 1];
            for (int i = 0; i < len - 1; i++)
            {
                bufferChar = (int)cipher[i] & 0x000000ff;
                ch = (bufferChar ^ CypherCode) & 0x0000000f;
                bufferChar = ((bufferChar >> 4) ^ ch) << 4;
                bufferChar |= ch;
                bufferChar ^= i;
                s[i] = (byte)bufferChar;
            }
            s[len - 1] = cipher[len - 1];
            return purifyCode(s);
        }

        private byte[] masqueradeCode(byte[] code)
        {
            int CipherCode;
            int nMasq, i, nMasqPos, value;
            int len = code.Length;

            nMasq = random(masqueradeLength);
            byte[] shape = new byte[nMasq + 2 + len];
            CipherCode = random(256);
            nMasqPos = 0;
            for (i = 0; i < nMasq; i++)
            {
                value = random(256);
                shape[nMasqPos] = (byte)value;
                nMasqPos++;
            }
            for (i = 0; i < len; i++)
            {
                shape[nMasqPos] = code[i];
                nMasqPos++;
            }
            shape[nMasqPos] = (byte)nMasq;
            nMasqPos++;
            shape[nMasqPos] = (byte)CipherCode;
            return shape;
        }

        private byte[] purifyCode(byte[] code)
        {
            if (code == null)
                return null;
            if (code.Length < 1)
                return null;

            int nTextLength, code_len, i;
            code_len = code.Length - 1;
            nTextLength = code_len - code[code_len - 1] - 1;

            if (nTextLength > 0)
            {
                byte[] text = new byte[nTextLength];
                for (i = 0; i < nTextLength; i++)
                    text[i] = code[code_len - nTextLength - 1 + i];
                return text;
            }
            else
                return null;


        }

        public CipherDecipherSrv(int length)
        {
            masqueradeLength = length;
            if (masqueradeLength < 0) masqueradeLength = 0;
        }
        public CipherDecipherSrv()
        {
            masqueradeLength = 0;
        }
    }

}
