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
    IQueryable<CourseContract> _model;
    AchievementQueryViewModel _viewModel;
    Object result;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<CourseContract>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;

        var coaches = models.GetTable<UserProfile>().Where(u => _viewModel.ByCoachID.Contains(u.UID));
        var coachID = coaches.Select(u => u.UID).ToArray();

        var contractItems = _model;
        var newContractItems = contractItems.Where(t => t.Renewal == false);
        var renewalContractItems = contractItems.Where(t => t.Renewal == true
                                    || !t.Renewal.HasValue);

        result = new
        {
            labels = coaches.Select(u => u.RealName).ToArray(),
            datasets = new object[]
            {
                new
                {
                    label= "續約合約簽訂數",
                    backgroundColor= "rgba(146, 203, 128, .8)",
                    data= coachID.Select(c=>renewalContractItems.Where(t=>t.FitnessConsultant==c).Count()).ToArray()
                },
                new
                {
                    label= "新合約簽訂數",
                    backgroundColor= "rgba(247, 208, 207, .8)",
                    data= coachID.Select(c=>newContractItems.Where(t=>t.FitnessConsultant==c).Count()).ToArray()
                },
            }
        };
    }

</script>
