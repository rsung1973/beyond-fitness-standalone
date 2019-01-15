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
    decimal[] result;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<TuitionAchievement>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;

        List<decimal> items = new List<decimal>();

        var contractItems = _model.Where(t => t.Payment.ContractPayment != null);
        var newContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == false);
        var renewalContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == true
                                     || !t.Payment.ContractPayment.CourseContract.Renewal.HasValue);
        var piSessionItems = _model.Where(t => t.Payment.TransactionType == (int)Naming.PaymentTransactionType.自主訓練);
        var otherItems = _model.Where(t => t.Payment.TransactionType != (int)Naming.PaymentTransactionType.體能顧問費
                && t.Payment.TransactionType != (int)Naming.PaymentTransactionType.自主訓練);

        var totalAchievement = _model.Sum(t => t.ShareAmount) ?? 0m;

        if (totalAchievement > 0)
        {
            items.Add(Math.Round((renewalContractItems.Sum(t => t.ShareAmount) ?? 0) * 100m / totalAchievement));
            items.Add(Math.Round((newContractItems.Sum(t => t.ShareAmount) ?? 0) * 100m / totalAchievement));
            items.Add(Math.Round((piSessionItems.Sum(t => t.ShareAmount) ?? 0) * 100m / totalAchievement));
            items.Add(Math.Round((otherItems.Sum(t => t.ShareAmount) ?? 0) * 100m / totalAchievement));

            result = items.ToArray();
        }
    }

</script>
