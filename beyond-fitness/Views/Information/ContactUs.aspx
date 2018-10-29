<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>


<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
<div id="ribbon">

    <span class="ribbon-button-alignment">
        <span id="refresh" class="btn btn-ribbon">
            <i class="fa fa-envelope"></i>
        </span>
    </span>

    <!-- breadcrumb -->
    <ol class="breadcrumb">
        <li>聯絡我們</li>
    </ol>
</div>
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
    <h1 class="page-title txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-envelope"></i>聯絡我們
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">


    <div class="row">

        <!-- NEW COL START -->
        <article class="col-xs-12 col-sm-12 col-md-8 col-lg-8">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget" id="wid-id-6" data-widget-editbutton="false" data-widget-custombutton="false" data-widget-colorbutton="false" data-widget-editbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
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
                    <span class="widget-icon"><i class="fa fa-edit"></i></span>
                    <h2>填寫相關資訊 </h2>

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

                        <form id="comment-form" action="<%= VirtualPathUtility.ToAbsolute("~/Information/ContactUs") %>" class="smart-form" method="post">

                            <fieldset>
                                <div class="row">
                                    <section class="col col-6">
                                        <label class="input">
                                            <i class="icon-append fa fa-user"></i>
                                            <input type="text" name="userName" class="input-lg" id="userName" placeholder="請輸入您的姓名" />
                                        </label>
                                    </section>
                                    <section class="col col-6">
                                        <label class="input">
                                            <i class="icon-append fa fa-envelope-o"></i>
                                            <input type="email" class="input-lg" name="email" id="email" placeholder="請輸入E-mail"/>
                                        </label>
                                    </section>
                                </div>
                                <section>
                                    <label class="input">
                                        <i class="icon-append fa fa-tag"></i>
                                        <input type="text" name="subject" id="subject" class="input-lg" placeholder="請輸入信件主旨"/>
                                    </label>
                                </section>
                                <section>
                                    <label class="textarea">
                                        <i class="icon-append fa fa-comment"></i>
                                        <textarea rows="4" name="comment" id="comment" placeholder="請輸入詢問內容"></textarea>
                                    </label>
                                </section>
                            </fieldset>

                            <footer>
                                <button type="submit" name="submit" class="btn btn-primary">
                                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                                </button>
                            </footer>

                            <% Html.RenderPartial("~/Views/Shared/Success.ascx"); %>
                        </form>

                    </div>
                    <!-- end widget content -->

                </div>
                <!-- end widget div -->

            </div>
            <!-- end widget -->
        </article>
        <!-- END COL -->

        <!-- NEW COL START -->
        <article class="col-xs-12 col-sm-12 col-md-4 col-lg-4">
            <!-- /well -->
            <div class="well well-sm bg-color-darken txt-color-white padding-10">
                <h5 class="margin-top-0"><i class="fa fa-envelope"></i>聯絡我們</h5>
                <ul class="no-padding no-margin">
                    <ul class="icons-list">
                        <li>
                            <a title="電話" href="tel:+886227152733"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-phone fa-stack-1x"></i></span>(02)2715-2733</a>
                        </li>
                        <li>
                            <a title="地址"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-map-marker fa-stack-1x"></i></span>台北市松山區南京東路四段17號B1</a>
                        </li>
                        <li>
                            <a title="Email" href="mailto:info@beyond-fitness.tw"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-envelope-o fa-stack-1x"></i></span>info@beyond-fitness.tw</a>
                        </li>
                    </ul>
                </ul>
            </div>
            <!-- /well -->
            <!-- /well -->
            <%  Html.RenderPartial("~/Views/Layout/SNS.ascx"); %>
            <!-- /well -->

        </article>
        <!-- END COL -->

    </div>

    <script>

        $(document).ready(function () {

            var $commentForm = $("#comment-form").validate({
                // Rules for form validation
                rules: {
                    userName: {
                        required: true
                    },
                    email: {
                        required: true,
                        email: true
                    },
                    subject: {
                        required: true
                    },
                    comment: {
                        required: true
                    }
                },

                // Messages for form validation
                messages: {
                    userName: {
                        required: '請輸入您的姓名',
                    },
                    email: {
                        required: '請輸入您的 email address',
                        email: '請輸入合法的 email address'
                    },
                    subject: {
                        required: '請輸入您的信件主旨',
                    },
                    comment: {
                        required: '請輸入您的詢問內容'
                    }
                },

                // Ajax form submition
                submitHandler: function (form) {
                    //$("#comment-form").addClass('submited');
                    var data = $(form).serializeObject();
                    data.comment = $('<div>').text(data.comment).html();
                    $.post($(form).prop('action'), data, function (data) {
                            if (data) {
                                $('#successMsg').remove();
                                $(form).append($(data));
                            } 
                    });
                },

                // Do not change code below
                errorPlacement: function (error, element) {
                    error.insertAfter(element.parent());
                }
            });

        })


    </script>
</asp:Content>
