<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="Push Up評量標準" class="bg-color-darken">
    <div class="row bg-color-darken txt-color-white padding-10">
        <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
            <table class="table table-striped table-bordered table-hover" width="100%">
                <thead>
                    <tr>
                        <th class="text-center">年齡</th>
                        <th colspan="3" class="text-center">Push Up 標準(次數)</th>
                    </tr>
                    <tr>
                        <th class="bg-color-blueLight" rowspan="2">男性</th>
                        <th class="text-center">良好</th>
                        <th class="text-center">一般</th>
                        <th class="text-center">稍差</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="bg-color-blueLight">20~29</td>
                        <td>＞ 44</td>
                        <td>35~44</td>
                        <td>＜ 35</td>
                    </tr>
                    <tr>
                        <td class="bg-color-blueLight">30~39</td>
                        <td>＞ 34</td>
                        <td>24~34</td>
                        <td>＜ 24</td>
                    </tr>
                    <tr>
                        <td class="bg-color-blueLight">40~49</td>
                        <td>＞ 29</td>
                        <td>20~29</td>
                        <td>＜ 20</td>
                    </tr>
                    <tr>
                        <td class="bg-color-blueLight">50~59</td>
                        <td>＞ 24</td>
                        <td>15~24</td>
                        <td>＜ 15</td>
                    </tr>
                    <tr>
                        <td class="bg-color-blueLight">60+</td>
                        <td>＞ 19</td>
                        <td>10~19</td>
                        <td>＜ 10</td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
            <table id="standard_dt" class="table table-striped table-bordered table-hover" width="100%">
                <thead>
                    <tr>
                        <th class="text-center">年齡</th>
                        <th colspan="3" class="text-center">Push Up 標準(次數)</th>
                    </tr>
                    <tr>
                        <th class="bg-color-pink" rowspan="2">女性</th>
                        <th class="text-center">良好</th>
                        <th class="text-center">一般</th>
                        <th class="text-center">稍差</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="bg-color-pink">20~29</td>
                        <td>＞ 33</td>
                        <td>17~33</td>
                        <td>＜ 17</td>
                    </tr>
                    <tr>
                        <td class="bg-color-pink">30~39</td>
                        <td>＞ 24</td>
                        <td>12~24</td>
                        <td>＜ 12</td>
                    </tr>
                    <tr>
                        <td class="bg-color-pink">40~49</td>
                        <td>＞ 19</td>
                        <td>8~19</td>
                        <td>＜ 8</td>
                    </tr>
                    <tr>
                        <td class="bg-color-pink">50~59</td>
                        <td>＞ 14</td>
                        <td>6~14</td>
                        <td>＜ 6</td>
                    </tr>
                    <tr>
                        <td class="bg-color-pink">60+</td>
                        <td>＞ 4</td>
                        <td>3~4</td>
                        <td>＜ 3</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-anchor'></i>  Push Up評量標準</h4>",
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
