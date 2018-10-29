<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="alert alert-warning fade in padding-5">
    <button class="close">
        <i class="fa fa-pencil-alt"></i>
    </button>
    <i class="fa-fw fa fa-info-circle"></i>
    <strong id="emphasis">重點：<%= _model.Emphasis %></strong>
</div>
<div class="panel panel-default no-padding pull-right">
    <button class="btn btn-xs bg-color-blueDark" id="<%= _accordionID %>collapseAll"><i class="fa fa-fw fa-chevron-circle-right text-pacificblue"></i>全部收合</button>
</div>
<div class="panel-group smart-accordion-default" id="<%= _accordionID %>">
    <%  foreach (var item in models.GetTable<TrainingStage>())
        {
            ViewBag.TrainingStage = item;
            Html.RenderPartial("~/Views/Training/Module/TrainingStagePanelView.ascx", _model);
        } %>
</div>

<script>

    $(function () {
        var headers = $('#<%= _accordionID %> .panel-heading');
        var contentAreas = $('#<%= _accordionID %> .panel-collapse').show();
        var expandLink = $('#<%= _accordionID %>collapseAll');
        expandLink.data('isAllOpen', true);


        // add the accordion functionality
        headers.click(function () {
            var panel = $(this).next();
            var isOpen = panel.is(':visible');

            // open or close as necessary
            panel[isOpen ? 'slideUp' : 'slideDown']()
                // trigger the correct custom event
                .trigger(isOpen ? 'hide' : 'show');

            // stop the link from causing a pagescroll
            return false;
        });

        // hook up the expand/collapse all
        expandLink.click(function () {
            var isAllOpen = $(this).data('isAllOpen');

            contentAreas[isAllOpen ? 'hide' : 'show']()
                .trigger(isAllOpen ? 'hide' : 'show');


        });

        // when panels open or close, check to see if they're all open
        contentAreas.on({
            // whenever we open a panel, check to see if they're all open
            // if all open, swap the button to collapser
            show: function () {
                var isAllOpen = !contentAreas.is(':hidden');
                if (isAllOpen) {
                    expandLink.html('<i class=\"fa fa-fw fa-chevron-circle-right text-pacificblue\"></i> 全部收合')
                        .data('isAllOpen', true);
                }
            },
            // whenever we close a panel, check to see if they're all open
            // if not all open, swap the button to expander
            hide: function () {
                var isAllOpen = !contentAreas.is(':hidden');
                if (!isAllOpen) {
                    expandLink.html('<i class=\"fa fa-fw fa-chevron-circle-down text-pacificblue\"></i> 全部展開')
                    .data('isAllOpen', false);
                }
            }
        });
    });
    
</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    TrainingExecution _model;
    String _accordionID = "acdn" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (TrainingExecution)this.Model;
    }

</script>
