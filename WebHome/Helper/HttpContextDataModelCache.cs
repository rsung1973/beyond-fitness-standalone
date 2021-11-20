using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;

namespace WebHome.Helper
{
    public partial class HttpContextDataModelCache
    {
        protected IMemoryCache _cache;
        protected ISession _session;
        protected ILogger _logger;

        public HttpContextDataModelCache(HttpContext context)
        {
            _cache = context.RequestServices.GetService(typeof(IMemoryCache)) as IMemoryCache;
            _session = context.Session;
            _logger = ApplicationLogging.CreateLogger<HttpContextDataModelCache>();

            _logger.LogTrace("Session Id:{0}", _session.Id);
        }

        public Object DataItem
        {
            get
            {
                if (_cache.TryGetValue(dataID, out object item))
                {
                    return item;
                }
                return null;
            }
            set
            {
                if (value != null)
                {
                    String key = dataID;
                    double timeout = Startup.Properties.GetValue<double>("SessionTimeoutInMinutes");
                    List<String> items = _cache.Get<List<String>>(_session.Id);

                    if (items == null)
                    {
                        items = new List<string>();
                        _cache.Set<List<String>>(_session.Id, items, TimeSpan.FromMinutes(timeout));
                    }

                    if (!items.Contains(key))
                    {
                        items.Add(key);
                    }
                    _cache.Set(key, value, TimeSpan.FromMinutes(timeout));
                }
                else
                {
                    _cache.Remove(dataID);
                }
            }
        }

        private String dataID
        {
            get
            {
                return String.Format("{0}{1}", _session.Id, KeyName);
            }
        }

        public String KeyName
        {
            get;
            set;
        }

        public void Clear()
        {
            List<String> items = _cache.Get<List<String>>(_session.Id);
            if (items != null && items.Count > 0)
            {
                foreach (var key in items)
                {
                    _cache.Remove(key);
                }
                items.Clear();
                _cache.Remove(_session.Id);
            }
        }

        public Object this[String index]
        {
            get
            {
                KeyName = index;
                return this.DataItem;
            }
            set
            {
                KeyName = index;
                this.DataItem = value;
            }
        }

    }
}