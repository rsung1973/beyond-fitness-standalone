﻿using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

using CommonLib.DataAccess;
//using MessagingToolkit.QRCode.Codec;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Helper.BusinessOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Helper;


namespace WebHome.Helper.MessageOperation
{
    public static class MessageExtensions
    {
        public static void PushLineMessage(this JObject jsonData)
        {
            jsonData.ToString().PushLineMessage();
        }

        public static void PushLineMessage(this String dataItem, bool synchronous = false)
        {
            var t = Task.Run(() =>
            {
                try
                {
                    using (WebClient client = new WebClient())
                    {
                        var encoding = new UTF8Encoding(false);
                        client.Headers.Add(HttpRequestHeader.ContentType, "application/json");
                        client.Headers.Add("Authorization", $"Bearer {WebApp.Properties["ChannelToken"]}");

                        ApplicationLogging.LoggerFactory.CreateLogger(typeof(MessageExtensions))
                            .LogInformation($"push:{dataItem}");

                        var result = client.UploadData(WebApp.Properties["LinePushMessage"], encoding.GetBytes(dataItem));

                        ApplicationLogging.LoggerFactory.CreateLogger(typeof(MessageExtensions))
                            .LogInformation($"push:{dataItem},result:{(result != null ? encoding.GetString(result) : "")}");
                    }
                }
                catch (Exception ex)
                {
                    ApplicationLogging.LoggerFactory.CreateLogger(typeof(MessageExtensions))
                        .LogError(ex, ex.Message);
                }
            });

            if (synchronous) 
            {
                t.Wait();
            }
        }

        //public static JObject CreateLineReadyToSignContract(this CourseContract item, GenericManager<BFDataContext> models)
        //{
        //    //var jsonData = new
        //    //{
        //    //    to = item.ContractOwner.UserProfileExtension.LineID,
        //    //    messages = new[]
        //    //    {
        //    //                new
        //    //                {
        //    //                    type =  "text",
        //    //                    text =  $"{item.CourseContractType.TypeName} 合約內容確認並簽署\r\n👉點這邊，立即簽署合約 {WebApp.Properties["HostDomain"]}{VirtualPathUtility.ToAbsolute("~/CornerKick/Index")}",
        //    //                }
        //    //    }
        //    //};

        //    //return JObject.FromObject(jsonData);

        //    String template = HttpContext.Current.WebApp.MapPath("~/Resource/LineNotifyToSignContract.json");
        //    JObject json = JObject.Parse(File.ReadAllText(template));

        //    json["to"] = item.ContractOwner.UserProfileExtension.LineID;

        //    json["messages"][0]["contents"]["body"]["contents"][0]["contents"][0]["contents"][1]["text"] = item.CourseContractType.TypeName;
        //    if (item.LessonPriceType.BranchStore.IsVirtualClassroom())
        //    {
        //        json["messages"][0]["contents"]["body"]["contents"][0]["contents"][1]["contents"][0]["text"] = "上課場所/簽約分店";
        //        json["messages"][0]["contents"]["body"]["contents"][0]["contents"][1]["contents"][1]["text"] = $"遠距/{item.CourseContractExtension.BranchStore.BranchName}";
        //    }
        //    else
        //    {
        //        json["messages"][0]["contents"]["body"]["contents"][0]["contents"][1]["contents"][0]["text"] = "上課場所";
        //        json["messages"][0]["contents"]["body"]["contents"][0]["contents"][1]["contents"][1]["text"] = item.CourseContractExtension.BranchStore.BranchName;
        //    }
        //    json["messages"][0]["contents"]["body"]["contents"][0]["contents"][2]["contents"][1]["text"] = $"{(item.InstallmentID.HasValue ? item.ContractInstallment.CourseContract.Sum(c => c.Lessons) : (item.Lessons ?? item.LessonPriceType?.ExpandActualLessonCount(models)))}";
        //    json["messages"][0]["contents"]["body"]["contents"][0]["contents"][3]["contents"][1]["text"] = item.ServingCoach.UserProfile.FullName();

        //    String uri = $"{WebApp.Properties["HostDomain"]}{VirtualPathUtility.ToAbsolute("~/CornerKick/ToSignCourseContract")}?KeyID={HttpUtility.UrlEncode(item.ContractID.EncryptKey())}&encUID={HttpUtility.UrlEncode(item.OwnerID.EncryptKey())}";
        //    json["messages"][0]["contents"]["footer"]["contents"][1]["action"]["uri"] = uri;

        //    return json;
        //}

    }
}