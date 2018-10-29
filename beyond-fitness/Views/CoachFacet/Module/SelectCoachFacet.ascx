<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="切換體能顧問" class="bg-color-darken">
    <div class="jarviswidget" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
        <div class="panel-group smart-accordion-default" id="accordion">
            <%  foreach (var item in models.GetTable<BranchStore>())
                { %>
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h4 class="panel-title"><a data-toggle="collapse" data-parent="#accordion" href="#collapse<%= item.BranchID %>" class="collapsed"><i class="fa fa-lg fa-angle-down pull-right"></i><i class="fa fa-lg fa-angle-up pull-right"></i><%= item.BranchName %> </a></h4>
                </div>
                <div id="collapse<%= item.BranchID %>" class="<%= !_model.IsCoach() || _model.ServingCoach.CoachWorkplace.Count == 0 || item.BranchID ==_model.ServingCoach.CoachWorkplace.First().BranchID ? "panel-collapse collapse in" : "panel-collapse collapse" %>">
                    <div class="panel-body">
                        <!-- content -->
                        <%  foreach (var coach in item.CoachWorkplace.Select(w => w.ServingCoach))
                            { %>
                        <div class="user">
                            <a href="javascript:selectCoach(<%= coach.CoachID %>,'<%= coach.CoachID == _model.UID ? "我" : coach.UserProfile.FullName() %>');">
                                <%  coach.UserProfile.RenderUserPicture(Writer, new { @class = "" }); %><%= coach.UserProfile.RealName %>
                            </a>
                            <div class="email">
                                <%= coach.UserProfile.Nickname %>
                            </div>
                        </div>
                        <%  } %>
                        <!-- end content -->
                    </div>
                </div>
            </div>
            <%  } %>
        </div>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: true,
            modal: true,
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-exchange'></i>  切換行事曆</h4>",
            buttons: [<%-- {
                html: "<i class='fa fa-road'></i>&nbsp;查看全部",
                "class": "btn btn-primary",
                click: function () {
                    selectCoach(null, '全部');
                }
            },--%> {
                html: "<i class='fa fa-undo'></i>&nbsp; 回到我的行事曆",
                "class": "btn btn-primary",
                click: function () {
                    selectCoach(<%= _model.UID %>, '我');
                }
            }],
            close: function (event, ui) {
                $('#<%= _dialog %>').remove();
            }
        });

    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "coachForFacet" + DateTime.Now.Ticks;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }

</script>
