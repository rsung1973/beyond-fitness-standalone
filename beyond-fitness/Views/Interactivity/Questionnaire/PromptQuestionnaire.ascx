<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="modal fade" id="promptQuestionnaire" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    &times;
                </button>
                <h4 class="modal-title" id="myModalLabel"><i class="fa-fw fa fa-volume-up"></i> 滿意度問卷</h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="panel panel-default bg-color-darken">
                    <form id="questionnaireForm" method="post" action="<%= Url.Action("Questionnaire","Interactivity",new { id = _model.QuestionnaireID }) %>"  class="smart-form">
                        <div class="panel-body status smart-form vote">
                            <div class="who clearfix">
                                <%  _model.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online", @style = "width:40px" }); %>
                                <span class="name font-lg"><b>Hi, <%= _model.UserProfile.FullName() %></b></span><br />
                                <span class="from font-md">為了讓您的體能顧問做出更優化的階段性調整，下方提供
                &lt;六個小問題&gt;
                請您回答補充，資料僅提供訓練使用，不會外洩，敬請放心填寫！</span>
                            </div>
                        </div>
                        <footer>
                            <button type="submit" id="btnSend" name="submit" class="btn btn-primary">
                                說出您的想法 <i class="fa fa-volume-up" aria-hidden="true"></i>
                            </button>
                        </footer>
                    </form>
                </div>
                <!-- /.modal-content -->
            </div>
        </div>
        <!-- /.modal-content -->
    </div>
    <!-- /.modal-dialog -->
    <script>

        $(function () {

            var $modal = $('#promptQuestionnaire');
            $modal.on('hidden.bs.modal', function (evt) {
                $modal.remove();
            });

<%--        $modal.on('shown.bs.modal', function () {
            $(this).find('.modal-dialog').css({
                width: '100%',
                height: '100%',
                'max-height': '100%'
            });

        });--%>

            $modal.modal('show');

        });
    </script>

</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    QuestionnaireRequest _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (QuestionnaireRequest)this.Model;
    }

</script>
