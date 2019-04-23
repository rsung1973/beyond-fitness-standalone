using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using Newtonsoft.Json;

using CommonLib.MvcExtension;
using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Security.Authorization;
using WebHome.Properties;
using WebHome.Helper.BusinessOperation;

namespace WebHome.Controllers
{
    [Authorize]
    public class CourseContractController : SampleController<UserProfile>
    {
        // GET: CourseContract
        public ActionResult ContractIndex(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }

        public ActionResult ApplyAmendment(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }

        public ActionResult CreateContract()
        {
            var profile = HttpContext.GetUser();
            var item = profile.LoadInstance(models);

            return View(item);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult EditCourseContract(CourseContractViewModel viewModel,bool? viewOnly)
        {

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                viewModel.ContractType = item.ContractType;
                viewModel.ContractDate = item.ContractDate;
                viewModel.Subject = item.Subject;
                viewModel.ValidFrom = item.ValidFrom;
                viewModel.Expiration = item.Expiration;
                viewModel.OwnerID = item.OwnerID;
                viewModel.SequenceNo = item.SequenceNo;
                viewModel.Lessons = item.Lessons;
                viewModel.PriceID = item.PriceID;
                viewModel.Remark = item.Remark;
                viewModel.FitnessConsultant = item.FitnessConsultant;
                viewModel.Status = item.Status;
                viewModel.UID = item.CourseContractMember.Select(m => m.UID).ToArray();
                viewModel.BranchID = item.CourseContractExtension.BranchID;
                viewModel.Renewal = item.Renewal;
                if(item.InstallmentID.HasValue)
                {
                    viewModel.InstallmentPlan = true;
                    viewModel.Installments = item.ContractInstallment.Installments;
                }
            }

            ViewBag.ViewModel = viewModel;
            ViewBag.ViewOnly = viewOnly;
            return View("~/Views/CourseContract/Module/EditCourseContract.ascx", item);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult DeleteCourseContract(CourseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if(viewModel.KeyID!=null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            bool result = false;
            try
            {
                var item = models.DeleteAny<CourseContract>(d => d.ContractID == viewModel.ContractID);
                if (item != null)
                {
                    result = true;
                    ClearPreliminaryMember();
                }
            }
            catch(Exception ex)
            {
                Logger.Error(ex);
            }
            return Json(new { result });
        }

        public ActionResult ClearPreliminaryMember()
        {
            models.ExecuteCommand(@"
                        DELETE FROM UserProfile
                        FROM     UserProfile INNER JOIN
                                       UserRole ON UserProfile.UID = UserRole.UID
                        WHERE   (UserRole.RoleID = 11) 
                            AND (UserProfile.UID NOT IN
                               (SELECT  UID
                               FROM     CourseContractMember))
                            AND (UserProfile.UID NOT IN
                               (SELECT  UID
                               FROM     RegisterLesson))");

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);

        }



        public ActionResult ListContractMember(int[] uid,int? contractType,int? ownerID,bool? viewOnly)
        {
            IQueryable<UserProfile> items = models.GetTable<UserProfile>();
            if (uid != null)
            {
                items = items.Where(c => uid.Contains(c.UID));
                ViewBag.UseLearnerDiscount = models.CheckLearnerDiscount(uid);
            }
            else
            {
                items = items.Where(u => false);
                ViewBag.UseLearnerDiscount = false;
            }
            ViewBag.ContractType = contractType;
            ViewBag.OwnerID = ownerID;
            ViewBag.ViewOnly = viewOnly;
            return View("~/Views/CourseContract/Module/ContractMemberList.ascx", items);
        }

        public ActionResult SelectContractMember(CourseContractViewModel viewModel, int? referenceUID)
        {
            ViewBag.ViewModel = viewModel;
            ViewBag.ReferenceUID = referenceUID;
            return View("~/Views/CourseContract/Module/SelectContractMember.ascx");
        }


        public ActionResult InquireContractMember(String userName, int? referenceUID)
        {
            IEnumerable<UserProfile> items;
            userName = userName.GetEfficientString();
            if (userName == null)
            {
                this.ModelState.AddModelError("userName", "請輸學員名稱!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }
            else
            {
                items = models.GetTable<UserProfile>()
                    .Where(l => l.RealName.Contains(userName) || l.Nickname.Contains(userName))
                    .FilterByLearner(models, true)
                    .OrderBy(l => l.RealName);
            }

            ViewBag.ReferenceUID = referenceUID;
            return View("~/Views/CourseContract/Module/MemberSelector.ascx", items);
        }

        public ActionResult EditContractMember(ContractMemberViewModel viewModel,int? referenceUID)
        {
            ViewBag.ViewModel = viewModel;

            UserProfile item;
            if (referenceUID.HasValue)
            {
                item = models.GetTable<UserProfile>().Where(u => u.UID == referenceUID).FirstOrDefault();
                if (item != null)
                {
                    viewModel.Address = item.Address;
                    viewModel.EmergencyContactPhone = item.UserProfileExtension.EmergencyContactPhone;
                    viewModel.EmergencyContactPerson = item.UserProfileExtension.EmergencyContactPerson;
                    viewModel.Relationship = item.UserProfileExtension.Relationship;
                    viewModel.AdministrativeArea = item.UserProfileExtension.AdministrativeArea;
                }
            }
            else
            {
                item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();

                if (item != null)
                {
                    viewModel.Gender = item.UserProfileExtension.Gender;
                    viewModel.EmergencyContactPhone = item.UserProfileExtension.EmergencyContactPhone;
                    viewModel.EmergencyContactPerson = item.UserProfileExtension.EmergencyContactPerson;
                    viewModel.Relationship = item.UserProfileExtension.Relationship;
                    viewModel.AdministrativeArea = item.UserProfileExtension.AdministrativeArea;
                    viewModel.IDNo = item.UserProfileExtension.IDNo;
                    viewModel.Phone = item.Phone;
                    viewModel.Birthday = item.Birthday;
                    viewModel.AthleticLevel = item.UserProfileExtension.AthleticLevel;
                    viewModel.RealName = item.RealName;
                    viewModel.Address = item.Address;
                    viewModel.Nickname = item.Nickname;

                }
            }

            return View("~/Views/CourseContract/Module/EditContractMember.ascx");
        }

        public ActionResult CommitContractMember(ContractMemberViewModel viewModel)
        {
            var item = viewModel.CommitContractMember(this, out String alertMessage);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View("~/Views/Shared/ReportInputError.ascx");
                }
                else
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: alertMessage);
                }
            }

            return Json(new
            {
                result = true,
                UID = item.UID,
                RealName = item.RealName,
                OwnerID = viewModel.OwnerID == -1
                            ? item.UID
                            : viewModel.OwnerID.HasValue
                                ? viewModel.OwnerID
                                : (int?)null
            });
        }

        public ActionResult GetLessonPriceList(int branchID,int? duration)
        {
            var items = models.GetTable<LessonPriceType>().Where(l => l.BranchID == branchID);
            if (duration.HasValue)
                items = items.Where(l => !l.DurationInMinutes.HasValue || l.DurationInMinutes == duration);
            return Json(items.Select(l => new
            {
                l.PriceID,
                l.Description,
                l.LowerLimit,
                l.UpperBound,
                l.BranchID,
                l.ListPrice,
                l.DiscountedPrice,
                l.DurationInMinutes
            }), JsonRequestBehavior.AllowGet);
        }

        public ActionResult ListLessonPrice(int branchID, int? duration, Naming.LessonPriceFeature? feature,int? priceID)
        {

            var items = models.PromptEffectiveLessonPrice()
                .Where(l => l.BranchID == branchID);

            if (duration.HasValue)
                items = items.Where(l => !l.DurationInMinutes.HasValue || l.DurationInMinutes == duration);
            if(!feature.HasValue)
            {
                items = items.Where(l => !l.LessonPriceProperty.Any());
            }
            else
            {
                items = items.Where(l => !l.LessonPriceProperty.Any() || l.LessonPriceProperty.Any(p => p.PropertyID == (int)feature));
            }

            var profile = HttpContext.GetUser();
            if (profile.IsAssistant() || profile.IsManager() || profile.IsViceManager() || profile.IsOfficer())
            {

            }
            else
            {
                items = items.Where(p => p.SeriesID.HasValue);
            }

            if(priceID.HasValue)
            {
                items = items.Concat(models.GetTable<LessonPriceType>().Where(p => p.PriceID == priceID));
            }

            items = items.OrderBy(l => l.LowerLimit).ThenBy(l => l.PriceID);
            return View("~/Views/CourseContract/Module/LessonPriceList.ascx", items);
        }

        private Naming.CourseContractStatus checkInitialStatus(CourseContractViewModel viewModel,UserProfile profile)
        {
            if (profile.IsManager())
                return Naming.CourseContractStatus.待簽名;
            var item = models.GetTable<LessonPriceType>().Where(p => p.PriceID == viewModel.PriceID).First();
            if(item.LowerLimit.HasValue && viewModel.Lessons>=item.LowerLimit
                && (!item.UpperBound.HasValue || viewModel.Lessons<item.UpperBound)
                && String.IsNullOrEmpty(viewModel.Remark))
            {
                return Naming.CourseContractStatus.待簽名;
            }
            return Naming.CourseContractStatus.待確認;
        }

        public ActionResult CommitContract(CourseContractViewModel viewModel)
        {
            var item = viewModel.CommitCourseContract(this, out String alertMessage);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View("~/Views/Shared/ReportInputError.ascx");
                }
                else
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: alertMessage);
                }
            }

            return Json(new { result = true, status = item.Status, contractID = item.ContractID });
        }

        public ActionResult SaveContract(CourseContractViewModel viewModel)
        {
            var item = viewModel.SaveCourseContract(this, out String alertMessage);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View("~/Views/Shared/ReportInputError.ascx");
                }
                else
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: alertMessage);
                }
            }

            return Json(new { result = true });
        }

        public ActionResult CourseContractSummary()
        {
            var item = HttpContext.GetUser().LoadInstance(models);
            //IQueryable<LessonTime> items = models.GetTable<LessonTime>();
            //if (viewModel.CoachID.HasValue)
            //    items = items.Where(t => t.AttendingCoach == viewModel.CoachID);
            //if (viewModel.QueryStart.HasValue)
            //    items = items.Where(t => t.ClassTime >= viewModel.QueryStart && t.ClassTime < viewModel.QueryStart.Value.AddMonths(1));
            if (item.IsAssistant() || item.IsManager() || item.IsViceManager())
            {
                return View("~/Views/CourseContract/Module/CourseContractSummary.ascx", item);
            }
            else
            {
                return View("~/Views/CourseContract/Module/CourseContractSummaryCoachView.ascx", item);
            }
        }

        public ActionResult ContractTodoList(CourseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            IQueryable<CourseContract> items;
            UserProfile agent = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.AgentID).First();
            switch ((Naming.CourseContractStatus)viewModel.Status)
            {
                case Naming.CourseContractStatus.草稿:
                    items = models.GetContractInEditingByAgent(agent);
                    break;
                case Naming.CourseContractStatus.待確認:
                    items = models.GetContractToAllowByAgent(agent);
                    break;
                case Naming.CourseContractStatus.待審核:
                    items = models.GetContractToConfirmByAgent(agent);
                    break;
                case Naming.CourseContractStatus.待簽名:
                    items = models.GetContractToSignByAgent(agent);
                    break;
                default:
                    items = models.GetTable<CourseContract>().Where(c => false);
                    break;
            }

            return View("~/Views/CourseContract/Module/ContractTodoList.ascx", items);
        }

        public ActionResult ContractAmendmentTodoList(CourseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            IQueryable<CourseContractRevision> items;
            UserProfile agent = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.AgentID).First();
            switch ((Naming.CourseContractStatus)viewModel.Status)
            {
                //case Naming.CourseContractStatus.草稿:
                //    items = models.GetContractInEditingByAgent(agent);
                //    break;
                case Naming.CourseContractStatus.待確認:
                    items = models.GetAmendmentToAllowByAgent(agent);
                    break;
                case Naming.CourseContractStatus.待審核:
                    items = models.GetAmendmentToConfirmByAgent(agent);
                    break;
                case Naming.CourseContractStatus.待簽名:
                    items = models.GetAmendmentToSignByAgent(agent);
                    break;
                default:
                    items = models.GetTable<CourseContractRevision>().Where(c => false);
                    break;
            }

            return View("~/Views/CourseContract/Module/ContractAmendmentTodoList.ascx", items);
        }

        [AllowAnonymous]
        public ActionResult ViewContract(CourseContractViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
                return View("CourseContractView", item);
            else
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
        }

        [AllowAnonymous]
        public ActionResult ViewSampleContract()
        {
            return View("SampleCourseContractView");
        }

        [AllowAnonymous]
        public ActionResult ViewContractAmendment(CourseContractViewModel viewModel)
        {
            var item = models.GetTable<CourseContractRevision>().Where(c => c.RevisionID == viewModel.RevisionID).FirstOrDefault();
            if (item != null)
                return View("CourseContractAmendmentView", item);
            else
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
        }


        public ActionResult ContractSignatureView(CourseContractViewModel viewModel)
        {
            ViewResult result = (ViewResult)ViewContract(viewModel);
            if(result.Model is CourseContract)
            {
                ViewBag.ContractAction = "~/Views/CourseContract/Module/ConfirmSignature.ascx";
            }
            return result;
        }

        public ActionResult ContractAmendmentSignatureView(CourseContractViewModel viewModel)
        {
            ViewResult result = (ViewResult)ViewContractAmendment(viewModel);
            if (result.Model is CourseContractRevision)
            {
                ViewBag.ContractAction = "~/Views/CourseContract/Module/ConfirmAmendmentSignature.ascx";
            }
            return result;
        }


        public ActionResult SignContract(CourseContractViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
                return View("~/Views/CourseContract/Module/SignCourseContract.ascx", item);
            else
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
        }

        public ActionResult ApproveContract(CourseContractViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
                return View("~/Views/CourseContract/Module/ApproveCourseContract.ascx", item);
            else
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
        }

        public ActionResult ContractApprovalView(CourseContractViewModel viewModel)
        {
            ViewResult result = (ViewResult)ViewContract(viewModel);
            if (result.Model is CourseContract)
            {
                ViewBag.ContractAction = "~/Views/CourseContract/Module/ContractApproval.ascx";
            }
            return result;
        }

        public ActionResult ContractAllowanceView(CourseContractViewModel viewModel)
        {
            ViewResult result = (ViewResult)ViewContract(viewModel);
            if (result.Model is CourseContract)
            {
                //var profile = HttpContext.GetUser();
                //var item = (CourseContract)result.Model;
                //item.AgentID = profile.UID;
                //models.SubmitChanges();
                ViewBag.ContractAction = "~/Views/CourseContract/Module/ContractAllowance.ascx";
            }
            return result;
        }

        public ActionResult ContractAmendmentApprovalView(CourseContractViewModel viewModel)
        {
            ViewResult result = (ViewResult)ViewContractAmendment(viewModel);
            if (result.Model is CourseContractRevision)
            {
                var item = (CourseContractRevision)result.Model;
                var profile = HttpContext.GetUser();
                //item.CourseContract.AgentID = profile.UID;
                //models.SubmitChanges();
                ViewBag.ContractAgent = profile;
                ViewBag.ContractAction = "~/Views/CourseContract/Module/ContractAmendmentApproval.ascx";
            }
            return result;
        }

        public ActionResult EnableContract(CourseContractViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
                return View("~/Views/CourseContract/Module/EnableCourseContract.ascx", item);
            else
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
        }


        public ActionResult ExecuteContractStatus(CourseContractViewModel viewModel)
        {
            var profile = HttpContext.GetUser();
            var item = viewModel.ExecuteContractStatus(this, out String alertMessage);
            if (item != null)
            {
                return Json(new { result = true });
            }
            else
                return View("~/Views/Shared/JsAlert.ascx", model: alertMessage);
        }

        public ActionResult EnableContractStatus(CourseContractViewModel viewModel)
        {
            var profile = HttpContext.GetUser();
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                var pdfFile = item.MakeContractEffective(models, profile, Naming.CourseContractStatus.待審核);
                if (pdfFile == null)
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: "合約狀態錯誤，請重新檢查!!");
                }
                else
                {
                    return Json(new { result = true, pdf = pdfFile != null ? VirtualPathUtility.ToAbsolute("~/" + pdfFile.Replace(HttpRuntime.AppDomainAppPath, "")) : null });
                }
            }
            else
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
        }

        public ActionResult ConfirmSignature(CourseContractViewModel viewModel)
        {
            var item = viewModel.ConfirmContractSignature(this,out String alertMessage,out String pdfFile);

            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View("~/Views/Shared/ReportInputError.ascx");
                }
                else
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: alertMessage);
                }
            }

            return Json(new { result = true, pdf = pdfFile != null ? VirtualPathUtility.ToAbsolute("~/" + pdfFile.Replace(HttpRuntime.AppDomainAppPath, "")) : null });
        }

        public ActionResult ConfirmSignatureForAmendment(CourseContractViewModel viewModel, bool? extension)
        {
            var item = viewModel.ConfirmContractServiceSignature(this, out String alertMessage, out String pdfFile);

            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View("~/Views/Shared/ReportInputError.ascx");
                }
                else
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: alertMessage);
                }
            }

            return Json(new { result = true, pdf = pdfFile != null ? VirtualPathUtility.ToAbsolute("~/" + pdfFile.Replace(HttpRuntime.AppDomainAppPath, "")) : null });

        }

        public ActionResult EnableContractAmendment(CourseContractViewModel viewModel)
        {
            var item = viewModel.EnableContractAmendment(this, out String alertMessage);
            if (item != null)
            {
                return Json(new { result = true });
            }
            else
                return View("~/Views/Shared/JsAlert.ascx", model: alertMessage);
        }

        public ActionResult SignaturePanel(CourseContractSignatureViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/CourseContract/Module/SignaturePanel.ascx");
        }

        public ActionResult CommitSignature(CourseContractSignatureViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContractSignature>().Where(s => s.ContractID == viewModel.ContractID
                && s.UID == viewModel.UID && s.SignatureName == viewModel.SignatureName).FirstOrDefault();

            if (item == null)
            {
                item = new CourseContractSignature
                {
                    ContractID = viewModel.ContractID.Value,
                    UID = viewModel.UID.Value,
                    SignatureName = viewModel.SignatureName
                };
                models.GetTable<CourseContractSignature>().InsertOnSubmit(item);
            }

            item.Signature = viewModel.Signature;
            models.SubmitChanges();

            return Json(new { result = true });
        }

        public ActionResult CreateContractPdf(CourseContractViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                item.CreateContractPDF(true);
                return Json(new { result = true }, JsonRequestBehavior.AllowGet);
            }
            else
                return Json(new { result = false, message = "合約資料錯誤!!" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult CalcTotalCost(CourseContractViewModel viewModel)
        {
            var price = models.GetTable<LessonPriceType>().Where(p => p.PriceID == viewModel.PriceID).FirstOrDefault();
            if (price == null)
            {
                return Json(new { result = false,message = "請選擇課程單價" }, JsonRequestBehavior.AllowGet);
            }

            var typeItem = models.GetTable<CourseContractType>().Where(c => c.TypeID == viewModel.ContractType).FirstOrDefault();
            if (typeItem == null)
            {
                return Json(new { result = false, message = "請選擇合約名稱" }, JsonRequestBehavior.AllowGet);
            }

            if (viewModel.Lessons.HasValue)
            {
                GroupingLessonDiscount discount = typeItem.GroupingLessonDiscount;

                var totalCost = viewModel.Lessons * price.ListPrice;
                if(discount!=null)
                {
                    totalCost = totalCost * discount.GroupingMemberCount * discount.PercentageOfDiscount / 100;
                }

                return Json(new { result = true, totalCost = String.Format("{0:##,###,###,###}",totalCost) }, JsonRequestBehavior.AllowGet);
            }

            return Json(new { result = false, message = "" }, JsonRequestBehavior.AllowGet);

        }

        public ActionResult GetContractPdf(CourseContractViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                String pdfFile = item.CreateContractPDF();
                return File(pdfFile, "application/pdf");
            }
            else
                return Json(new { result = false, message = "合約資料錯誤!!" }, JsonRequestBehavior.AllowGet);
        }

        [AllowAnonymous]
        public ActionResult GetSampleContractPdf()
        {
            String pdfFile = Path.Combine(GlobalDefinition.ContractPdfPath, "SampleContract.pdf");
            String viewUrl = Settings.Default.HostDomain + VirtualPathUtility.ToAbsolute("~/CourseContract/ViewSampleContract") + "?pdf=1";
            viewUrl.ConvertHtmlToPDF(pdfFile, 20);
            return File(pdfFile, "application/pdf");
        }

        public ActionResult GetContractAmendmentPdf(CourseContractViewModel viewModel)
        {
            if(viewModel.KeyID!=null)
            {
                viewModel.RevisionID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContractRevision>().Where(c => c.RevisionID == viewModel.RevisionID).FirstOrDefault();
            if (item != null)
            {
                String pdfFile = item.CreateContractAmendmentPDF();
                return File(pdfFile, "application/pdf");
            }
            else
                return Json(new { result = false, message = "合約資料錯誤!!" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult InquireContract(CourseContractQueryViewModel viewModel)
        {
            IQueryable<CourseContract> items = models.GetTable<CourseContract>();
                //.Where(c => c.SequenceNo == 0);

            var profile = HttpContext.GetUser();

            Expression<Func<CourseContract, bool>> queryExpr = c => false;
            bool hasConditon = false;

            viewModel.RealName = viewModel.RealName.GetEfficientString();
            if (viewModel.RealName != null)
            {
                hasConditon = true;
                queryExpr = queryExpr.Or(c => c.CourseContractMember.Any(m => m.UserProfile.RealName.Contains(viewModel.RealName) || m.UserProfile.Nickname.Contains(viewModel.RealName)));
            }

            if(!hasConditon)
            {
                viewModel.ContractNo = viewModel.ContractNo.GetEfficientString();
                if (viewModel.ContractNo != null)
                {
                    hasConditon = true;
                    var no = viewModel.ContractNo.Split('-');
                    int seqNo;
                    if (no.Length > 1)
                    {
                        int.TryParse(no[1], out seqNo);
                        queryExpr = queryExpr.Or(c => c.ContractNo.StartsWith(no[0])
                            && c.SequenceNo == seqNo);
                    }
                    else
                    {
                        queryExpr = queryExpr.Or(c => c.ContractNo.StartsWith(viewModel.ContractNo));
                    }
                }
            }


            if (!hasConditon)
            {
                if (viewModel.FitnessConsultant.HasValue)
                {
                    hasConditon = true;
                    queryExpr = queryExpr.Or(c => c.FitnessConsultant == viewModel.FitnessConsultant);
                }
            }

            if (!hasConditon)
            {
                if (viewModel.BranchID.HasValue)
                {
                    hasConditon = true;
                    queryExpr = queryExpr.Or(c => c.CourseContractExtension.BranchID == viewModel.BranchID);
                }
            }

            if (!hasConditon)
            {
                if (profile.IsAssistant() || profile.IsOfficer())
                {

                }
                else if (profile.IsManager() || profile.IsViceManager())
                {
                    var coaches = profile.GetServingCoachInSameStore(models);
                    items = items.Join(coaches, c => c.FitnessConsultant, h => h.CoachID, (c, h) => c);
                }
                else if (profile.IsCoach())
                {
                    items = items.Where(c => c.FitnessConsultant == profile.UID);
                }
            }

            if (hasConditon)
            {
                items = items.Where(queryExpr);
            }

            if (viewModel.Status.HasValue)
                items = items.Where(c => c.Status == viewModel.Status);

            if(viewModel.ContractType.HasValue)
                items = items.Where(c => c.ContractType == viewModel.ContractType);

            if (viewModel.ContractDateFrom.HasValue)
                items = items.Where(c => c.ContractDate >= viewModel.ContractDateFrom);

            if (viewModel.ContractDateTo.HasValue)
                items = items.Where(c => c.ContractDate < viewModel.ContractDateTo.Value.AddDays(1));

            return View("~/Views/CourseContract/Module/ContractQueryList.ascx", items);
        }

        public ActionResult InquireContractForAmendment(CourseContractQueryViewModel viewModel)
        {
            IQueryable<CourseContract> items = models.GetTable<CourseContract>()
                    .Where(c => c.Status == (int)Naming.CourseContractStatus.已生效
                        || c.Status == (int)Naming.CourseContractStatus.已過期)
                    .Where(c => c.SequenceNo == 0);

            bool hasCondition = false;

            viewModel.RealName = viewModel.RealName.GetEfficientString();
            if (viewModel.RealName != null)
            {
                items = items.Where(c => c.CourseContractMember.Any(m => m.UserProfile.RealName.Contains(viewModel.RealName) || m.UserProfile.Nickname.Contains(viewModel.RealName)));
                hasCondition = true;
            }

            viewModel.ContractNo = viewModel.ContractNo.GetEfficientString();
            if (viewModel.ContractNo != null)
            {
                hasCondition = true;
                var no = viewModel.ContractNo.Split('-');
                int seqNo;
                if (no.Length > 1)
                {
                    int.TryParse(no[1], out seqNo);
                    items = items.Where(c => c.ContractNo.StartsWith(no[0])
                        && c.SequenceNo == seqNo);
                }
                else
                {
                    items = items.Where(c => c.ContractNo.StartsWith(viewModel.ContractNo));
                }
            }

            if(!hasCondition)
            {
                return View("~/Views/Shared/JsAlert.ascx",model:"請輸入查詢條件!!");
            }

            return View("~/Views/CourseContract/Module/ContractQueryAmendmentList.ascx", items);

        }

        public ActionResult ListAmendment(CourseContractViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                return View("~/Views/CourseContract/Module/ContractAmendment.ascx", item);
            }
            else
                return Json(new { result = false, message = "合約資料錯誤!!" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult AmendContract(CourseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                return View("~/Views/CourseContract/Module/ApplyAmendment.ascx", item);
            }
            else
                return Json(new { result = false, message = "合約資料錯誤!!" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult CommitAmendment(CourseContractViewModel viewModel)
        {
            var item = viewModel.CommitContractService(this, out String alertMessage);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View("~/Views/Shared/ReportInputError.ascx");
                }
                else
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: alertMessage);
                }
            }

            return Json(new { result = true, status = item.Status });
        }

        private void assignDataRow(DataTable table, CourseContract item)
        {
            var r = table.NewRow();
            r[0] = item.ContractNo();
            r[1] = item.CourseContractRevision != null ? item.CourseContractRevision.SourceContract.CourseContractExtension.BranchStore.BranchName : item.CourseContractExtension.BranchStore.BranchName;
            r[2] = item.ServingCoach.UserProfile.FullName();
            if (item.CourseContractType.IsGroup == true)
            {
                r[3] = String.Join("/", item.CourseContractMember.Select(m => m.UserProfile).ToArray().Select(u => u.FullName()));
            }
            else
            {
                r[3] = item.ContractOwner.FullName();
            }
            r[4] = String.Format("{0:yyyy/MM/dd}", item.EffectiveDate);
            r[5] = String.Format("{0:yyyy/MM/dd}", item.Expiration);
            r[6] = item.CourseContractType.TypeName + "("
                + item.LessonPriceType.DurationInMinutes + " 分鐘)";
            if (item.SequenceNo == 0)
            {
                if (item.Status >= (int)Naming.CourseContractStatus.已生效)
                    r[7] = item.RemainedLessonCount();
                r[8] = item.Lessons;
                r[9] = item.TotalCost;
            }


            //if(item.Status <= (int)Naming.CourseContractStatus.已生效)
            //    r[9] =  item.TotalCost;

            var originalPrice = item.OriginalSeriesPrice();
            r[10] = originalPrice != null ? originalPrice.ListPrice : item.LessonPriceType.ListPrice;
            r[11] = item.LessonPriceType.ListPrice;
            var revision = item.CourseContractRevision;
            r[12] = revision == null ? "新合約" : revision.Reason;
            r[13] = ((Naming.ContractQueryStatus)item.Status).ToString();

            r[14] = item.Remark;
            if (item.SequenceNo == 0)
            {
                if (item.Status >= (int)Naming.CourseContractStatus.已生效)
                    r[15] = item.UnfinishedLessonCount();
                r[16] = item.TotalPaidAmount();
            }
            r[17] = String.Format("{0:yyyy/MM/dd}", item.ValidTo);
            r[18] = item.TotalAllowanceAmount();

            table.Rows.Add(r);

        }

        public ActionResult CreateContractQueryXlsx(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireContract(viewModel);
            IQueryable<CourseContract> items = (IQueryable<CourseContract>)result.Model;

            DataTable table = new DataTable();

            table.Columns.Add(new DataColumn("合約編號", typeof(String)));
            table.Columns.Add(new DataColumn("分店", typeof(String)));
            table.Columns.Add(new DataColumn("體能顧問", typeof(String)));
            table.Columns.Add(new DataColumn("學員姓名", typeof(String)));
            table.Columns.Add(new DataColumn("生效日期", typeof(String)));
            table.Columns.Add(new DataColumn("合約迄日", typeof(String)));
            table.Columns.Add(new DataColumn("合約名稱", typeof(String)));
            table.Columns.Add(new DataColumn("剩餘堂數", typeof(int)));
            table.Columns.Add(new DataColumn("購買堂數", typeof(int)));
            table.Columns.Add(new DataColumn("合約總金額", typeof(int)));
            table.Columns.Add(new DataColumn("單堂原價", typeof(int)));
            table.Columns.Add(new DataColumn("課程單價", typeof(int)));
            table.Columns.Add(new DataColumn("服務項目", typeof(String)));
            table.Columns.Add(new DataColumn("狀態", typeof(String)));
            table.Columns.Add(new DataColumn("備註", typeof(String)));
            table.Columns.Add(new DataColumn("未完成堂數", typeof(int)));
            table.Columns.Add(new DataColumn("已收金額", typeof(int)));
            table.Columns.Add(new DataColumn("合約完成日", typeof(String)));
            table.Columns.Add(new DataColumn("已發生折讓總額", typeof(decimal)));

            foreach (var item in items)
            {
                assignDataRow(table, item);
                foreach (var r in item.RevisionList)
                {
                    assignDataRow(table, r.CourseContract);
                }
            }


            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename=({1:yyyy-MM-dd HH-mm-ss}){0}", HttpUtility.UrlEncode("ContractDetails.xlsx"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                table.TableName = "合約列表";
                ds.Tables.Add(table);

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        public ActionResult LoadContract(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireContract(viewModel);
            IQueryable<CourseContract> items = (IQueryable<CourseContract>)result.Model;

            return Json(new
            {
                result = true,
                data = items.ToArray()
                .Select(c => new { ContractNo = c.ContractNo(), c.TotalCost, c.Installment })
            }, JsonRequestBehavior.AllowGet);

        }

        public ActionResult LoadInstallmentPlan(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/CourseContract/Module/InstallmentPlan.ascx");
        }

    }
}