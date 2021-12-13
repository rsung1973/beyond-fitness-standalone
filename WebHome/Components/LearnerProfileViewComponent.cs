using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CommonLib.DataAccess;
using CommonLib.Core.Utility;
using CommonLib.Utility;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.DependencyInjection;
using System.Globalization;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web;
using WebHome.Models.DataEntity;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using WebHome.Models.ViewModel;
using WebHome.Models.Locale;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using WebHome.Helper;

namespace WebHome.Components
{
    public class LearnerProfileViewComponent : ViewComponent
    {
        protected ModelSource<UserProfile> models;
        protected ModelStateDictionary _modelState;

        public LearnerProfileViewComponent()
        {

        }

        public virtual IViewComponentResult Invoke(ExercisePurposeViewModel viewModel)
        {
            models = (ModelSource<UserProfile>)HttpContext.Items["Models"];
            _modelState = ViewContext.ModelState;

            return View();
        }

        protected IViewComponentResult PrepareLearner(ExercisePurposeViewModel viewModel, out UserProfile item)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "學員資料錯誤!!");
            }

            return null;
        }

        public IViewComponentResult EditLearnerFeature(ExercisePurposeViewModel viewModel)
        {
            IViewComponentResult result = PrepareLearner(viewModel, out UserProfile item);
            if (result != null)
                return result;

            var purpose = item.PersonalExercisePurpose;
            if (purpose != null)
            {
                viewModel.Purpose = purpose.Purpose.GetEfficientString();
                viewModel.Ability = purpose.PowerAbility;
                viewModel.Cardiopulmonary = purpose.Cardiopulmonary;
                viewModel.Flexibility = purpose.Flexibility;
                viewModel.MuscleStrength = purpose.MuscleStrength;
                viewModel.AbilityStyle = purpose.AbilityStyle;
                viewModel.AbilityLevel = (Naming.PowerAbilityLevel?)purpose.AbilityLevel;
            }

            return View("~/Views/LearnerProfile/Module/EditLearnerFeature.cshtml", item);
        }

        public IViewComponentResult EditExercisePurpose(ExercisePurposeViewModel viewModel)
        {
            ViewViewComponentResult result = (ViewViewComponentResult)EditLearnerFeature(viewModel);
            if (result.ViewData.Model is not UserProfile)
                return result;

            result.ViewName = "~/Views/LearnerProfile/Module/EditExercisePurpose.cshtml";
            return result;
        }

    }
}
