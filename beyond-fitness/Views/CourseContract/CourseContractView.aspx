<%@ Page Title="" Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <!--<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">-->
    <title>BEYOND FITNESS</title>
    <meta name="description" content="">
    <meta name="author" content="">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <!-- Basic Styles -->
    <link rel="stylesheet" type="text/css" media="screen" href="~/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" media="screen" href="~/fonts/fontawesome5.0/css/fontawesome-all.css">
    <!-- SmartAdmin Styles : Caution! DO NOT change the order -->
    <link rel="stylesheet" type="text/css" media="screen" href="~/css/smartadmin-production-plugins-20180501.min.css">
    <link rel="stylesheet" type="text/css" media="screen" href="~/css/smartadmin-production-20180501.min.css">
    <link rel="stylesheet" type="text/css" media="screen" href="~/css/smartadmin-skins.min.css">
    <!-- SmartAdmin RTL Support -->
    <link rel="stylesheet" type="text/css" media="screen" href="~/css/smartadmin-rtl.min.css">
    <!-- We recommend you use "your_style.css" to override SmartAdmin
         specific styles this will also ensure you retrain your customization with each SmartAdmin update.-->
    <link rel="stylesheet" type="text/css" media="screen" href="~/css/beyond_style.css">


    <!-- PACE LOADER - turn this on if you want ajax loading to show (caution: uses lots of memory on iDevices)-->
    <% Html.RenderPartial("~/Module/Common/CommonScriptInclude.ascx"); %>

    <%  String basePath = VirtualPathUtility.ToAbsolute("~/"); %>
    <script src="<%= basePath + "js/plugin/jSignature/jSignature.js" %>"></script>
    <script src="<%= basePath + "js/plugin/jSignature/plugins/jSignature.CompressorBase30.js" %>"></script>
    <script src="<%= basePath + "js/plugin/jSignature/plugins/jSignature.CompressorSVG.js" %>"></script>
    <script src="<%= basePath + "js/plugin/jSignature/plugins/jSignature.UndoButton.js" %>"></script>
    <script src="<%= basePath + "js/plugin/jSignature/plugins/signhere/jSignature.SignHere.js" %>"></script>

</head>

<body class="smart-style-2 no-menu">
    <div id="main" role="main">
        <!-- MAIN CONTENT -->
        <div id="content">
            <%  Html.RenderPartial("~/Views/CourseContract/Module/CourseContractView.ascx", _model);
                if (ViewBag.ContractAction != null)
                {
                    Html.RenderPartial((String)ViewBag.ContractAction,_model);
                } %>

            <%--<div class="row text-center">
                <button type="cancel" name="cancel" class="btn">
                    退件 <i class="fa fa-times" aria-hidden="true"></i>
                </button>
                <button type="submit" name="submit" class="btn btn-primary" onclick="javascript:window.location.href='contract_cpb.pdf'">
                    確認審核 <i class="fa fa-check" aria-hidden="true"></i>
                </button>
            </div>--%>
        </div>
    </div>
<%--    <%= _msg %>--%>
</body>
</html>
<% Html.RenderPartial("~/Views/Shared/GlobalScript.ascx"); %>
<script>
    var done = false;
    var $signatureImage;
    function signaturePanel(contractID, uid, signatureName) {
        if (done)
            return;
        var event = event || window.event;
        $signatureImage = $(event.target);
        //showLoading();
        $.post('<%= Url.Action("SignaturePanel","CourseContract") %>', { 'contractID': contractID, 'uid': uid, 'signatureName': signatureName }, function (data) {
            //hideLoading();
            $(data).appendTo($('body'));
        });
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContract _model;
    String _msg = DateTime.Now.Ticks.ToString();
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
        ViewBag.ScrollUp = false;
    }

</script>
