<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<form id="pageForm" action="<%= _formAction %>" class="smart-form" method="post">
    <%=  Html.AntiForgeryToken() %>
    <fieldset>
        <div class="row">
            <section class="col col-6">
                <label class="input">
                    <i class="icon-append fa fa-envelope-o "></i>
                    <input class="form-control input-lg" maxlength="256" placeholder="請輸入註冊時的E-mail" type="email" name="EMail" id="EMail" value="<%= _viewModel.EMail %>" />
                </label>
            </section>
            <section class="col col-6">
                <label class="input">
                    <i class="icon-append fa fa-user "></i>
                    <input class="form-control input-lg" maxlength="20" placeholder="請輸入暱稱" type="text" name="UserName" id="UserName" value="<%= _viewModel.UserName %>" />
                </label>
            </section>
        </div>
    </fieldset>
    <fieldset>
        <div class="row">
            <div class="col col-12">
                <img src="<%= VirtualPathUtility.ToAbsolute("~/img/avatars/male.png") %>" alt="親愛的" class="online" id="profileImg" style="max-width:100px;" />
                <div class="input input-file">
                    <span class="button">
                        <input type="file" id="photopic" name="photopic" onchange="this.parentNode.nextSibling.value = this.value" />瀏覽
                    </span>
                    <input type="text" placeholder="請選擇圖片" readonly="" />
                </div>
            </div>
        </div>
    </fieldset>
    <fieldset>
        <label class="label">PS：圖形密碼與文字密碼請選擇一種輸入即可，若想改用文字密碼請點選 <i class="fa fa-keyboard-o  fa-lg fa-gear"></i>文字密碼</label>
        <% Html.RenderPartial("~/Views/Shared/SetPassword.ascx"); %>
    </fieldset>
    <footer class="text-right">
        <button type="button" id="btnSend" class="btn btn-primary" autofocus>
            送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
        </button>
    </footer>
</form>

<script>
    $(function () {

        var fileUpload = $('#photopic');
        var elmt = fileUpload.parent();

        fileUpload.on('change', function () {

            $('<form method="post" id="myForm" enctype="multipart/form-data"></form>')
            .append(fileUpload).ajaxForm({
                url: "<%= VirtualPathUtility.ToAbsolute("~/Account/UpdateMemberPicture") %>",
                data: { 'memberCode': '<%= _item.MemberCode %>' },
                beforeSubmit: function () {
                    //status.show();
                    //btn.hide();
                    //console.log('提交時');
                },
                success: function (data) {
                    elmt.append(fileUpload);
                    if (data.result) {
                        $('#profileImg').prop('src', '<%= VirtualPathUtility.ToAbsolute("~/Information/GetResource/") %>' + data.pictureID + "?stretch=true");
                    } else {
                        smartAlert(data.message);
                    }
                    //status.hide();
                    //console.log('提交成功');
                },
                error: function () {
                    elmt.after(fileUpload);
                    //status.hide();
                    //btn.show();
                    //console.log('提交失败');
                }
            }).submit();
        });
    });

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    RegisterViewModel _viewModel;
    UserProfile _item;
    String _formAction;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (RegisterViewModel)ViewBag.ViewModel;
        _item = (UserProfile)this.Model;

        if (_viewModel == null)
            _viewModel = new RegisterViewModel { };
        _formAction = ViewBag.FormAction ?? VirtualPathUtility.ToAbsolute("~/Account/CompleteRegister");
    }

</script>
