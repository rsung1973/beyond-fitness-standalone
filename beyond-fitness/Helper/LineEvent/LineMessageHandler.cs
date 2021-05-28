using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using LineMessagingAPISDK;
using LineMessagingAPISDK.Models;
using Newtonsoft.Json;
using WebHome.Properties;
using WebHome.Models.ViewModel;
using WebHome.Models.DataEntity;
using WebHome.Helper;

namespace WebHome.Helper.LineEvent
{
    public class LineMessageHandler
    {
        public const String __SLOGAN = @"謝謝您訊息我們喔 😊

若有問題需要個別回覆 , 
歡迎直接聯繫我們  😄

📍信義安和店 
02-27200530 
 
📍南京店 （小巨蛋旁）
02-2715-2733 
 
📍忠孝店 （忠孝復興旁）
02-2776-9932

📍東門店
02-2396-0776

若不方便也請來信公司信箱或是FB訊息，也能精確地幫助您解決問題喔 .


祝您有個美好的一天😊";

        private Event lineEvent;
        private LineClient lineClient = new LineClient(Settings.Default.ChannelToken);

        public LineMessageHandler(Event lineEvent,ModelSource<UserProfile> models)
        {
            this.lineEvent = lineEvent;
            this.models = models;
        }

        public Profile CurrentProfile
        {
            get;
            private set;
        }

        private ModelSource<UserProfile> models;

        public async Task HandleBeaconEvent()
        {
            await Reply(new TextMessage(__SLOGAN));
        }

        public async Task HandleFollowEvent()
        {
            await Reply(new TextMessage(__SLOGAN));
        }

        public async Task HandleJoinEvent()
        {
            await Reply(new TextMessage(__SLOGAN));
        }

        public async Task HandleLeaveEvent()
        {
            await Reply(new TextMessage(__SLOGAN));
        }

        public async Task HandlePostbackEvent()
        {
            string reply;
            // Handle DateTimePicker postback
            if (lineEvent.Postback?.Params != null)
            {
                var dateTime = lineEvent.Postback?.Params;
                reply = $"DateTime: {dateTime.DateTime}, Date: {dateTime.Date}, Time: {dateTime.Time}";
            }
            else
            {
                reply = lineEvent.Postback.Data;
            }
            await Reply(new TextMessage(reply));
        }

        public async Task HandleUnfollowEvent()
        {
            await Reply(new TextMessage(__SLOGAN));
        }

        public async Task<Profile> GetProfile(string mid)
        {
            CurrentProfile = await lineClient.GetProfile(mid);
            //return await lineClient.GetProfile(mid);
            return CurrentProfile;
        }

        public async Task HandleTextMessage()
        {
            var textMessage = JsonConvert.DeserializeObject<TextMessage>(lineEvent.Message.ToString());
            Message replyMessage = null;
            var message = textMessage.Text.ToLower().Trim();
            //if (message == "buttons")
            //{
            //    List<TemplateAction> actions = new List<TemplateAction>();
            //    actions.Add(new MessageTemplateAction("Message Label", "sample data"));
            //    actions.Add(new PostbackTemplateAction("Postback Label", "sample data", "sample data"));
            //    actions.Add(new UriTemplateAction("Uri Label", "https://github.com/kenakamu"));
            //    ButtonsTemplate buttonsTemplate = new ButtonsTemplate("https://github.com/apple-touch-icon.png", "Sample Title", "Sample Text", actions);

            //    replyMessage = new TemplateMessage("Buttons", buttonsTemplate);
            //}
            //else 
            if (message == "個人化" || message.Contains("專屬服務") || message.Contains("會員專屬服務，查詢快速又簡單"))
            {
                var url = HttpContext.Current.Request.Url;
                var imageUrl = $"{url.Scheme}://{url.Host}:{url.Port}/LineEvents/GetMapImage";
                List<ImageMapAction> actions = new List<ImageMapAction>();
                actions.Add(new UriImageMapAction($"{url.Scheme}://{url.Host}:{url.Port}{VirtualPathUtility.ToAbsolute("~/CornerKick/Index")}?X001={CurrentProfile.UserId}", new ImageMapArea(375, 0, 325, 1040)));
                actions.Add(new UriImageMapAction($"{url.Scheme}://{url.Host}:{url.Port}{VirtualPathUtility.ToAbsolute("~/CornerKick/TodayLesson")}?X001={CurrentProfile.UserId}", new ImageMapArea(0, 0, 375, 590)));
                actions.Add(new UriImageMapAction($"{url.Scheme}://{url.Host}:{url.Port}{VirtualPathUtility.ToAbsolute("~/CornerKick/Notice")}?X001={CurrentProfile.UserId}", new ImageMapArea(0, 590, 375, 450)));
                actions.Add(new UriImageMapAction($"{url.Scheme}://{url.Host}:{url.Port}{VirtualPathUtility.ToAbsolute("~/CornerKick/CheckBonusPointByLine")}?X001={CurrentProfile.UserId}", new ImageMapArea(700, 0, 350, 590)));
                actions.Add(new UriImageMapAction($"{url.Scheme}://{url.Host}:{url.Port}{VirtualPathUtility.ToAbsolute("~/CornerKick/CheckAttendance")}?X001={CurrentProfile.UserId}", new ImageMapArea(700, 590, 350, 450)));
                //actions.Add(new MessageImageMapAction("I love LINE!", new ImageMapArea(520, 0, 520, 1040)));
                replyMessage = new ImageMapMessage(imageUrl, "會員專屬服務，查詢快速又簡單", new BaseSize(1040, 1040), actions);
            }
            else if (message.Contains("帳號串連即可獲得beyond幣") || message.Contains("帳號串連") 
                || message.Contains("beyond幣") || message.Contains("帳號beyond幣") || message.Contains("帳號活動"))
            {
                var url = HttpContext.Current.Request.Url;
                var imageUrl = $"{url.Scheme}://{url.Host}:{url.Port}/LineEvents/GetBeyondCoinMap";
                List<ImageMapAction> actions = new List<ImageMapAction>();
                actions.Add(new UriImageMapAction($"{url.Scheme}://{url.Host}:{url.Port}{VirtualPathUtility.ToAbsolute("~/CornerKick/Index")}?X001={CurrentProfile.UserId}", new ImageMapArea(0, 0, 1040, 1040)));
                replyMessage = new ImageMapMessage(imageUrl, "會員專屬服務，查詢快速又簡單", new BaseSize(1040, 1040), actions);
            }
            else if (message == "check" || message == "打卡")
            {

                var item = models.GetTable<UserProfileExtension>().Where(u => u.LineID == CurrentProfile.UserId)
                        .Select(u => u.UserProfile).FirstOrDefault();
                if (item == null)
                {
                    List<TemplateAction> actions = new List<TemplateAction>();
                    ButtonsTemplate buttonsTemplate = new ButtonsTemplate();

                    buttonsTemplate.Title = "此支裝置尚未設定過專屬服務";
                    buttonsTemplate.Text = "請點選下方更多資訊/專屬服務/帳號設定才可使用！";
                    actions.Add(new UriTemplateAction("帳號設定", $"{ Settings.Default.HostDomain }{ VirtualPathUtility.ToAbsolute("~/CornerKick/Register")}?X001={ CurrentProfile.UserId}"));
                    buttonsTemplate.Actions = actions;
                    replyMessage = new TemplateMessage("上課打卡", buttonsTemplate);
                }
                else
                {
                    var checkAttendance = item.CheckLessonAttendanceEvent(models);
                    if (checkAttendance == null)
                    {
                        replyMessage = new TextMessage($"{(item.UserProfileExtension.Gender == "F" ? "親愛的" : "兄弟")}, 目前課程都有確實打卡喔！");
                    }
                    else
                    {
                        List<TemplateAction> actions = new List<TemplateAction>();
                        ButtonsTemplate buttonsTemplate = new ButtonsTemplate();

                        buttonsTemplate.Title = item.UserProfileExtension.Gender == "F" ? "親愛的" : "兄弟";
                        buttonsTemplate.Text = $"還有{checkAttendance.CheckCount}堂課沒打卡";
                        actions.Add(new UriTemplateAction("👉立即打卡", $"{Settings.Default.HostDomain}{VirtualPathUtility.ToAbsolute("~/CornerKick/CheckAttendance")}?X001={CurrentProfile.UserId}"));
                        buttonsTemplate.Actions = actions;
                        replyMessage = new TemplateMessage("上課打卡", buttonsTemplate);
                    }
                }

            }
            //else if (textMessage.Text.ToLower() == "confirm")
            //{
            //    List<TemplateAction> actions = new List<TemplateAction>();
            //    actions.Add(new MessageTemplateAction("Yes", "yes"));
            //    actions.Add(new MessageTemplateAction("No", "no"));
            //    ConfirmTemplate confirmTemplate = new ConfirmTemplate("Confirm Test", actions);
            //    replyMessage = new TemplateMessage("Confirm", confirmTemplate);
            //}
            //else if (textMessage.Text.ToLower() == "carousel")
            //{
            //    List<TemplateColumn> columns = new List<TemplateColumn>();
            //    List<TemplateAction> actions1 = new List<TemplateAction>();
            //    List<TemplateAction> actions2 = new List<TemplateAction>();

            //    // Add actions.
            //    actions1.Add(new MessageTemplateAction("Message Label", "sample data"));
            //    actions1.Add(new PostbackTemplateAction("Postback Label", "sample data", "sample data"));
            //    actions1.Add(new UriTemplateAction("Uri Label", "https://github.com/kenakamu"));

            //    // Add datetime picker actions
            //    actions2.Add(new DatetimePickerTemplateAction("DateTime Picker", "DateTime", DatetimePickerMode.Datetime, "2017-07-21T13:00"));
            //    actions2.Add(new DatetimePickerTemplateAction("Date Picker", "Date", DatetimePickerMode.Date, "2017-07-21"));
            //    actions2.Add(new DatetimePickerTemplateAction("Time Picker", "Time", DatetimePickerMode.Time, "13:00"));

            //    columns.Add(new TemplateColumn() { Title = "Casousel 1 Title", Text = "Casousel 1 Text", ThumbnailImageUrl = "https://github.com/apple-touch-icon.png", Actions = actions1 });
            //    columns.Add(new TemplateColumn() { Title = "Casousel 2 Title", Text = "Casousel 2 Text", ThumbnailImageUrl = "https://github.com/apple-touch-icon.png", Actions = actions2 });
            //    CarouselTemplate carouselTemplate = new CarouselTemplate(columns);
            //    replyMessage = new TemplateMessage("Carousel", carouselTemplate);
            //}
            //else if (textMessage.Text.ToLower() == "imagecarousel")
            //{
            //    List<ImageColumn> columns = new List<ImageColumn>();
            //    UriTemplateAction action = new UriTemplateAction("Uri Label", "https://github.com/kenakamu");

            //    columns.Add(new ImageColumn("https://github.com/apple-touch-icon.png", action));
            //    columns.Add(new ImageColumn("https://github.com/apple-touch-icon.png", action));
            //    columns.Add(new ImageColumn("https://github.com/apple-touch-icon.png", action));
            //    columns.Add(new ImageColumn("https://github.com/apple-touch-icon.png", action));
            //    columns.Add(new ImageColumn("https://github.com/apple-touch-icon.png", action));

            //    ImageCarouselTemplate carouselTemplate = new ImageCarouselTemplate(columns);

            //    replyMessage = new TemplateMessage("Carousel", carouselTemplate);
            //}
            //else if (textMessage.Text.ToLower() == "imagemap")
            //{
            //    var url = HttpContext.Current.Request.Url;
            //    var imageUrl = $"{url.Scheme}://{url.Host}:{url.Port}/LineEvents/GetIcon";
            //    List<ImageMapAction> actions = new List<ImageMapAction>();
            //    actions.Add(new UriImageMapAction($"{Settings.Default.HostDomain}{VirtualPathUtility.ToAbsolute("~/CornerKick/Index")}?lineID={CurrentProfile.UserId}", new ImageMapArea(0, 0, 520, 1040)));
            //    actions.Add(new MessageImageMapAction("I love LINE!", new ImageMapArea(520, 0, 520, 1040)));
            //    replyMessage = new ImageMapMessage(imageUrl, "GitHub", new BaseSize(1040, 1040), actions);
            //}
            //else if (textMessage.Text.ToLower() == "addrichmenu")
            //{
            //    // Create Rich Menu
            //    RichMenu richMenu = new RichMenu()
            //    {
            //        Size = new RichMenuSize(1686),
            //        Selected = false,
            //        Name = "nice richmenu",
            //        ChatBarText = "touch me",
            //        Areas = new List<RichMenuArea>()
            //            {
            //                new RichMenuArea()
            //                {
            //                    Action = new PostbackTemplateAction("action=buy&itemid=123"),
            //                    Bounds = new RichMenuBounds(0, 0, 2500, 1686)
            //                }
            //            }
            //    };


            //    var richMenuId = await lineClient.CreateRichMenu(richMenu);
            //    var image = new MemoryStream(File.ReadAllBytes(HttpContext.Current.Server.MapPath(@"~\Images\richmenu.PNG")));
            //    // Upload Image
            //    await lineClient.UploadRichMenuImage(richMenuId, image);
            //    // Link to user
            //    await lineClient.LinkRichMenuToUser(lineEvent.Source.UserId, richMenuId);
            //}
            //else if (textMessage.Text.ToLower() == "deleterichmenu")
            //{
            //    // Get Rich Menu for the user
            //    var richMenuId = await lineClient.GetRichMenuIdForUser(lineEvent.Source.UserId);

            //    await lineClient.UnlinkRichMenuToUser(lineEvent.Source.UserId);
            //    await lineClient.DeleteRichMenu(richMenuId);
            //}
            //else if (textMessage.Text.ToLower() == "deleteallrichmenu")
            //{
            //    // Get Rich Menu for the user
            //    var richMenuList = await lineClient.GetRichMenuList();
            //    foreach (var richMenu in richMenuList)
            //    {
            //        await lineClient.DeleteRichMenu(richMenu["richMenuId"].ToString());
            //    }
            //}
            else if (message == "劉加菲" || message == "garfaild")
            {
                //replyMessage = new TextMessage("($_$)");
                replyMessage = new StickerMessage("3", "256");
            }
            else if (message == "笨小胖")
            {
                replyMessage = new StickerMessage("2", "43");
            }
            else
            {
                replyMessage = new TextMessage(__SLOGAN);
            }

            if (replyMessage != null)
                await Reply(replyMessage);
        }

        public async Task HandleMediaMessage()
        {
            //Message message = JsonConvert.DeserializeObject<Message>(lineEvent.Message.ToString());
            //// Get media from Line server.
            //Media media = await lineClient.GetContent(message.Id);
            //Message replyMessage = null;

            //// Reply Image 
            //switch (message.Type)
            //{
            //    case MessageType.Image:
            //    case MessageType.Video:
            //    case MessageType.Audio:
            //        replyMessage = new ImageMessage("https://github.com/apple-touch-icon.png", "https://github.com/apple-touch-icon.png");
            //        break;
            //}

            //await Reply(replyMessage);
            await Reply(new TextMessage(__SLOGAN));

        }

        public async Task HandleStickerMessage()
        {
            ////https://devdocs.line.me/files/sticker_list.pdf
            //var stickerMessage = JsonConvert.DeserializeObject<StickerMessage>(lineEvent.Message.ToString());
            //var replyMessage = new StickerMessage("1", "1");
            //await Reply(replyMessage);
            await Reply(new TextMessage(__SLOGAN));
        }

        public async Task HandleLocationMessage()
        {
            var locationMessage = JsonConvert.DeserializeObject<LocationMessage>(lineEvent.Message.ToString());
            LocationMessage replyMessage = new LocationMessage(
                locationMessage.Title,
                locationMessage.Address,
                locationMessage.Latitude,
                locationMessage.Longitude);
            await Reply(replyMessage);
        }

        private async Task Reply(Message replyMessage)
        {
            try
            {
                await lineClient.ReplyToActivityAsync(lineEvent.CreateReply(message: replyMessage));
            }
            catch
            {
                await lineClient.PushAsync(lineEvent.CreatePush(message: replyMessage));
            }
        }
    }

}