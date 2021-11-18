using System;
using System.Collections.Generic;
using System.Data.Linq;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CommonLib.DataAccess;

namespace CommonLib.DataAccessLayer.Models
{
    public class ModelSource<T, TEntity> : GenericManager<T, TEntity>
        where T : DataContext, new()
        where TEntity : class,new()
    {
        protected IQueryable<TEntity> _items;
        protected ModelSourceInquiry<T, TEntity> _inquiry;

        public ModelSource() : base() { }
        public ModelSource(GenericManager<T> manager) : base(manager) { }

        public IQueryable<TEntity> Items
        {
            get
            {
                if (_items == null)
                    _items = this.EntityList;
                return _items;
            }
            set
            {
                _items = value;
            }
        }

        public T GetDataContext()
        {
            return (T)this._db;
        }

        public void BuildQuery()
        {
            if (_inquiry != null)
            {
                _inquiry.BuildQueryExpression(this);
            }
        }

        public ModelSourceInquiry<T, TEntity> Inquiry
        {
            get
            {
                return _inquiry;
            }
            set
            {
                _inquiry = value;
                _inquiry.ApplyModelSource(this);
            }
        }

        //private void applyModelSource()
        //{
        //    _inquiry.ModelSource = this;
        //}

        public String DataSourcePath
        {
            get;
            set;
        }

        public bool InquiryHasError
        {
            get;
            set;
        }
    }

    public partial class ModelSourceInquiry<T, TEntity> : ModelSourceInquiry
        where T : DataContext, new()
        where TEntity : class,new()
    {
        protected List<ModelSourceInquiry<T, TEntity>> _chainedInquiry;

        public void ApplyModelSource(ModelSource<T, TEntity> models)
        {
            this.ModelSource = models;
            if (_chainedInquiry != null)
            {
                foreach (var inquiry in _chainedInquiry)
                {
                    inquiry.ApplyModelSource(models);
                }
            }
        }

        public virtual void BuildQueryExpression(ModelSource<T, TEntity> models)
        {
            HasError = QueryRequired && !HasSet;
            if (HasError)
            {
                models.Items = models.EntityList.Where(f => false);
                ModelSource.InquiryHasError = true;
            }
            else
            {
                if (_chainedInquiry != null)
                {
                    foreach (var inquiry in _chainedInquiry)
                    {
                        inquiry.BuildQueryExpression(models);
                    }
                }
            }
        }

        public ModelSourceInquiry<T, TEntity> Append(ModelSourceInquiry<T, TEntity> inquiry)
        {
            if (_chainedInquiry == null)
            {
                _chainedInquiry = new List<ModelSourceInquiry<T, TEntity>>();
            }
            _chainedInquiry.Add(inquiry);
            return this;
        }

        public ModelSource<T, TEntity> ModelSource
        { get; set; }
    }

    public partial class ModelSourceInquiry
    {

        public bool QueryRequired
        { get; set; }

        public bool HasSet
        { get; protected set; }

        public String AlertMessage
        { get; set; }

        public string ActionName
        {
            get;
            set;
        }

        public String ControllerName
        {
            get;
            set;
        }

        public bool HasError
        {
            get;
            protected set;
        }

        public String QueryMessage
        { get; set; }


    }
}
