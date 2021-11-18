using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CommonLib.Web.Module.jQuery
{
    public partial class EnumSelector : HtmlSelector
    {
        [Bindable(true)]
        public String TypeName
        {
            get;
            set;
        }

        [Bindable(true)]
        public Type EnumType
        {
            get;
            set;
        }

        protected override void HtmlSelector_PreRender(object sender, EventArgs e)
        {
            base.HtmlSelector_PreRender(sender, e);

            if (EnumType == null && !String.IsNullOrEmpty(TypeName))
            {
                EnumType = Type.GetType(TypeName);
            }
            if (EnumType != null)
            {
                String[] items = Enum.GetNames(EnumType);
                Array values = Enum.GetValues(EnumType);
                for (int i = 0; i < items.Length; i++)
                {
                    _items.Add(new KeyValuePair<object, object>((int)values.GetValue(i), items[i]));
                }
            }
        }

    }
}