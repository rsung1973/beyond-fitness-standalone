using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using CommonLib.Core.Helper;
using CommonLib.Helper;
using CommonLib.Utility;
using Microsoft.Extensions.Logging;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;


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
                checkC0401(models, Path.Combine(Startup.Properties["EINVTurnKeyPath"], "C0401", "BAK", DateTime.Today.ToString("yyyyMMdd")), Naming.GeneralStatus.Successful);
                checkC0401(models, Path.Combine(Startup.Properties["EINVTurnKeyPath"], "C0401", "BAK", DateTime.Today.AddDays(-1).ToString("yyyyMMdd")), Naming.GeneralStatus.Successful);
                checkC0401(models, Path.Combine(Startup.Properties["EINVTurnKeyPath"], "C0401", "ERR"), Naming.GeneralStatus.Failed);

                checkC0501(models, Path.Combine(Startup.Properties["EINVTurnKeyPath"], "C0501", "BAK", DateTime.Today.ToString("yyyyMMdd")), Naming.GeneralStatus.Successful);
                checkC0501(models, Path.Combine(Startup.Properties["EINVTurnKeyPath"], "C0501", "BAK", DateTime.Today.AddDays(-1).ToString("yyyyMMdd")), Naming.GeneralStatus.Successful);
                checkC0501(models, Path.Combine(Startup.Properties["EINVTurnKeyPath"], "C0501", "ERR"), Naming.GeneralStatus.Failed);

                checkD0401(models, Path.Combine(Startup.Properties["EINVTurnKeyPath"], "D0401", "BAK", DateTime.Today.ToString("yyyyMMdd")), Naming.GeneralStatus.Successful);
                checkD0401(models, Path.Combine(Startup.Properties["EINVTurnKeyPath"], "D0401", "BAK", DateTime.Today.AddDays(-1).ToString("yyyyMMdd")), Naming.GeneralStatus.Successful);
                checkD0401(models, Path.Combine(Startup.Properties["EINVTurnKeyPath"], "D0401", "ERR"), Naming.GeneralStatus.Failed);

            }
        }

        private void checkC0401(ModelSource<UserProfile> models,String storePath, Naming.GeneralStatus status)
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
            catch(Exception ex)
            {
                ApplicationLogging.CreateLogger<CheckInvoiceDispatch>()
                    .LogError(ex, ex.Message);
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
            catch(Exception ex)
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
}