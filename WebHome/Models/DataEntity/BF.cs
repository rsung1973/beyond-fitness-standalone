namespace WebHome.Models.DataEntity
{
    partial class BFDataContext
    {
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
}