using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.EntityFrameworkCore;

using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

using WebHome.Models.DataEntity;
using WebHome.Controllers.Filters;
using Microsoft.Extensions.Logging;
using WebHome.Helper;
using CommonLib.Core.Utility;
using System.IO;
using Microsoft.AspNetCore.Mvc.Infrastructure;

namespace WebHome
{
    public class Startup
    {
        public static IConfigurationSection Properties { get; private set; }
        public static IWebHostEnvironment Environment { get; private set; }
        public static String ApplicationPath { get; private set; } = "";
        public static  IConfiguration GlobalConfiguration { get; private set; }

        public static String MapPath(String path)
        {
            return Path.Combine(Environment.WebRootPath, path.Replace("~", ""));
        }

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
            GlobalConfiguration = configuration;
            Properties = Configuration.GetSection("WebHome");
            _ = new CommonLib.Core.Startup(Configuration);
            ApplicationPath = Properties["ApplicationPath"];
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            var webHome = Configuration.GetSection("WebHome");

            //services.AddControllersWithViews();
            services.AddMemoryCache();

            services.AddSession(options =>
            {
                options.IdleTimeout = TimeSpan.FromMinutes(webHome.GetValue<double>("SessionTimeoutInMinutes"));
                options.Cookie.HttpOnly = true;
                options.Cookie.IsEssential = true;
            });

            services.AddMvc(config =>
            {
                config.Filters.Add(new SampleResultFilter());
                config.Filters.Add(new ExceptionFilter());
            }).ConfigureApiBehaviorOptions(options =>
            {
                options.SuppressMapClientErrors = true;
                options.SuppressModelStateInvalidFilter = true;
            });
                
            //services.AddDbContext<BFDataContext>(options =>
            //    {
            //        options
            //            .UseLazyLoadingProxies()
            //            .UseSqlServer(Configuration.GetConnectionString("BFDbConnection"),
            //                 sqlOptions => sqlOptions.CommandTimeout((int)TimeSpan.FromMinutes(30).TotalSeconds));
            //    });

            //�q�պAŪ���n�J�O�ɳ]�w
            double LoginExpireMinute = webHome.GetValue<double>("LoginExpireMinute");
            //���U CookieAuthentication�AScheme����
            services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme).AddCookie(option =>
            {
                //�γ\�n�q�պA��Ū���A�ۤv�r�u�M�w
                option.LoginPath = new PathString(webHome["LoginUrl"]);//�n�J��
                option.LogoutPath = new PathString(webHome["LogoutUrl"]);//�n�XAction
                //�Τ᭶�����d�Ӥ[�A�n�J�O���A��Controller��Action�̥Τ�n�J�ɡA�]�i�H�]�w��
                option.ExpireTimeSpan = TimeSpan.FromMinutes(LoginExpireMinute);//�S���w�]14��
                //����w��ĳfalse�A�սc�z���n��|�n�Dcookie���ੵ�i�Ĵ��A�o�ɳ]false�ܦ�����O���ɶ�
                //���p�G�A���Ȥ���������@���b�ϥΨt�Ϋo�e���Q�۰ʵn�X���ܡA�A�A�]��true(�M��z��policy�ЫȤᲤ�L�����ˬd) 
                option.SlidingExpiration = true;
            });

            services.AddControllersWithViews(options => {
                //���MCSRF��w�����A�o�̴N�[�J�������ҽd��Filter���ܡA�ݷ|Controller�N�����A�[�W[AutoValidateAntiforgeryToken]�ݩ�
                //options.Filters.Add(new AutoValidateAntiforgeryTokenAttribute());
            });

            services.AddScoped<IViewRenderService, ViewRenderService>();

            services.AddSingleton<IActionContextAccessor, ActionContextAccessor>();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, ILoggerFactory loggerFactory)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                //app.UseExceptionHandler("/Home/Error");
                app.UseDeveloperExceptionPage();
                app.UseHsts();
            }
            app.UseStaticFiles();

            app.UseRouting();

            //app.UseAuthorization();
            //�d�N�gCode���ǡA����������...
            app.UseAuthentication();
            app.UseAuthorization();//Controller�BAction�~��[�W [Authorize] �ݩ�
            app.UseSession();

            app.Use(next =>
                context =>
                {
                    context.Request.EnableBuffering();
                    return next(context);
                });

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller=Home}/{action=Index}/{id?}");

                endpoints.MapControllerRoute(
                    name: "actionName",
                    pattern: "{controller}/{*actionName}",
                    defaults: new { action = "HandleUnknownAction" });

            });


            //call ConfigureLogger in a centralized place in the code
            ApplicationLogging.ConfigureLogger(loggerFactory);
            //set it as the primary LoggerFactory to use everywhere
            ApplicationLogging.LoggerFactory = loggerFactory;
            Environment = env;
        }
    }
}
