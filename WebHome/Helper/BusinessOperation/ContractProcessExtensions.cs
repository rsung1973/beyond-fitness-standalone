using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Web;
using Microsoft.AspNetCore.Mvc;

using CommonLib.DataAccess;
//using MessagingToolkit.QRCode.Codec;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

using WebHome.Helper.MessageOperation;
using System.Threading.Tasks;
using CommonLib.Core.Utility;
using System.Data.SqlClient;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Http;

namespace WebHome.Helper.BusinessOperation
{
    public static class ContractProcessExtensions
    {
        public static CourseContract InitiateCourseContract(this GenericManager<BFDataContext> models, CourseContractViewModel viewModel, UserProfile profile, LessonPriceType lessonPrice, int? installmentID = null, String paymentMethod = null)

        {
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            var contractType = models.GetTable<CourseContractType>()
                .Where(c => c.TypeID == (int)viewModel.ContractType).First();

            var price = models.GetTable<LessonPriceType>()
                .Where(p => p.PriceID == viewModel.PriceID).First();

            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item == null)
            {
                item = new CourseContract
                {
                    //AgentID = profile.UID,  //lessonPrice.BranchStore.ManagerID.Value,
                    CourseContractExtension = new CourseContractExtension
                    {
                        BranchID = lessonPrice.BranchStore.IsVirtualClassroom() ? profile.ServingCoach.PreferredBranchID().Value : lessonPrice.BranchID.Value,
                        Version = (int?)viewModel.Version,
                    }
                };
                models.GetTable<CourseContract>().InsertOnSubmit(item);
            }

            item.AgentID = profile.UID;
            if (profile.IsManager())
            {
                item.SupervisorID = profile.UID;
                item.Status = (int)Naming.CourseContractStatus.待簽名;  //  (int)checkInitialStatus(viewModel, profile);
            }
            else
            {
                item.SupervisorID = lessonPrice.BranchStore.IsVirtualClassroom() ? profile.ServingCoach.CurrentWorkBranch()?.ManagerID : lessonPrice.BranchStore?.ManagerID;
                item.Status = (int)Naming.CourseContractStatus.待審核;
            }

            item.CourseContractLevel.Add(new CourseContractLevel
            {
                LevelDate = DateTime.Now,
                ExecutorID = profile.UID,
                LevelID = item.Status
            });

            item.ContractType = (int)viewModel.ContractType.Value;
            item.ContractDate = DateTime.Now;
            item.Subject = viewModel.Subject;
            item.ValidFrom = DateTime.Today;
            item.Expiration = DateTime.Today.AddMonths(price.EffectiveMonths ?? 18);
            item.OwnerID = viewModel.OwnerID.Value;
            item.SequenceNo = 0;// viewModel.SequenceNo;
            item.Lessons = price.IsPackagePrice ? price.ExpandActualLessonCount(models) : viewModel.Lessons;
            item.PriceID = viewModel.PriceID.Value;
            item.Remark = viewModel.Remark;
            item.FitnessConsultant = viewModel.FitnessConsultant.Value;
            item.Renewal = viewModel.Renewal;
            item.CourseContractExtension.PaymentMethod = paymentMethod;
            item.CourseContractExtension.Version = (int?)viewModel.Version;
            item.CourseContractExtension.SignOnline = viewModel.SignOnline;
            item.CourseContractExtension.UnitPriceID = price.GetOriginalSeriesPrice(models)?.PriceID;

            if (viewModel.InstallmentPlan == true)
            {
                if (installmentID.HasValue)
                {
                    item.InstallmentID = installmentID.Value;
                }
                else
                {
                    if (item.ContractInstallment == null)
                    {
                        item.ContractInstallment = new ContractInstallment { };
                    }
                    item.ContractInstallment.Installments = viewModel.Installments.Value;
                }
            }
            else
            {
                models.DeleteAllOnSubmit<ContractInstallment>(t => t.InstallmentID == item.InstallmentID);
                item.InstallmentID = null;
            }

            //item.Status = viewModel.Status;
            if (viewModel.UID != null && viewModel.UID.Length > 0)
            {
                models.DeleteAllOnSubmit<CourseContractMember>(m => m.ContractID == item.ContractID);
                item.CourseContractMember.AddRange(viewModel.UID.Select(u => new CourseContractMember
                {
                    UID = u
                }));
            }
            models.SubmitChanges();

            int? CalcTotalPrice()
            {
                if (price.IsPackagePrice)
                {
                    return price.ListPrice;
                }
                else if (price.IsCombination)
                {
                    return item.CourseContractOrder.Sum(o => o.Lessons * o.LessonPriceType.ListPrice);
                }
                else
                {
                    return item.Lessons * item.LessonPriceType.ListPrice;
                }
            }

            item.TotalCost = CalcTotalPrice(); //price.IsPackagePrice ? price.ListPrice : item.Lessons * item.LessonPriceType.ListPrice;
            if (item.CourseContractType.GroupingLessonDiscount != null)
            {
                item.TotalCost = item.TotalCost * item.CourseContractType.GroupingLessonDiscount.GroupingMemberCount * item.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount / 100;
            }
            models.SubmitChanges();

            foreach (var uid in viewModel.UID)
            {
                models.ExecuteCommand("update UserProfileExtension set CurrentTrial = null where UID = {0}", uid);
            }

            item.MarkContractNo(models);

            return item;
        }

        public static CourseContract InitiateCourseContract2022(this GenericManager<BFDataContext> models, CourseContractViewModel viewModel, UserProfile profile, LessonPriceType lessonPrice, int? installmentID = null, String paymentMethod = null,bool draftOnly = false)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item == null)
            {
                item = new CourseContract
                {
                    //AgentID = profile.UID,  //lessonPrice.BranchStore.ManagerID.Value,
                    CourseContractExtension = new CourseContractExtension
                    {
                        //BranchID = lessonPrice.BranchStore?.IsVirtualClassroom() == true 
                        //    ? profile.ServingCoach.PreferredBranchID().Value 
                        //    : lessonPrice.BranchID ?? viewModel.BranchID.Value,
                        Version = (int?)viewModel.Version,
                    }
                };
                models.GetTable<CourseContract>().InsertOnSubmit(item);
            }
            else
            {
                models.ExecuteCommand("delete CourseContractOrder where ContractID = {0}", item.ContractID);
            }

            BranchStore branch = models.GetTable<BranchStore>().Where(b => b.BranchID == viewModel.BranchID).First();

            item.AgentID = profile.UID;
            if(draftOnly)
            {
                item.Status = (int)Naming.CourseContractStatus.草稿;
            }
            else
            {
                if (profile.IsManager())
                {
                    item.SupervisorID = profile.UID;
                    item.Status = (int)Naming.CourseContractStatus.待簽名;  //  (int)checkInitialStatus(viewModel, profile);
                }
                else
                {
                    item.SupervisorID = branch.IsVirtualClassroom() ? profile.ServingCoach.CurrentWorkBranch()?.ManagerID : branch.ManagerID;
                    item.Status = (int)Naming.CourseContractStatus.待審核;
                }

                if (viewModel.InstallmentPlan == true)
                {
                    if (installmentID.HasValue)
                    {
                        item.InstallmentID = installmentID.Value;
                    }
                    else
                    {
                        if (item.ContractInstallment == null)
                        {
                            item.ContractInstallment = new ContractInstallment { };
                        }
                        item.ContractInstallment.Installments = viewModel.Installments.Value;
                    }
                }
                else
                {
                    models.DeleteAllOnSubmit<ContractInstallment>(t => t.InstallmentID == item.InstallmentID);
                    item.InstallmentID = null;
                }
            }

            item.CourseContractLevel.Add(new CourseContractLevel
            {
                LevelDate = DateTime.Now,
                ExecutorID = profile.UID,
                LevelID = item.Status
            });

            item.ContractType = viewModel.ContractType == CourseContractType.ContractTypeDefinition.CGA_Aux
                        ? (int)viewModel.ContractTypeAux.Value
                        : viewModel.ContractType == CourseContractType.ContractTypeDefinition.CVA_Aux
                            ? (int)viewModel.ContractTypeAux.Value + CourseContractType.OffsetFromCGA2CVA
                            : (int)viewModel.ContractType.Value;

            if(branch.IsVirtualClassOccurrence(models))
            {
                item.CourseContractExtension.BranchID = branch.IsVirtualClassroom()
                    ? profile.ServingCoach.PreferredBranchID().Value
                    : branch.BranchID;
            }
            else
            {
                item.CourseContractExtension.BranchID = branch.BranchID;
            }
            item.CourseContractExtension.CoursePlace = branch.BranchID;
            item.ContractDate = DateTime.Now;
            item.OwnerID = viewModel.OwnerID.Value;
            item.Subject = viewModel.Subject;
            item.ValidFrom = DateTime.Today;
            item.Expiration = DateTime.Today.AddMonths(lessonPrice.EffectiveMonths ?? 18);
            item.SequenceNo = 0;// viewModel.SequenceNo;
            //item.Lessons = lessonPrice.IsPackagePrice
            //    ? lessonPrice.ExpandActualLessonCount(models)
            //    : lessonPrice.IsCombination
            //        ? totalLessons
            //        : viewModel.Lessons;
            item.PriceID = lessonPrice.PriceID;
            item.Remark = viewModel.Remark;
            item.FitnessConsultant = viewModel.FitnessConsultant.Value;
            item.Renewal = viewModel.Renewal;
            item.CourseContractExtension.BRByCoach = null;
            item.CourseContractExtension.BRByLearner = null;
            if (item.Renewal == false)
            {
                if (viewModel.CheckBRCoach == true)
                {
                    item.CourseContractExtension.BRByCoach = viewModel.BRCoach;
                }
                if (viewModel.CheckBRLearner == true)
                {
                    item.CourseContractExtension.BRByLearner = viewModel.BRLearner;
                }
            }
            item.CourseContractExtension.PaymentMethod = paymentMethod;
            item.CourseContractExtension.Version = (int?)viewModel.Version;
            item.CourseContractExtension.SignOnline = viewModel.SignOnline;
            item.CourseContractExtension.UnitPriceID = lessonPrice.GetOriginalSeriesPrice(models)?.PriceID;
            item.CourseContractExtension.UnitPriceAdjustmentType = (int?)viewModel.PriceAdjustment;


            //item.Status = viewModel.Status;
            if (viewModel.UID != null && viewModel.UID.Length > 0)
            {
                models.DeleteAllOnSubmit<CourseContractMember>(m => m.ContractID == item.ContractID);
                item.CourseContractMember.AddRange(viewModel.UID.Select(u => new CourseContractMember
                {
                    UID = u
                }));
            }

            models.SubmitChanges();

            void CalcTotalPrice()
            {
                if (lessonPrice.IsCombination)
                {
                    List<LessonPriceType> combinationPrice = models.EvaluateCustomCombinationTotalCost(viewModel, null, out int totalLessons, out int totalCost);
                    item.Lessons = totalLessons;
                    item.TotalCost = totalCost;

                    item.Expiration = combinationPrice.Any()
                        ? DateTime.Today.AddMonths(combinationPrice[0].EffectiveMonths ?? 18)
                        : null;

                    for (int i = 0; i < combinationPrice.Count; i++)
                    {
                        var p = combinationPrice[i];
                        if (p != null && viewModel.OrderLessons[i] > 0)
                        {
                            item.CourseContractOrder.Add(new CourseContractOrder
                            {
                                LessonPriceType = p,
                                Lessons = viewModel.OrderLessons[i].Value,
                                SeqNo = item.CourseContractOrder.Count,
                            });
                        }
                    }
                }
                else
                {
                    if (lessonPrice.IsPackagePrice)
                    {
                        item.Lessons = lessonPrice.ExpandActualLessonCount(models);
                        item.TotalCost = lessonPrice.ListPrice;
                    }
                    else
                    {
                        item.Lessons = viewModel.Lessons;
                        item.TotalCost = item.Lessons * item.LessonPriceType.ListPrice;
                    }

                    if (item.CourseContractType.GroupingLessonDiscount != null)
                    {
                        item.TotalCost = item.TotalCost * item.CourseContractType.GroupingLessonDiscount.GroupingMemberCount * item.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount / 100;
                    }

                }
            }

            CalcTotalPrice(); //price.IsPackagePrice ? price.ListPrice : item.Lessons * item.LessonPriceType.ListPrice;

            models.SubmitChanges();

            if(!draftOnly)
            {
                foreach (var uid in viewModel.UID)
                {
                    models.ExecuteCommand("update UserProfileExtension set CurrentTrial = null where UID = {0}", uid);
                }

                item.MarkContractNo(models);
            }

            return item;
        }

        public static void ValidateContractApplication(this CourseContractViewModel viewModel, SampleController<UserProfile> controller, out LessonPriceType lessonPrice,bool draftOnly = false)
                
        {
            var ModelState = controller.ModelState;
            var models = controller.DataSource;

            lessonPrice = null;
            if (!viewModel.ContractType.HasValue)
            {
                ModelState.AddModelError("ContractType", "請選擇合約類型");
            }
            else if (viewModel.ContractType == CourseContractType.ContractTypeDefinition.CGA_Aux
                    || viewModel.ContractType == CourseContractType.ContractTypeDefinition.CVA_Aux)
            {
                if ( !viewModel.ContractTypeAux.HasValue)
                {
                    ModelState.AddModelError("ContractTypeAux", "請選擇人數");
                }
            }

            lessonPrice = viewModel.ValidateTotalCost(controller);

            if (!viewModel.BranchID.HasValue)
            {
                ModelState.AddModelError("BranchID", "請選擇上課場所");
            }

            if (viewModel.SignOnline == true)
            {
                var extension = models.GetTable<UserProfileExtension>()
                    .Where(u => u.UID == viewModel.OwnerID).FirstOrDefault();
                if (extension != null && extension.LineID == null)
                {
                    ModelState.AddModelError("SignOnline", "主簽約人無綁定Line，無法使用學生線上簽名");
                }
            }

            if (!draftOnly)
            {
                //請選擇上課時間長度
                if (!viewModel.Renewal.HasValue)
                {
                    ModelState.AddModelError("Renewal", "請選擇是否為VIP續約");
                }
                else if (viewModel.Renewal == false)
                {
                    if (viewModel.CheckBRCoach == true)
                    {
                        if (!viewModel.BRCoach.HasValue)
                        {
                            ModelState.AddModelError("CheckBRCoach", "請選擇BR教練");
                        }
                    }

                    if (viewModel.CheckBRLearner == true)
                    {
                        if (!viewModel.BRLearner.HasValue)
                        {
                            ModelState.AddModelError("CheckBRLearner", "請選擇BR學員");
                        }
                    }
                }

                if (viewModel.InstallmentPlan == true)
                {
                    if (!viewModel.Installments.HasValue)
                    {
                        ModelState.AddModelError("Installments", "請選擇分期");
                    }
                }
            }

            if (!viewModel.OwnerID.HasValue)
            {
                ModelState.AddModelError("OwnerID", "請設定主簽約人");
            }
            else if (viewModel.UID == null || viewModel.UID.Length < 1)
            {
                ModelState.AddModelError("OwnerID", "請新增合約學生");
            }
            //else if (viewModel.ContractType == CourseContractType.ContractTypeDefinition.CFA)
            //{

            //}
            else if (viewModel.ContractType == CourseContractType.ContractTypeDefinition.CGA_Aux
                    || viewModel.ContractType == CourseContractType.ContractTypeDefinition.CVA_Aux)
            {
                if (viewModel.ContractTypeAux == CourseContractType.ContractTypeDefinition.CGF)
                {

                }
                else
                {
                    var contractType = models.GetTable<CourseContractType>().Where(t => t.TypeID == (int?)viewModel.ContractTypeAux)
                                        .FirstOrDefault();

                    if (contractType?.GroupingMemberCount != viewModel.UID.Length)
                    {
                        ModelState.AddModelError("OwnerID", "請再次確認一次合約人數與合約類型是否相符");
                    }
                }
            }
            else
            {
                var contractType = models.GetTable<CourseContractType>().Where(t => t.TypeID == (int?)viewModel.ContractType)
                                    .FirstOrDefault();

                if (contractType?.GroupingMemberCount != viewModel.UID.Length)
                {
                    ModelState.AddModelError("OwnerID", "請再次確認一次合約人數與合約類型是否相符");
                }
            }


            if (!viewModel.FitnessConsultant.HasValue)
            {
                ModelState.AddModelError("FitnessConsultant", "請選擇合約負責體能顧問");
            }
            else
            {
                if (!models.GetTable<ServingCoach>().Any(s => s.CoachID == viewModel.FitnessConsultant
                     && s.UserProfile.UserProfileExtension.Signature != null))
                {
                    ModelState.AddModelError("FitnessConsultant", "請建立自己的簽名檔");
                }
            }

        }

        public static async Task<CourseContract> SaveCourseContractAsync(this CourseContractViewModel viewModel, SampleController<UserProfile> controller, bool checkPayment = false)

        {
            var Request = controller.Request;
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();
            profile = profile.LoadInstance(models);

            viewModel.ValidateContractApplication(controller, out LessonPriceType lessonPrice);

            if (lessonPrice != null)
            {
                if (lessonPrice.BranchStore.IsVirtualClassroom())
                {
                    if (profile.ServingCoach?.PreferredBranchID().HasValue == false)
                    {
                        ModelState.AddModelError("BranchID", "無法確定簽約分店!!");
                    }
                    else if (!CourseContractType.IsSuitableForVirtaulClass(viewModel.ContractType))
                    {
                        ModelState.AddModelError("ContractType", "遠距只能是1對1體能顧問課程!!");
                    }
                }
                else if (!lessonPrice.BranchStore.ManagerID.HasValue)
                {
                    ModelState.AddModelError("BranchID", "該分店未指定店長!!");
                }
            }

            if (viewModel.InstallmentPlan == true)
            {
                if (!viewModel.Installments.HasValue)
                {
                    ModelState.AddModelError("Installments", "請選擇分期轉開次數");
                }
            }


            String paymentMethod = null;
            if (checkPayment)
            {
                if (viewModel.PaymentMethod != null)
                {
                    paymentMethod = String.Join("/", viewModel.PaymentMethod.Where(p => p != null && p.Length > 0)).GetEfficientString();
                }

                if (paymentMethod == null)
                {
                    ModelState.AddModelError("PaymentMethod", "請選擇支付方式");
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return null;
            }

            String storedPath = null;
            if (Request.Form.Files.Count > 0)
            {
                storedPath = Path.Combine(FileLogger.Logger.LogDailyPath, Guid.NewGuid().ToString() + Path.GetExtension(Request.Form.Files[0].FileName));
                Request.Form.Files[0].SaveAs(storedPath);
            }

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item == null)
            {
                item = new CourseContract
                {
                    Status = (int)Naming.CourseContractStatus.草稿,
                    AgentID = profile.UID, //lessonPrice.BranchStore.ManagerID.Value,
                    CourseContractExtension = new CourseContractExtension
                    {
                        BranchID = lessonPrice.BranchStore.IsVirtualClassroom() ? profile.ServingCoach.PreferredBranchID().Value : lessonPrice.BranchID.Value,
                        Version = (int?)viewModel.Version,
                    },
                    SupervisorID = lessonPrice.BranchStore.IsVirtualClassroom() ? profile.ServingCoach.CurrentWorkBranch()?.ManagerID : lessonPrice.BranchStore?.ManagerID,
                };

                item.ExecuteContractStatus(profile, Naming.CourseContractStatus.草稿, null);
                models.GetTable<CourseContract>().InsertOnSubmit(item);
            }
            else
            {
                if (item.Status != (int)Naming.CourseContractStatus.草稿)
                {
                    ModelState.AddModelError("Message", "合約狀態錯誤，請重新檢查!!");
                    return null;
                }
            }

            item.ContractType = (int)viewModel.ContractType.Value;
            item.ContractDate = DateTime.Now;
            item.Subject = viewModel.Subject;
            item.ValidFrom = DateTime.Today;
            //item.Expiration = viewModel.Expiration;
            item.OwnerID = viewModel.OwnerID.Value;
            item.SequenceNo = 0;// viewModel.SequenceNo;
            item.Lessons = viewModel.Lessons;
            item.PriceID = viewModel.PriceID.Value;
            item.Remark = viewModel.Remark;
            item.FitnessConsultant = viewModel.FitnessConsultant.Value;
            item.Renewal = viewModel.Renewal;
            item.CourseContractExtension.SignOnline = viewModel.SignOnline;
            item.CourseContractExtension.PaymentMethod = paymentMethod;
            item.CourseContractExtension.Version = (int?)viewModel.Version;
            if (storedPath != null)
            {
                item.CourseContractExtension.Attachment = new Attachment
                {
                    StoredPath = storedPath,
                };
            }

            if (viewModel.InstallmentPlan == true)
            {
                if (item.ContractInstallment == null)
                    item.ContractInstallment = new ContractInstallment { };
                item.ContractInstallment.Installments = viewModel.Installments.Value;
            }
            else
            {
                models.DeleteAllOnSubmit<ContractInstallment>(t => t.InstallmentID == item.InstallmentID);
            }
            //item.Status = viewModel.Status;
            if (viewModel.UID != null && viewModel.UID.Length > 0)
            {
                models.DeleteAllOnSubmit<CourseContractMember>(m => m.ContractID == item.ContractID);
                item.CourseContractMember.AddRange(viewModel.UID.Select(u => new CourseContractMember
                {
                    UID = u
                }));
            }
            models.SubmitChanges();

            int? CalcTotalPrice()
            {
                if (lessonPrice.IsPackagePrice)
                {
                        return lessonPrice.ListPrice;
                }
                else if (lessonPrice.IsCombination)
                {
                    return item.CourseContractOrder.Sum(o => o.Lessons * o.LessonPriceType.ListPrice);
                }
                else
                {
                    return item.Lessons * item.LessonPriceType.ListPrice;
                }
            }


            item.TotalCost = CalcTotalPrice();  //lessonPrice.IsPackagePrice ? lessonPrice.ListPrice : item.Lessons * item.LessonPriceType.ListPrice;
            if (item.CourseContractType.GroupingLessonDiscount != null)
            {
                item.TotalCost = item.TotalCost * item.CourseContractType.GroupingLessonDiscount.GroupingMemberCount * item.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount / 100;
            }
            models.SubmitChanges();

            return item;
        }

        public static async Task<CourseContract> CommitCourseContractAsync(this CourseContractViewModel viewModel, SampleController<UserProfile> controller, bool checkPayment = false)
                
        {
            var Request = controller.Request;
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);

            viewModel.ValidateContractApplication(controller, out LessonPriceType lessonPrice);
            if (!(viewModel.ContractType == CourseContractType.ContractTypeDefinition.CGA || viewModel.ContractType == CourseContractType.ContractTypeDefinition.CNA))
            {
                if (!viewModel.Lessons.HasValue || viewModel.Lessons < 1)
                {
                    ModelState.AddModelError("Lessons", "請輸入購買堂數");
                }
            }

            if (lessonPrice != null)
            {
                if(lessonPrice.BranchStore.IsVirtualClassroom())
                {
                    if (profile.ServingCoach?.PreferredBranchID().HasValue == false)
                    {
                        ModelState.AddModelError("BranchID", "無法確定簽約分店!!");
                    }
                    else if (!CourseContractType.IsSuitableForVirtaulClass(viewModel.ContractType))
                    {
                        ModelState.AddModelError("ContractType", "遠距只能是1對1體能顧問課程!!");
                    }
                }
                else if (!lessonPrice.BranchStore.ManagerID.HasValue)
                {
                    ModelState.AddModelError("BranchID", "該分店未指定店長!!");
                }
            }

            String paymentMethod = null;
            if (checkPayment)
            {
                if (viewModel.PaymentMethod != null)
                {
                    paymentMethod = String.Join("/", viewModel.PaymentMethod.Where(p => p != null && p.Length > 0)).GetEfficientString();
                }

                if (paymentMethod == null)
                {
                    ModelState.AddModelError("PaymentMethod", "請選擇支付方式");
                }
            }


            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return null;
            }

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            CourseContract item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                if (item.Status != (int)Naming.CourseContractStatus.草稿)
                {
                    ModelState.AddModelError("Message", "合約狀態錯誤，請重新檢查!!");
                    return null;
                }
            }

            String storedPath = null;
            if (Request.Form.Files.Count > 0)
            {
                storedPath = Path.Combine(FileLogger.Logger.LogDailyPath, Guid.NewGuid().ToString() + Path.GetExtension(Request.Form.Files[0].FileName));
                Request.Form.Files[0].SaveAs(storedPath);
            }

            item = models.InitiateCourseContract(viewModel, profile, lessonPrice, paymentMethod: paymentMethod);
            DateTime payoffDue = item.ContractDate.Value.AddMonths(1).FirstDayOfMonth();
            item.PayoffDue = payoffDue.AddDays(-1);
            if (storedPath != null)
            {
                item.CourseContractExtension.Attachment = new Attachment
                {
                    StoredPath = storedPath,
                };
            }
            models.SubmitChanges();

            if (item.InstallmentID.HasValue)
            {
                int totalLessons = item.Lessons.Value;
                int installment = totalLessons / item.ContractInstallment.Installments;
                //if(item.Remark!=null)
                //{
                //    var idx = item.Remark.IndexOf("本合約分期轉開次數");
                //    if (idx >= 0)
                //    {
                //        item.Remark = item.Remark.Substring(0, idx);
                //    }
                //}

                //viewModel.Remark = item.Remark = $"{item.Remark}本合約分期轉開次數{item.ContractInstallment.Installments}次。";
                item.Lessons = installment + (totalLessons % item.ContractInstallment.Installments);
                item.TotalCost = item.TotalCost * item.Lessons / totalLessons;
                //item.Remark = $"{item.Remark}帳款應付期限{payoffDue:yyyy/MM/dd}。";
                models.SubmitChanges();

                totalLessons -= item.Lessons.Value;
                payoffDue = payoffDue.AddMonths(1);
                viewModel.ContractID = null;
                viewModel.KeyID = null;
                while (totalLessons > 0)
                {
                    viewModel.Lessons = Math.Min(installment, totalLessons);
                    var c = models.InitiateCourseContract(viewModel, profile, lessonPrice, item.InstallmentID, paymentMethod);
                    c.PayoffDue = payoffDue.AddDays(-1);
                    c.Installment = true;
                    //c.Remark = $"{c.Remark}帳款應付期限{payoffDue:yyyy/MM/dd}。";
                    if (storedPath != null)
                    {
                        c.CourseContractExtension.Attachment = new Attachment
                        {
                            StoredPath = storedPath,
                        };
                    }
                    models.SubmitChanges();

                    payoffDue = payoffDue.AddMonths(1);
                    totalLessons -= installment;
                }
            }

            if (item.Status == (int)Naming.CourseContractStatus.待審核)
            {
                if (item.CourseContractExtension.BranchStore.ManagerID.HasValue)
                {
                    var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyManagerToApproveContract.cshtml", item);
                    jsonData.PushLineMessage();
                }
                if (profile.UID != item.CourseContractExtension.BranchStore.ViceManagerID
                    && item.CourseContractExtension.BranchStore.ViceManagerID.HasValue)
                {
                    var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyViceManagerToApproveContract.cshtml", item);
                    jsonData.PushLineMessage();
                }
            }
            else if (item.Status == (int)Naming.CourseContractStatus.待簽名)
            {
                if (item.CourseContractExtension.SignOnline == true)
                {
                    //item.CreateLineReadyToSignContract(models).PushLineMessage();
                    var jsonData = await controller .RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyLearnerToSignContract.cshtml", item);
                    jsonData.PushLineMessage();
                }
                else if (!profile.IsManager())
                {
                    var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyCoachToSignContract.cshtml", item);
                    jsonData.PushLineMessage();
                }
            }

            return item;
        }

        private static void UpdateCustomCombinationTotalCost(this CourseContract contract, CourseContractViewModel viewModel)
        {
            int totalLessons = 0;
            int totalCost = 0;
            CourseContractType typeItem = contract.CourseContractType;

            for (int i = 0; i < viewModel.OrderPriceID.Length; i++)
            {
                CourseContractOrder order = contract.CourseContractOrder.Where(c => c.PriceID == viewModel.OrderPriceID[i]).FirstOrDefault();
                if (order == null)
                    continue;

                if (viewModel.OrderLessons[i] > 0)
                {
                    order.Lessons = viewModel.OrderLessons[i].Value;

                    LessonPriceType item = order.LessonPriceType;
                    int lessons = ((item.BundleCount ?? 1) * viewModel.OrderLessons[i].Value);
                    int cost = (item.ListPrice ?? 0) * lessons;
                    totalLessons += lessons;

                    if (item.LessonPriceProperty.Any(p => p.PropertyID == (int)Naming.LessonPriceFeature.一對一課程))
                    {
                        totalCost += cost;
                    }
                    else
                    {
                        totalCost += cost * (typeItem.GroupingMemberCount ?? 1) * (typeItem.GroupingLessonDiscount.PercentageOfDiscount ?? 100) / 100;
                    }
                }
                else
                {
                    order.Lessons = 0;
                }
            }
            contract.Lessons = totalLessons;
            contract.TotalCost = totalCost;
        }

        public static async Task<CourseContract> CommitCourseContract2022Async(this CourseContractViewModel viewModel, SampleController<UserProfile> controller, bool checkPayment = false,bool draftOnly = false)
        {
            var Request = controller.Request;
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);

            viewModel.ValidateContractApplication(controller, out LessonPriceType lessonPrice, draftOnly);

            //if (lessonPrice != null)
            //{
            //    if (lessonPrice.BranchStore?.IsVirtualClassroom() == true)
            //    {
            //        if (profile.ServingCoach?.PreferredBranchID().HasValue == false)
            //        {
            //            ModelState.AddModelError("BranchID", "無法確定簽約分店!!");
            //        }
            //        else if (!CourseContractType.IsSuitableForVirtaulClass(viewModel.ContractType))
            //        {
            //            ModelState.AddModelError("ContractType", "遠距只能是1對1體能顧問課程!!");
            //        }
            //    }
            //    else if (lessonPrice.BranchID.HasValue && !lessonPrice.BranchStore.ManagerID.HasValue)
            //    {
            //        ModelState.AddModelError("BranchID", "該分店未指定店長!!");
            //    }
            //}

            String paymentMethod = null;
            if (checkPayment)
            {
                if (viewModel.PaymentMethod != null)
                {
                    paymentMethod = String.Join("/", viewModel.PaymentMethod.Where(p => p != null && p.Length > 0)).GetEfficientString();
                }

                if (paymentMethod == null)
                {
                    ModelState.AddModelError("PaymentMethod", "請選擇支付方式");
                }
            }


            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return null;
            }

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            CourseContract item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                if (item.Status != (int)Naming.CourseContractStatus.草稿)
                {
                    ModelState.AddModelError("Message", "合約狀態錯誤，請重新檢查!!");
                    return null;
                }
            }

            String storedPath = null;
            if (Request.Form.Files.Count > 0)
            {
                storedPath = Path.Combine(FileLogger.Logger.LogDailyPath, Guid.NewGuid().ToString() + Path.GetExtension(Request.Form.Files[0].FileName));
                Request.Form.Files[0].SaveAs(storedPath);
            }

            item = models.InitiateCourseContract2022(viewModel, profile, lessonPrice, paymentMethod: paymentMethod, draftOnly: draftOnly);
            DateTime payoffDue = item.ContractDate.Value.AddMonths(1).FirstDayOfMonth();
            item.PayoffDue = payoffDue.AddDays(-1);
            if (storedPath != null)
            {
                item.CourseContractExtension.Attachment = new Attachment
                {
                    StoredPath = storedPath,
                };
            }
            models.SubmitChanges();

            if (!draftOnly)
            {
                if (item.InstallmentID.HasValue)
                {
                    if (lessonPrice.IsCombination)
                    {
                        int?[] viewModelLessons = new int?[viewModel.OrderLessons.Length];
                        int[] installment = viewModel.OrderLessons.Select(t => Math.Max((t ?? 0) / item.ContractInstallment.Installments, 1)).ToArray();
                        viewModel.OrderLessons.CopyTo(viewModelLessons, 0);

                        for (int i = 0; i < viewModel.OrderLessons.Length; i++)
                        {
                            if (viewModel.OrderLessons[i].HasValue)
                            {
                                viewModel.OrderLessons[i] = installment[i];
                                if (viewModelLessons[i] > item.ContractInstallment.Installments)
                                {
                                    viewModel.OrderLessons[i] += (viewModelLessons[i] % item.ContractInstallment.Installments);
                                }
                            }
                        }

                        item.UpdateCustomCombinationTotalCost(viewModel);
                        models.SubmitChanges();

                        for (int s = 0; s < viewModelLessons.Length; s++)
                        {
                            if (viewModelLessons[s].HasValue)
                            {
                                viewModelLessons[s] -= viewModel.OrderLessons[s];
                            }
                        }

                        payoffDue = payoffDue.AddMonths(1);
                        viewModel.ContractID = null;
                        viewModel.KeyID = null;

                        for (int idx = 0; idx < item.ContractInstallment.Installments - 1; idx++)
                        {
                            for (int i = 0; i < viewModel.OrderLessons.Length; i++)
                            {
                                if (viewModel.OrderLessons[i].HasValue)
                                {
                                    viewModel.OrderLessons[i] = Math.Min(installment[i], viewModelLessons[i].Value);
                                }
                            }

                            var c = models.InitiateCourseContract2022(viewModel, profile, lessonPrice, item.InstallmentID, paymentMethod);
                            c.PayoffDue = payoffDue.AddDays(-1);
                            c.Installment = true;
                            //c.Remark = $"{c.Remark}帳款應付期限{payoffDue:yyyy/MM/dd}。";
                            if (storedPath != null)
                            {
                                c.CourseContractExtension.Attachment = new Attachment
                                {
                                    StoredPath = storedPath,
                                };
                            }
                            models.SubmitChanges();

                            payoffDue = payoffDue.AddMonths(1);
                            for (int s = 0; s < viewModelLessons.Length; s++)
                            {
                                if (viewModelLessons[s].HasValue)
                                {
                                    viewModelLessons[s] -= viewModel.OrderLessons[s];
                                }
                            }
                        }
                    }
                    else
                    {
                        int totalLessons = item.Lessons.Value;
                        int installment = totalLessons / item.ContractInstallment.Installments;
                        //if(item.Remark!=null)
                        //{
                        //    var idx = item.Remark.IndexOf("本合約分期轉開次數");
                        //    if (idx >= 0)
                        //    {
                        //        item.Remark = item.Remark.Substring(0, idx);
                        //    }
                        //}

                        //viewModel.Remark = item.Remark = $"{item.Remark}本合約分期轉開次數{item.ContractInstallment.Installments}次。";
                        item.Lessons = installment + (totalLessons % item.ContractInstallment.Installments);
                        item.TotalCost = item.TotalCost * item.Lessons / totalLessons;
                        //item.Remark = $"{item.Remark}帳款應付期限{payoffDue:yyyy/MM/dd}。";
                        models.SubmitChanges();

                        totalLessons -= item.Lessons.Value;
                        payoffDue = payoffDue.AddMonths(1);
                        viewModel.ContractID = null;
                        viewModel.KeyID = null;
                        while (totalLessons > 0)
                        {
                            viewModel.Lessons = Math.Min(installment, totalLessons);
                            var c = models.InitiateCourseContract(viewModel, profile, lessonPrice, item.InstallmentID, paymentMethod);
                            c.PayoffDue = payoffDue.AddDays(-1);
                            c.Installment = true;
                            //c.Remark = $"{c.Remark}帳款應付期限{payoffDue:yyyy/MM/dd}。";
                            if (storedPath != null)
                            {
                                c.CourseContractExtension.Attachment = new Attachment
                                {
                                    StoredPath = storedPath,
                                };
                            }
                            models.SubmitChanges();

                            payoffDue = payoffDue.AddMonths(1);
                            totalLessons -= installment;
                        }
                    }
                }

                if (item.Status == (int)Naming.CourseContractStatus.待審核)
                {
                    if (item.CourseContractExtension.BranchStore.ManagerID.HasValue)
                    {
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyManagerToApproveContract.cshtml", item);
                        jsonData.PushLineMessage();
                    }
                    if (profile.UID != item.CourseContractExtension.BranchStore.ViceManagerID
                        && item.CourseContractExtension.BranchStore.ViceManagerID.HasValue)
                    {
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyViceManagerToApproveContract.cshtml", item);
                        jsonData.PushLineMessage();
                    }
                }
                else if (item.Status == (int)Naming.CourseContractStatus.待簽名)
                {
                    if (item.CourseContractExtension.SignOnline == true)
                    {
                        //item.CreateLineReadyToSignContract(models).PushLineMessage();
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyLearnerToSignContract.cshtml", item);
                        jsonData.PushLineMessage();
                    }
                    else if (!profile.IsManager() || item.FitnessConsultant != profile.UID)
                    {
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyCoachToSignContract.cshtml", item);
                        jsonData.PushLineMessage();
                    }
                }
            }

            return item;
        }

        public static LessonPriceType ValidateTotalCost(this CourseContractViewModel viewModel, SampleController<UserProfile> controller)
        {
            var ModelState = controller.ModelState;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            List<LessonPriceType> priceItems = new List<LessonPriceType>();
            var item = models.GetTable<LessonPriceType>().Where(p => p.PriceID == viewModel.PriceID).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("PriceID", "請選擇課程單價");
            }
            else if(!viewModel.Lessons.HasValue)
            {
                if (viewModel.OrderLessons == null || viewModel.OrderLessons.Length == 0)
                {
                    ModelState.AddModelError("OrderLessons", "請輸入購買單位");
                }
                else if (!viewModel.OrderLessons[0].HasValue || viewModel.OrderLessons[0] <= 0)
                {
                    ModelState.AddModelError("OrderLessons,0", "請輸入購買單位");
                }
                else
                {
                    var priceItem = models.GetTable<LessonPriceType>().Where(p => p.PriceID == viewModel.OrderPriceID[0]).FirstOrDefault();
                    if (priceItem == null)
                    {
                        ModelState.AddModelError("OrderLessons,0", "請選擇課程單價");
                    }
                    else
                    {
                        priceItems.Add(priceItem);

                        if (viewModel.PriceAdjustment == CourseContractExtension.UnitPriceAdjustmentDefinition.T1 && viewModel.OrderLessons[0] < priceItem.LowerLimit)
                        {
                            ModelState.AddModelError("OrderLessons,0", $"購買最少{priceItem.LowerLimit}單位");
                        }
                        else if (viewModel.PriceAdjustment == CourseContractExtension.UnitPriceAdjustmentDefinition.T1 && viewModel.OrderLessons[0] >= priceItem.UpperBound)
                        {
                            ModelState.AddModelError("OrderLessons,0", $"購買不可大於(含){priceItem.UpperBound}單位");
                        }
                        else if (viewModel.OrderLessons.Length > 1 && viewModel.OrderLessons[1] < 0)
                        {
                            ModelState.AddModelError("OrderLessons,1", "請輸入購買單位");
                        }
                        else if (viewModel.OrderLessons.Length > 2 && viewModel.OrderLessons[2] < 0)
                        {
                            ModelState.AddModelError("OrderLessons,2", "請輸入購買單位");
                        }
                        else if (viewModel.OrderLessons.Length > 3 && viewModel.OrderLessons[3] < 0)
                        {
                            ModelState.AddModelError("OrderLessons,3", "請輸入購買單位");
                        }
                    }

                    if (ModelState.IsValid)
                    {
                        //if(viewModel.PriceAdjustment == CourseContractExtension.UnitPriceAdjustmentDefinition.T1)
                        {
                            for (int i = 1; i < viewModel.OrderPriceID.Length; i++)
                            {
                                priceItem = models.GetTable<LessonPriceType>().Where(p => p.PriceID == viewModel.OrderPriceID[i]).FirstOrDefault();
                                priceItems.Add(priceItem);

                                if (priceItem == null)
                                {
                                    ModelState.AddModelError($"OrderLessons,{i}", "請選擇課程單價");
                                    continue;
                                }

                                if (priceItem.Status == (int)Naming.LessonPriceStatus.運動恢復課程
                                    || priceItem.Status == (int)Naming.LessonPriceStatus.運動防護課程)
                                {
                                    if (viewModel.OrderLessons[i] > viewModel.OrderLessons[0])
                                    {
                                        ModelState.AddModelError($"OrderLessons,{i}", $"購買不可大於{viewModel.OrderLessons[0]}單位");
                                    }
                                }
                                else if (priceItem.Status == (int)Naming.LessonPriceStatus.營養課程)
                                {
                                    if (viewModel.OrderLessons[i] > priceItem.UpperBound)
                                    {
                                        ModelState.AddModelError($"OrderLessons,{i}", $"購買不可大於{priceItem.UpperBound}單位");
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if(ModelState.IsValid)
            {
                controller.ViewBag.PriceItems = priceItems;
            }

            return item;
        }

        public static bool ExecuteContractStatus(this CourseContract item, UserProfile profile, Naming.CourseContractStatus status, Naming.CourseContractStatus? fromStatus)
        {
            if (fromStatus.HasValue && item.Status != (int)fromStatus)
                return false;

            item.CourseContractLevel.Add(new CourseContractLevel
            {
                ExecutorID = profile.UID,
                LevelDate = DateTime.Now,
                LevelID = (int)status
            });

            item.Status = (int)status;

            //if (item.CourseContractRevision == null)
            //{
            //    if (status == Naming.CourseContractStatus.待簽名)
            //        item.SupervisorID = profile.UID;
            //}
            //else 
            //{
            //    if (status == Naming.CourseContractStatus.已生效)
            //        item.SupervisorID = profile.UID;
            //}

            return true;

        }

        public static async Task<UserProfile> CommitUserProfileAsync(this ContractMemberViewModel viewModel, SampleController<UserProfile> controller)
            
        {
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            ViewBag.ViewModel = viewModel;

            viewModel.IDNo = viewModel.IDNo.GetEfficientString();
            if (viewModel.IDNo == null)
            {
                if (viewModel.CurrentTrial != 1 && viewModel.IsAdult)
                {
                    ModelState.AddModelError("IDNo", "請輸入身分證字號/護照號碼");
                }
            }
            else if (Regex.IsMatch(viewModel.IDNo, "[A-Za-z]\\d{9}") && !viewModel.IDNo.CheckIDNo())
            {
                ModelState.AddModelError("IDNo", "身份證字號格式錯誤!!");
            }
            else if (viewModel.UID.HasValue)
            {
                if (models.GetTable<UserProfileExtension>().Any(u => u.IDNo == viewModel.IDNo && u.UID != viewModel.UID))
                {
                    ModelState.AddModelError("IDNo", "身份證字號/護照號碼已存在!!");
                }
            }
            else
            {
                if (models.GetTable<UserProfileExtension>().Any(u => u.IDNo == viewModel.IDNo))
                {
                    ModelState.AddModelError("IDNo", "身份證字號/護照號碼已存在!!");
                }
            }

            if (viewModel.CurrentTrial != 1)
            {

                if (!viewModel.Birthday.HasValue)
                {
                    ModelState.AddModelError("Birthday", "請輸入出生");
                }

                viewModel.AdministrativeArea = viewModel.AdministrativeArea.GetEfficientString();
                if (viewModel.AdministrativeArea == null && viewModel.IsAdult)
                {
                    ModelState.AddModelError("AdministrativeArea", "請選擇縣市");
                }
                viewModel.Address = viewModel.Address.GetEfficientString();
                if (viewModel.Address == null && viewModel.IsAdult)
                {
                    ModelState.AddModelError("Address", "請輸入居住地址");
                }
                if (String.IsNullOrEmpty(viewModel.EmergencyContactPerson))
                {
                    ModelState.AddModelError("EmergencyContactPerson", "請輸入緊急聯絡人");
                }
                if (String.IsNullOrEmpty(viewModel.Relationship))
                {
                    ModelState.AddModelError("Relationship", "請選擇關係");
                }
                if (String.IsNullOrEmpty(viewModel.EmergencyContactPhone))
                {
                    ModelState.AddModelError("EmergencyContactPhone", "請輸入緊急聯絡人電話");
                }

                viewModel.RoleID = Naming.RoleID.Learner;
            }
            else
            {
                viewModel.RoleID = Naming.RoleID.Preliminary;
            }

            if (String.IsNullOrEmpty(viewModel.RealName))
            {
                ModelState.AddModelError("RealName", "請輸入真實姓名");
            }

            void validatePhone()
            {
                viewModel.Phone = viewModel.Phone.GetEfficientString();
                if (viewModel.Phone == null)
                {
                    if (!viewModel.IsAdult)
                    {
                        if (viewModel.PhoneType?.Contains(ContractMemberViewModel.PhoneUsage.Relational) == true)
                        {
                            viewModel.RelationMemo = viewModel.RelationMemo.GetEfficientString();
                            if (!viewModel.RelationID.HasValue)
                            {
                                ModelState.AddModelError("UserName", "請選擇非本人手機聯絡人");
                                return;
                            }
                            else if (viewModel.RelationMemo == null)
                            {
                                ModelState.AddModelError("RelationMemo", "請選擇關係");
                                return;
                            }
                        }
                    }
                    else
                    {
                        ModelState.AddModelError("Phone", "請輸入手機號碼");
                    }
                }
                else
                {
                    if (viewModel.UID.HasValue)
                    {
                        if (models.GetTable<UserProfile>().Any(u => u.Phone == viewModel.Phone && u.UID != viewModel.UID))
                        {
                            ModelState.AddModelError("Phone", "手機號碼不得與其他人相同!!");
                        }
                    }
                    else
                    {
                        if (models.GetTable<UserProfile>().Any(u => u.Phone == viewModel.Phone))
                        {
                            ModelState.AddModelError("Phone", "手機號碼不得與其他人相同!!");
                        }
                    }
                }
            }

            validatePhone();

            viewModel.Gender = viewModel.Gender.GetEfficientString();
            if (viewModel.Gender == null)
            {
                ModelState.AddModelError("Gender", "請選擇性別");
            }

            //if (!viewModel.AthleticLevel.HasValue)
            //{
            //    ModelState.AddModelError("AthleticLevel", "請選擇是否為運動員!!");
            //}

            var item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            viewModel.Email = viewModel.Email.GetEfficientString();
            if (viewModel.Email != null && item != null && item.LevelID == (int)Naming.MemberStatus.已註冊)
            {
                if (item.PID != viewModel.Email && models.GetTable<UserProfile>().Any(u => u.PID == viewModel.Email))
                {
                    ModelState.AddModelError("PID", "您的電子郵件信箱已經是註冊使用者!!");
                }
                else
                {
                    item.PID = viewModel.Email;
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return null;
            }

            if (item == null)
            {
                item = models.CreateLearner(viewModel);
                viewModel.UID = item.UID;
            }

            item.RealName = viewModel.RealName;
            item.Phone = viewModel.Phone;
            item.Address = viewModel.Address;
            if (viewModel.Birthday.HasValue)
            {
                item.BirthdateIndex = viewModel.Birthday.Value.Month * 100 + viewModel.Birthday.Value.Day;
            }
            else
            {
                item.BirthdateIndex = null;
            }
            item.Birthday = viewModel.Birthday;
            item.Nickname = viewModel.Nickname;
            item.UserProfileExtension.Gender = viewModel.Gender;
            item.UserProfileExtension.AthleticLevel = viewModel.AthleticLevel;

            item.UserProfileExtension.EmergencyContactPhone = viewModel.EmergencyContactPhone;
            item.UserProfileExtension.EmergencyContactPerson = viewModel.EmergencyContactPerson;
            item.UserProfileExtension.Relationship = viewModel.Relationship;
            item.UserProfileExtension.AdministrativeArea = viewModel.AdministrativeArea;
            viewModel.IDNo = viewModel.IDNo.GetEfficientString();
            if (viewModel.IDNo != null)
                item.UserProfileExtension.IDNo = viewModel.IDNo.ConvertToHalfWidthString().ToUpper();
            item.UserProfileExtension.CurrentTrial = viewModel.CurrentTrial;

            models.SubmitChanges();
            if (viewModel.CurrentTrial != 1)
            {
                models.ExecuteCommand("update UserRole set RoleID={0} where UID={1} and RoleID={2} ", (int)Naming.RoleID.Learner, item.UID, (int)Naming.RoleID.Preliminary);
            }

            if (viewModel.RelationID.HasValue)
            {
                models.ExecuteCommand("delete UserRelationship where UID={0} and RelationFor={1}",
                    item.UID, (int)UserRelationship.RelationForDefinition.NotMySelfPhone);

                var relation = models.GetTable<UserRelationship>().Where(r => r.LeaderID == viewModel.RelationID)
                        .Where(r => r.UID == item.UID).FirstOrDefault();

                if (relation == null)
                {
                    relation = new UserRelationship
                    {
                        UID = item.UID,
                        LeaderID = viewModel.RelationID.Value,
                    };
                    models.GetTable<UserRelationship>().InsertOnSubmit(relation);
                }
                relation.Memo = viewModel.RelationMemo;
                relation.RelationFor = (int)UserRelationship.RelationForDefinition.NotMySelfPhone;
                models.SubmitChanges();
            }

            return item;
        }

        public static async Task<CourseContract> ExecuteContractStatusAsync(this CourseContractViewModel viewModel, SampleController<UserProfile> controller)
            
        {
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                if (item.ExecuteContractStatus(profile, (Naming.CourseContractStatus)viewModel.Status.Value, viewModel.FromStatus))
                {
                    if (viewModel.Drawback == true)
                    {
                        item.ContractNo = null;
                        models.DeleteAllOnSubmit<CourseContractSignature>(s => s.ContractID == item.ContractID);

                        if (item.InstallmentID.HasValue)
                        {
                            if (viewModel.Status == (int)Naming.CourseContractStatus.草稿)
                            {
                                if (item.CourseContractOrder.Count > 0)
                                {
                                    var installments = models.GetTable<CourseContract>()
                                        .Where(t => t.InstallmentID == item.InstallmentID)
                                        .Where(t => t.ContractID != item.ContractID);

                                    foreach(var c in installments)
                                    {
                                        foreach(var source in c.CourseContractOrder)
                                        {
                                            var destPrice = item.CourseContractOrder.Where(d => d.PriceID == source.PriceID).FirstOrDefault();
                                            if (destPrice != null)
                                            {
                                                destPrice.Lessons += source.Lessons; ;
                                            }
                                            else
                                            {
                                                item.CourseContractOrder.Add(new CourseContractOrder 
                                                {
                                                    CourseContract = item,
                                                    Lessons = source.Lessons,
                                                    PriceID = source.PriceID,
                                                    Title = source.Title,
                                                    LessonPriceType = source.LessonPriceType,
                                                    SeqNo = item.CourseContractOrder.Count,
                                                });
                                            }
                                        }
                                        models.GetTable<CourseContract>().DeleteOnSubmit(c);
                                    }

                                    item.EvaluateCustomCombinationTotalCost(out int totalLessons, out int totalCost);
                                    item.Lessons = totalLessons;
                                    item.TotalCost = totalCost;
                                }
                                else
                                {
                                    var totalLessons = item.ContractInstallment.CourseContract.Sum(c => c.Lessons);
                                    if (item.Lessons > 0)
                                    {
                                        item.TotalCost = item.TotalCost * totalLessons / item.Lessons;
                                    }
                                    item.Lessons = totalLessons;
                                    models.DeleteAllOnSubmit<CourseContract>(t => t.ContractID != item.ContractID && t.InstallmentID == item.InstallmentID);
                                }

                                //var idx = item.Remark.IndexOf("本合約分期轉開次數");
                                //if (idx >= 0)
                                //{
                                //    item.Remark = item.Remark.Substring(0, idx);
                                //}
                            }
                            else
                            {
                                foreach (var c in item.ContractInstallment.CourseContract)
                                {
                                    if (c.ContractID == item.ContractID)
                                        continue;
                                    c.ExecuteContractStatus(profile, (Naming.CourseContractStatus)viewModel.Status.Value, viewModel.FromStatus);
                                    c.ContractNo = null;
                                    models.DeleteAllOnSubmit<CourseContractSignature>(s => s.ContractID == c.ContractID);
                                }
                            }
                        }

                    }
                    if (viewModel.SupervisorID.HasValue)
                    {
                        item.SupervisorID = viewModel.SupervisorID;
                    }
                    models.SubmitChanges();

                    if (item.CourseContractRevision == null)
                    {
                        if (viewModel.Status == (int)Naming.CourseContractStatus.待簽名)
                        {
                            if (!item.InstallmentID.HasValue)
                            {
                                //item.CreateLineReadyToSignContract(models).PushLineMessage();
                                if (item.CourseContractExtension.SignOnline == true)
                                {
                                    var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyLearnerToSignContract.cshtml", item);
                                    jsonData.PushLineMessage();
                                }
                                else
                                {
                                    var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyCoachToSignContract.cshtml", item);
                                    jsonData.PushLineMessage();
                                }
                            }
                            else if (!item.ContractInstallment.CourseContract.Any(c => c.Status != (int)Naming.CourseContractStatus.待簽名))
                            {
                                var current = item.ContractInstallment.CourseContract
                                                .OrderBy(c => c.ContractID)
                                                .First();
                                if (item.CourseContractExtension.SignOnline == true)
                                {
                                    //item.ContractInstallment.CourseContract.OrderBy(c => c.ContractID)
                                    //    .First().CreateLineReadyToSignContract(models).PushLineMessage();
                                    var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyLearnerToSignContract.cshtml", current);
                                    jsonData.PushLineMessage();
                                }
                                else
                                {
                                    var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyCoachToSignContract.cshtml", current);
                                    jsonData.PushLineMessage();
                                }

                            }
                        }
                        else if (viewModel.Drawback == true && profile.UID != item.FitnessConsultant)
                        {
                            var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyCoachToRejectContract.cshtml", item);
                            jsonData.PushLineMessage();
                        }
                    }
                    else if (item.CourseContractRevision.Reason == "展延")
                    {
                        //合約服務
                        if (viewModel.Status == (int)Naming.CourseContractStatus.待簽名)
                        {
                            if (item.CourseContractExtension.SignOnline == true)
                            {
                                var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyLearnerToSignExtend.cshtml", item);
                                jsonData.PushLineMessage();
                            }
                            else if (profile.UID != item.AgentID)
                            {
                                var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyCoachToSignExtend.cshtml", item);
                                jsonData.PushLineMessage();
                            }
                        }
                    }
                    else if (item.CourseContractRevision.Reason == "終止")
                    {
                        //合約服務
                        if (viewModel.Status == (int)Naming.CourseContractStatus.待簽名)
                        {
                            if (item.CourseContractExtension.SignOnline == true)
                            {
                                var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyLearnerToSignTermination.cshtml", item);
                                jsonData.PushLineMessage();
                            }
                            else if (profile.UID != item.AgentID)
                            {
                                var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyCoachToSignTermination.cshtml", item);
                                jsonData.PushLineMessage();
                            }
                        }
                    }
                    else if (item.CourseContractRevision.Reason == "轉換課程堂數")
                    {
                        //合約服務
                        if (viewModel.Status == (int)Naming.CourseContractStatus.待簽名)
                        {
                            if (item.CourseContractExtension.SignOnline == true)
                            {
                                var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyLearnerToSignExchange.cshtml", item);
                                jsonData.PushLineMessage();
                            }
                            else if (profile.UID != item.AgentID)
                            {
                                var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyCoachToSignExchange.cshtml", item);
                                jsonData.PushLineMessage();
                            }
                        }
                    }

                    return item;
                }
                else
                {
                    ModelState.AddModelError("Message", "合約狀態錯誤，請重新檢查!");
                    return null;
                }
            }
            else
            {
                ModelState.AddModelError("Message", "合約資料錯誤!!");
                return null;
            }
        }

        public static async Task NotifyLearnerToSignContractAsync(this CourseContract item, SampleController<UserProfile> controller)
        {
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            if (item.Status == (int)Naming.CourseContractStatus.待簽名)
            {
                if (item.CourseContractExtension.SignOnline == true)
                {
                    var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyLearnerToSignContract.cshtml", item);
                    jsonData.PushLineMessage();
                }
            }
        }

        public static async Task<CourseContract> EnableContractAmendmentAsync(this CourseContractViewModel viewModel, SampleController<UserProfile> controller, Naming.CourseContractStatus? fromStatus = Naming.CourseContractStatus.待簽名)
            
        {
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.RevisionID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContractRevision>().Where(c => c.RevisionID == viewModel.RevisionID).FirstOrDefault();
            if (item != null)
            {
                item.EnableContractAmendment(models, profile, fromStatus);
                return item.CourseContract;
            }
            else
            {
                ModelState.AddModelError("Message", "合約資料錯誤!!");
                return null;
            }
        }

        public static void MarkContractNo(this CourseContract item, GenericManager<BFDataContext> models)
            
        {
            if (item.ContractNo == null)
            {
                //var items = models.GetTable<CourseContract>().Where(c => c.EffectiveDate >= DateTime.Today
                //        && c.Status >= (int)Naming.CourseContractStatus.待審核);
                long seqNo = (long)SqlHelper.ExecuteScalar(models.Connection.ConnectionString, System.Data.CommandType.Text, "select next value for CourseContractNoSeq");
                item.ContractNo = item.CourseContractType.ContractCode + String.Format("{0:yyyyMMdd}", DateTime.Today) + String.Format("{0:0000}", seqNo % 10000);
                //item.ContractNo = item.CourseContractType.ContractCode + String.Format("{0:yyyyMMdd}", DateTime.Today) + String.Format("{0:0000}", (item.ContractID - 4999) % 10000);
                models.SubmitChanges();
            }
        }

        public static List<LessonPriceType> ExpandActualLessonPrice(this LessonPriceType priceItem, GenericManager<BFDataContext> models, List<LessonPriceType> container = null)
        {
            if (container == null)
            {
                container = new List<LessonPriceType>();
            }

            if (priceItem.LessonPricePackage.Any())
            {
                foreach (var item in priceItem.LessonPricePackage)
                {
                    item.ExpandActualLessonPrice(models, container);
                }
            }

            return container;
        }

        public static int? ExpandActualLessonCount(this LessonPriceType priceItem, GenericManager<BFDataContext> models)
        {
            return priceItem.ExpandActualLessonPrice(models).Sum(p => (p.BundleCount ?? 0));
        }

        public static List<String> ExpandContractLessonDetails(this CourseContract item, GenericManager<BFDataContext> models, String prefix = null)
        {
            if(item.CourseContractOrder.Any())
            {
                return item.CourseContractOrder.OrderBy(o => o.SeqNo)
                    .Select(o => o.ContractOrderLessonDetails(prefix))
                    .ToList();
            }

            return new List<string>();
        }

        public static String ContractOrderLessonDetails(this CourseContractOrder order, String prefix = null)
        {
            var item = order.LessonPriceType;
            switch ((Naming.LessonPriceStatus?)item.Status)
            {
                case Naming.LessonPriceStatus.營養課程:
                    return $"{prefix}{(order.SeqNo > 0 ? "加購" : null)}營養諮詢(S.D){order.Lessons}個月{order.Lessons * (item.BundleCount ?? 1)}堂(購買一個月單價{item.ListPrice*item.BundleCount:##,###,####,###}元)。";
                case Naming.LessonPriceStatus.運動恢復課程:
                    return $"{prefix}{(order.SeqNo > 0 ? "加購" : null)}運動恢復(S.R){item.DurationInMinutes}分鐘{order.Lessons * (item.BundleCount ?? 1)}堂(購買每堂單價{item.ListPrice:##,###,####,###}元)。";
                case Naming.LessonPriceStatus.運動防護課程:
                    return $"{prefix}{(order.SeqNo > 0 ? "加購" : null)}運動防護(A.T){item.DurationInMinutes}分鐘{order.Lessons * (item.BundleCount ?? 1)}堂(購買每堂單價{item.ListPrice:##,###,####,###}元)。";
                default:
                    return $"{prefix}{(order.SeqNo > 0 ? "加購" : null)}私人教練(P.T){item.DurationInMinutes}分鐘{order.Lessons * (item.BundleCount ?? 1)}堂(購買每堂單價{item.ListPrice:##,###,####,###}元)。";
            }
        }

        public static List<LessonPriceType> ExpandActualLessonPrice(this LessonPricePackage package, GenericManager<BFDataContext> models, List<LessonPriceType> container = null)
        {
            if (container == null)
            {
                container = new List<LessonPriceType>();
            }

            if (package.PackageItemPrice.LessonPricePackage.Any())
            {
                foreach (var item in package.PackageItemPrice.LessonPricePackage)
                {
                    item.ExpandActualLessonPrice(models, container);
                }
            }
            else
            {
                container.Add(package.PackageItemPrice);
            }

            return container;
        }


        public static String MakeContractEffective(this CourseContract item, GenericManager<BFDataContext> models, UserProfile profile, Naming.CourseContractStatus? fromStatus = null)
            
        {
            if (!item.ExecuteContractStatus(profile, Naming.CourseContractStatus.已生效, fromStatus))
                return null;

            FileLogger.Logger.Debug($"contract,{item.ContractNo},member count:{item.CourseContractMember.ToList().Count}");

            if(item.CourseContractOrder.Any())
            {
                foreach (var order in item.CourseContractOrder.OrderBy(o => o.SeqNo))
                {
                    CreateRegisterLesson(item, models, order.LessonPriceType, order.Lessons * (order.LessonPriceType.BundleCount ?? 1), order.SeqNo > 0 ? "加購" : null);
                }
            }
            else if (item.LessonPriceType.IsPackagePrice)
            {
                var priceItems = item.LessonPriceType.ExpandActualLessonPrice(models);

                foreach(var price in priceItems)
                {
                    CreateRegisterLesson(item, models, price, price.BundleCount ?? 0);
                }

                item.Lessons = priceItems.Sum(p => p.BundleCount ?? 0);
                models.SubmitChanges();
            }
            else
            {
                CreateRegisterLesson(item, models, item.LessonPriceType, item.Lessons.Value);
            }

            foreach (var m in item.CourseContractMember)
            {
                models.ExecuteCommand(@"
                        UPDATE UserRole
                        SET        RoleID = {2}
                        WHERE   (UID = {0}) AND (RoleID = {1})", m.UID, (int)Naming.RoleID.Preliminary, (int)Naming.RoleID.Learner);

                models.ExecuteCommand(@"
                        update UserProfileExtension set CurrentTrial = null where UID = {0}", m.UID);
            }

            if (!item.CourseContractAction.Any(a => a.ActionID == (int)CourseContractAction.ActionType.盤點))
            {
                item.CourseContractAction.Add(new CourseContractAction
                {
                    ActionID = (int)CourseContractAction.ActionType.盤點
                });
                models.SubmitChanges();
            }

            var pdfFile = item.CreateContractPDF();
            return pdfFile;
        }

        public static List<RegisterLesson> CreateRegisterLesson(this CourseContract item, GenericManager<BFDataContext> models,LessonPriceType price,int lessons,String title = null) 
        {

            var groupLesson = new GroupingLesson { };
            var table = models.GetTable<RegisterLesson>();
            List<RegisterLesson> sharingItems = new List<RegisterLesson>();

            foreach (var m in item.CourseContractMember)
            {

                if (item.RegisterLessonContract
                    .Where(r => r.RegisterLesson.UID == m.UID)
                    .Where(r => r.RegisterLesson.ClassLevel == price.PriceID)
                    .Any())
                {
                    continue;
                }

                var lesson = new RegisterLesson
                {
                    ClassLevel = price.PriceID,
                    RegisterDate = DateTime.Now,
                    Lessons = lessons,
                    Attended = (int)Naming.LessonStatus.準備上課,
                    GroupingMemberCount = item.CourseContractMember.Count,
                    IntuitionCharge = new IntuitionCharge
                    {
                        Payment = "CreditCard",
                        FeeShared = 0,
                        ByInstallments = 1
                    },
                    AdvisorID = item.FitnessConsultant,
                    AttendedLessons = 0,
                    UID = m.UID,
                    RegisterLessonContract = new RegisterLessonContract
                    {
                        ContractID = item.ContractID,
                        Title = title,
                    }
                };

                if (item.ContractType == (int)CourseContractType.ContractTypeDefinition.CFA
                    || item.ContractType == (int)CourseContractType.ContractTypeDefinition.CGF
                    || item.ContractType == (int)CourseContractType.ContractTypeDefinition.CVF)
                {
                    lesson.GroupingMemberCount = 1;
                    lesson.GroupingLesson = new GroupingLesson { };
                    lesson.RegisterLessonContract.ForShared = true;
                    //sharingItems.Add(lesson);
                }
                else
                {
                    if(price.IsOneByOne)
                    {
                        lesson.GroupingMemberCount = 1;
                        lesson.GroupingLesson = new GroupingLesson { };
                        lesson.RegisterLessonContract.ForShared = true;
                        //sharingItems.Add(lesson);
                    }
                    else
                    {
                        lesson.GroupingLesson = groupLesson;
                    }
                }

                sharingItems.Add(lesson);
                table.InsertOnSubmit(lesson);
            }

            models.SubmitChanges();

            if (sharingItems.Count > 0)
            {
                models.GetTable<RegisterLessonSharing>()
                    .InsertAllOnSubmit(sharingItems.Select(s => 
                        new RegisterLessonSharing 
                        {
                            ShareID = sharingItems[0].RegisterID,
                            RegisterID = s.RegisterID,
                        }));

                models.SubmitChanges();

                for (int i = 1; i <= lessons; i++)
                {
                    models.GetTable<RegisterLessonBooking>().InsertOnSubmit(new RegisterLessonBooking 
                    {
                        BookingID = i,
                        RegisterID = sharingItems[0].RegisterID,
                    });

                    models.SubmitChanges();
                }
            }

            return sharingItems;
        }

        public static async Task<CourseContract> ConfirmContractSignatureAsync(this CourseContractViewModel viewModel, SampleController<UserProfile> controller,CourseContract item = null)
            
        {
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (item == null)
            {
                if (viewModel.KeyID != null)
                {
                    viewModel.ContractID = viewModel.DecryptKeyValue();
                }

                item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            }

            if (item == null)
            {
                ModelState.AddModelError("Message", "合約資料錯誤!!");
                return null;
            }

            var owner = item.CourseContractMember.Where(m => m.UID == item.OwnerID).First();

            if (item.CourseContractType.ContractCode == "CFA"
                || item.CourseContractType.ContractCode == "CGF"
                || item.CourseContractType.ContractCode == "CVF")
            {
                if (owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 3)
                {
                    ModelState.AddModelError("Message", "未完成簽名!!");
                    return null;
                }
            }
            else
            {

                if (owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 2)
                {
                    ModelState.AddModelError("Message", "未完成簽名!!");
                    return null;
                }

                //if (item.CourseContractType.IsGroup == true)
                //{
                //    if (item.CourseContractMember.Any(m => m.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 2))
                //    {
                //        ModelState.AddModelError("Message", "未完成簽名!!");
                //        return null;
                //    }

                //    foreach (var m in item.CourseContractMember)
                //    {
                //        if (m.UserProfile.CurrentYearsOld() < 18 && owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Guardian") && s.Signature != null) < 2)
                //        {
                //            ModelState.AddModelError("Message", "家長/監護人未完成簽名!!");
                //            return null;
                //        }
                //    }
                //}
            }

            if (viewModel.Extension != true || viewModel.Booking != true)
            {
                ModelState.AddModelError("Message", "請閱讀並勾選同意超越體能顧問有限公司服務條款、相關使用及消費合約");
                return null;
            }

            if (viewModel.Agree != true)
            {
                ModelState.AddModelError("Message", "請閱讀並同意BF隱私政策、服務條款、相關使用及消費合約，即表示即日起您同意接受本合約正面及背面條款之相關約束及其責任");
                return null;
            }

            if (viewModel.GDPRAgree != true) {
                ModelState.AddModelError("Message", "請勾選同意BF得依本告知暨同意書之內容蒐集、處理、利用及國際傳輸本人之個人資料。就其中有關本人家屬和親友之個人資料，由本人負責告知，並使其充分知悉和同意本告知暨同意書之內容。");
                return null;
            }

            //if (!item.ExecuteContractStatus(profile, Naming.CourseContractStatus.待審核, Naming.CourseContractStatus.待簽名))
            //{
            //    alertMessage = "合約狀態錯誤，請重新檢查!!";
            //    return null;
            //}

            item.EffectiveDate = DateTime.Now;
            //item.ValidFrom = DateTime.Today;
            //item.Expiration = DateTime.Today.AddMonths(18);

            models.SubmitChanges();

            item.MarkContractNo(models);

            _ = item.MakeContractEffective(models, profile);

            //ThreadPool.QueueUserWorkItem(t =>
            //{
            //    try
            //    {
            //        item.CreateContractPDF();
            //    }
            //    catch (Exception ex)
            //    {
            //        Logger.Error(ex);
            //    }
            //});

            return item;
        }

        public static async Task<CourseContract> ConfirmContractServiceSignatureAsync(this CourseContractViewModel viewModel, SampleController<UserProfile> controller, CourseContractRevision item = null)
            
        {
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (item == null)
            {
                if (viewModel.KeyID != null)
                {
                    viewModel.ContractID = viewModel.DecryptKeyValue();
                }
                item = models.GetTable<CourseContractRevision>().Where(c => c.RevisionID == viewModel.ContractID).FirstOrDefault();
            }

            if (item != null)
            {
                CourseContract contract = item.CourseContract;
                var owner = contract.CourseContractMember.Where(m => m.UID == contract.OwnerID).First();

                if (contract.CourseContractType.ContractCode == "CFA"
                    || contract.CourseContractType.ContractCode == "CGF"
                    || contract.CourseContractType.ContractCode == "CVF")
                {
                    if (owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 1)
                    {
                        ModelState.AddModelError("Message", "未完成簽名!!");
                        return null;
                    }
                }
                else
                {

                    if (owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 1)
                    {
                        ModelState.AddModelError("Message", "未完成簽名!!");
                        return null;
                    }

                    //if (contract.CourseContractType.IsGroup == true)
                    //{
                    //    if (contract.CourseContractMember.Any(m => m.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 1))
                    //    {
                    //        return View("~/Views/Shared/JsAlert.cshtml", model: "未完成簽名!!");
                    //    }

                    //    foreach (var m in contract.CourseContractMember)
                    //    {
                    //        if (m.UserProfile.CurrentYearsOld() < 18 && owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Guardian") && s.Signature != null) < 1)
                    //        {
                    //            return View("~/Views/Shared/JsAlert.cshtml", model: "家長/監護人未完成簽名!!");
                    //        }
                    //    }
                    //}
                }

                if (viewModel.Extension != true)
                {
                    ModelState.AddModelError("Message", "請閱讀並勾選同意超越體能顧問有限公司服務條款、相關使用及消費合約");
                    return null;
                }
                

                if (item.Reason == "終止")
                {
                    if (viewModel.Agree != true)
                    {
                        ModelState.AddModelError("Message", "請閱讀並同意BF隱私政策、服務條款、相關使用及消費合約，即表示即日起您同意接受本合約正面及背面條款之相關約束及其責任");
                        return null;
                    }
                }

                if (item.Reason == "展延")
                {
                    if (viewModel.Booking != true || viewModel.Agree != true)
                    {
                        ModelState.AddModelError("Message", "請閱讀並同意BF隱私政策、服務條款、相關使用及消費合約，即表示即日起您同意接受本合約正面及背面條款之相關約束及其責任");
                        return null;
                    }
                }
                else if (item.Reason == "轉換課程堂數")
                {
                    if (viewModel.Booking != true || viewModel.Agree != true)
                    {
                        ModelState.AddModelError("Message", "請閱讀並同意BF隱私政策、服務條款、相關使用及消費合約，即表示即日起您同意接受本合約正面及背面條款之相關約束及其責任");
                        return null;
                    }
                }

                if (!item.EnableContractAmendment(models, profile))
                {
                    ModelState.AddModelError("Message", "服務狀態錯誤，請重新檢查!!");
                    return null;
                }

                if (item.Reason == "終止")
                {
                    if (viewModel.Agree != true)
                    {
                        ModelState.AddModelError("Message", "請閱讀並同意BF隱私政策、服務條款、相關使用及消費合約，即表示即日起您同意接受本合約正面及背面條款之相關約束及其責任");
                        return null;
                    }

                    if (!item.SourceContract.CourseContractAction.Any(a => a.ActionID == (int)CourseContractAction.ActionType.免收手續費))
                    {
                        if (item.CauseForEnding == (int)Naming.CauseForEnding.轉讓第三人
                            || item.CauseForEnding == (int)Naming.CauseForEnding.合約到期轉新約
                            || item.CauseForEnding == (int)Naming.CauseForEnding.更改合約類型)
                        {
                            if (item.SourceContract.AttendedLessonCount() > 0
                                || (DateTime.Today - item.SourceContract.ValidFrom.Value).TotalDays > 7)
                            {
                                if (!item.CourseContract.CourseContractAction.Any(c => c.ActionID == (int)CourseContractAction.ActionType.合約終止手續費))
                                {
                                    item.CourseContract.CourseContractAction
                                        .Add(
                                            new CourseContractAction
                                            {
                                                ActionID = (int)CourseContractAction.ActionType.合約終止手續費
                                            });
                                    models.SubmitChanges();
                                }
                            }
                        }
                    }
                }

                //_ = item.CreateContractAmendmentPDF(true);
                return contract;
            }
            else
            {
                ModelState.AddModelError("Message", "合約資料錯誤!!");
                return null;
            }
        }

        public static bool EnableContractAmendment(this CourseContractRevision item,GenericManager<BFDataContext> models, UserProfile profile,Naming.CourseContractStatus? fromStatus = Naming.CourseContractStatus.待簽名)
            
        {
            if (!item.CourseContract.ExecuteContractStatus(profile, Naming.CourseContractStatus.已生效, fromStatus))
                return false;

            item.CourseContract.EffectiveDate = DateTime.Now;
            models.SubmitChanges();

            foreach (var m in item.CourseContract.CourseContractMember)
            {
                models.ExecuteCommand(@"
                        UPDATE UserRole
                        SET        RoleID = {2}
                        WHERE   (UID = {0}) AND (RoleID = {1})", m.UID, (int)Naming.RoleID.Preliminary, (int)Naming.RoleID.Learner);
            }

            switch (item.Reason)
            {
                case "展延":
                    item.SourceContract.Expiration = item.CourseContract.Expiration;
                    if (item.SourceContract.Status == (int)Naming.CourseContractStatus.已過期)
                    {
                        item.SourceContract.Status = (int)Naming.CourseContractStatus.已生效;
                    }
                    models.SubmitChanges();
                    break;
                case "轉點":
                    item.ProcessContractMigration();
                    break;
                case "轉讓":
                    item.ProcessContractTransference();
                    break;
                case "終止":
                    if (item.OperationMode == (int)Naming.OperationMode.快速終止)
                    {
                        item.ProcessContractQuickTermination(profile);
                    }
                    else
                    {
                        item.ProcessContractTermination2022(profile);
                    }
                    break;
                case "轉換體能顧問":
                    item.SourceContract.FitnessConsultant = item.CourseContract.FitnessConsultant;
                    item.SourceContract.CourseContractExtension.BranchID = item.CourseContract.CourseContractExtension.BranchID;
                    models.SubmitChanges();
                    break;

                case "轉換課程堂數":
                    item.ProcessContractLessonExchange();
                    break;

            }

            return true;

        }


        public static async Task<CourseContract> CommitContractServiceAsync(this CourseContractViewModel viewModel, SampleController<UserProfile> controller, String attachment = null, String bankAccountInfo = null, String diagnosisPaper = null)

        {
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item == null)
            {
                ModelState.AddModelError("Message", "合約資料錯誤!!");
                return null;
            }

            CourseContract newItem;

            if (!viewModel.FitnessConsultant.HasValue)
            {
                ModelState.AddModelError("FitnessConsultant", "請選擇體能顧問!!");
            }

            if (String.IsNullOrEmpty(viewModel.Reason))
            {
                ModelState.AddModelError("Reason", "請選擇申請項目!!");
            }

            if (viewModel.Reason == "終止")
            {
                //if (!viewModel.SettlementPrice.HasValue)
                //{
                //    ModelState.AddModelError("SettlementPrice", "請填入課程單價!!");
                //}
                //else
                //{
                //    //bool checkRefund = true;
                //    if (item.ContractType == (int)CourseContractType.ContractTypeDefinition.CGA)
                //    {
                //        if (viewModel.SettlementPrice < 0)
                //        {
                //            ModelState.AddModelError("SettlementPrice", "組合包課程單價錯誤!!");
                //            //checkRefund = false;
                //        }
                //    }
                //    else
                //    {
                //        if (viewModel.SettlementPrice < item.LessonPriceType.ListPrice)
                //        {
                //            ModelState.AddModelError("SettlementPrice", "課程單價不可少於原購買單價!!");
                //            //checkRefund = false;
                //        }
                //    }

                //    //if (checkRefund)
                //    //{
                //    //    var refund = item.TotalPaidAmount() - item.AttendedLessonCount()
                //    //            * viewModel.SettlementPrice
                //    //            * item.CourseContractType.GroupingMemberCount
                //    //            * item.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount / 100;
                //    //    if (refund < 0)
                //    //    {
                //    //        ModelState.AddModelError("SettlementPrice", "退款差額不可小於零!!");
                //    //    }
                //    //}
                //}

                if (!viewModel.BySelf.HasValue)
                {
                    ModelState.AddModelError("BySelf", "請勾辦理人");
                }
                else if (viewModel.BySelf == Naming.Actor.ByOther)
                {
                    if (attachment == null)
                    {
                        ModelState.AddModelError("attachment", "請提供代辦委任書");
                    }
                }

                if (!viewModel.CauseForEnding.HasValue)
                {
                    ModelState.AddModelError("CauseForEnding", "請選擇終止原因");
                }
                else if (viewModel.CauseForEnding == Naming.CauseForEnding.其他)
                {
                    viewModel.Remark = viewModel.Remark.GetEfficientString();
                    if (viewModel.Remark == null)
                    {
                        ModelState.AddModelError("Remark", "請填入其他終止原因");
                    }
                }
                else if (viewModel.CauseForEnding == Naming.CauseForEnding.不宜運動)
                {
                    if (attachment == null)
                    {
                        ModelState.AddModelError("attachment", "請檢附醫生證明");
                    }
                }

                if (viewModel.OperationMode != Naming.OperationMode.快速終止)
                {

                    if (!(viewModel.CauseForEnding == Naming.CauseForEnding.轉讓第三人
                        || viewModel.CauseForEnding == Naming.CauseForEnding.合約到期轉新約
                        || viewModel.CauseForEnding == Naming.CauseForEnding.更改合約類型 
                        || item.TotalPaidAmount() <= 0))
                    {
                        viewModel.BankID = viewModel.BankID.GetEfficientString();
                        if (viewModel.BankID == null)
                        {
                            ModelState.AddModelError("BankID", "請輸入退款銀行代碼");
                        }

                        viewModel.BankAccount = viewModel.BankAccount.GetEfficientString();
                        if (viewModel.BankAccount == null)
                        {
                            ModelState.AddModelError("BankAccount", "請輸入退款銀行帳號");
                        }

                        if (bankAccountInfo == null)
                        {
                            ModelState.AddModelError("accountInfo", "請上傳帳戶存摺封面掃描圖片");
                        }
                    }
                }
            }
            else if (viewModel.Reason == "轉讓")
            {
                if (viewModel.UID == null || viewModel.UID.Length < 1 || viewModel.UID[0] <= 0)
                {
                    ModelState.AddModelError("UID", "請選擇上課學員!!");
                }
            }
            else if (viewModel.Reason == "展延")
            {
                if (!viewModel.MonthExtension.HasValue)
                {
                    ModelState.AddModelError("MonthExtension", "請選擇展延期間!!");
                }
                else if (viewModel.MonthExtension > 3)
                {
                    if (attachment == null)
                    {
                        ModelState.AddModelError("uploadFile", "展延期間３個月以上請提供證明文件!!");
                    }
                }
            }
            else if (viewModel.Reason == "轉點")
            {
                if (!viewModel.PriceID.HasValue)
                {
                    ModelState.AddModelError("PriceID", "請選擇課程單價!!");
                }
            }
            else if (viewModel.Reason == "轉換課程堂數")
            {
                if (viewModel.ContractLessonRegisterID == null || viewModel.ContractLessonRegisterID.Length < 1
                    || viewModel.SourcePriceID == null || viewModel.SourcePriceID.Length != viewModel.ContractLessonRegisterID.Length
                    || viewModel.TargetPriceID == null || viewModel.TargetPriceID.Length != viewModel.ContractLessonRegisterID.Length
                    || viewModel.TargetSubtotal == null || viewModel.TargetSubtotal.Length != viewModel.ContractLessonRegisterID.Length)
                {
                    ModelState.AddModelError("TargetSubtotal", "請輸入調整後堂數!!");
                }
                else
                {
                    for (int i = 0; i < viewModel.TargetSubtotal.Length; i++)
                    {
                        if(viewModel.TargetSubtotal[i] < 0)
                        {
                            ModelState.AddModelError("TargetSubtotal,{i}", "請輸入調整後堂數!!");
                        }
                    }

                    if(ModelState.IsValid)
                    {
                        Dictionary<int, decimal> checkSubtotal = new Dictionary<int, decimal>();

                        for (int i = 0; i < viewModel.ContractLessonRegisterID.Length; i++)
                        {
                            if (!viewModel.TargetSubtotal[i].HasValue)
                            {
                                continue;
                            }

                            if (!checkSubtotal.ContainsKey(viewModel.SourcePriceID[i].Value))
                            {
                                checkSubtotal[viewModel.SourcePriceID[i].Value] = 0;
                            }

                            RegisterLesson register = item.RegisterLessonContract.Where(r => r.RegisterID == viewModel.ContractLessonRegisterID[i])
                                                        .FirstOrDefault()?.RegisterLesson;

                            if (viewModel.SourcePriceID[i] != viewModel.TargetPriceID[i])
                            {
                                var exchangeItem = models.GetTable<LessonPriceExchange>().Where(x => x.SourceID == viewModel.SourcePriceID[i] && x.TargetID == viewModel.TargetPriceID[i])
                                        .FirstOrDefault();

                                if (exchangeItem == null)
                                {
                                    ModelState.AddModelError($"TargetSubtotal,{i}", "該課程不可轉換!!");
                                    break;
                                }
                                else if (exchangeItem.TargetPrice.BundleCount.HasValue
                                    && (viewModel.TargetSubtotal[i] % exchangeItem.TargetPrice.BundleCount) != 0)
                                {
                                    ModelState.AddModelError($"TargetSubtotal,{i}", $"調整後堂數需以{exchangeItem.TargetPrice.BundleCount}堂為單位!!");
                                    break;
                                }

                                checkSubtotal[viewModel.SourcePriceID[i].Value] += ((viewModel.TargetSubtotal[i] ?? 0) - (register?.RemainedLessonCount() ?? 0)) / exchangeItem.ExchangeRate;

                            }
                            else
                            {
                                if (register == null)
                                {
                                    ModelState.AddModelError($"TargetSubtotal,{i}", "請輸入正確調整後堂數!!");
                                    break;
                                }

                                checkSubtotal[viewModel.SourcePriceID[i].Value] += ((viewModel.TargetSubtotal[i] ?? 0) - register.RemainedLessonCount());
                            }

                        }

                        if (checkSubtotal.Values.Any(v => v != 0))
                        {
                            ModelState.AddModelError($"TargetSubtotal", "調整後堂數檢核不符!!");
                        }
                    }
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return null;
            }

            newItem = new CourseContract
            {
                AgentID = profile.UID,  //item.LessonPriceType.BranchStore.ManagerID.Value,
                CourseContractExtension = new CourseContractExtension
                {
                    BranchID = item.CourseContractExtension.BranchID,
                    Version = item.CourseContractExtension.Version,
                    SignOnline = viewModel.SignOnline,
                    UnitPriceAdjustmentType = item.CourseContractExtension.UnitPriceAdjustmentType,
                    CoursePlace = item.CourseContractExtension.CoursePlace,
                },
                SupervisorID = item.CourseContractExtension.BranchStore.ManagerID,
            };
            models.GetTable<CourseContract>().InsertOnSubmit(newItem);

            newItem.ContractType = item.ContractType;
            newItem.ContractDate = DateTime.Now;
            newItem.Subject = item.Subject;
            newItem.ValidFrom = item.ValidFrom;
            newItem.Expiration = item.Expiration;
            newItem.OwnerID = item.OwnerID;
            newItem.Lessons = item.Lessons;
            newItem.PriceID = item.PriceID;
            newItem.Remark = viewModel.Remark;
            newItem.FitnessConsultant = viewModel.FitnessConsultant.Value;
            newItem.TotalCost = item.TotalCost;
            newItem.CourseContractRevision = new CourseContractRevision
            {
                OriginalContract = item.ContractID,
                Reason = viewModel.Reason,
                RevisionNo = item.RevisionList.Count + 1,
                OperationMode = (int?)viewModel.OperationMode,
            };
            newItem.SequenceNo = newItem.CourseContractRevision.RevisionNo;
            newItem.ContractNo = item.ContractNo;   // + "-" + String.Format("{0:00}", newItem.CourseContractRevision.RevisionNo);
            if (attachment != null)
            {
                newItem.CourseContractRevision.Attachment = new Attachment
                {
                    StoredPath = attachment
                };
            }

            if (viewModel.Reason != "轉換體能顧問")
            {
                if (viewModel.Status.HasValue)
                {
                    newItem.ExecuteContractStatus(profile, (Naming.CourseContractStatus)viewModel.Status.Value, null);
                }
                else
                {
                    newItem.ExecuteContractStatus(profile, Naming.CourseContractStatus.待確認, null);
                    if (profile.IsManager())
                    {
                        newItem.ExecuteContractStatus(profile, Naming.CourseContractStatus.待簽名, null);
                    }
                }
            }

            switch (viewModel.Reason)
            {
                case "展延":

                    newItem.CourseContractMember.AddRange(item.CourseContractMember.Select(u => new CourseContractMember
                    {
                        UID = u.UID
                    }));

                    newItem.Expiration = newItem.Expiration.Value.AddMonths(viewModel.MonthExtension.Value);
                    newItem.CourseContractRevision.MonthExtension = viewModel.MonthExtension;
                    break;

                case "轉點":

                    newItem.CourseContractMember.AddRange(item.CourseContractMember.Select(u => new CourseContractMember
                    {
                        UID = u.UID
                    }));

                    var price = models.GetTable<LessonPriceType>().Where(p => p.PriceID == viewModel.PriceID).First();
                    newItem.PriceID = viewModel.PriceID.Value;
                    newItem.Lessons = item.RemainedLessonCount();
                    newItem.TotalCost = newItem.Lessons * price.ListPrice;
                    if (item.CourseContractType.GroupingLessonDiscount != null)
                    {
                        newItem.TotalCost = newItem.TotalCost * item.CourseContractType.GroupingLessonDiscount.GroupingMemberCount * item.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount / 100;
                    }
                    newItem.CourseContractExtension.BranchID = price.BranchID.Value;

                    break;

                case "轉讓":
                    newItem.OwnerID = viewModel.UID[0];
                    newItem.CourseContractMember.Clear();
                    newItem.CourseContractMember.Add(new CourseContractMember
                    {
                        UID = viewModel.UID[0]
                    });
                    break;

                case "終止":

                    newItem.CourseContractMember.AddRange(item.CourseContractMember.Select(u => new CourseContractMember
                    {
                        UID = u.UID
                    }));

                    newItem.CourseContractExtension.SettlementPrice = viewModel.SettlementPrice;
                    newItem.CourseContractRevision.BySelf = (int?)viewModel.BySelf;
                    newItem.CourseContractRevision.ProcessingFee = viewModel.ProcessingFee;
                    newItem.CourseContractRevision.CauseForEnding = (int?)viewModel.CauseForEnding;

                    newItem.CourseContractRevision.CourseContractTermination = new CourseContractTermination
                    {
                        BankAccount = viewModel.BankAccount,
                        BankID = viewModel.BankID,
                    };

                    if (bankAccountInfo != null)
                    {
                        newItem.CourseContractRevision.CourseContractTermination.Attachment = new Attachment
                        {
                            StoredPath = bankAccountInfo,
                        };
                    }

                    if (diagnosisPaper != null)
                    {
                        newItem.CourseContractRevision.Attachment = new Attachment
                        {
                            StoredPath = diagnosisPaper
                        };
                    }

                    if (viewModel.OperationMode == Naming.OperationMode.快速終止)
                    {
                        item.Subject = "已快速終止";
                        if (profile.IsManager())
                        {
                            newItem.CourseContractRevision.EnableContractAmendment(models, profile, Naming.CourseContractStatus.待確認);
                        }
                    }

                    break;

                case "轉換體能顧問":

                    newItem.CourseContractMember.AddRange(item.CourseContractMember.Select(u => new CourseContractMember
                    {
                        UID = u.UID
                    }));

                    newItem.FitnessConsultant = viewModel.FitnessConsultant.Value;
                    var work = models.GetTable<CoachWorkplace>().Where(w => w.CoachID == viewModel.FitnessConsultant).FirstOrDefault();
                    if (work != null)
                    {
                        newItem.CourseContractExtension.BranchID = work.BranchID;
                    }

                    newItem.CourseContractRevision.CourseContractRevisionItem = new CourseContractRevisionItem
                    {
                        FitnessConsultant = item.FitnessConsultant,
                        BranchID = item.CourseContractExtension.BranchID
                    };

                    if (profile.IsManager())
                    {
                        //newItem.SupervisorID = profile.UID;
                        newItem.CourseContractRevision.EnableContractAmendment(models, profile, null);
                    }
                    else
                    {
                        newItem.ExecuteContractStatus(profile, Naming.CourseContractStatus.待確認, null);
                    }
                    break;

                case "轉換課程堂數":

                    newItem.CourseContractMember.AddRange(item.CourseContractMember.Select(u => new CourseContractMember
                    {
                        UID = u.UID
                    }));

                    for (int i = 0; i < viewModel.ContractLessonRegisterID.Length; i++)
                    {
                        if (!viewModel.TargetSubtotal[i].HasValue || viewModel.TargetSubtotal[i] < 0)
                        {
                            continue;
                        }

                        RegisterLesson register = item.RegisterLessonContract
                                                .Where(r => r.RegisterID == viewModel.ContractLessonRegisterID[i])
                                                .FirstOrDefault()?.RegisterLesson;

                        newItem.CourseContractRevision.CourseContractLessonExchange.Add(
                            new CourseContractLessonExchange
                            {
                                TargetRegisterID = register?.RegisterID,
                                TargetPriceID = viewModel.TargetPriceID[i],
                                TargetSubtotal = viewModel.TargetSubtotal[i],
                                OriginalRemainedCount = register?.RemainedLessonCount() ?? 0,
                            });

                        models.SubmitChanges();
                    }

                    break;
            }

            models.SubmitChanges();

            await PushLineNotification(viewModel, controller, profile, newItem);

            return newItem;
        }

        private static async Task PushLineNotification(CourseContractViewModel viewModel, SampleController<UserProfile> controller, UserProfile profile, CourseContract newItem)
        {
            if (viewModel.Reason == "展延")
            {
                if (newItem.Status == (int)Naming.CourseContractStatus.待確認)
                {
                    if (newItem.CourseContractExtension.BranchStore.ManagerID.HasValue)
                    {
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyManagerToApproveExtend.cshtml", newItem);
                        jsonData.PushLineMessage();
                    }
                    if (profile.UID != newItem.CourseContractExtension.BranchStore.ViceManagerID
                        && newItem.CourseContractExtension.BranchStore.ViceManagerID.HasValue)
                    {
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyViceManagerToApproveExtend.cshtml", newItem);
                        jsonData.PushLineMessage();
                    }
                }
                else if (newItem.Status == (int)Naming.CourseContractStatus.待簽名)
                {
                    if (newItem.CourseContractExtension.SignOnline == true)
                    {
                        //item.CreateLineReadyToSignContract(models).PushLineMessage();
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyLearnerToSignExtend.cshtml", newItem);
                        jsonData.PushLineMessage();
                    }
                    else if (profile.UID != newItem.AgentID)
                    {
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyCoachToSignExtend.cshtml", newItem);
                        jsonData.PushLineMessage();
                    }
                }
            }
            else if (viewModel.Reason == "終止")
            {
                if (newItem.Status == (int)Naming.CourseContractStatus.待確認)
                {
                    if (viewModel.OperationMode == Naming.OperationMode.快速終止)
                    {
                        if (newItem.CourseContractExtension.BranchStore.ManagerID.HasValue)
                        {
                            var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyManagerToApproveQuickTermination.cshtml", newItem);
                            jsonData.PushLineMessage();
                        }
                        if (profile.UID != newItem.CourseContractExtension.BranchStore.ViceManagerID
                            && newItem.CourseContractExtension.BranchStore.ViceManagerID.HasValue)
                        {
                            var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyViceManagerToApproveQuickTermination.cshtml", newItem);
                            jsonData.PushLineMessage();
                        }
                    }
                    else
                    {
                        if (newItem.CourseContractExtension.BranchStore.ManagerID.HasValue)
                        {
                            var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyManagerToApproveTermination.cshtml", newItem);
                            jsonData.PushLineMessage();
                        }
                        if (profile.UID != newItem.CourseContractExtension.BranchStore.ViceManagerID
                            && newItem.CourseContractExtension.BranchStore.ViceManagerID.HasValue)
                        {
                            var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyViceManagerToApproveTermination.cshtml", newItem);
                            jsonData.PushLineMessage();
                        }
                    }

                }
                else if (newItem.Status == (int)Naming.CourseContractStatus.待簽名)
                {
                    if (newItem.CourseContractExtension.SignOnline == true)
                    {
                        //item.CreateLineReadyToSignContract(models).PushLineMessage();
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyLearnerToSignTermination.cshtml", newItem);
                        jsonData.PushLineMessage();
                    }
                    else if (profile.UID != newItem.AgentID)
                    {
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyCoachToSignTermination.cshtml", newItem);
                        jsonData.PushLineMessage();
                    }
                }
            }
            else if (viewModel.Reason == "轉換體能顧問")
            {
                if (newItem.Status == (int)Naming.CourseContractStatus.待確認)
                {
                    if (newItem.CourseContractExtension.BranchStore.ManagerID.HasValue)
                    {
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyManagerToApproveAssignment.cshtml", newItem);
                        jsonData.PushLineMessage();
                    }
                    if (profile.UID != newItem.CourseContractExtension.BranchStore.ViceManagerID
                        && newItem.CourseContractExtension.BranchStore.ViceManagerID.HasValue)
                    {
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyViceManagerToApproveAssignment.cshtml", newItem);
                        jsonData.PushLineMessage();
                    }
                }
            }
            else if (viewModel.Reason == "轉換課程堂數")
            {
                if (newItem.Status == (int)Naming.CourseContractStatus.待確認)
                {
                    if (newItem.CourseContractExtension.BranchStore.ManagerID.HasValue)
                    {
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyManagerToApproveExchange.cshtml", newItem);
                        jsonData.PushLineMessage();
                    }
                   if (profile.UID != newItem.CourseContractExtension.BranchStore.ViceManagerID
                        && newItem.CourseContractExtension.BranchStore.ViceManagerID.HasValue)
                    {
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyViceManagerToApproveExchange.cshtml", newItem);
                        jsonData.PushLineMessage();
                    }
                }
                else if (newItem.Status == (int)Naming.CourseContractStatus.待簽名)
                {
                    if (newItem.CourseContractExtension.SignOnline == true)
                    {
                        //item.CreateLineReadyToSignContract(models).PushLineMessage();
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyLearnerToSignExchange.cshtml", newItem);
                        jsonData.PushLineMessage();
                    }
                    else if (profile.UID != newItem.AgentID)
                    {
                        var jsonData = await controller.RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyCoachToSignExchange.cshtml", newItem);
                        jsonData.PushLineMessage();
                    }
                }
            }
        }

        public static Payment EditPaymentForContract(this PaymentViewModel viewModel, HttpContext context)
        {
            var HttpContext = context;
            var models = (ModelSource<UserProfile>)context.Items["Models"];

            var item = models.GetTable<Payment>().Where(c => c.PaymentID == viewModel.PaymentID).FirstOrDefault();
            if (item != null)
            {
                viewModel.PayoffAmount = item.PayoffAmount;
                viewModel.PayoffDate = item.PayoffDate;
                viewModel.Status = item.Status;
                viewModel.HandlerID = item.HandlerID;
                viewModel.PaymentType = item.PaymentType;
                viewModel.InvoiceID = item.InvoiceID;
                viewModel.TransactionType = item.TransactionType;
                viewModel.BuyerReceiptNo = item.InvoiceItem.InvoiceBuyer.IsB2C() ? null : item.InvoiceItem.InvoiceBuyer.ReceiptNo;
                viewModel.Remark = item.Remark;
                viewModel.InvoiceNo = item.InvoiceItem.TrackCode + item.InvoiceItem.No;
            }
            else
            {
                viewModel.PayoffDate = DateTime.Today;
            }

            return item;
        }

        public static int GetInstallmentPeriodNo(this CourseContract contract,GenericManager<BFDataContext> models)
        {
            if(!contract.InstallmentID.HasValue)
            {
                return 0;
            }

            return models.GetTable<CourseContract>()
                .Where(c => c.InstallmentID == contract.InstallmentID)
                .Where(c => c.ContractID <= contract.ContractID)
                .Count();
        }

    }
}