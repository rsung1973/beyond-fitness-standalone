<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="Sqaut/Lunge評量標準" class="bg-color-darken">
    <div class="row bg-color-darken txt-color-white padding-10">
        <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
            <table class="table table-striped table-bordered table-hover" width="100%">
                <thead>
                    <tr>
                        <th class="text-center">年齡</th>
                        <th colspan="3" class="text-center">Squat/ Lunge 標準(次數)</th>
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
                        <td class="bg-color-blueLight">18-25</td>
                        <td>＞ 43</td>
                        <td>35~43</td>
                        <td>＜ 35</td>
                    </tr>
                    <tr>
                        <td class="bg-color-blueLight">26-35</td>
                        <td>＞ 39</td>
                        <td>31~39</td>
                        <td>＜ 31</td>
                    </tr>
                    <tr>
                        <td class="bg-color-blueLight">36-45</td>
                        <td>＞ 34</td>
                        <td>27~34</td>
                        <td>＜ 27</td>
                    </tr>
                    <tr>
                        <td class="bg-color-blueLight">46-55</td>
                        <td>＞ 28</td>
                        <td>22~28</td>
                        <td>＜ 22</td>
                    </tr>
                    <tr>
                        <td class="bg-color-blueLight">56~65</td>
                        <td>＞ 24</td>
                        <td>17~24</td>
                        <td>＜ 17</td>
                    </tr>
                    <tr>
                        <td class="bg-color-blueLight">65+</td>
                        <td>＞ 21</td>
                        <td>15~21</td>
                        <td>＜ 15</td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
            <table id="standard_dt" class="table table-striped table-bordered table-hover" width="100%">
                <thead>
                    <tr>
                        <th class="text-center">年齡</th>
                        <th colspan="3" class="text-center">Squat/ Lunge  標準(次數)</th>
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
                        <td class="bg-color-pink">18-25</td>
                        <td>＞ 36</td>
                        <td>29~36</td>
                        <td>＜ 29</td>
                    </tr>
                    <tr>
                        <td class="bg-color-pink">26-35</td>
                        <td>＞ 32</td>
                        <td>25~32</td>
                        <td>＜ 25</td>
                    </tr>
                    <tr>
                        <td class="bg-color-pink">36-45</td>
                        <td>＞ 26</td>
                        <td>19~26</td>
                        <td>＜ 19</td>
                    </tr>
                    <tr>
                        <td class="bg-color-pink">46-55</td>
                        <td>＞ 21</td>
                        <td>14~21</td>
                        <td>＜ 14</td>
                    </tr>
                    <tr>
                        <td class="bg-color-pink">56-65</td>
                        <td>＞ 17</td>
                        <td>10~17</td>
                        <td>＜ 10</td>
                    </tr>
                    <tr>
                        <td class="bg-color-pink">65+</td>
                        <td>＞ 16</td>
                        <td>11~16</td>
                        <td>＜ 11</td>
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
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-anchor'></i>  Sqaut / Lunge 評量標準</h4>",
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
