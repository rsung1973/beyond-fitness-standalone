using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using WebHome.Models.DataEntity;
using WebHome.Models.ViewModel;
using WebHome.Helper;
using System.Threading;
using System.Text;
using WebHome.Models.Locale;
using Utility;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Web.Security;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [Authorize]
    public class SystemInfoController : SampleController<UserProfile>
    {
        // GET: SystemInfo
        [AssistantOrSysAdminAuthorize]
        public ActionResult ConfigureAll()
        {
            return View("ConfigureAll");
        }

        public ActionResult LessonPriceTypeList()
        {
            ViewBag.DataTableId = "priceType";
            return View("LessonPriceTypeList", models.GetTable<LessonPriceType>());
        }

        [AssistantOrSysAdminAuthorize]
        public ActionResult EditLessonPrice(int? priceID)
        {
            LessonPriceViewModel viewModel = new LessonPriceViewModel { };
            LessonPriceType item = models.GetTable<LessonPriceType>().Where(p => p.PriceID == priceID).FirstOrDefault();

            if(item!=null)
            {
                viewModel.PriceID = item.PriceID;
                viewModel.Description = item.Description;
                viewModel.ListPrice = item.ListPrice;
                viewModel.Status = item.Status;
                viewModel.UsageType = item.UsageType;
                viewModel.CoachPayoff = item.CoachPayoff;
                viewModel.CoachPayoffCreditCard = item.CoachPayoffCreditCard;
            }
            ViewBag.ViewModel = viewModel;

            return View();
        }

        public ActionResult DeleteLessonPrice(int id)
        {
            var item = models.DeleteAny<LessonPriceType>(p => p.PriceID == id);
            if(item!=null)
            {
                ViewBag.Message = "資料已刪除!!";
            }
            return ConfigureAll();
        }

        public ActionResult UpdateLessonPrice(int priceID,int status)
        {
            LessonPriceType item = models.GetTable<LessonPriceType>().Where(p => p.PriceID == priceID).FirstOrDefault();
            if (item == null)
            {
                ViewBag.Message = "課程類別資料不存在!!";
                return LessonPriceTypeList();
            }

            item.Status = status;
            models.SubmitChanges();

            if (status == (int)Naming.DocumentLevelDefinition.正常)
            {
                ViewBag.Message = "課程類別已啟用!!";
            }
            else if (status == (int)Naming.DocumentLevelDefinition.已刪除)
            {
                ViewBag.Message = "課程類別已停售!!";
            }

            return ConfigureAll();
        }



        public ActionResult CommitLessonPrice(LessonPriceViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if(!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("EditLessonPrice");
            }

            LessonPriceType item = models.GetTable<LessonPriceType>()
                .Where(p => p.PriceID == viewModel.PriceID).FirstOrDefault();

            if(item==null)
            {
                item = new LessonPriceType
                {
                    PriceID = models.GetTable<LessonPriceType>().Select(p => p.PriceID).Max() + 1,
                    Status = (int)Naming.DocumentLevelDefinition.正常
                };
                models.GetTable<LessonPriceType>().InsertOnSubmit(item);
            }

            item.CoachPayoff = viewModel.CoachPayoff;
            item.CoachPayoffCreditCard = viewModel.CoachPayoffCreditCard;
            item.Description = viewModel.Description;
            item.UsageType = viewModel.UsageType;
            item.ListPrice = viewModel.ListPrice;

            models.SubmitChanges();
            ViewBag.Message = "資料已儲存!!";

            return ConfigureAll();
        }
    }
}