using System;
namespace Infrastructure.CrossCutting.Adapters
{
    public static class TypeAdapterHelper
    {
        public static TTarget Adapt<TSource, TTarget>(TSource source)
            where TTarget : class
            where TSource : class
        {
            return TypeAdapterFactory.CreateAdapter().Adapt<TSource, TTarget>(source);
        }

        public static TTarget Adapt<TTarget>(object source)
           where TTarget : class
        {
            return TypeAdapterFactory.CreateAdapter().Adapt<TTarget>(source);
        }
    }
}
