using System;
using System.Collections.Generic;
using System.Data;

using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

using CommonLib.DataAccess;

using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Helper.BusinessOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc.Filters;
using WebHome.Properties;
using System.Net.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.AspNetCore.Http;
using CommonLib.Core.Utility;
using Microsoft.AspNetCore.Mvc.ViewEngines;

namespace WebHome.Controllers
{
    public class LearnerActivityController : ActivityBaseController
    {
        public LearnerActivityController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }

    }
}