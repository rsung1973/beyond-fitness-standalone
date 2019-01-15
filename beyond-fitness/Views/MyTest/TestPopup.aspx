<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">
        <article class="col-xs-12 col-sm-12 col-md-9 col-lg-9">
            <div class="modal fade" id="popup" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                <div class="modal-dialog" id="dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                                &times;
                            </button>
                            <h4 class="modal-title" id="myModalLabel">TEST Popup</h4>
                        </div>
                        <div class="modal-body bg-color-darken txt-color-white">
                            <form action="<%= VirtualPathUtility.ToAbsolute("~/MyTest/TestPopup") %>" id="pageForm" class="smart-form" method="post">
                                <fieldset>
                                    <div class="row">
                                        <section class="col col-6">
                                            <label class="input">
                                                <i class="icon-append fa fa-shopping-cart"></i>
                                                <input type="text" name="message" id="message" placeholder="請輸入" />
                                            </label>
                                        </section>
                                    </div>
                                </fieldset>
                                <footer>
                                    <button type="submit" name="submit" class="btn btn-primary">
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
                    <!-- /.modal-dialog -->
                </div>
                <!-- /.modal -->
                <!-- END MAIN CONTENT -->

            </div>

        </article>
    </div>

    <button type="button" class="btn btn-labeled btn-success bg-color-blueLight" onclick="popup();">
        <span class="btn-label">
            <i class="fa fa-calendar-alt-plus-o"></i>
        </span>method 1
    </button>

    <button type="button" class="btn btn-labeled btn-success bg-color-blueLight" data-toggle="modal" data-target="#popup">
        <span class="btn-label">
            <i class="fa fa-calendar-alt-plus-o"></i>
        </span>method 2
    </button>

    <button type="button" class="btn btn-labeled btn-success bg-color-blueLight" onclick="loadPopup();">
        <span class="btn-label">
            <i class="fa fa-calendar-alt-plus-o"></i>
        </span>method 3
    </button>

    <% Html.RenderPartial("~/Views/Lessons/DailyStackView.ascx", new DateTime(2016,8,11)); %>


    <script>
        function popup() {
            $('#popup').modal('show');
        }

        function loadPopup() {
            $('#popup').empty()
                .load('<%= VirtualPathUtility.ToAbsolute("~/MyTest/TestPopup") + " #dialog" %>', function () {
                    $(this).modal('show');
                });
        }

    </script>

</asp:Content>
