using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebHome.Models.Locale;

namespace WebHome.Models.ViewModel
{
    public class ExerciseBillboardQueryViewModel : QueryViewModel
    {
        public int? BranchID { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }

    public class CalendarEventQueryViewModel : UserEventViewModel 
    {
        public int? LessonID { get; set; }
        public String UserName { get; set; }
    }

    public class CalendarEventViewModel : CalendarEventQueryViewModel
    {
    }

}