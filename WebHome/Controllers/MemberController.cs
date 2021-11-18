using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNetCore.Mvc;
using WebHome.Models.DataEntity;
using WebHome.Models.ViewModel;
using WebHome.Helper;
using System.Threading;
using System.Text;
using WebHome.Models.Locale;
using CommonLib.Utility;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using Microsoft.AspNetCore.Authorization;
using System.Text.RegularExpressions;
using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;

namespace WebHome.Controllers
{
    [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach })]
    public class MemberController : SampleController<UserProfile>
    {
        public MemberController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult ListCoaches()
        {
            MembersQueryViewModel viewModel = (MembersQueryViewModel)HttpContext.GetCacheValue("MembersQuery");
            if (viewModel == null)
            {
                viewModel = new MembersQueryViewModel
                {
                    RoleID = Naming.RoleID.Coach
                };
                HttpContext.SetCacheValue("MembersQuery", viewModel);
            }

            return View("ListCoaches", viewModel);
        }

        
        public ActionResult ListLearners(MembersQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            IQueryable<UserProfile> items = models.GetTable<UserProfile>()    //.Where(u => u.LevelID != (int)Naming.MemberStatusDefinition.Deleted)
                .FilterByLearner(models)
                .OrderByDescending(u => u.UID);

            viewModel.ByName = viewModel.ByName.GetEfficientString();
            if (viewModel.ByName!=null)
            {
                items = items.Where(u => u.UserName.Contains(viewModel.ByName) || u.RealName.Contains(viewModel.ByName) || u.Nickname.Contains(viewModel.ByName));
            }

            return View("ListLearners", items);

        }


        
        public ActionResult AddLearner(LearnerViewModel viewModel)
        {
            return View(viewModel);
        }

        [HttpPost]
        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult CommitLearner(LearnerViewModel viewModel)
        {
            if (!this.ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View(viewModel);
            }

            CreateLearner(viewModel);

            ViewResult result = (ViewResult)ListLearners(null);
            ViewBag.TabIndex = viewModel.CurrentTrial.HasValue ? 1 : 0;
            return result;
        }

        private void CreateLearner(LearnerViewModel viewModel)
        {
            String memberCode;

            while (true)
            {
                memberCode = createMemberCode();
                if (!models.GetTable<UserProfile>().Any(u => u.MemberCode == memberCode))
                {
                    break;
                }
            }

            UserProfile item = new UserProfile
            {
                PID = memberCode,
                MemberCode = memberCode,
                LevelID = (int)Naming.MemberStatusDefinition.ReadyToRegister,
                RealName = viewModel.RealName,
                Phone = viewModel.Phone,
                Birthday = viewModel.Birthday,
                CreateTime = DateTime.Now,
                UserProfileExtension = new UserProfileExtension
                {
                    Gender = viewModel.Gender,
                    AthleticLevel = viewModel.AthleticLevel,
                    CurrentTrial = viewModel.CurrentTrial
                }
            };

            if (viewModel.Birthday.HasValue)
                item.BirthdateIndex = viewModel.Birthday.Value.Month * 100 + viewModel.Birthday.Value.Day;

            item.UserRole.Add(new UserRole
            {
                RoleID = (int)Naming.RoleID.Learner
            });


            models.GetTable<UserProfile>().InsertOnSubmit(item);
            models.SubmitChanges();

            item.InitializeSystemAnnouncement(models);
        }

        private String createMemberCode()
        {
            Thread.Sleep(1);
            Random rnd = new Random();

            return (new StringBuilder()).Append((char)((int)'A' + rnd.Next(26)))
                .Append((char)((int)'A' + rnd.Next(26)))
                .Append(rnd.Next(100000000))
                .ToString();
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult AddCoach(CoachViewModel model)
        {
            return View(model);
        }

        [HttpPost]
        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult CommitCoach(CoachViewModel viewModel)
        {
            if (viewModel.AuthorizedRole == null || viewModel.AuthorizedRole.Length == 0)
            {
                ModelState.AddModelError("AuthorizedRole", "請設定角色!");
            }

            if (!this.ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View(viewModel);
            }

            String memberCode;

            while (true)
            {
                memberCode = createMemberCode();
                if (!models.GetTable<UserProfile>().Any(u => u.MemberCode == memberCode))
                {
                    break;
                }
            }

            UserProfile item = new UserProfile
            {
                PID = memberCode,
                MemberCode = memberCode,
                LevelID = (int)Naming.MemberStatusDefinition.ReadyToRegister,
                RealName = viewModel.RealName,
                Phone = viewModel.Phone,
                Birthday = viewModel.Birthday,
                CreateTime = DateTime.Now,
                UserProfileExtension = new UserProfileExtension { }
            };

            if (viewModel.Birthday.HasValue)
                item.BirthdateIndex = viewModel.Birthday.Value.Month * 100 + viewModel.Birthday.Value.Day;

            models.DeleteAllOnSubmit<UserRole>(r => r.UID == item.UID);
            item.UserRole.Add(new UserRole
            {
                RoleID = viewModel.CoachRole.Value
            });

            models.DeleteAllOnSubmit<UserRoleAuthorization>(r => r.UID == item.UID);
            item.UserRoleAuthorization.AddRange(viewModel.AuthorizedRole.Select(r => new UserRoleAuthorization
            {
                RoleID = r.Value
            }));


            if (viewModel.AuthorizedRole.Contains((int)Naming.RoleID.Manager)
                    || viewModel.AuthorizedRole.Contains((int)Naming.RoleID.Coach)
                    || viewModel.AuthorizedRole.Contains((int)Naming.RoleID.ViceManager))
            {
                if (item.ServingCoach == null)
                {
                    item.ServingCoach = new ServingCoach
                    {
                    };
                }
                item.ServingCoach.Description = viewModel.Description;
                item.ServingCoach.LevelID = viewModel.LevelID;
            }

            models.GetTable<UserProfile>().InsertOnSubmit(item);
            models.SubmitChanges();

            ViewBag.Message = "員工資料新增完成!!";

            return ListCoaches();
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult CommitMember(CoachViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                String memberCode;
                while (true)
                {
                    memberCode = createMemberCode();
                    if (!models.GetTable<UserProfile>().Any(u => u.MemberCode == memberCode))
                    {
                        break;
                    }
                }

                item = new UserProfile
                {
                    PID = memberCode,
                    MemberCode = memberCode,
                    LevelID = (int)Naming.MemberStatusDefinition.ReadyToRegister,
                    Birthday = viewModel.Birthday,
                    CreateTime = DateTime.Now,
                    UserProfileExtension = new UserProfileExtension { }
                };

                if (viewModel.Birthday.HasValue)
                    item.BirthdateIndex = viewModel.Birthday.Value.Month * 100 + viewModel.Birthday.Value.Day;

                models.GetTable<UserProfile>().InsertOnSubmit(item);

            }
            else
            {
                var email = viewModel.Email.GetEfficientString();
                if (email == null)
                {
                    ModelState.AddModelError("Email", "請輸入Email");
                }
                else
                {
                    if (models.GetTable<UserProfile>().Any(u => u.PID == email && u.UID != item.UID))
                    {
                        ModelState.AddModelError("Email", "Email已經是註冊使用者!!");
                    }
                }
            }

            if (viewModel.AuthorizedRole == null || viewModel.AuthorizedRole.Length == 0
                || viewModel.AuthorizedRole.Where(r => r != (int)Naming.RoleID.Learner).Count() == 0)
            {
                ModelState.AddModelError("AuthorizedRole", "請選擇適用角色!!");
            }
            else if (viewModel.AuthorizedRole.Contains((int)Naming.RoleID.Coach))
            {
                if (!viewModel.BranchID.HasValue)
                {
                    ModelState.AddModelError("BranchID", "請選擇隸屬分店!!");
                }
                if (!viewModel.LevelID.HasValue)
                {
                    ModelState.AddModelError("LevelID", "請選擇Level!!");
                }
            }
            else if (viewModel.AuthorizedRole.Contains((int)Naming.RoleID.Manager)
                    || viewModel.AuthorizedRole.Contains((int)Naming.RoleID.ViceManager))
            {
                if (!viewModel.BranchID.HasValue)
                {
                    ModelState.AddModelError("BranchID", "請選擇隸屬分店!!");
                }
            }

            if (viewModel.HasGiftLessons == true && (!viewModel.MonthlyGiftLessons.HasValue || viewModel.MonthlyGiftLessons < 0))
            {
                ModelState.AddModelError("MonthlyGiftLessons", "請輸入堂數!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            models.DeleteAllOnSubmit<UserRole>(r => r.UID == item.UID);

            models.DeleteAllOnSubmit<UserRoleAuthorization>(r => r.UID == item.UID);
            item.UserRoleAuthorization.AddRange(viewModel.AuthorizedRole.Select(r => new UserRoleAuthorization
            {
                RoleID = r.Value
            }));

            if (viewModel.AuthorizedRole.Contains((int)Naming.RoleID.Assistant))
            {
                if (item.EmployeeWelfare == null)
                    item.EmployeeWelfare = new EmployeeWelfare { };
                item.EmployeeWelfare.MonthlyGiftLessons = viewModel.HasGiftLessons == true ? viewModel.MonthlyGiftLessons : null;
            }

            if (viewModel.AuthorizedRole.Any(r => r == (int)Naming.RoleID.Manager
                                || r == (int)Naming.RoleID.ViceManager
                                || r == (int)Naming.RoleID.Officer) && !viewModel.AuthorizedRole.Any(r => r == (int)Naming.RoleID.Coach))
            {
                item.UserRoleAuthorization.Add(new UserRoleAuthorization
                {
                    RoleID = (int)Naming.RoleID.Coach
                });
                item.UserRole.Add(new UserRole
                {
                    RoleID = (int)Naming.RoleID.Coach
                });
            }
            else
            {
                item.UserRole.Add(new UserRole
                {
                    RoleID = viewModel.CoachRole.Value
                });
            }

            ProfessionalLevel professionLevel = null;
            if (viewModel.AuthorizedRole.Any(r => r == (int)Naming.RoleID.Coach
                    || r == (int)Naming.RoleID.Manager
                    || r == (int)Naming.RoleID.ViceManager
                    || r == (int)Naming.RoleID.Officer))
            {
                if (item.ServingCoach == null)
                {
                    item.ServingCoach = new ServingCoach
                    {
                        Description = viewModel.Description
                    };
                }
                models.DeleteAllOnSubmit<CoachWorkplace>(c => c.CoachID == item.UID);
                item.ServingCoach.CoachWorkplace.Add(new CoachWorkplace
                {
                    BranchID = viewModel.BranchID.Value
                });

                if (viewModel.AuthorizedRole.Any(r => r == (int)Naming.RoleID.Coach)
                    && viewModel.LevelID.HasValue)
                {
                    professionLevel = models.GetTable<ProfessionalLevel>().Where(l => l.LevelID == viewModel.LevelID).First();
                    if (item.ServingCoach.LevelID != viewModel.LevelID)
                    {
                        item.ServingCoach.LevelID = viewModel.LevelID;
                        item.ServingCoach.CoachRating.Add(new CoachRating
                        {
                            CoachID = item.ServingCoach.CoachID,
                            LevelID = viewModel.LevelID.Value,
                            RatingDate = DateTime.Now
                        });
                    }
                }
                else if (viewModel.AuthorizedRole.Any(r => r == (int)Naming.RoleID.Manager))
                {
                    professionLevel = item.ServingCoach.ProfessionalLevel = models.GetTable<ProfessionalLevel>().Where(p => p.CategoryID == (int)Naming.ProfessionalCategory.FM).FirstOrDefault();
                }
                else if (viewModel.AuthorizedRole.Any(r => r == (int)Naming.RoleID.ViceManager))
                {
                    professionLevel = item.ServingCoach.ProfessionalLevel = models.GetTable<ProfessionalLevel>().Where(p => p.CategoryID == (int)Naming.ProfessionalCategory.AFM).FirstOrDefault();
                }
                else if (viewModel.AuthorizedRole.Any(r => r == (int)Naming.RoleID.Officer))
                {
                    professionLevel = item.ServingCoach.ProfessionalLevel = models.GetTable<ProfessionalLevel>().Where(p => p.CategoryID == (int)Naming.ProfessionalCategory.Special).FirstOrDefault();
                }

            }
            else
            {
                if (item.ServingCoach != null)
                {
                    item.ServingCoach.LevelID = (int)Naming.ProfessionLevelDefinition.Preliminary;
                }
            }

            item.RealName = viewModel.RealName;
            item.Phone = viewModel.Phone;

            models.SubmitChanges();

            if (professionLevel != null)
            {
                models.ExecuteCommand(@"UPDATE LessonTimeSettlement
                    SET        ProfessionalLevelID = {0}, MarkedGradeIndex = {1}
                    FROM     LessonTime INNER JOIN
                                   LessonTimeSettlement ON LessonTime.LessonID = LessonTimeSettlement.LessonID
                    WHERE   (LessonTime.AttendingCoach = {2}) AND (LessonTime.ClassTime >= {3})",
                        professionLevel.LevelID, professionLevel.GradeIndex, item.UID, new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1));
            }

            return Json(new { result = true });

        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult EditCoachCertificate(int uid)
        {

            ServingCoach item = models.GetTable<ServingCoach>().Where(u => u.CoachID == uid).FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            return View("~/Views/Member/Module/EditCoachCertificate.ascx", item);

        }

        
        public ActionResult ShowCoachCertificate(int coachID)
        {
            ViewResult result = (ViewResult)EditCoachCertificate(coachID);
            ServingCoach item = result.Model as ServingCoach;
            if (item != null)
            {
                result.ViewName = "~/Views/Member/Module/ShowCoachCertificate.ascx";
            }
            return result;
        }


        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult AddCoachCertificate(int uid)
        {

            ServingCoach item = models.GetTable<ServingCoach>().Where(u => u.CoachID == uid).FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            return View("~/Views/Member/Module/AddCoachCertificate.ascx", item);

        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult CommitCoachCertificate(CoachCertificateViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var coach = models.GetTable<ServingCoach>().Where(u => u.CoachID == viewModel.UID).FirstOrDefault();
            if (coach == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            if (!viewModel.CertificateID.HasValue)
            {
                ModelState.AddModelError("CertificateID", "請選證照!!");
            }

            if (!viewModel.Expiration.HasValue)
            {
                ModelState.AddModelError("Expiration", "請選到期日!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            var item = coach.CoachCertificate.Where(c => c.CertificateID == viewModel.CertificateID).FirstOrDefault();
            if (item == null)
            {
                item = new CoachCertificate
                {
                    CertificateID = viewModel.CertificateID.Value
                };
                coach.CoachCertificate.Add(item);
            }

            item.Expiration = viewModel.Expiration;

            models.SubmitChanges();
            return Json(new { result = true });

        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult DeleteCoachCertificate(CoachCertificateViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var item = models.DeleteAny<CoachCertificate>(c => c.CoachID == viewModel.UID && c.CertificateID == viewModel.CertificateID);

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            return Json(new { result = true });

        }


        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult CoachCertificateList(int uid, bool? viewOnly)
        {
            var items = models.GetTable<CoachCertificate>().Where(c => c.CoachID == uid);
            ViewBag.ViewOnly = viewOnly;
            return View("~/Views/Member/Module/CoachCertificateList.ascx", items);
        }



        public async Task<ActionResult> DeleteLessonsAsync(int id)
        {

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == (int?)HttpContext.GetCacheValue("EditMemberUID")).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                return ListLearners(null);
            }

            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            RegisterLesson lesson = item.RegisterLesson.Where(r => r.RegisterID == id).FirstOrDefault();
            if (lesson == null)
            {
                ViewBag.ViewModel = new LessonViewModel
                {
                    AdvisorID = profile.UID
                };
                return View("AddLessons", item);
            }

            models.DeleteAnyOnSubmit<RegisterLesson>(l => l.RegisterID == lesson.RegisterID);

            if (lesson.GroupingMemberCount > 1)
            {
                models.DeleteAnyOnSubmit<GroupingLesson>(g => g.GroupID == lesson.RegisterGroupID);
            }

            models.SubmitChanges();

            ViewBag.Message = "資料已刪除!!";
            ViewBag.ViewModel = new LessonViewModel
            {
                AdvisorID = profile.UID
            };
            return View("AddLessons", item);
        }

        public ActionResult Delete(int uid)
        {
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                return ListLearners(null);
            }

            item.LevelID = (int)Naming.MemberStatusDefinition.Deleted;
            models.SubmitChanges();

            try
            {
                models.DeleteAny<UserProfile>(u => u.UID == item.UID);
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<MemberController>().LogWarning(ex, "無法刪除使用者，因其他關聯性資料...");
            }

            ViewBag.Message = "資料已刪除!!";

            return ListLearners(null);

        }
        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult DeleteCoach(int uid)
        {

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                return ListCoaches();
            }

            item.LevelID = (int)Naming.MemberStatusDefinition.Deleted;
            models.SubmitChanges();

            try
            {
                models.DeleteAny<UserProfile>(u => u.UID == item.UID);
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<MemberController>().LogWarning(ex, "無法刪除使用者，因其他關聯性資料...");
            }

            ViewBag.Message = "資料已刪除!!";

            return ListCoaches();

        }

        public ActionResult EnableUser(int id)
        {



            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                return ListLearners(null);
            }

            item.LevelID = item.UserProfileExtension.RegisterStatus == true ? (int)Naming.MemberStatusDefinition.Checked : (int)Naming.MemberStatusDefinition.ReadyToRegister;
            models.SubmitChanges();

            ViewBag.Message = "會員已啟用!!";

            return ListLearners(null);

        }

        public ActionResult ApplyToFormal(int uid)
        {

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
            }
            else
            {
                item.UserProfileExtension.CurrentTrial = null;
                models.SubmitChanges();

                ViewBag.Message = "學員資料轉至完成!!";
            }

            ViewBag.TabIndex = 1;
            return ListLearners(null);

        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public ActionResult EnableCoach(int id)
        {

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                return ListCoaches();
            }

            item.LevelID = item.UserProfileExtension.RegisterStatus == true ? (int)Naming.MemberStatusDefinition.Checked : (int)Naming.MemberStatusDefinition.ReadyToRegister;
            models.SubmitChanges();

            ViewBag.Message = "會員已啟用!!";

            return ListCoaches();

        }


        
        public ActionResult EditCoach(int id)
        {

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                return ListCoaches();
            }

            var model = new CoachViewModel
            {
                //CoachRole = item.UserRole[0].RoleID,
                AuthorizedRole = item.UserRoleAuthorization.Select(r => (int?)r.RoleID).ToArray(),
                Phone = item.Phone,
                RealName = item.RealName,
                MemberCode = item.MemberCode,
                Birthday = item.Birthday,
                Email = item.PID.Contains("@") ? item.PID : null,
                IsCoach = item.ServingCoach != null,
                Description = item.ServingCoach != null ? item.ServingCoach.Description : null,
                LevelID = item.ServingCoach != null ? item.ServingCoach.LevelID : null
            };

            HttpContext.SetCacheValue("EditMemberUID", item.UID);
            ViewBag.Profile = item;

            return View(model);

        }

        
        public ActionResult EditMember(CoachViewModel viewModel)
        {

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID
                && !u.UserRole.Any(r => r.RoleID == (int)Naming.RoleID.Learner)).FirstOrDefault();

            if (item != null)
            {
                viewModel.Birthday = item.Birthday;
                viewModel.AuthorizedRole = item.UserRoleAuthorization.Select(r => (int?)r.RoleID).ToArray();
                viewModel.Phone = item.Phone;
                viewModel.Email = item.PID;
                viewModel.RealName = item.RealName;

                if (item.IsCoach())
                {
                    viewModel.IsCoach = true;
                    if (item.ServingCoach.CoachWorkplace.Count > 0)
                    {
                        viewModel.BranchID = item.ServingCoach.CoachWorkplace.First().BranchID;
                    }
                    viewModel.LevelID = item.ServingCoach.ProfessionalLevel.LevelID;
                    viewModel.LevelCategory = item.ServingCoach.ProfessionalLevel.CategoryID;
                }
                else
                {
                    viewModel.IsCoach = false;
                }

                if (item.EmployeeWelfare != null)
                {
                    viewModel.HasGiftLessons = item.EmployeeWelfare.MonthlyGiftLessons > 0;
                    viewModel.MonthlyGiftLessons = item.EmployeeWelfare.MonthlyGiftLessons;
                }
            }

            ViewBag.ViewModel = viewModel;

            return View("~/Views/Member/Module/EditMember.ascx");

        }


        public ActionResult ShowMember(int id)
        {

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                return ListLearners(null);
            }

            return View(item);

        }

        
        public ActionResult ShowLearner(int id)
        {
            return ShowMember(id);
        }


        [HttpPost]
        
        public async Task<ActionResult> EditCoach(CoachViewModel viewModel)
        {
            if (!this.ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View(viewModel);
            }

            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == (int?)HttpContext.GetCacheValue("EditMemberUID")).FirstOrDefault();

            if (item == null)
            {
                HttpContext.SetCacheValue("EditMemberUID", null);
                ViewBag.Message = "資料錯誤!!";
                return ListCoaches();
            }

            viewModel.Email = viewModel.Email.GetEfficientString();
            if (viewModel.Email != null)
            {
                if (item.PID != viewModel.Email && models.GetTable<UserProfile>().Any(u => u.PID == viewModel.Email))
                {
                    ModelState.AddModelError("email", "Email已經是註冊使用者!!");
                    ViewBag.ModelState = ModelState;
                    return View("EditCoach", viewModel);
                }
                item.PID = viewModel.Email;
            }

            item.RealName = viewModel.RealName;
            item.Phone = viewModel.Phone;
            item.Birthday = null;
            if (viewModel.Birthday.HasValue)
            {
                item.Birthday = viewModel.Birthday;
                item.BirthdateIndex = viewModel.Birthday.Value.Month * 100 + viewModel.Birthday.Value.Day;
            }

            if (viewModel.IsCoach == true)
            {
                item.ServingCoach.Description = viewModel.Description;
                if (profile.IsOfficer())
                {
                    if (item.ServingCoach.LevelID != viewModel.LevelID)
                    {
                        item.ServingCoach.LevelID = viewModel.LevelID;
                        item.ServingCoach.CoachRating.Add(new CoachRating
                        {
                            CoachID = item.ServingCoach.CoachID,
                            LevelID = viewModel.LevelID.Value,
                            RatingDate = DateTime.Now
                        });
                    }
                }
            }

            models.SubmitChanges();
            models.ExecuteCommand("update UserRole set RoleID = {0} where UID = {1}", viewModel.CoachRole, item.UID);

            HttpContext.SetCacheValue("EditMemberUID", null);

            ViewBag.Message = "資料更新完成!!";

            return ListCoaches();
        }

        
        public ActionResult EditLearner(int id)
        {
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                return ListLearners(null);
            }

            if (item.UserProfileExtension == null)
                item.UserProfileExtension = new UserProfileExtension { };

            var model = new LearnerViewModel
            {
                MemberCode = item.MemberCode,
                Phone = item.Phone,
                RealName = item.RealName,
                Birthday = item.Birthday,
                Email = item.PID.IndexOf('@') >= 0 ? item.PID : null,
                MemberStatus = (Naming.MemberStatusDefinition?)item.LevelID,
                Gender = item.UserProfileExtension.Gender,
                AthleticLevel = item.UserProfileExtension.AthleticLevel
            };


            HttpContext.SetCacheValue("EditMemberUID", item.UID);
            ViewBag.DataItem = item;
            ViewBag.Profile = item;

            return View(model);
        }

        [HttpPost]
        
        public ActionResult EditLearner(LearnerViewModel viewModel)
        {
            if (!this.ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View(viewModel);
            }

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == (int?)HttpContext.GetCacheValue("EditMemberUID".ToString())).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                HttpContext.SetCacheValue("EditMemberUID", null);
                return ListLearners(null);
            }



            item.RealName = viewModel.RealName;
            item.Phone = viewModel.Phone;
            item.Birthday = viewModel.Birthday;
            item.BirthdateIndex = null;
            if (viewModel.Birthday.HasValue)
                item.BirthdateIndex = viewModel.Birthday.Value.Month * 100 + viewModel.Birthday.Value.Day;

            if (!String.IsNullOrEmpty(viewModel.Email))
            {
                if (item.PID != viewModel.Email && models.GetTable<UserProfile>().Any(u => u.PID == viewModel.Email))
                {
                    ModelState.AddModelError("email", "Email已經是註冊使用者!!");
                    ViewBag.ModelState = ModelState;
                    return View(viewModel);
                }
                item.PID = viewModel.Email;
            }

            if (item.UserProfileExtension == null)
                item.UserProfileExtension = new UserProfileExtension { };
            item.UserProfileExtension.Gender = viewModel.Gender;
            item.UserProfileExtension.AthleticLevel = viewModel.AthleticLevel;

            models.SubmitChanges();

            HttpContext.SetCacheValue("EditMemberUID", null);
            ViewBag.Message = "資料更新完成!!";

            return ListLearners(null);
        }

        public ActionResult GroupLessons(int id)
        {
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                return RedirectToAction("ListAll");
            }

            HttpContext.SetCacheValue("EditMemberUID", item.UID);

            return View(item);
        }

        public ActionResult GroupLessonUsers(int lessonId)
        {

            RegisterLesson item = models.GetTable<RegisterLesson>()
                .Where(u => u.UID == (int?)HttpContext.GetCacheValue("EditMemberUID")
                    && u.RegisterID == lessonId).FirstOrDefault();

            if (item == null)
            {
                return Content("課程資料不存在!!");
            }

            return View(item);
        }

        public ActionResult PayInstallment(int registerID)
        {
            RegisterLesson item = models.GetTable<RegisterLesson>()
                .Where(u => u.UID == (int?)HttpContext.GetCacheValue("EditMemberUID")
                    && u.RegisterID == registerID).FirstOrDefault();

            if (item == null)
            {
                //ViewBag.Message = "課程資料不存在!!";
                return ListLearners(null);
            }

            if (item.IntuitionCharge == null)
            {
                item.IntuitionCharge = new IntuitionCharge
                {
                    ByInstallments = 1,
                    Payment = "Cash",
                    FeeShared = 0
                };
                models.SubmitChanges();
            }

            var viewModel = new InstallmentViewModel
            {
                RegisterID = item.RegisterID
            };

            var itemCount = Math.Max(item.IntuitionCharge.ByInstallments.Value, item.IntuitionCharge.TuitionInstallment.Count);
            viewModel.PayoffAmount = new int?[itemCount];
            viewModel.PayoffDate = new DateTime?[itemCount];

            if (item.IntuitionCharge.TuitionInstallment.Count > 0)
            {
                Array.Copy(item.IntuitionCharge.TuitionInstallment.Select(t => t.PayoffAmount).ToArray(), viewModel.PayoffAmount, item.IntuitionCharge.TuitionInstallment.Count);
                Array.Copy(item.IntuitionCharge.TuitionInstallment.Select(t => t.PayoffDate).ToArray(), viewModel.PayoffDate, item.IntuitionCharge.TuitionInstallment.Count);
            }

            ViewBag.ViewModel = viewModel;
            return View(item);
        }

        public ActionResult PaySingleInstallment(int registerID)
        {
            RegisterLesson item = models.GetTable<RegisterLesson>()
                .Where(u => u.RegisterID == registerID).FirstOrDefault();

            if (item == null)
            {
                //ViewBag.Message = "課程資料不存在!!";
                ViewBag.Message = "付款課程資料錯誤!!";
                return View("~/Views/Shared/MessageModal.ascx");
            }

            if (item.IntuitionCharge == null)
            {
                item.IntuitionCharge = new IntuitionCharge
                {
                    ByInstallments = 1,
                    Payment = "Cash",
                    FeeShared = 0
                };
                models.SubmitChanges();
            }

            return View("~/Views/Member/Tuition/Module/PaySingleInstallment.ascx", item.IntuitionCharge);
        }

        public ActionResult CommitSinglePayment(SingleInstallmentViewModel viewModel)
        {

            //IntuitionCharge item = models.GetTable<IntuitionCharge>()
            //    .Where(u => u.RegisterID == viewModel.RegisterID).FirstOrDefault();

            //if (item == null)
            //{
            //    ViewBag.Message = "課程資料不存在!!";
            //    return ListLearners(null);
            //}

            //if(!viewModel.PayoffAmount.HasValue || viewModel.PayoffAmount<=0)
            //{
            //    ModelState.AddModelError("PayoffAmount", "請輸入正確付款金額!!");
            //}

            //if (!viewModel.PayoffDate.HasValue)
            //{
            //    ModelState.AddModelError("PayoffDate", "請輸入付款日期!!");
            //}

            //if (!ModelState.IsValid)
            //{
            //    ViewBag.ModelState = ModelState;
            //    return View("~/Views/Shared/ReportInputError.ascx");
            //}

            //var installment = new TuitionInstallment
            //{
            //    PayoffAmount = viewModel.PayoffAmount,
            //    PayoffDate = viewModel.PayoffDate,
            //    RegisterID = item.RegisterID
            //};
            //installment.TuitionAchievement.Add(new TuitionAchievement
            //{
            //    CoachID = item.RegisterLesson.AdvisorID.Value,
            //    ShareAmount = installment.PayoffAmount
            //});

            //item.TuitionInstallment.Add(installment);
            //models.SubmitChanges();

            //return Json(new { result = true });
            return Json(new { result = false, message = "請執行收款管理!!" });

        }

        public ActionResult DeleteTuitionPayment(int installmentID)
        {

            var item = models.DeleteAny<TuitionInstallment>(t => t.InstallmentID == installmentID);

            if (item == null)
            {
                return Json(new { result = false, message = "付款資料錯誤!!" });
            }
            else
            {
                return Json(new { result = true });
            }

        }

        public ActionResult TuitionAchievementShare(int installmentID)
        {
            TuitionInstallment item = models.GetTable<TuitionInstallment>()
                .Where(u => u.InstallmentID == installmentID).FirstOrDefault();

            if (item == null)
            {
                //ViewBag.Message = "課程資料不存在!!";
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "付款資料錯誤!!");
            }

            return View("~/Views/Member/Tuition/Module/TuitionAchievementShare.ascx", item);
        }

        public ActionResult CommitAchievementShare(AchievementShareViewModel viewModel)
        {
            //TuitionInstallment item = models.GetTable<TuitionInstallment>()
            //    .Where(u => u.InstallmentID == viewModel.InstallmentID).FirstOrDefault();

            //if (item == null)
            //{
            //    return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "付款資料不存在!!");
            //}

            //if (!viewModel.ShareAmount.HasValue || viewModel.ShareAmount <= 0)
            //{
            //    ModelState.AddModelError("ShareAmount", "請輸入業績金額!!");
            //}

            //if(item.TuitionAchievement.Where(t=>t.CoachID!=viewModel.CoachID).Sum(t=>t.ShareAmount) + viewModel.ShareAmount > item.PayoffAmount)
            //{
            //    ModelState.AddModelError("ShareAmount", "所屬體能顧問業績總額大於付款金額!!");
            //}

            //if (!ModelState.IsValid)
            //{
            //    ViewBag.ModelState = ModelState;
            //    return View("~/Views/Shared/ReportInputError.ascx");
            //}

            //var shareItem = item.TuitionAchievement.Where(t => t.CoachID == viewModel.CoachID).FirstOrDefault();
            //if(shareItem==null)
            //{
            //    shareItem = new TuitionAchievement
            //    {
            //        CoachID = viewModel.CoachID
            //    };
            //    item.TuitionAchievement.Add(shareItem);
            //}

            //shareItem.ShareAmount = viewModel.ShareAmount;
            //models.SubmitChanges();

            //return Json(new { result = true });

            return Json(new { result = false, message = "請執行業績分潤設定!!" });

        }

        public ActionResult DeleteAchievementShare(int installmentID, int coachID)
        {

            //var item = models.DeleteAny<TuitionAchievement>(t => t.InstallmentID == installmentID
            //    && t.CoachID==coachID);

            //if (item == null)
            //{
            //    return Json(new { result = false, message = "業績資料錯誤!!" });
            //}
            //else
            //{
            //    return Json(new { result = true });
            //}

            return Json(new { result = false, message = "請執行業績分潤設定!!" });


        }


        public ActionResult CommitPayment(int registerID, InstallmentViewModel viewModel)
        {
            //RegisterLesson item = models.GetTable<RegisterLesson>()
            //    .Where(u => u.UID == (int?)HttpContext.GetCacheValue("EditMemberUID")
            //        && u.RegisterID == registerID).FirstOrDefault();

            //if (item == null)
            //{
            //    //ViewBag.Message = "課程資料不存在!!";
            //    return ListLearners(null);
            //}

            //List<TuitionInstallment> items = new List<TuitionInstallment>();
            //for(int i=0;i< viewModel.PayoffAmount.Length;i++)
            //{
            //    if(viewModel.PayoffAmount[i].HasValue && viewModel.PayoffDate[i].HasValue)
            //    {
            //        var installment = new TuitionInstallment
            //        {
            //            PayoffAmount = viewModel.PayoffAmount[i],
            //            PayoffDate = viewModel.PayoffDate[i],
            //            RegisterID = item.RegisterID
            //        };
            //        installment.TuitionAchievement.Add(new TuitionAchievement
            //        {
            //            CoachID = item.AdvisorID.Value,
            //            ShareAmount = installment.PayoffAmount
            //        });
            //        items.Add(installment);
            //    }
            //}

            //models.ExecuteCommand(@"DELETE FROM TuitionAchievement
            //        FROM     TuitionInstallment INNER JOIN
            //                        TuitionAchievement ON TuitionInstallment.InstallmentID = TuitionAchievement.InstallmentID
            //        WHERE   (TuitionInstallment.RegisterID = {0}) ", item.RegisterID);
            //models.ExecuteCommand("delete from TuitionInstallment where RegisterID = {0} ", item.RegisterID);
            //models.GetTable<TuitionInstallment>().InsertAllOnSubmit(items);
            //models.SubmitChanges();

            //ViewBag.Message = "資料已儲存!!";

            //return AddLessons((int)HttpContext.GetCacheValue("EditMemberUID"));

            ViewBag.Message = "請執行收款管理!!";
            return ListLearners(null);


        }

        public ActionResult GroupLessonUsersSelector(int lessonId, String userName)
        {

            RegisterLesson item = models.GetTable<RegisterLesson>()
                .Where(u => u.UID == (int?)HttpContext.GetCacheValue("EditMemberUID")
                    && u.RegisterID == lessonId).FirstOrDefault();

            if (item == null)
            {
                return Content("課程資料不存在!!");
            }

            RegisterLesson[] items;
            userName = userName.GetEfficientString();
            if (userName == null)
            {
                items = models.GetTable<RegisterLesson>().Where(l => l.Attended == (int)Naming.LessonStatus.準備上課 && l.ClassLevel == item.ClassLevel
                    && l.Lessons == item.Lessons
                    && l.RegisterID != item.RegisterID
                    && l.GroupingMemberCount == item.GroupingMemberCount).ToArray();

            }
            else
            {
                items = models.GetTable<RegisterLesson>().Where(l => l.Attended == (int)Naming.LessonStatus.準備上課 && l.ClassLevel == item.ClassLevel
                    && l.Lessons == item.Lessons
                    && l.RegisterID != item.RegisterID
                    && l.GroupingMemberCount == item.GroupingMemberCount
                    && (l.UserProfile.RealName.Contains(userName) || l.UserProfile.Nickname.Contains(userName) || l.RegisterGroupID == item.RegisterGroupID)).ToArray();
            }

            ViewBag.DataItems = items;

            return View(item);
        }


        public async Task<ActionResult> ApplyGroupLessons(int lessonId, int[] registerID)
        {
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == (int?)HttpContext.GetCacheValue("EditMemberUID")).FirstOrDefault();

            RegisterLesson lesson = models.GetTable<RegisterLesson>()
                .Where(u => u.UID == (int?)HttpContext.GetCacheValue("EditMemberUID")
                    && u.RegisterID == lessonId).FirstOrDefault();

            if (lesson == null)
            {
                ViewBag.Message = "課程資料不存在!!";
                return ListLearners(null);
            }

            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            if (lesson.RegisterGroupID.HasValue)
            {
                models.DeleteAnyOnSubmit<GroupingLesson>(g => g.GroupID == lesson.RegisterGroupID);
                lesson.RegisterGroupID = null;
                models.SubmitChanges();
            }

            GroupingLesson currentGroup = new GroupingLesson { };
            lesson.GroupingLesson = currentGroup;
            models.SubmitChanges();

            String sql = @"UPDATE RegisterLesson
                            SET RegisterGroupID = {0}
                            WHERE(RegisterID = {1})";
            String clearGroup = @"DELETE FROM GroupingLesson
                                    FROM     GroupingLesson INNER JOIN
                                                   RegisterLesson ON GroupingLesson.GroupID = RegisterLesson.RegisterGroupID
                                    WHERE   (RegisterLesson.RegisterID = {0})";
            foreach (var id in registerID)
            {
                models.ExecuteCommand(clearGroup, id);
                models.ExecuteCommand(sql, currentGroup.GroupID, id);
            }

            ViewBag.Message = "團體課學員設定完成!!";
            ViewBag.ViewModel = new LessonViewModel
            {
                AdvisorID = profile.UID
            };
            return View("AddLessons", item);
        }

        public ActionResult RemoveGroupUser(int id)
        {
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == (int?)HttpContext.GetCacheValue("EditMemberUID")).FirstOrDefault();

            RegisterLesson lesson = models.GetTable<RegisterLesson>()
                .Where(u => u.RegisterID == id).FirstOrDefault();

            if (lesson == null || lesson.GroupingLesson == null
                || !lesson.GroupingLesson.RegisterLesson.Any(r => r.UID == (int?)HttpContext.GetCacheValue("EditMemberUID")))
            {
                ViewBag.Message = "課程資料不存在!!";
                return RedirectToAction("ListAll");
            }

            models.ExecuteCommand("update RegisterLesson set RegisterGroupID = null where RegisterID = {0} ", lesson.RegisterID);

            return View("GroupLessons", item);
        }

        public ActionResult ChangeRoleList(Naming.RoleID? roleID)
        {
            if (roleID.HasValue)
            {
                MembersQueryViewModel viewModel = (MembersQueryViewModel)HttpContext.GetCacheValue("MembersQuery");
                if (viewModel == null)
                {
                    viewModel = new MembersQueryViewModel { };
                }
                viewModel.RoleID = roleID;
                HttpContext.SetCacheValue("MembersQuery", viewModel);
            }

            return Json(new { result = true });
        }

        public async Task<ActionResult> RegisterLessonForm(int? registerID)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Content("連線已逾時，請重新登入系統!!");
            }

            var viewModel = new LessonViewModel
            {
                AdvisorID = profile.UID
            };

            var item = models.GetTable<RegisterLesson>().Where(r => r.RegisterID == registerID).FirstOrDefault();
            if (item != null)
            {
                viewModel.RegisterID = item.RegisterID;
                viewModel.Lessons = item.Lessons;
                viewModel.ClassLevel = item.ClassLevel.Value;
                viewModel.Grouping = item.GroupingMemberCount > 1 ? "Y" : "N";
                viewModel.MemberCount = item.GroupingMemberCount;
                viewModel.AdvisorID = item.AdvisorID;
                viewModel.ByInstallments = item.IntuitionCharge.ByInstallments;
                viewModel.FeeShared = item.IntuitionCharge.FeeShared;
                viewModel.Installments = item.IntuitionCharge.ByInstallments.HasValue && item.IntuitionCharge.ByInstallments > 1 ? "Y" : "N";
                viewModel.Payment = item.IntuitionCharge.Payment;
            }

            return View(viewModel);

        }

        [AssistantOrSysAdminAuthorize]
        public async Task<ActionResult> AddLessons(int id)
        {
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                return ListLearners(null);
            }

            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            //var lesson = item.RegisterLesson.OrderByDescending(r => r.RegisterID).FirstOrDefault();

            var model = new LessonViewModel
            {
                AdvisorID = profile.UID
            };

            HttpContext.SetCacheValue("EditMemberUID", item.UID);
            ViewBag.ViewModel = model;

            return View("AddLessons", item);
        }

        [AssistantOrSysAdminAuthorize]
        public ActionResult LessonTuitionInstallment(int id)
        {
            var item = models.GetTable<RegisterLesson>().Where(u => u.RegisterID == id).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                return ListLearners(null);
            }

            if (item.IntuitionCharge == null)
            {
                item.IntuitionCharge = new IntuitionCharge
                {
                    ByInstallments = 1,
                    Payment = "Cash",
                    FeeShared = 0
                };
                models.SubmitChanges();
            }

            ViewBag.DataItem = item.IntuitionCharge;
            return View("~/Views/Member/Tuition/InstallmentPayment.aspx", item.UserProfile);
        }

        [AssistantOrSysAdminAuthorize]
        public ActionResult TuitionCharge(int id)
        {
            var item = models.GetTable<IntuitionCharge>().Where(u => u.RegisterID == id).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                return ListLearners(null);
            }

            return View("~/Views/Member/Tuition/Module/TuitionCharge.ascx", item);
        }

        [HttpPost]
        public async Task<ActionResult> CommitLessons(LessonViewModel viewModel)
        {

            UserProfile learner = models.GetTable<UserProfile>().Where(u => u.UID == (int?)HttpContext.GetCacheValue("EditMemberUID".ToString())).FirstOrDefault();

            if (learner == null)
            {
                ViewBag.Message = "資料錯誤!!";
                HttpContext.SetCacheValue("EditMemberUID", null);
                return ListLearners(null);
            }

            UserProfile coach = await HttpContext.GetUserAsync();
            if (coach == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            ViewBag.ViewModel = viewModel;
            if (viewModel.Lessons < 1)
            {
                ModelState.AddModelError("Lessons", "購買堂數錯誤!!");
            }

            if (!viewModel.AdvisorID.HasValue || viewModel.AdvisorID <= 1)
            {
                ModelState.AddModelError("AdvisorID", "請選擇體能顧問!!");
            }

            if (viewModel.Grouping == "Y" && viewModel.MemberCount < 2)
            {
                ModelState.AddModelError("MemberCount", "請選擇團體上課人數!!");
            }

            if (viewModel.Installments == "Y" && (!viewModel.ByInstallments.HasValue || viewModel.ByInstallments < 2))
            {
                ModelState.AddModelError("ByInstallments", "請輸入分期期數!!");
            }


            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("AddLessons", learner);
            }

            var item = models.GetTable<RegisterLesson>().Where(r => r.RegisterID == viewModel.RegisterID).FirstOrDefault();

            if (item == null)
            {
                item = new RegisterLesson
                {
                    ClassLevel = viewModel.ClassLevel,
                    RegisterDate = DateTime.Now,
                    Lessons = viewModel.Lessons,
                    Attended = (int)Naming.LessonStatus.準備上課,
                    GroupingMemberCount = viewModel.Grouping == "Y" ? viewModel.MemberCount : 1,
                    IntuitionCharge = new IntuitionCharge
                    {
                        Payment = viewModel.Payment,
                        FeeShared = viewModel.Payment == "CreditCard" ? viewModel.FeeShared : 0,
                        ByInstallments = viewModel.Installments == "Y" ? viewModel.ByInstallments : 1
                    },
                    AdvisorID = viewModel.AdvisorID,
                    AttendedLessons = 0
                };

                item.GroupingLesson = new GroupingLesson { };
                learner.RegisterLesson.Add(item);

            }
            else
            {
                item.Lessons = viewModel.Lessons;
                item.ClassLevel = viewModel.ClassLevel;
                item.GroupingMemberCount = viewModel.Grouping == "Y" ? viewModel.MemberCount : 1;
                //if (item.GroupingMemberCount != 1 && item.RegisterGroupID.HasValue)
                //{
                //    item.RegisterGroupID = null;
                //}
                item.AdvisorID = viewModel.AdvisorID;
                item.IntuitionCharge.Payment = viewModel.Payment;
                item.IntuitionCharge.FeeShared = viewModel.Payment == "CreditCard" ? viewModel.FeeShared : 0;
                item.IntuitionCharge.ByInstallments = viewModel.Installments == "Y" ? viewModel.ByInstallments : 1;
                //models.DeleteAllOnSubmit<TuitionInstallment>(t => t.RegisterID == item.RegisterID);
            }

            models.SubmitChanges();
            ViewBag.ViewModel = new LessonViewModel
            {
                AdvisorID = coach.UID
            };
            ViewBag.Message = "資料已儲存!!";
            //HttpContext.SetCacheValue("EditMemberUID", null);

            return View("AddLessons", learner);
        }


        public ActionResult Test(String alertMsg)
        {
            ModelState.AddModelError("realName", "test error...");
            ViewBag.ModelState = this.ModelState;
            ViewBag.Message = alertMsg ?? "Test Alert Message...";
            return View();
        }

        
        public async Task<ActionResult> PDQ(int id, int? groupID)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();
            if (item == null)
            {
                ViewBag.Message = "學員資料不存在!!";
                return ListLearners(null);
            }

            ViewBag.GroupID = groupID;
            switch (groupID)
            {
                case 1:
                    ViewBag.Percent = "20%";
                    return View(item);
                case 2:
                    ViewBag.Percent = "40%";
                    return View("PDQ_All", item);
                case 3:
                    ViewBag.Percent = "60%";
                    return View("PDQ_All", item);
                case 4:
                    ViewBag.Percent = "80%";
                    return View("PDQ_All", item);
                case 5:
                    ViewBag.Percent = "95%";
                    return View("PDQ_All", item);
                case 6:
                    return View("PDQ_Final", item);
                default:
                    return View(item);
            }
        }

        public async Task<ActionResult> UpdatePDQ(int id, int groupID, int? goalID, int? styleID, int? levelID)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Json(new { result = false, message = "您的連線已中斷，請重新登入系統!!" });
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "學員資料不存在!!" });
            }

            models.ExecuteCommand(@"
                DELETE FROM PDQTask
                FROM     PDQTask INNER JOIN
                                PDQQuestion ON PDQTask.QuestionID = PDQQuestion.QuestionID
                WHERE   (PDQTask.UID = {0}) AND (PDQQuestion.GroupID = {1})", item.UID, groupID);

            foreach (var key in Request.Form.Keys.Where(k => Regex.IsMatch(k, "_\\d")))
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
                .Where(q => !q.PDQTask.Any(t => t.UID == id)
                    || q.PDQTask.Count(t => t.UID == id && !t.SuggestionID.HasValue && t.PDQAnswer == "") == 1)
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

            var values = Request.Form[key];
            if (values == (String)null || values.Count == 0)
                return;

            switch ((Naming.QuestionType)quest.QuestionType)
            {
                case Naming.QuestionType.問答題:
                    if (values.Count > 0)
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
                    if (values.Count > 0)
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
    }

}