<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<table id="<%= _tableId %>" class="table table-striped table-bordered table-hover" width="100%">
    <thead>
        <tr>
            <th data-class="expand">活動名稱</th>
            <th data-hide="phone">活動起日</th>
            <th data-hide="phone">活動迄日</th>
            <th>贈送點數</th>
            <th data-hide="phone">贈送方式</th>
            <th>目前贈送人數</th>
            <th>狀態</th>
            <th data-hide="phone">功能</th>
        </tr>
    </thead>
    <tbody>
        <%  
            foreach (var item in _model)
            {
                var pdqQuest = item.PDQQuestion.First();
                var pdqExt = pdqQuest.PDQQuestionExtension; %>
        <tr>
            <td><%= item.GroupName %></td>
            <td nowrap="noWrap" class="text-center"><%= item.StartDate.HasValue ? $"{item.StartDate:yyyy/MM/dd}" : "--" %></td>
            <td nowrap="noWrap" class="text-center"><%= item.EndDate.HasValue ? $"{item.StartDate:yyyy/MM/dd}" : "--" %></td>
            <td nowrap="noWrap" class="text-center"><%= pdqExt.BonusPoint %></td>
            <td><%= $"{(Naming.BonusAwardingAction)pdqExt.AwardingAction}" %></td>
            <td nowrap="noWrap" class="text-center">
                <%  var appliedCount = pdqQuest.PDQTask.Count(); %>
                <%= appliedCount %>
            </td>
            <td><%  Naming.LessonSeriesStatus status = Naming.LessonSeriesStatus.已啟用;
                    if(pdqExt.Status.HasValue)
                    {
                        status = (Naming.LessonSeriesStatus)pdqExt.Status;
                        Writer.Write(status);
                    }
                    else if(item.StartDate>DateTime.Today)
                    {
                        status = Naming.LessonSeriesStatus.準備中;
                        Writer.Write("待生效");
                    }
                    else
                    {
                        Writer.Write("已啟用");
                    }   %>
            </td>
            <td nowrap="noWrap">
                <a href="#" onclick="javascript:editPromotion('<%= item.GroupID.EncryptKey() %>');" class="btn btn-circle bg-color-yellow"><i class="fa fa-fw fa fa-lg fa-edit" aria-hidden="true"></i></a>&nbsp;&nbsp;
                <%  if (status == Naming.LessonSeriesStatus.已啟用)
                    {   %>
                    <%  if (pdqExt.AwardingAction!=(int)Naming.BonusAwardingAction.程式連結)
                        {   %>
                        <a href="#" onclick="editParticipant('<%= item.GroupID.EncryptKey() %>');" class="btn btn-circle btn-primary listAttendantDialog_link"><i class="fa fa-fw fa fa-lg fa-user-plus" aria-hidden="true"></i></a>&nbsp;&nbsp;
                        <a href="#" onclick="deletePromotion('<%= item.GroupID.EncryptKey() %>');" class="btn btn-circle bg-color-red"><i class="fa fa-fw fa-lg fa-trash-alt" aria-hidden="true"></i></a>&nbsp;&nbsp;
                    <%  }   %>
                <%  }
                    else if(status==Naming.LessonSeriesStatus.已停用)
                    {   %>
                        <a href="#"  onclick="enablePromotion('<%= item.GroupID.EncryptKey() %>');" class="btn btn-circle bg-color-red"><i class="fa fa-fw fa-lg fa-check-square" aria-hidden="true"></i></a>&nbsp;&nbsp;
                <%  }
                    else
                    {   %>
                        <a href="#" onclick="deletePromotion('<%= item.GroupID.EncryptKey() %>');" class="btn btn-circle bg-color-red"><i class="fa fa-fw fa-lg fa-trash-alt" aria-hidden="true"></i></a>&nbsp;&nbsp;
                <%  }
                    if (appliedCount > 0)
                    {   %>
                        <a href="#" id="btnDownloadPromotion" onclick="downloadPromotion('<%= item.GroupID.EncryptKey() %>');" class="btn btn-circle bg-color-green"><i class="fa fa-fw fa-cloud-download-alt" aria-hidden="true"></i></a>&nbsp;&nbsp;
                <%  } %>
            </td>
        </tr>
        <%  } %>
    </tbody>
</table>

<script>
    $(function () {
        var responsiveHelper_<%= _tableId %> = undefined;

        var responsiveHelper_datatable_fixed_column = undefined;
        var responsiveHelper_datatable_col_reorder = undefined;
        var responsiveHelper_datatable_tabletools = undefined;

        var breakpointDefinition = {
            tablet: 1024,
            phone: 480
        };

        $('#<%= _tableId %>').dataTable({
            //"bPaginate": false,
            //"pageLength": 30,
            //"lengthMenu": [[30, 50, 100, -1], [30, 50, 100, "全部"]],
            "ordering": false,
            //"order": [[1,'asc']],
            "sDom": "<'dt-toolbar'<'col-xs-12 col-sm-6'f><'col-sm-6 col-xs-12 hidden-xs'l>r>" +
                "t" +
                "<'dt-toolbar-footer'<'col-sm-6 col-xs-12 hidden-xs'i><'col-xs-12 col-sm-6'p>>",
            "autoWidth": true,
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

<%  if(_model.Count()>0)
    {  %>
        $('#btnDownloadPromotion').css('display', 'inline');
        //$('#btnDownloadTrustLesson').css('display', 'inline');
<%  }  %>

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "pdqGroup" + DateTime.Now.Ticks;
    IQueryable<PDQGroup> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<PDQGroup>)this.Model;
    }

</script>
