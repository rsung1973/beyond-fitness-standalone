using CommonLib.DataAccess;
using System.Linq;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;

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

        public static IQueryable<V_Tuition> SessionScopeForComleteLesson(this IQueryable<V_Tuition> items, GenericManager<BFDataContext> models)
        {
            return items.Where(v => models.PromptComleteLessonPrice()
                                        .Where(p => p.PriceID == v.PriceID)
                                        .Any());
        }

        public static IQueryable<V_Tuition> SRSessionScope(this IQueryable<V_Tuition> items, GenericManager<BFDataContext> models)
        {
            return items.Where(v => models.PromptSRLessonPrice()
                                        .Where(p => p.PriceID == v.PriceID)
                                        .Any());
        }

        public static IQueryable<LessonPriceType> PromptComleteLessonPrice(this GenericManager<BFDataContext> models)
        {
            var priceItems = models.GetTable<LessonPriceType>()
                                            .Where(p => SessionScopeForComleteLessonCount.Contains(p.Status))
                                            .Where(p => !p.LessonPriceProperty.Any(t => t.PropertyID == (int)Naming.LessonPriceFeature.運動恢復課程));

            return priceItems;
        }

        public static IQueryable<LessonPriceType> PromptSRLessonPrice(this GenericManager<BFDataContext> models)
        {
            var priceItems = models.GetTable<LessonPriceType>()
                                            .Where(p => p.Status == (int)Naming.LessonPriceStatus.運動恢復課程
                                                    || (p.Status == (int)Naming.LessonPriceStatus.點數兌換課程 
                                                        && p.LessonPriceProperty.Any(t => t.PropertyID == (int)Naming.LessonPriceFeature.運動恢復課程)));

            return priceItems;
        }

        public static IEnumerable<V_Tuition> SessionScopeForComleteLesson(this IEnumerable<V_Tuition> items, GenericManager<BFDataContext> models)
        {
            return items.Where(v => models.PromptComleteLessonPrice()
                                        .Where(p => p.PriceID == v.PriceID)
                                        .Any());
        }


        private static readonly int?[] SessionScopeForComleteLessonCount = new int?[]
        {
                    (int)Naming.LessonPriceStatus.一般課程,
                    (int)Naming.LessonPriceStatus.已刪除,
                    (int)Naming.LessonPriceStatus.點數兌換課程,
                    (int)Naming.LessonPriceStatus.員工福利課程,
                    (int)Naming.LessonPriceStatus.團體學員課程,
        };

        public static readonly int?[] GeneralPTSessionScope = new int?[]
        {
                    (int)Naming.LessonPriceStatus.一般課程,
                    (int)Naming.LessonPriceStatus.已刪除,
                    (int)Naming.LessonPriceStatus.點數兌換課程,
                    (int)Naming.LessonPriceStatus.員工福利課程,
                    (int)Naming.LessonPriceStatus.團體學員課程,
                    (int)Naming.LessonPriceStatus.運動恢復課程,
                    (int)Naming.LessonPriceStatus.運動防護課程,
                    //(int)Naming.LessonPriceStatus.營養課程,   //Cami 為PT兼SD，SD課暫不計入 2024/3/31
        };

        public static readonly int?[] HSSessionScope = new int?[]
        {
                    (int)Naming.LessonPriceStatus.運動恢復課程,
                    (int)Naming.LessonPriceStatus.運動防護課程,
                    (int)Naming.LessonPriceStatus.營養課程,
        };

        public static readonly int?[] SessionScopeForSelfAssessment=
        [
                    (int)Naming.LessonPriceStatus.一般課程,
                    (int)Naming.LessonPriceStatus.已刪除,
                    (int)Naming.LessonPriceStatus.點數兌換課程,
                    (int)Naming.LessonPriceStatus.員工福利課程,
                    (int)Naming.LessonPriceStatus.團體學員課程,
                    (int)Naming.LessonPriceStatus.自主訓練,
        ];
    }
}
