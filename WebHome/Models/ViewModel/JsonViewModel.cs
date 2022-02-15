using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebHome.Models.ViewModel
{
    public class JsonViewModel
    {

    }

    public class BranchJsonViewModel
    {
        public String branchName { get; set; }
        public int? unit { get; set; }
    }

    public class CalendarEvent
    {
        public String id { get; set; }
        public String title { get; set; }
        public String start { get; set; }
        public String end { get; set; }
        public String description { get; set; }
        public bool allDay { get; set; }
        public String[] className { get; set; }
        public String icon { get; set; }
        public int? lessonID { get; set; }
        public bool editable { get; set; }
        public String keyID { get; set; }
        public int? learnerID { get; set; }
             
    }

    public class CalendarEventItem
    {
        private DateTime? eventTime;

        public DateTime? EventTime { get => eventTime?.CurrentLocalTime(); set => eventTime = value; }
        public Object EventItem { get; set; }
    }

    public class CoachItem
    {
        public string coachName { get; set; }
        public string nickname { get; set; }
        public string prologue { get; set; }
        public List<string> scenarioPhoto { get; set; }
    }

    public class CoachData
    {
        public string branchName { get; set; }
        public string arenaView { get; set; }
        public List<string> scenarioPhoto { get; set; }
        public List<CoachItem> coachItems { get; set; }
    }

    public class PriceItem
    {
        public string priceName { get; set; }
        public string price { get; set; }
        public string desc { get; set; }
        public bool? promote { get; set; }
    }

    public class DurationItem
    {
        public int? unit { get; set; }
        public List<PriceItem> priceItems { get; set; }
    }

    public class PricingData
    {
        public string branchName { get; set; }
        public List<DurationItem> durationItems { get; set; }
    }

}