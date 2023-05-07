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
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

using CommonLib.DataAccess;

using EPOS;
using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Helper.BusinessOperation;
using WebHome.Helper.MessageOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc.Filters;

namespace WebHome.Controllers
{
    public class CornerKickController : SampleController<UserProfile>
    {
        public CornerKickController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: CornerKick
        public ActionResult Index(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.LineID = viewModel.KeyID.DecryptKey();
            }
            return View("Index");
        }

        public ActionResult TestError()
        {
            throw new Exception("Test Error...");
        }

        public async Task<ActionResult> LoginAsync(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ViewResult result = (await AutoLoginAsync(viewModel)) as ViewResult;
            if (result != null)
            {
                return result;
            }

            return View("Login");
        }

        public ActionResult Error(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("Error");
        }
                

        public ActionResult ForgetPassword(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }

        public async Task<ActionResult> AutoLoginAsync(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = await HttpContext.GetUserAsync();
            if (item != null)
            {
                await HttpContext.SignOnAsync(item);
                return View("~/Views/CornerKick/Module/AutoLogin.cshtml", model: this.ProcessLogin(item));
            }

            return new EmptyResult();
        }

        public async Task<ActionResult> RegisterAsync(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<UserProfileExtension>().Where(u => u.LineID == viewModel.LineID)
                    .Select(u => u.UserProfile)
                    .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                    .FirstOrDefault();

            if (item != null)
            {
                await HttpContext.SignOnAsync(item);
                return View("~/Views/CornerKick/Module/AutoLogin.cshtml", model: this.ProcessLogin(item, true));
            }
            else
            {
                return View();
            }

        }

        public ActionResult Unbind(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<UserProfileExtension>().Where(u => u.LineID == viewModel.LineID)
                    .Select(u => u.UserProfile).FirstOrDefault();

            if (item != null)
            {
                return View(item);
            }
            else
            {
                return View("Index");
            }

        }

        public ActionResult CommitUnbound(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();

            if (item != null)
            {
                item.UserProfileExtension.LineID = null;
                models.SubmitChanges();
            }

            return View("Index");

        }


        public async Task<ActionResult> BindUserAsync(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            viewModel.LineID = viewModel.LineID.GetEfficientString();
            if (viewModel.LineID == null)
            {
                ModelState.AddModelError("PID", "您輸入的Line ID錯誤，請確認後再重新輸入!!");
            }

            viewModel.MemberCode = viewModel.MemberCode.GetEfficientString();
            if (viewModel.MemberCode == null)
            {
                ModelState.AddModelError("MemberCode", "會員編號資料錯誤，請確認後再重新輸入!!");
            }

            viewModel.PID = viewModel.PID.GetEfficientString();
            if (viewModel.PID == null || !Regex.IsMatch(viewModel.PID, "\\w+([-+.']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"))
            {
                ModelState.AddModelError("PID", "電子信箱資料錯誤，請確認後再重新輸入!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                ViewBag.SingleError = true;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            UserProfile item = models.GetTable<UserProfile>()
                .Where(u => u.MemberCode == viewModel.MemberCode
                        || u.UserProfileExtension.IDNo == viewModel.MemberCode)
                .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked
                    || u.LevelID == (int)Naming.MemberStatusDefinition.ReadyToRegister)
                .FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            if (item.UserProfileExtension.LineID != null)
            {
                ModelState.AddModelError("PID", "您的帳號已設定過其他Line ID，請確認後再重新輸入!!");
            }

            if (models.GetTable<UserProfileExtension>().Any(u => u.LineID == viewModel.LineID))
            {
                ModelState.AddModelError("PID", "您的Line ID已設定其他使用者帳號，請確認後再重新輸入!!");
            }

            if (models.GetTable<UserProfile>().Any(u => u.PID == viewModel.PID && u.UID != item.UID))
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                ViewBag.ModelState = ModelState;
            }

            if (item.UserProfileExtension.CurrentTrial == 1 || !item.IsLearner())
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
            }

            var pwd = (viewModel.Password).MakePassword();
            if (item.LevelID != (int)Naming.MemberStatusDefinition.ReadyToRegister)
            {
                if (item.Password != pwd)
                {
                    ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                }
            }
            else if (pwd == null)
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
            }
            else
            {
                item.Password = pwd;
                item.LevelID = (int)Naming.MemberStatusDefinition.Checked;
            }


            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                ViewBag.SingleError = true;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            if (item.PID != viewModel.PID)
            {
                item.PID = viewModel.PID;
            }

            item.UserProfileExtension.LineID = viewModel.LineID;
            models.SubmitChanges();

            await HttpContext.SignOnAsync(item);

            //綁定Line贈點活動
            PDQTask taskItem = null;
            if (!models.GetTable<PDQTask>().Any(t => t.UID == item.UID && t.PDQQuestion.GroupID == 8))
            {
                var quest = models.GetTable<PDQQuestion>().Where(q => q.GroupID == 8).FirstOrDefault();
                if (quest != null)
                {
                    taskItem = new PDQTask
                    {
                        QuestionID = quest.QuestionID,
                        UID = item.UID,
                        TaskDate = DateTime.Now,
                        PDQTaskBonus = new PDQTaskBonus 
                        {
                            BonusPoint = quest.PDQQuestionExtension.BonusPoint ?? 1,
                        },
                    };
                    models.GetTable<PDQTask>().InsertOnSubmit(taskItem);
                    models.SubmitChanges();
                }
            }

            return Json(new { result = true, bonus = taskItem!=null });

        }

        public async Task<ActionResult> CommitToRegister(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            viewModel.MemberCode = viewModel.MemberCode.GetEfficientString();
            if (viewModel.MemberCode == null)
            {
                ModelState.AddModelError("MemberCode", "會員編號資料錯誤，請確認後再重新輸入!!");
            }

            viewModel.PID = viewModel.PID.GetEfficientString();
            if (viewModel.PID == null || !Regex.IsMatch(viewModel.PID, "\\w+([-+.']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"))
            {
                ModelState.AddModelError("PID", "電子信箱資料錯誤，請確認後再重新輸入!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                ViewBag.SingleError = true;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.MemberCode == viewModel.MemberCode
                || u.UserProfileExtension.IDNo == viewModel.MemberCode).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            if (models.GetTable<UserProfile>().Any(u => u.PID == viewModel.PID && u.UID != item.UID))
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                ViewBag.ModelState = ModelState;
            }

            if (item.UserProfileExtension.CurrentTrial == 1 /*|| !item.IsLearner()*/)
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
            }

            var pwd = (viewModel.Password).MakePassword();
            if (item.LevelID != (int)Naming.MemberStatusDefinition.ReadyToRegister)
            {
                if (item.Password != pwd)
                {
                    ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                }
            }
            else if (pwd == null)
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
            }
            else
            {
                item.Password = pwd;
                item.LevelID = (int)Naming.MemberStatusDefinition.Checked;
            }


            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                ViewBag.SingleError = true;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            if (item.PID != viewModel.PID)
            {
                item.PID = viewModel.PID;
            }

            models.SubmitChanges();

            await HttpContext.SignOnAsync(item);

            return Json(new { result = true });

        }


        [Authorize]
        public ActionResult Settings(bool? learnerSettings,bool? bonus)
        {
            ViewBag.LearnerSettings = learnerSettings;
            ViewBag.LineBonus = bonus;
            return View();
        }

        [Authorize]
        public async Task<ActionResult> CommitSettings(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            viewModel.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.UserName == null)
            {
                ModelState.AddModelError("UserName", "請輸入暱稱!!");
            }


            UserProfile item = (await HttpContext.GetUserAsync()).LoadInstance(models);

            if (viewModel.LearnerSettings == true)
            {
                viewModel.PID = viewModel.PID.GetEfficientString();
                if (viewModel.PID != null)
                {
                    if (item.PID != viewModel.PID && models.GetTable<UserProfile>().Any(u => u.PID == viewModel.PID && u.UID != item.UID))
                    {
                        ModelState.AddModelError("EMail", "您的Email已經是註冊使用者!!請重新設定Email!!");
                    }
                    else
                    {
                        item.PID = viewModel.PID;
                    }
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }
            
            item.UserName = viewModel.UserName;
            models.SubmitChanges();

            return View("~/Views/Html/Module/AutoLogin.cshtml", model: this.ProcessLogin(item, true));

        }

        public async Task<ActionResult> NoticeAsync(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.LineID = viewModel.KeyID.DecryptKey();
            }
            var item = models.GetTable<UserProfileExtension>().Where(u => u.LineID == viewModel.LineID)
                    .Select(u => u.UserProfile)
                    .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                    .FirstOrDefault();

            if (item != null)
            {
                await HttpContext.SignOnAsync(item);
                return View("~/Views/CornerKick/Notice.cshtml", item);
            }
            else
            {
                ViewBag.Message = "此支裝置尚未設定過專屬服務，請點選下方更多資訊/專屬服務/帳號設定才可使用！";
                return View("Index");
            }

        }

        public ActionResult NoticeNotFound(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }

        public ActionResult DataNotFound(DataItemViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }


        public async Task<ActionResult> CheckAttendanceAsync(RegisterViewModel viewModel)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item != null)
            {
                return View("CheckAttendance", item.LoadInstance(models));
            }

            ViewResult result = (ViewResult)await NoticeAsync(viewModel);
            item = result.Model as UserProfile;

            if(item!=null)
            {
                result.ViewName = "CheckAttendance";
            }

            return result;
        }

        [Authorize]
        public async Task<ActionResult> LearnerToCheckAttendance()
        {
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);
            return View("CheckAttendance", profile);
        }


        public ActionResult AttendanceAccomplished(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }

        [Authorize]
        public async Task<ActionResult> CommitAttendanceAsync(LearnerQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);

            if(viewModel.LessonID!=null && viewModel.LessonID.Length>0)
            {
                foreach (var item in models.GetTable<LessonTime>().Where(l => viewModel.LessonID.Contains(l.LessonID)))
                {
                    if (item.GroupingLesson.RegisterLesson.Any(r => r.UID == profile.UID))
                    {
                        item.LessonPlan.CommitAttendance = DateTime.Now;
                        models.SubmitChanges();
                    }
                }
            }

            return View("CheckAttendance",profile);

        }

        [Authorize]
        public async Task<ActionResult> ConfirmAttendanceAsync(LearnerQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);

            int? lessonID = viewModel?.LessonID?[0];
            if (viewModel.KeyID != null)
            {
                lessonID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<LessonTime>().Where(l => l.LessonID == lessonID)
                    .FirstOrDefault();
            if (item != null)
            {
                ViewBag.DataItem = item;
                return View("ConfirmAttendance", profile);
            }

            return View("CheckAttendance", profile);

        }

        [Authorize]
        public async Task<ActionResult> WriteOffAttendanceAsync(LearnerQueryViewModel viewModel)
        {
            ViewResult result = await ConfirmAttendanceAsync(viewModel) as ViewResult;
            LessonTime item = ViewBag.DataItem as LessonTime;

            if (item == null)
            {
                return result;
            }

            viewModel.WriteoffCode = viewModel.WriteoffCode.GetEfficientString();
            if (item.AsAttendingCoach.UserProfile.Phone != viewModel.WriteoffCode)
            {
                ModelState.AddModelError("WriteoffCode", "兌換核銷密碼欄位資料錯誤，請確認後再重新輸入");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            item.LessonPlan.CommitAttendance = DateTime.Now;
            item.LessonPlan.Remark = $"{item.AsAttendingCoach.UserProfile.FullName()}治療完成";
            var execution = item.TrainingPlan.FirstOrDefault()?.TrainingExecution;
            if (execution != null)
            {
                execution.Emphasis = "AT課程";
            }
            models.SubmitChanges();

            models.AttendLesson(item, item.AsAttendingCoach.UserProfile);
            return Json(new { result = true });
        }


        [Authorize]
        public async Task<ActionResult> CommitCurrentUserEventAsync(UserEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);

            if (viewModel.KeyID != null)
            {
                viewModel.EventID = viewModel.DecryptKeyValue();
            }

            var eventItem = models.GetTable<UserEvent>()
                    .Where(v => v.EventID == viewModel.EventID)
                    .Where(v => v.UID == profile.UID)
                    .FirstOrDefault();

            if (eventItem != null)
            {
                if (eventItem.UserEventCommitment == null)
                {
                    eventItem.UserEventCommitment = new UserEventCommitment
                    {
                        CommitmentDate = DateTime.Now,
                    };
                    models.SubmitChanges();
                }
            }

            return View("~/Views/CornerKick/LearnerIndex.cshtml", profile);

        }


        [Authorize]
        public async Task<ActionResult> AnswerDailyQuestionAsync()
        {
            var profile = await HttpContext.GetUserAsync();
            var item = models.PromptLearnerDailyQuestion(profile);
            return View("AnswerDailyQuestion", item);
        }

        [Authorize]
        public async Task<ActionResult> MyContractAsync()
        {
            var profile = await HttpContext.GetUserAsync();
            var items = models.PromptEffectiveContract()
                .Where(c => c.CourseContractMember.Any(m => m.UID == profile.UID));

            var lessons = models.GetTable<RegisterLesson>()
                .Where(r => r.UID == profile.UID)
                .Where(r => r.Attended != (int)Naming.LessonStatus.課程結束);

            if (items.Count() > 0 || lessons.Count() > 0)
            {
                ViewBag.DataItems = lessons;
                return View("~/Views/CornerKick/MyContract.cshtml", items);
            }
            else
            {
                ViewBag.ViewModel = new DataItemViewModel
                {
                    Title = "我的合約",
                    Message = "目前尚未規劃任何訓練，<br/>若有興趣請與您的教練一起規劃訓練內容喔！",
                };
                return View("~/Views/CornerKick/DataNotFound.cshtml");
            }
        }

        public async Task<ActionResult> ToSignCourseContractAsync(CourseContractQueryViewModel viewModel, String encUID)
        {
            int? uid = null;
            if (encUID != null)
            {
                uid = encUID.DecryptKeyValue();
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (item != null)
            {
                await HttpContext.SignOnAsync(item);
                return await SignCourseContractAsync(viewModel);
            }
            else
            {
                //ViewBag.Message = "此支裝置尚未設定過專屬服務，請點選下方更多資訊/專屬服務/帳號設定才可使用！";
                return View("Index");
            }
        }

        public async Task<ActionResult> ToSignContractServiceAsync(CourseContractQueryViewModel viewModel, String encUID)
        {
            int? uid = null;
            if (encUID != null)
            {
                uid = encUID.DecryptKeyValue();
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (item != null)
            {
                await HttpContext.SignOnAsync(item);
                return await SignContractServiceAsync (viewModel);
            }
            else
            {
                //ViewBag.Message = "此支裝置尚未設定過專屬服務，請點選下方更多資訊/專屬服務/帳號設定才可使用！";
                return View("Index");
            }
        }



        [Authorize]
        public async Task<ActionResult> SignCourseContractAsync(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            var profile = await HttpContext.GetUserAsync();

            var item = models.GetTable<CourseContract>()
                .Where(c => c.ContractID == viewModel.ContractID)
                .Where(c => c.CourseContractMember.Any(m => m.UID == profile.UID))
                .FirstOrDefault();

            if (item == null)
            {
                ViewBag.ViewModel = new DataItemViewModel
                {
                    Title = "我的合約",
                    Message = "目前尚未規劃任何訓練，<br/>若有興趣請與您的教練一起規劃訓練內容喔！",
                };
                return View("~/Views/CornerKick/DataNotFound.cshtml");
            }
            else if (item.Status != (int)Naming.CourseContractStatus.待簽名)
            {
                ViewBag.ViewModel = new DataItemViewModel
                {
                    Title = "我的合約",
                    Message = "合約狀態不符！",
                };
                return View("~/Views/CornerKick/ErrorMessage.cshtml");
            }

            ViewBag.DataItem = item;
            return View("~/Views/CornerKick/SignCourseContract.cshtml", profile.LoadInstance(models));
        }

        [Authorize]
        public async Task<ActionResult> SignGDPRAgreementAsync(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            var profile = await HttpContext.GetUserAsync();

            var item = models.GetTable<CourseContract>()
                .Where(c => c.ContractID == viewModel.ContractID)
                .Where(c => c.CourseContractMember.Any(m => m.UID == profile.UID))
                .FirstOrDefault();

            if (item == null)
            {
                ViewBag.ViewModel = new DataItemViewModel
                {
                    Title = "我的合約",
                    Message = "目前尚未規劃任何訓練，<br/>若有興趣請與您的教練一起規劃訓練內容喔！",
                };
                return View("~/Views/CornerKick/DataNotFound.cshtml");
            }

            ViewBag.DataItem = item;
            return View("~/Views/CornerKick/SignGDPRAgreement.cshtml", profile.LoadInstance(models));
        }

        [Authorize]
        public async Task<ActionResult> SignContractServiceAsync(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            var profile = await HttpContext.GetUserAsync();

            var item = models.GetTable<CourseContract>()
                .Where(c => c.ContractID == viewModel.ContractID)
                .Where(c => c.CourseContractMember.Any(m => m.UID == profile.UID))
                .FirstOrDefault();

            if (item == null)
            {
                ViewBag.ViewModel = new DataItemViewModel
                {
                    Title = "我的合約",
                    Message = "目前尚未規劃任何訓練，<br/>若有興趣請與您的教練一起規劃訓練內容喔！",
                };
                return View("~/Views/CornerKick/DataNotFound.cshtml");
            }
            else if (item.Status != (int)Naming.CourseContractStatus.待簽名)
            {
                ViewBag.ViewModel = new DataItemViewModel
                {
                    Title = "我的合約",
                    Message = "合約狀態不符！",
                };
                return View("~/Views/CornerKick/ErrorMessage.cshtml");
            }

            ViewBag.DataItem = item;
            return View("~/Views/CornerKick/SignContractService.cshtml", profile.LoadInstance(models));
        }


        [Authorize]
        public async Task<ActionResult> ConfirmSignatureAsync(CourseContractViewModel viewModel, CourseContractSignatureViewModel signatureViewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (viewModel.Agree != true)
            {
                ModelState.AddModelError("Message", "請閱讀並同意BF隱私政策、服務條款、相關使用及消費合約，即表示即日起您同意接受本合約正面及背面條款之相關約束及其責任");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }
            else if (viewModel.Booking != true)
            {
                ModelState.AddModelError("Message", "請閱讀並同意第8條服務預約之規定");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }
            else if (viewModel.Extension != true)
            {
                ModelState.AddModelError("Message", "請閱讀並同意第9條體能/健康顧問服務期間與一般展延之申請之規定");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            viewModel.SignerPIN = viewModel.SignerPIN.GetEfficientString();
            if (viewModel.SignerPIN == null)
            {
                ModelState.AddModelError("SignerPIN", "動態密碼輸入錯誤，請確認後再重新輸入");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            CourseContract item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("Message", "合約資料錯誤!!");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            if (viewModel.SignerPIN != item.CourseContractExtension.SignerPIN)
            {
                ModelState.AddModelError("SignerPIN", "動態密碼輸入錯誤，請確認後再重新輸入");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            if (item.InstallmentID.HasValue)
            {
                foreach(var c in models.GetTable<CourseContract>().Where(c => c.InstallmentID == item.InstallmentID))
                {
                    var contract = await commitSignatureAsync(viewModel, signatureViewModel, c);
                    if (contract == null)
                    {
                        ModelState.AddModelError("Message", ModelState.ErrorMessage());
                        ViewBag.AlertError = true;
                        ViewBag.ModelState = this.ModelState;
                        return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
                    }
                }
            }
            else
            {
                item = await commitSignatureAsync(viewModel, signatureViewModel, item);
                if (item == null)
                {
                    ModelState.AddModelError("Message", ModelState.ErrorMessage());
                    ViewBag.AlertError = true;
                    ViewBag.ModelState = this.ModelState;
                    return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
                }
            }

            if (signatureViewModel.NextStep == true)
            {
                ViewBag.ViewModel = new QueryViewModel
                {
                    UrlAction = Url.Action("SignGDPRAgreement", "CornerKick", new { KeyID = item.ContractID.EncryptKey() }),
                };
                return View("~/Views/CornerKick/Shared/ViewModelCommitted.cshtml");
            }

            String jsonData = await RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyToContractPayment.cshtml", item);
            jsonData.PushLineMessage();

            ViewBag.ViewModel = new QueryViewModel
            {
                UrlAction = Url.Action("MyContract", "CornerKick"),
            };
            return View("~/Views/CornerKick/Shared/ViewModelCommitted.cshtml");
        }

        [Authorize]
        public async Task<ActionResult> ConfirmGDPRWithSignatureAsync(CourseContractViewModel viewModel, CourseContractSignatureViewModel signatureViewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            CourseContract item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("Message", "合約資料錯誤!!");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            if (item.InstallmentID.HasValue)
            {
                foreach (var c in models.GetTable<CourseContract>().Where(c => c.InstallmentID == item.InstallmentID))
                {
                    var contract = await commitSignatureAsync(viewModel, signatureViewModel, c);
                    if (contract == null)
                    {
                        ModelState.AddModelError("Message", ModelState.ErrorMessage());
                        ViewBag.AlertError = true;
                        ViewBag.ModelState = this.ModelState;
                        return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
                    }
                }
            }
            else
            {
                item = await commitSignatureAsync(viewModel, signatureViewModel, item);
                if (item == null)
                {
                    ModelState.AddModelError("Message", ModelState.ErrorMessage());
                    ViewBag.AlertError = true;
                    ViewBag.ModelState = this.ModelState;
                    return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
                }
            }

            String jsonData = await RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyToContractPayment.cshtml", item);
            jsonData.PushLineMessage();

            ViewBag.ViewModel = new QueryViewModel
            {
                UrlAction = Url.Action("MyContract", "CornerKick"),
            };
            return View("~/Views/CornerKick/Shared/ViewModelCommitted.cshtml");
        }

        [Authorize]
        public async Task<ActionResult> ConfirmContractServiceSignatureAsync(CourseContractViewModel viewModel, CourseContractSignatureViewModel signatureViewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.Agree != true)
            {
                ModelState.AddModelError("Message", "請閱讀並同意BF隱私政策、服務條款、相關使用及消費合約，即表示即日起您同意接受本合約正面及背面條款之相關約束及其責任");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            viewModel.SignerPIN = viewModel.SignerPIN.GetEfficientString();
            if (viewModel.SignerPIN == null)
            {
                ModelState.AddModelError("SignerPIN", "動態密碼輸入錯誤，請確認後再重新輸入");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            CourseContract item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("Message", "合約資料錯誤!!");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            if (viewModel.SignerPIN != item.CourseContractExtension.SignerPIN)
            {
                ModelState.AddModelError("SignerPIN", "動態密碼輸入錯誤，請確認後再重新輸入");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            item = await commitSignatureAsync(viewModel, signatureViewModel, item);
            if (item == null)
            {
                ModelState.AddModelError("Message", ModelState.ErrorMessage());
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            var jsonData = await RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyToCoachBook.cshtml", item);
            jsonData.PushLineMessage();

            ViewBag.ViewModel = new QueryViewModel
            {
                UrlAction = Url.Action("MyContract", "CornerKick"),
            };
            return View("~/Views/CornerKick/Shared/ViewModelCommitted.cshtml");
        }

        private async Task<CourseContract> commitSignatureAsync(CourseContractViewModel viewModel, CourseContractSignatureViewModel signatureViewModel, CourseContract item)
        {
            var profile = await HttpContext.GetUserAsync();

            for (int i = 0; i < (signatureViewModel.SignatureCount ?? 1); i++)
            {
                String signatureName = $"{signatureViewModel.SignatureName}{i:#}";
                var sigItem = models.GetTable<CourseContractSignature>()
                    .Where(s => s.ContractID == item.ContractID)
                    .Where(s => s.UID == profile.UID)
                    .Where(s => s.SignatureName == signatureName)
                    .FirstOrDefault();

                if (sigItem == null)
                {
                    sigItem = new CourseContractSignature
                    {
                        ContractID = item.ContractID,
                        UID = profile.UID,
                        SignatureName = signatureName,
                    };
                    models.GetTable<CourseContractSignature>().InsertOnSubmit(sigItem);
                }

                sigItem.Signature = signatureViewModel.Signature;
                models.SubmitChanges();
            }

            if (item.CourseContractRevision != null)
            {
                return await viewModel.ConfirmContractServiceSignatureAsync(this, item.CourseContractRevision);
            }
            else if (signatureViewModel.NextStep == true)
            {
                return item;
            }
            else
            {
                return await viewModel.ConfirmContractSignatureAsync(this, item);
            }
        }

        [Authorize]
        public async Task<ActionResult> CommitAnswerDailyQuestionAsync(DailyQuestionViewModel viewModel)
        {

            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if(viewModel.KeyID!=null)
            {
                viewModel.QuestionID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<PDQQuestion>().Where(q => q.QuestionID == viewModel.QuestionID).FirstOrDefault();
            if (item == null || !viewModel.SuggestionID.HasValue)
            {
                return await AnswerDailyQuestionAsync();
            }

            if (models.GetTable<PDQTask>().Any(t => t.UID == profile.UID
                 && t.TaskDate >= DateTime.Today && t.TaskDate < DateTime.Today.AddDays(1)
                 && t.PDQQuestion.GroupID == 6))
            {
                return await AnswerDailyQuestionAsync();
            }

            var taskItem = new PDQTask
            {
                QuestionID = item.QuestionID,
                SuggestionID = viewModel.SuggestionID,
                UID = profile.UID,
                TaskDate = DateTime.Now
            };
            models.GetTable<PDQTask>().InsertOnSubmit(taskItem);
            models.SubmitChanges();

            if (item.PDQSuggestion.Any(s => s.SuggestionID == viewModel.SuggestionID && s.RightAnswer == true))
            {
                if (item.PDQQuestionExtension != null)
                {
                    taskItem.PDQTaskBonus = new PDQTaskBonus 
                    {
                        BonusPoint = item.PDQQuestionExtension.BonusPoint ?? 1,
                    };
                    models.SubmitChanges();
                }
            }

            return await AnswerDailyQuestionAsync();
        }

        [Authorize]
        public async Task<ActionResult> LearnerIndexAsync()
        {
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);
            return View("~/Views/CornerKick/LearnerIndex.cshtml", profile);
        }

        public ActionResult Logout(RegisterViewModel viewModel,String message = null)
        {
            this.HttpContext.Logout();
            ViewBag.Message = message;
            return Index(viewModel);
        }

        [Authorize]
        public async Task<ActionResult> LearnerNoticeAsync()
        {
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);
            return View("~/Views/CornerKick/Notice.cshtml", profile);
        }

        public async Task<ActionResult> ResetPasswordAsync(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            UserProfile item;
            if (viewModel.UUID != null)
            {
                item = models.GetTable<ResetPassword>().Where(r => r.ResetID == viewModel.UUID)
                    .Select(r => r.UserProfile)
                    .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                    .FirstOrDefault();
            }
            else
            {
                item = (await HttpContext.GetUserAsync())?.LoadInstance(models);
            }

            if (item == null)
            {
                return Index(viewModel);
            }

            return View(item);
        }

        public async Task<ActionResult> CommitPasswordAsync(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            UserProfile item;
            if (viewModel.UUID != null)
            {
                item = models.GetTable<ResetPassword>().Where(r => r.ResetID == viewModel.UUID)
                    .Select(r => r.UserProfile)
                    .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                    .FirstOrDefault();
            }
            else
            {
                item = (await HttpContext.GetUserAsync())?.LoadInstance(models);
            }

            if (item == null)
            {
                if (viewModel.KeyID != null)
                {
                    viewModel.UID = viewModel.DecryptKeyValue();
                }
                item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            }

            if (item == null)
            {
                return await LoginAsync(viewModel);
            }

            var pwd = (viewModel.Password).MakePassword();
            if (pwd == null)
            {
                ModelState.AddModelError("Password", "您輸入的資料錯誤，請確認後再重新輸入!!");
            }
            else if (viewModel.Password.ToUpper() == "BEYOND")
            {
                ModelState.AddModelError("Password", "您所輸入的密碼安全性不足，請重新設定!!");
            }
            else
            {
                item.Password = pwd;
                item.LevelID = (int)Naming.MemberStatusDefinition.Checked;
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                ViewBag.SingleError = true;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            models.SubmitChanges();

            //if (viewModel.UUID != null)
            //{
                await HttpContext.SignOnAsync(item);
            //}

            return View("~/Views/CornerKick/Module/CommitPassword.cshtml", item);

        }

        [Authorize]
        public async Task<ActionResult> TrainingAnalysisAsync()
        {
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);
            return View(profile);
        }

        [Authorize]
        public async Task<ActionResult> AnnouncementAsync(UserEventViewModel viewModel)
        {
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);
            if (viewModel.KeyID != null)
            {
                viewModel.EventID = viewModel.DecryptKeyValue();
            }

            var eventItem = models.GetTable<UserEvent>()
                    .Where(v => v.EventID == viewModel.EventID)
                    .Where(v => v.UID == profile.UID)
                    .FirstOrDefault();

            if (eventItem != null)
            {
                ViewBag.EventItem = eventItem;
                return View(profile);
            }
            else
            {
                return View("~/Views/CornerKick/LearnerIndex.cshtml", profile);
            }
        }


        [Authorize]
        public async Task<ActionResult> LearnerTrainingGoalAsync()
        {
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);
            return View(profile);
        }

        [Authorize]
        public async Task<ActionResult> LearnerToCheckTrainingGoalAsync()
        {
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);
            models.ExecuteCommand(@"UPDATE PersonalExercisePurposeItem
                            SET        NoticeStatus = {0}
                            WHERE   (UID = {1})", (int)Naming.IncommingMessageStatus.已讀, profile.UID);
            return View("LearnerTrainingGoal", profile);
        }


        [Authorize]
        public async Task<ActionResult> StartNavigationAsync(UserEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.EventID = viewModel.DecryptKeyValue();
            }

            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);
            if (viewModel.EventID.HasValue)
            {
                models.ExecuteCommand("delete UserEvent where UID={0} and EventID={1}", profile.UID, viewModel.EventID);
            }

            return View(profile);
        }

        [Authorize]
        public async Task<ActionResult> CheckBonusPointAsync(AwardQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);
            return View("~/Views/CornerKick/CheckBonusPoint2021.cshtml", profile);
        }


        public async Task<ActionResult> TodayLessonAsync(RegisterViewModel viewModel)
        {
            ViewResult result = (ViewResult)await NoticeAsync(viewModel);
            UserProfile item = result.Model as UserProfile;

            if (item != null)
            {
                return View("TodayLesson", item);
            }
            else
            {
                return result;
            }
        }

        public async Task<ActionResult> CheckBonusPointByLineAsync(RegisterViewModel viewModel)
        {
            ViewResult result = (ViewResult)await NoticeAsync(viewModel);
            UserProfile item = result.Model as UserProfile;

            if (item != null)
            {
                return View("~/Views/CornerKick/CheckBonusPoint2021.cshtml", item);
            }
            else
            {
                return result;
            }
        }

        [Authorize]
        public async Task<ActionResult> ViewLessonAsync(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if(viewModel.KeyID!=null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            ViewBag.DataItem = models.GetTable<LessonTime>().Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);
            return View("~/Views/CornerKick/TodayLesson.cshtml", profile);
        }

        [Authorize]
        public async Task<ActionResult> AboutOnlineLessonAsync(LessonTimeBookingViewModel viewModel)
        {
            ViewResult result = (ViewResult)await ViewLessonAsync(viewModel);
            result.ViewName = "~/Views/CornerKick/AboutOnlineLesson.cshtml";

            return result;
        }


        public async Task<ActionResult> SignOnAsync(LoginViewModel viewModel, string returnUrl)
        {
            ViewBag.ViewModel = viewModel;

            UserProfile item = viewModel.ValiateLogin(models, ModelState);

            if (item == null)
            {
                ViewBag.ModelState = ModelState;
                return View("Login");
            }
            
            if (viewModel.Password.ToUpper() == "BEYOND")
            {
                return View("ResetPassword", item);
            }

            await HttpContext.SignOnAsync(item, viewModel.RememberMe);

            if (!String.IsNullOrEmpty(returnUrl))
            {
                return View("~/Views/Html/Module/AutoLogin.cshtml", model: returnUrl);
            }

            return View("~/Views/Html/Module/AutoLogin.cshtml", model: this.ProcessLogin(item, false));

        }

        public ActionResult CommitToForgetPassword(String email)
        {
            if (String.IsNullOrEmpty(email))
            {
                ModelState.AddModelError("email", "請輸入您的 email address");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }


            UserProfile item = models.GetTable<UserProfile>().Where(u => u.PID == email.Trim()
                && u.LevelID == (int)Naming.MemberStatusDefinition.Checked).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("email", "您輸入的資料錯誤，請確認後再重新輸入!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            ResetPassword toReset = new ResetPassword
            {
                ResetID = Guid.NewGuid(),
                UserProfile = item
            };

            models.GetTable<ResetPassword>().InsertOnSubmit(toReset);
            models.SubmitChanges();

            toReset.NotifyResetPassword(notifyUrl:$"{Startup.Properties["HostDomain"]}{VirtualPathUtility.ToAbsolute("~/CornerKick/NotifyResetPassword")}");

            return View("~/Views/Shared/JsAlert.cshtml", model: "重設密碼通知郵件已寄出!!");

        }

        public ActionResult NotifyResetPassword(String resetID)
        {
            return View("NotifyResetPassword", model: resetID);
        }

        [Authorize]
        public async Task<ActionResult> LearnerCalendarAsync()
        {
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);
            return View(profile);
        }

        [Authorize]
        public async Task<ActionResult> LearnerEventsAsync(DateTime dateFrom, DateTime? dateTo)
        {
            ViewBag.StartDate = dateFrom;
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);
            return View("~/Views/CornerKick/Module/LearnerEvents.cshtml", profile);
        }

        [Authorize]
        public async Task<ActionResult> EditUserEventAsync(UserEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);

            if(viewModel.KeyID!=null)
            {
                viewModel.EventID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<UserEvent>().Where(v => v.EventID == viewModel.EventID && v.UID == profile.UID).FirstOrDefault();
            if (item != null)
            {
                viewModel.UID = item.UID;
                viewModel.StartDate = item.StartDate;
                viewModel.EndDate = item.EndDate;
                viewModel.Title = item.Title;
            }

            return View("~/Views/CornerKick/EditUserEvent.cshtml", profile);
        }

        [Authorize]
        public async Task<ActionResult> CommitUserEventAsync(UserEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = await HttpContext.GetUserAsync();

            if (!viewModel.StartDate.HasValue)
            {
                ModelState.AddModelError("StartDate", "請選擇開始時間!!");
            }
            if (!viewModel.EndDate.HasValue)
            {
                ModelState.AddModelError("EndDate", "請選擇結束時間!!");
            }

            if(viewModel.StartTime.HasValue)
            {
                viewModel.StartDate = viewModel.StartDate.Value + viewModel.StartTime.Value;
            }

            if (viewModel.EndTime.HasValue)
            {
                viewModel.EndDate = viewModel.EndDate.Value + viewModel.EndTime.Value;
            }

            if (viewModel.StartDate > viewModel.EndDate)
            {
                ModelState.AddModelError("StartDate", "開始日期晚於結束日期!!");
            }


            if (String.IsNullOrEmpty(viewModel.Title))
            {
                ModelState.AddModelError("Title", "請輸入行事曆內容!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            var item = models.GetTable<UserEvent>().Where(u => u.EventID == viewModel.EventID).FirstOrDefault();
            if (item == null)
            {
                item = new UserEvent
                {
                    UID = profile.UID
                };
                models.GetTable<UserEvent>().InsertOnSubmit(item);
                viewModel.CreateNew = true;
            }

            item.StartDate = viewModel.StartDate.Value;
            item.EndDate = viewModel.EndDate.Value;
            item.Title = viewModel.Title;

            models.SubmitChanges();

            return View("~/Views/CornerKick/Module/CompleteUserEvent.cshtml", item);
        }

        [Authorize]
        public async Task<ActionResult> ShowLearnerEventAsync(UserEventViewModel viewModel)
        {
            var profile = await HttpContext.GetUserAsync();

            var eventItem = models.GetTable<UserEvent>().Where(v => v.UID == profile.UID && v.EventID == viewModel.EventID).FirstOrDefault();
            if (eventItem != null)
            {
                return await EditUserEventAsync(viewModel);
            }

            var lessonItem = models.GetTable<LessonTime>().Where(l => l.LessonID == viewModel.EventID).FirstOrDefault();
            if (lessonItem != null)
            {
                ViewBag.DataItem = lessonItem;
                return View("~/Views/CornerKick/TodayLesson.cshtml", profile.LoadInstance(models));
            }

            return View("LearnerCalendar", profile.LoadInstance(models));
        }

        [Authorize]
        public async Task<ActionResult> DeleteLearnerEventAsync(UserEventViewModel viewModel)
        {
            var profile = await HttpContext.GetUserAsync();
            var eventItem = models.DeleteAny<UserEvent>(v => v.UID == profile.UID && v.EventID == viewModel.EventID);
            return View("LearnerCalendar", profile.LoadInstance(models));
        }

        public async Task<ActionResult> WriteOffBonusPointAsync(AwardQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel = JsonConvert.DeserializeObject<AwardQueryViewModel>(viewModel.KeyID.DecryptKey());
            }

            ViewBag.ViewModel = viewModel;

            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);


            var item = models.GetTable<BonusAwardingItem>().Where(i => i.ItemID == viewModel.ItemID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "兌換商品錯誤!!" });
            }

            if (profile.BonusPoint(models) < item.PointValue)
            {
                return Json(new { result = false, message = "累積點數不足!!" });
            }

            ViewBag.DataItem = item;

            if (viewModel.Confirmed == true)
            {
                return View("~/Views/CornerKick/WriteOffBonusPoint.cshtml", profile);
            }
            else
            {
                viewModel.Confirmed = true;
                ViewBag.ViewModel = new QueryViewModel
                {
                    UrlAction = Url.Action("WriteOffBonusPoint"),
                    KeyID = viewModel.JsonStringify().EncryptKey()
                };
                return View("~/Views/CornerKick/Shared/ViewModelCommitted.cshtml");
            }
        }

        public async Task<ActionResult> ExchangeBonusPointAsync(AwardQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);

            var item = models.GetTable<BonusAwardingItem>().Where(i => i.ItemID == viewModel.ItemID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "兌換商品錯誤!!" });
            }

            if (profile.BonusPoint(models) < item.PointValue)
            {
                return Json(new { result = false, message = "累積點數不足!!" });
            }

            viewModel.WriteoffCode = viewModel.WriteoffCode.GetEfficientString();
            int? recipientID = null;
            if (item.BonusAwardingLesson != null)
            {
                viewModel.ActorID = profile.UID;

                if (item.BonusAwardingIndication != null && item.BonusAwardingIndication.Indication == "AwardingLessonGift")
                {
                    var users = models.GetTable<UserProfile>()
                        .Where(u => u.UID != profile.UID)
                        .Where(u => u.LevelID != (int)Naming.MemberStatusDefinition.Deleted
                                && u.LevelID != (int)Naming.MemberStatusDefinition.Anonymous)
                        .Where(l => l.Phone == viewModel.WriteoffCode)
                        .FilterByLearner(models)
                        .Where(u => u.UserProfileExtension != null && !u.UserProfileExtension.CurrentTrial.HasValue);

                    int count = users.Count();

                    if (count == 0)
                    {
                        ModelState.AddModelError("WriteoffCode", "受贈會員資料錯誤，請確認後再重新輸入");
                    }
                    else if (count > 1)
                    {
                        ModelState.AddModelError("WriteoffCode", "受贈學員手機號碼重複，請連絡您的體能顧問");
                    }
                    else
                    {
                        recipientID = users.First().UID;
                    }
                }
            }
            else
            {
                var coach = models.PromptEffectiveCoach(models.GetTable<UserProfile>().Where(l => l.Phone == viewModel.WriteoffCode)).FirstOrDefault();
                if (coach == null)
                {
                    ModelState.AddModelError("WriteoffCode", "兌換核銷密碼欄位資料錯誤，請確認後再重新輸入");
                }
                else
                {
                    viewModel.ActorID = coach.CoachID;
                }
            }

            if(!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/CornerKick/Shared/ReportInputError.cshtml");
            }

            var award = new LearnerAward
            {
                UID = profile.UID,
                AwardDate = DateTime.Now,
                ItemID = item.ItemID,
                ActorID = viewModel.ActorID.Value,
            };
            models.GetTable<LearnerAward>().InsertOnSubmit(award);

            int usedPoints = item.PointValue;
            foreach (var bonusItem in profile.BonusPointList(models))
            {
                if (usedPoints <= 0)
                    break;
                award.BonusExchange.Add(new BonusExchange
                {
                    TaskID = bonusItem.TaskID
                });
                int currentUsed = Math.Min(usedPoints, bonusItem.BonusPoint.Value);
                usedPoints -= currentUsed;
                bonusItem.BonusPoint -= currentUsed;
                //usedPoints -= bounsItem.PDQTask.PDQQuestion.PDQQuestionExtension.BonusPoint.Value;
            }

            ///兌換課程
            ///
            if (item.BonusAwardingLesson != null)
            {
                var lesson = models.GetTable<RegisterLesson>().Where(r => r.UID == profile.UID)
                    .Join(models.GetTable<RegisterLessonContract>(), r => r.RegisterID, c => c.RegisterID, (r, c) => r)
                    .OrderByDescending(r => r.RegisterID).FirstOrDefault();

                if (item.BonusAwardingIndication != null && item.BonusAwardingIndication.Indication == "AwardingLessonGift")
                {
                    var giftLesson = new RegisterLesson
                    {
                        RegisterDate = DateTime.Now,
                        GroupingMemberCount = 1,
                        ClassLevel = item.BonusAwardingLesson.PriceID,
                        Lessons = 1,
                        UID = recipientID.Value,
                        AdvisorID = lesson?.RegisterLessonContract.CourseContract.FitnessConsultant,
                        Attended = (int)Naming.LessonStatus.準備上課,
                        GroupingLesson = new GroupingLesson { }
                    };
                    award.AwardingLessonGift = new AwardingLessonGift
                    {
                        RegisterLesson = giftLesson
                    };
                    models.GetTable<RegisterLesson>().InsertOnSubmit(giftLesson);
                }
                else
                {
                    var awardLesson = new RegisterLesson
                    {
                        RegisterDate = DateTime.Now,
                        GroupingMemberCount = 1,
                        ClassLevel = item.BonusAwardingLesson.PriceID,
                        Lessons = 1,
                        UID = profile.UID,
                        AdvisorID = lesson?.AdvisorID,
                        Attended = (int)Naming.LessonStatus.準備上課,
                        GroupingLesson = new GroupingLesson { }
                    };
                    award.AwardingLesson = new AwardingLesson
                    {
                        RegisterLesson = awardLesson
                    };
                    models.GetTable<RegisterLesson>().InsertOnSubmit(awardLesson);
                }
            }

            models.SubmitChanges();
            return Json(new { result = true });

        }

        public async Task<ActionResult> PayoffOnLineAsync(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.PaymentID = viewModel.DecryptKeyValue();
            }

            var profile = await HttpContext.GetUserAsync();

            var item = models.GetTable<Payment>()
                .Where(c => c.PaymentID == viewModel.PaymentID)
                .FirstOrDefault();

            if (item == null)
            {
                ViewBag.ViewModel = new DataItemViewModel
                {
                    Title = "我的付款",
                    Message = "付款資料錯誤！",
                };
                return View("~/Views/CornerKick/DataNotFound.cshtml");
            }

            PaymentOnLine paymentItem = new PaymentOnLine
            {
                PaymentID = item.PaymentID,
                oid = Guid.NewGuid().ToString(),
            };

            models.GetTable<PaymentOnLine>().InsertOnSubmit(paymentItem);
            models.SubmitChanges();

            paymentItem.oid = $"{paymentItem.OrderID:000000000000}";
            models.SubmitChanges();

            return View("~/Views/CornerKick/PayoffOnLine.cshtml", paymentItem);
        }

        public async Task<ActionResult> FrontendPayoffAsync(PayoffViewModel viewModel)
        {
            //return CommitPayoff(viewModel);
            var path = await DumpAsync(false);
            return Content(System.IO.File.ReadAllText(path), "text/plain");
        }

        public async Task<ActionResult> CommitPayoffAsync(PayoffViewModel viewModel)
        {
            String path = await DumpAsync();

            ViewBag.ViewModel = viewModel;

            var profile = await HttpContext.GetUserAsync();

            var item = models.GetTable<PaymentOnLine>()
                .Where(c => c.oid == viewModel.oid)
                .FirstOrDefault();

            if (item != null)
            {
                item.mid = viewModel.mid;
                item.tid = viewModel.tid;
                item.oid = viewModel.oid;
                item.pan = viewModel.pan;
                item.transCode = viewModel.transCode;
                item.transMode = viewModel.transMode;
                item.transDate = viewModel.transDate;
                item.transTime = viewModel.transTime;
                item.transAmt = viewModel.transAmt;
                item.approveCode = viewModel.approveCode;
                item.responseCode = viewModel.responseCode;
                item.responseMsg = viewModel.responseMsg;
                item.installmentType = viewModel.installmentType;
                item.installment = viewModel.installment;
                item.firstAmt = viewModel.firstAmt;
                item.eachAmt = viewModel.eachAmt;
                item.fee = viewModel.fee;
                item.redeemType = viewModel.redeemType;
                item.redeemUsed = viewModel.redeemUsed;
                item.redeemBalance = viewModel.redeemBalance;
                item.creditAmt = viewModel.creditAmt;
                item.secureStatus = viewModel.secureStatus.GetEfficientString();

                models.SubmitChanges();

                if ($"{item.PaymentTransaction.Payment.PayoffAmount}" != item.transAmt)
                {
                    int rtnCode = 0;
                    ApiClient apiClient = new ApiClient();

                    apiClient.clear();
                    apiClient.setMid(item.mid);
                    apiClient.setOid(item.oid);
                    apiClient.setTransCode("01");
                    apiClient.setDoname("eposuat.sinopac.com");
                    apiClient.setSecurityId(item.PaymentTransaction.BranchStore.EPOS_SID);
                    try
                    {
                        rtnCode = apiClient.post();
                    }
                    catch (Exception ex)
                    {
                        ApplicationLogging.CreateLogger<CornerKickController>().LogError(ex, ex.Message);
                    }
                }
            }

            //return Content(System.IO.File.ReadAllText(path), "text/plain");

            var result = new
            {
                viewModel.mid,
                viewModel.tid,
                viewModel.oid,
                transCode = $"{viewModel.transCode:00}",
                viewModel.approveCode,
                viewModel.responseCode,
            };

            //Logger.Info(result.JsonStringify());
            return Json(result);

        }
    }
}