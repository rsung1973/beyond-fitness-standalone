using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace CommonLib.MvcExtension
{
    public static class ExtensionMethods
    {
        public static string RenderViewToString(this Controller controller,
                                                    string viewName, ViewDataDictionary viewData = null, TempDataDictionary tempData = null)
        {

            var view = ViewEngines.Engines.FindPartialView(controller.ControllerContext, viewName).View;

            StringBuilder sb = new StringBuilder();
            using (StringWriter writer = new StringWriter(sb))
            {
                var viewContext = new ViewContext(controller.ControllerContext, view,
                                                  viewData ?? controller.ViewData, tempData ?? controller.TempData, writer);
                viewContext.View.Render(viewContext, writer);
                writer.Flush();
            }
            return sb.ToString();
        }

        public static string RenderViewToString<T>(this Controller controller, string viewPath, T model)
        {
            controller.ViewData.Model = model;
            using (var writer = new StringWriter())
            {
                IView view;
                if (viewPath.EndsWith("html", StringComparison.OrdinalIgnoreCase))
                {
                    view = new RazorView(controller.ControllerContext, viewPath, null, false, null);
                }
                else
                {
                    view = new WebFormView(controller.ControllerContext, viewPath);
                }
                var dataDict = new ViewDataDictionary<T>(model);
                var tempDict = new TempDataDictionary();
                var viewContext = new ViewContext(controller.ControllerContext, view, dataDict,
                                            controller.TempData /*new TempDataDictionary()*/, writer);
                viewContext.View.Render(viewContext, writer);
                return writer.ToString();
            }
        }

    }
}
