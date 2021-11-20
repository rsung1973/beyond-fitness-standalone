using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNetCore.Mvc;
using WebHome.Models.DataEntity;
using CommonLib.Utility;

namespace WebHome.Controllers
{
    public class ErrorController : SampleController<UserProfile>
    {
        public ErrorController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
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

        public ActionResult Goback(String message)
        {
            message = message.GetEfficientString();
            if(message==null)
            {
                return Content("<script>window.history.go(-1);</script>");
            }
            else
            {
                return Content($"<script>alert('{HttpUtility.JavaScriptStringEncode(message)}');window.history.go(-1);</script>");
            }
        }

    }
}