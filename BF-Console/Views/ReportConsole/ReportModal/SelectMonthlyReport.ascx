﻿<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5>更多查詢條件</h5>
                <a class="closebutton" data-dismiss="modal"></a>
            </div>
            <div class="modal-body">
                <div class="row clearfix">
                    <div class="col-12">
                        <div class="card action_bar">
                            <div class="body">
                                <div class="row clearfix">
                                    <div class="col-12">
                                        <div class="input-group">
                                            <input type="text" class="form-control month" data-date-format="yyyy/mm" readonly="readonly" placeholder="查詢月份" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-time"></i>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-darkteal btn-round waves-effect"><i class="zmdi zmdi-download"></i></button>
            </div>
        </div>
    </div>
    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
    <script>
        $(function () {

            $('.month').datetimepicker({
                language: "zh-TW",
                weekStart: 1,
                todayBtn: 0,
                clearBtn: 1,
                autoclose: 1,
                todayHighlight: true,
                startView: 3,
                minView: 3,
                defaultView: 2,
                forceParse: 0,
                endDate: new Date(),
                autoclose: true
            });

            $('#<%= _dialogID %> button').on('click', function (event) {
                var dateVal = $('#<%= _dialogID %> input:text').val();
                if (dateVal != '') {
                    dateVal = dateVal + '/01';
                    if ($global.doQuery) {
                        $('#<%= _dialogID %>').modal('hide');
                        $global.doQuery(dateVal);
                    }
                }
            });
        });
    </script>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialogID = $"reportQuery{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }


</script>