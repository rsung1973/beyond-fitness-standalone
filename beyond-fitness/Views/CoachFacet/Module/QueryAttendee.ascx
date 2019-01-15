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

<div id="<%= _dialog %>" title="查詢學員" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="#" class="smart-form" method="post" autofocus>
            <div>
                <fieldset>
                    <div class="row">
                        <section class="col col-8">
                            <%--<label class="label">請選擇上課學員</label>--%>
                            <label class="input">
                                <i class="icon-prepend fa fa-search"></i>
                                <input type="text" name="userName" maxlength="20" placeholder="請輸入學員姓名" />
                                <script>
                                    $('#btnAttendeeQuery').on('click', function (evt) {
                                        var userName = $('input[name="userName"]').val();

                                        clearErrors();
                                        showLoading();
                                        $('#attendeeSelector').load('<%= Url.Action("VipSelector","CoachFacet",new { forCalendar = true }) %>', { 'userName': userName }, function (data) {
                                            hideLoading();
                                        });
                                    });
                                </script>
                            </label>
                        </section>
                        <section class="col col-4">
                            <button id="btnAttendeeQuery" class="btn bg-color-blue btn-sm" type="button">查詢</button>
                        </section>
                    </div>
                    <div class="row">
                        <section id="attendeeSelector" class="col col-12">
                        </section>
                    </div>
                </fieldset>
            </div>
        </form>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "600",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-search'></i> 學員查詢</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class": "btn btn-primary",
                click: function () {
                    var $item = $('input[name="UID"]:checked');
                    if ($item.length>0) {
                        selectAttendee($item.val(), $item.attr('data-name'));
                        $('#<%= _dialog %>').dialog("close");
                    } else {
                        alert('請選擇學員!!');
                    }
                }
            }],
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });
    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "queryLearner" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
