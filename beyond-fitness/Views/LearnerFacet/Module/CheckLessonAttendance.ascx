<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<!-- ui-dialog -->
<div id="undolistDialog" title="待辦事項" class="bg-color-darken">
    <!-- content -->
    <table id="<%= _tableId %>" class="table table-striped table-bordered table-hover" width="100%" autofocus>
        <thead>
            <tr>
                <th data-class="expand">日期</th>
                <th data-hide="phone">時間</th>
                <th data-hide="phone">體能顧問</th>
                <th>上課打卡</th>
            </tr>
        </thead>
        <tbody>
            <%  foreach (var item in _uncheckedLessons)
                { %>
            <tr>
                <td><%= String.Format("{0:yyyy/MM/dd}",item.ClassTime) %></td>
                <td><%= String.Format("{0:H:mm}",item.ClassTime) %>~<%= String.Format("{0:H:mm}",item.ClassTime.Value.AddMinutes(item.DurationInMinutes.Value)) %></td>
                <td><%= item.AsAttendingCoach.UserProfile.FullName() %></td>
                <td>
                    <a href="#" onclick="checkLessonAttendance(<%= item.LessonID %>);" class="btn btn-circle bg-color-green"><i class="fa fa-fw fa fa-lg fa-check" aria-hidden="true"></i></a>
                </td>
            </tr>
            <%  } %>
        </tbody>
    </table>
    <!-- end content -->
    <script>

        $('#undolistDialog').dialog({
            //autoOpen: false,
            width: "auto",
            height: "auto",
            resizable: true,
            modal: true,
            closeText: "關閉",
            title: "<h4 class='modal-title'><i class='icon-append fa fa-list-ol'></i> 上課未打卡</h4>",
            close: function (event, ui) {
                $('#undolistDialog').remove();
            }
        });

        function checkLessonAttendance(lessonID) {
            var event = event || window.event;
            var $target = $(event.target)
            var $tr = $target.closest('tr');
            showLoading();
            $.post('<%= Url.Action("LearnerAttendLesson","Attendance") %>', { 'lessonID': lessonID }, function (data) {
                hideLoading();
                if (data) {
                    if (data.result) {
                        alert("已完成打卡!!");
                        var count = $target.closest('table').find('a.btn-circle.bg-color-green').length - 1;
                        $('#undolistDialog_link u').text(count);
                        $tr.remove();
                        if (count == 0) {
                            $('#undolistDialog').dialog('close');
                        }
                    } else {
                        alert(data.message);
                    }
                }
            });
        }
    </script>

</div>
<!-- dialog-message -->



<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    String _tableId;
    IQueryable<LessonTime> _uncheckedLessons;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _tableId = ViewBag.DataTableId ?? "dt_attendLesson";

        _uncheckedLessons = _model.LearnerGetUncheckedLessons(models)
            .OrderBy(l => l.ClassTime);


    }

</script>
