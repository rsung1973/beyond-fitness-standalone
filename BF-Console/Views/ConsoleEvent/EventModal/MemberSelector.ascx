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
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <a class="closebutton" data-dismiss="modal"></a>
            </div>
            <div class="modal-body">
                <ul class="new_friend_list list-unstyled row">
                    <%  foreach (var item in _model)
                        {   %>
                    <li class="col-lg-4 col-md-4 col-6">
                        <a onclick="<%= _buildSelect(item) %>">
                            <% item.PictureID.RenderUserPicture(this.Writer, new { @class = "img-thumbnail popfit" }, "images/avatar/noname.png"); %>
                            <h6 class="users_name"><%= item.RealName %></h6>
                            <small class="join_date"><%= item.Nickname %></small>
                        </a>
                    </li>
                    <%  } %>
                </ul>
            </div>
        </div>
    </div>
    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<UserProfile> _model;
    String _dialogID = $"attendee{DateTime.Now.Ticks}";
    Func<UserProfile, String> _buildSelect;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<UserProfile>)this.Model;
        _buildSelect = (Func<UserProfile, String>)ViewBag.SelectMember;
    }


</script>
