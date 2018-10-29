<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<div class="container-fluid">
    <div class="row clearfix">
        <h4 class="card-outbound-header m-l-15">我的分店業績</h4>
        <div class="col-lg-12 col-md-12">
            <div class="row clearfix">
                <div class="col-12">
                    <div class="card">
                        <div class="body">
                            <div class="p-15">
                                <span class="m-r-20"><i class="zmdi zmdi-label col-amber m-r-5"></i>P.T</span>
                                <span class="m-r-20"><i class="zmdi zmdi-label col-pink m-r-5"></i>P.I</span>
                                <span class="m-r-20"><i class="zmdi zmdi-label col-purple m-r-5"></i>體驗</span>
                            </div>
                            <div class="chart-box">
                                <%  
                                    Html.RenderPartial("~/Views/ConsoleHome/Module/TodayLessonsBarChart.ascx", _model);
                                 %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }


</script>
