using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebHome.Helper.DataOperation
{
    public static class DataProcessExtensions
    {
        public static bool In(this int target,params int[] values)
        {
            return values.Any(v => target == v);
        }
    }
}