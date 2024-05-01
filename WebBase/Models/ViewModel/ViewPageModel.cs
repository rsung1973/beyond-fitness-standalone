using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;

namespace WebHome.Models.ViewModel
{
    public class ViewPageModel
    {
    }

    public class BookingLessonPageModel
    {
        public bool HasChoice { get; set; }
        public bool PDQStatus { get; set; }
        public bool GroupComplete { get; set; }
        public bool QuestionnaireStatus { get; set; }
    }
}