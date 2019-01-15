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

<div id="<%= _dialog %>" title="服務申請歷程" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <%  Html.RenderPartial("~/Views/CourseContract/Module/ContractAmendmentList.ascx", _model.RevisionList); %>
    </div>
    <script>

        $('#<%= _dialog %>').dialog({
            //autoOpen : false,
            width : "600",
            resizable : false,
            modal : true,
            title: "<div class='modal-title'><h4><i class='fa fa-cogs'></i> 學員服務申請歷程</h4></div>",
            <%  if (!_model.RevisionList.Any(c => c.CourseContract.Status < (int)Naming.CourseContractStatus.已生效))
                { %>
            buttons : [{
                html : "<i class='fa fa-paper-plane'></i>&nbsp; 新增服務申請",
                    "class" : "btn btn-primary",
                    click : function() {
                    showLoading();
                        $.post('<%= Url.Action("AmendContract", "CourseContract", new { _model.ContractID }) %>', {}, function (data) {
                            hideLoading();
                            if ($.isPlainObject(data)) {
                                alert(data.message);
                            } else {
                                $(data).appendTo($('body'));
                                $('#<%= _dialog %>').dialog('close');
                            }
                        });
                    }
                }],
            <%  } %>
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });

        $(function () {
            $global.openToApproveAmendment = function (revisionID) {
                $('#<%= _dialog %>').dialog('close');
                window.open('<%= Url.Action("ContractAmendmentApprovalView","CourseContract") %>' + '?revisionID=' + revisionID, '_blank', 'fullscreen=yes');
            };

            $global.openToSignAmendment = function (revisionID) {
                $('#<%= _dialog %>').dialog('close');
                window.open('<%= Url.Action("ContractAmendmentSignatureView","CourseContract") %>' + '?revisionID=' + revisionID, '_blank', 'fullscreen=yes');
            };

            $global.enableAmendment = function (revisionID) {
                var event = event || window.event;
                var $a = $(event.target);
                if (!$a.is('a')) {
                    $a = $a.closest('a');
                }
                showLoading();
                $.post('<%= Url.Action("EnableContractAmendment","CourseContract",new { Status = (int)Naming.CourseContractStatus.已生效 }) %>', { 'revisionID': revisionID }, function (data) {
                    hideLoading();
                    if (data.result) {
                        alert('合約已生效!!');
                        $a.closest('td').prev().text('已生效');
                        $a.remove();
                    } else {
                        $(data).appendTo($('body')).remove();
                    }
                });
            };

        });

    </script>
</div>



<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContractViewModel _viewModel;
    String _dialog = "amendment" + DateTime.Now.Ticks;
    CourseContract _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
    }

</script>
