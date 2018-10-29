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
                <h4 class="modal-title" id="myModalLabel">維護業績所屬體能顧問</h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">
                <label class="text-warning font-md">
                    目前業績所屬體能顧問：
                    <%  foreach(var t in _model.TuitionAchievement)
                        { %>
                            <%= t.ServingCoach.UserProfile.FullName() %>《<%= String.Format("{0:##,###,###,###}",t.ShareAmount) %>》<br />
                    <%  } %>
                    </label>
                <form action="<%= Url.Action("CommitAchievementShare","Member",new { InstallmentID = _model.InstallmentID }) %>" id="shareInstallmentForm" class="smart-form" method="post">
                    <fieldset>
                        <div class="row">
                            <section class="col col-6">
                                <label>業績所屬體能顧問</label>
                                <label class="select">
                                    <%  ViewBag.Inline = true;
                                        Html.RenderPartial("~/Views/Lessons/SimpleCoachSelector.ascx", new InputViewModel { Id = "CoachID", Name = "CoachID" }); %>
                                    <i class="icon-append far fa-keyboard"></i>
                                </label>
                            </section>
                            <section class="col col-6">
                                <label>業績金額</label>
                                <label class="input">
                                    <i class="icon-append fa fa-dollar-sign"></i>
                                    <input type="text" name="ShareAmount" maxlength="7" placeholder="請輸入業績金額" value=""/>
                                </label>
                            </section>
                        </div>
                    </fieldset>
                    <footer>
                        <button id="btnSend" type="button" class="btn btn-primary">
                            送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                        </button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">
                            取消
                        </button>
                    </footer>
                </form>
            </div>
            <!-- /.modal-content -->
        </div>
    </div>
</div>
<script>

    $(function () {
        var $modal = $('#<%= ViewBag.ModalId ?? "theModal" %>');

        $modal.on('hidden.bs.modal', function (evt) {
            $modal.remove();
        });
        
        $modal.modal('show');

        $('#btnSend').on('click', function (evt) {
            var event = event || window.event;
            var $form = $('#shareInstallmentForm');
            $form.ajaxSubmit({
                beforeSubmit: function () {
                    showLoading();
                },
                success: function (data) {
                    if (data.result) {
                        smartAlert("資料已儲存!!", function () {
                            if ($global.reload) {
                                $global.reload();
                            }
                        });
                        $modal.modal('hide');
                    } else {
                        var $data = $(data);
                        $('body').append($data);
                        $data.remove();
                    }
                    hideLoading();
                }
            });
        });

    });
</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    TuitionInstallment _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (TuitionInstallment)this.Model;
        ViewBag.ModalId = "achievementShare";
    }

</script>
