using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebHome.Models.DataEntity;

namespace WebHome.Controllers
{
    public class ErrorController : SampleController<UserProfile>
    {
        // GET: Error
        public ActionResult Http404()
        {
            return View();
        }
        public ActionResult Http500()
        {
            return View();
        }

        public ActionResult InvalidCrypto()
        {
            return View();
        }
    }
}