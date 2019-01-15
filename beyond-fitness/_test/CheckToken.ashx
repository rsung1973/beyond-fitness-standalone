<%@ WebHandler Language="C#" Class="WebHome._test.CheckToken" %>
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;

namespace WebHome._test
{
    /// <summary>
    /// Summary description for CheckToken
    /// </summary>
    public class CheckToken : IHttpHandler, IRequiresSessionState
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            var Request = context.Request;
            var Response = context.Response;
            var Session = context.Session;
            if (Request["token"] != null)
            {
                if (Session[Request["token"]] == null)
                {
                    Session[Request["token"]] = DateTime.Now;
                    Response.Write("Has page...");
                }
                else
                {
                    DateTime ticket = (DateTime)Session[Request["token"]];
                    if ((DateTime.Now - ticket).TotalSeconds < 10)
                    {
                        Response.Write("No page...");
                    }
                    else
                    {
                        Session[Request["token"]] = null;
                        Response.Write("Has page...");
                    }
                }
            }
            else
            {
                Response.Write("No page...");
            }
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
