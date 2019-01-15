<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="心肺評量標準" class="bg-color-darken">
    <div class="bg-color-darken txt-color-white padding-10">
        <table class="table table-striped table-bordered table-hover" width="100%">
            <thead>
                <tr>
                    <th class="text-center">心肺</th>
                    <th class="text-center">標準(持續時間五分鐘)</th>
                </tr>
                <tr>
                    <th>儲備心律 = 220-年齡-安靜心跳</th>
                    <th>有效訓練心跳率 = 220-年齡-安靜心跳率)*70%+安靜心跳率</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>100</td>
                    <td>145</td>
                </tr>
            </tbody>
        </table>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-anchor'></i>  心肺評量標準</h4>",
            close: function (event, ui) {
                $('#<%= _dialog %>').remove();
            }
        });
    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "diagRule" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
