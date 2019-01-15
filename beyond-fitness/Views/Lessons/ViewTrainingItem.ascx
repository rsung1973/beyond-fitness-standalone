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
    { %>
        <tr>
            <td><%= _model.TrainingType.BodyParts %> <%= String.IsNullOrEmpty(_model.Description) ? null : "【" + _model.Description + "】" %></td>
            <td><%= !String.IsNullOrEmpty(_model.ActualTurns) ? _model.ActualTurns : "--" %> / <%= !String.IsNullOrEmpty(_model.GoalTurns) ? _model.GoalTurns : "--" %></td>
            <td><%= !String.IsNullOrEmpty(_model.ActualStrength) ? _model.ActualStrength : "--" %> / <%= !String.IsNullOrEmpty(_model.GoalStrength) ? _model.GoalStrength : "--" %></td>
            <td><%= _model.Remark %></td>
        </tr>
<%  }
    else
    { %>
        <tr>
            <td class=" expand"><span class="responsiveExpander"></span>休息時間 <%= _model.BreakIntervalInSecond %>秒</td>
            <td>以上項目重複<%= _model.Repeats %>組</td>
            <td></td>
            <td><%= _model.Remark %></td>
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
