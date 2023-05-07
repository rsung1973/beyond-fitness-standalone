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
using WebHome.Helper.Jobs;

namespace WebHome
{
    public class Startup
    {
        public static IConfigurationSection Properties { get; private set; }
        public static IWebHostEnvironment Environment { get; private set; }
        public static String ApplicationPath { get; private set; } = "";
        public static  IConfiguration GlobalConfiguration { get; private set; }

        public static String MapPath(String path, bool isStatic = true)
        {
            return isStatic
                ? Path.Combine(Environment.WebRootPath, path.Replace("~/", "")
                    .TrimStart('/').Replace('/', Path.DirectorySeparatorChar))
                : Path.Combine(Environment.ContentRootPath, path.Replace("~/", "")
                    .TrimStart('/').Replace('/', Path.DirectorySeparatorChar));
        }

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
            GlobalConfiguration = configuration;
            Properties = Configuration.GetSection("WebHome");
            _ = new CommonLib.Core.Startup(Configuration);
            ApplicationPath = Properties["ApplicationPath"];

            BusinessExtensionMethods.ContractViewUrl = item =>
            {
                return $"{Properties["HostDomain"]}{VirtualPathUtility.ToAbsolute("~/CommonHelper/ViewContract")}?pdf=1&contractID={item.ContractID}&t={DateTime.Now.Ticks}";
            };

            BusinessExtensionMethods.ContractServiceViewUrl = item =>
            {
                return $"{Properties["HostDomain"]}{VirtualPathUtility.ToAbsolute("~/CommonHelper/ViewContractService")}?pdf=1&revisionID={item.RevisionID}&t={DateTime.Now.Ticks}";
            };

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
            })
            .AddRazorRuntimeCompilation();
                
            //services.AddDbContext<BFDataContext>(options =>
            //    {
            //        options
            //            .UseLazyLoadingProxies()
            //            .UseSqlServer(Configuration.GetConnectionString("BFDbConnection"),
            //                 sqlOptions => sqlOptions.CommandTimeout((int)TimeSpan.FromMinutes(30).TotalSeconds));
            //    });

            //從組態讀取登入逾時設定
            double LoginExpireMinute = webHome.GetValue<double>("LoginExpireMinute");
            //註冊 CookieAuthentication，Scheme必填
            services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme).AddCookie(option =>
            {
                //或許要從組態檔讀取，自己斟酌決定
                option.LoginPath = new PathString(webHome["LoginUrl"]);//登入頁
                option.LogoutPath = new PathString(webHome["LogoutUrl"]);//登出Action
                //用戶頁面停留太久，登入逾期，或Controller的Action裡用戶登入時，也可以設定↓
                option.ExpireTimeSpan = TimeSpan.FromMinutes(LoginExpireMinute);//沒給預設14天
                //↓資安建議false，白箱弱掃軟體會要求cookie不能延展效期，這時設false變成絕對逾期時間
                //↓如果你的客戶反應明明一直在使用系統卻容易被自動登出的話，你再設為true(然後弱掃policy請客戶略過此項檢查) 
                option.SlidingExpiration = true;
            });

            services.AddControllersWithViews(options => {
                //↓和CSRF資安有關，這裡就加入全域驗證範圍Filter的話，待會Controller就不必再加上[AutoValidateAntiforgeryToken]屬性
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
            //留意寫Code順序，先執行驗證...
            app.UseAuthentication();
            app.UseAuthorization();//Controller、Action才能加上 [Authorize] 屬性
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
                        name: "Official",
                        pattern: "Official/{action}/{id?}/{keyID?}",
                        defaults: new { controller = "MainActivity", action = "Index" }
                    );

                endpoints.MapControllerRoute(
                    name: "OfficialActionName",
                    pattern: "Official/{*actionName}",
                    defaults: new { controller = "MainActivity", action = "HandleUnknownAction" });

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

            JobLauncher.StartUp();
        }
    }
}
