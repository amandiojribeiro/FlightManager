namespace Presentation.Api
{
    using Application.Services.FlightService;
    using Data.Repository;
    using Domain.Core.RepositoryInterfaces;
    using Domain.Services;
    using Infrastructure.Crosscuting;
    using Infrastructure.Crosscuting.Adapters.Automapper;
    using Microsoft.AspNetCore.Authentication.Cookies;
    using Microsoft.AspNetCore.Builder;
    using Microsoft.AspNetCore.Hosting;
    using Microsoft.AspNetCore.Identity;
    using Microsoft.Extensions.Configuration;
    using Microsoft.Extensions.DependencyInjection;
    using Presentation.Api.Models;
    using Swashbuckle.AspNetCore.Swagger;
    using System.Threading.Tasks;

    public class Startup
    {
        public IConfiguration Configuration { get; }

        private IHostingEnvironment _env;

        public Startup(IHostingEnvironment env)
        {
            _env = env;

            var builder = new ConfigurationBuilder()
                .SetBasePath(env.ContentRootPath)
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true)
                .AddEnvironmentVariables();
            Configuration = builder.Build();

        }


        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddSingleton(Configuration);

            services.AddTransient<IFlightRepository, FlightRepository>();
            services.AddTransient<IAirportRepository, AirportRepository>();
            services.AddTransient<IFlightDistanceCalculatorService, FlightDistanceCalculatorService>();
            services.AddTransient<IFlightService, FlightService>();

            TypeAdapterFactory.SetCurrent(new AutomapperTypeAdapterFactory());

            services.AddMvc();

            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new Info { Title = "Flight Service", Version = "v1" });
            });

            services.AddIdentity<User, Role>().AddDefaultTokenProviders();
            services.ConfigureApplicationCookie(cfg =>
                cfg.Events = new CookieAuthenticationEvents
                {
                    OnRedirectToLogin = ctx =>
                    {
                        if (ctx.Request.Path.StartsWithSegments("/api"))
                            ctx.Response.StatusCode = (int)System.Net.HttpStatusCode.Unauthorized;

                        return Task.FromResult(0);
                    }
                });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            // Enable middleware to serve generated Swagger as a JSON endpoint.
            app.UseSwagger();

            // Enable middleware to serve swagger-ui (HTML, JS, CSS, etc.), specifying the Swagger JSON endpoint.
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/v1/swagger.json", "Flight Service V1");
            });

            app.UseMvc();

            app.UseAuthentication();
        }
    }
}
