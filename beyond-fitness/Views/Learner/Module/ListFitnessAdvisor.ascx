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

<div id="<%= _dialog %>" title="設定體能顧問" class="bg-color-darken">
    <!-- Widget ID (each widget will need unique ID)-->
    <div class="jarviswidget jarviswidget-color-darken" id="wid-id-2" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
        <!-- widget options:
                   usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">

                   data-widget-colorbutton="false"
                   data-widget-editbutton="false"
                   data-widget-togglebutton="false"
                   data-widget-deletebutton="false"
                   data-widget-fullscreenbutton="false"
                   data-widget-custombutton="false"
                   data-widget-collapsed="true"
                   data-widget-sortable="false"

                   -->
        <header>
            <span class="widget-icon"><i class="fa fa-table"></i></span>
            <h2>所屬體能顧問列表</h2>
            <div class="widget-toolbar">
                <a onclick="$global.assignAdvisor();" class="btn btn-primary"><i class="fa fa-fw fa-plus"></i>新增體能顧問</a>
            </div>
        </header>
        <!-- widget div-->
        <div>
            <!-- widget edit box -->
            <div class="jarviswidget-editbox">
                <!-- This area used as dropdown edit box -->
            </div>
            <!-- end widget edit box -->
            <!-- widget content -->
            <div class="widget-body bg-color-darken txt-color-white no-padding">
                <%  Html.RenderPartial("~/Views/Learner/Module/FitnessAdvisorList.ascx", _items); %>
            </div>
            <!-- end widget content -->
        </div>
        <!-- end widget div -->
    </div>
    <!-- end widget -->
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 設定體能顧問</h4></div>",
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });

        $(function() {
            $global.assignAdvisor = function () {
                showLoading();
                $.post('<%= Url.Action("AssignFitnessAdvisor","Learner",new { _model.UID }) %>', {}, function (data) {
                    hideLoading();
                    $(data).appendTo($('body'));
                    $('#<%= _dialog %>').dialog('close');
                });
            }

            $global.deleteAdvisor = function (coachID) {
                var event = event || window.event;
                $tr = $(event.target).closest('tr');
                showLoading();
                $.post('<%= Url.Action("DeleteAdvisorAssignment","Learner",new { _model.UID }) %>', { 'coachID': coachID }, function (data) {
                    hideLoading();
                    if (data.result) {
                        $tr.remove();
                    } else {
                        alert(data.message);
                    }
                });
            }
        });

    </script>
</div>

<script runat="server">

    String _dialog = "advisor" + DateTime.Now.Ticks;
    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    IEnumerable<LearnerFitnessAdvisor> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _items = _model.LearnerFitnessAdvisor;
    }

</script>
