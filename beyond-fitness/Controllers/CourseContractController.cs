using System;
using System.Collections.Generic;
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
using System.Data;

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
            }

            ViewBag.ViewModel = viewModel;
            ViewBag.ViewOnly = viewOnly;
            return View("~/Views/CourseContract/Module/EditCourseContract.ascx", item);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult DeleteCourseContract(int contractID)
        {
            bool result = false;
            try
            {
                var item = models.DeleteAny<CourseContract>(d => d.ContractID == contractID);
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
                    .Where(l => l.UserRole.Any(r=>r.RoleID==(int)Naming.RoleID.Learner 
                            || r.RoleID==(int)Naming.RoleID.Preliminary))
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
            ViewBag.ViewModel = viewModel;

            viewModel.IDNo = viewModel.IDNo.GetEfficientString();
            if (viewModel.IDNo == null)
            {
                if (viewModel.CurrentTrial != 1)
                {
                    ModelState.AddModelError("IDNo", "請輸入身份證字號/護照號碼!!");
                }
            }
            else if (Regex.IsMatch(viewModel.IDNo,"[A-Za-z]\\d{9}") && !viewModel.IDNo.CheckIDNo())
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
                    ModelState.AddModelError("Birthday", "請輸入生日!!");
                }

                if (String.IsNullOrEmpty(viewModel.AdministrativeArea))
                {
                    ModelState.AddModelError("AdministrativeArea", "請選擇縣市!!");
                }
                if (String.IsNullOrEmpty(viewModel.Address))
                {
                    ModelState.AddModelError("Address", "請輸入居住地址!!");
                }
                if (String.IsNullOrEmpty(viewModel.EmergencyContactPerson))
                {
                    ModelState.AddModelError("EmergencyContactPerson", "請輸入緊急聯絡人!!");
                }
                if (String.IsNullOrEmpty(viewModel.Relationship))
                {
                    ModelState.AddModelError("Relationship", "請選擇緊急聯絡人關係!!");
                }
                if (String.IsNullOrEmpty(viewModel.EmergencyContactPhone))
                {
                    ModelState.AddModelError("EmergencyContactPhone", "請輸入緊急聯絡人電話!!");
                }

                viewModel.RoleID = Naming.RoleID.Learner;
            }
            else
            {
                viewModel.RoleID = Naming.RoleID.Preliminary;
            }

            if (String.IsNullOrEmpty(viewModel.RealName))
            {
                ModelState.AddModelError("RealName", "請輸入學員姓名!!");
            }

            viewModel.Phone = viewModel.Phone.GetEfficientString();
            if (String.IsNullOrEmpty(viewModel.Phone))
            {
                ModelState.AddModelError("Phone", "請輸聯絡電話!!");
            }

            if (String.IsNullOrEmpty(viewModel.Gender))
            {
                ModelState.AddModelError("Gender", "請選擇性別!!");
            }
            if (!viewModel.AthleticLevel.HasValue)
            {
                ModelState.AddModelError("AthleticLevel", "請選擇是否為運動員!!");
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            viewModel.Email = viewModel.Email.GetEfficientString();
            if (viewModel.Email != null && item != null && item.LevelID == (int)Naming.MemberStatus.已註冊)
            {
                if (item.PID != viewModel.Email && models.EntityList.Any(u => u.PID == viewModel.Email))
                {
                    ModelState.AddModelError("PID", "您的Email已經是註冊使用者!!");
                }
                else
                {
                    item.PID = viewModel.Email;
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            if (item == null)
            {
                item = models.CreateLearner(viewModel);
                viewModel.UID = item.UID;
            }

            item.RealName = viewModel.RealName;
            item.Phone = viewModel.Phone;
            item.Address = viewModel.Address;
            if(viewModel.Birthday.HasValue)
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
            if(viewModel.CurrentTrial != 1)
            {
                models.ExecuteCommand("update UserRole set RoleID={0} where UID={1} and RoleID={2} ", (int)Naming.RoleID.Learner, item.UID, (int)Naming.RoleID.Preliminary);
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

            var items = models.GetTable<LessonPriceType>().Where(l => l.Status == (int)Naming.LessonSeriesStatus.已啟用)
                .Where(l => l.BranchID == branchID
                && (l.LowerLimit.HasValue && (!l.SeriesID.HasValue || l.CurrentPriceSeries.Status == (int)Naming.LessonSeriesStatus.已啟用)));

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
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            LessonPriceType lessonPrice;
            validateContractApplication(viewModel, out lessonPrice);
            if (!viewModel.Lessons.HasValue || viewModel.Lessons < 1)
            {
                ModelState.AddModelError("Lessons", "請輸入購買堂數!!");
            }

            if (lessonPrice != null && !lessonPrice.BranchStore.ManagerID.HasValue)
            {
                ModelState.AddModelError("BranchID", "該分店未指定店長!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            CourseContract item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                if (item.Status != (int)Naming.CourseContractStatus.草稿)
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: "合約狀態錯誤，請重新檢查!!");
                }
            }

            item = models.InitiateCourseContract(viewModel, profile, lessonPrice);

            return Json(new { result = true, status = item.Status, contractID = item.ContractID });
        }

        private void markContractNo(CourseContract item)
        {
            if (item.ContractNo == null)
            {
                //var items = models.GetTable<CourseContract>().Where(c => c.EffectiveDate >= DateTime.Today
                //        && c.Status >= (int)Naming.CourseContractStatus.待審核);
                long seqNo = models.ExecuteQuery<long>("select next value for CourseContractNoSeq").First();
                item.ContractNo = item.CourseContractType.ContractCode + String.Format("{0:yyyyMMdd}", DateTime.Today) + String.Format("{0:0000}", seqNo % 10000);
                //item.ContractNo = item.CourseContractType.ContractCode + String.Format("{0:yyyyMMdd}", DateTime.Today) + String.Format("{0:0000}", (item.ContractID - 4999) % 10000);
                models.SubmitChanges();
            }
        }

        public ActionResult SaveContract(CourseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            LessonPriceType lessonPrice;
            validateContractApplication(viewModel,out lessonPrice);

            if (lessonPrice != null && !lessonPrice.BranchStore.ManagerID.HasValue)
            {
                ModelState.AddModelError("BranchID", "該分店未指定店長!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item == null)
            {
                item = new CourseContract
                {
                    Status = (int)Naming.CourseContractStatus.草稿,
                    AgentID = profile.UID, //lessonPrice.BranchStore.ManagerID.Value,
                    CourseContractExtension = new Models.DataEntity.CourseContractExtension
                    {
                        BranchID = lessonPrice.BranchID.Value
                    }
                };

                executeContractStatus(profile, item, Naming.CourseContractStatus.草稿, null);
                models.GetTable<CourseContract>().InsertOnSubmit(item);
            }
            else
            {
                if(item.Status!= (int)Naming.CourseContractStatus.草稿)
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: "合約狀態錯誤，請重新檢查!!");
                }
            }

            item.ContractType = viewModel.ContractType.Value;
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

            item.TotalCost = item.Lessons * item.LessonPriceType.ListPrice;
            if (item.CourseContractType.GroupingLessonDiscount != null)
            {
                item.TotalCost = item.TotalCost * item.CourseContractType.GroupingLessonDiscount.GroupingMemberCount * item.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount / 100;
            }
            models.SubmitChanges();

            return Json(new { result = true });
        }

        private void validateContractApplication(CourseContractViewModel viewModel,out LessonPriceType lessonPrice)
        {
            lessonPrice = null;
            if (!viewModel.ContractType.HasValue)
            {
                ModelState.AddModelError("ContractType", "請選擇合約名稱!!");
            }

            if (!viewModel.Renewal.HasValue)
            {
                ModelState.AddModelError("Renewal", "請選擇是否為舊學員續約!!");
            }

            if (!viewModel.PriceID.HasValue)
            {
                ModelState.AddModelError("PriceID", "請選擇課程單價!!");
            }
            else
            {
                lessonPrice = models.GetTable<LessonPriceType>().Where(l => l.PriceID == viewModel.PriceID).FirstOrDefault();
            }
            if (!viewModel.FitnessConsultant.HasValue)
            {
                ModelState.AddModelError("FitnessConsultant", "請選擇體能顧問!!");
            }
            else
            {
                if (!models.GetTable<ServingCoach>().Any(s => s.CoachID == viewModel.FitnessConsultant
                     && s.UserProfile.UserProfileExtension.Signature != null))
                {
                    ModelState.AddModelError("FitnessConsultant", "體能顧問未建立簽名檔!!");
                }
            }

            if (!viewModel.OwnerID.HasValue)
            {
                ModelState.AddModelError("OwnerID", "請設定主簽約人!!");
            }
            else if (viewModel.UID == null || viewModel.UID.Length < 1)
            {
                ModelState.AddModelError("OwnerID", "請設定學員!!");
            }
            else if ((viewModel.ContractType == 1 && viewModel.UID.Length != 1)
                || (viewModel.ContractType == 3 && viewModel.UID.Length != 2)
                || (viewModel.ContractType == 4 && viewModel.UID.Length != 3))
            {
                ModelState.AddModelError("OwnerID", "學員數與合約不符!!");
            }
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
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
                return View("~/Views/CourseContract/Module/SignCourseContract.ascx", item);
            else
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
        }

        public ActionResult ApproveContract(CourseContractViewModel viewModel)
        {
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
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
                return View("~/Views/CourseContract/Module/EnableCourseContract.ascx", item);
            else
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
        }


        public ActionResult ExecuteContractStatus(CourseContractViewModel viewModel)
        {
            var profile = HttpContext.GetUser();
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                if (executeContractStatus(profile, item, (Naming.CourseContractStatus)viewModel.Status.Value, viewModel.FromStatus))
                {
                    if (viewModel.Drawback == true)
                    {
                        item.ContractNo = null;
                        models.DeleteAllOnSubmit<CourseContractSignature>(s => s.ContractID == item.ContractID);
                    }
                    models.SubmitChanges();

                    return Json(new { result = true });
                }
                else
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: "合約狀態錯誤，請重新檢查!!");
                }
            }
            else
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
        }

        private bool executeContractStatus(UserProfile profile, CourseContract item, Naming.CourseContractStatus status, Naming.CourseContractStatus? fromStatus, bool updateAgent = true)
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
            if (updateAgent)
                item.AgentID = profile.UID;

            return true;

        }

        public ActionResult EnableContractStatus(CourseContractViewModel viewModel)
        {
            var profile = HttpContext.GetUser();
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                var pdfFile = makeContractEffective(profile, item, Naming.CourseContractStatus.待審核);
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

        private String makeContractEffective(UserProfile profile, CourseContract item,Naming.CourseContractStatus fromStatus)
        {
            if (!executeContractStatus(profile, item, Naming.CourseContractStatus.已生效, fromStatus))
                return null;

            var groupLesson = new GroupingLesson { };
            var table = models.GetTable<RegisterLesson>();

            foreach (var m in item.CourseContractMember)
            {
                if (item.RegisterLessonContract.Any(r => r.RegisterLesson.UID == m.UID))
                    continue;

                var lesson = new RegisterLesson
                {
                    ClassLevel = item.PriceID,
                    RegisterDate = DateTime.Now,
                    Lessons = item.Lessons.Value,
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
                        ContractID = item.ContractID
                    }
                };

                if (item.CourseContractType.ContractCode == "CFA")
                {
                    lesson.GroupingMemberCount = 1;
                    lesson.GroupingLesson = new GroupingLesson { };
                }
                else
                {
                    lesson.GroupingLesson = groupLesson;
                }

                table.InsertOnSubmit(lesson);
            }

            models.SubmitChanges();

            foreach (var m in item.CourseContractMember)
            {
                models.ExecuteCommand(@"
                        UPDATE UserRole
                        SET        RoleID = {2}
                        WHERE   (UID = {0}) AND (RoleID = {1})", m.UID, (int)Naming.RoleID.Preliminary, (int)Naming.RoleID.Learner);

                models.ExecuteCommand(@"
                        update UserProfileExtension set CurrentTrial = null where UID = {0}", m.UID);
            }

            var pdfFile = item.CreateContractPDF();
            return pdfFile;
        }

        public ActionResult ConfirmSignature(CourseContractViewModel viewModel, bool? extension, bool? booking, bool? cancel)
        {
            var profile = HttpContext.GetUser();
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                var owner = item.CourseContractMember.Where(m => m.UID == item.OwnerID).First();

                if (item.CourseContractType.ContractCode == "CFA")
                {
                    if (owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 3)
                    {
                        return View("~/Views/Shared/JsAlert.ascx", model: "未完成簽名!!");
                    }
                }
                else
                {

                    if (owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 2)
                    {
                        return View("~/Views/Shared/JsAlert.ascx", model: "未完成簽名!!");
                    }

                    if (item.CourseContractType.IsGroup == true)
                    {
                        if (item.CourseContractMember.Any(m => m.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 2))
                        {
                            return View("~/Views/Shared/JsAlert.ascx", model: "未完成簽名!!");
                        }

                        foreach (var m in item.CourseContractMember)
                        {
                            if (m.UserProfile.CurrentYearsOld() < 18 && owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Guardian") && s.Signature != null) < 2)
                            {
                                return View("~/Views/Shared/JsAlert.ascx", model: "家長/監護人未完成簽名!!");
                            }
                        }
                    }
                }

                if (extension != true || booking != true || cancel != true)
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: "請勾選合約聲明!!");
                }

                if (!executeContractStatus(profile, item, Naming.CourseContractStatus.待審核, Naming.CourseContractStatus.待簽名))
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: "合約狀態錯誤，請重新檢查!!");
                }

                item.EffectiveDate = DateTime.Now;
                //item.ValidFrom = DateTime.Today;
                //item.Expiration = DateTime.Today.AddMonths(18);

                models.SubmitChanges();

                markContractNo(item);
                //do
                //{
                //    try
                //    {
                //    }
                //    catch (Exception ex)
                //    {
                //        Logger.Error(ex);
                //    }
                //} while (item.ContractNo == null);

                String pdfFile = null;

                if(item.ContractAgent.IsManager() /*item.ServingCoach.UserProfile.IsManager()*/)
                {
                    pdfFile = makeContractEffective(profile, item, Naming.CourseContractStatus.待審核);
                }

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

                return Json(new { result = true, pdf = pdfFile != null ? VirtualPathUtility.ToAbsolute("~/" + pdfFile.Replace(HttpRuntime.AppDomainAppPath, "")) : null });

            }
            else
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
        }

        public ActionResult ConfirmSignatureForAmendment(CourseContractViewModel viewModel, bool? extension)
        {
            var profile = HttpContext.GetUser();
            var item = models.GetTable<CourseContractRevision>().Where(c => c.RevisionID == viewModel.RevisionID).FirstOrDefault();
            if (item != null)
            {
                CourseContract contract = item.CourseContract;
                var owner = contract.CourseContractMember.Where(m => m.UID == contract.OwnerID).First();

                if (contract.CourseContractType.ContractCode == "CFA")
                {
                    if (owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 1)
                    {
                        return View("~/Views/Shared/JsAlert.ascx", model: "未完成簽名!!");
                    }
                }
                else
                {

                    if (owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 1)
                    {
                        return View("~/Views/Shared/JsAlert.ascx", model: "未完成簽名!!");
                    }

                    //if (contract.CourseContractType.IsGroup == true)
                    //{
                    //    if (contract.CourseContractMember.Any(m => m.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 1))
                    //    {
                    //        return View("~/Views/Shared/JsAlert.ascx", model: "未完成簽名!!");
                    //    }

                    //    foreach (var m in contract.CourseContractMember)
                    //    {
                    //        if (m.UserProfile.CurrentYearsOld() < 18 && owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Guardian") && s.Signature != null) < 1)
                    //        {
                    //            return View("~/Views/Shared/JsAlert.ascx", model: "家長/監護人未完成簽名!!");
                    //        }
                    //    }
                    //}
                }

                if (extension != true )
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: "請勾選合約聲明!!");
                }

                if (!enableContractAmendment(profile, item))
                {
                    return View("~/Views/Shared/JsAlert.ascx", model: "服務狀態錯誤，請重新檢查!!");
                }

                var pdfFile = item.CreateContractAmendmentPDF(true);

                String contractPDF = pdfFile.Replace(HttpRuntime.AppDomainAppPath, "");
                return Json(new { result = true, pdf = VirtualPathUtility.ToAbsolute("~/" + contractPDF) });
            }
            else
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
        }

        public ActionResult EnableContractAmendment(CourseContractViewModel viewModel)
        {
            var profile = HttpContext.GetUser();
            var item = models.GetTable<CourseContractRevision>().Where(c => c.RevisionID == viewModel.RevisionID).FirstOrDefault();
            if (item != null)
            {
                enableContractAmendment(profile, item);
                return Json(new { result = true });
            }
            else
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
        }

        private bool enableContractAmendment(UserProfile profile, CourseContractRevision item)
        {
            if (!executeContractStatus(profile, item.CourseContract, Naming.CourseContractStatus.已生效, Naming.CourseContractStatus.待簽名, false))
                return false;

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
                    models.SubmitChanges();
                    break;
                case "轉點":
                    item.ProcessContractMigration();
                    break;
                case "轉讓":
                    item.ProcessContractTranference();
                    break;
                case "終止":
                    item.ProcessContractTermination(profile);
                    break;
            }

            return true;

        }

        public ActionResult SignaturePanel(CourseContractSignatureViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/CourseContract/Module/SignaturePanel.ascx");
        }

        public ActionResult CommitSignature(CourseContractSignatureViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

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
                    .Where(c => c.Status == (int)Naming.CourseContractStatus.已生效)
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
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "合約資料錯誤!!" }, JsonRequestBehavior.AllowGet);
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
                if (!viewModel.SettlementPrice.HasValue)
                    ModelState.AddModelError("SettlementPrice", "請填入課程單價!!");
            }
            else if (viewModel.Reason == "轉讓")
            {
                if (viewModel.UID == null || viewModel.UID.Length < 1)
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
            }
            else if (viewModel.Reason == "轉點")
            {
                if (!viewModel.PriceID.HasValue)
                {
                    ModelState.AddModelError("PriceID", "請選擇課程單價!!");
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            newItem = new CourseContract
            {
                AgentID = profile.UID,  //item.LessonPriceType.BranchStore.ManagerID.Value,
                CourseContractExtension = new Models.DataEntity.CourseContractExtension
                {
                    BranchID = item.CourseContractExtension.BranchID
                }
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
                RevisionNo = item.RevisionList.Count + 1
            };
            newItem.SequenceNo = newItem.CourseContractRevision.RevisionNo;
            newItem.ContractNo = item.ContractNo;   // + "-" + String.Format("{0:00}", newItem.CourseContractRevision.RevisionNo);

            executeContractStatus(profile, newItem, Naming.CourseContractStatus.待確認, null);
            if(profile.IsManager())
            {
                executeContractStatus(profile, newItem, Naming.CourseContractStatus.待簽名, null);
            }

            switch (viewModel.Reason)
            {
                case "展延":

                    newItem.CourseContractMember.AddRange(item.CourseContractMember.Select(u => new CourseContractMember
                    {
                        UID = u.UID
                    }));

                    newItem.Expiration = newItem.Expiration.Value.AddMonths(viewModel.MonthExtension.Value);
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
                    break;
            }

            models.SubmitChanges();

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
                if (item.Status == (int)Naming.CourseContractStatus.已生效)
                    r[7] = item.RemainedLessonCount();
                r[8] = item.Lessons;
            }


            if(item.Status <= (int)Naming.CourseContractStatus.已生效)
                r[9] =  item.TotalCost;

            var originalPrice = item.OriginalSeriesPrice();
            r[10] = originalPrice != null ? originalPrice.ListPrice : item.LessonPriceType.ListPrice;
            r[11] = item.LessonPriceType.ListPrice;
            var revision = item.CourseContractRevision;
            r[12] = revision == null ? "新合約" : revision.Reason;
            r[13] = ((Naming.CourseContractStatus)item.Status).ToString();

            r[14] = item.Remark;

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

    }
}