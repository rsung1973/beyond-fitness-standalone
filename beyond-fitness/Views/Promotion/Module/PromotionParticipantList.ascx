<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<table id="<%= _tableId %>" class="table table-striped table-bordered table-hover" width="100%">
    <thead>
        <tr>
            <th><i class="fa fa-fw fa-user text-muted hidden-md hidden-sm hidden-xs"></i>學員姓名</th>
            <th>功能</th>
        </tr>
    </thead>
    <tbody>
        <%  var pdqExt = _promotion?.PDQQuestion.FirstOrDefault()?.PDQQuestionExtension;
            foreach (var item in _model)
            {
                %>
        <tr>
            <td><%= item.UserProfile.FullName() %></td>
            <td>
                <%  if (pdqExt?.AwardingAction == (int)Naming.BonusAwardingAction.程式連結
                        /*|| item.PDQTaskBonus.BonusExchange.Any()*/)
                    {
                    }
                    else
                    {   %>
                <a href="#" onclick="deleteParticipant('<%= item.TaskID.EncryptKey() %>');" class="btn btn-circle bg-color-red delete"><i class="fa fa-fw fa-lg fa-trash-alt" aria-hidden="true"></i></a>
                <%  } %>
            </td>
        </tr>
        <%  } %>
    </tbody>
</table>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "participant" + DateTime.Now.Ticks;
    IQueryable<PDQTask> _model;
    PDQGroup _promotion;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<PDQTask>)this.Model;
        _promotion = (PDQGroup)ViewBag.DataItem;
    }

</script>
