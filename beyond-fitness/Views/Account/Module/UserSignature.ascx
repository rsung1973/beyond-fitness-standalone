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

<style type="text/css">

            /*div {
                margin-top:1em;
                margin-bottom:1em;
            }
            input {
                padding: .5em;
                margin: .5em;
            }
            select {
                padding: .5em;
                margin: .5em;
            }*/

            #signatureparent {
                color:darkblue;
                background-color:darkgrey;
                /*max-width:600px;*/
                padding:20px;
            }

            /*This is the div within which the signature canvas is fitted*/
            #signature {
                border: 2px dotted black;
                background-color:lightgrey;
            }

            /* Drawing the 'gripper' for touch-enabled devices */ 
            html.touch #content {
                float:left;
                width:92%;
            }
            html.touch #scrollgrabber {
                float:right;
                width:4%;
                margin-right:2%;
                background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAAFCAAAAACh79lDAAAAAXNSR0IArs4c6QAAABJJREFUCB1jmMmQxjCT4T/DfwAPLgOXlrt3IwAAAABJRU5ErkJggg==)
            }
            html.borderradius #scrollgrabber {
                border-radius: 1em;
            }

        </style>


<img onclick="$global.signaturePanel(<%= _model.UID %>);" src="<%= _model.Signature != null ? _model.Signature : VirtualPathUtility.ToAbsolute("~/img/SignHere.png") %>" width="200px" />

<%  String basePath = VirtualPathUtility.ToAbsolute("~/"); %>
<script src="<%= basePath + "js/plugin/jSignature/jSignature.js" %>"></script>
<script src="<%= basePath + "js/plugin/jSignature/plugins/jSignature.CompressorBase30.js" %>"></script>
<script src="<%= basePath + "js/plugin/jSignature/plugins/jSignature.CompressorSVG.js" %>"></script>
<script src="<%= basePath + "js/plugin/jSignature/plugins/jSignature.UndoButton.js" %>"></script>
<script src="<%= basePath + "js/plugin/jSignature/plugins/signhere/jSignature.SignHere.js" %>"></script>

<script>
    $(function () {
        $global.$signatureImage = null;
        $global.signaturePanel = function (uid) {
            var event = event || window.event;
            $global.$signatureImage = $(event.target);
            //showLoading();
            $.post('<%= Url.Action("UserSignaturePanel","Account") %>', { 'uid': uid }, function (data) {
                //hideLoading();
                $(data).appendTo($('body'));
            });
        };

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfileExtension _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfileExtension)this.Model;
    }

</script>
