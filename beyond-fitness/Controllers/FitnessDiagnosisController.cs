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

using CommonLib.MvcExtension;
using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    //[CoachOrAssistantAuthorize]
    public class FitnessDiagnosisController : SampleController<UserProfile>
    {
        // GET: FitnessDiagnosis
        public ActionResult Diagnose(FitnessDiagnosisViewModel viewModel)
        {
            var model = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if(model==null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "學員資料錯誤!!");
            }

            BodyDiagnosis item;
            BodyDiagnosis first = model.BodyDiagnosis.OrderBy(d => d.DiagnosisID).FirstOrDefault();
            if (viewModel.DiagnosisID.HasValue)
            {
                item = model.BodyDiagnosis.Where(d => d.DiagnosisID == viewModel.DiagnosisID).FirstOrDefault();
            }
            else
            {
                item = model.BodyDiagnosis.OrderBy(d => d.DiagnosisID).FirstOrDefault();
            }
            ViewBag.DataItem = item;
            ViewBag.IsFirst = first != null && first == item;

            if (item != null)
                viewModel.DiagnosisID = item.DiagnosisID;

            ViewBag.ViewModel = viewModel;
            return View("~/Views/FitnessDiagnosis/Module/Diagnose.ascx", model);
        }

        public ActionResult DiagnoseByLearner(FitnessDiagnosisViewModel viewModel)
        {

            BodyDiagnosis item;
            BodyDiagnosis first = models.GetTable<BodyDiagnosis>()
                .Where(d => d.LearnerID == viewModel.UID)
                .OrderBy(d => d.DiagnosisID).First();
            if (viewModel.DiagnosisID.HasValue)
            {
                item = models.GetTable<BodyDiagnosis>()
                    .Where(d => d.LearnerID == viewModel.UID)
                    .Where(d => d.DiagnosisID == viewModel.DiagnosisID).First();
            }
            else
            {
                item = models.GetTable<BodyDiagnosis>()
                    .Where(d => d.LearnerID == viewModel.UID)
                    .OrderBy(d => d.DiagnosisID).First();
            }

            ViewBag.DataItem = item;
            ViewBag.IsFirst = first == item;


            ViewBag.ViewModel = viewModel;
            return View("~/Views/FitnessDiagnosis/Module/DiagnoseByLearner.ascx", item.UserProfile);
        }

        public ActionResult CreateDiagnosis(FitnessDiagnosisViewModel viewModel)
        {
            var model = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (model == null)
            {
                return Json(new { result = false, message = "學員資料錯誤!!" });
            }

            var item = model.BodyDiagnosis.OrderByDescending(d => d.DiagnosisID).FirstOrDefault();
            if (item != null)
            {
                if (item.LevelID == (int)Naming.DocumentLevelDefinition.暫存)
                {
                    return Json(new { result = false, message = "診斷未完成之前不可以新增!!" });
                }
            }

            var profile = HttpContext.GetUser();
            item = new BodyDiagnosis
            {
                CoachID = profile.UID,
                DiagnosisDate = DateTime.Now,
                LearnerID = model.UID,
                LevelID = (int)Naming.DocumentLevelDefinition.暫存
            };
            model.BodyDiagnosis.Add(item);
            models.SubmitChanges();

            ViewBag.DataItem = item;
            ViewBag.ViewModel = viewModel;
            return Json(new { result = true,message = item.DiagnosisID });
        }

        public ActionResult DiagnosisContent(FitnessDiagnosisViewModel viewModel)
        {
            var item = models.GetTable<BodyDiagnosis>().Where(u => u.LearnerID == viewModel.UID 
                && u.DiagnosisID==viewModel.DiagnosisID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "診斷資料錯誤!!");
            }

            BodyDiagnosis first = models.GetTable<BodyDiagnosis>().Where(u => u.LearnerID == viewModel.UID)
                .OrderBy(d => d.DiagnosisID).FirstOrDefault();
            ViewBag.IsFirst = first == item;


            ViewBag.ViewModel = viewModel;
            return View("~/Views/FitnessDiagnosis/Module/DiagnosisContent.ascx", item);
        }

        public ActionResult EditDiagnosisGoal(FitnessDiagnosisViewModel viewModel)
        {
            var item = models.GetTable<BodyDiagnosis>().Where(u => u.LearnerID == viewModel.UID
                && u.DiagnosisID == viewModel.DiagnosisID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "診斷資料錯誤!!");
            }

            ViewBag.ViewModel = viewModel;
            return View("~/Views/FitnessDiagnosis/Module/EditDiagnosisGoal.ascx", item);
        }

        public ActionResult CommitDiagnosisGoal(FitnessDiagnosisViewModel viewModel)
        {
            var item = models.GetTable<BodyDiagnosis>().Where(u => u.DiagnosisID == viewModel.DiagnosisID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "診斷資料錯誤!!" });
            }

            item.Goal = viewModel.Goal;
            item.Description = viewModel.Description;

            models.SubmitChanges();

            return View("~/Views/FitnessDiagnosis/Module/DiagnosisGoal.ascx", item);
        }

        public ActionResult EditDiagnosisAssessment(FitnessDiagnosisViewModel viewModel)
        {
            var item = models.GetTable<BodyDiagnosis>().Where(u => u.DiagnosisID == viewModel.DiagnosisID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "診斷資料錯誤!!");
            }

            var assessment = item.DiagnosisAssessment.Where(d => d.ItemID == viewModel.ItemID).FirstOrDefault();
            if (assessment != null)
            {
                viewModel.Assessment = assessment.Assessment;
                viewModel.AdditionalAssessment = assessment.AdditionalAssessment;
                viewModel.Description = assessment.Description;
                viewModel.Judgement = assessment.Judgement;
                viewModel.DiagnosisAction = assessment.DiagnosisAction;
            }

            ViewBag.ViewModel = viewModel;
            return View("~/Views/FitnessDiagnosis/Module/EditDiagnosisAssessment.ascx", item);
        }

        public ActionResult MakeJudgement(FitnessDiagnosisViewModel viewModel)
        {
            var item = models.GetTable<BodyDiagnosis>().Where(u => u.DiagnosisID == viewModel.DiagnosisID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "診斷資料錯誤!!" });
            }

            if(!viewModel.Assessment.HasValue)
            {
                return Json(new { result = false, message = "輸入資料錯誤!!" });
            }

            var assessmentItem = models.GetTable<FitnessAssessmentItem>().Where(i => i.ItemID == viewModel.ItemID && i.GroupID == 8).FirstOrDefault();
            if(assessmentItem==null)
            {
                return Json(new { result = false, message = "診斷項目錯誤!!" });
            }



            if(!item.UserProfile.Birthday.HasValue || String.IsNullOrEmpty(item.UserProfile.UserProfileExtension.Gender))
            {
                return Json(new { result = false, message = "因個人資訊不足系統當下無法判斷!!" });
            }
            var yearsOld = DateTime.Today.Year - item.UserProfile.Birthday.Value.Year;

            if (assessmentItem.ItemID == 57)
            {
                if (!viewModel.AdditionalAssessment.HasValue)
                {
                    return Json(new { result = false, message = "輸入資料錯誤!!" });
                }

                var effectiveRate = (220 - yearsOld - (int)viewModel.Assessment) * 70 / 100 + (int)viewModel.Assessment;
                if (viewModel.AdditionalAssessment < (effectiveRate - 10))
                {
                    return Json(new { result = true, message = "良好", effectiveRate });
                }
                else if (viewModel.AdditionalAssessment > (effectiveRate + 10))
                {
                    return Json(new { result = true, message = "稍差", effectiveRate });
                }
                else
                {
                    return Json(new { result = true, message = "一般", effectiveRate });
                }
            }

            var judgement = models.GetTable<FitnessDiagnosis>()
                .Where(f => f.ItemID == assessmentItem.ItemID)
                .Where(f => f.Gender == item.UserProfile.UserProfileExtension.Gender)
                .Where(f => yearsOld >= f.YearsOldStart && (!f.YearsOldEnd.HasValue || yearsOld <= f.YearsOldEnd))
                .Join(models.GetTable<DiagnosisJudgement>()
                        .Where(d => !d.RangeStart.HasValue || viewModel.Assessment >= d.RangeStart)
                        .Where(d => !d.RangeEnd.HasValue || viewModel.Assessment < d.RangeEnd),
                    f => f.FitnessID, d => d.FitnessID, (f, d) => d).FirstOrDefault();


            if (judgement == null)
            {
                return Json(new { result = false, message = "因個人資訊不足系統當下無法判斷!!" });
            }

            return Json(new { result = true, message = judgement.Judgement });

        }

        public ActionResult CommitDiagnosisAssessment(FitnessDiagnosisViewModel viewModel)
        {
            var item = models.GetTable<BodyDiagnosis>().Where(u => u.DiagnosisID == viewModel.DiagnosisID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "診斷資料錯誤!!" });
            }


            var assessmentItem = models.GetTable<FitnessAssessmentItem>().Where(i => i.ItemID == viewModel.ItemID && i.GroupID == 8).FirstOrDefault();
            if (assessmentItem == null)
            {
                return Json(new { result = false, message = "診斷項目錯誤!!" });
            }

            switch(assessmentItem.ItemID)
            {
                case 53:
                case 54:
                case 55:
                    if (!viewModel.Assessment.HasValue)
                    {
                        return Json(new { result = false, message = "輸入資料錯誤!!" });
                    }
                    break;
                case 57:
                    if (!viewModel.Assessment.HasValue || !viewModel.AdditionalAssessment.HasValue)
                    {
                        return Json(new { result = false, message = "輸入資料錯誤!!" });
                    }
                    break;
            }

            var diagAssessment = item.DiagnosisAssessment.Where(d => d.ItemID == assessmentItem.ItemID).FirstOrDefault();
            if(diagAssessment==null)
            {
                diagAssessment = new DiagnosisAssessment
                {
                    DiagnosisID = item.DiagnosisID,
                    ItemID = assessmentItem.ItemID
                };
                item.DiagnosisAssessment.Add(diagAssessment);
            }

            diagAssessment.DiagnosisAction = viewModel.DiagnosisAction;
            diagAssessment.AdditionalAssessment = viewModel.AdditionalAssessment;
            diagAssessment.Assessment = viewModel.Assessment;
            diagAssessment.Description = viewModel.Description;
            diagAssessment.Judgement = viewModel.Judgement;

            models.SubmitChanges();

            return View("~/Views/FitnessDiagnosis/Module/DiagnosisAssessment.ascx", item);

        }

        public ActionResult DeleteDiagnosisAssessment(FitnessDiagnosisViewModel viewModel)
        {
            var item = models.DeleteAny<DiagnosisAssessment>(d => d.DiagnosisID == viewModel.DiagnosisID
                && d.ItemID == viewModel.ItemID);

            if (item == null)
            {
                return Json(new { result = false, message = "診斷資料錯誤!!" });
            }

            return Json(new { result = true });

        }

        public ActionResult EnableBodySuffering(FitnessDiagnosisViewModel viewModel,String part)
        {
            var item = models.GetTable<BodyParts>().Where(p => p.Part == part).FirstOrDefault();

            if (item == null)
            {
                return Json(new { result = false, message = "診斷資料錯誤!!" });
            }

            var diagnosis = models.GetTable<BodyDiagnosis>().Where(d => d.DiagnosisID == viewModel.DiagnosisID).FirstOrDefault();
            if(diagnosis==null)
            {
                return Json(new { result = false, message = "診斷資料錯誤!!" });
            }

            if(!diagnosis.BodySuffering.Any(s=>s.PartID==item.PartID))
            {
                diagnosis.BodySuffering.Add(new BodySuffering
                {
                    PartID = item.PartID
                });
                models.SubmitChanges();
            }
                        
            return Json(new { result = true });

        }

        public ActionResult DisableBodySuffering(FitnessDiagnosisViewModel viewModel, String part)
        {
            var item = models.GetTable<BodyParts>().Where(p => p.Part == part).FirstOrDefault();

            if (item == null)
            {
                return Json(new { result = false, message = "診斷資料錯誤!!" });
            }

            var suffering = models.DeleteAny<BodySuffering>(d => d.DiagnosisID == viewModel.DiagnosisID
                && d.PartID == item.PartID);

            if (suffering == null)
            {
                return Json(new { result = false, message = "診斷資料錯誤!!" });
            }

            return Json(new { result = true });

        }

        public ActionResult DeleteDiagnosis(FitnessDiagnosisViewModel viewModel, String part)
        {
            var item = models.DeleteAny<BodyDiagnosis>(d => d.DiagnosisID == viewModel.DiagnosisID);

            if (item == null)
            {
                return Json(new { result = false, message = "診斷資料錯誤!!" });
            }

            return Json(new { result = true });

        }

        public ActionResult ConfirmDiagnosis(FitnessDiagnosisViewModel viewModel)
        {
            var item = models.GetTable<BodyDiagnosis>().Where(d => d.DiagnosisID == viewModel.DiagnosisID).FirstOrDefault();

            if (item == null)
            {
                return Json(new { result = false, message = "診斷資料錯誤!!" });
            }

            item.LevelID = (int)Naming.DocumentLevelDefinition.正常;
            models.SubmitChanges();

            return Json(new { result = true });

        }

        public ActionResult DiagnosisRule(FitnessDiagnosisViewModel viewModel)
        {
            switch(viewModel.ItemID)
            {
                case 53:
                    return View("~/Views/FitnessDiagnosis/Module/PushupStandardDialog.ascx");
                case 54:
                case 55:
                    return View("~/Views/FitnessDiagnosis/Module/SquatStandard.ascx");
                case 57:
                    return View("~/Views/FitnessDiagnosis/Module/CardioStandard.ascx");
            }
            return new EmptyResult();
        }



    }
}