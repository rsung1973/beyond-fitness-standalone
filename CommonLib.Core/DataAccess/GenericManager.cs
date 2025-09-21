using System;
using System.Data;
using System.Linq;
using System.Data.Linq;
using System.Collections.Generic;
using System.Data.Common;
using System.IO;

using CommonLib.Utility;
using System.Linq.Expressions;
using System.Collections;
using CommonLib.Logger;
using CommonLib.Core.Properties;
using System.Data.SqlClient;

namespace CommonLib.DataAccess
{
    /// <summary>
    /// UserManager 的摘要描述。
    /// </summary>
    public partial class GenericManager<T, TEntity> : GenericManager<T>
        where T : DataContext, new()
        where TEntity : class, new()
    {
        protected internal TEntity? _entity;

        public GenericManager() : base() { }
        public GenericManager(GenericManager<T> mgr) : base(mgr) { }


        public TEntity? DataEntity
        {
            get
            {
                return _entity;
            }
        }

        public Table<TEntity> EntityList
        {
            get
            {
                return _db.GetTable<TEntity>();
            }
        }


        protected TEntity? instantiateData(IQueryable<TEntity> values)
        {
            _entity = values.FirstOrDefault();
            return _entity;
        }

        public virtual TEntity CreateEntity()
        {
            _entity = new TEntity();
            EntityList.InsertOnSubmit(_entity);
            return _entity;
        }

        public void DeleteEntity()
        {
            if (_entity != null)
            {
                _db.GetTable<TEntity>().DeleteOnSubmit(_entity);
                _db.SubmitChanges();
                _entity = default(TEntity);
            }
        }

        public TEntity DeleteAny(Expression<Func<TEntity, bool>> predicate)
        {
            return DeleteAny<TEntity>(predicate);
        }

        public TEntity DeleteAnyOnSubmit(Expression<Func<TEntity, bool>> predicate)
        {
            return DeleteAnyOnSubmit<TEntity>(predicate);
        }

        public IEnumerable<TEntity> DeleteAll(Expression<Func<TEntity, bool>> predicate)
        {
            return DeleteAll<TEntity>(predicate);
        }

        public IEnumerable<TEntity> DeleteAllOnSubmit(Expression<Func<TEntity, bool>> predicate)
        {
            return DeleteAllOnSubmit<TEntity>(predicate);
        }


    }

    public class GenericManager<T> : IDisposable
                where T : DataContext, new()
    {
        protected internal T _db;
        protected internal bool _isInstance = true;

        private bool _bDisposed = false;
        private SqlLogger _logWriter;

        public GenericManager(T db)
        {
            //
            // TODO: 在此加入建構函式的程式碼
            //
            _db = db;
            _isInstance = false;
        }

        public GenericManager()
            : this(new T(), null)
        {

        }


        public GenericManager(IDbConnection connection)
        {
            _isInstance = false;

            Type type = typeof(T);
            T db = (T)type.Assembly.CreateInstance(type.FullName, false, System.Reflection.BindingFlags.CreateInstance, null,
                new Object[] { connection }, null, null);

            initialize(db, null);
        }

        public GenericManager(GenericManager<T> mgr)
        {
            if (mgr != null)
            {
                _db = mgr.DataContext;
                _isInstance = false;
            }
            else
            {
                initialize(new T(), null);
            }
        }

        public GenericManager(T db, TextWriter log)
        {
            initialize(db, log);
        }

        private void initialize(T db, TextWriter log)
        {
            _db = db;
            _db.Log = log;

            if (_db.Log == null && AppSettings.Default.SqlLog)
            {
                _logWriter = new SqlLogger { IgnoreSelect = AppSettings.Default.SqlLogIgnoreSelect }; 
                _db.Log = _logWriter;
            }
        }


        public IDbConnection Connection
        {
            get { return _db.Connection; }
        }



        public T DataContext
        {
            get { return _db; }
        }

        public GenericManager<U> BridgeManager<U>()
            where U : DataContext, new()
        {
            return new GenericManager<U>(_db.Connection);
        }

        public void SubmitChanges()
        {
            _db.SubmitChanges();
        }


        public DbTransaction EnterTransaction()
        {
            if (_db.Connection.State != ConnectionState.Open)
            {
                _db.Connection.Open();
            }

            DbTransaction tran = _db.Connection.BeginTransaction();
            _db.Transaction = tran;

            return tran;
        }


        public DataLoadOptions LoadOptions
        {
            get
            {
                return DataContext.LoadOptions;
            }
            set
            {
                DataContext.LoadOptions = value;
            }
        }

        public Table<TTable> GetTable<TTable>() where TTable : class
        {
            return _db.GetTable<TTable>();
        }

        public DbCommand GetCommand(IQueryable query)
        {
            return _db.GetCommand(query);
        }

        public IEnumerable ExecuteQuery(Type elementType, string query, params Object[] parameters)
        {
            return _db.ExecuteQuery(elementType, query, parameters);
        }

        public IEnumerable<TResult> ExecuteQuery<TResult>(string query, params Object[] parameters)
        {
            return _db.ExecuteQuery<TResult>(query, parameters);
        }

        public IEnumerable<TResult> ExecutePagingQuery<TResult>(IQueryable<TResult> query, int skipCount, int takeCount)
        {
            SqlCommand sqlCmd = (SqlCommand)_db.GetCommand(query);
            var sqlText = sqlCmd.ToExecutableSql();
            sqlText = $"{sqlText} {(sqlText.Contains("ORDER BY",StringComparison.OrdinalIgnoreCase) ? "" : "ORDER BY (SELECT NULL)")} OFFSET {skipCount} ROWS FETCH NEXT {takeCount} ROWS ONLY";
            return _db.ExecuteQuery<TResult>(sqlText);
        }

        public IEnumerable ExecutePagingQuery(Type type, IQueryable query, int skipCount, int takeCount)
        {
            SqlCommand sqlCmd = (SqlCommand)_db.GetCommand(query);
            var sqlText = sqlCmd.ToExecutableSql();
            sqlText = $"{sqlText} {(sqlText.Contains("ORDER BY", StringComparison.OrdinalIgnoreCase) ? "" : "ORDER BY (SELECT NULL)")} OFFSET {skipCount} ROWS FETCH NEXT {takeCount} ROWS ONLY";
            return _db.ExecuteQuery(type, sqlText);
        }



        public int ExecuteCommand(string command, params Object[] parameters)
        {
            return _db.ExecuteCommand(command, parameters);
        }

        public TSource DeleteAnyOnSubmit<TSource>(Expression<Func<TSource, bool>> predicate) where TSource : class, new()
        {
            var table = _db.GetTable<TSource>();
            TSource item = table.Where(predicate).FirstOrDefault();
            if (item != null)
            {
                table.DeleteOnSubmit(item);
            }
            return item;
        }

        public IEnumerable<TSource> DeleteAllOnSubmit<TSource>(Expression<Func<TSource, bool>> predicate) where TSource : class, new()
        {
            var table = _db.GetTable<TSource>();
            IEnumerable<TSource> items = table.Where(predicate);
            table.DeleteAllOnSubmit(items);
            return items;
        }

        public IEnumerable<TSource> DeleteAll<TSource>(Expression<Func<TSource, bool>> predicate) where TSource : class, new()
        {
            IEnumerable<TSource> items = DeleteAllOnSubmit<TSource>(predicate);
            _db.SubmitChanges();
            return items;
        }


        public TSource DeleteAny<TSource>(Expression<Func<TSource, bool>> predicate) where TSource : class, new()
        {
            TSource item = DeleteAnyOnSubmit<TSource>(predicate);
            if (item != null)
            {
                _db.SubmitChanges();
            }
            return item;
        }

        #region IDisposable 成員

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!_bDisposed)
            {
                if (disposing)
                {
                    if (_isInstance)
                    {
                        _db.Dispose();
                        if (_logWriter != null)
                            _logWriter.Dispose();
                    }
                }

                _bDisposed = true;
            }
        }

        ~GenericManager()
        {
            Dispose(false);
        }

        #endregion

    }

}
