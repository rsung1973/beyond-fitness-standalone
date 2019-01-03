using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebHome.Models.ViewModel
{
    public class JsonViewModel
    {

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
             
    }

    public class CalendarEventItem
    {
        public DateTime? EventTime { get; set; }
        public Object EventItem { get; set; }
    }

}