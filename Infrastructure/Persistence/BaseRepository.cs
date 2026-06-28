using System.Data;
using System.Linq.Expressions;
using SqlSugar;
using LogisticsProduction.Net8.Domain.Exceptions;

namespace LogisticsProduction.Net8.Infrastructure.Persistence;

/// <summary>
/// 仓储基类，提供通用的参数化数据访问能力
/// </summary>
public abstract class BaseRepository<T> where T : class, new()
{
    protected readonly SqlSugarScope Db;

    protected BaseRepository(DbContextFactory dbFactory)
    {
        Db = dbFactory.GetClient();
    }

    #region 基础 CRUD

    public virtual T? GetById(object id)
    {
        return Db.Queryable<T>().InSingle(id);
    }

    public virtual List<T> GetList(Expression<Func<T, bool>>? whereExpression = null)
    {
        var query = Db.Queryable<T>();
        if (whereExpression != null)
        {
            query = query.Where(whereExpression);
        }
        return query.ToList();
    }

    public virtual async Task<List<T>> GetListAsync(Expression<Func<T, bool>>? whereExpression = null)
    {
        var query = Db.Queryable<T>();
        if (whereExpression != null)
        {
            query = query.Where(whereExpression);
        }
        return await query.ToListAsync();
    }

    public virtual int Insert(T entity)
    {
        return Db.Insertable(entity).ExecuteCommand();
    }

    public virtual async Task<int> InsertAsync(T entity)
    {
        return await Db.Insertable(entity).ExecuteCommandAsync();
    }

    public virtual int Update(T entity)
    {
        return Db.Updateable(entity).ExecuteCommand();
    }

    public virtual int Delete(object id)
    {
        return Db.Deleteable<T>().In(id).ExecuteCommand();
    }

    #endregion

    #region 存储过程调用

    protected DataTable ExecuteProcedure(string procedureName, Dictionary<string, object>? parameters = null)
    {
        try
        {
            var sqlParams = ConvertToSqlParameters(parameters);
            return Db.Ado.UseStoredProcedure().GetDataTable(procedureName, sqlParams);
        }
        catch (Exception ex)
        {
            throw new DataAccessException($"执行存储过程 {procedureName} 失败", ex);
        }
    }

    protected async Task<DataTable> ExecuteProcedureAsync(string procedureName, Dictionary<string, object>? parameters = null)
    {
        try
        {
            var sqlParams = ConvertToSqlParameters(parameters);
            return await Db.Ado.UseStoredProcedure().GetDataTableAsync(procedureName, sqlParams);
        }
        catch (Exception ex)
        {
            throw new DataAccessException($"执行存储过程 {procedureName} 失败", ex);
        }
    }

    private SugarParameter[] ConvertToSqlParameters(Dictionary<string, object>? parameters)
    {
        if (parameters == null || parameters.Count == 0)
        {
            return Array.Empty<SugarParameter>();
        }

        return parameters.Select(kvp => new SugarParameter(kvp.Key, kvp.Value)).ToArray();
    }

    #endregion

    #region 事务支持

    public void BeginTransaction()
    {
        Db.BeginTran();
    }

    public void CommitTransaction()
    {
        Db.CommitTran();
    }

    public void RollbackTransaction()
    {
        Db.RollbackTran();
    }

    #endregion
}
