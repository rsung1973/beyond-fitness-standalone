<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <a class="closebutton" data-dismiss="modal"></a>
            </div>
            <div class="modal-body">
                <div class="card">
                    <div class="header">
                        <h2><%= _model.Title %>：<%=_model.ActivityProgram %></h2>
                        <p><%  if ((_model.EndDate - _model.StartDate).TotalDays >= 1)
                                {   %>
                            <%= _model.StartDate.ToString("yyyy/MM/dd") %>~<%= _model.EndDate.ToString("yyyy/MM/dd") %>
                            <%  }
                                else
                                {   %>
                            <%= _model.StartDate.ToString("yyyy/MM/dd HH:mm") %>~<%= _model.EndDate.ToString("HH:mm") %>
                            <%  } %>
                        </p>
                    </div>
                    <div class="body">
                        <%  if (_model.GroupEvent.Count > 1)
                            {   %>
                        <ul class="list-unstyled team-info margin-0">
                            <%  foreach (var r in _model.GroupEvent)
                                {   %>
                           <li>
                               <%   r.UserProfile.PictureID.RenderUserPicture(this.Writer, new { @class = "popfit" }, "images/avatar/noname.png"); %>
                           </li>
                            <%  } %>
                        </ul>
                        <%  } %>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <%  if (_profile.IsAssistant() || _model.UID == _profile.UID)
                    {   %>
                <button type="button" class="btn btn-darkteal btn-round waves-effect" onclick="bookingCustomEvent({'keyID':'<%= _model.EventID.EncryptKey() %>'});"><i class="zmdi zmdi-edit"></i></button>
                <button type="button" class="btn btn-danger btn-round btn-simple btn-round waves-effect waves-red" onclick="javascript:deleteUserEvent('<%= _model.EventID.EncryptKey() %>');"><i class="zmdi zmdi-delete"></i></button>
                <%  } %>
            </div>
        </div>
    </div>
    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserEvent _model;
    CalendarEventQueryViewModel _viewModel;
    String _dialogID = $"userEvent{DateTime.Now.Ticks}";
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserEvent)this.Model;
        _viewModel = (CalendarEventQueryViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser();
    }


</script>
