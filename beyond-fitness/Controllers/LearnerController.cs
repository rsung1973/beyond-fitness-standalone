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
using CommonLib.DataAccess;

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
    public class LearnerController : SampleController<UserProfile>
    {
        // GET: Learner
        public ActionResult Index()
        {
             return View();
        }

        public ActionResult InquireLearner(LearnerQueryViewModel viewModel)
        {
            IQueryable<UserProfile> items = models.EntityList
                        .FilterByLearner(models, true);

            Expression<Func<UserProfile, bool>> queryExpr = u => false;

            bool hasCondition = false;

            viewModel.RealName = viewModel.RealName.GetEfficientString();
            if (viewModel.RealName != null)
            {
                queryExpr = queryExpr.Or(m => m.RealName.Contains(viewModel.RealName) || m.Nickname.Contains(viewModel.RealName));
                hasCondition = true;
            }

            if (!hasCondition)
            {
                viewModel.IDNo = viewModel.IDNo.GetEfficientString();
                if (viewModel.IDNo != null)
                {
                    queryExpr = queryExpr.Or(c => c.UserProfileExtension.IDNo.StartsWith(viewModel.IDNo));
                    hasCondition = true;
                }
            }

            if (!hasCondition)
            {
                viewModel.Phone = viewModel.Phone.GetEfficientString();
                if (viewModel.Phone != null)
                {
                    queryExpr = queryExpr.Or(c => c.Phone == viewModel.Phone);
                    hasCondition = true;
                }
            }

            if (!hasCondition)
            {
                if (viewModel.UID.HasValue)
                {
                    queryExpr = queryExpr.Or(c => c.UID == viewModel.UID);
                    hasCondition = true;
                }
            }

            if(!hasCondition)
            {
                if(viewModel.CoachID.HasValue)
                {
                    queryExpr = queryExpr.Or(c => c.LearnerFitnessAdvisor.Any(a => a.CoachID == viewModel.CoachID));
                    hasCondition = true;
                }
            }

            if (hasCondition)
            {
                items = items.Where(queryExpr);
            }

            if(viewModel.CurrentTrial.HasValue)
            {
                if (viewModel.CurrentTrial == 1)
                    items = items.Where(u => u.UserProfileExtension.CurrentTrial.HasValue);
                else
                    items = items.Where(u => !u.UserProfileExtension.CurrentTrial.HasValue);
            }

            if(viewModel.MemberStatus.HasValue)
            {
                items = items.Where(u => u.LevelID == (int)viewModel.MemberStatus);
            }

            viewModel.Gender = viewModel.Gender.GetEfficientString();
            if (viewModel.Gender!=null)
            {
                    items = items.Where(u => u.UserProfileExtension.Gender == viewModel.Gender);
            }

            if (viewModel.AthleticLevel.HasValue)
            {
                items = items.Where(u => u.UserProfileExtension.AthleticLevel == viewModel.AthleticLevel);
            }
                        
            return View("~/Views/Learner/Module/LearnerList.ascx", items);

        }


        public ActionResult LearnerList()
        {
            ViewResult result = (ViewResult)Index();
            result.ViewName = "~/Views/Learner/Module/LearnerList.ascx";
            return result;
        }

        public ActionResult EditLearner(ContractMemberViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            UserProfile item;
            item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();

            viewModel.CurrentTrial = 1;
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
                viewModel.CurrentTrial = item.UserProfileExtension.CurrentTrial;
                viewModel.RealName = item.RealName;
                viewModel.Nickname = item.Nickname;
                viewModel.Address = item.Address;
                viewModel.Nickname = item.Nickname;
                viewModel.UID = item.UID;
                viewModel.Email = item.PID;
            }

            return View("~/Views/Learner/Module/EditLearner.ascx", item);
        }

        [CoachOrAssistantAuthorize]
        public ActionResult PDQ(int uid, int? groupID)
        {
            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "學員資料不存在!!");
            }

            ViewBag.GroupID = groupID;
            switch (groupID)
            {
                case 1:
                    ViewBag.Percent = "20%";
                    return View("~/Views/Learner/Module/PDQ.ascx", item);
                case 2:
                    ViewBag.Percent = "40%";
                    return View("~/Views/Learner/Module/PDQ_All.ascx", item);
                case 3:
                    ViewBag.Percent = "60%";
                    return View("~/Views/Learner/Module/PDQ_All.ascx", item);
                case 4:
                    ViewBag.Percent = "80%";
                    return View("~/Views/Learner/Module/PDQ_All.ascx", item);
                case 5:
                    ViewBag.Percent = "95%";
                    return View("~/Views/Learner/Module/PDQ_All.ascx", item);
                case 6:
                    return View("~/Views/Learner/Module/PDQ_Final.ascx", item);
                default:
                    return View("~/Views/Learner/Module/PDQ.ascx", item);
            }
        }

        public ActionResult UpdatePDQ(int uid, int groupID, int? goalID, int? styleID, int? levelID)
        {
            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "學員資料不存在!!" });
            }

            models.ExecuteCommand(@"
                DELETE FROM PDQTask
                FROM     PDQTask INNER JOIN
                                PDQQuestion ON PDQTask.QuestionID = PDQQuestion.QuestionID
                WHERE   (PDQTask.UID = {0}) AND (PDQQuestion.GroupID = {1})", item.UID, groupID);

            foreach (var key in Request.Form.AllKeys.Where(k => Regex.IsMatch(k, "_\\d")))
            {
                savePDQ(item, key);
            }

            if (item.PDQUserAssessment == null)
                item.PDQUserAssessment = new PDQUserAssessment { };
            item.PDQUserAssessment.GoalID = goalID;
            item.PDQUserAssessment.StyleID = styleID;
            item.PDQUserAssessment.LevelID = levelID;

            models.SubmitChanges();

            IQueryable<PDQQuestion> questItems = models.GetTable<PDQQuestion>().Where(q => q.GroupID == groupID);
            var voidAns = questItems
                .Where(q => !q.PDQTask.Any(t => t.UID == uid)
                    || q.PDQTask.Count(t => t.UID == uid && !t.SuggestionID.HasValue && t.PDQAnswer == "") == 1)
                .OrderBy(q => q.QuestionNo);
            if (voidAns.Count() > 0)
            {
                return Json(new { result = false, message = "請填選第" + String.Join("、", voidAns.Select(q => q.QuestionNo)) + "題答案!!" });
            }

            return Json(new { result = true });
        }

        protected void savePDQ(UserProfile item, string key)
        {
            int questionID = int.Parse(key.Substring(1));
            var quest = models.GetTable<PDQQuestion>().Where(q => q.QuestionID == questionID).FirstOrDefault();
            if (quest == null)
                return;

            var values = Request.Form.GetValues(key);
            if (values == null)
                return;

            switch ((Naming.QuestionType)quest.QuestionType)
            {
                case Naming.QuestionType.問答題:
                    if (values.Length > 0)
                    {
                        models.GetTable<PDQTask>().InsertOnSubmit(new PDQTask
                        {
                            QuestionID = quest.QuestionID,
                            UID = item.UID,
                            PDQAnswer = values[0]
                        });
                        models.SubmitChanges();
                    }
                    break;

                case Naming.QuestionType.單選題:
                case Naming.QuestionType.單選其他:
                    foreach (var v in values)
                    {
                        int suggestID;
                        if (int.TryParse(v, out suggestID))
                        {
                            models.GetTable<PDQTask>().InsertOnSubmit(new PDQTask
                            {
                                QuestionID = quest.QuestionID,
                                UID = item.UID,
                                SuggestionID = suggestID
                            });
                        }
                        else
                        {
                            models.GetTable<PDQTask>().InsertOnSubmit(new PDQTask
                            {
                                QuestionID = quest.QuestionID,
                                UID = item.UID,
                                PDQAnswer = v
                            });
                        }
                        models.SubmitChanges();
                    }
                    break;

                case Naming.QuestionType.多重選:
                    break;

                case Naming.QuestionType.是非題:
                    if (values.Length > 0)
                    {
                        models.GetTable<PDQTask>().InsertOnSubmit(new PDQTask
                        {
                            QuestionID = quest.QuestionID,
                            UID = item.UID,
                            YesOrNo = values[0] == "1" ? true : false
                        });
                        models.SubmitChanges();
                    }
                    break;
            }
        }

        public ActionResult ListFitnessAdvisor(int uid)
        {
            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).First();
            return View("~/Views/Learner/Module/ListFitnessAdvisor.ascx", item);
        }

        public ActionResult AssignFitnessAdvisor(int uid)
        {
            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).First();
            return View("~/Views/Learner/Module/AssignFitnessAdvisor.ascx", item);
        }

        public ActionResult CommitAdvisorAssignment(int uid, int? CoachID)
        {
            if (!CoachID.HasValue)
            {
                ModelState.AddModelError("CoachID", "請選擇體能顧問");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            if (!models.GetTable<LearnerFitnessAdvisor>().Any(f => f.UID == uid && f.CoachID == CoachID))
            {
                models.GetTable<LearnerFitnessAdvisor>().InsertOnSubmit(new LearnerFitnessAdvisor
                {
                    UID = uid,
                    CoachID = CoachID.Value
                });
                models.SubmitChanges();
            }

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);

        }

        public ActionResult DeleteAdvisorAssignment(int uid, int? coachID)
        {
            var item = models.DeleteAny<LearnerFitnessAdvisor>(f => f.UID == uid && f.CoachID == coachID);
            if(item==null)
            {
                return Json(new { result = false, message = "資料錯誤!!" }, JsonRequestBehavior.AllowGet);
            }
            return Json(new { result = true }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult DeleteLearner(int uid)
        {
            UserProfile item = models.EntityList.Where(u => u.UID == uid).FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }

            item.LevelID = (int)Naming.MemberStatusDefinition.Deleted;
            models.SubmitChanges();

            try
            {
                models.DeleteAny<UserProfile>(u => u.UID == item.UID);
                return Json(new { result = true },JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                Logger.Warn("無法刪除使用者，因其他關聯性資料...\r\n" + ex);
                return Json(new { result = true, message = "無法刪除，已改為停用!!" }, JsonRequestBehavior.AllowGet);
            }

        }

        public ActionResult EnableLearner(int uid)
        {

            UserProfile item = models.EntityList.Where(u => u.UID == uid).FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }

            item.LevelID = item.UserProfileExtension.RegisterStatus == true ? (int)Naming.MemberStatusDefinition.Checked : (int)Naming.MemberStatusDefinition.ReadyToRegister;
            models.SubmitChanges();

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult CreateUnallocatedLearnerListXlsx(LearnerQueryViewModel viewModel, String tableName)
        {
            ViewResult result = (ViewResult)InquireLearner(viewModel);
            IQueryable<UserProfile> items = result.Model as IQueryable<UserProfile>;
            if (items == null)
            {
                ViewBag.GoBack = true;
                return View("~/Views/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }

            items = items.Where(u => !u.LearnerFitnessAdvisor.Any())
                        .Where(l => l.UserProfileExtension != null && !l.UserProfileExtension.CurrentTrial.HasValue);

            renderToXlsx(items, "未指派體能顧問學員清單",$"LearnerReport({DateTime.Now:yyyy-MM-dd HH-mm-ss})");
            return new EmptyResult();
        }


        private void renderToXlsx(IQueryable<UserProfile> items, String tableName,String fileName)
        {
            models.ExecuteCommand(@"UPDATE RegisterLesson
                        SET        BranchID = CourseContractExtension.BranchID
                        FROM     RegisterLesson INNER JOIN
                                       RegisterLessonContract ON RegisterLesson.RegisterID = RegisterLessonContract.RegisterID INNER JOIN
                                       CourseContract ON RegisterLessonContract.ContractID = CourseContract.ContractID INNER JOIN
                                       CourseContractExtension ON CourseContract.ContractID = CourseContractExtension.ContractID
                        WHERE   (RegisterLesson.BranchID IS NULL)");

            var resultItems = items
                    .Join(models.GetTable<RegisterLesson>().Where(m => m.BranchID.HasValue && m.Attended != (int)Naming.LessonStatus.課程結束)
                        .GroupBy(r => new { r.UID, r.BranchStore.BranchName }),
                        u => u.UID, m => m.Key.UID, (u, m) =>
                                new
                                {
                                    EMail = u.LevelID == (int)Naming.MemberStatus.已註冊 ? u.PID : null,
                                    真實姓名 = u.RealName,
                                    暱稱 = u.Nickname,
                                    性別 = u.UserProfileExtension.Gender == "F" ? "女" : "男",
                                    出生 = u.Birthday,
                                    聯絡電話 = u.Phone,
                                    分店 = m.Key.BranchName
                                });

            DataTable details = resultItems.ToDataTable();
            if (!String.IsNullOrEmpty(tableName))
                details.TableName = tableName;

            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", $"attachment;filename={fileName}.xlsx");

            using (DataSet ds = new DataSet())
            {
                ds.Tables.Add(details);

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            details.Dispose();
        }




    }
}