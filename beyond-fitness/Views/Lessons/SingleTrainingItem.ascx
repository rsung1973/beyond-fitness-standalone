<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (String.IsNullOrEmpty(_model.BreakIntervalInSecond))
    {
        var rowSpan = String.IsNullOrEmpty(_model.Remark) ? 1 : 2;  %>
        <tr class="rowIdx">
            <%  if (ViewBag.ShowOnly != true)
                {
                     %>
            <td rowspan="<%= rowSpan %>">
                <a onclick="moveItem('up');">
                    <i class="fa fa-arrow-circle-o-up fa-lg btn btn-xs bg-color-pink"></i>
                </a>&nbsp;
                <a onclick="moveItem('down');">
                    <i class="fa fa-arrow-circle-o-down fa-lg btn btn-xs bg-color-pink"></i>
                </a>&nbsp;
                <a onclick="editTrainingItem(<%= _model.ExecutionID %>,<%= _model.ItemID %>);">
                    <i class="fa fa-pencil-alt text-warning fa-lg btn btn-xs bg-color-orange"></i>
                </a>&nbsp;
                <a onclick="deleteItem(<%= _model.ExecutionID %>,<%= _model.ItemID %>);">
                    <i class="far fa-trash-alt btn btn-xs fa-lg bg-color-redLight"></i>
                </a>
                <input type="hidden" name="ItemID" value="<%= _model.ItemID %>" />
            </td>
            <td><%= _model.TrainingType.BodyParts %><%= String.IsNullOrEmpty(_model.Description) ? null : "【" + _model.Description + "】" %></td>
            <%  }
                else
                { %>
            <td rowspan="<%= rowSpan %>"><%= _model.TrainingType.BodyParts %><%= String.IsNullOrEmpty(_model.Description) ? null : "【" + _model.Description + "】" %></td>
            <%  } %>
            
            <td><%= String.IsNullOrEmpty(_model.ActualTurns) ? "--" : _model.ActualTurns %>/<%= String.IsNullOrEmpty(_model.GoalTurns) ? "--" : _model.GoalTurns %></td>
            <td><%= String.IsNullOrEmpty(_model.ActualStrength) ? "--" : _model.ActualStrength %>/<%= String.IsNullOrEmpty(_model.GoalStrength) ? "--" : _model.GoalStrength %></td>
        </tr>
    <%  if (!String.IsNullOrEmpty(_model.Remark))
        { %>
        <tr class="remark">
            <%  if (ViewBag.ShowOnly != true)
                { %>
                <td colspan="3"><%= _model.Remark %></td>
            <%  }
                else
                {%>
                <td colspan="2"><%= _model.Remark %></td>
            <%  } %>
        </tr>
    <%  } %>
<%  }
    else
    {
        var rowSpan = String.IsNullOrEmpty(_model.Remark) ? 1 : 2;
        if (!String.IsNullOrEmpty(_model.Remark))
        { %>
            <tr class="rowIdx">
        <% }
            else
            { %>
            <tr class="line_btm rowIdx">
        <%}
            if (ViewBag.ShowOnly != true)
            { %>
            <td rowspan="<%= rowSpan %>">
                <a onclick="moveItem('up');">
                    <i class="fa fa-arrow-circle-o-up fa-lg btn btn-xs bg-color-pink"></i>
                </a>&nbsp;
                <a onclick="moveItem('down');">
                    <i class="fa fa-arrow-circle-o-down fa-lg btn btn-xs bg-color-pink"></i>
                </a>&nbsp;
                <a onclick="editBreakInterval(<%= _model.ExecutionID %>,<%= _model.ItemID %>);">
                    <i class="fa fa-pencil-alt text-warning fa-lg btn btn-xs bg-color-orange"></i>
                </a>&nbsp;
                <a onclick="deleteItem(<%= _model.ExecutionID %>,<%= _model.ItemID %>);">
                    <i class="far fa-trash-alt btn btn-xs fa-lg bg-color-redLight"></i>
                </a>
                <input type="hidden" name="ItemID" value="<%= _model.ItemID %>" />
            </td>
            <td>
                <%= String.IsNullOrEmpty(_model.BreakIntervalInSecond) ? null : "休息時間 " + _model.BreakIntervalInSecond + "秒" %></td>
            <%  }
                else
                { %>
            <td rowspan="<%= rowSpan %>">
                <%= String.IsNullOrEmpty(_model.BreakIntervalInSecond) ? null : "休息時間 " + _model.BreakIntervalInSecond + "秒" %></td>
            <%  } %>
            <td colspan="2">以上項目重複<%= _model.Repeats %>組</td>
        <%  if (!String.IsNullOrEmpty(_model.Remark))
            { %>
            <tr class="line_btm remark">
                <%  if (ViewBag.ShowOnly != true)
                { %>
                <td colspan="3"><%= _model.Remark %></td>
            <%  }
                else
                {%>
                <td colspan="2"><%= _model.Remark %></td>
            <%  } %>
            </tr>
        <%  } %>
        </tr>
<%  } %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    TrainingItem _model;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (TrainingItem)this.Model;
    }

</script>
