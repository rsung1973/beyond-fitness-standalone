using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CommonLib.Web
{
    public static  partial class ExtensionMethods
    {
        public static String CheckSymbol(this bool val)
        {
            return val == true ? "☑" : "☐";
        }

    }
}
