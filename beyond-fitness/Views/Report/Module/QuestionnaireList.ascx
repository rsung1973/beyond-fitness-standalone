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

<table id="<%= _tableId %>" class="table table-striped table-bordered table-hover display responsive no-wrap" width="100%">
    <thead>
        <tr>
            <th data-class="expand">填寫人員</th>
            <th>學員</th>
            <th>合約編號</th>
            <th>日期</th>
            <th>滿意度</th>
            <th>狀態</th>
            <th>功能</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <td>
                <%  var ansTask = item.PDQTask.FirstOrDefault();
                    if (ansTask != null)
                        Writer.Write(ansTask.UserProfile.FullName());
                    else if (item.QuestionnaireCoachBypass != null)
                        Writer.Write(item.QuestionnaireCoachBypass.UserProfile.FullName());
                    else
                        Writer.Write("--"); %>
            </td>
            <td><%= item.UserProfile.FullName() %></td>
            <td><%= item.RegisterLesson.RegisterLessonContract?.CourseContract.ContractNo() %></td>
            <td><%= $"{item.RequestDate:yyyy/MM/dd}" %></td>
            <td class="text-center">
                <%  var ansSuggestion = item.PDQTask.Where(t => t.PDQQuestion.QuestionNo == 4)
                        .Select(t=>t.PDQSuggestion)
                        .FirstOrDefault(); 
                    if (ansSuggestion != null)
                        Writer.Write(ansSuggestion.Suggestion);
                    else
                        Writer.Write("--"); %>
            </td>
            <td><%= item.Status.HasValue 
                        ? item.Status==(int)Naming.IncommingMessageStatus.已讀 || item.Status==(int)Naming.IncommingMessageStatus.未讀
                            ? "已填寫"
                            : item.Status==(int)Naming.IncommingMessageStatus.教練代答
                                ? "我超強不用了解學生"
                                : "不方便填寫"
                        : "未填寫" %>                
                </td>
            <td nowrap="noWrap">
                <%  if (item.Status == (int)Naming.IncommingMessageStatus.已讀 || item.Status == (int)Naming.IncommingMessageStatus.未讀)
                    {   %>
                <a onclick="showLearnerQuestionnaire(<%= item.QuestionnaireID %>);" class="btn btn-circle bg-color-blueLight"><i class="fa fa-fw fa-lg fa-eye" aria-hidden="true"></i></a>&nbsp;&nbsp;   
                <%  }
                    else if(!item.Status.HasValue)
                    { %>
                <a onclick="$global.promptQuestionnaire(null,<%= item.QuestionnaireID %>);" class="btn btn-circle bg-color-yellow modifyquestionaireDialog_link"><i class="fa fa-fw fa fa-lg fa-edit" aria-hidden="true"></i> </a>&nbsp;&nbsp;
                <%  } %>
            </td>
        </tr>
        <%  } %>
    </tbody>
</table>

<script>
    $(function () {
        var responsiveHelper_<%= _tableId %> = undefined;

        var responsiveHelper_datatable_fixed_column = undefined;
        var responsiveHelper_datatable_col_reorder = undefined;
        var responsiveHelper_datatable_tabletools = undefined;

        var breakpointDefinition = {
            tablet: 1024,
            phone: 480
        };

        $('#<%= _tableId %>').dataTable({
            "sDom": "<'dt-toolbar'<'col-xs-12 col-sm-6'f><'col-sm-6 col-xs-12 hidden-xs'l>r>" +
                     "t" +
                     "<'dt-toolbar-footer'<'col-sm-6 col-xs-12 hidden-xs'i><'col-xs-12 col-sm-6'p>>",
            "autoWidth": false,
            "responsive": true,
            "lengthMenu": [[10, 30, 50, -1], [10, 30, 50, "全部"]],
            "ordering": [0],
            "oLanguage": {
                "sSearch": '<span class="input-group-addon"><i class="glyphicon glyphicon-search"></i></span>'
            },
            "preDrawCallback": function () {
                // Initialize the responsive datatables helper once.
                if (!responsiveHelper_<%= _tableId %>) {
                    responsiveHelper_<%= _tableId %> = new ResponsiveDatatablesHelper($('#<%= _tableId %>'), breakpointDefinition);
                }
            },
            "rowCallback": function (nRow) {
                responsiveHelper_<%= _tableId %>.createExpandIcon(nRow);
            },
            "drawCallback": function (oSettings) {
                responsiveHelper_<%= _tableId %>.respond();
            }
        });

<%  if (_model.Count() > 0)
    {  %>
        $('#btnDownloadLessons').css('display', 'inline');
        $('#btnLearnerToComplete').css('display', 'inline');
<%  }  %>

        $('.achievement').text('');

<%  if (_viewModel.AchievementDateFrom.HasValue || _viewModel.AchievementDateTo.HasValue)
    { %>
        $('.achievement').text('(<%= _viewModel.AchievementDateFrom.HasValue ? String.Format("{0:yyyy/MM/dd}",_viewModel.AchievementDateFrom) : null %>~<%= _viewModel.AchievementDateTo.HasValue ? String.Format("{0:yyyy/MM/dd}",_viewModel.AchievementDateTo.Value.AddMonths(1).AddDays(-1)) : null %>)');
        <%  } %>

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "questionnaire" + DateTime.Now.Ticks;
    IQueryable<QuestionnaireRequest> _model;
    AchievementQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<QuestionnaireRequest>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
    }

</script>
