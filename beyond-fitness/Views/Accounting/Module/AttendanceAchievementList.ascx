﻿<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<div id="<%= _dialog %>" title="上課明細" class="bg-color-darken">
    <!-- content -->
    <%  Html.RenderPartial("~/Views/Accounting/Module/AttendanceAchievementDetails.ascx", _model); %>
    <!-- end content -->
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-table'></i>  <%= _viewModel.AchievementYearMonthFrom %>上課明細：<%= _items.First().AsAttendingCoach.UserProfile.FullName() %></h4>",
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });
    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "attendance" + DateTime.Now.Ticks;
    IQueryable<V_Tuition> _model;
    IQueryable<LessonTime> _items;
    AchievementQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<V_Tuition>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
        _items = _model.Join(models.GetTable<LessonTime>(), t => t.LessonID, c => c.LessonID, (t, c) => c);
    }

</script>
