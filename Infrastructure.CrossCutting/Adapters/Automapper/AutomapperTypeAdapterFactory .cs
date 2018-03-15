namespace Infrastructure.CrossCutting.Adapters.Automapper
{
    using System;
    using System.Linq;
    using AutoMapper;

    public class AutomapperTypeAdapterFactory : ITypeAdapterFactory
    {
        #region Constructor

        /// <summary>
        /// Create a new Automapper type adapter factory
        /// </summary>
        public AutomapperTypeAdapterFactory()
        {
            // scan all Farfetch assemblies finding Automapper Profile
            var profiles = AppDomain.CurrentDomain
                                    .GetAssemblies()
                                    .SelectMany(a => a.GetTypes())
                                    .Where(t => t.BaseType == typeof(Profile));

            Mapper.Initialize(cfg =>
            {
                foreach (var item in profiles.Where(item => item.FullName != "AutoMapper.SelfProfiler`2"))
                {
                    cfg.AddProfile(Activator.CreateInstance(item) as Profile);
                }
            });
        }

        #endregion Constructor

        #region ITypeAdapterFactory Members

        public ITypeAdapter Create()
        {
            return new AutomapperTypeAdapter();
        }

        #endregion ITypeAdapterFactory Members
    }
}
