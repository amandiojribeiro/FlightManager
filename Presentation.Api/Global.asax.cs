using Infrastructure.CrossCutting.Adapters;
using Infrastructure.CrossCutting.Adapters.Automapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace Presentation.Api
{
    /// <summary>
    /// 
    /// </summary>
    public class WebApiApplication : System.Web.HttpApplication
    {
        /// <summary>
        /// 
        /// </summary>
        protected void Application_Start()
        {
            GlobalConfiguration.Configure(WebApiConfig.Register);
            TypeAdapterFactory.SetCurrent(new AutomapperTypeAdapterFactory());
            AreaRegistration.RegisterAllAreas();
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }

        /// <summary>
        /// 
        /// </summary>
        protected void Application_End()
        {
            UnityWebApiActivator.Shutdown();
        }
    }
}
