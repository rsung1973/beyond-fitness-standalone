using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;


using LineMessagingAPISDK.Models;
using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Helper.LineEvent;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;
using CommonLib.Core.Utility;
using Microsoft.Extensions.Logging;

namespace WebHome.Controllers
{
    public class LineEventsController : SampleController<UserProfile>
    {
        public LineEventsController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: LineEvents
        public async Task<ActionResult> Index(/*[FromBody]String content*/)
        {
            await Request.SaveAsAsync(Path.Combine(FileLogger.Logger.LogDailyPath, "LineEvents-" + DateTime.Now.Ticks + ".txt"));

            if (Request.ContentLength > 0)
            {
                byte[] content = await Request.GetRequestBytesAsync();
                if(validateSignature(content))
                {
                    var jsonData = Encoding.UTF8.GetString(content);
                    Activity activity = JsonConvert.DeserializeObject<Activity>(jsonData);
                    foreach (Event lineEvent in activity.Events)
                    {

                        //if (lineEvent.ReplyToken == "00000000000000000000000000000000"
                        //    || lineEvent.ReplyToken != "ffffffffffffffffffffffffffffffff")
                        //{
                        //    return new EmptyResult();
                        //}

                        LineMessageHandler handler = new LineMessageHandler(lineEvent, DataSource, HttpContext);

                        Profile profile = await handler.GetProfile(lineEvent.Source.UserId);

                        switch (lineEvent.Type)
                        {
                            case EventType.Beacon:
                                await handler.HandleBeaconEvent();
                                break;
                            case EventType.Follow:
                                await handler.HandleFollowEvent();
                                break;
                            case EventType.Join:
                                await handler.HandleJoinEvent();
                                break;
                            case EventType.Leave:
                                await handler.HandleLeaveEvent();
                                break;
                            case EventType.Message:
                                Message message = JsonConvert.DeserializeObject<Message>(lineEvent.Message.ToString());
                                switch (message.Type)
                                {
                                    case MessageType.Text:
                                        await handler.HandleTextMessage();
                                        break;
                                    case MessageType.Audio:
                                    case MessageType.Image:
                                    case MessageType.Video:
                                        await handler.HandleMediaMessage();
                                        break;
                                    case MessageType.Sticker:
                                        await handler.HandleStickerMessage();
                                        break;
                                    case MessageType.Location:
                                        await handler.HandleLocationMessage();
                                        break;
                                }
                                break;
                            case EventType.Postback:
                                await handler.HandlePostbackEvent();
                                break;
                            case EventType.Unfollow:
                                await handler.HandleUnfollowEvent();
                                break;
                        }
                    }
                }
            }
            return new EmptyResult();
        }

        public async Task<ActionResult> BindAccountAsync()
        {
            await Request.SaveAsAsync(Path.Combine(FileLogger.Logger.LogDailyPath, "Bind-" + DateTime.Now.Ticks + ".txt"));
            return new EmptyResult();
        }

        private bool validateSignature(byte[] content)
        {
            var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(Startup.Properties["ChannelSecret"]));
            
            var computeHash = hmac.ComputeHash(content);
            var contentHash = Convert.ToBase64String(computeHash);
            var headerHash = Request.Headers["X-Line-Signature"].FirstOrDefault();

            return contentHash == headerHash;
        }

        public ActionResult GetIcon(String id)
        {
            var root = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
            var path = Startup.MapPath("~/images/GitHubIcon/" + id + ".jpg");

            return new PhysicalFileResult(path, "image/png");
        }
        public ActionResult GetMapImage(String id)
        {
            var root = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
            var path = Startup.MapPath("~/images/Map/" + id + ".jpg");

            return new PhysicalFileResult(path, "image/png");
        }

        public ActionResult GetBeyondCoinMap(String id)
        {
            var root = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
            var path = Startup.MapPath($"~/images/Map/BeyondCoin{id}.jpg");

            return new PhysicalFileResult(path, "image/png");
        }

        public ActionResult PushMessage(LineMessageViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            viewModel.Message = viewModel.Message.GetEfficientString();

            if (viewModel.Message == null)
            {
                return Content("Message is empty !");
            }

            var item = models.GetTable<UserProfile>()
                        .Where(u => u.UID == viewModel.UID)
                        .FirstOrDefault();

            if (item == null)
            {
                return Content("User not found !");
            }

            if (item.UserProfileExtension?.LineID != null)
            {
                using (WebClient client = new WebClient())
                {
                    var encoding = new UTF8Encoding(false);
                    client.Headers.Add(HttpRequestHeader.ContentType, "application/json");
                    client.Headers.Add("Authorization", $"Bearer {Startup.Properties["ChannelToken"]}");

                    var jsonData = new
                    {
                        to = item.UserProfileExtension.LineID,
                        messages = new[]
                        {
                            new
                            {
                                type =  "text",
                                text =  viewModel.Message
                            }
                        }
                    };

                    var dataItem = JsonConvert.SerializeObject(jsonData);
                    var result = client.UploadData(Startup.Properties["LinePushMessage"], encoding.GetBytes(dataItem));

                    ApplicationLogging.CreateLogger<LineEventsController>().LogInformation($"push:{dataItem},result:{(result != null ? encoding.GetString(result) : "")}");
                }
            }
            else
            {
                ApplicationLogging.CreateLogger<LineEventsController>().LogWarning($"device without line ID:{item.PID}");
            }

            return Content("OK!");
        }

    }
}