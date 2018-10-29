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

<div class="alert alert-warning fade in padding-5" onclick="editEmphasis();">
    <button class="close">
        <i class="fa fa-pencil-alt"></i>
    </button>
    <i class="fa-fw fa fa-info-circle"></i>
    <strong id="emphasis">重點：<%= _model.Emphasis ?? "<i>點此編輯課程重點!!</i>" %></strong>
</div>
<div class="panel panel-default no-padding pull-right">
    <button class="btn btn-xs bg-color-blueDark" id="accordioncollapseAll"><i class="fa fa-fw fa-chevron-circle-right text-pacificblue"></i>全部收合</button>
</div>
<div class="panel-group smart-accordion-default" id="accordion">
    <%  foreach (var item in models.GetTable<TrainingStage>())
        {
            ViewBag.TrainingStage = item;
            Html.RenderPartial("~/Views/Training/Module/TrainingStagePanel.ascx", _model);
        } %>
</div>

<script>

    $('.dd').on('change', function () {
        /* on change event */
        var itemID = [];
        $(this).find('[data-id]')
            .each(function (idx, elmt) {
                itemID.push($(this).data('id'));
            });

        showLoading();
        $.post('<%= Url.Action("UpdateStageTrainingItemSequence", "Lessons") %>', {'itemID':itemID}, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                if (data.result) {
                } else {
                    alert(data.message);
                }
            } else {
                $(data).appendTo($('body'));
            }
        });
    });

    var headers = $('#accordion .panel-heading');
    var contentAreas = $('#accordion .panel-collapse').show();
    var expandLink = $('#accordioncollapseAll');
    expandLink.data('isAllOpen', true);


    // add the accordion functionality
    headers.click(function () {
        var panel = $(this).next();
        var isOpen = panel.is(':visible');

        // open or close as necessary
        panel[isOpen ? 'slideUp' : 'slideDown']()
            // trigger the correct custom event
            .trigger(isOpen ? 'hide' : 'show');

        //                if (isOpen) {                
        //                    if (!panel('#accordion .panel-heading .panel-title .text-pacificblue').is(':visible')) {                        
        //                        panel('#accordion .panel-heading .panel-title .text-pacificblue').show();
        //                        panel('#accordion .panel-heading .panel-title .text-carmine').hide();
        //                    }
        //                    
        //                } else {
        //                    if (panel('#accordion .panel-heading .panel-title .text-pacificblue').is(':visible')) {
        //                        panel('#accordion .panel-heading .panel-title .text-pacificblue').hide();
        //                        panel('#accordion .panel-heading .panel-title .text-carmine').show();
        //                    }
        //                }              

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
                //$('#accordion .panel-heading .panel-title .text-pacificblue').show();
                //$('#accordion .panel-heading .panel-title .text-carmine').hide();                        
            }
        },
        // whenever we close a panel, check to see if they're all open
        // if not all open, swap the button to expander
        hide: function () {
            var isAllOpen = !contentAreas.is(':hidden');
            if (!isAllOpen) {
                expandLink.html('<i class=\"fa fa-fw fa-chevron-circle-down text-pacificblue\"></i> 全部展開')
                .data('isAllOpen', false);
                //$('#accordion .panel-heading .panel-title .text-pacificblue').hide();
                //$('#accordion .panel-heading .panel-title .text-carmine').show();   
            }
        }
    });

    function editEmphasis() {
        showLoading();
        $.post('<%= Url.Action("EditEmphasis", "Training", new { _model.ExecutionID }) %>', {}, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $(data).appendTo($('body'));
            }
        });
    }

    function editStageTrainingItem(stageID, itemID) {
        showLoading();
        $.post('<%= Url.Action("EditTrainingItem", "Training", new { _model.ExecutionID }) %>', { 'stageID': stageID, 'itemID': itemID }, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $(data).appendTo($('body'));
            }
        });
    }

    function editStageBreakInterval(stageID, itemID) {
        showLoading();
        $.post('<%= Url.Action("EditBreakInterval", "Training", new { _model.ExecutionID }) %>', { 'stageID': stageID, 'itemID': itemID }, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $(data).appendTo($('body'));
            }
        });
    }
    
</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    TrainingExecution _model;
    String _tableId;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (TrainingExecution)this.Model;
        _tableId = ViewBag.DataTableId ?? "dt_basic" + DateTime.Now.Ticks;
    }

</script>
