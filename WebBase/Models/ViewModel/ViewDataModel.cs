using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using Microsoft.AspNetCore.Mvc;

namespace WebHome.Models.ViewModel
{
    public class ViewDataModel
    {
    }

    public class CampaignMissionDataModel
    {
        public String ViewPath { get; set; }
        public object Goal { get; set; }
        public bool CheckResult { get; set; }
        public String MissionID { get; set; }
        public object ResultModel { get; set; }
    }

    public class PromotionAppraisalDataModel
    {
        public GameLevel PromotionLevel { get; set; }
        public bool CheckResult { get; set; }
        public List<CampaignMissionDataModel> Missions { get; set; } = [];
    }
}