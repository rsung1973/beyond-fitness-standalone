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

            div {
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
            }

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

<div id="contractAction" class="row text-center">
    <button type="button" name="btnReject" class="btn bg-color-red" onclick="rejectSignature();">
        刪除 <i class='far fa-trash-alt' aria-hidden='true'></i>
    </button>
    <button type="button" name="btnConfirm" class="btn btn-primary" onclick="confirmSignature();">
        確定 <i class="fa fa-paper-plane" aria-hidden="true"></i>
    </button>
</div>
<script>
    function confirmSignature() {
        showLoading();
        $.post('<%= Url.Action("ConfirmSignatureForAmendment","CourseContract",new { _model.RevisionID }) %>',
            {
                'extension': $('input[name="extension"]').is(':checked')
            }, function (data) {
                hideLoading();
                if (data.result) {
                    done = true;
                    $('#contractAction').remove();
                    window.location.href = data.pdf;
                    //alert('簽約完成!!');
                } else {
                    $(data).appendTo($('body')).remove();
                }
            });
    }

    function rejectSignature() {
        if (confirm('確定退件?')) {
            showLoading();
            $.post('<%= Url.Action("DeleteCourseContract","CourseContract",new { _model.CourseContract.ContractID }) %>', {}, function (data) {
                hideLoading();
                if (data.result) {
                    done = true;
                    $('#contractAction').remove();
                    alert('合約已退件!!');
                    window.close();
                } else {
                    $(data).appendTo($('body')).remove();
                }
            });
        }
    }

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContractRevision _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContractRevision)this.Model;
    }

</script>
