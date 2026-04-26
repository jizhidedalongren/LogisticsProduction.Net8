using System.Linq.Expressions;

namespace LogisticsProduction.Net8.Domain.Interfaces;

/// <summary>
/// 仓储接口基类
/// </summary>
public interface IRepository<T> where T : class
{
    T? GetById(object id);
    List<T> GetList(Expression<Func<T, bool>>? whereExpression = null);
    Task<List<T>> GetListAsync(Expression<Func<T, bool>>? whereExpression = null);
    int Insert(T entity);
    Task<int> InsertAsync(T entity);
    int Update(T entity);
    int Delete(object id);
}
