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
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Security;

using CommonLib.MvcExtension;
using LineMessagingAPISDK.Models;
using Newtonsoft.Json;
using Utility;
using WebHome.Helper;
using WebHome.Helper.LineEvent;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    public class LineEventsController : SampleController<UserProfile>
    {
        // GET: LineEvents
        public async Task<ActionResult> Index(/*[FromBody]String content*/)
        {
            Request.SaveAs(Path.Combine(Logger.LogDailyPath, "LineEvents-" + DateTime.Now.Ticks + ".txt"), true);

            if (Request.ContentLength > 0)
            {
                byte[] content = new byte[Request.ContentLength];
                Request.InputStream.Read(content, 0, Request.ContentLength);
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

                        LineMessageHandler handler = new LineMessageHandler(lineEvent, models);

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

        public ActionResult BindAccount()
        {
            Request.SaveAs(Path.Combine(Logger.LogDailyPath, "Bind-" + DateTime.Now.Ticks + ".txt"), true);
            return new EmptyResult();
        }

        private bool validateSignature(byte[] content)
        {
            var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(Settings.Default.ChannelSecret));
            
            var computeHash = hmac.ComputeHash(content);
            var contentHash = Convert.ToBase64String(computeHash);
            var headerHash = Request.Headers.GetValues("X-Line-Signature").First();

            return contentHash == headerHash;
        }

        public async Task<ActionResult> GetIcon(String id)
        {
            var root = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
            var path = Server.MapPath("~/images/GitHubIcon/" + id + ".jpg");

            return File(path, "image/png");
        }
        public async Task<ActionResult> GetMapImage(String id)
        {
            var root = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
            var path = Server.MapPath("~/images/Map/" + id + ".jpg");

            return File(path, "image/png");
        }

        public async Task<ActionResult> GetBeyondCoinMap(String id)
        {
            var root = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
            var path = Server.MapPath($"~/images/Map/BeyondCoin{id}.jpg");

            return File(path, "image/png");
        }
    }
}