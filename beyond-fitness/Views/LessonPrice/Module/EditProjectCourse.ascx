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

<div id="<%= _dialog %>" title="編輯專案價目表" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitProjectCourse","LessonPrice",new { _viewModel.PriceID }) %>" class="smart-form" method="post" autofocus>
            <fieldset>
                <section>
                    <label class="label">專案名稱</label>
                    <label class="input">
                        <i class="icon-append far fa-copy"></i>
                        <input type="text" name="Description" maxlength="40" placeholder="請輸入專案名稱" value="<%= _viewModel.Description %>" />
                    </label>
                </section>
            </fieldset>
            <fieldset>
                <section>
                    <label class="label">價格</label>
                    <label class="input">
                        <i class="icon-append far fa-copy"></i>
                        <input type="number" name="ListPrice" maxlength="20" placeholder="請輸入價格" value="<%= _viewModel.ListPrice %>" />
                    </label>
                </section>
            </fieldset>
            <fieldset>
                <div class="row">
                    <section class="col col-4">
                        <label class="label">分店</label>
                        <label class="select">
                            <select name="BranchID">
                                <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.cshtml", model: _viewModel.BranchID ?? -1); %>
                            </select>
                            <i class="icon-append fa fa-at"></i>
                        </label>
                        <script>
                            $('#<%= _dialog %> select[name="BranchID"]').val('<%= _viewModel.BranchID %>')
                        </script>
                    </section>
                    <section class="col col-4">
                        <label class="label">時間長度</label>
                        <label class="select">
                            <select name="DurationInMinutes">
                                <option value="60">60分鐘</option>
                                <option value="90">90分鐘</option>
                            </select>
                            <i class="icon-append far fa-clock"></i>
                        </label>
                        <script>
                            $('select[name="DurationInMinutes"]').val('<%= _viewModel.DurationInMinutes %>')
                        </script>
                    </section>
                    <section class="col col-4">
                        <label class="label">狀態</label>
                        <label class="select">
                            <select name="Status">
                                <option value="0">已停用</option>
                                <option value="1">已啟用</option>
                            </select>
                            <i class="icon-append far fa-clock"></i>
                        </label>
                        <script>
                            $('#<%= _dialog %> select[name="Status"]').val('<%= _viewModel.Status %>')
                        </script>
                    </section>
                </div>
            </fieldset>
        </form>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: true,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i>  編輯專案價目表</h4></div>",
            buttons: [
    <%  if (_model != null && _model.RegisterLesson.Count == 0 && _model.CourseContract.Count == 0)
        {       %>
            {
                html: "<i class='far fa-trash-alt' aria-hidden='true'></i>&nbsp; 刪除",
                "class": "btn bg-color-red",
                click: function () {

                    if (confirm('確定刪除此價目項次?')) {
                        startLoading();
                        $.post('<%= Url.Action("DeleteLessonPrice", "LessonPrice",new { _viewModel.PriceID }) %>', { }, function (data) {
                            hideLoading();
                            if (data.result) {
                                alert('價目已刪除!!');
                                $('#<%= _dialog %>').dialog('close');
                                $global.renderProjectCourse();
                            } else {
                                alert(data.message);
                            }
                        });
                    }
                }
            },
    <%  }   %>
            {
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 確定",
                "class": "btn btn-primary",
                click: function () {
                    var $form = $('#<%= _dialog %> form');
                    clearErrors();
                    $form.ajaxSubmit({
                        beforeSubmit: function () {
                            showLoading();
                        },
                        success: function (data) {
                            hideLoading();
                            if ($.isPlainObject(data)) {
                                if (data.result) {
                                    alert('資料已儲存!!');
                                    $('#<%= _dialog %>').dialog('close');
                                    $global.renderProjectCourse();
                                } else {
                                    alert(data.message);
                                }
                            } else {
                                $(data).appendTo($('body')).remove();
                            }
                        }
                    });
                }
            }],
            close: function () {
                $('#<%= _dialog %>').remove();
            }

        });

        <%  if (_model != null && (_model.RegisterLesson.Count > 0 || _model.CourseContract.Count > 0))
        {   %>

        $(function () {
            $('#<%= _dialog %> input').each(function (idx, element) {
                var $this = $(this);
                $this.attr('readOnly', 'readOnly');
            });

            $('#<%= _dialog %> select[name!="Status"]').each(function (idx, element) {
                var $this = $(this);
                var $option = $this.find('option:selected');
                $this.empty().append($option);
            });
        });
    <%  } %>

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "projectCourse" + DateTime.Now.Ticks;
    LessonPriceQueryViewModel _viewModel;
    LessonPriceType _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (LessonPriceQueryViewModel)ViewBag.ViewModel;
        _model = (LessonPriceType)this.Model;
    }

</script>
