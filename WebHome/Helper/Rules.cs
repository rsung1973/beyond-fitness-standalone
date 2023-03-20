using WebHome.Models.Locale;

namespace WebHome.Helper
{
    public static partial class BusinessConsoleExtensions
    {
        public static readonly int?[] SessionScopeForAchievement = new int?[]
                    {
                        (int)Naming.LessonPriceStatus.一般課程,
                        (int)Naming.LessonPriceStatus.已刪除,
                        (int)Naming.LessonPriceStatus.團體學員課程,
                    };

        public static readonly int?[] SessionScopeForComleteLessonCount = new int?[]
        {
                    (int)Naming.LessonPriceStatus.一般課程,
                    (int)Naming.LessonPriceStatus.已刪除,
                    (int)Naming.LessonPriceStatus.點數兌換課程,
                    (int)Naming.LessonPriceStatus.員工福利課程,
                    (int)Naming.LessonPriceStatus.團體學員課程,
        };

        public static readonly int?[] SessionScopeForAveragePrice = new int?[]
        {
                    (int)Naming.LessonPriceStatus.一般課程,
                    (int)Naming.LessonPriceStatus.已刪除,
                    (int)Naming.LessonPriceStatus.點數兌換課程,
                    (int)Naming.LessonPriceStatus.員工福利課程,
                    (int)Naming.LessonPriceStatus.團體學員課程,
                    (int)Naming.LessonPriceStatus.運動恢復課程,
                    (int)Naming.LessonPriceStatus.運動防護課程,
                    (int)Naming.LessonPriceStatus.營養課程,
        };

        public static readonly int?[] HSSessionScope = new int?[]
        {
                    (int)Naming.LessonPriceStatus.運動恢復課程,
                    (int)Naming.LessonPriceStatus.運動防護課程,
                    (int)Naming.LessonPriceStatus.營養課程,
        };
    }
}
