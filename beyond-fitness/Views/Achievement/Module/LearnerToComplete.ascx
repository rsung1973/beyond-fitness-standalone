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

<div id="<%= _dialogID %>" title="學員未打卡比較表" class="bg-color-darken">
    <!-- Widget ID (each widget will need unique ID)-->
    <div class="jarviswidget jarviswidget-color-darken" id="wid-id-1" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
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
            <h2>學員未打卡數統計</h2>
            <div class="widget-toolbar">
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
                <div class="row">
                    <div class="col col-xs-12 col-sm-8 col-md-8">
                        <%  Html.RenderPartial("~/Views/Achievement/Module/LearnerToCompleteBarChart.ascx",_model); %>
                    </div>
                    <div class="col col-xs-12 col-sm-4 col-md-4">
                        <table class="table table-striped table-bordered table-hover display responsive no-wrap" width="100%">
                            <thead>
                                <tr>
                                    <th>體能顧問</th>
                                    <th class="text-center">P.T</th>
                                    <th class="text-center">P.I</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%  int PTTotalCount = 0, PITotalCount = 0;

                                    foreach (var g in _model.GroupBy(l => l.AttendingCoach))
                                    {
                                        var coach = models.GetTable<ServingCoach>().Where(c => c.CoachID == g.Key).First(); %>
                                <tr>
                                    <td>
                                        <%= coach.UserProfile.FullName() %>
                                    </td>
                                    <td nowrap="noWrap" class="text-center">
                                        <%  var items = g.PTLesson();
                                            int PTCount = items.Count();
                                            PTTotalCount += PTCount; %>
                                        <%  if (PTCount > 0)
                                            { %>
                                            <a onclick="checkLearnerAttendance(<%= g.Key %>);" class="btn btn-circle bg-color-red"><%= PTCount %></a>
                                        <%  }
                                            else
                                            { %>
                                        <%= PTCount %>
                                        <%  } %>
                                    </td>
                                    <td nowrap="noWrap" class="text-center">
                                        <%  items = g.Where(l => l.TrainingBySelf == 1);
                                            int PICount = items.Count();
                                            PITotalCount += PICount; %>
                                        <%= PICount %>
                                    </td>
                                </tr>
                                <%  } %>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td class="text-class">總計</td>
                                    <td class="text-center"><%= PTTotalCount %></td>
                                    <td class="text-center"><%= PITotalCount %></td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                </div>
            </div>
            <!-- end widget content -->
        </div>
        <!-- end widget div -->
    </div>
    <!-- end widget -->
    <script>
        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "100%",
            title: "<h4 class='modal-title'><i class='fa-fw far fa-check-square'></i>  學員未打卡比較表</h4>",
            close: function (event, ui) {
                $('#<%= _dialogID %>').remove();
            }
        });

        function checkLearnerAttendance(coachID) {
            var event = event || window.event;
            var $target = $(event.target);
            //var $td = $target.closest('td');
            var formData = $('#queryForm').serializeObject();
            formData.coachID = coachID;

            showLoading();
            $.post('<%= Url.Action("CheckLearnerAttendance","Achievement") %>', formData, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if (data.result) {
                        alert("已完成打卡!!");
                        //$td.text('0');
                        $('#<%= _dialogID %>').dialog('close');
                        showLearnerToComplete();
                    } else {
                        alert(data.message);
                    }
                } else {
                    $(data).appendTo($('body'));
                }
            });
        }
    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "lesson" + DateTime.Now.Ticks;
    IQueryable<LessonTime> _model;
    AchievementQueryViewModel _viewModel;
    String _dialogID = "toComplete" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
    }

</script>
