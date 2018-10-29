<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage2017.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <span class="ribbon-button-alignment">
        <span id="refresh" class="btn btn-ribbon">
            <i class="fa fa-user-secret"></i>
        </span>
    </span>
    <!-- breadcrumb -->
    <ol class="breadcrumb">
        <li>人員管理></li>
        <li>員工管理</li>
    </ol>
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
<%--    <h1 class="page-title txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-user-secret"></i>員工管理
                     <span>>  
                     員工列表
                     </span>
    </h1>--%>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

<div class="row">
                  <!-- NEW WIDGET START -->
                  <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
                     <!-- Widget ID (each widget will need unique ID)-->
                     <div class="jarviswidget jarviswidget-color-darken" id="wid-id-1" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
                        <!-- widget options:
                           usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">
                           
                           data-widget-colorbutton="false"
                           data-widget-editbutton="false"
                           data-widget-togglebutton="false"
                           data-widget-deletebutton="false"
                           data-widget-fullscreenbutton="false"
                           data-widget-custombutton="false"
                           data-widget-collapsed="true"
                           data-widget-sortable="false"
                           
                           -->
                        <header>
                           <span class="widget-icon"> <i class="fa fa-table"></i> </span>
                           <h2>員工列表</h2>
                           <div class="widget-toolbar">
                               <%--<a class="btn btn-primary" onclick="editMember(null,<%= (int)Naming.RoleID.Assistant %>);" href="#"><i class="fa fa-fw fa-user-plus"></i>新增員工</a>--%>
                               <a class="btn btn-primary" onclick="editMember(null,<%= (int)Naming.RoleID.Coach %>);" href="#"><i class="fa fa-fw fa-user-plus"></i>新增員工</a>
                           </div>
                        </header>
                        <!-- widget div-->
                        <div>
                           <!-- widget edit box -->
                           <div class="jarviswidget-editbox">
                              <!-- This area used as dropdown edit box -->
                           </div>
                           <!-- end widget edit box -->
                           <!-- widget content -->
                           <div class="widget-body bg-color-darken txt-color-white no-padding">
                               <% Html.RenderPartial("~/Views/Member/CoachList.ascx", models); %>
                           </div>
                           <!-- end widget content -->
                        </div>
                        <!-- end widget div -->
                     </div>
                     <!-- end widget -->
                  </article>
                  <!-- WIDGET END -->
               </div>

    <script>

        function deleteCoach(uid) {
            $.SmartMessageBox({
                title: "<i class=\"fa fa-fw far fa-trash-alt\" aria-hidden=\"true\"></i> 刪除教練＼員工",
                content: "確定刪除此資料?",
                buttons: '[刪除][取消]'
            }, function (ButtonPressed) {
                if (ButtonPressed == "刪除") {
                    $('<form method="post"/>').appendTo($('body'))
                    .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Member/DeleteCoach") %>' + '?uid=' + uid)
                    .submit();
                }
            });
        }

    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
