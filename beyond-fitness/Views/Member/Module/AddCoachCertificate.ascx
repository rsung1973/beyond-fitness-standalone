<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="編輯證照資料" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitCoachCertificate","Member",new { uid = _model.CoachID }) %>" class="smart-form" method="post" autofocus>
            <fieldset>
                <div class="row">
                    <section class="col col-6">
                        <label class="label">證照</label>
                        <label class="select">
                            <select name="CertificateID">
                                <%  foreach (var item in models.GetTable<ProfessionalCertificate>())
                                    { %>
                                <option value="<%= item.CertificateID %>"><%= item.Description %></option>
                                <%  } %>
                            </select>
                            <i class="icon-append fa fa-certificate"></i>
                        </label>
                    </section>
                    <section class="col col-6">
                        <label class="label">證照到期日</label>
                        <label class="input">
                            <i class="icon-append far fa-calendar-alt"></i>
                            <input type="text" name="Expiration" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" value="" placeholder="請選擇證照到期日" />
                        </label>
                    </section>
                </div>
            </fieldset>
        </form>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 新增證照資料</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 確定",
                "class": "btn btn-primary",
                click: function () {
                    showLoading();
                    $('#<%= _dialog %> form').ajaxSubmit({
                        success: function (data) {
                            hideLoading();
                            if (data.result) {
                                alert('資料已儲存!!');
                                $('#<%= _dialog %>').dialog('close');
                                showLoading();
                                loadCertificate();
                            } else {
                                $(data).appendTo($('body')).remove();
                            }
                        }
                    });
                }
            }],
            close: function (event, ui) {
                $('#<%= _dialog %>').remove();
            }
        });

        $('.form_date').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 1,
            clearBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 2,
            minView: 2,
            forceParse: 0
        });

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "addCertDialog" + DateTime.Now.Ticks;
    ServingCoach _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (ServingCoach)this.Model;
    }

</script>
