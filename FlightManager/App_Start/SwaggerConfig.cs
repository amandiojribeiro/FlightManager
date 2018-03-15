using System.Web.Http;
using WebActivatorEx;
using FlightManager;
using Swashbuckle.Application;

[assembly: PreApplicationStartMethod(typeof(SwaggerConfig), "Register")]

namespace FlightManager
{
    public class SwaggerConfig
    {
        public static void Register()
        {
            var thisAssembly = typeof(SwaggerConfig).Assembly;

            GlobalConfiguration.Configuration
                .EnableSwagger(c => { c.SingleApiVersion("v1", "API"); })
                .EnableSwaggerUi(c => { });
        }
    }
}
