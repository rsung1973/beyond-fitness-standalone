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
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Html;
using System.Data;
using System.Data.Linq;


using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc.ViewFeatures;

namespace WebHome.Controllers
{
    [Authorize]
    public class LessonsController : LessonEventController
    {
        public LessonsController(IServiceProvider serviceProvider) : base(serviceProvider) { }
        // GET: Lessons
        [AllowAnonymous]
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult BookingSelfTraining(int? lessonID)
        {
            LessonTime item = models.GetTable<LessonTime>().Where(l => l.LessonID == lessonID).FirstOrDefault();
            LessonTimeViewModel viewModel = new LessonTimeViewModel
            {
                BranchID = 1
            };
            if(item!=null)
            {
                viewModel.LessonID = item.LessonID;
                viewModel.ClassDate = item.ClassTime.Value;
                //viewModel.Duration = item.DurationInMinutes.Value;
                viewModel.BranchID = item.BranchID.Value;
            }
            return View("~/Views/Lessons/LessonTime/Module/BookingSelfTraining.ascx", viewModel);
        }

        public async Task<ActionResult> CommitBookingSelfTrainingAsync(LessonTimeViewModel viewModel)
        {

            var profile = await HttpContext.GetUserAsync();

            if(viewModel.KeyID!=null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            LessonTime timeItem = models.GetTable<LessonTime>().Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();

            ViewBag.ViewModel = viewModel;

            if (!viewModel.ClassTimeStart.HasValue)
            {
                ModelState.AddModelError("ClassTimeStart", "請選擇上課日期!!");
            }
            else if (viewModel.ClassTimeStart < DateTime.Today)
            {
                ModelState.AddModelError("ClassTimeStart", "預約時間不可早於今天!!");
            }
            else if(viewModel.ClassTimeEnd.HasValue && viewModel.ClassTimeStart >= viewModel.ClassTimeEnd)
            {
                ModelState.AddModelError("ClassTimeEnd", "結束時間不可早於開始時間!!");
            }

            if (!viewModel.BranchID.HasValue)
            {
                ModelState.AddModelError("BranchID", "請選擇上課地點!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(Startup.Properties["ReportInputError"]);
            }

            var priceType = models.GetTable<LessonPriceType>().Where(p => p.Status == (int)Naming.DocumentLevelDefinition.教練PI).FirstOrDefault();
            if (priceType == null)
            {
                ViewBag.Message = "教練P.I課程類別未設定!!";
                return View("~/Views/Shared/AlertMessage.ascx");
            }


            DateTime endTime = viewModel.ClassEndTime ?? viewModel.ClassDate.Value.AddMinutes(priceType.DurationInMinutes.Value);

            if (timeItem == null)
            {
                RegisterLesson lesson = new RegisterLesson
                {
                    RegisterDate = DateTime.Now,
                    GroupingMemberCount = 1,
                    ClassLevel = priceType.PriceID,
                    Lessons = 1,
                    UID = profile.UID,
                    AdvisorID = profile.UID,
                    GroupingLesson = new GroupingLesson { },
                    MasterRegistration = true,
                };

                timeItem = new LessonTime
                {
                    RegisterLesson = lesson,
                    LessonPlan = new LessonPlan
                    {

                    },
                    GroupingLesson = lesson.GroupingLesson
                };

                timeItem.LessonFitnessAssessment.Add(new LessonFitnessAssessment
                {
                    UID = lesson.UID
                });

                models.GetTable<LessonTime>().InsertOnSubmit(timeItem);
            }

            timeItem.ClassTime = viewModel.ClassDate;
            timeItem.DurationInMinutes = (int)(viewModel.ClassEndTime.Value - viewModel.ClassDate.Value).TotalMinutes; //priceType.DurationInMinutes;
            if (viewModel.BranchID > 0)
                timeItem.BranchID = viewModel.BranchID;
            timeItem.InvitedCoach =  timeItem.AttendingCoach = profile.UID;
            if (models.GetTable<DailyWorkingHour>().Any(d => d.Hour == viewModel.ClassTimeStart.Value.Hour))
                timeItem.HourOfClassTime = viewModel.ClassTimeStart.Value.Hour;

            models.SubmitChanges();

            if (viewModel.AttendeeID == null || viewModel.AttendeeID.Length == 0)
            {
                models.ExecuteCommand("delete LessonTime where LessonID<>{0} and GroupID={1}", timeItem.LessonID, timeItem.GroupID);
                models.ExecuteCommand("delete RegisterLesson where RegisterID<>{0} and RegisterGroupID={1}", timeItem.RegisterID, timeItem.GroupID);
            }
            else
            {
                String attendee = $"({String.Join(",", viewModel.AttendeeID.Select(i => i.ToString()))})";
                models.ExecuteCommand("delete LessonTime where LessonID<>{0} and GroupID={1} and AttendingCoach not in " + attendee, timeItem.LessonID, timeItem.GroupID);
                models.ExecuteCommand("delete RegisterLesson where RegisterID<>{0} and RegisterGroupID={1} and UID not in " + attendee, timeItem.RegisterID, timeItem.GroupID, attendee);

                var lesson = timeItem.RegisterLesson;
                foreach (var uid in viewModel.AttendeeID.Distinct())
                {
                    if (models.GetTable<LessonTime>().Any(l => l.GroupID == timeItem.GroupID && l.AttendingCoach == uid))
                        continue;

                    LessonTime coachPI = models.GetTable<ServingCoach>().Any(s => s.CoachID == uid)
                        ? SpawnCoachPI(timeItem, uid, uid)
                        : SpawnCoachPI(timeItem, uid, profile.UID);

                    coachPI.HourOfClassTime = timeItem.HourOfClassTime;
                    models.GetTable<LessonTime>().InsertOnSubmit(coachPI);
                    models.SubmitChanges();
                }
            }

            timeItem.BookingLessonTimeExpansion(models, timeItem.ClassTime.Value, timeItem.DurationInMinutes.Value);

            return Json(new { result = true, message = "上課時間預約完成!!" });

        }

        public static LessonTime SpawnCoachPI(LessonTime timeItem, int uid,int coachID)
        {
            var coachPI = new LessonTime
            {
                RegisterLesson = new RegisterLesson
                {
                    RegisterDate = timeItem.RegisterLesson.RegisterDate,
                    GroupingMemberCount = 1,
                    ClassLevel = timeItem.RegisterLesson.ClassLevel,
                    Lessons = 1,
                    UID = uid,
                    AdvisorID = coachID,
                    GroupingLesson = timeItem.RegisterLesson.GroupingLesson
                },
                LessonPlan = new LessonPlan
                {

                },
                GroupingLesson = timeItem.RegisterLesson.GroupingLesson,
                ClassTime = timeItem.ClassTime,
                DurationInMinutes = timeItem.DurationInMinutes,
                InvitedCoach = coachID,
                AttendingCoach = coachID,
                BranchID = timeItem.BranchID,
            };

            coachPI.LessonFitnessAssessment.Add(new LessonFitnessAssessment
            {
                UID = uid
            });

            return coachPI;
        }

        [HttpGet]
        public async Task<ActionResult> BookingByCoachAsync(int? coachID)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            ViewBag.ViewModel = new LessonTimeViewModel
            {
                ClassDate = DateTime.Today.AddHours(8)
            };
            if (coachID.HasValue)
                ViewBag.DefaultCoach = coachID;
            return View(item);

        }

        public async Task<ActionResult> BookingTrialLesson(int? coachID)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            ViewBag.ViewModel = new LessonTimeViewModel
            {
                ClassDate = DateTime.Today.AddHours(8)
            };
            if (coachID.HasValue)
                ViewBag.DefaultCoach = coachID;
            return View(item);
        }

        public async Task<ActionResult> RebookingByCoach(int id, LessonTimeViewModel viewModel)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            LessonTime item = models.GetTable<LessonTime>().Where(l => l.LessonID == id).FirstOrDefault();
            if (item == null)
            {
                ViewBag.ViewModel = new DailyBookingQueryViewModel
                {
                    Message = "修改上課時間資料不存在!!",
                };
                return  View("~/Views/Account/Coach");
            }

            if (Request.Method == "POST")
            {
                ViewBag.ViewModel = viewModel;
                if(!ModelState.IsValid)
                {
                    ViewBag.ModelState = ModelState;
                    return View(item);
                }

                LessonTime timeItem = new LessonTime
                {
                    InvitedCoach = viewModel.CoachID,
                    AttendingCoach = viewModel.CoachID,
                    ClassTime = viewModel.ClassDate,
                    DurationInMinutes = item.DurationInMinutes
                };

                var users = models.CheckOverlapedBooking(timeItem, item.RegisterLesson, item);
                if (users.Count() > 0)
                {
                    ViewBag.Message = "學員(" + String.Join("、", users.Select(u => u.RealName)) + ")上課時間重複!!";
                    return View(item);
                }

                //item.InvitedCoach = viewModel.CoachID;
                //item.AttendingCoach = viewModel.CoachID;
                item.ClassTime = viewModel.ClassDate;
                if (models.GetTable<DailyWorkingHour>().Any(d => d.Hour == viewModel.ClassDate.Value.Hour))
                    item.HourOfClassTime = viewModel.ClassDate.Value.Hour;

                //item.DurationInMinutes = viewModel.Duration;
                item.BranchID = viewModel.BranchID;
                //item.TrainingBySelf = viewModel.TrainingBySelf;
                foreach (var t in item.ContractTrustTrack)
                {
                    t.EventDate = viewModel.ClassDate.Value;
                }
                models.SubmitChanges();

                if (!item.IsSTSession())
                {
                    item.BookingLessonTimeExpansion(models, item.ClassTime.Value, item.DurationInMinutes.Value);

                    models.ExecuteCommand("delete PreferredLessonTime where LessonID = {0}", item.LessonID);
                    item.ProcessBookingWhenCrossBranch(models);
                }

                if (item.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自主訓練)
                {
                    models.ExecuteCommand("update TuitionInstallment set PayoffDate = {0} where RegisterID = {1} ", item.ClassTime, item.RegisterID);
                }

                ViewBag.ViewModel = new DailyBookingQueryViewModel
                {
                    Message = "修改上課時間資料不存在!!",
                    LessonDate = item.ClassTime,
                };
                return View("~/Views/Account/Coach");
                                
            }


            ViewBag.ViewModel = new LessonTimeViewModel
            {
                ClassDate = item.ClassTime.Value,
                CoachID = item.AttendingCoach.Value,
                //Duration = item.DurationInMinutes.Value,
                TrainingBySelf = (LessonTime.SelfTrainingDefinition?)item.TrainingBySelf,
                BranchID = item.BranchID.Value
            };

            return View(item);

        }

        //public ActionResult FreeAgentClockIn(int? coachID)
        //{
        //    UserProfile item = await HttpContext.GetUserAsync();
        //    if (item == null)
        //    {
        //        return Json(new { result = false, message = "連線已中斷，請重新登入!!" });
        //    }

        //    if (item.IsFreeAgent() && item.UID != coachID)
        //    {
        //        return Json(new { result = false, message = "自由教練資料錯誤!!" });
        //    }

        //    var items = models.GetTable<LessonTime>()
        //        .Where(l => l.ClassTime >= DateTime.Today && l.ClassTime < DateTime.Today.AddDays(1))
        //        .Where(l => l.AttendingCoach == coachID)
        //        .Where(l => l.LessonAttendance == null);

        //    if (items.Count() <= 0)
        //    {
        //        return Json(new { result = false, message = "本日無自由教練課程!!" });
        //    }

        //    foreach (var lesson in items)
        //    {
        //        lesson.LessonAttendance = new LessonAttendance
        //        {
        //            CompleteDate = DateTime.Now
        //        };
        //    }
        //    models.SubmitChanges();

        //    return Json(new { result = true });

        //}

        [HttpGet]
        public async Task<ActionResult> BookingByFreeAgentAsync(int? coachID)
        {
            return await BookingByCoachAsync(coachID);
        }

        public async Task<ActionResult> CommitBookingByCoachAsync(LessonTimeViewModel viewModel)
        {
            var lesson = models.GetTable<RegisterLesson>().Where(r => r.RegisterID == viewModel.RegisterID).FirstOrDefault();
            if (lesson != null)
            {
                if (lesson.RegisterLessonEnterprise != null)
                {
                    return CommitEnterpriseBookingByCoach(viewModel);
                    //return this.TransferToAction("CommitBookingByCoach", "EnterpriseProgram", viewModel);
                }
                else if(lesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.點數兌換課程)
                {
                    var result = await CommitBonusLessonAsync(viewModel);
                    var item = ViewBag.LessonItem as LessonTime;
                    if (item != null)
                    {
                        if (item.RegisterLesson.LessonPriceType.ForDietary == true)
                        {
                            viewModel.ClassDate = viewModel.ClassDate.Value.AddMonths(1);
                            result = await CommitBonusLessonAsync(viewModel);
                            LessonTime nextItem = ViewBag.LessonItem as LessonTime;

                            if (nextItem == null)
                            {
                                models.ExecuteCommand("delete LessonTime where LessonID = {0}", item.LessonID);
                                return Json(new { result = false, message = "預約未完成，請重新預約!!" });
                            }

                        }
                    }

                    return result;
                }
            }

            if (viewModel.TrainingBySelf == LessonTime.SelfTrainingDefinition.在家訓練)
            {
                return await CommitBookingSTSessionByCoachAsync(viewModel);
            }
            else
            {
                if (viewModel.Version == Naming.ContractVersion.Ver2022)
                {
                    return CommitCourseContractBookingByCoach2022(viewModel);
                }
                else
                {
                    return await CommitCourseContractBookingByCoachAsync(viewModel);
                }
            }
        }

        public async Task<ActionResult> CommitCourseContractBookingByCoachAsync(LessonTimeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            ValidateCommonBooking(viewModel, out ServingCoach coach, out BranchStore branch);

            if (!this.ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View(Startup.Properties["ReportInputError"]);
            }

            if (coach == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "未指定體能顧問!!");
            }

            if (branch?.IsVirtualClassroom() != true && viewModel.TrainingBySelf != LessonTime.SelfTrainingDefinition.在家訓練)
            {
                if (!models.GetTable<CoachWorkplace>()
                                .Any(c => c.BranchID == viewModel.BranchID
                                    && c.CoachID == viewModel.CoachID)
                    && viewModel.ClassDate.Value < DateTime.Today.AddDays(1))
                {
                    return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "此時段不允許跨店預約!!");
                }
            }

            RegisterLesson lesson;
            LessonPriceType priceType;

            if (viewModel.TrainingBySelf.HasValue)
            {
                if (!viewModel.UID.HasValue)
                {
                    this.ModelState.AddModelError("userName", "請選擇上課學員!!");
                    ViewBag.ModelState = this.ModelState;
                    return View(Startup.Properties["ReportInputError"]);
                }

                if (viewModel.SessionStatus.HasValue)
                {
                    priceType = models.CurrentSessionPrice(viewModel.SessionStatus.Value, viewModel.PriceID);
                }
                else
                {
                    priceType = models.CurrentSessionPrice();
                }

                lesson = new RegisterLesson
                {
                    UID = viewModel.UID.Value,
                    RegisterDate = DateTime.Now,
                    GroupingMemberCount = 1,
                    Lessons = 1,
                    ClassLevel = priceType != null ? priceType.PriceID : (int?)null,
                    IntuitionCharge = new IntuitionCharge
                    {
                        ByInstallments = 1,
                        Payment = "Cash",
                        FeeShared = 0
                    },
                    AdvisorID = viewModel.CoachID,
                    GroupingLesson = new GroupingLesson { },
                };

                //var installment = new TuitionInstallment
                //{
                //    PayoffDate = viewModel.ClassDate,
                //    PayoffAmount = priceType.ListPrice
                //};
                //installment.TuitionAchievement.Add(new TuitionAchievement
                //{
                //    CoachID = lesson.AdvisorID.Value,
                //    ShareAmount = installment.PayoffAmount
                //});

                //lesson.IntuitionCharge.TuitionInstallment.Add(installment);
                models.GetTable<RegisterLesson>().InsertOnSubmit(lesson);
                models.SubmitChanges();
            }
            else
            {
                lesson = models.GetTable<RegisterLesson>().Where(r => r.RegisterID == viewModel.RegisterID).FirstOrDefault();
                if (lesson == null)
                {
                    return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "學員未購買課程!!");
                }
                priceType = lesson.LessonPriceType;

                if (lesson.Attended == (int)Naming.LessonStatus.課程結束)
                {
                    return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "學員課程已結束!!");
                }

                if (lesson.RegisterLessonContract != null)
                {
                    var contract = lesson.RegisterLessonContract.CourseContract;
                    if (contract.Expiration.Value < DateTime.Today)
                    {
                        return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "合約已過期!!");
                    }

                    if (contract.Expiration.Value.AddDays(1) < viewModel.ClassDate.Value)
                    {
                        return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "合約尚未生效或已過期!!");
                    }

                    var lessonCount = lesson.AttendedLessonCount();
                    //var lessonCount = lesson.GroupingLesson.LessonTime.Count;
                    //if (contract.CourseContractType.ContractCode == "CFA"
                    //        || contract.CourseContractType.ContractCode == "CGF"
                    //        || contract.CourseContractType.ContractCode == "CVF")
                    //{
                    //    lessonCount = contract.RegisterLessonContract.Sum(c => c.RegisterLesson.GroupingLesson.LessonTime.Count());
                    //}

                    //if (lessonCount + (lesson.AttendedLessons ?? 0) >= lesson.Lessons)
                    //{
                    //    return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "學員上課堂數已滿!!");
                    //}

                    if (lessonCount >= lesson.Lessons)
                    {
                        return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "學員上課堂數已滿!!");
                    }

                    if (lesson.ClassLevel == contract.PriceID)
                    {
                        if (contract.TotalCost / contract.Lessons * lessonCount > contract.ContractPayment.Sum(c => c.Payment.PayoffAmount))
                        {
                            return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "學員繳款餘額不足!!");
                        }
                    }
                }
            }

            if (priceType.IsDistanceLesson && branch?.IsVirtualClassroom() != true)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "遠距課程上課地點錯誤!!");
            }

            LessonTime timeItem = new LessonTime
            {
                InvitedCoach = viewModel.CoachID,
                AttendingCoach = viewModel.CoachID,
                //ClassTime = viewModel.ClassDate.Add(viewModel.ClassTime),
                ClassTime = viewModel.ClassDate,
                DurationInMinutes = priceType.DurationInMinutes,
                TrainingBySelf = (int?)viewModel.TrainingBySelf,
                RegisterID = lesson.RegisterID,
                LessonPlan = new LessonPlan
                {

                },
                BranchID = viewModel.BranchID,
                LessonTimeSettlement = new LessonTimeSettlement
                {
                    ProfessionalLevelID = coach.LevelID.Value,
                    MarkedGradeIndex = coach.ProfessionalLevel.GradeIndex,
                    CoachWorkPlace = coach.WorkBranchID(),
                },
                Place = branch?.IsVirtualClassroom() == true ? viewModel.Place : null,
            };
            if (models.GetTable<DailyWorkingHour>().Any(d => d.Hour == viewModel.ClassDate.Value.Hour))
                timeItem.HourOfClassTime = viewModel.ClassDate.Value.Hour;

            if (viewModel.TrainingBySelf.HasValue)
            {
                timeItem.GroupID = lesson.RegisterGroupID;
            }
            else
            {
                var users = models.CheckOverlapedBooking(timeItem, lesson);
                if (users.Any())
                {
                    ViewBag.Message = "學員(" + String.Join("、", users.Select(u => u.RealName)) + ")上課時間重複!!";
                    return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml");
                }

                if (lesson.GroupingMemberCount > 1)
                {
                    timeItem.GroupID = lesson.RegisterGroupID;
                    timeItem.LessonFitnessAssessment.AddRange(
                        lesson.GroupingLesson.RegisterLesson.Select(
                            r => new LessonFitnessAssessment
                            {
                                UID = r.UID
                            }));
                }
                else
                {
                    timeItem.LessonFitnessAssessment.Add(new LessonFitnessAssessment
                    {
                        UID = lesson.UID
                    });
                    if (!lesson.RegisterGroupID.HasValue)
                    {
                        timeItem.GroupingLesson = lesson.GroupingLesson = new GroupingLesson { };
                    }
                    else
                    {
                        timeItem.GroupID = lesson.RegisterGroupID;
                    }
                }

                if (lesson.RegisterLessonContract != null)
                {
                    models.GetTable<ContractTrustTrack>().InsertOnSubmit(new ContractTrustTrack
                    {
                        ContractID = lesson.RegisterLessonContract.ContractID,
                        EventDate = timeItem.ClassTime.Value,
                        LessonTime = timeItem,
                        TrustType = Naming.TrustType.N.ToString()
                    });
                }

            }

            models.GetTable<LessonTime>().InsertOnSubmit(timeItem);

            try
            {
                models.SubmitChanges();

                timeItem.BookingLessonTimeExpansion(models, timeItem.ClassTime.Value, timeItem.DurationInMinutes.Value);
                timeItem.ProcessBookingWhenCrossBranch(models);

            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<LessonsController>().LogError(ex, ex.Message);
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "預約未完成，請重新預約!!");
            }

            return Json(new { result = true, message = "上課時間預約完成!!" });
        }

        public ActionResult CommitCourseContractBookingByCoach2022(LessonTimeViewModel viewModel)
        {
            LessonTime item;
            LessonPriceType priceType = null;
            if (viewModel.SessionStatus.HasValue)
            {
                priceType = models.CurrentSessionPrice(viewModel.SessionStatus.Value, viewModel.PriceID);
            }

            if(priceType.IsSingleCharge)
            {
                item = viewModel.CommitSingleCourseBookingByCoach(this, priceType);
            }
            else
            {
                item = viewModel.CommitCourseContractBookingByCoach(this);
            }

            if (item != null)
            {
                if (item.RegisterLesson.LessonPriceType.ForDietary == true)
                {
                    viewModel.ClassDate = viewModel.ClassDate.Value.AddMonths(1);
                    LessonTime nextItem = viewModel.CommitCourseContractBookingByCoach(this);

                    if (nextItem == null)
                    {
                        models.ExecuteCommand("delete LessonTime where LessonID = {0}", item.LessonID);
                        ModelState.AddModelError("Message", "預約未完成，請重新預約!!");
                        item = null;
                    }
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                ViewBag.AlertError = true;
                return View("~/Views/ConsoleHome/Shared/ReportInputError.cshtml");
            }

            return Json(new { result = true, message = "上課時間預約完成!!" });
        }

        public async Task<ActionResult> CommitBookingSTSessionByCoachAsync(LessonTimeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            var coach = models.GetTable<ServingCoach>().Where(s => s.CoachID == viewModel.CoachID).FirstOrDefault();
            if (coach == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "未指定體能顧問!!");
            }

            RegisterLesson lesson;
            LessonPriceType priceType;

            if (!viewModel.UID.HasValue)
            {
                this.ModelState.AddModelError("userName", "請選擇上課學員!!");
                ViewBag.ModelState = this.ModelState;
                return View(Startup.Properties["ReportInputError"]);
            }

            priceType = models.CurrentSessionPrice(viewModel.SessionStatus.Value, viewModel.PriceID);

            lesson = new RegisterLesson
            {
                UID = viewModel.UID.Value,
                RegisterDate = DateTime.Now,
                GroupingMemberCount = 1,
                Lessons = 1,
                ClassLevel = priceType?.PriceID,
                IntuitionCharge = new IntuitionCharge
                {
                    ByInstallments = 1,
                    Payment = "Cash",
                    FeeShared = 0
                },
                AdvisorID = viewModel.CoachID,
                GroupingLesson = new GroupingLesson { }
            };

            models.GetTable<RegisterLesson>().InsertOnSubmit(lesson);
            models.SubmitChanges();

            LessonTime timeItem = new LessonTime
            {
                InvitedCoach = viewModel.CoachID,
                AttendingCoach = viewModel.CoachID,
                //ClassTime = viewModel.ClassDate.Add(viewModel.ClassTime),
                ClassTime = viewModel.ClassDate,
                DurationInMinutes = priceType.DurationInMinutes,
                TrainingBySelf = (int?)viewModel.TrainingBySelf,
                RegisterID = lesson.RegisterID,
                LessonPlan = new LessonPlan
                {

                },
                LessonTimeSettlement = new LessonTimeSettlement
                {
                    ProfessionalLevelID = coach.LevelID.Value,
                    MarkedGradeIndex = coach.ProfessionalLevel.GradeIndex,
                    CoachWorkPlace = coach.WorkBranchID(),
                }
            };
            if (models.GetTable<DailyWorkingHour>().Any(d => d.Hour == viewModel.ClassDate.Value.Hour))
                timeItem.HourOfClassTime = viewModel.ClassDate.Value.Hour;

            timeItem.GroupID = lesson.RegisterGroupID;
            timeItem.Place = Naming.BranchName.甜蜜的家.ToString();
            models.GetTable<LessonTime>().InsertOnSubmit(timeItem);

            try
            {
                models.SubmitChanges();
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<LessonsController>().LogError(ex, ex.Message);
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "預約未完成，請重新預約!!");
            }

            return Json(new { result = true, message = "上課時間預約完成!!" });
        }

        public async Task<ActionResult> CommitBonusLessonAsync(LessonTimeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ViewBag.LessonItem = null;
            var profile = await HttpContext.GetUserAsync();

            ValidateCommonBooking(viewModel, out ServingCoach coach, out BranchStore branch);

            if (!this.ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View(Startup.Properties["ReportInputError"]);
            }

            if (coach == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "未指定體能顧問!!");
            }

            if (branch?.IsVirtualClassroom() != true && !models.GetTable<CoachWorkplace>()
                            .Any(c => c.BranchID == viewModel.BranchID
                                && c.CoachID == viewModel.CoachID)
                && viewModel.ClassDate.Value < DateTime.Today.AddDays(1))
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "此時段不允許跨店預約!!");
            }

            RegisterLesson lesson;
            LessonPriceType priceType;

            lesson = models.GetTable<RegisterLesson>().Where(r => r.RegisterID == viewModel.RegisterID).FirstOrDefault();
            if (lesson == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "請選擇點數兌換課學員!!");
            }
            priceType = lesson.LessonPriceType;

            if (lesson.Attended == (int)Naming.LessonStatus.課程結束)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "學員課程已結束!!");
            }

            var lessonCount = lesson.GroupingLesson.LessonTime.Count;

            if (lessonCount + (lesson.AttendedLessons ?? 0) >= lesson.Lessons)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "學員上課堂數已滿!!");
            }

            if (priceType.IsDistanceLesson && branch?.IsVirtualClassroom() != true)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "遠距課程上課地點錯誤!!");
            }

            LessonTime timeItem = new LessonTime
            {
                InvitedCoach = viewModel.CoachID,
                AttendingCoach = viewModel.CoachID,
                //ClassTime = viewModel.ClassDate.Add(viewModel.ClassTime),
                ClassTime = viewModel.ClassDate,
                DurationInMinutes = priceType.DurationInMinutes,
                TrainingBySelf = (int?)viewModel.TrainingBySelf,
                RegisterID = lesson.RegisterID,
                LessonPlan = new LessonPlan
                {

                },
                BranchID = viewModel.BranchID,
                LessonTimeSettlement = new LessonTimeSettlement
                {
                    ProfessionalLevelID = coach.LevelID.Value,
                    MarkedGradeIndex = coach.ProfessionalLevel.GradeIndex,
                    CoachWorkPlace = coach.WorkBranchID(),
                },
                Place = viewModel.Place,
            };
            if (models.GetTable<DailyWorkingHour>().Any(d => d.Hour == viewModel.ClassDate.Value.Hour))
                timeItem.HourOfClassTime = viewModel.ClassDate.Value.Hour;


            var users = models.CheckOverlapedBooking(timeItem, lesson);
            if (users.Count() > 0)
            {
                ViewBag.Message = "學員(" + String.Join("、", users.Select(u => u.RealName)) + ")上課時間重複!!";
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml");
            }

            timeItem.LessonFitnessAssessment.Add(new LessonFitnessAssessment
            {
                UID = lesson.UID
            });

            if (!lesson.RegisterGroupID.HasValue)
            {
                timeItem.GroupingLesson = lesson.GroupingLesson = new GroupingLesson { };
            }
            else
            {
                timeItem.GroupID = lesson.RegisterGroupID;
            }

            models.GetTable<LessonTime>().InsertOnSubmit(timeItem);

            try
            {
                models.SubmitChanges();

                timeItem.BookingLessonTimeExpansion(models, timeItem.ClassTime.Value, timeItem.DurationInMinutes.Value);
                timeItem.ProcessBookingWhenCrossBranch(models);
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<LessonsController>().LogError(ex, ex.Message);
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "預約未完成，請重新預約!!");
            }

            ViewBag.LessonItem = timeItem;

            return Json(new { result = true, message = "上課時間預約完成!!" });
        }

        public ActionResult TrialLearner()
        {
            return View("~/Views/Lessons/Module/TrialLearner.ascx");
        }


        public ActionResult Attendee(String userName)
        {
            return View();
        }

        public ActionResult AttendeeByVip(String userName)
        {
            return View();
        }


        public ActionResult AttendeeSelector(String userName)
        {

            IEnumerable<RegisterLesson> items;
            userName = userName.GetEfficientString();
            if (userName == null)
            {
                items = models.GetTable<RegisterLesson>().Where(l => false);
            }
            else
            {
                items = models.GetTable<RegisterLesson>()
                    .Where(r => r.RegisterLessonContract != null)
                    .Where(l => l.Attended != (int)Naming.LessonStatus.課程結束
                        && (l.UserProfile.RealName.Contains(userName) || l.UserProfile.Nickname.Contains(userName)))
                    .Where(l => l.Lessons > l.GroupingLesson.LessonTime.Count)
                    .Where(l => l.RegisterGroupID.HasValue)
                    .OrderBy(l => l.UID).ThenBy(l => l.ClassLevel).ThenBy(l => l.Lessons);
            }

            return View(items);
        }

        public ActionResult TrialLearnerSelector(String userName)
        {
            IEnumerable<UserProfile> items = models.GetTable<UserProfile>().Where(u => u.UserProfileExtension.CurrentTrial.HasValue);

            userName = userName.GetEfficientString();
            if (userName == null)
            {
                items = items.Where(u => false);
            }
            else
            {
                items = items.Where(l => l.RealName.Contains(userName) || l.Nickname.Contains(userName))
                    .OrderBy(l => l.RealName);
            }

            return View("~/Views/Lessons/Module/TrialLearnerSelector.ascx", items);
        }

        public ActionResult VipSelector(String userName)
        {

            IEnumerable<UserProfile> items;
            userName = userName.GetEfficientString();
            if (userName == null)
            {
                items = models.GetTable<UserProfile>().Where(l => false);
            }
            else
            {
                items = models.GetTable<UserProfile>()
                    .Where(u => u.LevelID != (int)Naming.MemberStatusDefinition.Deleted
                        && u.LevelID != (int)Naming.MemberStatusDefinition.Anonymous)
                    .Where(l => l.RealName.Contains(userName) || l.Nickname.Contains(userName))
                    .FilterByLearner(models)
                    .Where(u => u.UserProfileExtension != null && !u.UserProfileExtension.CurrentTrial.HasValue)
                    .OrderBy(l => l.UID);
            }

            return View(items);
        }

        public async Task<ActionResult> BookingEventsAsync(DateTime start, DateTime end)
        {

            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Json(new object[] { });
            }

            var today = DateTime.Today;

            DailyBookingQueryViewModel viewModel = (DailyBookingQueryViewModel)HttpContext.GetCacheValue("DailyBookingQuery");

            var dataItems = models.GetTable<LessonTime>()
                .Where(t => t.ClassTime >= start && t.ClassTime < end.AddDays(1));

            IQueryable<LessonTime> timeItems = models.GetTable<LessonTime>();

            if(viewModel!=null && viewModel.BranchID.HasValue)
            {
                dataItems = dataItems.Where(t => t.BranchID == viewModel.BranchID);
                timeItems = timeItems.Where(l => l.BranchID==viewModel.BranchID);
            }

            IEnumerable<CalendarEvent> items;
            if (profile.IsFreeAgent())
            {
                items = timeItems
                        .Where(t => t.ClassTime >= start && t.ClassTime < end.AddDays(1))
                        .Where(t => t.AttendingCoach == profile.UID)
                        .Select(t => new { t.ClassTime.Value.Date, t.RegisterLesson.GroupingMemberCount }).ToList()
                        .GroupBy(t => t.Date)
                        .Select(g => new CalendarEvent
                        {
                            id = "freeAgent",
                            title = g.Sum(v => v.GroupingMemberCount).ToString(),
                            start = g.Key.ToString("yyyy-MM-dd"),
                            description = "自由教練",
                            allDay = true,
                            className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-yellow" },
                            icon = /*g.Key < today ? "fa-check" :*/ "fa-tags"
                        });
            }
            else
            {
                items = timeItems
                        .Where(t => t.ClassTime >= start && t.ClassTime < end.AddDays(1))
                        .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自由教練預約)
                        .Select(t => new { t.ClassTime.Value.Date, t.RegisterLesson.GroupingMemberCount }).ToList()
                        .GroupBy(t => t.Date)
                        .Select(g => new CalendarEvent
                        {
                            id = "freeAgent",
                            title = g.Sum(v => v.GroupingMemberCount).ToString(),
                            start = g.Key.ToString("yyyy-MM-dd"),
                            description = "自由教練",
                            allDay = true,
                            className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-yellow" },
                            icon = /*g.Key < today ? "fa-check" :*/ "fa-tags"
                        });

                items = items.Concat(dataItems
                    .Where(t => !t.TrainingBySelf.HasValue || t.TrainingBySelf == 0)
                    .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.正常
                        || t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.已刪除
                    || t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.點數兌換課程)
                    .Select(t => new { ClassDate = t.ClassTime.Value.Date, t.RegisterLesson.UID }).ToList()
                    .GroupBy(t => t.ClassDate)
                    .Select(g => new CalendarEvent
                    {
                        id = "course",
                        title = g.Distinct().Count().ToString(),
                        start = g.Key.ToString("yyyy-MM-dd"),
                        description = "P.T session",
                        allDay = true,
                        className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-blue" },
                        icon = /*g.Key < today ? "fa-check" :*/ "fa-clock-o"
                    }));

                items = items.Concat(dataItems
                    .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI)
                    .Select(t => new { ClassDate = t.ClassTime.Value.Date, t.RegisterLesson.UID }).ToList()
                    .GroupBy(t => t.ClassDate)
                    .Select(g => new CalendarEvent
                    {
                        id = "coach",
                        title = g.Distinct().Count().ToString(),
                        start = g.Key.ToString("yyyy-MM-dd"),
                        description = "教練P.I",
                        allDay = true,
                        className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-teal" },
                        icon = /*g.Key < today ? "fa-check" :*/ "fa-university"
                    }));

                items = items.Concat(dataItems
                    .Where(t => t.TrainingBySelf == 1)
                    .Select(t => new { ClassDate = t.ClassTime.Value.Date, t.RegisterLesson.UID }).ToList()
                    .GroupBy(t => t.ClassDate)
                    .Select(g => new CalendarEvent
                    {
                        id = "self",
                        title = g.Distinct().Count().ToString(),
                        start = g.Key.ToString("yyyy-MM-dd"),
                        description = "P.I session",
                        allDay = true,
                        className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-red" },
                        icon = "fa-child" // g.Key < today ? "fa-ckeck" : "fa-clock-o"
                }));

                items = items.Concat(dataItems
                    .Where(t => t.TrainingBySelf == 2)
                    .Select(t => new { ClassDate = t.ClassTime.Value.Date, t.RegisterLesson.UID }).ToList()
                    .GroupBy(t => t.ClassDate)
                    .Select(g => new CalendarEvent
                    {
                        id = "home",
                        title = g.Distinct().Count().ToString(),
                        start = g.Key.ToString("yyyy-MM-dd"),
                        description = "S.T session",
                        allDay = true,
                        className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-yellow" },
                        icon = "fa-child" // g.Key < today ? "fa-ckeck" : "fa-clock-o"
                    }));

                items = items.Concat(dataItems
                    .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程)
                    .Select(t => new { ClassDate = t.ClassTime.Value.Date, t.RegisterLesson.UID }).ToList()
                    .GroupBy(t => t.ClassDate)
                    .Select(g => new CalendarEvent
                    {
                        id = "trial",
                        title = g.Distinct().Count().ToString(),
                        start = g.Key.ToString("yyyy-MM-dd"),
                        description = "體驗課程",
                        allDay = true,
                        className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-pink" },
                        icon = "fa-magic" // g.Key < today ? "fa-ckeck" : "fa-clock-o"
                    }));
            }


            return Json(items);


        }

        [AllowAnonymous]
        public ActionResult DailyLearnerCount(DateTime date)
        {
            var items = models.GetTable<LessonTime>()
                .Where(t => t.ClassTime >= date.Date && t.ClassTime < date.AddDays(1))
                .Join(models.GetTable<GroupingLesson>(), t => t.GroupID, l => l.GroupID, (t, l) => l)
                .Join(models.GetTable<RegisterLesson>(), g => g.GroupID, r => r.RegisterGroupID, (g, r) => r)
                .Select(t => t.UID)
                .Distinct();

            return Content(items.Count().ToString());
        }

        public async Task<ActionResult> VipEventsAsync(int? id, DateTime start, DateTime end, bool? learner)
        {
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();
            if (item == null)
                item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Json(new object[] { });
            }

            IEnumerable<CalendarEvent> items = item.BuildVipLessonEvents(models, start, end, learner);

            var eventItems = models.GetTable<UserEvent>()
                .Where(v => !v.SystemEventID.HasValue)
                .Where(t => (t.StartDate >= start && t.StartDate < end.AddDays(1))
                    || (t.EndDate >= start && t.EndDate < end.AddDays(1))
                    || (t.StartDate < start && t.EndDate >= end))
                .Where(t => t.UID == item.UID).ToList();

            items = items.Concat(eventItems
                .Select(g => new CalendarEvent
                {
                    id = "my",
                    title = "",
                    start = g.StartDate.ToString("yyyy-MM-dd"),
                    end = g.EndDate.AddDays(1).ToString("yyyy-MM-dd"),
                    description = g.Title + g.ActivityProgram,
                    lessonID = g.EventID,
                    allDay = true,
                    className = new string[] { "event", "bg-color-greenLight" },  //g.StartDate < today ? g.EndDate < today ? new string[] { "event", "bg-color-red" } : new string[] { "event", "bg-color-blue" } : new string[] { "event", "bg-color-pink" },
                    icon = ""   //"fa-magic"
                }));

            return Json(items);


        }

        public async Task<ActionResult> VipLessonEventsAsync(FullCalendarViewModel viewModel)
        {
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
                item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Json(new object[] { });
            }

            IEnumerable<CalendarEvent> items = item.BuildVipLessonEvents(models, viewModel.DateFrom.Value, viewModel.DateTo.Value, true);

            return Json(items);


        }

        public async Task<ActionResult> VipEventAsync(DateTime lessonDate)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Json(new { result = false });
            }

            var items = models.GetTable<LessonTime>().Where(t => t.ClassTime >= lessonDate
                && t.ClassTime < lessonDate.AddDays(1)
                && t.RegisterLesson.UID == profile.UID);

            if (items.Count() == 0)
            {
                return Json(new { result = false, message = "課程資料不存在!!" });
            }

            if(items.Count()>1)
            {
                return View("SelectVipDay", items);
            }
            else
            {
                return View("ToVipDay", items.First());
            }

        }

        public async Task<ActionResult> VipDayAsync(int id)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            var item = models.GetTable<LessonTime>().Where(t => t.LessonID == id
                && t.RegisterLesson.UID == profile.UID).FirstOrDefault();

            if (item == null)
            {
                return RedirectToAction("Vip", "Account");
            }

            ViewBag.LessonTimeExpansion = item.LessonTimeExpansion.First();
            return View(item);

        }

        public async Task<ActionResult> LearnerLessonRemarkAsync(int id, FeedBackViewModel viewModel)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return  Content("連線逾時，請重新登入!!");
            }

            LessonTime lesson = models.GetTable<LessonTime>().Where(l => l.LessonID == id).FirstOrDefault();
            if (lesson == null)
                return Content("課程資料不存在!!");

            LessonFeedBack item = lesson.LessonFeedBack.Where(f => f.RegisterLesson.UID == profile.UID).FirstOrDefault();
            if (item == null)
            {
                if (lesson.RegisterLesson.GroupingMemberCount > 1)
                {
                    RegisterLesson regItem = lesson.GroupingLesson.RegisterLesson.Where(r => r.UID == profile.UID).FirstOrDefault();
                    if (regItem == null)
                        return Content("團體課程資料不存在!!");

                    item = new LessonFeedBack
                    {
                        LessonID = id,
                        RegisterID = regItem.RegisterID,
                        //Status = (int)Naming.IncommingMessageStatus.未讀
                    };
                }
                else
                {
                    item = new LessonFeedBack
                    {
                        LessonID = id,
                        RegisterID = lesson.RegisterID,
                        //Status = (int)Naming.IncommingMessageStatus.未讀
                    };
                }

                lesson.LessonFeedBack.Add(item);
            }

            item.Remark = viewModel.FeedBack;
            item.RemarkDate = DateTime.Now;
            item.Status = (int)Naming.IncommingMessageStatus.未讀;
            models.SubmitChanges();

            return View("~/Views/Lessons/Feedback/LearnerLessonRemarkItem.ascx", lesson);

        }


        public async Task<ActionResult> FeedbackAsync(int id,FeedBackViewModel viewModel)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Json(new { result = false, message = "連線逾時，請重新登入!!" });
            }

            var item = models.GetTable<LessonTime>().Where(t => t.LessonID == id
                && t.RegisterLesson.UID == profile.UID).FirstOrDefault();

            if (item == null)
            {
                return Json(new { result = false, message = "課程資料不存在!!" });
            }

            item.LessonPlan.FeedBack = viewModel.FeedBack;
            item.LessonPlan.FeedBackDate = DateTime.Now;
            if (viewModel.ExecutionFeedBack != null)
            {
                for (int i = 0; i < item.TrainingPlan.Count && i < viewModel.ExecutionFeedBack.Length; i++)
                {
                    item.TrainingPlan[i].TrainingExecution.ExecutionFeedBack = viewModel.ExecutionFeedBack[i];
                    item.TrainingPlan[i].TrainingExecution.ExecutionFeedBackDate = DateTime.Now;
                }
            }
            models.SubmitChanges();

            return Json(new { result = true });

        }

        public async Task<ActionResult> CommitConclusionAsync(int lessonID, String conclusion)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Json(new { result = false, message = "連線已中斷!!" });
            }

            TrainingPlan item = models.GetTable<TrainingPlan>().Where(t => t.LessonID == lessonID).FirstOrDefault();

            if (item == null)
            {
                return Json(new { result = false, message = "課程資料不存在!!" });
            }

            item.TrainingExecution.Conclusion = conclusion;
            models.SubmitChanges();

            return Json(new { result = true });

        }


        public async Task<ActionResult> DailyBookingListJsonAsync(DateTime lessonDate,DateTime? endQueryDate,String category)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Json(new { data = new object[] { } });
            }

            Expression<Func<LessonTime, bool>> queryExpr = l => true;

            if (endQueryDate.HasValue)
            {
                queryExpr = queryExpr.And(l => l.ClassTime >= lessonDate && l.ClassTime < endQueryDate.Value.AddDays(1));
            }
            else
            {
                queryExpr = l => l.ClassTime >= lessonDate && l.ClassTime < lessonDate.AddDays(1);
            }

            if (category == "coach")
            {
                queryExpr = queryExpr.And(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI);
            }
            else if (category == "trial")
            {
                queryExpr = queryExpr.And(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程);
            }

            if (item.IsFreeAgent())
            {
                queryExpr = queryExpr.And(l => l.AttendingCoach == item.UID);
            }

            DailyBookingQueryViewModel viewModel = (DailyBookingQueryViewModel)HttpContext.GetCacheValue("DailyBookingQuery");
            if (viewModel != null && viewModel.BranchID.HasValue)
            {
                queryExpr = queryExpr.And(l => l.BranchID == viewModel.BranchID);
            }

            var items = models.GetTable<LessonTime>().Where(queryExpr)
                .Join(models.GetTable<LessonTimeExpansion>(), t => t.LessonID, p => p.LessonID, (t, p) => p);

            return getBookingListJson(items);
        }

        private ActionResult getBookingListJson(IQueryable<LessonTimeExpansion> items)
        {
            var listItems = items.GroupBy(l => new { ClassDate = l.ClassDate, Hour = l.Hour });

            return Json(new
            {
                data = listItems
                .Select(g => new
                {
                    timezone = String.Format("{0:00}:00 - {1:00}:00", g.Key.Hour, g.Key.Hour + 1),
                    count = g.ToArray()
                        .Select(p=>p.LessonTime.RegisterLesson)
                        .GroupBy(r=>r.RegisterID)
                        .Sum(t => t.First().GroupingMemberCount),
                    booktime = "--",
                    hour = g.Key.Hour,
                    function = "",
                    details = ""    //getDailyBookingMembers(items, g.Key.ClassDate, g.Key.Hour)
                })
                .ToArray()
            });
        }

        public ActionResult DailyBookingList(DateTime lessonDate, DateTime? endQueryDate)
        {
            ViewBag.EndQueryDate = endQueryDate;
            return View(lessonDate);
        }


        public ActionResult DailyTodoList(DateTime lessonDate, DateTime? endQueryDate)
        {
            ViewBag.EndQueryDate = endQueryDate;
            return View(lessonDate);
        }

        [HttpGet]
        public async Task<ActionResult> QueryVipAsync(DateTime? lessonDate, String userName, int? branchID,String category)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            if (!lessonDate.HasValue)
                HttpContext.RemoveCache("DailyBookingQuery");

            DailyBookingQueryViewModel viewModel = HttpContext.InitializeBookingQuery(userName, branchID, item);

            //if (lessonDate.HasValue)
            //{
            //    viewModel.DateFrom = lessonDate;
            //    viewModel.DateTo = lessonDate;
            //    viewModel.HasQuery = true;
            //}

            ViewBag.LessonDate = lessonDate.HasValue ? lessonDate.Value : new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            ViewBag.ViewModel = viewModel;
            ViewBag.Category = category;

            return View();
        }


        public async Task<ActionResult> QueryVipAsync(DailyBookingQueryViewModel viewModel)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            ViewBag.ViewModel = viewModel;

            if(!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View();
            }
            //if (!viewModel.DateFrom.HasValue)
            //{
            //    viewModel.DateFrom = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            //    viewModel.DateTo = viewModel.DateFrom.Value.AddMonths(1).AddDays(-1);
            //}
            //if (!viewModel.MonthInterval.HasValue)
            //    viewModel.MonthInterval = 1;
            viewModel.HasQuery = true;
            HttpContext.SetCacheValue("DailyBookingQuery", viewModel);
            return View();
        }

        public ActionResult QueryLessonList(DateTime? lessonDate,DateTime? start, DateTime? end,String category)
        {
            DailyBookingQueryViewModel viewModel = (DailyBookingQueryViewModel)HttpContext.GetCacheValue("DailyBookingQuery");
            //if (viewModel != null)
            //{
            //    if (start.HasValue)
            //        viewModel.DateFrom = start;
            //    if (end.HasValue)
            //        viewModel.DateTo = end;
            //}

            ViewBag.ViewModel = viewModel;
            ViewBag.LessonDate = lessonDate;
            ViewBag.Category = category;
            return View("~/Views/Lessons/LessonTime/Module/QueryLessonList.ascx");
        }


        public async Task<ActionResult> QueryBookingListAsync(DateTime? lessonDate, DateTime? start, DateTime? end,String category)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            IQueryable<LessonTime> items = queryBookingLessons(item);
            if (start.HasValue)
                items = items.Where(t => t.ClassTime >= start);
            if (end.HasValue)
                items = items.Where(t => t.ClassTime < end.Value.AddDays(1));
            if (category == "coach")
            {
                items = items.Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI);
            }
            else if (category == "trial")
            {
                items = items.Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程);
            }
            ViewBag.StartDate = start;
            ViewBag.EndDate = end;
            ViewBag.Category = category;

            if (lessonDate.HasValue)
            {
                ViewBag.DataItems = items.Join(models.GetTable<LessonTimeExpansion>(),
                    t => t.LessonID, l => l.LessonID, (t, l) => l)
                    .Where(l => l.ClassDate == lessonDate.Value);
                ViewBag.ByQuery = true;
                return View("DailyBookingList", lessonDate);
            }
            else
            {
                ViewBag.DataItems = items;
                return View("QueryBookingList");
            }

        }

        public async Task<ActionResult> DailyBookingMembersByQueryAsync(DateTime lessonDate, int? hour,String category)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return new EmptyResult();
            }

            IQueryable<LessonTime> lessons = queryBookingLessons(item);
            if (category == "coach")
            {
                lessons = lessons.Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI);
            }
            else if (category == "trial")
            {
                lessons = lessons.Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程);
            }

            IQueryable<LessonTimeExpansion> items = lessons.Join(models.GetTable<LessonTimeExpansion>(),
                        n => n.LessonID, t => t.LessonID, (n, t) => t)
                    .Where(t => t.ClassDate == lessonDate)
                    .GroupBy(t => t.LessonID)
                    .Select(g => g.OrderBy(m => m.Hour).First());

            if (hour.HasValue)
            {
                items = items.Where(t => t.Hour == hour);
            }

            if (item.IsFreeAgent())
            {
                //return View("DailyBookingMembersByFreeAgent", items);
                return View("DailyBookingMembers", items);
            }
            else
            {
                return View("DailyBookingMembers", items);
            }
        }


        public async Task<ActionResult> QueryBookingListJsonAsync(DateTime? start, DateTime? end)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Json(new { data = new object[] { } });
            }

            IQueryable<LessonTime> lessons = queryBookingLessons(item);
            if (start.HasValue)
                lessons = lessons.Where(t => t.ClassTime >= start);
            if (end.HasValue)
                lessons = lessons.Where(t => t.ClassTime < end.Value.AddDays(1));

            var items = lessons.Select(t => t.LessonTimeExpansion.OrderBy(l => l.Hour).First());
            return getQueryBookingListJson(items);
        }

        private ActionResult getQueryBookingListJson(IQueryable<LessonTimeExpansion> items)
        {
            var listItems = items
                    .GroupBy(t => t.ClassDate)
                    .ToList();

            return Json(new
            {
                data = listItems
                .Select(g => new
                {
                    timezone = g.Key.ToString("yyyy/MM/dd"),
                    count = g.Select(p=>p.LessonTime.RegisterLesson)
                                .GroupBy(r=>r.RegisterID)
                                .Sum(t => t.First().GroupingMemberCount),
                    booktime = "--",
                    hour = g.Key.Hour,
                    function = "",
                    details = ""//getDailyBookingMembers(items, g.Key, g.Key.Hour)
                })
                .ToArray()
            });
        }

        public async Task<ActionResult> DailyBookingListJsonByQueryAsync(DateTime lessonDate,String category)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Json(new { data = new object[] { } });
            }

            IQueryable<LessonTime> lessons = queryBookingLessons(item).Where(t => t.ClassTime >= lessonDate && t.ClassTime < lessonDate.AddDays(1));
            if (category == "coach")
            {
                lessons = lessons.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI);
            }
            else if (category == "trial")
            {
                lessons = lessons.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程);
            }
            var items = lessons.Select(t => t.LessonTimeExpansion.OrderBy(l => l.Hour).First());

            return getBookingListJson(items);

        }



        private IQueryable<LessonTime> queryBookingLessons(UserProfile profile, DailyBookingQueryViewModel viewModel=null)
        {
            if (viewModel == null)
                viewModel = (DailyBookingQueryViewModel)HttpContext.GetCacheValue("DailyBookingQuery");

            if(viewModel==null)
            {
                return models.GetTable<LessonTime>().Where(l => false);
            }
            DataLoadOptions ops = new DataLoadOptions();
            ops.LoadWith<LessonTime>(i => i.LessonTimeExpansion);
            ops.LoadWith<LessonTime>(i => i.LessonPlan);
            ops.LoadWith<LessonTime>(i => i.RegisterLesson);
            ops.LoadWith<RegisterLesson>(i => i.UserProfile);
            models.DataContext.LoadOptions = ops;
            IQueryable<LessonTime> items = models.GetTable<LessonTime>();

            if (viewModel.DateFrom.HasValue)
            {
                items = items.Where(l => l.ClassTime >= viewModel.DateFrom.Value);
                if (viewModel.MonthInterval.HasValue)
                {
                    items = items.Where(l => l.ClassTime < viewModel.DateFrom.Value.AddMonths(viewModel.MonthInterval.Value));
                }
            }
            if (viewModel.DateTo.HasValue)
                items = items.Where(l => l.ClassTime < viewModel.DateTo.Value.AddDays(1));

            if (viewModel.CoachID.HasValue)
                items = items.Where(l => l.AttendingCoach == viewModel.CoachID);

            if (!string.IsNullOrEmpty(viewModel.UserName))
            {
                items = items.Where(l => l.GroupingLesson.RegisterLesson.Any(r => r.UserProfile.RealName.Contains(viewModel.UserName) || r.UserProfile.Nickname.Contains(viewModel.UserName)));
            }

            if(viewModel.LessonStatus.HasValue)
            {
                switch(viewModel.LessonStatus)
                {
                    case 1:
                        items = items.Where(l => l.LessonAttendance == null);
                        break;
                    case 2:
                        items = items.Where(l => l.LessonAttendance != null);
                        break;
                    case 3:
                        items = items.Where(l => !l.LessonPlan.CommitAttendance.HasValue);
                        break;
                    case 4:
                        items = items.Where(l => l.TrainingBySelf == 1);
                        break;
                    case 5:
                        items = items.Where(l => l.TrainingBySelf == 2);
                        break;
                }
            }

            if(viewModel.BranchID.HasValue)
            {
                items = items.Where(l => l.BranchID == viewModel.BranchID);
            }

            if (profile.IsFreeAgent())
            {
                items = items.Where(l => l.AttendingCoach == profile.UID);
            }

            return items;
        }

        public async Task<ActionResult> QueryBookingPlotAsync()
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Json(new object[] { });
            }

            IQueryable<LessonTime> lessons = queryBookingLessons(item);

            var items = lessons.Join(models.GetTable<LessonTimeExpansion>(),
                t => t.LessonID, l => l.LessonID, (t, l) => l)
                .ToList()
                .GroupBy(t => t.ClassDate);

            return Json(items.Select(g => new
            {
                x = g.Key.ToString("MM/dd"),
                y = g.Select(p=>p.LessonTime.RegisterLesson)
                        .GroupBy(r=>r.RegisterID)
                        .Sum(t => t.First().GroupingMemberCount)
            }).OrderBy(o => o.x).ToArray());

        }

        public async Task<ActionResult> QueryBookingEventsAsync(DateTime start, DateTime end)
        {

            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Json(new object[] { });
            }

            IQueryable<LessonTime> lessons = queryBookingLessons(item);
            lessons = lessons.Where(t => t.ClassTime >= start && t.ClassTime < end.AddDays(1));

            var today = DateTime.Today;
            IEnumerable<CalendarEvent> items;

            if (item.IsFreeAgent())
            {
                items = lessons
                    .Select(t => new { t.ClassTime.Value.Date, t.RegisterLesson.GroupingMemberCount }).ToList()
                    .GroupBy(t => t.Date)
                    .Select(g => new CalendarEvent
                    {
                        id = "freeAgent",
                        title = g.Sum(v => v.GroupingMemberCount).ToString(),
                        start = g.Key.ToString("yyyy-MM-dd"),
                        description = "自由教練",
                        allDay = true,
                        className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-yellow" },
                        icon = /*g.Key < today ? "fa-check" :*/ "fa-tags"
                    });
            }
            else
            {
                items = lessons.Where(l=>l.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自由教練預約)
                    .Select(t => new { t.ClassTime.Value.Date, t.RegisterLesson.GroupingMemberCount }).ToList()
                    .GroupBy(t => t.Date)
                    .Select(g => new CalendarEvent
                    {
                        id = "freeAgent",
                        title = g.Sum(v => v.GroupingMemberCount).ToString(),
                        start = g.Key.ToString("yyyy-MM-dd"),
                        description = "自由教練",
                        allDay = true,
                        className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-yellow" },
                        icon = /*g.Key < today ? "fa-check" :*/ "fa-tags"
                    });

                items = items.Concat(lessons
                        .Where(n => !n.TrainingBySelf.HasValue || n.TrainingBySelf == 0)
                        .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.正常
                            || t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.已刪除
                    || t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.點數兌換課程)
                    .Join(models.GetTable<LessonTimeExpansion>(), n => n.LessonID, t => t.LessonID, (n, t) => t)
                    .Where(t => t.ClassDate >= start && t.ClassDate < end.AddDays(1))
                    .Select(t => new { t.ClassDate, t.LessonID }).ToList()
                    .GroupBy(t => t.ClassDate)
                    .Select(g => new CalendarEvent
                    {
                        id = "course",
                        title = g.Distinct().Count().ToString(),
                        start = g.Key.ToString("yyyy-MM-dd"),
                        description = "P.T session",
                        allDay = true,
                        className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-blue" },
                        icon = /*g.Key < today ? "fa-check" :*/ "fa-clock-o"
                    }));

                items = items.Concat(lessons
                        .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI)
                    .Join(models.GetTable<LessonTimeExpansion>(), n => n.LessonID, t => t.LessonID, (n, t) => t)
                    .Where(t => t.ClassDate >= start && t.ClassDate < end.AddDays(1))
                    .Select(t => new { t.ClassDate, t.LessonID }).ToList()
                    .GroupBy(t => t.ClassDate)
                    .Select(g => new CalendarEvent
                    {
                        id = "coach",
                        title = g.Distinct().Count().ToString(),
                        start = g.Key.ToString("yyyy-MM-dd"),
                        description = "教練P.I",
                        allDay = true,
                        className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-teal" },
                        icon = /*g.Key < today ? "fa-check" :*/ "fa-university"
                    }));

                items = items.Concat(lessons.Where(n => n.TrainingBySelf == 1)
                    .Join(models.GetTable<LessonTimeExpansion>(), n => n.LessonID, t => t.LessonID, (n, t) => t)
                    .Where(t => t.ClassDate >= start && t.ClassDate < end.AddDays(1))
                    .Select(t => new { t.ClassDate, t.LessonID }).ToList()
                    .GroupBy(t => t.ClassDate)
                    .Select(g => new CalendarEvent
                    {
                        id = "self",
                        title = g.Distinct().Count().ToString(),
                        start = g.Key.ToString("yyyy-MM-dd"),
                        description = "P.I session",
                        allDay = true,
                        className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-red" },
                        icon = "fa-child"   //g.Key < today ? "fa-ckeck" : "fa-clock-o"
                }));

                items = items.Concat(lessons.Where(n => n.TrainingBySelf == 2)
                    .Join(models.GetTable<LessonTimeExpansion>(), n => n.LessonID, t => t.LessonID, (n, t) => t)
                    .Where(t => t.ClassDate >= start && t.ClassDate < end.AddDays(1))
                    .Select(t => new { t.ClassDate, t.LessonID }).ToList()
                    .GroupBy(t => t.ClassDate)
                    .Select(g => new CalendarEvent
                    {
                        id = "home",
                        title = g.Distinct().Count().ToString(),
                        start = g.Key.ToString("yyyy-MM-dd"),
                        description = "S.T session",
                        allDay = true,
                        className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-yellow" },
                        icon = "fa-child"   //g.Key < today ? "fa-ckeck" : "fa-clock-o"
                    }));

                items = items.Concat(lessons
                        .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程)
                    .Join(models.GetTable<LessonTimeExpansion>(), n => n.LessonID, t => t.LessonID, (n, t) => t)
                    .Where(t => t.ClassDate >= start && t.ClassDate < end.AddDays(1))
                    .Select(t => new { t.ClassDate, t.LessonID }).ToList()
                    .GroupBy(t => t.ClassDate)
                    .Select(g => new CalendarEvent
                    {
                        id = "trial",
                        title = g.Distinct().Count().ToString(),
                        start = g.Key.ToString("yyyy-MM-dd"),
                        description = "體驗課程",
                        allDay = true,
                        className = g.Key < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-pink" },
                        icon = /*g.Key < today ? "fa-check" :*/ "fa-magic"
                    }));
            }

            return Json(items);

        }


        public async Task<ActionResult> DailyBookingQueryAsync(DailyBookingQueryViewModel viewModel)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            IQueryable<LessonTime> items = models.GetTable<LessonTime>();

            HttpContext.SetCacheValue("DailyBookingQuery", viewModel);

            if (viewModel.DateFrom.HasValue)
            {
                items = items.Where(l => l.ClassTime >= viewModel.DateFrom.Value);
                if (viewModel.MonthInterval.HasValue)
                {
                    items = items.Where(l => l.ClassTime < viewModel.DateFrom.Value.AddMonths(viewModel.MonthInterval.Value));
                }
            }
            if(viewModel.DateTo.HasValue)
                items = items.Where(l => l.ClassTime < viewModel.DateTo.Value.AddDays(1));

            if (viewModel.CoachID.HasValue)
                items = items.Where(l => l.AttendingCoach == viewModel.CoachID);

            if(!string.IsNullOrEmpty(viewModel.UserName))
            {
                items = items.Where(l => l.RegisterLesson.UserProfile.RealName.Contains(viewModel.UserName) || l.RegisterLesson.UserProfile.Nickname.Contains(viewModel.UserName));
            }

            if(item.IsFreeAgent())
            {
                items = items.Where(l => l.AttendingCoach == item.UID);
            }

            ViewBag.DataItems = items;
            return View(DateTime.Today);
        }

        public ActionResult DailyBookingSummary(DateTime lessonDate)
        {
            Dictionary<int, int> index = new Dictionary<int, int>();
            foreach (int idx in Enumerable.Range(8, 15))
            {
                index[idx] = 0;
            }

            var items = models.GetTable<LessonTimeExpansion>()
                .Where(t => t.ClassDate == lessonDate)
                .Select(t => t.Hour).ToList()
                .GroupBy(t => t);

            foreach (var item in items)
            {
                index[item.Key] = item.Count();
            }

            return Json(index.Select(i => new object[] { i.Key, i.Value }).ToArray());
        }

        public async Task<ActionResult> DailyBookingPlotAsync(DateTime lessonDate)
        {
            Dictionary<int, int> index = await dailyBookingHourlyCountAsync(lessonDate);

            return Json(index.Select(i => new
            {
                x = i.Key,
                y = i.Value
            }).ToArray());
        }

        [AllowAnonymous]
        public async Task<ActionResult> DailyBookingHourlyListAsync(DateTime lessonDate)
        {
            Dictionary<int, int> index = await dailyBookingHourlyCountAsync(lessonDate);
            return Content(String.Join(",", index.Select(d => d.Value.ToString())));
        }


        private async Task<Dictionary<int, int>> dailyBookingHourlyCountAsync(DateTime lessonDate)
        {
            Dictionary<int, int> index = new Dictionary<int, int>();
            foreach (int idx in Enumerable.Range(7, 16))
            {
                index[idx] = 0;
            }

            UserProfile profile = await HttpContext.GetUserAsync();

            if (profile != null)
            {
                IQueryable<LessonTimeExpansion> lessonTime;
                //if(profile.IsFreeAgent())
                //{
                //    lessonTime = models.GetTable<LessonTimeExpansion>()
                //        .Where(t => t.LessonTime.AttendingCoach == profile.UID);
                //}
                //else
                {
                    lessonTime = models.GetTable<LessonTimeExpansion>();
                }

                DailyBookingQueryViewModel viewModel = (DailyBookingQueryViewModel)HttpContext.GetCacheValue("DailyBookingQuery");
                if (viewModel != null && viewModel.BranchID.HasValue)
                {
                    lessonTime = lessonTime.Where(t => t.LessonTime.BranchID == viewModel.BranchID);
                }

                var items = lessonTime
                    .Where(t => t.ClassDate == lessonDate)
                    .Select(t => t.Hour).ToList()
                    .GroupBy(t => t);

                foreach (var item in items)
                {
                    index[item.Key] = item.Count();
                }
            }

            return index;
        }

        class GraphDataItem
        {
            public DateTime? ClassTime { get; set; }
            public int ActionLearning { get; set; }
            public int PostureRedress { get; set; }
            public int Training { get; set; }
            public int Cardiopulmonary { get; set; }
            public int Endurance { get; set; }
            public int ExplosiveForce { get; set; }
            public int Flexibility { get; set; }
            public int SportsPerformance { get; set; }
            public int Strength { get; set; }
            public String ClassDate { get; set; }
        }

        GraphDataItem calcAverage(LessonTime item)
        {
            var trend = item.LessonTrend;
            decimal total = 30m;// trend.ActionLearning.Value + trend.PostureRedress.Value + trend.Training.Value;
            var r = new GraphDataItem
            {
                ClassTime = item.ClassTime.Value,
                ClassDate = String.Format("{0:yyyy-MM-dd}",item.ClassTime),
                ActionLearning = (int)Math.Round(trend.ActionLearning.Value * 100m / total),
                PostureRedress = (int)Math.Round(trend.PostureRedress.Value * 100m / total),
                Training = (int)Math.Round(trend.Training.Value * 100m / total)
            };
            //r.Training = 100 - r.ActionLearning - r.PostureRedress;
            return r;
        }

        GraphDataItem fitnessAverage(LessonTime item)
        {
            var fitness = item.FitnessAssessment;
            decimal total = 60m;
            //decimal total = (fitness.Cardiopulmonary ?? 0)
            //    + (fitness.Endurance ?? 0)
            //    + (fitness.ExplosiveForce ?? 0)
            //    + (fitness.Flexibility ?? 0)
            //    + (fitness.SportsPerformance ?? 0)
            //    + (fitness.Strength ?? 0);

            if (total == 0)
            {
                return new GraphDataItem
                {

                };
            }

            var r = new GraphDataItem
            {
                ClassTime = item.ClassTime.Value,
                ClassDate = String.Format("{0:yyyy-MM-dd}", item.ClassTime),
                Cardiopulmonary = (int)Math.Round((fitness.Cardiopulmonary ?? 0) * 100m / total),
                Endurance = (int)Math.Round((fitness.Endurance ?? 0 ) * 100m / total),
                ExplosiveForce = (int)Math.Round((fitness.ExplosiveForce ?? 0 ) * 100m / total),
                Flexibility = (int)Math.Round((fitness.Flexibility ?? 0 ) * 100m / total),
                SportsPerformance = (int)Math.Round((fitness.SportsPerformance ?? 0 ) * 100m / total),
                Strength = (int)Math.Round((fitness.Strength ?? 0) * 100m / total)
            };

            //r.Strength = 100
            //    - r.Cardiopulmonary
            //    - r.Endurance
            //    - r.ExplosiveForce
            //    - r.Flexibility
            //    - r.SportsPerformance;

            return r;
        }


        public async Task<ActionResult> FitnessGraphAsync(DateTime start, DateTime end)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Json(new object[] { });
            }

            DateTime startDate = start < end ? new DateTime(start.Year, start.Month, 1) : new DateTime(end.Year, end.Month, 1);
            DateTime endDate = start >= end ? start : end;

            var items = models.GetTable<LessonTime>()
                .Where(t => t.ClassTime >= startDate && t.ClassTime < endDate.AddDays(1))
                .Where(t => t.RegisterLesson.UID == profile.UID)
                .Where(t => t.LessonAttendance != null).ToArray()
                .Select(t => fitnessAverage(t)).ToArray();

            return Json(items);

            //var idx = Enumerable.Range(0, items.Length);
            //int section = items.Length >= 12 ? (items.Length + 11) / 12 : 1;

            //return Json(
            //    new
            //    {
            //        data = new object[]
            //        {
            //            new
            //            {
            //                label = "柔軟度",
            //                data = idx.Select(g=>new object[]
            //                {
            //                    g,
            //                    items[g].Flexibility
            //                }).ToArray()
            //            },
            //            new
            //            {
            //                label = "心肺",
            //                data = idx.Select(g=>new object[]
            //                {
            //                    g,
            //                    items[g].Cardiopulmonary
            //                }).ToArray()
            //            },
            //            new
            //            {
            //                label = "肌力",
            //                data = idx.Select(g=>new object[]
            //                {
            //                    g,
            //                    items[g].Strength
            //                }).ToArray()
            //            },
            //            new
            //            {
            //                label = "肌耐力",
            //                data = idx.Select(g=>new object[]
            //                {
            //                    g,
            //                    items[g].Endurance
            //                }).ToArray()
            //            },
            //            new
            //            {
            //                label = "爆發力",
            //                data = idx.Select(g=>new object[]
            //                {
            //                    g,
            //                    items[g].ExplosiveForce
            //                }).ToArray()
            //            },
            //            new
            //            {
            //                label = "運動表現",
            //                data = idx.Select(g=>new object[]
            //                {
            //                    g,
            //                    items[g].SportsPerformance
            //                }).ToArray()
            //            }
            //        },
            //        ticks = idx.Select(g => new object[]
            //            {
            //                g,
            //                //g%section==0 ? (g+1).ToString() : ""
            //                ""
            //            }).ToArray()
            //    });
        }


        public async Task<ActionResult> TrendGraphAsync(DateTime start, DateTime end)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Json(new object[] { });
            }

            DateTime startDate = start < end ? new DateTime(start.Year, start.Month, 1) : new DateTime(end.Year, end.Month, 1);
            DateTime endDate = start >= end ? start : end;

            var items = models.GetTable<LessonTime>()
                .Where(t => t.ClassTime >= startDate && t.ClassTime < endDate.AddDays(1))
                .Where(t => t.RegisterLesson.UID == profile.UID)
                .Where(t => t.LessonAttendance != null).ToArray()
                .Select(t => calcAverage(t)).ToArray();

            return Json(items);

            //var idx = Enumerable.Range(0, items.Length);
            //int section = items.Length >= 12 ? (items.Length + 11) / 12 : 1;

            //return Json(
            //    new
            //    {
            //        data = new object[]
            //        {
            //            new
            //            {
            //                label = "動作學習",
            //                data = idx.Select(g=>new object[]
            //                {
            //                    g,
            //                    items[g].ActionLearning
            //                }).ToArray()
            //            },
            //            new
            //            {
            //                label = "姿勢矯正",
            //                data = idx.Select(g=>new object[]
            //                {
            //                    g,
            //                    items[g].PostureRedress
            //                }).ToArray()
            //            },
            //            new
            //            {
            //                label = "訓練",
            //                data = idx.Select(g=>new object[]
            //                {
            //                    g,
            //                    items[g].Training
            //                }).ToArray()
            //            }
            //        },
            //        ticks = idx.Select(g => new object[]
            //            {
            //                g,
            //                //g%section==0 ? (g+1).ToString() : ""
            //                ""
            //            }).ToArray()
            //    });
        }


        public async Task<ActionResult> TrendGraphAverageAsync(DateTime start, DateTime end)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Json(new object[] { });
            }

            DateTime startDate = start < end ? new DateTime(start.Year,start.Month,1) : new DateTime(end.Year, end.Month, 1);
            DateTime endDate = start >= end ? start : end;

            var items = models.GetTable<LessonTime>()
                .Where(t => t.ClassTime >= startDate && t.ClassTime < endDate.AddDays(1))
                .Where(t => t.RegisterLesson.UID == profile.UID)
                .Where(t => t.LessonAttendance != null).ToArray()
                .Select(t=> calcAverage(t))
                .GroupBy(t => new { Year = t.ClassTime.Value.Year, Month = t.ClassTime.Value.Month })
                .Select(g => new
                {
                    Key = g.Key,
                    ActonLearning = (g.Sum(v => v.ActionLearning) + g.Count() / 2) / g.Count(),
                    PostureRedress = (g.Sum(v => v.PostureRedress) + g.Count() / 2) / g.Count(),
                    Training = (g.Sum(v => v.Training) + g.Count() / 2) / g.Count()
                });

            return Json(
                new
                {
                    data = new object[]
                    {
                        new
                        {
                            label = "動作學習",
                            data = items.Select(g=>new object[]
                            {
                                (g.Key.Year-startDate.Year)*12+g.Key.Month-startDate.Month,
                                g.ActonLearning
                            }).ToArray() },
                        new
                        {
                            label = "姿勢矯正",
                            data = items.Select(g => new object[]
                            {
                                (g.Key.Year-startDate.Year)*12+g.Key.Month-startDate.Month,
                                g.PostureRedress
                            }).ToArray()
                        },
                        new
                        {
                            label = "訓練",
                            data = items.Select(g => new object[]
                            {
                                (g.Key.Year-startDate.Year)*12+g.Key.Month-startDate.Month,
                                g.Training
                            }).ToArray()
                        }
                    },
                    ticks = Enumerable.Range(0, (end.Year - start.Year) * 12 + end.Month - start.Month + 1)
                        .Select(g => new object[]
                        {
                            g,
                            String.Format("{0:00}",(start.Month-1+g)%12+1)
                        }).ToArray()
                });
        }

        async Task<string> getDailyBookingMembersAsync(IQueryable<LessonTimeExpansion> items, DateTime lessonDate, int? hour)
        {
            IQueryable<LessonTimeExpansion> listItems = items.GroupBy(t => t.LessonID).Select(g => g.OrderBy(m => m.Hour).First());

            if (hour.HasValue)
            {
                listItems = listItems.Where(t => t.Hour == hour);
            }

            return await RenderViewToStringAsync("DailyBookingMembers", listItems);

        }

        //public String getDailyBookingMembersByQuery(UserProfile item,DateTime lessonDate, int? hour)
        //{

        //    IQueryable<LessonTime> lessons = queryBookingLessons(item);
        //    IQueryable<LessonTimeExpansion> items = lessons.Join(models.GetTable<LessonTimeExpansion>(),
        //                n => n.LessonID, t => t.LessonID, (n, t) => t)
        //            .Where(t => t.ClassDate == lessonDate)
        //            .GroupBy(t => t.LessonID).Select(g => g.OrderBy(m => m.Hour).First());

        //    if (hour.HasValue)
        //    {
        //        items = items.Where(t => t.Hour == hour);
        //    }

        //    return this.RenderViewToString("DailyBookingMembers", new ViewDataDictionary(items), this.TempData);
        //}

        public async Task<ActionResult> DailyBookingMembersAsync(DateTime lessonDate, int? hour,String category)
        {
            //IQueryable<LessonTimeExpansion> items = models.GetTable<LessonTimeExpansion>().Where(t => t.ClassDate == lessonDate);
            //if(hour.HasValue)
            //{
            //    items = items.Where(t => t.Hour == hour);
            //}

            //return View(items.GroupBy(l => l.LessonID).Select(g => g.First()));

            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return new EmptyResult();
            }

            DailyBookingQueryViewModel viewModel = (DailyBookingQueryViewModel)HttpContext.GetCacheValue("DailyBookingQuery");

            if (profile.IsFreeAgent())
            {
                IQueryable<LessonTimeExpansion> items = models.GetTable<LessonTimeExpansion>();
                if(viewModel!=null && viewModel.BranchID.HasValue)
                {
                    items = items.Where(t => t.LessonTime.BranchID == viewModel.BranchID);
                }
                if (hour.HasValue)
                {
                    items = items.Where(t => t.Hour == hour);
                }
                if (category == "coach")
                {
                    items = items.Where(t => t.LessonTime.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI);
                }
                else if (category == "trial")
                {
                    items = items.Where(t => t.LessonTime.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程);
                }

                items = items.Where(t => t.LessonTime.AttendingCoach == profile.UID)
                    .Where(t => t.ClassDate == lessonDate)
                    .GroupBy(l => l.LessonID).Select(g => g.OrderBy(m => m.Hour).First());

                //return View("DailyBookingMembersByFreeAgent", items);
                return View(items);
            }
            else
            {
                IQueryable<LessonTimeExpansion> items = models.GetTable<LessonTimeExpansion>();
                if (viewModel != null && viewModel.BranchID.HasValue)
                {
                    items = items.Where(t => t.LessonTime.BranchID == viewModel.BranchID);
                }
                if (hour.HasValue)
                {
                    items = items.Where(t => t.Hour == hour);
                }
                if (category == "coach")
                {
                    items = items.Where(t => t.LessonTime.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI);
                }
                else if (category == "trial")
                {
                    items = items.Where(t => t.LessonTime.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程);
                }


                items = items.Where(t => t.ClassDate == lessonDate)
                    .GroupBy(l => l.LessonID).Select(g => g.OrderBy(m => m.Hour).First());

                return View(items);
            }

        }

        //public ActionResult DailyBookingMembersByFreeAgent(DateTime lessonDate, int? hour)
        //{
        //    return DailyBookingMembers(lessonDate, hour);
        //}

        public async Task<ActionResult> RevokeBookingAsync(int lessonID)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            LessonTime item = models.GetTable<LessonTime>().Where(l => l.LessonID == lessonID).FirstOrDefault();
            if (item == null)
            {
                ViewBag.Message = "課程資料不存在!!";
                return RedirectToAction("Coach", "Account", new { message = "課程資料不存在!!" });
            }
            else if (item.ContractTrustTrack.Any(t => t.SettlementID.HasValue))
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "課程資料已信託，不可取消!!");
            }
            //else if (item.LessonPlan != null || item.TrainingPlan.Count > 0)
            //{
            //    ViewBag.Message = "請先刪除預編課程!!";
            //    return RedirectToAction("Coach", "Account", new { lessonDate = lessonDate, message= "請先刪除預編課程!!" });
            //}

            item.RevokeBooking(models);

            ViewBag.Message = "課程預約已取消!!";
            return RedirectToAction("Coach", "Account", new { lessonDate = item.ClassTime.Value.Date ,message = "課程預約已取消!!" });

        }

        public async Task<ActionResult> RevokeBookingByFreeAgentAsync(int lessonID)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            LessonTime item = models.GetTable<LessonTime>().Where(l => l.LessonID == lessonID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "課程資料不存在!!" });
            }

            models.DeleteAny<LessonTime>(l => l.LessonID == lessonID);
            models.DeleteAny<RegisterLesson>(l => l.RegisterID == item.RegisterID);

            return Json(new { result = true });

        }

        public ActionResult PreviewLesson(LessonTimeExpansionViewModel viewModel)
        {
            var item = models.GetTable<LessonTimeExpansion>().Where(l => l.ClassDate == viewModel.ClassDate
                && l.LessonTime.RegisterID == viewModel.RegisterID && l.Hour == viewModel.Hour).First();

            //return View(item);
            ViewBag.PreviewLesson = true;
            return View("~/Views/Lessons/LessonTime/DataItem.aspx", item);

        }

        public ActionResult PreviewLessonTime(LessonTimeExpansionViewModel viewModel)
        {
            var item = models.GetTable<LessonTimeExpansion>().Where(l => l.ClassDate == viewModel.ClassDate
                && l.LessonTime.RegisterID == viewModel.RegisterID && l.Hour == viewModel.Hour).First();

            return View("~/Views/Lessons/LessonTime/DataItem.aspx", item);

        }


        public ActionResult UpdateLessonPlanRemark(int lessonID,String remark)
        {
            models.ExecuteCommand(@"
                UPDATE LessonPlan
                SET        Remark = {1}
                WHERE   (LessonID = {0})", lessonID, remark);

            return Json(new { result = true });

        }


        public ActionResult DailyTrendPie(int lessonID, bool? isLearner)
        {
            var item = models.GetTable<LessonTime>().Where(l => l.LessonID == lessonID).FirstOrDefault();

            if (item == null || item.LessonTrend == null)
                return Json(new object[] { });

            var trend = item.LessonTrend;

            if (isLearner == true)
            {
                return Json(new object[] {
                    new {
                        label = "動作學習",
                        data = trend.ActionLearning
                    },
                    new {
                        label = "姿勢矯正",
                        data = trend.PostureRedress
                    },
                    new {
                        label = "訓練",
                        data = trend.Training
                    }
                });
            }
            else
            {
                return Json(new object[] {
                    new {
                        label = "動作學習",
                        data = trend.ActionLearning
                    },
                    new {
                        label = "姿勢矯正",
                        data = trend.PostureRedress
                    },
                    new {
                        label = "訓練",
                        data = trend.Training
                    },
                    new {
                        label = "狀態溝通",
                        data = trend.Counseling
                    }
                });
            }

        }

        public ActionResult DailyFitnessPie(int lessonID)
        {
            var item = models.GetTable<LessonTime>().Where(l => l.LessonID == lessonID).FirstOrDefault();

            if (item==null || item.FitnessAssessment == null)
                return Json(new object[] { });

            var fitness = item.FitnessAssessment;

            return Json(new object[] {
                new {
                    label = "柔軟度",
                    data = fitness.Flexibility
                },
                new {
                    label = "心肺",
                    data = fitness.Cardiopulmonary
                },
                new {
                    label = "肌力",
                    data = fitness.Strength
                },
                new {
                    label = "肌耐力",
                    data = fitness.Endurance
                },
                new {
                    label = "爆發力",
                    data = fitness.ExplosiveForce
                },
                new {
                    label = "運動表現",
                    data = fitness.SportsPerformance
                }
            });

        }


        [CoachOrAssistantAuthorize]
        public ActionResult TrainingPlan(LessonTimeExpansionViewModel viewModel)
        {

            var item = models.GetTable<LessonTimeExpansion>().Where(l => l.ClassDate == viewModel.ClassDate
                && l.LessonTime.RegisterID == viewModel.RegisterID && l.Hour == viewModel.Hour).FirstOrDefault();

            if (item == null)
            {
                ViewBag.ViewModel = new DailyBookingQueryViewModel
                {
                    Message = "上課時間資料不存在!!",
                };
                return View("~/Views/Account/Coach");
            }

            HttpContext.SetCacheValue("Training", item);
            //return View(item);
            return View("~/Views/Lessons/LessonTime/EditItem.aspx", item);

        }

        public ActionResult EditLessonTime(LessonTimeExpansionViewModel viewModel)
        {

            var item = models.GetTable<LessonTimeExpansion>().Where(l => l.ClassDate == viewModel.ClassDate
                && l.LessonTime.RegisterID == viewModel.RegisterID && l.Hour == viewModel.Hour).FirstOrDefault();

            if (item == null)
            {
                ViewBag.ViewModel = new DailyBookingQueryViewModel
                {
                    Message = "上課時間資料不存在!!",
                };
                return View("~/Views/Account/Coach"); 
            }

            HttpContext.SetCacheValue("Training", item);
            return View("~/Views/Lessons/LessonTime/EditItem.aspx", item);
        }

        public ActionResult MakeTrainingPlan(int lessonID)
        {

            var item = models.GetTable<LessonTime>().Where(l => l.LessonID == lessonID).FirstOrDefault();

            if (item == null)
            {
                ViewBag.ViewModel = new DailyBookingQueryViewModel
                {
                    Message = "上課時間資料不存在!!",
                };
                return View("~/Views/Account/Coach");
            }

            var model = item.LessonTimeExpansion.First();
            HttpContext.SetCacheValue("Training", model);
            return View("~/Views/Lessons/LessonTime/EditItem.aspx", model);
        }

        public ActionResult TrainingStagePlan(int lessonID)
        {
            ViewResult result = (ViewResult)SingleTrainingExecutionPlan(lessonID);
            result.ViewName = "~/Views/Lessons/Module/TrainingStagePlan.ascx";
            return result;
        }


        public ActionResult SingleTrainingExecutionPlan(int lessonID)
        {

            var item = models.GetTable<LessonTime>().Where(l => l.LessonID == lessonID).First();

            var plan = item.AssertTrainingPlan(models);

            return View("SingleTrainingExecutionPlan", plan.TrainingExecution);
        }

        public ActionResult DeletePlan()
        {
            LessonTimeExpansion item = (LessonTimeExpansion)HttpContext.GetCacheValue("Training");

            if (item == null)
            {
                ViewBag.Message = "未登記此上課時間!!";
                return RedirectToAction("Coach", "Account");
            }

            models.DeleteAllOnSubmit<TrainingPlan>(p => p.LessonID == item.LessonID);
            models.DeleteAllOnSubmit<LessonPlan>(p => p.LessonID == item.LessonID);
            models.SubmitChanges();

            HttpContext.RemoveCache("Training");
            return RedirectToAction("Coach", "Account", new { lessonDate = item.ClassDate, hour = item.Hour, registerID = item.LessonTime.RegisterID, lessonID = item.LessonID });
        }

        public ActionResult CompletePlan()
        {
            LessonTimeExpansion item = (LessonTimeExpansion)HttpContext.GetCacheValue("Training");

            if (item == null)
            {
                return RedirectToAction("Coach", "Account");
            }

            HttpContext.RemoveCache("Training");
            return RedirectToAction("Coach", "Account", new { lessonDate = item.ClassDate, hour = item.Hour, registerID = item.LessonTime.RegisterID, lessonID = item.LessonID });
        }

        public ActionResult CommitPlan(TrainingPlanViewModel viewModel)
        {
            ActionResult result;
            LessonTimeExpansion model;
            LessonPlan plan = prepareLessonPlan(out result, out model);

            if (result != null)
                return result;

            plan.Warming = viewModel.Warming;
            //plan.RecentStatus = viewModel.RecentStatus;
            //model.RegisterLesson.UserProfile.RecentStatus = viewModel.RecentStatus;
            plan.EndingOperation = viewModel.EndingOperation;
            plan.Remark = viewModel.Remark;


            //execution.Repeats = viewModel.Repeats;
            //execution.BreakIntervalInSecond = viewModel.BreakInterval;

            //for (int i = 0; i < execution.TrainingItem.Count && i < viewModel.TrainingID.Length; i++)
            //{
            //    var item = execution.TrainingItem[i];
            //    item.TrainingID = (viewModel.TrainingID[i]).Value;
            //    item.GoalStrength = viewModel.GoalStrength[i];
            //    item.GoalTurns = viewModel.GoalTurns[i];
            //    item.Description = viewModel.Description[i];
            //}

            //execution.TrainingPlan.PlanStatus = (int)Naming.DocumentLevelDefinition.正常;

            models.SubmitChanges();
            //HttpContext.RemoveCache("Training");

            //return RedirectToAction("Coach", "Account", new { lessonDate = model.ClassDate, hour = model.Hour, registerID = model.RegisterID, lessonID = model.LessonID });
            return Json(new { result = true, message = "資料更新完成!!" });

        }

        public ActionResult EditRecentStatus(int uid)
        {
            UserProfile profile = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (profile == null)
            {
                return Content("學員資料錯誤!!");
            }

            return View(profile);
        }

        public ActionResult CommitRecentStatus(int uid,String recentStatus)
        {

            UserProfile profile = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (profile == null)
            {
                return Content("學員資料錯誤!!");
            }

            profile.RecentStatus = recentStatus;

            models.SubmitChanges();
            return Json(new { result = true, message = "資料更新完成!!" });

        }

        private LessonPlan prepareLessonPlan(out ActionResult result,out LessonTimeExpansion model)
        {
            result = null;
            LessonTimeExpansion item = (LessonTimeExpansion)HttpContext.GetCacheValue("Training");

            model = null;
            if (item != null)
            {
                model = models.GetTable<LessonTimeExpansion>()
                    .Where(l => l.ExpansionID == item.ExpansionID)
                    .FirstOrDefault();
            }

            if (model == null)
            {
                ViewBag.Message = "未登記此上課時間!!";
                result = RedirectToAction("Coach", "Account");
                return null;
            }

            LessonPlan plan = model.LessonTime.LessonPlan;
            if (plan == null)
                plan = model.LessonTime.LessonPlan = new LessonPlan { };

            return plan;
        }

        public ActionResult DeleteTraining(int id)
        {
            LessonTimeExpansion item = (LessonTimeExpansion)HttpContext.GetCacheValue("Training");
            models.DeleteAny<TrainingPlan>(t => t.ExecutionID == id && t.LessonID == item.LessonID);

            LessonTimeExpansion model = models.GetTable<LessonTimeExpansion>()
                .Where(l => l.ExpansionID == item.ExpansionID).First();

            return View("TrainingExecutionPlan", model);
        }


        public virtual ActionResult AddTraining(TrainingPlanViewModel viewModel)
        {
            ActionResult result;
            LessonTimeExpansion model;
            LessonPlan plan = prepareLessonPlan(out result,out model);

            if (result != null)
                return result;

            plan.Warming = viewModel.Warming;
            //plan.RecentStatus = viewModel.RecentStatus;
            //model.RegisterLesson.UserProfile.RecentStatus = viewModel.RecentStatus;
            plan.EndingOperation = viewModel.EndingOperation;
            plan.Remark = viewModel.Remark;

            models.SubmitChanges();

            HttpContext.RemoveCache("TrainingExecution");
            return View("AddTraining",new TrainingExecution { });
        }


        public ActionResult AddTrainingItem(int id)
        {
            TrainingExecution item = models.GetTable<TrainingExecution>().Where(x => x.ExecutionID == id).First();
            ViewBag.ViewModel = new TrainingItemViewModel
            {
                ExecutionID = item.ExecutionID
            };

            return View("EditSingleTrainingItem", item);
        }

        public ActionResult AddTrainingBreakInterval(int id)
        {
            TrainingExecution item = models.GetTable<TrainingExecution>().Where(x => x.ExecutionID == id).First();
            ViewBag.ViewModel = new TrainingItemViewModel
            {
                ExecutionID = item.ExecutionID
            };

            return View("EditBreakInterval", item);
        }

        public ActionResult CloneTrainingPlan(int lessonID, int sourceID,LessonTimeExpansionViewModel viewModel)
        {
            if(lessonID==sourceID)
            {
                return Json(new { result = false, message = "複製來源與目的課程不能相同!!" });
            }

            var srcItem = models.GetTable<LessonTime>().Where(t => t.LessonID == sourceID).First();
            var targetItem = models.GetTable<LessonTime>().Where(t => t.LessonID == lessonID).First();

            models.DeleteAll<TrainingPlan>(t => t.LessonID == targetItem.LessonID);

            if (srcItem.LessonPlan != null)
            {
                if (targetItem.LessonPlan == null)
                    targetItem.LessonPlan = new LessonPlan { };
                targetItem.LessonPlan.Warming = srcItem.LessonPlan.Warming;
                targetItem.LessonPlan.EndingOperation = srcItem.LessonPlan.EndingOperation;
            }


            foreach (var p in srcItem.TrainingPlan)
            {
                var newItem = new TrainingPlan
                {
                    LessonID = lessonID,
                    PlanStatus = p.PlanStatus,
                    //RegisterID = p.RegisterID,
                    TrainingExecution = new TrainingExecution
                    {
                        Emphasis = null //p.TrainingExecution.Emphasis
                    }
                };

                newItem.TrainingExecution.TrainingExecutionStage.AddRange(p.TrainingExecution.TrainingExecutionStage
                    .Select(t => new TrainingExecutionStage
                    {
                        StageID = t.StageID,
                        TotalMinutes = t.TotalMinutes
                    }));

                foreach(var i in p.TrainingExecution.TrainingItem)
                {
                    var item = new TrainingItem
                    {
                        ActualStrength = i.ActualStrength,
                        ActualTurns = i.ActualTurns,
                        BreakIntervalInSecond = i.BreakIntervalInSecond,
                        Description = i.Description,
                        GoalStrength = i.GoalStrength,
                        GoalTurns = i.GoalTurns,
                        Remark = i.Remark,
                        Repeats = i.Repeats,
                        Sequence = i.Sequence,
                        TrainingID = i.TrainingID,
                        DurationInMinutes = i.DurationInMinutes,
                    };

                    newItem.TrainingExecution.TrainingItem.Add(item);
                    item.TrainingItemAids.AddRange(i.TrainingItemAids
                        .Select(a => new TrainingItemAids
                        {
                            AidID = a.AidID
                        }));

                }

                models.GetTable<TrainingPlan>().InsertOnSubmit(newItem);

            }

            models.SubmitChanges();

            return Json(new { result = true });
            
        }


        public ActionResult QueryLessonTime(DailyBookingQueryViewModel viewModel,LessonTimeExpansionViewModel timeModel)
        {
            ViewBag.ViewModel = viewModel;
            ViewBag.LessonTimeExpansion = timeModel;
            return View();
        }

        public ActionResult QueryLessonTimeList(DailyBookingQueryViewModel viewModel)
        {
            IQueryable<LessonTime> items = models.GetTable<LessonTime>()
                .Where(t => t.TrainingPlan.Any(p => p.TrainingExecution.TrainingItem.Count > 0));

            if (viewModel.CoachID.HasValue)
                items = items.Where(t => t.AttendingCoach == viewModel.CoachID.Value);

            if (viewModel.TrainingBySelf.HasValue)
            {
                items = items.Where(t => t.TrainingBySelf == viewModel.TrainingBySelf);
            }
            else 
            {
                items = items.Where(t => !t.TrainingBySelf.HasValue || t.TrainingBySelf == 0);
            }

            if (!String.IsNullOrEmpty(viewModel.UserName))
            {
                items = items.Where(t => t.RegisterLesson.UserProfile.RealName.Contains(viewModel.UserName) || t.RegisterLesson.UserProfile.Nickname.Contains(viewModel.UserName));
            }

            ViewBag.ViewModel = viewModel;

            return View(items.OrderByDescending(t => t.LessonID).Take(20));
        }

        public ActionResult EditTrainingItem(int executionID,int itemID)
        {
            TrainingItem item = models.GetTable<TrainingItem>().Where(x => x.ExecutionID == executionID && x.ItemID == itemID).First();

            ViewBag.ViewModel = new TrainingItemViewModel
            {
                ExecutionID = item.ExecutionID,
                ActualStrength = item.ActualStrength,
                ActualTurns = item.ActualTurns,
                BreakInterval = item.BreakIntervalInSecond,
                Description = item.Description,
                GoalStrength = item.GoalStrength,
                GoalTurns = item.GoalTurns,
                Remark = item.Remark,
                Repeats = item.Repeats,
                TrainingID = item.TrainingID,
                ItemID = item.ItemID
            };

            ViewBag.Edit = true;

            return View("EditSingleTrainingItem", item.TrainingExecution);
        }

        public ActionResult EditTrainingBreakInterval(int executionID, int itemID)
        {
            TrainingItem item = models.GetTable<TrainingItem>().Where(x => x.ExecutionID == executionID && x.ItemID == itemID).First();

            ViewBag.ViewModel = new TrainingItemViewModel
            {
                ExecutionID = item.ExecutionID,
                BreakInterval = item.BreakIntervalInSecond,
                Remark = item.Remark,
                Repeats = item.Repeats,
                ItemID = item.ItemID
            };

            ViewBag.Edit = true;

            return View("EditBreakInterval", item.TrainingExecution);
        }

        public ActionResult EditTraining(int id)
        {

            TrainingExecution execution = models.GetTable<TrainingExecution>().Where(t => t.ExecutionID == id).FirstOrDefault();
            if(execution==null)
            {
                ViewBag.Message = "修改項目不存在!!";
                return View("AddTraining", new TrainingExecution { });
            }
            HttpContext.SetCacheValue("TrainingExecution", execution.ExecutionID);
            return View("AddTraining", execution);
        }

        public ActionResult UpdateTrainingItemSequence(int id,int[] itemID)
        {
            if (itemID != null && itemID.Length > 0)
            {
                for (int i = 0; i < itemID.Length; i++)
                {
                    var item = models.GetTable<TrainingItem>().Where(t => t.ItemID == itemID[i]).FirstOrDefault();
                    if (item != null)
                        item.Sequence = i;
                }
                models.SubmitChanges();
            }
            return SingleTrainingExecutionPlan(id);
        }

        public ActionResult UpdateStageTrainingItemSequence(int[] itemID)
        {
            if (itemID != null && itemID.Length > 0)
            {
                for (int i = 0; i < itemID.Length; i++)
                {
                    var item = models.GetTable<TrainingItem>().Where(t => t.ItemID == itemID[i]).FirstOrDefault();
                    if (item != null)
                        item.Sequence = i;
                }
                models.SubmitChanges();
            }

            return Json(new { result = true });

        }



        public ActionResult CommitTrainingItem(TrainingItemViewModel viewModel)
        {
            if(!ModelState.IsValid)
            {
                return Json(new { result = false, message = ModelState.ErrorMessage() });
            }

            TrainingExecution execution = models.GetTable<TrainingExecution>().Where(t=>t.ExecutionID==viewModel.ExecutionID).FirstOrDefault();
            if(execution==null)
            {
                return Json(new { result = false, message = "預編課程項目不存在!!" });
            }

            TrainingItem item;
            if (viewModel.ItemID.HasValue)
            {
                item = execution.TrainingItem.Where(i => i.ItemID == viewModel.ItemID).FirstOrDefault();
                if(item==null)
                {
                    return Json(new { result = false, message = "修改動作項目不存在!!" });
                }
                item.ActualStrength = viewModel.ActualStrength;
                item.ActualTurns = viewModel.ActualTurns;
            }
            else
            {
                item = new TrainingItem
                {
                    ActualTurns = viewModel.GoalTurns,
                    ActualStrength = viewModel.GoalStrength,
                    Sequence = int.MaxValue
                };
                execution.TrainingItem.Add(item);
            }

            item.Description = viewModel.Description;
            item.GoalStrength = viewModel.GoalStrength;
            item.GoalTurns = viewModel.GoalTurns;
            item.TrainingID = viewModel.TrainingID;
            item.Remark = viewModel.Remark;

            models.SubmitChanges();
            return Json(new { result = true, message = "" });

        }

        public ActionResult CommitTrainingBreakInterval(TrainingItemViewModel viewModel)
        {
            if (!ModelState.IsValid)
            {
                return Json(new { result = false, message = ModelState.ErrorMessage() });
            }

            TrainingExecution execution = models.GetTable<TrainingExecution>().Where(t => t.ExecutionID == viewModel.ExecutionID).FirstOrDefault();
            if (execution == null)
            {
                return Json(new { result = false, message = "預編課程項目不存在!!" });
            }

            TrainingItem item;
            if (viewModel.ItemID.HasValue)
            {
                item = execution.TrainingItem.Where(i => i.ItemID == viewModel.ItemID).FirstOrDefault();
                if (item == null)
                {
                    return Json(new { result = false, message = "修改動作項目不存在!!" });
                }
            }
            else
            {
                item = new TrainingItem
                {
                    Sequence = int.MaxValue
                };
                execution.TrainingItem.Add(item);
            }

            item.BreakIntervalInSecond = viewModel.BreakInterval;
            item.Repeats = viewModel.Repeats;
            item.Remark = viewModel.Remark;

            models.SubmitChanges();
            return Json(new { result = true, message = "" });

        }


        public ActionResult CreateTrainingItem(TrainingExecutionViewModel viewModel)
        {
            TrainingExecution execution = prepareTrainingExecution();

            if (!ModelState.IsValid)
            {
                return Json(new { result = false, message = ModelState.ErrorMessage() });
            }

            execution.Repeats = viewModel.Repeats;
            execution.BreakIntervalInSecond = viewModel.BreakInterval;

            TrainingItem item = new TrainingItem
            {
                TrainingID = 1
            };
            execution.TrainingItem.Add(item);

            models.SubmitChanges();

            HttpContext.SetCacheValue("TrainingExecution", execution.ExecutionID);

            return View("EditTrainingItem", item);
        }

        private TrainingExecution prepareTrainingExecution(bool createNew = true)
        {
            TrainingExecution execution = models.GetTable<TrainingExecution>()
                .Where(t => t.ExecutionID == (int?)HttpContext.GetCacheValue("TrainingExecution")).FirstOrDefault();

            if (execution == null || createNew)
            {
                LessonTimeExpansion item = (LessonTimeExpansion)HttpContext.GetCacheValue("Training");
                var lesson = models.GetTable<LessonTime>().Where(l => l.LessonID == item.LessonID).FirstOrDefault();

                TrainingPlan plan = lesson.AssertTrainingPlan(models, Naming.DocumentLevelDefinition.暫存);
                execution = plan.TrainingExecution;
            }

            return execution;
        }

        public ActionResult DeleteTrainingItem(int itemID,int executionID)
        {

            var item = models.DeleteAny<TrainingItem>(i => i.ItemID == itemID && i.ExecutionID == executionID);
            if (item == null)
            {
                return Json(new { result = false, message = "課程項目不存在!!" });
            }

            return Json(new { result = true });
        }

        public ActionResult ValidateToCommitTraining(TrainingExecutionViewModel viewModel)
        {

            if (!ModelState.IsValid)
            {
                return Json(new { result = false, message = ModelState.ErrorMessage() });
            }
            return Json(new { result = true });
        }

        public ActionResult TrainingExecutionItem()
        {
            TrainingExecution execution = prepareTrainingExecution();
            models.SubmitChanges();

            HttpContext.SetCacheValue("TrainingExecution", execution.ExecutionID);
            return View(execution);
        }

        public ActionResult CommitTraining(TrainingExecutionViewModel viewModel)
        {
            TrainingExecution execution = models.GetTable<TrainingExecution>().Where(x=>x.ExecutionID==viewModel.ExecutionID).FirstOrDefault();

            if (execution == null)
            {
                return Json(new { result = false, message = "預編課程項目不存在!!" });
            }

            if (execution.TrainingItem.Count == 0)
            {
                return Json(new { result = false, message = "尚未設定上課項目!!" });
            }

            if(!ModelState.IsValid)
            {
                return Json(new { result = false, message = ModelState.ErrorMessage() });
            }

            execution.Repeats = viewModel.Repeats;
            execution.BreakIntervalInSecond = viewModel.BreakInterval;
            execution.Conclusion = viewModel.Conclusion;

            for (int i = 0; i < execution.TrainingItem.Count && i < viewModel.TrainingID.Length; i++)
            {
                var item = execution.TrainingItem[i];
                item.TrainingID = (viewModel.TrainingID[i]).Value;
                item.GoalStrength = viewModel.GoalStrength[i];
                item.GoalTurns = viewModel.GoalTurns[i];
                item.ActualStrength = viewModel.ActualStrength[i];
                item.ActualTurns = viewModel.ActualTurns[i];
                item.Description = viewModel.Description[i];
                item.Remark = viewModel.Remark[i];
            }

            execution.TrainingPlan.PlanStatus = (int)Naming.DocumentLevelDefinition.正常;
            models.SubmitChanges();

            return Json(new { result = true });

        }

        public virtual ActionResult CompleteTraining()
        {
            LessonTimeExpansion cacheItem = (LessonTimeExpansion)HttpContext.GetCacheValue("Training");
            var timeItem = models.GetTable<LessonTimeExpansion>()
                .Where(l => l.ExpansionID == cacheItem.ExpansionID).First();

            ViewBag.DataItem = timeItem.LessonTime;
            return View("TrainingPlan", timeItem);

        }

        public virtual ActionResult TrainingExecutionPlan()
        {
            LessonTimeExpansion cacheItem = (LessonTimeExpansion)HttpContext.GetCacheValue("Training");
            if (cacheItem == null)
                return Content("資料錯誤!!");
            var timeItem = models.GetTable<LessonTimeExpansion>()
                .Where(l => l.ExpansionID == cacheItem.ExpansionID).First();

            return View(timeItem);

        }

        public ActionResult QueryModal()
        {
            return View();
        }

        public ActionResult LessonRemark(int lessonID,int registerID)
        {
            var model = models.GetTable<LessonFeedBack>().Where(l => l.LessonID == lessonID && l.RegisterID == registerID).FirstOrDefault();

            if (model == null)
            {
                ViewBag.Message = "課程資料不存在!!";
                return View("~/Views/Shared/ShowMessage.ascx");
            }

            return View("~/Views/Lessons/Feedback/LessonRemark.ascx", model);
            

            //ActionResult result;
            //LessonTimeExpansion model;
            //LessonPlan plan = prepareLessonPlan(out result, out model);

            //if (result != null)
            //    return result;

            //plan.Warming = viewModel.Warming;
            ////plan.RecentStatus = viewModel.RecentStatus;
            ////model.RegisterLesson.UserProfile.RecentStatus = viewModel.RecentStatus;
            //plan.EndingOperation = viewModel.EndingOperation;
            //plan.Remark = viewModel.Remark;


            ////execution.Repeats = viewModel.Repeats;
            ////execution.BreakIntervalInSecond = viewModel.BreakInterval;

            ////for (int i = 0; i < execution.TrainingItem.Count && i < viewModel.TrainingID.Length; i++)
            ////{
            ////    var item = execution.TrainingItem[i];
            ////    item.TrainingID = (viewModel.TrainingID[i]).Value;
            ////    item.GoalStrength = viewModel.GoalStrength[i];
            ////    item.GoalTurns = viewModel.GoalTurns[i];
            ////    item.Description = viewModel.Description[i];
            ////}

            ////execution.TrainingPlan.PlanStatus = (int)Naming.DocumentLevelDefinition.正常;

            //models.SubmitChanges();
            ////HttpContext.RemoveCache("Training");

            ////return RedirectToAction("Coach", "Account", new { lessonDate = model.ClassDate, hour = model.Hour, registerID = model.RegisterID, lessonID = model.LessonID });
            //return Json(new { result = true, message = "資料更新完成!!" });

        }

        public ActionResult CommitLessonRemark(int id, String remark)
        {
            var model = models.GetTable<LessonTime>().Where(l => l.LessonID == id).FirstOrDefault();

            if (model == null)
            {
                return Json(new { result = false, message = "課程資料不存在!!" });
            }

            model.LessonPlan.Remark = remark;
            models.SubmitChanges();

            return Json(new { result = true, message = "資料更新完成!!" });

        }

        public async Task<ActionResult> CreateLessonsQueryXlsxAsync(DailyBookingQueryViewModel viewModel)
        {
            var profile = await HttpContext.GetUserAsync();

            IQueryable<LessonTime> items = queryBookingLessons(profile, viewModel)
                .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI);

            DataTable table = new DataTable();

            table.Columns.Add(new DataColumn("上課日期", typeof(String)));
            table.Columns.Add(new DataColumn("上課時間", typeof(String)));
            table.Columns.Add(new DataColumn("上課地點", typeof(String)));
            table.Columns.Add(new DataColumn("上課時間長度", typeof(int)));
            table.Columns.Add(new DataColumn("課程類別", typeof(String)));
            table.Columns.Add(new DataColumn("體能顧問姓名", typeof(String)));
            table.Columns.Add(new DataColumn("學員姓名", typeof(String)));

            foreach (var item in items)
            {
                var row = table.NewRow();
                table.Rows.Add(row);

                row["上課日期"] = String.Format("{0:yyyy/MM/dd}",item.ClassTime);
                row["上課時間"] = String.Format("{0:HH:mm}", item.ClassTime) + "~" + String.Format("{0:HH:mm}", item.ClassTime.Value.AddMinutes(item.DurationInMinutes.Value));
                if (item.BranchID.HasValue)
                    row["上課地點"] = item.BranchStore.BranchName;
                row["上課時間長度"] = item.DurationInMinutes;
                row["課程類別"] = item.RegisterLesson.RegisterLessonEnterprise==null 
                    ? item.RegisterLesson.LessonPriceType.Status.LessonTypeStatus()
                    : item.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status.LessonTypeStatus()+"(企)";
                row["體能顧問姓名"] = item.AsAttendingCoach.UserProfile.FullName();
                row["學員姓名"] = String.Join("/", item.GroupingLesson.RegisterLesson.Select(r => r.UserProfile).ToArray().Select(r => r.RealName.MaskedName()));
            }

            using (DataSet ds = new DataSet())
            {
                table.TableName = "上課統計";
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("上課統計"), DateTime.Now), viewModel.FileDownloadToken);
            }

            return new EmptyResult();
        }
    }
}