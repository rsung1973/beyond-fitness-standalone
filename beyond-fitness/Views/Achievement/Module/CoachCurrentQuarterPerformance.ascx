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

<div id="<%= _dialogID %>" title="業績列表" class="bg-color-darken">
    <!-- Widget ID (each widget will need unique ID)-->
    <div class="jarviswidget jarviswidget-color-darken" id="wid-id-2" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
        <div>
            <!-- widget edit box -->
            <div class="jarviswidget-editbox">
                <!-- This area used as dropdown edit box -->
            </div>
            <!-- end widget edit box -->
            <!-- widget content -->
            <div class="widget-body bg-color-darken txt-color-white no-padding">
                <table id="<%= _tableId %>" class="table table-striped table-bordered table-hover" width="100%">
                    <thead>
                        <tr>
                            <th data-class="expand">月份</th>
                            <th style="white-space:nowrap;">上課堂數</th>
                            <th>上課金額（含稅）</th>
                            <th>業績金額（含稅）</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%                  
                            decimal totalCount = 0, summary = 0, totalShares = 0, subtotal = 0;

                            for (DateTime start = _viewModel.AchievementDateFrom.Value; start <= _viewModel.AchievementDateTo; start = start.AddMonths(1))
                            {
                                DateTime to = start.AddMonths(1);
                                var items = _model.Where(t => t.ClassTime >= start && t.ClassTime < to);
                                var tuitionItems = _items.Where(a => a.Payment.PayoffDate >= start && a.Payment.PayoffDate < to);
                                var attendanceCount = items.Count() - (decimal)(items
                                        .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自主訓練
                                            || (t.RegisterLesson.RegisterLessonEnterprise != null
                                                && t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.DocumentLevelDefinition.自主訓練)).Count()) / 2m;
                                totalCount += attendanceCount;
                        %>
                        <tr>
                            <td><%= $"{start:yyyy/MM}" %></td>
                            <td class="text-right">
                                <%  if (attendanceCount > 0)
                                    { %>
                                <a onclick="showAttendanceAchievement('<%= $"{start:yyyy/MM}" %>');"><u><%= attendanceCount %></u></a>
                                <%  }
                                    else
                                    { %>
                                --
                                <%  } %>
                            </td>
                            <td class="text-right">
                                <%    
                                    int shares;
                                    var lessons = items
                                            .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
                                            .Where(t => t.RegisterLesson.RegisterLessonEnterprise == null
                                                || t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status != (int)Naming.DocumentLevelDefinition.自主訓練);
                                    var achievement = models.CalcAchievement(lessons, out shares);
                                    summary += achievement;
                                    Writer.Write(shares > 0 ? $"{shares:0,0}" : "--");
                                    totalShares += shares; %>
                            </td>
                            <td class="text-right">
                                <%  
                                    var tuitionAmt = tuitionItems.Sum(l => l.ShareAmount);
                                    subtotal += tuitionAmt ?? 0; %>
                                <%  if (tuitionAmt > 0)
                                    { %>
                                <a onclick="showTuitionShares('<%= $"{start:yyyy/MM}" %>');"><u><%= tuitionAmt > 0 ? $"{tuitionAmt:0,0}" : "--" %></u></a>
                                <%  }
                                    else
                                    { %>
                                --
                                <%  } %>
                            </td>
                        </tr>
                        <%  } %>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td class="text-right">總計</td>
                            <td class="text-right"><%= $"{totalCount:0,0}" %></td>
                            <td class="text-right"><%= $"{totalShares:0,0}" %></td>
                            <td class="text-right"><%= $"{subtotal:0,0}" %></td>
                        </tr>
                    </tfoot>
                </table>
            </div>
            <!-- end widget content -->
        </div>
        <!-- end widget div -->
    </div>
    <!-- end widget -->
    <script>
        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-trophy'></i> 業績統計表</h4></div>",
            close: function (event, ui) {
                $('#<%= _dialogID %>').remove();
            }
        });

        var responsiveHelper_<%= _tableId %> = undefined;

        var responsiveHelper_datatable_fixed_column = undefined;
        var responsiveHelper_datatable_col_reorder = undefined;
        var responsiveHelper_datatable_tabletools = undefined;

        var breakpointDefinition = {
            tablet: 1024,
            phone: 480
        };

        $('#<%= _tableId %>').dataTable({
            "sDom": "",
            "autoWidth": true,
            "bPaginate": false,
            "order": [],
            "oLanguage": {
                "sSearch": '<span class="input-group-addon"><i class="glyphicon glyphicon-search"></i></span>'
            },
            "preDrawCallback": function () {
                // Initialize the responsive datatables helper once.
                if (!responsiveHelper_<%= _tableId %>) {
                    responsiveHelper_<%= _tableId %> = new ResponsiveDatatablesHelper($('#<%= _tableId %>'), breakpointDefinition);
                }
            },
            "rowCallback": function (nRow) {
                responsiveHelper_<%= _tableId %>.createExpandIcon(nRow);
            },
            "drawCallback": function (oSettings) {
                responsiveHelper_<%= _tableId %>.respond();
            }
        });

    </script>
</div>



<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "performance" + DateTime.Now.Ticks;
    IQueryable<LessonTime> _model;
    IQueryable<TuitionAchievement> _items;
    AchievementQueryViewModel _viewModel;
    String _dialogID = "coachPerformance" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
        _items = (IQueryable<TuitionAchievement>)ViewBag.TuitionItems;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
    }

</script>
