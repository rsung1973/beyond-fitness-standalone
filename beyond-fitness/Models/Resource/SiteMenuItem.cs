using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebHome.Models.Resource
{
    public class SiteMenuItem
    {
        public SiteMenuItem[] MenuItem { get; set; }
        public String Id { get; set; }
        public String Name { get; set; }
        public String Url { get; set; }

    }
}