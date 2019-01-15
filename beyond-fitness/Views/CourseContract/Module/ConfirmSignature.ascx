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
    <%  if (!_model.CourseContractExtension.RevisionTrackingID.HasValue)
        { %>
    <button type="button" name="btnReject" class="btn bg-color-red" onclick="rejectSignature();">
        退件 <i class='fa fa-times' aria-hidden='true'></i>
    </button>
    <%  } %>
    <button type="button" name="btnConfirm" class="btn btn-primary" onclick="confirmSignature();">
        確定 <i class="fa fa-paper-plane" aria-hidden="true"></i>
    </button>
</div>
<script>
    function confirmSignature() {
        showLoading();
        $.post('<%= Url.Action("ConfirmSignature","CourseContract",new { _model.ContractID }) %>',
            {
                'extension': $('input[name="extension"]').is(':checked'),
                'booking': $('input[name="booking"]').is(':checked'),
                'cancel': $('input[name="cancel"]').is(':checked'),
            }, function (data) {
                hideLoading();
                if (data.result) {
                    done = true;
                    $('#contractAction').remove();
                    if (data.pdf) {
                        window.location.href = data.pdf;
                    } else {
                        alert('合約已送審!!');
                        window.close();
                    }
                } else {
                    $(data).appendTo($('body')).remove();
                }
            });
    }

    function rejectSignature() {
        showLoading();
        $.post('<%= Url.Action("ExecuteContractStatus","CourseContract",new { _model.ContractID, Status = (int)Naming.CourseContractStatus.草稿,FromStatus = (int)Naming.CourseContractStatus.待簽名,  Drawback=true }) %>', {}, function (data) {
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

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContract _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
    }

</script>
