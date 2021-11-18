using System.Web.Mvc;

namespace CommonLib.MvcExtension
{

    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return this.TransferToAction("Index", "Users");
        }
    }
}