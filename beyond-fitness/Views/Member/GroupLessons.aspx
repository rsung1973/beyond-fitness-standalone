<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
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

                <div class="col-md-10">

                    <!-- Classic Heading -->
                    <h4 class="classic-title"><span class="fa fa-link"> 設定團體學員</span></h4>
                    <!-- Stat Search -->
                    <!-- Start Post -->
                    <% Html.RenderPartial("~/Views/Member/MemberInfo.ascx", _model); %>

                    <!-- TABLE 1 -->
                    <table class="panel panel-default table">
                        <tr class="info">
                            <th class="text-center">建檔日期</th>
                            <th>課程類別</th>
                            <th class="text-center">團體課程</th>
                            <th class="text-center">堂數</th>
                            <th class="text-center">功能</th>
                        </tr>
                        <% foreach (var item in _items)
                            {
                                var currentGroups = models.GetTable<GroupingLesson>().Where(g => g.GroupID == item.RegisterGroupID)
                                    .Join(models.GetTable<RegisterLesson>().Where(r => r.RegisterID != item.RegisterID), g => g.GroupID,
                                        r => r.RegisterGroupID, (g, r) => r); %>
                        <tr>
                            <td class="text-center" rowspan="<%= currentGroups.Count()+1 %>"><%= item.RegisterDate.ToString("yyyy/MM/dd") %></td>
                            <td rowspan="<%= currentGroups.Count()+1 %>"><%= item.LessonPriceType.Description + " " + item.LessonPriceType.ListPrice %></td>
                            <td class="text-center">
                                <i class="fa fa-check-circle" aria-hidden="true"></i><%= item.GroupingMemberCount %>人
                            </td>
                            <td class="text-center" rowspan="<%= currentGroups.Count()+1 %>"><%= item.Lessons %></td>
                            <td class="text-center" rowspan="<%= currentGroups.Count()+1 %>">
                                <%  if (item.GroupingLesson == null || item.GroupingLesson.LessonTime.Count() == 0)
                                    {   %>
                                <a onclick="addGroupingUser(<%= item.RegisterID %>);" class="btn btn-system btn-small">設定<i class="fa fa-users" aria-hidden="true"></i></a>
                                <%  } %>
                            </td>
                        </tr>
                            <%  foreach (var g in currentGroups)
                                { %>
                        <tr>
                            <td class="text-center"><%= g.UserProfile.FullName() %> 
                                <%  if (g.GroupingLesson.LessonTime.Count() == 0)
                                    { %>
                                <a href="<%= VirtualPathUtility.ToAbsolute("~/Member/RemoveGroupUser/") + g.RegisterID %>" class="btn btn-system btn-small">刪除<i class="fa fa-user-times" aria-hidden="true"></i></a>
                                <%  } %>
                            </td>
                        </tr>
                            <%  } %>
                        <%  } %>
                    </table>


                    <div class="tabs-section">

                        <div class="hr1" style="margin: 5px 0px;"></div>

                        <!--<div style="height:60px;border:1px solid #000;">驗證碼區塊</div>-->

                        <div class="hr1" style="margin: 5px 0px;"></div>
                        <a class="btn-system btn-medium" href="<%= VirtualPathUtility.ToAbsolute("~/Member/ListAll") %>">回清單頁 <i class="fa fa-th-list" aria-hidden="true"></i></a>
                        <%--<a href="add-vip-group-verify.htm" class="btn-system btn-medium">確定 <i class="fa fa-thumbs-o-up" aria-hidden="true"></i></a>--%>
                        <!-- End Contact Form -->

                    </div>
                    <!-- End Post -->


                </div>

            </div>
        </div>
    </div>

        <!-- End content -->
    <script>
        $('#vip,#m_vip').addClass('active');
        $('#theForm').addClass('contact-form');

        function addGroupingUser(lessonId) {
            $('form').find('#addUserItem').remove();
            var $modal = $('<div class="form-horizontal modal fade" id="addUserItem" tabindex="-1" role="dialog" aria-labelledby="searchdilLabel" aria-hidden="true" />');
            $('#loading').css('display', 'table');
            $modal.appendTo($('form'))
                .load('<%= VirtualPathUtility.ToAbsolute("~/Member/GroupLessonUsers") %>', { 'lessonId': lessonId }, function () {
                    $('#loading').css('display', 'none');
                    $modal.modal('show');
                });
        }
    </script>
</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    IQueryable<RegisterLesson> _items;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _items = _model.RegisterLesson.Where(r => r.Attended == (int)Naming.LessonStatus.準備上課 && r.GroupingMemberCount > 1);
    }



</script>
