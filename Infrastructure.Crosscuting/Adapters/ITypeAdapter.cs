namespace Infrastructure.Crosscuting
{
    // <summary>
    /// This is the interface to work with mapper such as automapper
    /// </summary>
    public interface ITypeAdapter
    {
        /// <summary>
        /// Adapt a source object to an instance of type <c>"TTarget"</c>/>
        /// </summary>
        /// <typeparam name="TSource">Type of source item</typeparam>
        /// <typeparam name="TTarget">Type of target item</typeparam>
        /// <param name="source">Instance to adapt</param>
        /// <returns><paramref name="source"/> <typeparamref name="TTarget"/>mapped to </returns>
        TTarget Adapt<TSource, TTarget>(TSource source)
            where TTarget : class
            where TSource : class;

        /// <summary>
        /// Adapt a source object to an instnace of type <c>"TTarget"</c>/>
        /// </summary>
        /// <typeparam name="TTarget">Type of target item</typeparam>
        /// <param name="source">Instance to adapt</param>
        /// <returns><paramref name="source"/> mapped to <typeparamref name="TTarget"/>mapped to </returns>
        TTarget Adapt<TTarget>(object source)
            where TTarget : class;
    }
}
