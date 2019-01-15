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

<section class="col col-4">
    <label class="label">展延時間</label>
    <label class="select">
        <select name="MonthExtension">
            <option value="3">3個月</option>
            <%--<option value="6">6個月</option>
            <option value="9">9個月</option>
            <option value="12">12個月</option>--%>
        </select>
        <i class="icon-append far fa-clock"></i>
    </label>
    <script>
        $('select[name="MonthExtension"]').on('change', function (evt) {
            var months = parseInt($(this).val());
            var d = new Date(<%= _model.Expiration.Value.Year %>,<%= _model.Expiration.Value.Month-1 %>+months,<%= _model.Expiration.Value.Day %>);
            $('#expiration').text(d.getFullYear() + '/' + (d.getMonth()+1) + '/' + d.getDate());
        });
    </script>
</section>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContractViewModel _viewModel;
    String _dialog = "amendment" + DateTime.Now.Ticks;
    CourseContract _model;
    bool _useLearnerDiscount;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
        _useLearnerDiscount = models.CheckLearnerDiscount(_model.CourseContractMember.Select(m => m.UID));
    }

</script>
