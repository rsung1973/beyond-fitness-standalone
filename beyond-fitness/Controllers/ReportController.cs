using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;

using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [Authorize]
    public class ReportController : SampleController<UserProfile>
    {
        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach, (int)Naming.RoleID.Accounting, (int)Naming.RoleID.Assistant,(int)Naming.RoleID.Manager,(int)Naming.RoleID.ViceManager })]
        public ActionResult LearnerPayment(LearnerPaymentViewModel viewModel)
        {
            IQueryable<RegisterLesson> items = models.GetTable<RegisterLesson>().Where(r => false);
            ViewBag.ViewModel = viewModel;

            if (viewModel.HasQuery == true)
            {
                items = models.GetTable<RegisterLesson>()
                    .Where(r => r.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
                    .Where(r => r.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.體驗課程)
                    .Where(r => r.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.點數兌換課程)
                    .Where(r => r.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自由教練預約)
                    .Where(r => r.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI);


                if (viewModel.Payoff == true)
                {
                    Expression<Func<TuitionInstallment,bool>> f = t => t.PayoffDate.HasValue;
                    if (viewModel.DateFrom.HasValue)
                         f = f.And(t => t.PayoffDate >= viewModel.DateFrom);
                    if (viewModel.DateTo.HasValue)
                        f = f.And(t => t.PayoffDate < viewModel.DateTo.Value.AddDays(1));
                    var queryItems = models.GetTable<TuitionInstallment>().Where(f).Select(t => t.RegisterID);

                    items = items.Where(i => queryItems.Contains(i.RegisterID));
                }
                else if (viewModel.Payoff == false)
                {
                    items = items.Where(r => r.IntuitionCharge.TuitionInstallment.Count == 0
                        || r.IntuitionCharge.TuitionInstallment.Any(t => !t.PayoffDate.HasValue));
                }

                if(!String.IsNullOrEmpty(viewModel.UserName))
                {
                    items = items.Where(r => r.UserProfile.RealName.Contains(viewModel.UserName) || r.UserProfile.Nickname.Contains(viewModel.UserName));
                }

                if(viewModel.CoachID.HasValue)
                {
                    items = items.Where(r => r.AdvisorID == viewModel.CoachID);
                }
            }

            return View(items);
        }

        public ActionResult LearnerRecentLessons(int uid,int? lessonID,bool? cloneLesson,bool? showCalendar)
        {
            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (item == null)
            {
                ViewBag.Title = "檢視課程記錄";
                ViewBag.Message = "學員資料錯誤!!";
                return View("MessageModal");
            }

            ViewBag.LessonID = lessonID;
            ViewBag.ShowCalendar = showCalendar;
            if (cloneLesson == true)
                ViewBag.CloneLesson = true;
            return View(item);
        }

        public ActionResult RecentLessonsCalendar(int uid,int? lessonID)
        {
            var items = models.GetTable<LessonTime>().Where(t => t.RegisterLesson.UID == uid
                    || t.GroupingLesson.RegisterLesson.Any(r => r.UID == uid));

            if(lessonID.HasValue)
            {
                items = items.Where(l => l.LessonID == lessonID);
            }

            var dataItems = items.OrderByDescending(t => t.ClassTime).Take(2).ToArray();

            if (dataItems.Count() == 0)
            {
                return Content("學員未建立上課資料!!");
            }

            var item = dataItems.Last();

            ViewBag.LessonDate = item.ClassTime;
            ViewBag.EventsUrl = (new UrlHelper(ControllerContext.RequestContext)).Action("VipEvents", "Lessons", new { id = uid });
            return View(item);
        }

        public ActionResult RecentLessons(int uid,int? lessonID,bool? edit)
        {
            var items = models.GetTable<LessonTime>().Where(t => t.RegisterLesson.UID == uid
                    || t.GroupingLesson.RegisterLesson.Any(r => r.UID == uid));


            if (lessonID.HasValue)
            {
                items = items.Where(l => l.LessonID == lessonID);
            }

            var dataItems = items.OrderByDescending(t => t.ClassTime).Take(2).ToArray();

            if (dataItems.Count() == 0)
            {
                return Content("學員未建立上課資料!!");
            }

            var item = dataItems.Last();

            ViewBag.LessonDate = item.ClassTime;
            ViewBag.ByCalendar = true;
            if (edit == true)
                ViewBag.Edit = true;
            return View("~/Views/Lessons/LessonContent.ascx",item);
        }

        public ActionResult LessonContent(int lessonID,bool? edit,bool? learner,int? tabIndex,bool? byCalendar)
        {
            var item = models.GetTable<LessonTime>().Where(t => t.LessonID == lessonID).FirstOrDefault();

            if (item == null)
            {
                return Content("學員未建立上課資料!!");
            }

            ViewBag.LessonDate = item.ClassTime;
            if (edit == true)
                ViewBag.Edit = true;
            if (learner == true)
                ViewBag.Learner = true;
            ViewBag.TabIndex = tabIndex;
            ViewBag.ByCalendar = byCalendar;
            return View("~/Views/Lessons/LessonContent.ascx", item);
        }

        public ActionResult ListLessonPriceType()
        {
            var items = models.GetTable<LessonPriceType>();
            return View(items);
        }

        [RoleAuthorize(RoleID = new int[] {(int)Naming.RoleID.Accounting,(int)Naming.RoleID.Assistant })]
        public ActionResult StaffAchievement()
        {
            return View();
        }

        [CoachAuthorize]
        public ActionResult CoachAchievement()
        {
            return View();
        }

        public ActionResult ListLessonAttendanceModal(int? coachID, DateTime? dateFrom, DateTime? dateTo, int? month,int? branchID)
        {
            ViewResult result = (ViewResult)ListLessonAttendance(coachID, dateFrom, dateTo, month, branchID);
            if (((IEnumerable<LessonTime>)result.Model).Count() <= 0)
            {
                ViewBag.Message = "資料不存在!!";
                return View("~/Views/Shared/MessageModal.ascx");
            }
            else
            {
                result.ViewName = "~/Views/Report/Module/LessonAttendanceModal.ascx";
            }

            return result;
        }

        public ActionResult ListLessonAttendance(int? coachID, DateTime? dateFrom, DateTime? dateTo, int? month,int? branchID)
        {
            IQueryable<LessonTime> items = models.GetLessonAttendance(coachID, dateFrom, ref dateTo, month, branchID);

            ViewBag.DateFrom = dateFrom;
            ViewBag.DateTo = dateTo;

            return View(items);

        }

        //private IQueryable<LessonTime> GetLessonAttendance(int? coachID, DateTime? dateFrom, ref DateTime? dateTo, int? month, int? branchID)
        //{
        //    var items = models.GetTable<LessonTime>()
        //        //.Where(t => t.LessonAttendance != null)
        //        .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
        //        .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自由教練預約)
        //        .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI)
        //        .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.體驗課程)
        //        .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.點數兌換課程)
        //        .Where(t => t.LessonAttendance != null || t.LessonPlan.CommitAttendance.HasValue);

        //    if (coachID.HasValue)
        //    {
        //        items = items.Where(t => t.AttendingCoach == coachID);
        //    }

        //    if (dateFrom.HasValue)
        //    {
        //        items = items.Where(t => t.ClassTime >= dateFrom);
        //    }

        //    if (dateTo.HasValue)
        //    {
        //        items = items.Where(t => t.ClassTime < dateTo.Value.AddDays(1));
        //    }
        //    else if (month.HasValue)
        //    {
        //        dateTo = dateFrom.Value.AddMonths(month.Value);
        //        items = items.Where(t => t.ClassTime < dateTo);
        //        dateTo = dateTo.Value.AddDays(-1);
        //    }

        //    if (branchID.HasValue)
        //    {
        //        items = items.Where(t => t.BranchID == branchID);
        //    }

        //    return items;
        //}

        public ActionResult ListRegisterLessonModal(int? coachID, DateTime? dateFrom, DateTime? dateTo, int? month,int? branchID)
        {
            ViewResult result = (ViewResult)ListRegisterLesson(coachID, dateFrom, dateTo, month, branchID);
            if (((IEnumerable<TuitionAchievement>)result.Model).Count() <= 0)
            {
                ViewBag.Message = "資料不存在!!";
                return View("~/Views/Shared/MessageModal.ascx");
            }
            else
            {
                result.ViewName = "~/Views/Report/Module/ListRegisterLessonModal.ascx";
            }

            return result;
        }

        public ActionResult ListRegisterLesson(int? coachID, DateTime? dateFrom, DateTime? dateTo,int? month,int? branchID)
        {
            IQueryable<TuitionAchievement> items = models.GetTuitionAchievement(coachID, dateFrom, ref dateTo, month);

            ViewBag.DateFrom = dateFrom;
            ViewBag.DateTo = dateTo;

            return View(items);

        }

        //private IQueryable<TuitionAchievement> GetTuitionAchievement(int? coachID, DateTime? dateFrom, ref DateTime? dateTo, int? month)
        //{
        //    IQueryable<TuitionInstallment> installment = models.GetTable<TuitionInstallment>();
        //    IQueryable<TuitionAchievement> items;

        //    if (dateFrom.HasValue)
        //    {
        //        installment = installment.Where(i => i.PayoffDate >= dateFrom);
        //    }
        //    if (dateTo.HasValue)
        //    {
        //        installment = installment.Where(i => i.PayoffDate < dateTo.Value.AddDays(1));
        //    }
        //    else if (month.HasValue)
        //    {
        //        dateTo = dateFrom.Value.AddMonths(month.Value);
        //        installment = installment.Where(i => i.PayoffDate < dateTo);
        //        dateTo = dateTo.Value.AddDays(-1);
        //    }

        //    if (coachID.HasValue)
        //    {
        //        items = installment.Join(models.GetTable<TuitionAchievement>().Where(c => c.CoachID == coachID),
        //            t => t.InstallmentID, i => i.InstallmentID, (t, i) => i);
        //    }
        //    else
        //    {
        //        items = installment.Join(models.GetTable<TuitionAchievement>(),
        //            t => t.InstallmentID, i => i.InstallmentID, (t, i) => i);
        //    }

        //    return items;
        //}

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult BonusAwardList()
        {
            return View();
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach })]
        public ActionResult BonusPromotionIndex()
        {
            return View();
        }


        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult ListBonusAward(AwardQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            IQueryable<LearnerAward> items = models.GetTable<LearnerAward>();

            Expression<Func<LearnerAward, bool>> queryExpr = c => false;
            bool hasConditon = false;

            viewModel.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.UserName != null)
            {
                hasConditon = true;
                queryExpr = queryExpr.Or(c => c.UserProfile.RealName.Contains(viewModel.UserName) || c.UserProfile.Nickname.Contains(viewModel.UserName));
            }

            if(viewModel.ActorID.HasValue)
            {
                hasConditon = true;
                queryExpr = queryExpr.Or(c => c.ActorID == viewModel.ActorID);
            }

            if (viewModel.ItemID.HasValue)
            {
                hasConditon = true;
                queryExpr = queryExpr.Or(c => c.ItemID == viewModel.ItemID);
            }

            if(hasConditon)
            {
                items = items.Where(queryExpr);
            }

            if(viewModel.DateFrom.HasValue)
            {
                items = items.Where(c => c.AwardDate >= viewModel.DateFrom);
            }

            if(viewModel.DateTo.HasValue)
            {
                items = items.Where(c => c.AwardDate < viewModel.DateTo.Value.AddDays(1));
            }

            return View("~/Views/Report/Module/ListBonusAward.ascx", items);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach })]
        public ActionResult ListBonusPromotion(AwardQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            IQueryable<UserProfile> items = models.GetTable<UserProfile>();

            viewModel.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.UserName != null)
            {
                items = items.Where(c => c.RealName.Contains(viewModel.UserName) || c.Nickname.Contains(viewModel.UserName));
            }

            if (viewModel.ActorID.HasValue)
            {
                items = items
                    .Join(models.GetTable<LearnerFitnessAdvisor>()
                        .Where(f => f.CoachID == viewModel.ActorID), 
                        u => u.UID, f => f.UID, (u, f) => u);
            }

            var taskItems = models.GetTable<PDQTask>()
                .Join(models.GetTable<PDQTaskBonus>(),
                    t => t.TaskID, q => q.TaskID, (t, q) => t)
                .Join(items, t => t.UID, u => u.UID, (t, u) => t);

            return View("~/Views/Report/Module/ListBonusPromotion.ascx", taskItems);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach })]
        public ActionResult ListLearnerBonus(AwardQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if(viewModel.KeyID!=null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            var taskItems = models.GetTable<PDQTask>()
                .Where(t => t.UID == viewModel.UID)
                .Join(models.GetTable<PDQTaskBonus>(),
                    t => t.TaskID, q => q.TaskID, (t, q) => t);

            return View("~/Views/Report/Module/ListLearnerBonus.ascx", taskItems);
        }

        public ActionResult QuestionnaireIndex(QuestionnaireQueryViewModel viewModel)
        {
            viewModel.AchievementDateTo = DateTime.Today;
            ViewBag.ViewModel = viewModel;
            return View();
        }

        public ActionResult InquireQuestionnaire(QuestionnaireQueryViewModel viewModel, int? qureyAction = null)
        {
            ViewBag.ViewModel = viewModel;

            //if (!viewModel.AchievementDateFrom.HasValue)
            //{
            //    ModelState.AddModelError("AchievementDateFrom", "請選擇查詢起日");
            //}

            if (!viewModel.AchievementDateTo.HasValue)
            {
                ModelState.AddModelError("AchievementDateTo", "請選擇查詢迄日");
            }

            //if (viewModel.AchievementDateFrom.HasValue && viewModel.AchievementDateTo.HasValue
            //    && (viewModel.AchievementDateTo.Value - viewModel.AchievementDateFrom.Value).TotalDays > 31)
            //{
            //    ModelState.AddModelError("AchievementDateFrom", "查詢區間只能是一個月內");
            //    ModelState.AddModelError("AchievementDateTo", "查詢區間只能是一個月內");
            //}

            if (viewModel.ByCoachID == null || viewModel.ByCoachID.Length == 0)
            {
                ModelState.AddModelError("ByCoachID", "請勾選一位");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            IQueryable<QuestionnaireRequest> items = models.GetTable<QuestionnaireRequest>();

            if (viewModel.AchievementDateFrom.HasValue)
                items = items.Where(t => t.RequestDate >= viewModel.AchievementDateFrom);

            if (viewModel.AchievementDateTo.HasValue)
                items = items.Where(t => t.RequestDate < viewModel.AchievementDateTo.Value.AddDays(1));

            if (viewModel.ByCoachID != null && viewModel.ByCoachID.Length > 0)
            {
                var uid = models.GetTable<LearnerFitnessAdvisor>().Where(l => viewModel.ByCoachID.Contains(l.CoachID));
                var questID = models.GetTable<PDQTask>().Where(u => viewModel.ByCoachID.Contains(u.UID))
                        .GroupBy(t => t.QuestionnaireID).Select(g => g.Key);
                items = items.Join(uid, q => q.UID, u => u.UID, (q, u) => q)
                    .Union(items.Join(questID, q => q.QuestionnaireID, t => t, (q, t) => q));
            }

            if (viewModel.Status.HasValue)
            {
                switch (viewModel.Status)
                {
                    case 1:
                        items = items.Where(q => !q.Status.HasValue);
                        break;
                    case 2:
                        items = items.Where(q => q.Status == (int)Naming.IncommingMessageStatus.已讀
                            || q.Status == (int)Naming.IncommingMessageStatus.未讀);
                        break;
                    case 3:
                        items = items.Where(q => q.Status == (int)Naming.IncommingMessageStatus.教練代答);
                        break;
                    case 4:
                        items = items.Where(q => q.Status == (int)Naming.IncommingMessageStatus.拒答);
                        break;
                }
            }

            viewModel.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.UserName!=null)
            {
                var uid = models.GetTable<UserProfile>().Where(u => u.RealName.Contains(viewModel.UserName) || u.Nickname.Contains(viewModel.UserName))
                    .Select(u => u.UID);
                items = items.Where(q => uid.Contains(q.UID));
            }

            return View("~/Views/Report/Module/QuestionnaireList.ascx", items);
        }



    }
}