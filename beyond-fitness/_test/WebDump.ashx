<%@ WebHandler Language="C#" Class="WebHome._test.WebDump" %>
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Utility;
    using System.IO;

namespace WebHome._test
{
    /// <summary>
    /// Summary description for CheckToken
    /// </summary>
    public class WebDump : IHttpHandler, IRequiresSessionState
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            var Request = context.Request;
            var Response = context.Response;
            var Session = context.Session;

            Response.ContentType = "text/xml";
            Request.SaveAs(Path.Combine(Logger.LogDailyPath, String.Format("{0:yyyyMMdd-HHmmssfff}.txt", DateTime.Now)), true);

            Response.Write("<root>OK!</root>");

        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}
