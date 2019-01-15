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
                <i class="icon-append fa fa-user"></i>
                <input type="text" name="realName" id="realName" class="input-lg" placeholder="請輸入員工姓名" value="<%= _model.RealName %>" />
            </label>
        </section>
        <section class="col col-6">
            <label class="input">
                <i class="icon-prepend fa fa-phone"></i>
                <input type="tel" name="phone" id="phone" class="input-lg" placeholder="請輸入手機號碼或市話" data-mask="0999999999" value="<%= _model.Phone %>" />
            </label>
        </section>
    </div>
</fieldset>
<%  if (ViewBag.CreateNew == null)
    { %>
<fieldset>
    <section>
        <label class="input">
            <i class="icon-append fa fa-envelope-o"></i>
            <input type="email" name="email" maxlength="256" id="email" class="input-lg" placeholder="E-mail" value="<%= _model.Email %>" />
        </label>
    </section>
</fieldset>
<%  } %>
<fieldset>
    <div class="row">
        <section class="col col-6">
            <label class="label">員工身份</label>
            <div class="inline-group">
                <%  if (_model.IsCoach == true)
                    { %>
                <label class="radio">
                    <input type="radio" name="coachRole" value="2" />
                    <i></i>一般教練</label>
                <label class="radio">
                    <input type="radio" name="coachRole" value="3" />
                    <i></i>自由教練</label>
                <%  }
                    else
                    { %>
                <label class="radio">
                    <input type="radio" name="coachRole" value="6" />
                    <i></i>財務</label>
                <%--<label class="radio">
                    <input type="radio" name="coachRole" value="7" />
                    <i></i>經理</label>--%>
                <label class="radio">
                    <input type="radio" name="coachRole" value="8" />
                    <i></i>行政助理</label>
                <%  } %>
                <script>
                    $(function () {
                        $('input:radio[name="coachRole"][value="<%= _model.CoachRole %>"]').prop('checked', true);
                });
                </script>
            </div>
        </section>
        <%  if (_userProfile.IsOfficer() && _model.IsCoach==true)
            { %>
        <section class="col col-6">
            <label class="label">職級</label>
            <label class="select">
                <%  Html.RenderPartial("~/Views/Lessons/ProfessionalLevelSelector.ascx", new InputViewModel { Id = "LevelID", Name = "LevelID", DefaultValue = _model.LevelID }); %>
                <i class="icon-append far fa-keyboard"></i>
            </label>
        </section>
        <%  } %>
    </div>
</fieldset>
<%  if (_model.IsCoach == true)
    { %>
<fieldset>
    <section>
        <label class="label">證照資格</label>
        <label class="textarea">
            <i class="icon-append fa fa-certificate"></i>
            <textarea rows="10" id="description" name="Description"><%= _model.Description %></textarea>
        </label>
    </section>
</fieldset>
<%  } %>
<script>

    $(function () {

        $('#realName').rules('add', {
            'required': true,
            'maxlength': 20,
            'messages': {
                'required': '請輸入員工姓名'
            }
        });

        $('#phone').rules('add', {
            'required': true,
            'regex': /^[0-9]{6,20}$/,
            'messages': {
                'required': '請輸入市話或手機號碼'
            }
        });
    });


</script>

<script runat="server">

    ModelStateDictionary _modelState;
    CoachViewModel _model;
    UserProfile _userProfile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = this.Model as CoachViewModel;
        _userProfile = Context.GetUser();
    }
</script>
