<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <uc1:PageBanner runat="server" ID="PageBanner" Title="會員專區" TitleInEng="VIP" />

    <!-- Start Content -->
    <div id="content">
        <div class="container">

            <div class="row">

                <div class="col-md-12">

                    <!-- Classic Heading -->
                    <h4 class="classic-title"><span>人員管理</span></h4>

                    <!-- Start Contact Form -->
                    <!-- Stat Search -->
                    <div class="navbar bg_gray" style="min-height: 30px;">
                        <div class="search-side">
                            <a class="btn-system btn-small" href="<%= VirtualPathUtility.ToAbsolute("~/Member/AddCoach") %>">新增教練 <span class="fa fa-user-plus"></span></a>
                            <a class="btn-system btn-small" href="<%= VirtualPathUtility.ToAbsolute("~/Member/AddLearner") %>">新增學員 <span class="fa fa-user-plus"></span></a>
                            <a class="btn btn-search" data-toggle="modal" data-target="#searchdil" data-whatever="搜尋"><i class="fa fa-search"></i></a>
                        </div>
                    </div>
                    <ul class="nav nav-tabs">
                        <li class='<%= _model.RoleID==Naming.RoleID.Coach ? "active" : null %>'><a id="toggleCoach" href="#tab-coach" data-toggle="tab"><i class="fa fa-th-list"></i>教練清單</a></li>
                        <li class='<%= _model.RoleID==Naming.RoleID.Learner ? "active" : null %>'><a id="toggleLearner" href="#tab-learner" data-toggle="tab"><i class="fa fa-th-list" aria-hidden="true"></i>學員清單</a></li>
                    </ul>
                    <!-- Tab panels -->
                    <div class="tab-content">
                        <!-- Tab Content 1 -->
                        <div class="<%= _model.RoleID==Naming.RoleID.Coach ? "tab-pane fade in active" : "tab-pane fade" %>" tab-pane fade in active" id="tab-coach">
                            <% Html.RenderPartial("~/Views/Member/ListCoaches.ascx", models); %>
                        </div>
                        <!-- Tab Content 2 -->
                        <div class="<%= _model.RoleID==Naming.RoleID.Learner ? "tab-pane fade in active" : "tab-pane fade" %>" id="tab-learner">
                            <%  if (_model.RoleID == Naming.RoleID.Learner)
                                {
                                    Html.RenderAction("ListLearners", _model);
                                } %>
                        </div>
                    </div>
                    <!-- End Contact Form -->
                </div>
                <% Html.RenderPartial("~/Views/Shared/AlertMessage.ascx"); %>
            </div>
        </div>
    </div>
    <!-- End content -->
    <div class="form-horizontal modal fade" id="searchdil" tabindex="-1" role="dialog" aria-labelledby="searchdilLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                    <h4 class="modal-title" id="searchdilLabel"><span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span>搜尋</h4>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label for="exampleInputFile" class="col-md-2 control-label">依學員：</label>
                        <div class="col-md-10">
                            <input class="form-control" name="byName" type="text" value=""/>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-system btn-sm" name="btnQuery" id="btnQuery" ><span class="glyphicon glyphicon-ok" aria-hidden="true"></span>確認</button>
                        <button type="button" class="btn btn-default btn-sm" data-dismiss="modal"><span class="glyphicon glyphicon-log-out" aria-hidden="true"></span>取消</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <% Html.RenderPartial("~/Views/Shared/AlertMessage.ascx"); %>
    <% Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>

    <script>
        $('#vip,#m_vip').addClass('active');
        $('#theForm').addClass('contact-form');

        function deleteCoach(uid) {
            confirmIt({ title: '刪除教練', message: '確定刪除此教練資料?' }, function (evt) {
                $('<form method="post"/>').appendTo($('body'))
                    .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Member/Delete") %>' + '?uid=' + uid)
                    .submit();
            });
        }

        function deleteLearner(uid) {
            confirmIt({ title: '刪除學員', message: '確定刪除此學員資料?' }, function (evt) {
                $('<form method="post"/>').appendTo($('body'))
                    .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Member/Delete") %>' + '?uid=' + uid)
                    .submit();
            });
        }

        $('.nav-tabs').on('shown.bs.tab', function (evt) {
            //console.log(evt.target);
            //console.log(evt.relatedTarget);
            startLoading();
            if ($(evt.target).prop('id') == 'toggleLearner') {
                $.post('<%= VirtualPathUtility.ToAbsolute("~/Member/ChangeRoleList") %>', { 'roleID' : <%= (int)Naming.RoleID.Coach  %>},function(data) {
                    $('#loading').css('display', 'none');
                    $('#searchdil').modal('show');
                });
            } else if ($(evt.target).prop('id') == 'toggleCoach') {
                $.post('<%= VirtualPathUtility.ToAbsolute("~/Member/ChangeRoleList") %>', { 'roleID' : <%= (int)Naming.RoleID.Coach  %>},function(data) {
                    $('#loading').css('display', 'none');
                });
            }
        });

        $('#btnQuery').on('click', function (evt) {
            $('#loading').css('display', 'table');
            $('#tab-learner').load('<%= VirtualPathUtility.ToAbsolute("~/Member/ListLearners") %>', { 'byName': $('input[name="byName"]').val() }, function () {
                $('#searchdil').modal('hide');
                $('#loading').css('display', 'none');
            });
        });

    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    MembersQueryViewModel _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (MembersQueryViewModel)this.Model;
    }




</script>
