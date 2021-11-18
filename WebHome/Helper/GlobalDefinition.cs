using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace WebHome.Helper
{
    public class GlobalDefinition
    {
        static GlobalDefinition()
        {
            ContractPdfPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "assets", "contract");
            if (!Directory.Exists(ContractPdfPath))
                Directory.CreateDirectory(ContractPdfPath);

            InvoicePdfPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "assets", "invoice");
            if (!Directory.Exists(InvoicePdfPath))
                Directory.CreateDirectory(InvoicePdfPath);

        }

        public static String ContractPdfPath { get; private set; }

        public static String InvoicePdfPath { get; private set; }

    }

    public enum CachingKey
    {
        UID = 10001,
        EditMemberUID = 10002,
        Training = 10003,
        TrainingExecution = 10004,
        DailyBookingQuery = 10005,
        MembersQuery = 10006
    }
}