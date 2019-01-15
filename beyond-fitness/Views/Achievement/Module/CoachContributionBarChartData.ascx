<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%= JsonConvert.SerializeObject(result) %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<TuitionAchievement> _model;
    AchievementQueryViewModel _viewModel;
    Object result;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<TuitionAchievement>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;

        var coaches = models.GetTable<UserProfile>().Where(u => _viewModel.ByCoachID.Contains(u.UID));
        var coachID = coaches.Select(u => u.UID).ToArray();

        var contractItems = _model.Where(t => t.Payment.ContractPayment != null);
        var newContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == false);
        var renewalContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == true
                                    || !t.Payment.ContractPayment.CourseContract.Renewal.HasValue);
        var piSessionItems = _model.Where(t => t.Payment.TransactionType == (int)Naming.PaymentTransactionType.自主訓練);
        var otherItems = _model.Where(t => t.Payment.TransactionType != (int)Naming.PaymentTransactionType.體能顧問費
                                        && t.Payment.TransactionType != (int)Naming.PaymentTransactionType.自主訓練);

        result = new
        {
            labels = coaches.Select(u => u.RealName).ToArray(),
            datasets = new object[]
            {
                new
                {
                    label= "續約合約",
                    backgroundColor= "rgba(146, 203, 128, .8)",
                    data= coachID.Select(c=>renewalContractItems.Where(t=>t.CoachID==c).Sum(t=>t.ShareAmount)??0).ToArray()
                },
                new
                {
                    label= "新合約",
                    backgroundColor= "rgba(247, 208, 207, .8)",
                    data= coachID.Select(c=>newContractItems.Where(t=>t.CoachID==c).Sum(t=>t.ShareAmount)??0).ToArray()
                },
                new
                {
                    label= "P.I",
                    backgroundColor= "rgba(255,7,7,.43)",
                    data= coachID.Select(c=>piSessionItems.Where(t=>t.CoachID==c).Sum(t=>t.ShareAmount)??0).ToArray()
                },
                new
                {
                    label= "其他",
                    backgroundColor= "rgba(223, 152, 134, 1)",
                    data= coachID.Select(c=>otherItems.Where(t=>t.CoachID==c).Sum(t=>t.ShareAmount)??0).ToArray()
                }
            }
        };
    }

</script>
