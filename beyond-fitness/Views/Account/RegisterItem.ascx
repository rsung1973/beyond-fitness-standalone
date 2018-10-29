<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<fieldset>
    <div class="row">
        <section class="col col-6">
            <label class="input">
                <i class="icon-append fa fa-envelope-o "></i>
                <input class="form-control input-lg" maxlength="256" placeholder="請輸入註冊時的E-mail" type="email" name="EMail" id="EMail" value="<%= _model.EMail %>" />
            </label>
        </section>
        <section class="col col-6">
            <label class="input">
                <i class="icon-append fa fa-user "></i>
                <input class="form-control input-lg" maxlength="20" placeholder="請輸入暱稱" type="text" name="userName" id="userName" value="<%= _model.UserName %>" />
            </label>
        </section>
    </div>
</fieldset>
<fieldset>
    <div class="row">
        <div class="col col-6">
            <% _model.PictureID.RenderUserPicture(this.Writer, new { id = "profileImg", @class = "online", style = "width:100px" }); %>
            <div class="input input-file">
                <span class="button">
                    <input type="file" id="photopic" name="photopic" onchange="this.parentNode.nextSibling.value = this.value" />瀏覽
                </span>
                <input type="text" placeholder="請選擇圖片" readonly="" />
            </div>
        </div>
        <%  if(_profile!=null 
                && (_profile.IsAssistant() || _profile.IsCoach() || _profile.IsManager() || _profile.IsViceManager() || _profile.IsOfficer()))
            { %>
        <div class="col col-6">
            <label>合約簽名檔</label>
            <div><% Html.RenderAction("UserSignature", "Account", new { _model.UID }); %></div>
        </div>
        <%  } %>
    </div>
</fieldset>

<fieldset>
    <% Html.RenderPartial("~/Views/Shared/SetPassword.ascx"); %>
</fieldset>

<script>

    $(function () {

        var fileUpload = $('#photopic');
        var elmt = fileUpload.parent();

        fileUpload.off('click').on('change', function () {

            $('<form method="post" id="myForm" enctype="multipart/form-data"></form>')
            .append(fileUpload).ajaxForm({
                url: "<%= VirtualPathUtility.ToAbsolute("~/Account/UpdateMemberPicture") %>",
                data: { 'memberCode': '<%= _model.MemberCode %>' },
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

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    RegisterViewModel _model;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (RegisterViewModel)this.Model;
        _profile = models.GetTable<UserProfile>().Where(u => u.UID == _model.UID).FirstOrDefault();
    }


</script>
