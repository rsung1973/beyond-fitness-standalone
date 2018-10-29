<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="modal fade" id="<%= ViewBag.ModalId ?? "theModal" %>" tabindex="-1" role="dialog" aria-labelledby="confirmLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    &times;
                </button>
                <h4 class="modal-title" id="myModalLabel">修改個人近況</h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">

                <fieldset>
                    <div class="form-group">
                        <textarea class="form-control" placeholder="請輸入個人近況" rows="10" name="recentStatus"><%= _model.RecentStatus %></textarea>
                        <p class="note"><strong>Note:</strong> 最多輸入250個中英文字</p>
                    </div>

                </fieldset>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">
                    取消
                </button>
                <button type="button" class="btn btn-primary">
                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                </button>
            </div>
        </div>
    </div>
</div>
<script>

    $(function () {
        var $modal = $('#<%= ViewBag.ModalId ?? "theModal" %>');

        $modal.on('hidden.bs.modal', function (evt) {
            $modal.remove();
        });

        $modal.find('button.btn-primary').on('click', function (evt) {
            commitRecentStatus(<%= _model.UID %>,$modal.find('textarea').val());
            $modal.modal('hide');
        });
        
        $modal.modal('show');
    });
</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        ViewBag.ModalId = "editRecentStatus";
    }

</script>
