using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CommonLib.DataAccess
{
    public class LinqDataSource : System.Web.UI.WebControls.LinqDataSource
    {
        protected System.Web.UI.WebControls.LinqDataSourceView _view;

        public event EventHandler<LinqDataSourceViewEventArgs> DataSourceViewCreated;

        protected override System.Web.UI.WebControls.LinqDataSourceView CreateView()
        {
            _view = base.CreateView();
            if (DataSourceViewCreated != null)
            {
                DataSourceViewCreated(this, new LinqDataSourceViewEventArgs
                {
                    DataSourceView = _view
                });
            }
            return _view;
        }

        public System.Web.UI.WebControls.LinqDataSourceView DataSourceView
        {
            get
            {
                return _view;
            }
        }


    }

    public partial class LinqDataSourceViewEventArgs : EventArgs
    {
        public System.Web.UI.WebControls.LinqDataSourceView DataSourceView { get; set; }
    }

}
