using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CommonLib.Web.Module.jQuery
{
    public partial class HtmlSelector : ViewUserControl
    {
        protected List<KeyValuePair<object, object>> _items;

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            this.PreRender += HtmlSelector_PreRender;
        }

        protected virtual void HtmlSelector_PreRender(object sender, EventArgs e)
        {
            if(_items==null)
            {
                _items = new List<KeyValuePair<object, object>>();
            }
        }

        [System.ComponentModel.Bindable(true)]
        public String FieldName
        { get; set; }

        [System.ComponentModel.Bindable(true)]
        public String DefaultValue
        { get; set; }

        [System.ComponentModel.Bindable(true)]
        public String SelectorIndication
        { get; set; }

        [System.ComponentModel.Bindable(true)]
        public String SelectorIndicationValue
        { get; set; }
    }
}