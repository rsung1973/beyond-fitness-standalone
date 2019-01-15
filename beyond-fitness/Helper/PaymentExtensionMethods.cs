using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Mvc;

using CommonLib.DataAccess;
using MessagingToolkit.QRCode.Codec;
using Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;

namespace WebHome.Helper
{
    public static class PaymentExtensionMethods
    {
        public static IQueryable<Payment> FilterByUserRoleScope<TEntity>(this IQueryable<Payment> items, ModelSource<TEntity> models, UserProfile profile)
            where TEntity : class, new()
        {
            if (profile.IsAssistant() || profile.IsOfficer())
            {
                return items;
            }
            else if (profile.IsManager() || profile.IsViceManager())
            {
                var payment = models.GetTable<BranchStore>().Where(b => b.ManagerID == profile.UID || b.ViceManagerID == profile.UID)
                    .SelectMany(b => b.PaymentTransaction)
                    .Select(p => p.Payment);

                return items
                        .Join(models.GetTable<PaymentTransaction>()
                            .Join(models.GetTable<BranchStore>().Where(b => b.ManagerID == profile.UID || b.ViceManagerID == profile.UID),
                                t => t.BranchID, b => b.BranchID, (t, b) => t),
                            p => p.PaymentID, t => t.PaymentID, (p, t) => p);
            }
            else
            {
                return items.Where(f => false);
            }
        }

        public static IQueryable<Payment> FilterByAccountingPayment<TEntity>(this IQueryable<Payment> items, ModelSource<TEntity> models)
                    where TEntity : class, new()
        {
            return items
                .Where(p => p.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                    || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                    || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額)
                .Where(p => p.VoidPayment == null || p.AllowanceID.HasValue);
        }

        public static IEnumerable<Payment> FilterByAccountingPayment(this IEnumerable<Payment> items)
        {
            return items
                .Where(p => p.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                    || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                    || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額)
                .Where(p => p.VoidPayment == null || p.AllowanceID.HasValue);
        }

    }
}