using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using CommonLib.Core.Helper;
using CommonLib.Core.Utility;
using CommonLib.Helper;
using CommonLib.Utility;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Properties;


namespace WebHome.Helper.Jobs
{
    public class CheckInvoiceDispatch : IJob
    {
        public void Dispose()
        {

        }

        public void DoJob()
        {
            using (ModelSource<UserProfile> models = new ModelSource<UserProfile>())
            {
                CheckTurnkeyLog(models);
                checkC0401(models, Path.Combine(WebApp.Properties["EINVTurnKeyPath"], "C0401", "BAK", DateTime.Today.ToString("yyyyMMdd")), Naming.GeneralStatus.Successful);
                checkC0401(models, Path.Combine(WebApp.Properties["EINVTurnKeyPath"], "C0401", "BAK", DateTime.Today.AddDays(-1).ToString("yyyyMMdd")), Naming.GeneralStatus.Successful);
                checkC0401(models, Path.Combine(WebApp.Properties["EINVTurnKeyPath"], "C0401", "ERR"), Naming.GeneralStatus.Failed);

                checkC0501(models, Path.Combine(WebApp.Properties["EINVTurnKeyPath"], "C0501", "BAK", DateTime.Today.ToString("yyyyMMdd")), Naming.GeneralStatus.Successful);
                checkC0501(models, Path.Combine(WebApp.Properties["EINVTurnKeyPath"], "C0501", "BAK", DateTime.Today.AddDays(-1).ToString("yyyyMMdd")), Naming.GeneralStatus.Successful);
                checkC0501(models, Path.Combine(WebApp.Properties["EINVTurnKeyPath"], "C0501", "ERR"), Naming.GeneralStatus.Failed);

                checkD0401(models, Path.Combine(WebApp.Properties["EINVTurnKeyPath"], "D0401", "BAK", DateTime.Today.ToString("yyyyMMdd")), Naming.GeneralStatus.Successful);
                checkD0401(models, Path.Combine(WebApp.Properties["EINVTurnKeyPath"], "D0401", "BAK", DateTime.Today.AddDays(-1).ToString("yyyyMMdd")), Naming.GeneralStatus.Successful);
                checkD0401(models, Path.Combine(WebApp.Properties["EINVTurnKeyPath"], "D0401", "ERR"), Naming.GeneralStatus.Failed);

            }
        }

        private void checkC0401(ModelSource<UserProfile> models, String storePath, Naming.GeneralStatus status)
        {
            try
            {
                if (!Directory.Exists(storePath))
                {
                    return;
                }

                var items = models.GetTable<InvoiceItem>();
                String archieve = storePath + ".zip";
                foreach (var f in Directory.EnumerateFiles(storePath, "*.xml", SearchOption.AllDirectories))
                {
                    String fileName = Path.GetFileNameWithoutExtension(f);
                    if (Regex.IsMatch(fileName, "[A-Za-z]{2}[0-9]{8}"))
                    {
                        String trackCode = fileName.Substring(0, 2).ToUpper();
                        String no = fileName.Substring(2);
                        var item = items.Where(c => c.TrackCode == trackCode
                            && c.No == no).FirstOrDefault();

                        if (item != null && item.InvoiceItemDispatchLog == null)
                        {
                            item.InvoiceItemDispatchLog = new InvoiceItemDispatchLog
                            {
                                DispatchDate = DateTime.Now,
                                Status = (int)status
                            };
                            models.SubmitChanges();
                        }

                        storeFile(archieve, f);

                    }
                }
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<CheckInvoiceDispatch>()
                    .LogError(ex, ex.Message);
            }
        }

        private TurnkeyLog[] GetInvoiceTurnkeyLog(string invoiceNo,String docType,out String result)
        {
            using (WebClient client = new WebClient())
            {
                client.Encoding = Encoding.UTF8;
                String url = $"{AppSettings.Default.TurnkeyCheckUrl}?InvoiceNo={invoiceNo}&DocType={docType}";
                result = client.DownloadString(url);
                if(result?.Length>0)
                {
                    FileLogger.Logger.Info(result);
                    return JsonConvert.DeserializeObject<TurnkeyLog[]>(result);
                }
            }
            return null;
        }

        private TurnkeyLog[] GetAllowanceTurnkeyLog(string allowanceNo, String docType,out String result)
        {
            using (WebClient client = new WebClient())
            {
                client.Encoding = Encoding.UTF8;
                String url = $"{AppSettings.Default.TurnkeyCheckUrl}?AllowanceNo={allowanceNo}&DocType={docType}";
                result = client.DownloadString(url);
                if (result?.Length > 0)
                {
                    return JsonConvert.DeserializeObject<TurnkeyLog[]>(result);
                }
            }
            return null;
        }

        private void CheckTurnkeyLog(ModelSource<UserProfile> models)
        {
            foreach (var f in Directory.EnumerateFiles(AppSettings.Default.TurnkeyCheckListPath, "*", SearchOption.AllDirectories))
            {
                try
                {
                    if (int.TryParse(Path.GetFileNameWithoutExtension(f), out int docID))
                    {
                        var docItem = models.GetTable<Document>().Where(d => d.DocID == docID).FirstOrDefault();
                        if (docItem != null)
                        {
                            TurnkeyLog[] logItems = null;
                            switch ((Naming.DocumentTypeDefinition)docItem.DocType)
                            {
                                case Naming.DocumentTypeDefinition.E_Invoice:
                                    var item = docItem.InvoiceItem;
                                    logItems = GetInvoiceTurnkeyLog($"{item?.TrackCode}{item?.No}", "C0401",out String result);
                                    if (logItems?.Length > 0)
                                    {
                                        if (item.InvoiceItemDispatchLog == null)
                                        {
                                            item.InvoiceItemDispatchLog = new InvoiceItemDispatchLog
                                            {
                                            };
                                        }
                                        item.InvoiceItemDispatchLog.DispatchDate = DateTime.Now;
                                        item.InvoiceItemDispatchLog.Status = logItems[0].STATUS == "C"
                                            ? (int)Naming.GeneralStatus.Successful
                                            : logItems[0].STATUS == "E"
                                                ? (int)Naming.GeneralStatus.Failed
                                                : null;

                                        models.SubmitChanges();
                                        if(item.InvoiceItemDispatchLog.Status.HasValue)
                                        {
                                            File.Delete(f);
                                        }
                                        else
                                        {
                                            File.WriteAllText(f, result);
                                        }
                                    }
                                    break;

                                case Naming.DocumentTypeDefinition.E_InvoiceCancellation:
                                    item = docItem.DerivedDocument?.TargetDocument?.InvoiceItem;
                                    logItems = GetInvoiceTurnkeyLog($"{item?.TrackCode}{item?.No}", "C0501",out result);
                                    if (logItems?.Length > 0)
                                    {
                                        if (item.InvoiceCancellation != null)
                                        {
                                            if (item.InvoiceCancellation.InvoiceCancellationDispatchLog == null)
                                            {
                                                item.InvoiceCancellation.InvoiceCancellationDispatchLog = new InvoiceCancellationDispatchLog
                                                {
                                                };
                                            }
                                            item.InvoiceCancellation.InvoiceCancellationDispatchLog.DispatchDate = DateTime.Now;
                                            item.InvoiceCancellation.InvoiceCancellationDispatchLog.Status = 
                                                logItems[0].STATUS == "C"
                                                    ? (int)Naming.GeneralStatus.Successful
                                                    : logItems[0].STATUS == "E"
                                                        ? (int)Naming.GeneralStatus.Failed
                                                        : null;
                                            models.SubmitChanges();

                                            if (item.InvoiceCancellation.InvoiceCancellationDispatchLog.Status.HasValue)
                                            {
                                                File.Delete(f);
                                            }
                                            else
                                            {
                                                File.WriteAllText (f, result);
                                            }
                                        }
                                    }
                                    break;

                                case Naming.DocumentTypeDefinition.E_Allowance:
                                    var allowance = docItem.InvoiceAllowance;
                                    logItems = GetAllowanceTurnkeyLog(allowance?.AllowanceNumber, "D0401",out result);
                                    if (logItems?.Length > 0)
                                    {
                                        if (allowance.InvoiceAllowanceDispatchLog == null)
                                        {
                                            allowance.InvoiceAllowanceDispatchLog = new InvoiceAllowanceDispatchLog
                                            {
                                            };
                                        }
                                        allowance.InvoiceAllowanceDispatchLog.DispatchDate = DateTime.Now;
                                        allowance.InvoiceAllowanceDispatchLog.Status =
                                                logItems[0].STATUS == "C"
                                                    ? (int)Naming.GeneralStatus.Successful
                                                    : logItems[0].STATUS == "E"
                                                        ? (int)Naming.GeneralStatus.Failed
                                                        : null;
                                        models.SubmitChanges();

                                        if(allowance.InvoiceAllowanceDispatchLog.Status.HasValue)
                                        {
                                            File.Delete(f);
                                        }
                                        else
                                        {
                                            File.WriteAllText(f, result);
                                        }
                                    }
                                    break;

                                case Naming.DocumentTypeDefinition.E_AllowanceCancellation:
                                    allowance = docItem.DerivedDocument?.TargetDocument?.InvoiceAllowance;
                                    logItems = GetAllowanceTurnkeyLog(allowance?.AllowanceNumber, "D0501", out result);
                                    if (logItems?.Length > 0)
                                    {
                                        if (allowance.InvoiceAllowanceCancellation != null)
                                        {

                                        }
                                        File.Delete(f);
                                    }
                                    break;
                            }
                        }
                    }
                    else
                    {
                        File.Delete(f);
                    }

                }
                catch (Exception ex)
                {
                    ApplicationLogging.CreateLogger<CheckInvoiceDispatch>()
                        .LogError(ex, ex.Message);
                }
            }
        }

        private void checkC0501(ModelSource<UserProfile> models, String storePath, Naming.GeneralStatus status)
        {
            try
            {
                if (!Directory.Exists(storePath))
                {
                    return;
                }

                var items = models.GetTable<InvoiceItem>();
                String archieve = storePath + ".zip";
                foreach (var f in Directory.EnumerateFiles(storePath, "*.xml", SearchOption.AllDirectories))
                {
                    String fileName = Path.GetFileNameWithoutExtension(f);
                    if (Regex.IsMatch(fileName, "[A-Za-z]{2}[0-9]{8}"))
                    {
                        String trackCode = fileName.Substring(0, 2).ToUpper();
                        String no = fileName.Substring(2);
                        var item = items.Where(c => c.TrackCode == trackCode
                            && c.No == no).FirstOrDefault();

                        if (item != null && item.InvoiceCancellation != null && item.InvoiceCancellation.InvoiceCancellationDispatchLog == null)
                        {
                            item.InvoiceCancellation.InvoiceCancellationDispatchLog = new InvoiceCancellationDispatchLog
                            {
                                DispatchDate = DateTime.Now,
                                Status = (int)status
                            };
                            models.SubmitChanges();
                        }

                        storeFile(archieve, f);

                    }
                }
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<CheckInvoiceDispatch>()
                    .LogError(ex, ex.Message);
            }
        }

        private void checkD0401(ModelSource<UserProfile> models, String storePath, Naming.GeneralStatus status)
        {
            try
            {
                if (!Directory.Exists(storePath))
                {
                    return;
                }

                var items = models.GetTable<InvoiceAllowance>();
                String archieve = storePath + ".zip";
                foreach (var f in Directory.EnumerateFiles(storePath, "*.xml", SearchOption.AllDirectories))
                {
                    String fileName = Path.GetFileNameWithoutExtension(f);

                    var item = items.Where(c => c.AllowanceNumber == fileName).FirstOrDefault();

                    if (item != null && item.InvoiceAllowanceDispatchLog == null)
                    {
                        item.InvoiceAllowanceDispatchLog = new InvoiceAllowanceDispatchLog
                        {
                            DispatchDate = DateTime.Now,
                            Status = (int)status
                        };
                        models.SubmitChanges();
                    }

                    storeFile(archieve, f);
                }
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<CheckInvoiceDispatch>()
                    .LogError(ex, ex.Message);
            }
        }


        private void storeFile(string archieve, string fileName)
        {
            using (var zipOut = File.Open(archieve, FileMode.OpenOrCreate, FileAccess.ReadWrite))
            {
                using (ZipArchive zip = new ZipArchive(zipOut, ZipArchiveMode.Update))
                {
                    ZipArchiveEntry entry = zip.CreateEntry(Path.GetFileName(fileName));
                    using (Stream outStream = entry.Open())
                    {
                        using (var inStream = File.Open(fileName, FileMode.Open))
                        {
                            inStream.CopyTo(outStream);
                        }
                    }
                }
            }

            File.Delete(fileName);

        }

        public DateTime GetScheduleToNextTurn(DateTime current)
        {
            return current.AddMinutes(30);
        }
    }

    public class TurnkeyLog
    {
        public string SEQNO { get; set; }
        public string SUBSEQNO { get; set; }
        public string STATUS { get; set; }
        public string DocType { get; set; }
        public string TrackCode { get; set; }
        public string No { get; set; }
        public string InvoiceNo { get; set; }
        public DateTime? InvoiceDate { get; set; }
        public string AllowanceNo { get; set; }
        public DateTime? AllowanceDate { get; set; }
        public DateTime? MESSAGE_DTS { get; set; }
    }

}