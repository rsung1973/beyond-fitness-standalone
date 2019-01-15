<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="編輯學員資料" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitContractMember","CourseContract",new { uid = _viewModel.UID }) %>" class="smart-form" autofocus method="post">
            <fieldset>
                <div class="row">
                    <section class="col col-4">
                        <label class="label">是否為體驗學員</label>
                        <div class="inline-group">
                            <label class="select">
                                <select name="CurrentTrial">
                                    <option value="">否</option>
                                    <option value="1" <%= _viewModel.CurrentTrial==1 ? "selected" : null %>>是</option>
                                </select>
                                <i class="icon-append fa fa-address-card"></i>
                            </label>
                        </div>
                    </section>
                    <section class="col col-4">
                        <label class="label">真實姓名</label>
                        <label class="input">
                            <i class="icon-append fa fa-user"></i>
                            <input type="text" name="RealName" value="<%= _viewModel.RealName %>" maxlength="20" placeholder="請輸入學員姓名" />
                        </label>
                    </section>
                    <section class="col col-4">
                        <label class="label">暱稱</label>
                        <label class="input">
                            <i class="icon-append fa fa-user"></i>
                            <input type="text" name="nickname" maxlength="20" placeholder="請輸入暱稱" value="<%= _viewModel.Nickname %>">
                        </label>
                    </section>
                </div>
                <div class="row">
                    <section class="col col-4">
                        <label class="label">身份證字號/護照號碼</label>
                        <label class="input">
                            <i class="icon-append far fa-id-card"></i>
                            <input type="text" name="IDNo" value="<%= _viewModel.IDNo %>" maxlength="20" placeholder="請輸入身份證字號/護照號碼" />
                        </label>
                    </section>
                    <section class="col col-4">
                        <label class="label">出生</label>
                        <label class="input">
                            <i class="icon-append far fa-calendar-alt"></i>
                            <input type="text" name="Birthday" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value='<%= _viewModel.Birthday.HasValue ? _viewModel.Birthday.Value.ToString("yyyy/MM/dd") : "" %>' />
                        </label>
                    </section>
                    <section class="col col-4">
                        <label class="label">聯絡電話</label>
                        <label class="input">
                            <i class="icon-append fa fa-phone"></i>
                            <input type="tel" name="Phone" value="<%= _viewModel.Phone %>" maxlength="20" placeholder="請輸入住家電話" />
                        </label>
                    </section>
                </div>
                <div class="row">
                    <section class="col col-4">
                        <label class="label">性別</label>
                        <div class="inline-group">
                            <label class="radio">
                                <input type="radio" name="Gender" value="M" />
                                <i></i>男</label>
                            <label class="radio">
                                <input type="radio" name="Gender" value="F" />
                                <i></i>女</label>
                        </div>
                        <%  if (_viewModel.Gender != null)
                        { %>
                        <script>
                            $(function () {
                                $('input[name="Gender"][value="<%= _viewModel.Gender %>"]').prop('checked', true);
                            });
                        </script>
                        <%  } %>
                    </section>
                    <section class="col col-6">
                        <label class="label">是否為運動員</label>
                        <div class="inline-group">
                            <label class="radio">
                                <input type="radio" name="AthleticLevel" value="0" />
                                <i></i>否</label>
                            <label class="radio">
                                <input type="radio" name="AthleticLevel" value="1" />
                                <i></i>是</label>
                        </div>
                        <%  if (_viewModel.AthleticLevel.HasValue)
                            { %>
                        <script>
                            $(function () {
                                $('input[name="AthleticLevel"][value="<%= _viewModel.AthleticLevel %>"]').prop('checked', true);
                            });
                        </script>
                        <%  } %>
                    </section>
                </div>
                <%  if (_model != null && _model.LevelID == (int)Naming.MemberStatus.已註冊)
                    { %>
                <div class="row">
                    <section class="col col-10">
                        <label class="label">E-mail</label>
                        <label class="input">
                            <i class="icon-append fa fa-at"></i>
                            <input type="text" name="Email" value="<%= _viewModel.Email %>" maxlength="100" placeholder="請輸入E-mail" />
                        </label>
                    </section>
                </div>
                <%  } %>
                <div class="row">
                    <section class="col col-4">
                        <label class="label">居住地址</label>
                        <label class="select">
                            <select name="AdministrativeArea">
                                <option value="">請選擇縣市</option>
                                <option value="基隆市">基隆市</option>
                                <option value="臺北市">臺北市</option>
                                <option value="新北市">新北市</option>
                                <option value="桃園市">桃園市</option>
                                <option value="新竹市">新竹市</option>
                                <option value="新竹縣">新竹縣</option>
                                <option value="苗栗縣">苗栗縣</option>
                                <option value="臺中市">臺中市</option>
                                <option value="彰化縣">彰化縣</option>
                                <option value="南投縣">南投縣</option>
                                <option value="雲林縣">雲林縣</option>
                                <option value="嘉義市">嘉義市</option>
                                <option value="嘉義縣">嘉義縣</option>
                                <option value="臺南市">臺南市</option>
                                <option value="高雄市">高雄市</option>
                                <option value="屏東縣">屏東縣</option>
                                <option value="臺東縣">臺東縣</option>
                                <option value="花蓮縣">花蓮縣</option>
                                <option value="宜蘭縣">宜蘭縣</option>
                                <option value="澎湖縣">澎湖縣</option>
                                <option value="金門縣">金門縣</option>
                                <option value="連江縣">連江縣</option>
                            </select>
                            <i class="icon-append fa fa-at"></i>
                            <%  if (_viewModel.AdministrativeArea!=null)
                                { %>
                            <script>
                                $(function () {
                                    $('select[name="AdministrativeArea"]').val('<%= _viewModel.AdministrativeArea %>');
                                });
                            </script>
                            <%  } %>
                        </label>
                    </section>
                    <section class="col col-8">
                        <label class="label">居住地址</label>
                        <label class="input">
                            <i class="icon-append fa fa-at"></i>
                            <input type="text" name="Address" value="<%= _viewModel.Address %>" maxlength="100" placeholder="請輸入居住地址" />
                        </label>
                    </section>
                </div>
            </fieldset>
            <fieldset>
                <div class="row">
                    <section class="col col-4">
                        <label class="label">緊急聯絡人</label>
                        <label class="input">
                            <i class="icon-append fa fa-user"></i>
                            <input type="text" name="EmergencyContactPerson" value="<%= _viewModel.EmergencyContactPerson %>" maxlength="20" placeholder="請輸入緊急聯絡人" />
                        </label>
                    </section>
                    <section class="col col-4">
                        <label class="label">關係</label>
                        <label class="select">
                            <select name="Relationship">
                                <option>父母</option>
                                <option>親子</option>
                                <option>夫婦</option>
                                <option>兄弟姊妹</option>
                                <option>朋友</option>
                            </select>
                            <i class="icon-append fa fa-address-card"></i>
                            <%  if (_viewModel.Relationship!=null)
                                { %>
                            <script>
                                $(function () {
                                    $('select[name="Relationship"]').val('<%= _viewModel.Relationship %>');
                                });
                            </script>
                            <%  } %>
                        </label>
                    </section>
                    <section class="col col-4">
                        <label class="label">緊急聯絡人電話</label>
                        <label class="input">
                            <i class="icon-append fa fa-mobile"></i>
                            <input type="tel" name="EmergencyContactPhone" value="<%= _viewModel.EmergencyContactPhone %>" maxlength="20" placeholder="請輸入聯絡電話" />
                        </label>
                    </section>
                </div>
            </fieldset>
        </form>
    </div>
    <script>
        console.log('debug...');
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 編輯學員資料</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 確定",
                "class": "btn btn-primary",
                click: function () {
                    var $form = $('#<%= _dialog %> form');
                    clearErrors();
                    $form.ajaxSubmit({
                        success: function (data) {
                            if ($.isPlainObject(data)) {
                                if (data.result) {
                                    if ($global.renderLearnerList) {
                                        $global.renderLearnerList(data.UID);
                                    }
                                    $('#<%= _dialog %>').dialog('close');
                                } else {
                                    alert(data.message);
                                }
                            } else {
                                $(data).appendTo($('body')).remove();
                            }
                        }
                    });
                }
            }],
            close: function () {
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
    String _dialog = "contractMember" + DateTime.Now.Ticks;
    ContractMemberViewModel _viewModel;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (ContractMemberViewModel)ViewBag.ViewModel;
        _model = (UserProfile)this.Model;
    }

</script>
