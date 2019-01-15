<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<table id="dt_basic" class="table table-forum" width="100%">
    <thead>
        <tr>
            <th style="width: 50px">
                <a id="collapse" style="display:none;" >
                    <i class="fa fa-minus-circle text-danger"></i>
                </a>
                <a id="expand">
                    <i class="fa fa-plus-circle text-success"></i>
                </a>
            </th>
            <th><i class="fa fa-fw fa-calendar text-muted hidden-md hidden-sm hidden-xs"></i>時間區段</th>
            <th><i class="fa fa-fw fa-user text-muted hidden-md hidden-sm hidden-xs"></i>人數</th>
        </tr>
    </thead>
</table>



<script>
    function showAttendee(lessonDate, hour) {
        $('#loading').css('display', 'table');
        $('#attendeeList').load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/DailyBookingMembers") %>', { 'lessonDate': lessonDate, 'hour': hour }, function () {
            $('#loading').css('display', 'none');
        });
    }


    function renderData(lessonDate) {
        /* BASIC ;*/
        var responsiveHelper_dt_basic = undefined;
        var responsiveHelper_datatable_fixed_column = undefined;
        var responsiveHelper_datatable_col_reorder = undefined;
        var responsiveHelper_datatable_tabletools = undefined;

        var breakpointDefinition = {
            tablet: 1024,
            phone: 480
        };

        /* Formatting function for row details - modify as you need */
        function deferredShow(row) {
            if (row.data().details) {
                row.child(row.data().details).show()
            } else {
                $.post('<%= Url.Action(ViewBag.ByQuery == true ? "DailyBookingMembersByQuery" : "DailyBookingMembers","Lessons",new { category = ViewBag.Category } ) %>',
                    {
                        'lessonDate': lessonDate,
                        'hour': row.data().hour
                    }).done(function (data) {
                        row.data().details = data;
                        row.child(data).show();
                    });
            }
        }

<%--        function format(d) {
            // `d` is the original data object for the row
            var result;
            var d = $.Deferred();

            $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/DailyBookingMembers") %>',
                {
                    'lessonDate': lessonDate,
                    'hour': d.hour
                }).done(function (data) {
                    result = data;
                    d.resolve(data);
                });

            result = d.promise();
            return result;
        }--%>

        // clears the variable if left blank
        var table = $('#dt_basic').DataTable({
            "order": [[1, "asc"]],
            "fnDrawCallback": function( oSettings ) {
                hideLoading();
            },
            "bPaginate": false,
            "sDom": "",
            "ajax": "<%= VirtualPathUtility.ToAbsolute(ViewBag.ByQuery==true ? "~/Lessons/DailyBookingListJsonByQuery" : "~/Lessons/DailyBookingListJson") %>" + "?lessonDate=" + lessonDate + '&category=' + '<%= (String)ViewBag.Category %>',
            "autoWidth": true,
            "bDestroy": true,
            "oLanguage": {
                "sSearch": '<span class="input-group-addon"><i class="glyphicon glyphicon-search"></i></span>'
            },
            "columns": [
                    {
                        "class": 'details-control',
                        "orderable": false,
                        "data": null,
                        "defaultContent": ''
                    },
                    { "data": "timezone" },
                    { "data": "count" }
            ]
        });

        // Add event listener for opening and closing details
        $('#dt_basic tbody').on('click', 'td.details-control', function () {
            var tr = $(this).closest('tr');
            var row = table.row(tr);

            if (row.child.isShown()) {
                // This row is already open - close it
                row.child.hide();
                tr.removeClass('shown');
            }
            else {
                // Open this row
                //row.child(format(row.data())).show();
                deferredShow(row);
                tr.addClass('shown');
            }
        });

        $('#collapse').on('click', function (evt) {
            $('#dt_basic tbody tr td.details-control').parent().each(function (idx) {
                var tr = $(this);
                var row = table.row(tr);
                if (row.child.isShown()) {
                    // This row is already open - close it
                    row.child.hide();
                    tr.removeClass('shown');
                }
            });
            $('#collapse').css('display', 'none');
            $('#expand').css('display', 'block');
        });

        $('#expand').on('click', function (evt) {
            $('#dt_basic tbody tr td.details-control').parent().each(function (idx) {
                var tr = $(this);
                var row = table.row(tr);
                // Open this row
                deferredShow(row);
                tr.addClass('shown');
            });
            $('#collapse').css('display', 'block');
            $('#expand').css('display', 'none');
        });
        /* END BASIC */
    }

    $(function () {
        renderData('<%= _lessonDate.Value.ToString("yyyy-MM-dd") %>');
    });

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    DateTime? _lessonDate;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _lessonDate = (DateTime?)this.Model;
    }

</script>
