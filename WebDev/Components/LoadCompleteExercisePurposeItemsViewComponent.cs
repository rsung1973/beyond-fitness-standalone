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

namespace WebHome.Components
{
    public class LoadCompleteExercisePurposeItemsViewComponent : ViewComponent
    {

        protected ModelSource<UserProfile> models;
        protected ModelStateDictionary _modelState;

        public LoadCompleteExercisePurposeItemsViewComponent()
        {

        }

        public IViewComponentResult Invoke(ExercisePurposeViewModel viewModel)
        {
            models = (ModelSource<UserProfile>)HttpContext.Items["Models"];
            _modelState = ViewContext.ModelState;

            return LoadCompleteExercisePurposeItems(viewModel);
        }

        public IViewComponentResult LoadCompleteExercisePurposeItems(ExercisePurposeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var items = models.GetTable<PersonalExercisePurposeItem>()
                .Where(p => p.UID == viewModel.UID)
                .Where(p => p.CompleteDate.HasValue)
                .OrderByDescending(p => p.CompleteDate);

            return View("~/Views/LearnerProfile/Module/TrainingMilestoneItems.cshtml", items);
        }
    }
}
