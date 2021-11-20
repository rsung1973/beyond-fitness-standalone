using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebHome.Models.DataEntity;
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

    public class GlobalStaticViewModel
    {
        private static GlobalStaticViewModel __Instance = new GlobalStaticViewModel { };

        private GlobalStaticViewModel()
        { }

        public Article ArticleItem { get; set; }

        public long Expiration { get; set; } = 0;

        public LessonTime LessonTimeItem { get; set; }

        public long LessonTimeExpiration { get; set; } = 0;


        public static GlobalStaticViewModel Instance
        {
            get => __Instance;
        }

    }

}