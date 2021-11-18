using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace CommonLib.Core
{
    public class Startup
    {
        public static IConfigurationSection Properties { get; private set; }
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
            Properties = Configuration.GetSection("CommonLib.Core");
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {

        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app)
        {

        }
    }
}
