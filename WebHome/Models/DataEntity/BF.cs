namespace WebHome.Models.DataEntity
{
    public partial class BFDataContext
    {
        public BFDataContext() :
            base(global::WebHome.Properties.Settings.Default.BFDbConnection, mappingSource)
        {
            OnCreated();
        }

        partial void OnCreated()
        {
            this.CommandTimeout = 300;
        }

    }

    public partial class QuestionnaireRequest
    {
        public enum PartIDEnum
        {
            PartA = 0,
            PartB = 1,
        }
    }

    public partial class MonthlySalary
    {
        public enum SalaryTypeEnum
        {
            RegularPay = 1,
            Additional = 2,
            AnnualBonus = 3,
        }
    }

    public interface ISalary
    {
        int? AchievementBonus { get; set; }
        decimal? AchievementShareRatio { get; set; }
        int? AttendanceBonus { get; set; }
        int CoachID { get; set; }
        decimal GradeIndex { get; set; }
        int LevelID { get; set; }
        int? ManagerBonus { get; set; }
        int? SpecialBonus { get; set; }
    }

    public partial class CoachMonthlySalary : ISalary
    {

    }

    public partial class CoachYearlyAdditionalPay : ISalary
    {

    }

}