namespace Infrastructure.CrossCutting.Adapters.Automapper
{
    using AutoMapper;

    /// <summary>
    /// <c>Automapper</c> type adapter implementation
    /// </summary>
    public class AutomapperTypeAdapter
       : ITypeAdapter
    {
        #region ITypeAdapter Members

        /// <summary>
        /// <see cref="ITypeAdapter"/>
        /// </summary>
        /// <typeparam name="TSource"><see cref="ITypeAdapter"/>source type</typeparam>
        /// <typeparam name="TTarget"><see cref="ITypeAdapter"/>target type</typeparam>
        /// <param name="source"><see cref="ITypeAdapter"/>the object to adapt</param>
        /// <returns><see cref="ITypeAdapter"/>mapped to </returns>
        public TTarget Adapt<TSource, TTarget>(TSource source)
            where TSource : class
            where TTarget : class
        {
            return Mapper.Map<TSource, TTarget>(source);
        }

        /// <summary>
        /// <see cref="ITypeAdapter"/>
        /// </summary>
        /// <typeparam name="TTarget"><see cref="ITypeAdapter"/>target type</typeparam>
        /// <param name="source"><see cref="ITypeAdapter"/>the object to adapt</param>
        /// <returns><see cref="ITypeAdapter"/>mapped to </returns>
        public TTarget Adapt<TTarget>(object source) where TTarget : class
        {
            return Mapper.Map<TTarget>(source);
        }

        #endregion ITypeAdapter Members
    }
}
