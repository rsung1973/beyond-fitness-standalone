using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Caching;
using System.Web.SessionState;

namespace CommonLib.Web
{
    public partial class DataModelCache
    {
        protected Cache _cache;
        protected HttpSessionStateBase _session;
        public const String __CACHE_KEY = "__CACHE_KEY";

        public DataModelCache(HttpContextBase context)
        {
            _cache = context.Cache;
            _session = context.Session;
            if (_session[__CACHE_KEY] == null)
                _session[__CACHE_KEY] = Guid.NewGuid();
        }


        public Object DataItem
        {
            get
            {
                return _cache[dataID];
            }
            set
            {
                if (value != null)
                {
                    String key = dataID;
                    List<String> items = _cache[_session.SessionID] as List<String>;
                    if (items == null)
                    {
                        items = new List<string>();
                        _cache.Insert(_session.SessionID, items, null, Cache.NoAbsoluteExpiration, TimeSpan.FromMinutes(_session.Timeout));
                    }
                    if (!items.Contains(key))
                    {
                        items.Add(key);
                    }
                    _cache.Insert(key, value, null, Cache.NoAbsoluteExpiration, TimeSpan.FromMinutes(_session.Timeout));
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
                return String.Format("{0}{1}", _session.SessionID, KeyName);
            }
        }

        public String KeyName
        {
            get;
            set;
        }

        public void Clear()
        {
            List<String> items = _cache[_session.SessionID] as List<String>;
            if (items != null && items.Count > 0)
            {
                //Cache.Remove(Session.SessionID);
                foreach (var key in items)
                {
                    _cache.Remove(key);
                }
                items.Clear();
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