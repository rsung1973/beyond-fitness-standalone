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
<select name="AttendeeID" class="ms employeegroup" multiple="multiple">
    <%--<optgroup label="其他">
                                                        <%  var roles = models.GetTable<UserRoleAuthorization>().Where(r => r.RoleID == (int)Naming.RoleID.Assistant);
                                                            var users = models.GetTable<UserProfile>()
                                                                    .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                                                                    .Where(u => roles.Any(r => r.UID == u.UID));
                                                            foreach (var u in users)
                                                            {   %>
                                                        <option value="<%= u.UID %>"><%= u.FullName() %></option>
                                                        <%  }   %>
                                                    </optgroup>--%>
    <%  foreach (var branch in models.GetTable<BranchStore>())
        {   %>
    <optgroup label="<%= branch.BranchName %>">
        <%  var items = models.GetTable<CoachWorkplace>().Where(w => w.BranchID == branch.BranchID)
                                                                .Select(w => w.ServingCoach)
                                                                .Where(s => s.CoachID != _profile.UID)
                                                                .Where(s => s.UserProfile.LevelID == (int)Naming.MemberStatusDefinition.Checked);
            Html.RenderPartial("~/Views/SystemInfo/ServingCoachOptions.ascx", items);
        %>
    </optgroup>
    <%  }   %>
</select>
<script>
    $(function () {
        $('.employeegroup').multiSelect();
<%  if (_model != null && _model.Length > 0)
    {   %>
        $('.employeegroup').multiSelect('select',<%= JsonConvert.SerializeObject(_model.Select(i => i.ToString()))  %>);
<%  }   %>
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    int[] _model;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = this.Model as int[];
        _profile = Context.GetUser();
    }


</script>
