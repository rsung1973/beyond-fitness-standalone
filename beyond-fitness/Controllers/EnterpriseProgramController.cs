using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
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
using CommonLib.DataAccess;
using WebHome.Properties;
    
namespace WebHome.Controllers
{
    [Authorize]
    public class EnterpriseProgramController : LessonEventController
    {
        public EnterpriseProgramController() : base()
        {

        }

        // GET: EnterpriseProgram
        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult ProgramIndex()
        {
            return View();
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult EditEnterpriseContract(EnterpriseContractViewModel viewModel)
        {
            var item = models.GetTable<EnterpriseCourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                viewModel.TotalCost = item.TotalCost;
                viewModel.CompanyID = item.CompanyID;
                viewModel.CompanyName = item.Organization.CompanyName;
                viewModel.ReceiptNo = item.Organization.ReceiptNo;
                viewModel.EnterprisePriceID = item.EnterpriseCourseContent.Select(c => (int?)c.TypeID).ToArray();
                viewModel.EnterpriseLessons = item.EnterpriseCourseContent.Select(c => c.Lessons).ToArray();
                viewModel.EnterpriseDurationInMinutes = item.EnterpriseCourseContent.Select(c => c.DurationInMinutes).ToArray();
                viewModel.EnterpriseListPrice = item.EnterpriseCourseContent.Select(c => c.ListPrice).ToArray();
                viewModel.Subject = item.Subject;
                viewModel.Remark = item.Remark;
                viewModel.UID = item.EnterpriseCourseMember.Select(m => m.UID).ToArray();
                viewModel.BranchID = item.BranchID;
                viewModel.ValidFrom = item.ValidFrom;
                viewModel.Expiration = item.Expiration;
            }

            ViewBag.ViewModel = viewModel;
            return View("~/Views/EnterpriseProgram/Module/EditEnterpriseContract.ascx", item);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult EditProgramDataItem(EnterpriseProgramItemViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/EnterpriseProgram/Module/EditProgramDataItem.ascx");
        }


        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult ApplyProgramDataItem(EnterpriseProgramItemViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (!viewModel.ListPrice.HasValue || viewModel.ListPrice < 0)
            {
                ModelState.AddModelError("ListPrice", "請輸入體能顧問終點費用!!");
            }

            if (!viewModel.PriceID.HasValue)
            {
                ModelState.AddModelError("PriceID", "請選擇體能顧問服務項目!!");
            }

            if (!viewModel.Lessons.HasValue || viewModel.Lessons <= 0)
            {
                ModelState.AddModelError("Lessons", "請輸入購買堂數!!");
            }

            var item = models.GetTable<EnterpriseLessonType>().Where(t => t.TypeID == viewModel.PriceID).FirstOrDefault();
            if (item == null)
            {
                ModelState.AddModelError("PriceID", "請選擇體能顧問服務項目!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx"); ;
            }

            return View("~/Views/EnterpriseProgram/Module/ApplyProgramDataItem.ascx", item);

        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult CommitEnterpriseContract(EnterpriseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            EnterpriseCourseContract item = models.GetTable<EnterpriseCourseContract>()
                .Where(p => p.ContractID == viewModel.ContractID).FirstOrDefault();

            if (!viewModel.ValidFrom.HasValue)
            {
                ModelState.AddModelError("ValidFrom", "請選擇合約起日!!");
            }

            if (!viewModel.Expiration.HasValue)
            {
                ModelState.AddModelError("Expiration", "請選擇合約迄日!!");
            }

            viewModel.CompanyName = viewModel.CompanyName.GetEfficientString();
            if (viewModel.CompanyName == null)
            {
                ModelState.AddModelError("CompanyName", "請輸入企業名稱!!");
            }

            viewModel.ReceiptNo = viewModel.ReceiptNo.GetEfficientString();
            if (viewModel.ReceiptNo == null)
            {
                ModelState.AddModelError("ReceiptNo", "請輸入統一編號!!");
            }


            viewModel.Subject = viewModel.Subject.GetEfficientString();
            if (viewModel.Subject == null)
            {
                ModelState.AddModelError("Subject", "請輸入合作方案說明!!");
            }

            if (!viewModel.TotalCost.HasValue || viewModel.TotalCost<=0)
            {
                ModelState.AddModelError("TotalCost", "請輸入價格!!");
            }


            if (viewModel.EnterprisePriceID == null || viewModel.EnterprisePriceID.Length == 0)
            {
                ModelState.AddModelError("Subject", "請設定課程項目!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            try
            {
                var orgItem = models.GetTable<Organization>().Where(o => o.ReceiptNo == viewModel.ReceiptNo).FirstOrDefault();
                if (orgItem == null)
                {
                    orgItem = new Organization
                    {
                        ReceiptNo = viewModel.ReceiptNo
                    };
                    models.GetTable<Organization>().InsertOnSubmit(orgItem);
                }
                orgItem.CompanyName = viewModel.CompanyName;
                models.SubmitChanges();

                if (item == null)
                {
                    item = new EnterpriseCourseContract
                    {
                        ContractNo = "CEA" + String.Format("{0:yyyyMMdd}", DateTime.Today) + String.Format("{0:0000}", DailySequence.NextSequenceNo) + "-00",
                    };
                    models.GetTable<EnterpriseCourseContract>().InsertOnSubmit(item);
                }

                item.BranchID = viewModel.BranchID;
                item.CompanyID = orgItem.CompanyID;
                item.Expiration = viewModel.Expiration;
                item.ValidFrom = viewModel.ValidFrom;
                item.Remark = viewModel.Remark;
                item.Subject = viewModel.Subject;
                item.TotalCost = viewModel.TotalCost;

                models.SubmitChanges();

                try
                {
                    models.ExecuteCommand("delete EnterpriseCourseContent where ContractID={0}", item.ContractID);
                }
                catch(Exception ex)
                {
                    Logger.Error(ex);
                }

                if (viewModel.EnterprisePriceID != null && viewModel.EnterprisePriceID.Length > 0)
                {
                    for (int i = 0; i < viewModel.EnterprisePriceID.Length; i++)
                    {
                        var content = item.EnterpriseCourseContent.Where(c => c.TypeID == viewModel.EnterprisePriceID[i]).FirstOrDefault();
                        if (content == null)
                        {
                            content = new EnterpriseCourseContent
                            {
                                ContractID = item.ContractID,
                                TypeID = viewModel.EnterprisePriceID[i].Value
                            };
                            models.GetTable<EnterpriseCourseContent>().InsertOnSubmit(content);
                        }
                        content.DurationInMinutes = viewModel.EnterpriseDurationInMinutes[i];
                        content.Lessons = viewModel.EnterpriseLessons[i];
                        content.ListPrice = viewModel.EnterpriseListPrice[i];
                    }
                    models.SubmitChanges();
                }

                return Json(new { result = true });
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult ListMember(EnterpriseContractViewModel viewModel,bool? itemsOnly)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<EnterpriseCourseContract>().Where(t => t.ContractID == viewModel.ContractID).FirstOrDefault();
            if(item==null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
            }

            if (itemsOnly == true)
            {
                return View("~/Views/EnterpriseProgram/Module/MemberItemList.ascx", item);
            }
            else
            {
                return View("~/Views/EnterpriseProgram/Module/EnterpriseProgramMemberList.ascx", item);
            }
        }

        public ActionResult AddMember(EnterpriseGroupMemberViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/EnterpriseProgram/Module/MemberSelector.ascx");
        }

        public ActionResult RemoveMember(EnterpriseGroupMemberViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var item = models.GetTable<EnterpriseCourseMember>().Where(m => m.ContractID == viewModel.ContractID
                && m.UID == viewModel.UID).FirstOrDefault();

            if (item == null)
                return Json(new { result = false, message = "資料錯誤!!" }, JsonRequestBehavior.AllowGet);

            try
            {
                models.ExecuteCommand(@"DELETE FROM RegisterLesson
                        FROM     EnterpriseCourseContract INNER JOIN
                                    RegisterLessonEnterprise ON EnterpriseCourseContract.ContractID = RegisterLessonEnterprise.ContractID INNER JOIN
                                    RegisterLesson ON RegisterLessonEnterprise.RegisterID = RegisterLesson.RegisterID
                        WHERE   (EnterpriseCourseContract.ContractID = {0}) AND (RegisterLesson.UID = {1})", item.ContractID, item.UID);

                models.DeleteAny<EnterpriseCourseMember>(m => m.ContractID == viewModel.ContractID
                        && m.UID == viewModel.UID);

                return Json(new { result = true }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }

        }


        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult CommitMember(EnterpriseGroupMemberViewModel viewModel)
        {
            if(!viewModel.UID.HasValue)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "請選擇學員!!");
            }

            var item = models.GetTable<EnterpriseCourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if(item==null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "合約資料錯誤!!");
            }

            try
            {
                var member = item.EnterpriseCourseMember.Where(m => m.UID == viewModel.UID).FirstOrDefault();
                if (member == null)
                {
                    member = new EnterpriseCourseMember
                    {
                        ContractID = item.ContractID,
                        UID = viewModel.UID.Value
                    };

                    models.GetTable<EnterpriseCourseMember>().InsertOnSubmit(member);
                    models.SubmitChanges();
                }

                checkMemberLesson(member);

                var groupMember = item.EnterpriseCourseMember.Where(m => m.UID == viewModel.GroupUID).FirstOrDefault();
                if (groupMember != null)
                {
                    if (groupMember.GroupingLesson == null)
                    {
                        groupMember.GroupingLesson = new GroupingLesson { };
                    }
                    member.GroupingLesson = groupMember.GroupingLesson;
                    models.SubmitChanges();

                    matchGroup(groupMember, member);

                }

                return Json(new { result = true });
            }
            catch(Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }

        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult TakeGroupApart(int groupID)
        {
            var item = models.DeleteAny<GroupingLesson>(g => g.GroupID == groupID);
            if (item != null)
            {
                return Json(new { result = true }, JsonRequestBehavior.AllowGet);
            }
            return Json(new { result = false, message = "資料錯誤!!" }, JsonRequestBehavior.AllowGet);
        }


        public ActionResult GetMemberLessonXlsxList(EnterpriseContractViewModel viewModel)
        {
            var contract = models.GetTable<EnterpriseCourseContract>().Where(m => m.ContractID == viewModel.ContractID).FirstOrDefault();

            if (contract == null)
                return View("~/Views/Shared/JsAlert.ascx", model: "未建立學員!!");

            var group = models.GetTable<EnterpriseCourseContract>().Where(m => m.ContractID == viewModel.ContractID)
                    .SelectMany(d => d.RegisterLessonEnterprise)
                    .Select(r => r.RegisterLesson)
                    .Select(r => r.GroupingLesson)
                    .Select(g => g.GroupID);

            var items = group.Distinct()
                    .Join(models.GetTable<LessonTime>(), g => g, l => l.GroupID, (g, l) => l);

            var details = items.ToArray()
                .OrderBy(i => i.GroupID)
                .ThenByDescending(i => i.ClassTime)
                .Select(i => new
                {
                    上課學員 = String.Join("、",i.GroupingLesson.RegisterLesson.Select(r=>r.UserProfile).ToArray().Select(u=>u.FullName())),
                    上課日期 = String.Format("{0:yyyy/MM/dd HH:mm}",i.ClassTime),
                    課程項目 = i.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Description
                });


            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename=({1:yyyy-MM-dd HH-mm-ss}){0}", HttpUtility.UrlEncode("EnterpriseCourse.xlsx"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                table.TableName = "企業方案(" + contract.ContractNo + ")";
                ds.Tables.Add(table);

                table = createEnterpriseLessonSummary(contract);
                ds.Tables.Add(table);

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        public ActionResult GetEnterpriseLessonReportXlsx(EnterpriseContractViewModel viewModel)
        {
            var contract = models.GetTable<EnterpriseCourseContract>().Where(m => m.ContractID == viewModel.ContractID).FirstOrDefault();

            if (contract == null)
                return View("~/Views/Shared/JsAlert.ascx", model: "未建立學員!!");

            DataTable table = createEnterpriseLessonSummary(contract);

            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename=({1:yyyy-MM-dd HH-mm-ss}){0}", HttpUtility.UrlEncode("EnterpriseCourseSummary.xlsx"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                ds.Tables.Add(table);

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        private DataTable createEnterpriseLessonSummary(EnterpriseCourseContract contract)
        {
            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("學員名稱", typeof(String)));

            foreach (var content in contract.EnterpriseCourseContent)
            {
                table.Columns.Add(new DataColumn(content.EnterpriseLessonType.Description + "(購買堂數)", typeof(int)));
                table.Columns.Add(new DataColumn(content.EnterpriseLessonType.Description + "(已上課堂數)", typeof(int)));
            }


            foreach (var user in contract.EnterpriseCourseMember)
            {
                var row = table.NewRow();
                int idx = 0;
                row[idx++] = user.UserProfile.FullName();
                foreach (var content in contract.EnterpriseCourseContent)
                {
                    row[idx++] = content.Lessons;
                    row[idx++] = content.RegisterLessonEnterprise
                        .Select(r => r.RegisterLesson)
                        .Where(r => r.UID == user.UID && r.RegisterGroupID.HasValue)
                        .Select(r => r.GroupingLesson).Sum(g => g.LessonTime.Count);
                }
                table.Rows.Add(row);
            }

            table.TableName = "企業方案學員明細(" + contract.ContractNo + ")";

            return table;
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult AttendeeSelector(String userName)
        {
            IEnumerable<RegisterLesson> items;
            userName = userName.GetEfficientString();
            if (userName == null)
            {
                this.ModelState.AddModelError("userName", "請輸學員名稱!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }
            else
            {
                items = models.GetTable<RegisterLesson>()
                    .Where(l => l.Attended != (int)Naming.LessonStatus.課程結束
                        && (l.UserProfile.RealName.Contains(userName) || l.UserProfile.Nickname.Contains(userName)))
                    .Where(l => l.Lessons > l.GroupingLesson.LessonTime.Count)
                    .Where(l => l.RegisterGroupID.HasValue)
                    .Join(models.GetTable<RegisterLessonEnterprise>(), r => r.RegisterID, t => t.RegisterID, (r, t) => r);
            }

            return View("~/Views/EnterpriseProgram/Module/AttendeeSelector.ascx", items);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult CheckMemberLessonStatus()
        {
            foreach(var profile in models.GetTable<EnterpriseCourseMember>())
            {
                checkMemberLesson(profile);
            }
            return Json(new { result = true }, JsonRequestBehavior.AllowGet);
        }

        private void checkMemberLesson(EnterpriseCourseMember profile)
        {
            var priceType = models.GetTable<LessonPriceType>().Where(p => p.Status == (int)Naming.LessonPriceStatus.企業合作方案).FirstOrDefault();
            foreach (var course in profile.EnterpriseCourseContract.EnterpriseCourseContent)
            {
                RegisterLesson lesson = course.RegisterLessonEnterprise
                    .Select(t => t.RegisterLesson)
                    .Where(r => r.UID == profile.UID).FirstOrDefault();
                if (lesson == null)
                {
                    lesson = new RegisterLesson
                    {
                        RegisterDate = DateTime.Now,
                        //Lessons = course.Lessons.Value,
                        Attended = (int)Naming.LessonStatus.準備上課,
                        GroupingMemberCount = course.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.團體學員課程
                            ? course.EnterpriseCourseContract.GroupingMemberCount : 1,
                        IntuitionCharge = new IntuitionCharge
                        {
                            Payment = "CreditCard",
                            FeeShared = 0,
                            ByInstallments = 1
                        },
                        LessonPriceType = priceType,
                        AdvisorID = Settings.Default.DefaultCoach,
                        AttendedLessons = 0,
                        UID = profile.UID
                    };

                    course.RegisterLessonEnterprise.Add(new RegisterLessonEnterprise
                    {
                        RegisterLesson = lesson
                    });
                }

                lesson.Lessons = course.Lessons.Value;
                if (!lesson.RegisterGroupID.HasValue)
                    lesson.GroupingLesson = new GroupingLesson { };
                models.SubmitChanges();

            }
        }

        private void matchGroup(EnterpriseCourseMember groupUser, EnterpriseCourseMember profile)
        {
            if (groupUser.ContractID != profile.ContractID)
                return;

            foreach (var course in groupUser.EnterpriseCourseContract.EnterpriseCourseContent.Where(c=>c.EnterpriseLessonType.Status==(int)Naming.LessonPriceStatus.團體學員課程))
            {
                RegisterLesson groupLesson = course.RegisterLessonEnterprise
                    .Select(t => t.RegisterLesson)
                    .Where(r => r.UID == groupUser.UID).FirstOrDefault();

                if (groupLesson == null)
                    continue;

                RegisterLesson lesson = course.RegisterLessonEnterprise
                    .Select(t => t.RegisterLesson)
                    .Where(r => r.UID == profile.UID).FirstOrDefault();

                if (lesson == null)
                    continue;

                if (groupLesson.RegisterGroupID != lesson.RegisterGroupID)
                {
                    lesson.RegisterGroupID = groupLesson.RegisterGroupID;
                    models.SubmitChanges();
                }

            }
        }


        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult CommitBookingByCoach(LessonTimeViewModel viewModel)
        {
            return CommitEnterpriseBookingByCoach(viewModel);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult EnterprisePaymentList(EnterpriseContractViewModel viewModel,bool? itemsOnly)
        {
            var item = models.GetTable<EnterpriseCourseContract>().Where(t => t.ContractID == viewModel.ContractID).FirstOrDefault();
            if(item==null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }
            if (itemsOnly == true)
            {
                return View("~/Views/EnterpriseProgram/Module/PaymentItemList.ascx", item);
            }
            else
            {
                return View("~/Views/EnterpriseProgram/Module/EnterpriseContractPaymentList.ascx", item);
            }
        }

    }
}