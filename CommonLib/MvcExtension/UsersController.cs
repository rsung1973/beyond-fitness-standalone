using System.Web.Mvc;

namespace CommonLib.MvcExtension
{
    public class UsersController : Controller
    {
        [TransferActionOnly]
        public ActionResult Index()
        {
            return View();
        }
    }
}