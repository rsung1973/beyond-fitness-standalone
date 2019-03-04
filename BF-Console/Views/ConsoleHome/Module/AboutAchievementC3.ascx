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
                    <div class="card xl-labaster">
                        <div class="body">
                            <div class="row text-center calendar-todo">
<!--                                        <div class="col-sm-3 col-6">
                                            <h4 class="margin-0">20</h4>
                                            <p class="text-muted margin-0"> 本月P.T 編輯中</p>
                                        </div>
                                        <div class="col-sm-3 col-6">
                                            <h4 class="margin-0">8</h4>
                                            <p class="text-muted margin-0"> 本月P.I 編輯中</p>
                                        </div>
                                        <div class="col-sm-3 col-6">
                                            <h4 class="margin-0">28</h4>
                                            <p class="text-muted margin-0"> 截至上月P.T 未完成</p>
                                        </div>
                                        <div class="col-sm-3 col-6">
                                            <h4 class="margin-0">3</h4>
                                            <p class="text-muted margin-0"> 截至上月P.I 未完成</p>
                                        </div>-->
                                    </div>
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
