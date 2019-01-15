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
    int rangeType;
    Object result;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<TuitionAchievement>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;

        result = new
        {
            labels = getAxisX(),
            datasets = models.GetTable<BranchStore>().Select
            (
                b => new
                {
                    label = b.BranchName + "(%)",
                    backgroundColor = b.BranchID == 1
                                            ? "rgba(69, 167, 52, 1)"
                                            : b.BranchID == 2
                                                ? "rgba(209, 109, 82, 1)"
                                                : "rgba(76, 191, 188, 1)",
                    pointBackgroundColor = "rgba(151,187,205, 1)",
                    hoverPointBackgroundColor = "#fff",
                    pointHighlightStroke = "rgba(151,187,205, 1)",
                    data = getDistribution(b),
                }).ToArray(),
        };
    }

    IEnumerable<String> getAxisX()
    {
        var interval = _viewModel.AchievementDateTo - _viewModel.AchievementDateFrom;
        if (interval.HasValue)
        {
            if (interval.Value.TotalDays > 31)
            {
                rangeType = 2;
                for (DateTime g = _viewModel.AchievementDateFrom.Value; g <= _viewModel.AchievementDateTo.Value; g = g.AddMonths(1))
                {
                    yield return $"{g:yyyy/MM}";
                }
            }
            else
            {
                rangeType = 1;
                for (DateTime g = _viewModel.AchievementDateFrom.Value; g <= _viewModel.AchievementDateTo.Value; g = g.AddDays(1))
                {
                    yield return $"{g:yyyy/MM/dd}";
                }
            }
        }
    }

    IEnumerable<decimal> getDistribution(BranchStore branch)
    {
        var items = _model.Where(t => t.Payment.PaymentTransaction.BranchID == branch.BranchID);
        switch (rangeType)
        {
            case 1:

                for (DateTime g = _viewModel.AchievementDateFrom.Value; g <= _viewModel.AchievementDateTo.Value; g = g.AddDays(1))
                {
                    var scopeItems = items.Where(t => t.Payment.PayoffDate >= g && t.Payment.PayoffDate < g.AddDays(1));
                    var baseItems = _model.Where(t => t.Payment.PayoffDate >= g && t.Payment.PayoffDate < g.AddDays(1));

                    decimal achievement = scopeItems.Sum(t => t.ShareAmount) ?? 0;
                    decimal totalAchievement = baseItems.Sum(t => t.ShareAmount) ?? 0;

                    yield return totalAchievement > 0 ? Math.Round(achievement * 100m / totalAchievement) : 0;

                }
                break;
            case 2:
                for (DateTime g = _viewModel.AchievementDateFrom.Value; g <= _viewModel.AchievementDateTo.Value; g = g.AddMonths(1))
                {
                    var scopeItems = items.Where(t => t.Payment.PayoffDate >= g && t.Payment.PayoffDate < g.AddMonths(1));
                    var baseItems = _model.Where(t => t.Payment.PayoffDate >= g && t.Payment.PayoffDate < g.AddMonths(1));

                    decimal achievement = scopeItems.Sum(t => t.ShareAmount) ?? 0;
                    decimal totalAchievement = baseItems.Sum(t => t.ShareAmount) ?? 0;

                    yield return totalAchievement > 0 ? Math.Round(achievement * 100m / totalAchievement) : 0;

                }
                break;
        }
    }

</script>
