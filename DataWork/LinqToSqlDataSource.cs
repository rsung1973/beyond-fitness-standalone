using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.Linq;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Web.UI;

using Utility;

namespace CommonLib.DataAccess
{
    public partial class LinqToSqlDataSource<T, TEntity> : DataSourceControl
        where T : DataContext, new()
        where TEntity : class, new()
    {
        protected LinqToSqlDataSourceView<T, TEntity> _view;
        protected GenericManager<T, TEntity> _mgr;

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
                _view = new LinqToSqlDataSourceView<T, TEntity>(this, viewName);
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

        protected internal virtual void OnSelect(LinqToSqlDataSourceEventArgs<TEntity> args)
        {
            if (Select != null)
            {
                Select(this, args);
            }
        }


        public GenericManager<T, TEntity> DataManager
        {
            get
            {
                return _mgr;
            }
        }

        public GenericManager<T, TEntity> CreateDataManager()
        {
            if (_mgr == null)
            {
                String keyName = "__LinqDS" + typeof(T).ToString();
                if (!Isolated && Page!=null && Page.Items[keyName] != null)
                {
                    _mgr = new GenericManager<T,TEntity>((GenericManager<T>)Page.Items[keyName]);
                }
                else
                {
                    _mgr = new GenericManager<T, TEntity>();
                    if (!Isolated && Page!=null)
                    {
                        Page.Items[keyName] = _mgr;
                    }
                }
            }
            return _mgr;
        }

        public LinqToSqlDataSourceView<T, TEntity> CurrentView
        {
            get
            {
                return _view;
            }
        }

        public event EventHandler<LinqToSqlDataSourceEventArgs<TEntity>> Select;

    }

    public partial class LinqToSqlDataSourceView<T, TEntity> : DataSourceView
        where T : DataContext, new()
        where TEntity : class, new()
    {
        private LinqToSqlDataSource<T, TEntity> _owner;
        private DataSourceSelectArguments _arguments;

        public LinqToSqlDataSourceView(IDataSource owner, string viewName)
            : base(owner, viewName)
        {
            _owner = (LinqToSqlDataSource<T, TEntity>)owner;
        }

        public DataSourceSelectArguments LastSelectArguments
        {
            get
            {
                return _arguments;
            }
        }

        protected override IEnumerable ExecuteSelect(DataSourceSelectArguments arguments)
        {
            _arguments = arguments;

            LinqToSqlDataSourceEventArgs<TEntity> eventArgs = new LinqToSqlDataSourceEventArgs<TEntity>
            {
                Query = _owner.DataContext.GetTable<TEntity>()
            };

            _owner.OnSelect(eventArgs);

            if (eventArgs.Query == null)
            {
                eventArgs.Query = _owner.DataContext.GetTable<TEntity>();
            }

            IEnumerable<TEntity> result = (eventArgs.QueryExpr != null) ? eventArgs.Query.Where(eventArgs.QueryExpr) : eventArgs.Query;

            arguments.TotalRowCount = result.Count();
            if (arguments.MaximumRows > 0 && arguments.StartRowIndex >= 0)
            {
                return result.Skip(arguments.StartRowIndex).Take(arguments.MaximumRows);
            }
            else
            {
                return result;
            }
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

    public partial class LinqToSqlDataSourceEventArgs<TEntity> : EventArgs
    {
        public IQueryable<TEntity> Query { get; set; }
        public Expression<Func<TEntity, bool>> QueryExpr { get; set; }
    }

}
