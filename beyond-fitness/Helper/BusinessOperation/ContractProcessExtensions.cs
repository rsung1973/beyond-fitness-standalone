using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Web;
using System.Web.Mvc;

using CommonLib.DataAccess;
using MessagingToolkit.QRCode.Codec;
using Utility;
using WebHome.Controllers;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;

namespace WebHome.Helper.BusinessOperation
{
    public static class ContractProcessExtensions
    {
        public static CourseContract InitiateCourseContract<TEntity>(this ModelSource<TEntity> models, CourseContractViewModel viewModel, UserProfile profile, LessonPriceType lessonPrice, int? installmentID = null)
            where TEntity : class, new()
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
                    CourseContractExtension = new Models.DataEntity.CourseContractExtension
                    {
                        BranchID = lessonPrice.BranchID.Value
                    }
                };
                models.GetTable<CourseContract>().InsertOnSubmit(item);
            }

            item.AgentID = profile.UID;
            item.Status = (int)Naming.CourseContractStatus.待簽名;  //  (int)checkInitialStatus(viewModel, profile);
            item.CourseContractLevel.Add(new CourseContractLevel
            {
                LevelDate = DateTime.Now,
                ExecutorID = profile.UID,
                LevelID = item.Status
            });

            item.ContractType = viewModel.ContractType.Value;
            item.ContractDate = DateTime.Now;
            item.Subject = viewModel.Subject;
            item.ValidFrom = DateTime.Today;
            item.Expiration = DateTime.Today.AddMonths(18);
            item.OwnerID = viewModel.OwnerID.Value;
            item.SequenceNo = 0;// viewModel.SequenceNo;
            item.Lessons = viewModel.Lessons;
            item.PriceID = viewModel.PriceID.Value;
            item.Remark = viewModel.Remark;
            item.FitnessConsultant = viewModel.FitnessConsultant.Value;
            item.Renewal = viewModel.Renewal;

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

            item.TotalCost = item.Lessons * item.LessonPriceType.ListPrice;
            if (item.CourseContractType.GroupingLessonDiscount != null)
            {
                item.TotalCost = item.TotalCost * item.CourseContractType.GroupingLessonDiscount.GroupingMemberCount * item.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount / 100;
            }
            models.SubmitChanges();

            foreach (var uid in viewModel.UID)
            {
                models.ExecuteCommand("update UserProfileExtension set CurrentTrial = null where UID = {0}", uid);
            }

            return item;
        }

        public static void ValidateContractApplication<TEntity>(this CourseContractViewModel viewModel, SampleController<TEntity> controller, out LessonPriceType lessonPrice)
                where TEntity : class, new()
        {
            var ModelState = controller.ModelState;
            var models = controller.DataSource;

            lessonPrice = null;
            if (!viewModel.ContractType.HasValue)
            {
                ModelState.AddModelError("ContractType", "請選擇合約類型");
            }
            if (!viewModel.BranchID.HasValue)
            {
                ModelState.AddModelError("BranchID", "請選擇上課場所");
            }

            //請選擇上課時間長度
            if (!viewModel.Renewal.HasValue)
            {
                ModelState.AddModelError("Renewal", "請選擇是否為舊學員續約");
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

        public static CourseContract SaveCourseContract<TEntity>(this CourseContractViewModel viewModel, SampleController<TEntity> controller, out String alertMessage)
                where TEntity : class, new()
        {
            alertMessage = null;
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            viewModel.ValidateContractApplication(controller, out LessonPriceType lessonPrice);

            if (lessonPrice != null && !lessonPrice.BranchStore.ManagerID.HasValue)
            {
                ModelState.AddModelError("BranchID", "該分店未指定店長!!");
            }

            if (viewModel.InstallmentPlan == true)
            {
                if (!viewModel.Installments.HasValue)
                {
                    ModelState.AddModelError("Installments", "請選擇分期!!");
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

                item.ExecuteContractStatus(profile, Naming.CourseContractStatus.草稿, null);
                models.GetTable<CourseContract>().InsertOnSubmit(item);
            }
            else
            {
                if (item.Status != (int)Naming.CourseContractStatus.草稿)
                {
                    alertMessage = "合約狀態錯誤，請重新檢查!!";
                    return null;
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

            item.TotalCost = item.Lessons * item.LessonPriceType.ListPrice;
            if (item.CourseContractType.GroupingLessonDiscount != null)
            {
                item.TotalCost = item.TotalCost * item.CourseContractType.GroupingLessonDiscount.GroupingMemberCount * item.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount / 100;
            }
            models.SubmitChanges();

            return item;
        }

        public static CourseContract CommitCourseContract<TEntity>(this CourseContractViewModel viewModel, SampleController<TEntity> controller, out String alertMessage)
                where TEntity : class, new()
        {
            alertMessage = null;
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            viewModel.ValidateContractApplication(controller, out LessonPriceType lessonPrice);
            if (!viewModel.Lessons.HasValue || viewModel.Lessons < 1)
            {
                ModelState.AddModelError("Lessons", "請輸入購買堂數");
            }

            if (lessonPrice != null && !lessonPrice.BranchStore.ManagerID.HasValue)
            {
                ModelState.AddModelError("BranchID", "該分店未指定店長!!");
            }

            if (viewModel.InstallmentPlan == true)
            {
                if (!viewModel.Installments.HasValue)
                {
                    ModelState.AddModelError("Installments", "請選擇分期!!");
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
                    alertMessage = "合約狀態錯誤，請重新檢查!!";
                    return null;
                }
            }

            item = models.InitiateCourseContract(viewModel, profile, lessonPrice);

            if (item.InstallmentID.HasValue)
            {
                int totalLessons = item.Lessons.Value;
                int installment = totalLessons / item.ContractInstallment.Installments;
                DateTime payoffDue = item.ContractDate.Value.AddMonths(1).FirstDayOfMonth();
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
                item.PayoffDue = payoffDue.AddDays(-1);
                //item.Remark = $"{item.Remark}帳款應付期限{payoffDue:yyyy/MM/dd}。";
                models.SubmitChanges();

                totalLessons -= item.Lessons.Value;
                payoffDue = payoffDue.AddMonths(1);
                viewModel.ContractID = null;
                while (totalLessons > 0)
                {
                    viewModel.Lessons = Math.Min(installment, totalLessons);
                    var c = models.InitiateCourseContract(viewModel, profile, lessonPrice, item.InstallmentID);
                    c.PayoffDue = payoffDue.AddDays(-1);
                    //c.Remark = $"{c.Remark}帳款應付期限{payoffDue:yyyy/MM/dd}。";
                    models.SubmitChanges();

                    payoffDue = payoffDue.AddMonths(1);
                    totalLessons -= installment;
                }
            }

            return item;
        }

        public static bool ExecuteContractStatus(this CourseContract item, UserProfile profile, Naming.CourseContractStatus status, Naming.CourseContractStatus? fromStatus, bool updateAgent = true)
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

        public static UserProfile CommitContractMember<TEntity>(this ContractMemberViewModel viewModel, SampleController<TEntity> controller, out String alertMessage)
            where TEntity : class, new()
        {
            alertMessage = null;
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            ViewBag.ViewModel = viewModel;

            viewModel.IDNo = viewModel.IDNo.GetEfficientString();
            if (viewModel.IDNo == null)
            {
                if (viewModel.CurrentTrial != 1)
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

                if (String.IsNullOrEmpty(viewModel.AdministrativeArea))
                {
                    ModelState.AddModelError("AdministrativeArea", "請選擇縣市");
                }
                if (String.IsNullOrEmpty(viewModel.Address))
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

            viewModel.Phone = viewModel.Phone.GetEfficientString();
            if (String.IsNullOrEmpty(viewModel.Phone))
            {
                ModelState.AddModelError("Phone", "請輸入聯絡電話");
            }

            if (String.IsNullOrEmpty(viewModel.Gender))
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

            return item;
        }

        public static CourseContract ExecuteContractStatus<TEntity>(this CourseContractViewModel viewModel, SampleController<TEntity> controller, out String alertMessage)
            where TEntity : class, new()
        {
            alertMessage = null;
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

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
                                var totalLessons = item.ContractInstallment.CourseContract.Sum(c => c.Lessons);
                                item.TotalCost = item.TotalCost * totalLessons / item.Lessons;
                                item.Lessons = totalLessons;
                                models.DeleteAllOnSubmit<CourseContract>(t => t.ContractID != item.ContractID && t.InstallmentID == item.InstallmentID);

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
                    models.SubmitChanges();

                    return item;
                }
                else
                {
                    alertMessage = "合約狀態錯誤，請重新檢查!!";
                    return null;
                }
            }
            else
            {
                alertMessage = "合約資料錯誤!!";
                return null;
            }
        }

        public static CourseContract EnableContractAmendment<TEntity>(this CourseContractViewModel viewModel, SampleController<TEntity> controller, out String alertMessage, Naming.CourseContractStatus? fromStatus = Naming.CourseContractStatus.待簽名)
            where TEntity : class, new()
        {
            alertMessage = null;
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

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
                alertMessage = "合約資料錯誤!!";
                return null;
            }
        }

        public static void MarkContractNo<TEntity>(this CourseContract item, ModelSource<TEntity> models)
            where TEntity : class, new()
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

        public static String MakeContractEffective<TEntity>(this CourseContract item, ModelSource<TEntity> models, UserProfile profile, Naming.CourseContractStatus fromStatus)
            where TEntity : class, new()
        {
            if (!item.ExecuteContractStatus(profile, Naming.CourseContractStatus.已生效, fromStatus))
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


        public static CourseContract ConfirmContractSignature<TEntity>(this CourseContractViewModel viewModel, SampleController<TEntity> controller, out String alertMessage, out String pdfFile)
            where TEntity : class, new()
        {
            alertMessage = null;
            pdfFile = null;
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                var owner = item.CourseContractMember.Where(m => m.UID == item.OwnerID).First();

                if (item.CourseContractType.ContractCode == "CFA")
                {
                    if (owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 3)
                    {
                        alertMessage = "未完成簽名!!";
                        return null;
                    }
                }
                else
                {

                    if (owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 2)
                    {
                        alertMessage = "未完成簽名!!";
                        return null;
                    }

                    if (item.CourseContractType.IsGroup == true)
                    {
                        if (item.CourseContractMember.Any(m => m.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 2))
                        {
                            alertMessage = "未完成簽名!!";
                            return null;
                        }

                        foreach (var m in item.CourseContractMember)
                        {
                            if (m.UserProfile.CurrentYearsOld() < 18 && owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Guardian") && s.Signature != null) < 2)
                            {
                                alertMessage = "家長/監護人未完成簽名!!";
                                return null;
                            }
                        }
                    }
                }

                if (viewModel.Extension != true || viewModel.Booking != true || viewModel.Cancel != true)
                {
                    alertMessage = "請勾選合約聲明!!";
                    return null;
                }

                if (!item.ExecuteContractStatus(profile, Naming.CourseContractStatus.待審核, Naming.CourseContractStatus.待簽名))
                {
                    alertMessage = "合約狀態錯誤，請重新檢查!!";
                    return null;
                }

                item.EffectiveDate = DateTime.Now;
                //item.ValidFrom = DateTime.Today;
                //item.Expiration = DateTime.Today.AddMonths(18);

                models.SubmitChanges();

                item.MarkContractNo(models);
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

                if (item.ContractAgent.IsManager() /*item.ServingCoach.UserProfile.IsManager()*/)
                {
                    pdfFile = item.MakeContractEffective(models, profile, Naming.CourseContractStatus.待審核);
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

                return item;

            }
            else
            {
                alertMessage = "合約資料錯誤!!";
                return null;
            }
        }

        public static CourseContract ConfirmContractServiceSignature<TEntity>(this CourseContractViewModel viewModel, SampleController<TEntity> controller, out String alertMessage, out String pdfFile)
            where TEntity : class, new()
        {
            alertMessage = null;
            pdfFile = null;
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<CourseContractRevision>().Where(c => c.RevisionID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                CourseContract contract = item.CourseContract;
                var owner = contract.CourseContractMember.Where(m => m.UID == contract.OwnerID).First();

                if (contract.CourseContractType.ContractCode == "CFA")
                {
                    if (owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 1)
                    {
                        alertMessage = "未完成簽名!!";
                        return null;
                    }
                }
                else
                {

                    if (owner.CourseContractSignature.Count(s => s.SignatureName.StartsWith("Signature") && s.Signature != null) < 1)
                    {
                        alertMessage = "未完成簽名!!";
                        return null;
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

                if (viewModel.Extension != true)
                {
                    alertMessage = "請勾選合約聲明!!";
                    return null;
                }

                if (item.Reason == "展延")
                {
                    if (viewModel.Booking != true || viewModel.Cancel!=true)
                    {
                        alertMessage = "請勾選合約聲明!!";
                        return null;
                    }
                }

                if (!item.EnableContractAmendment(models, profile))
                {
                    alertMessage = "服務狀態錯誤，請重新檢查!!";
                    return null;
                }

                pdfFile = item.CreateContractAmendmentPDF(true);
                return contract;
            }
            else
            {
                alertMessage = "合約資料錯誤!!";
                return null;
            }
        }

        public static bool EnableContractAmendment<TEntity>(this CourseContractRevision item,ModelSource<TEntity> models, UserProfile profile,Naming.CourseContractStatus? fromStatus = Naming.CourseContractStatus.待簽名)
            where TEntity : class, new()
        {
            if (!item.CourseContract.ExecuteContractStatus(profile, Naming.CourseContractStatus.已生效, fromStatus, false))
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
                    models.SubmitChanges();
                    break;
                case "轉點":
                    item.ProcessContractMigration();
                    break;
                case "轉讓":
                    item.ProcessContractTransference();
                    break;
                case "終止":
                    item.ProcessContractTermination(profile);
                    break;
                case "轉換體能顧問":
                    item.SourceContract.FitnessConsultant = item.CourseContract.FitnessConsultant;
                    models.SubmitChanges();
                    break;

            }

            return true;

        }


        public static CourseContract CommitContractService<TEntity>(this CourseContractViewModel viewModel, SampleController<TEntity> controller, out String alertMessage)
            where TEntity : class, new()
        {
            alertMessage = null;
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item == null)
            {
                alertMessage = "合約資料錯誤!!";
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
                if (!viewModel.SettlementPrice.HasValue)
                    ModelState.AddModelError("SettlementPrice", "請填入課程單價!!");
                else
                {

                    var refund = item.TotalPaidAmount() - item.AttendedLessonCount()
                            * viewModel.SettlementPrice
                            * item.CourseContractType.GroupingMemberCount
                            * item.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount / 100;
                    if (refund < 0)
                    {
                        ModelState.AddModelError("SettlementPrice", "退款差額不可小於零!!");
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
                ViewBag.ModelState = ModelState;
                return null;
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

            if (viewModel.Reason != "轉換體能顧問")
            {
                newItem.ExecuteContractStatus(profile, Naming.CourseContractStatus.待確認, null);
                if (profile.IsManager())
                {
                    newItem.ExecuteContractStatus(profile, Naming.CourseContractStatus.待簽名, null);
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

                case "轉換體能顧問":

                    newItem.CourseContractMember.AddRange(item.CourseContractMember.Select(u => new CourseContractMember
                    {
                        UID = u.UID
                    }));

                    newItem.FitnessConsultant = viewModel.FitnessConsultant.Value;
                    newItem.CourseContractRevision.CourseContractRevisionItem = new CourseContractRevisionItem
                    {
                        FitnessConsultant = item.FitnessConsultant
                    };

                    if(profile.IsManager())
                    {
                        newItem.CourseContractRevision.EnableContractAmendment(models, profile, null);
                    }
                    else
                    {
                        newItem.ExecuteContractStatus(profile, Naming.CourseContractStatus.待確認, null);
                    }
                    break;
            }

            models.SubmitChanges();
            return newItem;
        }
    }
}