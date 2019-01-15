<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<fieldset>
    <div class="row">
        <section class="col col-6">
            <label class="input">
                <i class="icon-append fa fa-user"></i>
                <input type="text" name="realName" id="realName" maxlength="20" class="input-lg" placeholder="請輸入姓名" value="<%= _model.RealName %>" />
            </label>
        </section>
        <section class="col col-6">
            <label class="input">
                <i class="icon-prepend fa fa-phone"></i>
                <input type="tel" name="phone" id="phone" maxlength="20" class="input-lg" placeholder="請輸入手機號碼或市話" data-mask="0999999999" value="<%= _model.Phone %>" />
            </label>
        </section>
    </div>
</fieldset>
<fieldset>
    <div class="row">
        <section class="col col-6">
            <label class="input input-group">
                <i class="icon-append far fa-calendar-alt"></i>
                <input type="text" name="birthDay" id="birthDay" readonly="readonly" class="form-control input-lg date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value='<%= _model.Birthday.HasValue ? _model.Birthday.Value.ToString("yyyy/MM/dd") : "" %>' />
            </label>
        </section>
        <section class="col col-6">
            <%  if (_model.MemberStatus == Naming.MemberStatusDefinition.Checked)
                { %>
            <label class="input">
                <i class="icon-append fa fa-envelope-o"></i>
                <input type="email" id="email" name="email" class="input-lg" maxlength="256" placeholder="請輸入E-mail" value="<%= _model.Email %>" />
            </label>
            <%  } %>
        </section>
    </div>
</fieldset>
<fieldset>
    <div class="row">
        <section class="col col-6">
            <label class="label">性別</label>
            <label class="select">
                <select class="input-lg" name="Gender" id="Gender">
                    <option value="M">男</option>
                    <option value="F">女</option>
                </select>
                <i class="icon-append far fa-keyboard"></i>
            </label>
            <%  if (_model.Gender != null)
                { %>
            <script>
                $(function () {
                    $('#Gender').val('<%= _model.Gender %>')
                        });
            </script>
            <%  } %>
        </section>
        <section class="col col-6">
            <label class="label">是否為運動員</label>
            <div class="inline-group">
                <label class="radio">
                    <input type="radio" name="AthleticLevel" value="1" />
                    <i></i>是</label>
                <label class="radio">
                    <input type="radio" name="AthleticLevel" value="0" />
                    <i></i>否</label>
            </div>
            <%  if (_model.AthleticLevel.HasValue)
                { %>
            <script>
                $(function () {
                    $('input[name="AthleticLevel"][value="<%= _model.AthleticLevel %>"]').prop('checked', true);
                        });
            </script>
            <%  } %>
        </section>
    </div>
</fieldset>

<script>

    $(function () {
        <%  if (_model.MemberStatus == Naming.MemberStatusDefinition.Checked)
    { %>
        $('#email').rules('add', {
            'required': false,
            'email': true,
            'messages': {
                'email': '請輸入E-mail',
            }
        });
        <%  }   %>

        $('#realName').rules('add', {
            'required': true,
            'maxlength': 20,
            'messages': {
                required: '請輸入姓名',
            }
        });

        $('#phone').rules('add', {
            'required': true,
            'regex': /^[0-9]{6,20}$/,
            'messages': {
                required: '請輸入手機號碼或市話'
            }
        });

        //$('#birthDay').rules('add', {
        //    'required': true,
        //    'messages': {
        //        required: '請點選日曆'
        //    }
        //});

    });

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    LearnerViewModel _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = this.Model as LearnerViewModel;

    }
</script>
