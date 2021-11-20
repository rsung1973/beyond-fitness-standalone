using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

namespace Win32
{
    /// <summary>
    /// http://www.pinvoke.net/
    /// </summary>

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
    public struct PRINTER_INFO_2
    {
        [MarshalAs(UnmanagedType.LPTStr)]
        public string pServerName;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string pPrinterName;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string pShareName;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string pPortName;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string pDriverName;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string pComment;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string pLocation;
        public IntPtr pDevMode;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string pSepFile;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string pPrintProcessor;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string pDatatype;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string pParameters;
        public IntPtr pSecurityDescriptor;
        public uint Attributes;
        public uint Priority;
        public uint DefaultPriority;
        public uint StartTime;
        public uint UntilTime;
        public uint Status;
        public uint cJobs;
        public uint AveragePPM;
    }

    [FlagsAttribute]
    enum PrinterEnumFlags
    {
        PRINTER_ENUM_DEFAULT = 0x00000001,
        PRINTER_ENUM_LOCAL = 0x00000002,
        PRINTER_ENUM_CONNECTIONS = 0x00000004,
        PRINTER_ENUM_FAVORITE = 0x00000004,
        PRINTER_ENUM_NAME = 0x00000008,
        PRINTER_ENUM_REMOTE = 0x00000010,
        PRINTER_ENUM_SHARED = 0x00000020,
        PRINTER_ENUM_NETWORK = 0x00000040,
        PRINTER_ENUM_EXPAND = 0x00004000,
        PRINTER_ENUM_CONTAINER = 0x00008000,
        PRINTER_ENUM_ICONMASK = 0x00ff0000,
        PRINTER_ENUM_ICON1 = 0x00010000,
        PRINTER_ENUM_ICON2 = 0x00020000,
        PRINTER_ENUM_ICON3 = 0x00040000,
        PRINTER_ENUM_ICON4 = 0x00080000,
        PRINTER_ENUM_ICON5 = 0x00100000,
        PRINTER_ENUM_ICON6 = 0x00200000,
        PRINTER_ENUM_ICON7 = 0x00400000,
        PRINTER_ENUM_ICON8 = 0x00800000,
        PRINTER_ENUM_HIDE = 0x01000000
    }


    public abstract class Winspool
    {
        [DllImport("winspool.drv", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern bool SetDefaultPrinter(string Name);

        [DllImport("winspool.drv", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern bool EnumPrinters(PrinterEnumFlags Flags, string Name, uint Level, IntPtr pPrinterEnum, uint cbBuf, ref uint pcbNeeded, ref uint pcReturned);



    }
}
