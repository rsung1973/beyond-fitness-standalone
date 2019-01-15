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

<div class="col-sm-12">
    <div class="block">
        <div class="head" style="bottom center no-repeat;">
            <%  Html.RenderPartial("~/Views/Member/Module/MemberPhoto.ascx", _model); %>
            <div class="head-panel nm">
                <%--<div class="hp-info pull-left" rel="tooltip" data-placement="bottom" data-original-title="<span class='label bg-color-blueLight font-md'></span>" data-html="true">
                    <div class="hp-icon">
                    <span class="fa fa-trophy"></span>
                    </div>
                    <span class="hp-main">
                    </span>
                    <span class="hp-sm">
                    </span>
                </div>
                <div class="hp-info pull-left">
                    <div class="hp-icon">
                    <span class="fa fa-address-card"></span>
                    </div>
                    <span class="hp-main"></span>
                    <span class="hp-sm"></span>
                </div>
                <div class="hp-info pull-left">
                    <div class="hp-icon">
                    <span class="fa fa-certificate"></span>
                    </div>
                    <span class="hp-main"></span>
                    <span class="hp-sm">Cert</span>
                </div>--%>
                <div class="hp-info pull-right" onclick="showGameWidget(<%= _model.UID %>);">
                    <div class="hp-icon">
                        <span class="fa fa-gamepad text-success"></span>
                    </div>
                    <span class="hp-main text-success">
                        <%  var contestant = _model.ExerciseGameContestant;
                            if (contestant != null && contestant.ExerciseGamePersonalRank != null)
                            {
                                Writer.Write(contestant.ExerciseGamePersonalRank.Rank);
                            }   %>
                    </span>
                    <span class="hp-sm text-success">Rank</span>
                </div>
            </div>
        </div>
    </div>
    <script>
        $(function () {
            $('span[rel="tooltip"]').tooltip();
        });

        function showGameWidget(uid) {
            showLoading();
            $.post('<%= Url.Action("ShowGameWidget","ExerciseGame") %>', { 'uid': uid }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }


    </script>
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
