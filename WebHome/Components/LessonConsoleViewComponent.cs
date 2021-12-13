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
    public class LessonConsoleViewComponent : ViewComponent
    {
        protected ModelSource<UserProfile> models;
        protected ModelStateDictionary _modelState;

        public LessonConsoleViewComponent()
        {

        }

        public virtual IViewComponentResult Invoke(LessonTimeBookingViewModel viewModel)
        {
            models = (ModelSource<UserProfile>)HttpContext.Items["Models"];
            _modelState = ViewContext.ModelState;

            return View();
        }

        public IViewComponentResult LessonContentDetails(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            LessonTime item = models.GetTable<LessonTime>()
                    .Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();

            if (item == null)
            {
                return Content("課程資料錯誤!!");
            }

            return View("~/Views/LessonConsole/Module/LessonContentDetails.cshtml", item);

        }

    }
}
