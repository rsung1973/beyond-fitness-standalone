﻿<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog" aria-labelledby="exampleModalLongTitle" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <a class="closebutton" data-dismiss="modal"></a>
            <div class="modal-body">
                <form>
                    <div class="row clearfix">
                        <div class="col-12">
                            <div class="card">
                                <div class="header">
                                    <h2><strong>基本資料</strong>
                                        <input id="checkbox22" type="checkbox" name="OwnerID" value="<%= _viewModel.UID  %>" <%= _viewModel.OwnerID==_viewModel.UID ? "checked" : null %> />
                                        <label for="checkbox22" class="col-red">主簽約人</label>
                                    </h2>
                                </div>
                                <div class="body">
                                    <div class="row clearfix">
                                        <div class="col-sm-6 col-12">
                                            <div class="input-group">
                                                <input type="text" class="form-control form-control-danger" placeholder="真實姓名" name="RealName" value="<%= _viewModel.RealName %>" />
                                                <span class="input-group-addon">
                                                    <i class="zmdi zmdi-account-circle"></i>
                                                </span>
                                            </div>
                                            <%--<label class="material-icons help-error-text">clear 請輸入真實姓名</label>--%>
                                        </div>
                                        <div class="col-sm-6 col-12">
                                            <div class="input-group">
                                                <input type="text" class="form-control form-control-danger" placeholder="暱稱" name="Nickname" value="<%= _viewModel.Nickname %>" />
                                                <span class="input-group-addon">
                                                    <i class="zmdi zmdi-comment-edit"></i>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-sm-3 col-12">
                                            <div class="input-group">
                                                <input type="text" class="form-control date" data-date-format="yyyy/mm/dd" readonly="readonly" placeholder="出生" name="Birthday" value="<%= $"{_viewModel.Birthday:yyyy/MM/dd}" %>" />
                                                <span class="input-group-addon xl-slategray">
                                                    <i class="zmdi zmdi-time"></i>
                                                </span>
                                            </div>
                                            <%--<label class="material-icons help-error-text">clear 請輸入出生</label>--%>
                                        </div>
                                        <div class="col-sm-3 col-12">
                                            <select class="form-control show-tick" name="Gender">
                                                <option value="">- 請選擇性別 -</option>
                                                <option value="M">男</option>
                                                <option value="F">女</option>
                                            </select>
                                            <script>
                                                $('select[name="Gender"]').val('<%= _viewModel.Gender %>')
                                            </script>
                                            <%--<label class="material-icons help-error-text">clear 請選擇性別</label>--%>
                                        </div>
                                        <div class="col-sm-3 col-12">
                                            <div class="input-group">
                                                <input type="text" class="form-control form-control-danger" placeholder="身分證字號" name="IDNo" value="<%= _viewModel.IDNo %>" />
                                                <span class="input-group-addon">
                                                    <i class="zmdi zmdi-text-format"></i>
                                                </span>
                                            </div>
                                            <%--<label class="material-icons help-error-text">clear 請輸入身分證字號/護照號碼</label>--%>
                                        </div>
                                        <div class="col-sm-3 col-12">
                                            <div class="input-group">
                                                <input type="text" class="form-control form-control-danger" placeholder="聯絡電話" name="Phone" value="<%= _viewModel.Phone %>" />
                                                <span class="input-group-addon">
                                                    <i class="zmdi zmdi-smartphone"></i>
                                                </span>
                                            </div>
                                            <%--<label class="material-icons help-error-text">clear 請輸入聯絡電話</label>--%>
                                        </div>
                                        <div class="col-sm-6 col-12">
                                            <select class="form-control show-tick" name="AdministrativeArea">
                                                <option value="">- 請選擇縣市 -</option>
                                                <option value="基隆市">基隆市</option>
                                                <option value="臺北市">臺北市</option>
                                                <option value="新北市">新北市</option>
                                                <option value="桃園市">桃園市</option>
                                                <option value="新竹市">新竹市</option>
                                                <option value="新竹縣">新竹縣</option>
                                                <option value="苗栗縣">苗栗縣</option>
                                                <option value="臺中市">臺中市</option>
                                                <option value="彰化縣">彰化縣</option>
                                                <option value="南投縣">南投縣</option>
                                                <option value="雲林縣">雲林縣</option>
                                                <option value="嘉義市">嘉義市</option>
                                                <option value="嘉義縣">嘉義縣</option>
                                                <option value="臺南市">臺南市</option>
                                                <option value="高雄市">高雄市</option>
                                                <option value="屏東縣">屏東縣</option>
                                                <option value="臺東縣">臺東縣</option>
                                                <option value="花蓮縣">花蓮縣</option>
                                                <option value="宜蘭縣">宜蘭縣</option>
                                                <option value="澎湖縣">澎湖縣</option>
                                                <option value="金門縣">金門縣</option>
                                                <option value="連江縣">連江縣</option>
                                            </select>
                                            <script>
                                                $(function () {
                                                    $('select[name="AdministrativeArea"]').val('<%= _viewModel.AdministrativeArea %>');
                                                });
                                            </script>
                                            <%--<label class="material-icons help-error-text">clear 請選擇縣市</label>--%>
                                        </div>
                                        <div class="col-12">
                                            <div class="form-group">
                                                <textarea rows="4" class="form-control no-resize" name="Address" placeholder="居住地址"><%= _viewModel.Address %></textarea>
                                            </div>
                                            <%--<label class="material-icons help-error-text">clear 請輸入居住地址</label>--%>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-12">
                            <div class="card xl-pink">
                                <div class="header">
                                    <h2><strong>緊急聯絡人資料</strong></h2>
                                </div>
                                <div class="body">
                                    <div class="row clearfix">
                                        <div class="col-sm-4 col-12">
                                            <div class="input-group">
                                                <input type="text" class="form-control form-control-danger" placeholder="緊急聯絡人" name="EmergencyContactPerson" value="<%= _viewModel.EmergencyContactPerson %>" />
                                                <span class="input-group-addon xl-pink">
                                                    <i class="zmdi zmdi-account-circle"></i>
                                                </span>
                                            </div>
                                            <%--<label class="material-icons help-error-text">clear 請輸入緊急聯絡人</label>--%>
                                        </div>
                                        <div class="col-sm-4 col-12">
                                            <select class="form-control show-tick" name="Relationship">
                                                <option value="">- 請選擇關係 -</option>
                                                <option>父母</option>
                                                <option>親子</option>
                                                <option>夫婦</option>
                                                <option>兄弟姊妹</option>
                                                <option>朋友</option>
                                            </select>
                                            <script>
                                                $(function () {
                                                    $('select[name="Relationship"]').val('<%= _viewModel.Relationship %>');
                                                });
                                            </script>
                                            <%--<label class="material-icons help-error-text">clear 請選擇關係</label>--%>
                                        </div>
                                        <div class="col-sm-4 col-12">
                                            <div class="input-group">
                                                <input type="text" class="form-control form-control-danger" placeholder="緊急聯絡人電話" name="EmergencyContactPhone" value="<%= _viewModel.EmergencyContactPhone %>" />
                                                <span class="input-group-addon xl-pink">
                                                    <i class="zmdi zmdi-smartphone"></i>
                                                </span>
                                            </div>
                                            <%--<label class="material-icons help-error-text">clear 請輸入緊急聯絡人電話</label>--%>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-darkteal btn-round waves-effect" onclick="commitContractMember();"><i class="zmdi zmdi-edit"></i></button>
                <button type="button" class="btn btn-danger btn-round btn-simple btn-round waves-effect waves-red swal-delete"><i class="zmdi zmdi-delete"></i></button>
            </div>
        </div>
    </div>
    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
    <script>
        $(function () {

        });

        function commitContractMember() {
            clearErrors();
            var viewModel = <%= JsonConvert.SerializeObject(_viewModel) %>;
            var $formData = $('#<%= _dialogID %> form').serializeObject();
            showLoading();
            $.post('<%= Url.Action("CommitContractMember", "ContractConsole") %>', $.extend({}, viewModel, $formData), function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    alert(data.message);
                } else {
                    $(data).appendTo($('body'));
                }
            });
        }

    </script>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialogID = $"contractMember{DateTime.Now.Ticks}";
    ContractMemberViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (ContractMemberViewModel)ViewBag.ViewModel;
        _viewModel.DialogID = _dialogID;
    }


</script>