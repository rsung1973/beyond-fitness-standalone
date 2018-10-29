<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="panel-group smart-accordion-default" id="accordion">
    <%  foreach (var item in models.GetTable<BranchStore>())
        {
            if (_profile.IsManager() || _profile.IsViceManager())
            {
                if (!item.CoachWorkplace.Any(w => w.CoachID == _profile.UID))
                    continue;
            }   %>
    <div class="panel panel-default">
        <div class="panel-heading">
            <h4 class="panel-title">
                <label class="checkbox-inline padding-10">
                    <input type="checkbox" class="checkbox style-3" name="checkAll" value="<%= item.BranchID %>" />
                    <span class="text-muted">依分店-<%= item.BranchName %>查詢</span>
                </label>
                <a data-toggle="collapse" data-parent="#accordion" href="#collapseArena<%= item.BranchID %>" class="collapsed"><i class="fa fa-lg fa-angle-down pull-right"></i><i class="fa fa-lg fa-angle-up pull-right"></i>體能顧問列表 </a>
            </h4>
        </div>
        <div id="collapseArena<%= item.BranchID %>" class="panel-collapse collapse">
            <%  var coaches = item.CoachWorkplace.Select(w => w.ServingCoach).ToArray(); %>
            <div class="panel-body">
                <div class="row">
                    <%  for (int c = 0; c < 4; c++)
                        { %>
                    <div class="col col-3">
                        <%  for (int i = c; i < coaches.Length; i += 4)
                            { %>
                        <label class="checkbox">
                            <input type="checkbox" name="ByCoachID" value="<%= coaches[i].CoachID %>">
                            <i></i><%= coaches[i].UserProfile.FullName() %></label>
                        <%  } %>
                    </div>
                    <%  } %>
                </div>
            </div>
        </div>
    </div>
    <%  } %>
</div>
<script>
    $(function () {
        $('#accordion div.panel-collapse.collapse').eq(0).addClass('in');
        $('#accordion input:checkbox').on('click', function (evt) {
            var $this = $(this);
            $('#collapseArena' + $this.val() + ' input:checkbox').prop('checked', $this.is(':checked'));
            //$('#accordion input:checkbox').prop('checked', false);
            //if ($this.is(':checked')) {
            //    $('#collapseArena' + $this.val() + ' input:checkbox').prop('checked', true);
            //    //$('#accordion div.panel-collapse.collapse').removeClass('in');
            //    //$this.parent().parent().next().addClass('in');
            //}
        });
    });
</script>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;

        _profile = Context.GetUser();
    }

</script>
