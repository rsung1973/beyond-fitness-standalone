using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.EntityFrameworkCore;

using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

using WebHome.Models.DataEntity;
using WebHome.Controllers.Filters;
using Microsoft.Extensions.Logging;
using WebHome.Helper;
using CommonLib.Core.Utility;
using System.IO;
using Microsoft.AspNetCore.Mvc.Infrastructure;
//using WebHome.Helper.Jobs;

namespace WebHome
{
    public class WebApp
    {
        public static IConfigurationSection Properties { get; protected set; }
        public static IWebHostEnvironment Environment { get; protected set; }
        public static String ApplicationPath { get; protected set; } = "";
        public static  IConfiguration GlobalConfiguration { get; protected set; }

        public static String MapPath(String path, bool isStatic = true)
        {
            return isStatic
                ? Path.Combine(Environment.WebRootPath, path.Replace("~/", "")
                    .TrimStart('/').Replace('/', Path.DirectorySeparatorChar))
                : Path.Combine(Environment.ContentRootPath, path.Replace("~/", "")
                    .TrimStart('/').Replace('/', Path.DirectorySeparatorChar));
        }

    }
}
