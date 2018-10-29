using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebHome.Models.DataEntity;

namespace WebHome.Models.Timeline
{
    public class TimelineEvent
    {
        public DateTime? EventTime { get; set; }
        public UserProfile Profile { get; set; }
    }

    public class LessonEvent : TimelineEvent
    {
        public LessonTime Lesson { get; set; }
    }

    public class BirthdayEvent : TimelineEvent
    {

    }

    public class LearnerMonthlyReviewEvent : TimelineEvent
    {

    }

    public class QuestionnaireRequestEvent : TimelineEvent
    {
        public QuestionnaireRequest Questionnaire { get; set; }
    }

    public class LessonAttendanceCheckEvent : TimelineEvent
    {
        public int CheckCount { get; set; }
    }

    public class DailyQuestionEvent : TimelineEvent
    {
        public PDQQuestion DailyQuestion { get; set; }
    }

    public class UserGuideEvent : TimelineEvent
    {
        public IQueryable<UserEvent> GuideEventList { get; set; }
    }

    public class ExpiringContractEvent : TimelineEvent
    {
        public CourseContract ExpiringContract { get; set; }
    }

    public class PromptContractEvent : TimelineEvent
    {
        public IQueryable<CourseContract> ContractList { get; set; }
    }

    public class PersonalExercisePurposeEvent : TimelineEvent
    {
        public IQueryable<PersonalExercisePurposeItem> PurposeItemEventList { get; set; }
    }

    public class PersonalExercisePurposeAccomplishedEvent : PersonalExercisePurposeEvent
    {

    }



}