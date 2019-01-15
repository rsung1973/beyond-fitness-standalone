<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="編輯員工資料" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitMember","Member",new { uid = _viewModel.UID }) %>" class="smart-form" method="post" autofocus>
            <fieldset id="branchStore" style="<%= _viewModel.IsCoach==true ? "display:block": "display:none" %>">
                <section>
                    <label class="label">隸屬分店</label>
                    <label class="select">
                        <select name="BranchID">
                            <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", model: _viewModel.BranchID); %>
                        </select>
                        <i class="icon-append far fa-keyboard"></i>
                    </label>
                </section>
            </fieldset>
            <fieldset>
                <div class="row">
                    <section class="col col-6">
                        <label class="label">姓名</label>
                        <label class="input">
                            <i class="icon-append fa fa-user"></i>
                            <input type="text" name="RealName" maxlength="20" placeholder="請輸入員工姓名" value="<%= _viewModel.RealName %>" />
                        </label>
                    </section>
                    <section class="col col-6">
                        <label class="label">行動電話</label>
                        <label class="input">
                            <i class="icon-append fa fa-phone"></i>
                            <input type="tel" name="Phone" maxlength="20" placeholder="請輸入行動電話" data-mask="0999999999" value="<%= _viewModel.Phone %>">
                        </label>
                    </section>
                </div>
            </fieldset>
            <%  if (_viewModel.UID.HasValue)
                { %>
            <fieldset>
                <section>
                    <label class="label">Email</label>
                    <label class="input">
                        <i class="icon-append fa fa-envelope"></i>
                        <input type="text" name="Email" maxlength="20" placeholder="請輸入Email" value="<%= _viewModel.Email %>" />
                    </label>
                </section>
            </fieldset>
            <%  } %>
            <fieldset>
                <section>
                    <label class="label">適用角色</label>
                    <div class="col col-4">
                        <label class="checkbox">
                            <input type="checkbox" name="AuthorizedRole" value="<%= (int)Naming.RoleID.Officer %>">
                            <i></i><%= Naming.RoleName[(int)Naming.RoleID.Officer] %></label>
                        <label class="checkbox">
                            <input type="checkbox" name="AuthorizedRole" value="<%= (int)Naming.RoleID.Coach %>">
                            <i></i><%= Naming.RoleName[(int)Naming.RoleID.Coach] %></label>
                        <label class="checkbox">
                            <input type="checkbox" name="AuthorizedRole" value="<%= (int)Naming.RoleID.Servitor %>">
                            <i></i><%= Naming.RoleName[(int)Naming.RoleID.Servitor] %></label>
                    </div>
                    <div class="col col-4">
                        <label class="checkbox">
                            <input type="checkbox" name="AuthorizedRole" value="<%= (int)Naming.RoleID.Manager %>">
                            <i></i><%= Naming.RoleName[(int)Naming.RoleID.Manager] %></label>
                        <label class="checkbox">
                            <input type="checkbox" name="AuthorizedRole" value="<%= (int)Naming.RoleID.Accounting %>">
                            <i></i><%= Naming.RoleName[(int)Naming.RoleID.Accounting] %></label>
                    </div>
                    <div class="col col-4">
                        <label class="checkbox">
                            <input type="checkbox" name="AuthorizedRole" value="<%= (int)Naming.RoleID.ViceManager %>">
                            <i></i><%= Naming.RoleName[(int)Naming.RoleID.ViceManager] %></label>
                        <label class="checkbox">
                            <input type="checkbox" name="AuthorizedRole" value="<%= (int)Naming.RoleID.Assistant %>">
                            <i></i><%= Naming.RoleName[(int)Naming.RoleID.Assistant] %></label>
                    </div>
                    <script>
                        $('input:checkbox[name="AuthorizedRole"][value="2"]').on('click', function (evt) {
                            checkStore($(this));
                            checkLevel($(this));
                        });

                        $('input:checkbox[name="AuthorizedRole"][value="9"]').on('click', function (evt) {
                            checkStore($(this));
                        });

                        $('input:checkbox[name="AuthorizedRole"][value="10"]').on('click', function (evt) {
                            checkStore($(this));
                        });

                        $('input:checkbox[name="AuthorizedRole"][value="8"]').on('click', function (evt) {
                            checkAssistant($(this));
                        });

                        function checkStore($item) {
                            if ($item.is(':checked')) {
                                $('#branchStore').css('display', 'block');
                            } else {
                                $('#branchStore').css('display', 'none');
                            }
                        }

                        function checkLevel($item) {
                            if ($item.is(':checked')) {
                                $('#coachLevel').css('display', 'block');
                            } else {
                                $('#coachLevel').css('display', 'none');
                            }
                        }

                        function checkAssistant($item) {
                            if ($item.is(':checked')) {
                                $('#forAssistant').css('display', 'block');
                            } else {
                                $('#forAssistant').css('display', 'none');
                            }
                        }


                        $(function () {
                            var $item;

                            $('#coachLevel').css('display', 'none');
                            $('#branchStore').css('display', 'none');
                            $('#forAssistant').css('display', 'none');

                            <%  foreach(var item in _viewModel.AuthorizedRole)
                                {   %>
                            $item = $('input:checkbox[name="AuthorizedRole"][value="<%= item %>"]');
                            $item.prop('checked', true);
                            <%      if (item == (int)Naming.RoleID.Coach)
                                    {   %>
                            checkStore($item);
                            checkLevel($item);
                            <%      }
                                    else if (item == (int)Naming.RoleID.Manager || item==(int)Naming.RoleID.ViceManager)
                                    {   %>
                            checkStore($item);
                            <%      }
                                    else if (item == (int)Naming.RoleID.Assistant)
                                    {   %>
                            checkAssistant($item);
                            <%      }   %>
                            <%  }   %>
                        });

                    </script>
                </section>
            </fieldset>
            <fieldset id="forAssistant">
                <div class="row">
                    <section class="col col-6">
                        <label class="label">是否提供員工福利課程</label>
                        <label class="select">
                            <select name="HasGiftLessons">
                                <option value="False" <%= _viewModel.HasGiftLessons!=true ? "selected" : null %>>否</option>
                                <option value="True" <%= _viewModel.HasGiftLessons==true ? "selected" : null %>>是</option>
                            </select>
                            <i class="icon-append far fa-keyboard"></i>
                        </label>
                        <script>
                            function checkGiftLessons() {
                                var $item = $('#<%= _dialog %> select[name="HasGiftLessons"]');
                                if ($item.val()=='True') {
                                    $('.giftLessons').css('display', 'block');
                                } else {
                                    $('.giftLessons').css('display', 'none');
                                }
                            }

                            $('#<%= _dialog %> select[name="HasGiftLessons"]').on('change', function (evt) {
                                checkGiftLessons();
                            });

                            $(function () {
                                checkGiftLessons();
                            });
                        </script>
                    </section>
                    <section class="col col-6 giftLessons">
                        <label class="label">每月提供堂數</label>
                        <label class="input">
                            <i class="icon-append fa fa-university"></i>
                            <input type="text" name="MonthlyGiftLessons" value="<%= _viewModel.MonthlyGiftLessons %>" maxlength="2" placeholder="請輸入每月提供堂數" data-mask="99"/>
                        </label>
                    </section>
                </div>
            </fieldset>
            <fieldset id="coachLevel">
                <div class="row">
                    <section class="col col-6">
                        <label class="label">是否為資深體能顧問</label>
                        <label class="select">
                            <select name="LevelCategory">
                                <option value="1105" <%= _viewModel.LevelCategory == 1105 ? "selected" : null %>>否</option>
                                <option value="1104" <%= _viewModel.LevelCategory == 1104 ? "selected" : null %>>是</option>
                            </select>
                            <i class="icon-append far fa-keyboard"></i>
                        </label>
                    </section>
                    <section class="col col-6">
                        <label class="label">P.T 級別</label>
                        <label class="select">
                            <select name="LevelID">
                            </select>
                            <i class="icon-append fa fa-thermometer-full"></i>
                        </label>
                    </section>
                    <script>
                        $(function () {

                            function buildLevel(category) {
                                var $levelID = $('select[name="LevelID"]');
                                $levelID.find('option').remove();
                                if (category == '<%= (int)Naming.ProfessionalCategory.Junior %>') {
                                    <%  foreach(var item in models.GetTable<ProfessionalLevel>().Where(l=>l.CategoryID==(int)Naming.ProfessionalCategory.Junior))
                        {   %>
                                    $('<option>').attr('value', '<%= item.LevelID %>').text('<%= item.LevelName %>').appendTo($levelID);
                                    <%  } %>
                                } else {
                                    <%  foreach(var item in models.GetTable<ProfessionalLevel>().Where(l=>l.CategoryID==(int)Naming.ProfessionalCategory.Senior))
                        {   %>
                                    $('<option>').attr('value', '<%= item.LevelID %>').text('<%= item.LevelName %>').appendTo($levelID);
                                    <%  } %>
                                }
                            }

                            $('select[name="LevelCategory"]').on('change', function (evt) {
                                buildLevel($('select[name="LevelCategory"]').val());
                            });

                            <%  if(_viewModel.LevelID.HasValue)
                                {   %>
                            buildLevel('<%= _viewModel.LevelCategory %>');
                            $('select[name="LevelID"]').val('<%= _viewModel.LevelID %>');
                            <%  }
                                else
                                {   %>
                            buildLevel('<%= (int)Naming.ProfessionalCategory.新制 %>');
                            <%  }   %>

                        });
                    </script>
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
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 編輯<%= _viewModel.CoachRole==(int)Naming.RoleID.Coach ? "員工" : "員工" %>資料</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 確定",
                "class": "btn btn-primary",
                click: function () {
                    clearErrors();
                    showLoading();
                    $('#<%= _dialog %> form').ajaxSubmit({
                        success: function (data) {
                            hideLoading();
                            if (data.result) {
                                alert('資料已儲存!!');
                                $('#<%= _dialog %>').dialog('close');
                                showLoading();
                                window.location.href = '<%= Url.Action("ListCoaches","Member") %>';
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
    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "modifyCoachDialog" + DateTime.Now.Ticks;
    CoachViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (CoachViewModel)ViewBag.ViewModel;
    }

</script>
