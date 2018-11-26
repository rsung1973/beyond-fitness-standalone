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
                    <div class="card bg-darkteal">
                        <div class="body">
                            <%  
                                Html.RenderPartial("~/Views/ConsoleHome/Module/TodayLessonsBarChartC3.ascx", _model);
                            %>
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
