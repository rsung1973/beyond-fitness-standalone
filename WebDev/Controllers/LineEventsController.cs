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
using DocumentFormat.OpenXml.Spreadsheet;
using Newtonsoft.Json.Linq;
using System.Net.Http.Headers;
using System.Net.Http;

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

                        LineMessageHandler handler = new LineMessageHandler(lineEvent, this);

                        Profile profile = await handler.GetProfile(lineEvent.Source.UserId);

                        switch (lineEvent.Type)
                        {
                            case EventType.Beacon:
                                //await handler.HandleBeaconEvent();
                                break;
                            case EventType.Follow:
                                //await handler.HandleFollowEvent();
                                break;
                            case EventType.Join:
                                //await handler.HandleJoinEvent();
                                break;
                            case EventType.Leave:
                                //await handler.HandleLeaveEvent();
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
                                        //await handler.HandleMediaMessage();
                                        break;
                                    case MessageType.Sticker:
                                        //await handler.HandleStickerMessage();
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
                                //await handler.HandleUnfollowEvent();
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
            var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(WebApp.Properties["ChannelSecret"]));
            
            var computeHash = hmac.ComputeHash(content);
            var contentHash = Convert.ToBase64String(computeHash);
            var headerHash = Request.Headers["X-Line-Signature"].FirstOrDefault();

            return contentHash == headerHash;
        }

        public ActionResult GetIcon(String id)
        {
            var root = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
            var path = WebApp.MapPath("~/images/GitHubIcon/" + id + ".jpg");

            return new PhysicalFileResult(path, "image/png");
        }
        public ActionResult GetMapImage(String id)
        {
            var root = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
            var path = WebApp.MapPath("~/images/Map/" + id + ".jpg");

            return new PhysicalFileResult(path, "image/png");
        }
        public ActionResult GetMapMenuImage(String id)
        {
            var root = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
            var path = WebApp.MapPath($"~/LearnerActivity/images/lineevent/map/mapmenu-{id}.png");

            return new PhysicalFileResult(path, "image/png");
        }        

        public ActionResult GetBeyondCoinMap(String id)
        {
            var root = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
            var path = WebApp.MapPath($"~/images/Map/BeyondCoin{id}.jpg");

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
                    client.Headers.Add("Authorization", $"Bearer {WebApp.Properties["ChannelToken"]}");

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
                    var result = client.UploadData(WebApp.Properties["LinePushMessage"], encoding.GetBytes(dataItem));

                    ApplicationLogging.CreateLogger<LineEventsController>().LogInformation($"push:{dataItem},result:{(result != null ? encoding.GetString(result) : "")}");
                }
            }
            else
            {
                ApplicationLogging.CreateLogger<LineEventsController>().LogWarning($"device without line ID:{item.PID}");
            }

            return Content("OK!");
        }

        public async Task<ActionResult> PushPINAsync()
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Content("User not found !");
            }

            String linePIN = $"{DateTime.Now.Ticks % 1000000:000000}";
            profile = profile.LoadInstance(models);
            profile.UserProfileExtension.PIN = linePIN;
            profile.UserProfileExtension.PINExpiration = DateTime.Now.AddMinutes(5);
            models.SubmitChanges();

            var item = profile.LoadInstance(models);
            if (item.UserProfileExtension?.LineID != null)
            {
                using (WebClient client = new WebClient())
                {
                    var encoding = new UTF8Encoding(false);
                    client.Headers.Add(HttpRequestHeader.ContentType, "application/json");
                    client.Headers.Add("Authorization", $"Bearer {WebApp.Properties["ChannelToken"]}");

                    var jsonData = new
                    {
                        to = item.UserProfileExtension.LineID,
                        messages = new[]
                        {
                            new
                            {
                                type =  "text",
                                text =  $"通關密碼：{linePIN}"
                            }
                        }
                    };

                    var dataItem = JsonConvert.SerializeObject(jsonData);
                    var result = client.UploadData(WebApp.Properties["LinePushMessage"], encoding.GetBytes(dataItem));

                    ApplicationLogging.CreateLogger<LineEventsController>().LogInformation($"push:{dataItem},result:{(result != null ? encoding.GetString(result) : "")}");
                }
            }
            else
            {
                ApplicationLogging.CreateLogger<LineEventsController>().LogWarning($"device without line ID:{item.PID}");
            }

            return Content("OK!");
        }

        public async Task<ActionResult> AuthAsync(UserProfileViewModel viewModel)
        {
            await Request.SaveAsAsync(Path.Combine(FileLogger.Logger.LogDailyPath, $"{DateTime.Now.Ticks}.txt"), true);
            string authorizationCode = viewModel.Code.GetEfficientString();

            if (authorizationCode == null)
            {
                return RedirectToAction("Login", "LearnerActivity");
            }

            using (var httpClient = new HttpClient())
            {
                httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", AppSettings.Default.LineAuth.ChannelSecret);
                var content = new FormUrlEncodedContent(new[]
                {
                    new KeyValuePair<string, string>("grant_type", "authorization_code"),
                    new KeyValuePair<string, string>("code", authorizationCode),
                    new KeyValuePair<string, string>("redirect_uri", AppSettings.Default.LineAuth.ReturnUrl),
                    new KeyValuePair<string, string>("client_id", AppSettings.Default.LineAuth.ChannelID),
                    new KeyValuePair<string, string>("client_secret", AppSettings.Default.LineAuth.ChannelSecret)
                });

                var response = await httpClient.PostAsync("https://api.line.me/oauth2/v2.1/token", content);
                var responseContent = await response.Content.ReadAsStringAsync();

                FileLogger.Logger.Debug(responseContent);
                // 解析回應，取得存取權杖和其他資訊
                // 這裡你可以根據回應的內容進行使用者登入驗證的邏輯

                if (response.IsSuccessStatusCode && responseContent != null)
                {
                    JObject token = JObject.Parse(responseContent);
                    // 登入驗證成功的處理
                    content = new FormUrlEncodedContent(new[]
                    {
                        new KeyValuePair<string, string>("id_token", token["id_token"]!.ToString()),
                        new KeyValuePair<string, string>("client_id", AppSettings.Default.LineAuth.ChannelID),
                    });

                    response = await httpClient.PostAsync("https://api.line.me/oauth2/v2.1/verify", content);
                    responseContent = await response.Content.ReadAsStringAsync();

                    FileLogger.Logger.Debug(responseContent);

                    if (response.IsSuccessStatusCode && responseContent != null)
                    {
                        token = JObject.Parse(responseContent);
                        var lineID = token?["sub"];
                        if (lineID != null)
                        {
                            var profile = await HttpContext.GetUserAsync();
                            if (profile?.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                            {
                                profile = profile.LoadInstance(models);
                                if (models.GetTable<UserProfileExtension>()
                                        .Where(u => u.LineID == (string)lineID)
                                        .Where(u => u.UID != profile.UID)
                                        .Any())
                                {
                                    return RedirectToAction("Settings", "LearnerActivity",new { AlertMessage = "帳號已綁定其他帳號[XA007]，請聯繫您的專屬顧問！"});
                                }
                                else
                                {
                                    profile.UserProfileExtension.LineID = (string)lineID;
                                    models.SubmitChanges();
                                    return RedirectToAction("Settings", "LearnerActivity");
                                }
                            }

                            var user = models.GetTable<UserProfileExtension>().Where(m => m.LineID == (string)lineID!)
                                            .FirstOrDefault()?.UserProfile;
                            if (user != null)
                            {
                                return RedirectToAction("SignOn", "LearnerActivity", new { KeyID = user.UID.EncryptKey() });
                            }
                            else
                            {
                                return RedirectToAction("ActivateAccount", "LearnerActivity", new { EncLineID = ((string)lineID).EncryptKey() });
                            }
                        }
                    }
                }
                else
                {
                    // 登入驗證失敗的處理
                    return RedirectToAction("Login", "LearnerActivity");
                }
            }
            return RedirectToAction("Login", "LearnerActivity");
        }


    }
}