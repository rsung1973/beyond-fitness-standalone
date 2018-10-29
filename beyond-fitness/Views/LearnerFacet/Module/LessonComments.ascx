<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="col-md-12 block block-drop-shadow" id="chatboard">
    <div class="header">
        <h2><i class="fa fa-envelope"></i>&nbsp;&nbsp; MESSAGING</h2>
    </div>
    <div class="footer">
        <div class="input-group">
            <span class="input-group-addon"><i class="fa fa-comments"></i></span>
            <input type="text" class="form-control" placeholder="message .." name="comment" />
            <span class="input-group-btn">
                <button class="btn" id="btnPushComment"><span class="fa fa-chevron-up"></span></button>
            </span>
        </div>
    </div>
    <div class="content messages npr npb" id="lessonComments">
        <div class="scroll oh">
            <%  foreach (var item in _items)
                {
                    Html.RenderPartial("~/Views/LearnerFacet/Module/LessonCommentItem.ascx", item);
                } %>
            <div></div>
        </div>
    </div>
</div>
<script>
    $('#btnPushComment').on('click', function (evt) {
        var comment = $('input[name="comment"]').val();
        if (comment && comment != '') {
            $('input[name="comment"]').val('');
            showLoading();
            $.post('<%= Url.Action("PushComment","LearnerFacet") %>', {'speakerID':<%= _model.UID %>,'comment':comment},function(data){
                hideLoading();
                if(data) {
                    $('#lessonComments div div:first-child').before(data);
                }
            });
        }
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    IQueryable<LessonComment> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _items = models.GetTable<LessonComment>().Where(c => c.SpeakerID == _model.UID || c.HearerID == _model.UID)
                    .OrderByDescending(c => c.CommentDate);
    }

</script>
