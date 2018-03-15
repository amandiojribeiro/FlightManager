using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.CrossCutting.Adapters
{
    public interface ITypeAdapterFactory
    {
        /// <summary>
        /// Create a type adater
        /// </summary>
        /// <returns>The created ITypeAdapter</returns>
        ITypeAdapter Create();
    }
}
