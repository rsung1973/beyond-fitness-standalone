<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="healthlistDialog" title="維護健康指數" class="bg-color-darken">
    <!-- content -->
    <div class="row padding-10">
        <form action="<%= Url.Action("CommitHealthAssessment","Activity",new { uid = _model.UID,groupID = 2 }) %>" method="post" class="form-horizontal" autofocus>
            <fieldset>
                <div class="form-group">
                    <div class="col col-sm-12">
                        <label class="input input-group">
                            <i class="icon-append far fa-calendar-alt"></i>
                            <input type="text" class="form-control date form_date" value="<%= String.Format("{0:yyyy/MM/dd}", DateTime.Today) %>" readonly="readonly" data-date-format="yyyy/mm/dd" placeholder="請輸入付款日期" name="assessmentDate" />
                        </label>
                    </div>
                </div>
            </fieldset>
            <fieldset>
                <div class="form-group">
                    <div class="col col-sm-6 col-md-4">
                        <div class="input-group">
                            <span class="input-group-addon">腰</span>
                            <input class="form-control" type="number" step="0.1" placeholder="請輸入純數字" name="_13" value="" />
                            <span class="input-group-addon">CM</span>
                        </div>
                    </div>
                    <div class="col col-sm-6 col-md-4">
                        <div class="input-group">
                            <span class="input-group-addon">腿</span>
                            <input class="form-control" type="number" step="0.1" placeholder="請輸入純數字" name="_14" value="" />
                            <span class="input-group-addon">CM</span>
                        </div>
                    </div>
                    <div class="col col-sm-6 col-md-4">
                        <div class="input-group">
                            <span class="input-group-addon">臂</span>
                            <input class="form-control" type="number" step="0.1" placeholder="請輸入純數字" name="_15" value="" />
                            <span class="input-group-addon">CM</span>
                        </div>
                    </div>
                </div>
            </fieldset>
            <fieldset>
                <div class="form-group">
                    <div class="col col-sm-6 col-md-4">
                        <div class="input-group">
                            <span class="input-group-addon">體重</span>
                            <input class="form-control" type="number" step="0.1" placeholder="請輸入純數字" name="_49" value="" />
                            <span class="input-group-addon">KG</span>
                        </div>
                    </div>
                    <div class="col col-sm-6 col-md-4">
                        <div class="input-group">
                            <span class="input-group-addon">皮脂厚度</span>
                            <input class="form-control" type="number" step="0.1" placeholder="請輸入純數字" name="_50" value="" />
                            <span class="input-group-addon">MM</span>
                        </div>
                    </div>
                    <div class="col col-sm-6 col-md-4">
                        <div class="input-group">
                            <span class="input-group-addon">體脂率</span>
                            <input class="form-control" type="number" step="0.1" placeholder="請輸入純數字" name="_51" value="" />
                            <span class="input-group-addon">%</span>
                        </div>
                    </div>
                </div>
            </fieldset>
            <div class="form-actions">
                <div class="row">
                    <div class="col-md-12">
                        <button class="btn btn-primary" type="button" id="btnSendAssessment">
                            <i class="fa fa fa-reply"></i>更新
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
    <div class="row" id="healthList">
        <%  Html.RenderPartial("~/Views/Activity/HealthIndex.ascx", _model); %>
    </div>
    <!-- end content -->
    <script>
        $('#healthlistDialog').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-history'></i>  維護健康指數</h4>",
            close: function (event, ui) {
                $('#healthlistDialog').remove();
            }
        });

        $('.form_date').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 1,
            clearBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 2,
            minView: 2,
            forceParse: 0
        });

        $('#btnSendAssessment').on('click', function (evt) {

            var form = $(this)[0].form;
            if (!validateForm(form))
                return false;

            showLoading();
            $($(this)[0].form).ajaxSubmit({
                success: function (data) {
                    hideLoading();
                    if (data.result) {
                        $('#healthList').load('<%= Url.Action("HealthIndex","Activity",new { id = _model.UID }) %>', {}, function (data) { });
                    }
                }
            });
        });
    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }

</script>
