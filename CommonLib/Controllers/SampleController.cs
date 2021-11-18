using System;
using System.Collections.Generic;
using System.Data.Linq;
using System.IO;
using System.Linq;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using CommonLib.DataAccessLayer.Models;
using Utility;

namespace CommonLib.Controllers
{
    public class SampleController<T,TEntity> : Controller
        where T : DataContext, new()
        where TEntity : class, new()
    {
        protected ModelSource<T, TEntity> models;

        protected SampleController() :base()
        {
            models = new ModelSource<T, TEntity>();
            
        }

        public ModelSource<T,TEntity> DataSource
        {
            get
            {
                return models;
            }
        }

        protected override void OnResultExecuted(ResultExecutedContext filterContext)
        {
            base.OnResultExecuted(filterContext);
            models.Dispose();
        }
    }
}