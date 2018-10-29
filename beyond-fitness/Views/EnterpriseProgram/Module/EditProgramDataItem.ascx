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

<div id="<%= _dialog %>" title="新增項目" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="" class="smart-form" method="post" autofocus>
            <fieldset>
                <section class="col col-6">
                    <label class="label">體能顧問服務項目</label>
                    <label class="select">
                        <select class="input" name="PriceID">
                            <%  foreach(var price in models.GetTable<EnterpriseLessonType>())
                                {   %>
                            <option value="<%= price.TypeID %>"><%= price.Description %></option>
                            <%  } %>
                        </select>
                        <i class="icon-append far fa-keyboard"></i>
                    </label>
                </section>
                <section class="col col-6">
                    <label class="label">上課時間長度</label>
                    <label class="select">
                        <select name="DurationInMinutes">
                            <option value="60">60分鐘</option>
                            <option value="90">90分鐘</option>
                        </select>
                        <i class="icon-append far fa-clock"></i>
                    </label>
                </section>
            </fieldset>
            <fieldset>
                <section class="col col-6">
                    <label class="label">購買堂數</label>
                    <label class="input">
                        <i class="icon-append fa fa-shopping-cart"></i>
                        <input type="number" name="Lessons" maxlength="10" placeholder="請輸入數字"/>
                    </label>
                </section>
                <section class="col col-6">
                    <label class="label">體能顧問終點費用</label>
                    <label class="input">
                        <i class="icon-append fa fa-dollar-sign"></i>
                        <input type="number" name="ListPrice" maxlength="10" placeholder="請輸入數字"/>
                    </label>
                </section>
            </fieldset>
        </form>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: true,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-plus'></i> 新增項目</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class": "btn btn-primary",
                click: function () {
                    var $form = $('#<%= _dialog %> form');
                    var formData = $form.serializeObject();
                    clearErrors();
                    $.post('<%= Url.Action("ApplyProgramDataItem","EnterpriseProgram") %>', formData, function (data) {
                        var $data = $(data);
                        if ($data.is('tr')) {
                            $global.appendProgramItem($data);
                            $('#<%= _dialog %>').dialog("close");
                        } else {
                            $data.appendTo($('body'));
                        }
                    });
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
    String _dialog = "program" + DateTime.Now.Ticks;
    EnterpriseProgramItemViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (EnterpriseProgramItemViewModel)ViewBag.ViewModel;
    }

</script>
