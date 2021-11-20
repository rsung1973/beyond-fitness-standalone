using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.Linq;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Web.UI;

using Utility;
using System.Data.SqlClient;
using System.Data;
using System.Data.Common;

namespace CommonLib.DataAccess
{
    public partial class DataAccessLayerDataSource<T> : DataSourceControl
        where T : DataContext, new()
    {
        private DataAccessLayerDataSourceView<T> _view;
        private GenericManager<T> _mgr;

        public bool Isolated
        {
            get;
            set;
        }

        protected override DataSourceView GetView(string viewName)
        {
            if (_view == null)
            {
                CreateDataManager();
                _view = new DataAccessLayerDataSourceView<T>(this, viewName);
            }
            return _view;
        }

        internal T DataContext
        {
            get
            {
                return _mgr._db;
            }
        }

        protected override void OnUnload(EventArgs e)
        {
            base.OnUnload(e);
            if (_mgr != null)
                _mgr.Dispose();
        }

        protected internal virtual void OnSelect(DataAccessLayerDataSourceEventArgs args)
        {
            if (Select != null)
            {
                Select(this, args);
            }
        }


        public GenericManager<T> CreateDataManager()
        {
            if (_mgr == null)
            {
                if (!Isolated && Page!=null && Page.Items["__LinqDS"] != null)
                {
                    _mgr = new GenericManager<T>((GenericManager<T>)Page.Items["__LinqDS"]);
                }
                else
                {
                    _mgr = new GenericManager<T>();
                    if (!Isolated && Page!=null)
                    {
                        Page.Items["__LinqDS"] = _mgr;
                    }
                }
            }
            return _mgr;
        }

        public event EventHandler<DataAccessLayerDataSourceEventArgs> Select;

    }

    public partial class DataAccessLayerDataSourceView<T> : DataSourceView
        where T : DataContext, new()
    {
        private DataAccessLayerDataSource<T> _owner;

        public DataAccessLayerDataSourceView(IDataSource owner, string viewName)
            : base(owner, viewName)
        {
            _owner = (DataAccessLayerDataSource<T>)owner;
        }

        protected override IEnumerable ExecuteSelect(DataSourceSelectArguments arguments)
        {
            DataAccessLayerDataSourceEventArgs eventArgs = new DataAccessLayerDataSourceEventArgs();
            _owner.OnSelect(eventArgs);

            if (eventArgs.QueryCommand == null)
            {
                eventArgs.QueryCommand = new SqlCommand("select null as ColumnName");
                arguments.TotalRowCount = 0;
                return new DataTable().AsEnumerable();
            }

            SqlConnection conn = (SqlConnection)_owner.CreateDataManager()._db.Connection;
            eventArgs.QueryCommand.Connection = conn;
            conn.Open();

            if (eventArgs.QueryCommand.CommandText.Trim().ToUpper().StartsWith("SELECT"))
            {
                SqlCommand cmdRecordCount = eventArgs.QueryCommand.Clone();
                cmdRecordCount.CommandText = "select Count(*) as RecordCount " + cmdRecordCount.CommandText.Substring(cmdRecordCount.CommandText.ToUpper().IndexOf("FROM"));
                arguments.TotalRowCount = (int)cmdRecordCount.ExecuteScalar();
            }
            else
            {
                arguments.TotalRowCount = 1;
            }


            SqlDataAdapter da = new SqlDataAdapter(eventArgs.QueryCommand);
            DataSet result = new DataSet();
            if (arguments.MaximumRows > 0 && arguments.StartRowIndex >= 0)
            {
                da.Fill(result, arguments.StartRowIndex, arguments.MaximumRows, "Table");
            }
            else
            {
                da.Fill(result);
            }

            return result.Tables[0].AsEnumerable();

        }

        protected override int ExecuteDelete(IDictionary keys, IDictionary oldValues)
        {
            //return base.ExecuteDelete(keys, oldValues);
            //foreach (var key in keys.Keys)
            //{
            //    object obj = keys[key];
            //}

            //foreach (var key in oldValues.Keys)
            //{
            //    object obj = oldValues[key];
            //}

            return -1;
        }

        protected override int ExecuteInsert(IDictionary values)
        {
            //return base.ExecuteInsert(values);
            return -1;
        }

        protected override int ExecuteUpdate(IDictionary keys, IDictionary values, IDictionary oldValues)
        {
            //return base.ExecuteUpdate(keys, values, oldValues);
            //foreach (var key in keys.Keys)
            //{
            //    object obj = keys[key];
            //}

            //foreach (var key in values.Keys)
            //{
            //    object obj = values[key];
            //}
            return -1;
        }

        public override bool CanRetrieveTotalRowCount
        {
            get
            {
                return true;
            }
        }

        public override bool CanDelete
        {
            get
            {
                return true;
            }
        }

        public override bool CanInsert
        {
            get
            {
                return true;
            }
        }

        public override bool CanPage
        {
            get
            {
                return true;
            }
        }

        public override bool CanSort
        {
            get
            {
                return true;
            }
        }

        public override bool CanUpdate
        {
            get
            {
                return true;
            }
        }

    }

    public partial class DataAccessLayerDataSourceEventArgs : EventArgs
    {
        public SqlCommand QueryCommand { get; set; }
    }
}
