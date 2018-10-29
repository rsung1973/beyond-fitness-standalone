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

<table class="table table-striped table-bordered table-hover" width="100%">
    <thead>
        <tr>
            <th data-class="expand">一般項目</th>
            <th class="text-center">教練已完成</th>
            <th data-hide="phone" class="text-center">教練未完成</th>
            <th data-hide="phone" class="text-center">學員已完成</th>
            <th data-hide="phone" class="text-center">學員未完成</th>
        </tr>
    </thead>
    <tbody>
        <%  
            var items = _model.PTLesson();  %>
        <tr>
            <td nowrap="noWrap">P.T session<%= reportCount(items.Count(),"") %></td>
            <td nowrap="noWrap" class="text-center"><%= reportCount(coachMarkAttended(items).Count()) %></td>
            <td nowrap="noWrap" class="text-center">
                <%  var listItems = coachToCommit(items);
                    if (listItems.Count() > 0)
                    { %>
                        <a href="javascript:showCoachToCommit(<%= (int)Naming.LessonQueryType.一般課程 %>,'待辦事項：P.T session(教練未完成)');" class="undolistDialog_link"><u>(<%= listItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                        --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-center">
                <%  listItems = learnerMarkAttended(items);
                    if (listItems.Count() > 0)
                    {
                        if(_viewModel.QueryStart.HasValue)
                        {%>
                <a href="javascript:showLearnerMarkAttended(<%= (int)Naming.LessonQueryType.一般課程 %>,'待辦事項：P.T session(學員已完成)');" class="undolistDialog_link"><u>(<%= listItems.Count() %>)</u></a>
                <%      }
                        else
                        {   %>
                (<%= listItems.Count() %>)
                <%      }
                    }
                    else
                    { %>
                        --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-center">
                <%  listItems = learnerToCommit(items);
                    if (listItems.Count() > 0)
                    { %>
                <a href="javascript:showLearnerToCommit(<%= (int)Naming.LessonQueryType.一般課程 %>,'待辦事項：P.T session(學員未完成)');" class="undolistDialog_link"><u>(<%= listItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                        --
                <%  } %>
            </td>
        </tr>
        <%  items = _model.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.自主訓練
                || (l.RegisterLesson.RegisterLessonEnterprise!=null && l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status==(int)Naming.LessonPriceStatus.自主訓練));  %>
        <tr>
            <td nowrap="noWrap">P.I session<%= reportCount(items.Count(),"") %></td>
            <td nowrap="noWrap" class="text-center"><%= reportCount(coachMarkAttended(items).Count()) %></td>
            <td nowrap="noWrap" class="text-center">
                <%  listItems = coachToCommit(items);
                    if (listItems.Count() > 0)
                    { %>
                        <a href="javascript:showCoachToCommit(<%= (int)Naming.LessonQueryType.自主訓練 %>,'待辦事項：P.I session(教練未完成)');" class="undolistDialog_link"><u>(<%= listItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                        --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-center">
                <%  listItems = learnerMarkAttended(items);
                    if (listItems.Count() > 0)
                    { %>
                <a href="javascript:showLearnerMarkAttended(<%= (int)Naming.LessonQueryType.自主訓練 %>,'待辦事項：P.I session(學員已完成)');" class="undolistDialog_link"><u>(<%= listItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                        --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-center">
                <%  listItems = learnerToCommit(items);
                    if (listItems.Count() > 0)
                    { %>
                <a href="javascript:showLearnerToCommit(<%= (int)Naming.LessonQueryType.自主訓練 %>,'待辦事項：P.I session(學員未完成)');" class="undolistDialog_link"><u>(<%= listItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                        --
                <%  } %>
            </td>
        </tr>
        <%  items = _model.TrialLesson();  %>
        <tr>
            <td nowrap="noWrap">體驗課程<%= reportCount(items.Count(),"") %></td>
            <td nowrap="noWrap" class="text-center"><%= reportCount(coachMarkAttended(items).Count()) %></td>
            <td nowrap="noWrap" class="text-center">
            <%  listItems = coachToCommit(items);
                    if (listItems.Count() > 0)
                    { %>
                        <a href="javascript:showCoachToCommit(<%= (int)Naming.LessonQueryType.體驗課程 %>,'待辦事項：體驗課程(教練未完成)');" class="undolistDialog_link"><u>(<%= listItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                        --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-center">
                <%  listItems = learnerMarkAttended(items);
                    if (listItems.Count() > 0)
                    { %>
                <a href="javascript:showLearnerMarkAttended(<%= (int)Naming.LessonQueryType.體驗課程 %>,'待辦事項：體驗課程(學員已完成)');" class="undolistDialog_link"><u>(<%= listItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                        --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-center">
            <%  listItems = learnerToCommit(items);
                    if (listItems.Count() > 0)
                    { %>
                <a href="javascript:showLearnerToCommit(<%= (int)Naming.LessonQueryType.體驗課程 %>,'待辦事項：體驗課程(學員未完成)');" class="undolistDialog_link"><u>(<%= listItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                        --
                <%  } %>
            </td>
        </tr>
        <%  items = _model.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.教練PI);  %>
        <tr>
            <td nowrap="noWrap">教練P.I<%= reportCount(items.Count(),"") %></td>
            <td nowrap="noWrap" class="text-center"><%= reportCount(coachMarkAttended(items).Count()) %></td>
            <td nowrap="noWrap" class="text-center">
                <%  listItems = coachToCommit(items);
                    if (listItems.Count() > 0)
                    { %>
                <a href="javascript:showCoachToCommit(<%= (int)Naming.LessonQueryType.教練PI %>,'待辦事項：教練P.I(教練未完成)');" class="undolistDialog_link"><u>(<%= listItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                        --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-center">--</td>
            <td nowrap="noWrap" class="text-center">--</td>
        </tr>
        <%  
            IQueryable<QuestionnaireRequest> questionnaireItems = models.GetTable<QuestionnaireRequest>();
            if (_viewModel.QueryStart.HasValue)
            {
                questionnaireItems = questionnaireItems.Where(q => q.RequestDate >= _viewModel.QueryStart && q.RequestDate < _viewModel.QueryStart.Value.AddMonths(1));
            }
            if (_viewModel.CoachID.HasValue)
            {
                var uid = models.GetTable<LearnerFitnessAdvisor>().Where(l => l.CoachID == _viewModel.CoachID).Select(l => l.UID);
                questionnaireItems = questionnaireItems.Where(q => uid.Contains(q.UID));
            }
            %>
        <%--<tr>
            <td nowrap="noWrap">階段性調整計劃<%= reportCount(questionnaireItems.Count(),"") %></td>
            <td nowrap="noWrap" class="text-center">--</td>
            <td nowrap="noWrap" class="text-center">--</td>
            <td nowrap="noWrap" class="text-center"><a href="javascript:showQuestionnaire(true,'待辦事項：階段性調整計劃(學員已完成)');" class="questionnairelist_link"><u><%= reportCount(questionnaireItems.Where(q=>q.PDQTask.Any()).Count()) %></u></a></td>
            <td nowrap="noWrap" class="text-center"><a href="javascript:showQuestionnaire(false,'待辦事項：階段性調整計劃(學員未完成)');" class="questionnairelist_link"><u><%= reportCount(questionnaireItems.Where(q=>!q.PDQTask.Any()).Count()) %></u></a></td>
        </tr>--%>
    </tbody>
</table>
<script>

    function showCoachToCommit(query,title) {
        $global.showLessonList('<%= Url.Action("ShowCoachToCommit","CoachFacet") %>'+'?query='+query,title);
    }

    function showLearnerMarkAttended(query,title) {
        $global.showLessonList('<%= Url.Action("ShowLearnerMarkAttended","CoachFacet") %>'+'?query='+query,title);
    }

    function showLearnerToCommit(query,title) {
        $global.showLessonList('<%= Url.Action("ShowLearnerToCommit","CoachFacet") %>'+'?query='+query,title);
    }

    function showQuestionnaire(committed,title) {
        $global.showLessonList('<%= Url.Action("QueryQuestionnaire","CoachFacet") %>'+'?committed='+committed,title);
    }

    $(function () {
        $global.showLessonList = function (url, title, params) {
            var postData = <%= JsonConvert.SerializeObject(_viewModel) %>;
            if(params){
                $.extend(postData,params);
            }
            showLoading();
            $.post(url,postData , function (data) {
                hideLoading();
                if (data) {
                    var $dialog = $(data);
                    $dialog.dialog({
                        width: "auto",
                        height: "auto",
                        resizable: true,
                        modal: true,
                        closeText: "關閉",
                        title: "<h4 class='modal-title'><i class='icon-append fa fa-list-ol'></i> " + title + "</h4>",
                        close: function (evt, ui) {
                            $dialog.remove();
                        }
                    });
                }
            });
        };

        $global.showQuestionnaireList = function (url, title) {
            $.post(url, <%= JsonConvert.SerializeObject(_viewModel) %>, function (data) {
                if (data) {
                    var $dialog = $(data);
                    $dialog.dialog({
                        width: "100%",
                        height: "auto",
                        resizable: true,
                        modal: true,
                        closeText: "關閉",
                        title: "<h4 class='modal-title'><i class='icon-append fa fa-list-ol'></i> " + title + "</h4>",
                        close: function (evt, ui) {
                            $dialog.remove();
                        }
                    });
                }
            });
        };

        
        $global.rejectQuestionnaire = function (id) {
            var event = event || window.event;
            var $tr = $(event.target).closest('tr');
            showLoading();
            $.post('<%= Url.Action("RejectQuestionnaire","Interactivity") %>', {'id':id}, function (data) {
                hideLoading();
                if (data.result && !data.message) {
                    $tr.remove();
                }
            });
        };

    });
</script>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonQueryViewModel _viewModel;
    IQueryable<LessonTime> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
        _viewModel = (LessonQueryViewModel)ViewBag.ViewModel;

    }

    IQueryable<LessonTime> coachMarkAttended(IQueryable<LessonTime> items)
    {
        return items.Where(l => l.LessonAttendance != null);
    }

    IQueryable<LessonTime> coachToCommit(IQueryable<LessonTime> items)
    {
        return items.Where(l => l.LessonAttendance == null);
    }


    IQueryable<LessonTime> learnerMarkAttended(IQueryable<LessonTime> items)
    {
        return items.Where(l => l.LessonPlan.CommitAttendance.HasValue);
    }

    IQueryable<LessonTime> learnerToCommit(IQueryable<LessonTime> items)
    {
        return items.Where(l => !l.LessonPlan.CommitAttendance.HasValue);
    }

    String reportCount(int count,String asZero = null)
    {
        return count > 0 ? "(" + count.ToString() + ")" : asZero ?? "--";
    }

</script>
