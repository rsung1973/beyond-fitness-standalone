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

<%  var items = models.GetTable<TrainingItem>()
        .Where(t => t.ExecutionID == _model.ExecutionID)
        .Where(t => t.TrainingType.TrainingStageItem.StageID == _stage.StageID)
        .OrderBy(t => t.Sequence); %>
<div class="panel panel-default">
    <div class="panel-heading">
        <h4 class="panel-title">
            <a data-toggle="collapse" data-parent="#accordion" href="#<%= _stageID %>">
                <i class="fa fa-fw fa-chevron-circle-right text-pacificblue"></i><i class="fa fa-fw fa-chevron-circle-right text-pacificblue"></i>
                <b>STAGE <%= _stage.StageID %>.<%= _stage.Stage %></b>
                <%  var duration = _model.TrainingExecutionStage.Where(s=>s.StageID==_stage.StageID).FirstOrDefault();
                    if (duration !=null)
                    { %>
                <em class="badge bg-color-pink">
                    <%= String.Format("{0:.#}",duration.TotalMinutes) %> min</em>
                <%  } %>
            </a>
        </h4>
    </div>
    <div id="<%= _stageID %>" class="panel-collapse collapse in">
        <div class="panel-body padding-5">
            <div class="dd no-padding" id="nestable_<%= _stageID %>">
                <ol class="dd-list">
                    <%
                        foreach (var item in items)
                        {
                            if (item.TrainingType.BreakMark != true)
                            { %>
                    <li class="dd-item dd3-item" data-id="<%= item.ItemID %>">
                        <div class="dd-handle dd3-handle">
                            Drag
                        </div>
                        <div class="dd3-content" onclick="editStageTrainingItem(<%= _stage.StageID %>,<%= item.ItemID%>);">
                            <div>
                                <div class="pull-left">
                                    <em class="badge bg-color-yellow"><%= item.TrainingType.BodyParts %></em>
                                </div>
                                <span class="semi-bold">
                                    <%  if (item.TrainingItemAids.Count > 0)
                                        {
                                            Writer.Write(String.Join("、", item.TrainingItemAids.Select(t => t.TrainingAids.ItemName))); %> - 
                                    <%  } %>
                                    <%= item.Description %>&nbsp;
                                </span>
                                <div class="pull-right">
                                    <%  if (item.GoalStrength != null)
                                        { %>
                                    <em class="badge bg-color-yellow"><%: item.GoalStrength %></em> 
                                    <%  } %>
                                    <%  if (item.GoalTurns != null && item.GoalStrength != null)
                                        { %>
                                    X
                                    <%  } %>
                                    <%  if (item.GoalTurns != null)
                                        { %>
                                    <em class="badge bg-color-yellow"><%: item.GoalTurns %></em>
                                    <%  } %>
                                </div>
                            </div>
                            <span><%= item.Remark %></span>
                        </div>
                    </li>
                        <%  }
                            else
                            { %>
                    <li class="dd-item dd3-item line_btm" data-id="<%= item.ItemID %>">
                        <div class="dd-handle dd3-handle">
                            Drag
                        </div>
                        <div class="dd3-content" onclick="editStageBreakInterval(<%= _stage.StageID %>,<%= item.ItemID%>);">
                            <span class="text-danger">&nbsp;</span>
                            <div class="pull-right">
                                <%  if (item.Repeats != null)
                                    { %>
                                <em class="badge bg-color-blueLight">
                                    以上項目重複<%= item.Repeats %>組
                                </em>
                                <%  }
                                    if (item.BreakIntervalInSecond != null)
                                    { %>
                                <em class="badge bg-color-blueLight">
                                    休息<%= item.BreakIntervalInSecond %>秒
                                </em>
                                <%  } %>
                            </div>
                            <span><%= item.Remark %></span>
                        </div>
                    </li>
                        <%  } %>
                    <%  } %>
                    <li class="dd-item dd3-item">
                        <div class="dd3-content">
                            <h4>
                                <a onclick="editStageTrainingItem(<%= _stage.StageID %>);">
                                    <i class="fa fa-plus text-warning"></i>
                                </a>&nbsp;&nbsp;
                                <a onclick="editStageBreakInterval(<%= _stage.StageID %>);" >
                                    <i class="far fa-clock text-warning"></i>
                                </a>
                            </h4>
                        </div>
                    </li>
                </ol>
            </div>
        </div>
    </div>
</div>

<script>

    $('#nestable_<%= _stageID %>').nestable({
        group: <%= _stage.StageID %>,
        maxDepth: 1
    })

</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    TrainingExecution _model;
    String _stageID;
    TrainingStage _stage;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (TrainingExecution)this.Model;
        _stage = (TrainingStage)ViewBag.TrainingStage;
        _stageID = "stage" + DateTime.Now.Ticks + "_" + _stage.StageID;
    }

    int calculateDuration(IEnumerable<TrainingItem> items)
    {
        int totalDuration = 0, duration = 0;
        var regex = new Regex("\\d+");
        foreach (var item in items)
        {
            if (item.TrainingType.BreakMark == true)
            {
                if (item.Repeats != null)
                {
                    var m = regex.Match(item.Repeats);
                    if (m.Success)
                    {
                        duration *= int.Parse(m.Value);
                    }
                }
                totalDuration += duration;
                duration = 0;
            }
            else if (item.DurationInMinutes.HasValue)
            {
                duration += (int)item.DurationInMinutes.Value;
            }
        }

        totalDuration += duration;
        return totalDuration;
    }

</script>
