<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    &times;
                </button>
                <h4 class="modal-title" id="myModalLabel"><%= _model.RegisterID.HasValue ? "修改" : "新增" %>課程購買數</h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">
                <form action="<%= VirtualPathUtility.ToAbsolute("~/Member/CommitLessons") %>" id="pageForm" class="smart-form" method="post">
                    <input type="hidden" name="registerID" value="<%= _model.RegisterID %>" />
                    <fieldset>
                        <div class="row">
                            <section class="col col-6">
                                <label>課程類型</label>
                                <label class="select">
                                    <% Html.RenderPartial("~/Views/Member/LearnerClassLevel.ascx", _model);  %>
                                    <i></i>
                                </label>
                            </section>
                            <section class="col col-6">
                                <label>購買堂數</label>
                                <label class="input">
                                    <i class="icon-append fa fa-shopping-cart"></i>
                                    <input type="text" name="Lessons" id="Lessons" maxlength="3" placeholder="請輸入購買數量" value="<%= _model.Lessons %>" />
                                </label>
                            </section>
                        </div>
                    </fieldset>
                    <fieldset>
                        <div class="row">
                            <section class="col col-6">
                                <label>是否為團體課程</label>
                                <label class="select">
                                    <select name="grouping" id="grouping">
                                        <option value="N">否</option>
                                        <option value="Y">是</option>
                                    </select><i></i>
                                </label>
                            </section>
                            <section class="col col-6" id="selectMemberCount" style="display: <%= _model.Grouping == "Y" ? "display" : "none" %>;">
                                <label>團體上課人數</label>
                                <label class="select">
                                    <select name="MemberCount" id="MemberCount">
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                        <option>6</option>
                                    </select>
                                    <i></i>
                                </label>
                            </section>
                            <script>
                                <%  if(_model.MemberCount>1)
                                    {   %>
                                        $(function () {
                                            $('#grouping').val('<%= _model.Grouping %>');
                                            $('#MemberCount').val(<%= _model.MemberCount %>);
                                        });
                                <%  }   %>
                            </script>
                        </div>
                    </fieldset>
                    <div>
                        <hr class="simple"/>
                    </div>
                    <fieldset>
                        <section>
                            <label>請選擇體能顧問</label>
                            <label class="select">
                                <% //ViewBag.SelectIndication = "<option value=''></option>";
                                    Html.RenderPartial("~/Views/Lessons/SimpleCoachSelector.ascx", new InputViewModel { Id = "AdvisorID", Name = "AdvisorID", DefaultValue = _model.AdvisorID>1 ? _model.AdvisorID : (int?)null }); %>
                                <i class="icon-append far fa-keyboard"></i>
                            </label>
                        </section>
                    </fieldset>
                    <div>
                        <hr class="simple">
                    </div>
                    <fieldset>
                        <div class="row">
                            <section class="col col-6">
                                <label>學員付款方式</label>
                                <label class="select">
                                    <select name="payment">
                                        <option value="Cash">現金</option>
                                        <option value="CreditCard">信用卡</option>
                                    </select>
                                    <i></i>
                                </label>
                                <script>
                                    $(function () {
                                        $('select[name="payment"]').val('<%= String.IsNullOrEmpty(_model.Payment) ? "Cash" : _model.Payment %>');
                                    });
                                </script>
                            </section>
                            <section class="col col-6" id="selectFeeShared" style="display:<%= _model.Payment=="CreditCard" ? "display" : "none" %>;">
                                <label>體能顧問是否自行吸收信用卡刷卡手續費</label>
                                <label class="select">
                                    <select name="feeShared" id="feeShared">
                                        <option value="1">是</option>
                                        <option value="0">否</option>
                                    </select>
                                    <i></i>
                                </label>
                                <%  if (_model.FeeShared.HasValue)
                                    { %>
                                        <script>
                                            $(function () {
                                                $('select[name="feeShared"]').val(<%= _model.FeeShared %>);
                                            });
                                        </script>
                                <%  } %>
                            </section>
                        </div>
                    </fieldset>
                    <fieldset>
                        <div class="row">
                            <section class="col col-6">
                                <label>是否使用分期</label>
                                <label class="select">
                                    <select name="installments" id="installments">
                                        <option value="N">否</option>
                                        <option value="Y" <%= _model.Installments=="Y" ? "selected" : null %>>是</option>
                                    </select>
                                    <i></i>
<%--                                    <%  if (_model.ByInstallments > 0)
                                        { %>
                                    <script>
                                        $(function () {
                                            $('#installments').val('Y');
                                        });
                                    </script>
                                    <%  } %>--%>
                                </label>
                            </section>
                            <section class="col col-6" id="selectIntallments" style="display: <%= _model.Installments=="Y" ? "display" : "none" %>;">
                                <label>分期期數</label>
                                <label class="input">
                                    <i class="icon-append fa fa-shopping-cart"></i>
                                    <input type="text" name="ByInstallments" id="ByInstallments" maxlength="3" placeholder="請輸入分期期數" value="<%= _model.ByInstallments %>" />
                                </label>
                            </section>
                        </div>
                    </fieldset>
                    <footer>
                        <button type="submit" name="submit" class="btn btn-primary">
                            送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                        </button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">
                            取消
                        </button>
                    </footer>
                </form>
            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
    </div>
<script>

    $('#grouping').on('change', function (evt) {
        if ($(this).val()=='Y') {
            $('#selectMemberCount').css('display', 'block');
        } else {
            $('#selectMemberCount').css('display', 'none');
        }
    });

    $('#installments').on('change', function (evt) {
        if ($(this).val()=='Y') {
            $('#selectIntallments').css('display', 'block');
        } else {
            $('#selectIntallments').css('display', 'none');
        }
    });

    $('select[name="payment"]').on('change', function (evt) {
        if ($(this).val()=='CreditCard') {
            $('#selectFeeShared').css('display', 'block');
        } else {
            $('#selectFeeShared').css('display', 'none');
        }
    });

    $(function () {
        
        $('#Lessons').focus();

<%--        $('#AdvisorID').rules('add', {
            'required': true,
            messages: {
                'required': '請選擇教練'
            }
        });

        $('#ByInstallments').rules('add', {
            'required': true,
            'min': 2,
            messages: {
                'required': '請輸入分期期數',
                'min': '請輸入分期期數'
            }
        });

        $('#MemberCount').rules('add', {
            'required': true,
            messages: {
                'required': '請選擇團體上課人數'
            }
        });

        $('#Lessons').rules('add', {
            'number': true,
            'required': true,
            'min': 1,
            messages: {
                'required': '請輸入購買數量',
                'number': '請輸入購買數量',
                'min': '請輸入購買數量'
            }
        });
--%>
    });



</script>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonViewModel _model;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonViewModel)this.Model;
    }

</script>
