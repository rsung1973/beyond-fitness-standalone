<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="lessonCommentDialog" title="運動留言板" class="bg-color-darken">
    <div class="col-md-12 block block-drop-shadow">
        <%  Html.RenderPartial("~/Views/CoachFacet/Module/LessonCommentList.ascx",_model.Speaker); %>
    </div>
    <script>
        $('#lessonCommentDialog').dialog({
            width: "600",
            height: "auto",
            resizable: true,
            modal: true,
            closeText: "關閉",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-envelope'></i>  運動留言板</h4>",
            close: function (evt, ui) {
                $('#lessonCommentDialog').remove();
            }
        });
        
    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonComment _model;
    UserProfile _profile;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonComment)this.Model;

        _profile = Context.GetUser();
        if (!_profile.IsSysAdmin())
        {
            _model.Status = (int)Naming.IncommingMessageStatus.已讀;
            models.SubmitChanges();
        }

    }

</script>
