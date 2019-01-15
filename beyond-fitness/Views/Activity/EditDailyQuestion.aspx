<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-pencil-alt"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>上稿管理></li>
            <li>每日問與答</li>
            <li>新增問題</li>
        </ol>
        <!-- end breadcrumb -->

        <!-- You can also add more buttons to the
                ribbon for further usability

                Example below:

                <span class="ribbon-button-alignment pull-right">
                <span id="search" class="btn btn-ribbon hidden-xs" data-title="search"><i class="fa-grid"></i> Change Grid</span>
                <span id="add" class="btn btn-ribbon hidden-xs" data-title="add"><i class="fa-plus"></i> Add</span>
                <span id="search" class="btn btn-ribbon" data-title="search"><i class="fa-search"></i> <span class="hidden-mobile">Search</span></span>
                </span> -->

    </div>
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
    <h1 class="page-title txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-pencil-alt"></i>每日問與答
                            <span>>  
                                新增問題
                            </span>
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">

        <!-- NEW COL START -->
        <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget" id="wid-id-6" data-widget-editbutton="false" data-widget-custombutton="false" data-widget-editbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false" data-widget-colorbutton="false">
                <!-- widget options:
                                    usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">
                                    
                                    data-widget-colorbutton="false" 
                                    data-widget-editbutton="false"
                                    data-widget-togglebutton="false"
                                    data-widget-deletebutton="false"
                                    data-widget-fullscreenbutton="false"
                                    data-widget-custombutton="false"
                                    data-widget-collapsed="true" 
                                    data-widget-sortable="false"
                                    
                                -->
                <header>
                    <span class="widget-icon"><i class="fa fa-edit"></i></span>
                    <h2>填寫問題資訊 </h2>

                </header>

                <!-- widget div-->
                <div>

                    <!-- widget edit box -->
                    <div class="jarviswidget-editbox">
                        <!-- This area used as dropdown edit box -->

                    </div>
                    <!-- end widget edit box -->

                    <!-- widget content -->
                    <div class="widget-body bg-color-darken txt-color-white no-padding">

                        <form action="<%= Url.Action("EditDailyQuestion") %>" id="pageForm" class="smart-form" method="post">
                            <input type="hidden" name="questionID" value="<%= _viewModel.QuestionID %>" />
                            <fieldset>
                                <section>
                                    <label class="select">
                                        <%  var inputItem = new InputViewModel { Id = "AskerID", Name = "AskerID", DefaultValue = _viewModel.AskerID };
                                            ViewBag.SelectIndication = "<option value=''>請選擇提問者</option>";
                                            Html.RenderPartial("~/Views/Lessons/SimpleCoachSelector.ascx", inputItem); %>
                                        <i class="icon-append far fa-keyboard"></i>
                                    </label>
                                </section>
                                <section>
                                    <label class="input">
                                        <i class="icon-append far fa-keyboard"></i>
                                        <input type="text" class="input-lg" name="question" id="question" maxlength="100" placeholder="請輸入題目" value="<%= _viewModel.Question %>"/>
                                    </label>
                                    <p class="note"><strong>Note:</strong> 最多僅能輸入100個中英文字</p>
                                </section>
                            </fieldset>
                            <fieldset>
                                <div class="row">
                                    <section class="col col-6">
                                        <label class="label">選項A</label>
                                        <label class="input">
                                            <i class="icon-append far fa-keyboard"></i>
                                            <input type="text" class="input-lg" name="Suggestion" id="Suggestion0" maxlength="60" placeholder="請輸入選項A" value="<%= _viewModel.Suggestion!=null && _viewModel.Suggestion.Length>0 ? _viewModel.Suggestion[0] : null %>" />
                                        </label>
                                        <p class="note"><strong>Note:</strong> 最多僅能輸入60個中英文字</p>
                                    </section>
                                    <section class="col col-6">
                                        <label class="label">選項B</label>
                                        <label class="input">
                                            <i class="icon-append far fa-keyboard"></i>
                                            <input type="text" class="input-lg" name="Suggestion" id="Suggestion1" maxlength="60" placeholder="請輸入選項B" value="<%= _viewModel.Suggestion!=null && _viewModel.Suggestion.Length>1 ? _viewModel.Suggestion[1] : null %>" />
                                        </label>
                                        <p class="note"><strong>Note:</strong> 最多僅能輸入60個中英文字</p>
                                    </section>
                                </div>
                                <div class="row">
                                    <section class="col col-6">
                                        <label class="label">選項C</label>
                                        <label class="input">
                                            <i class="icon-append far fa-keyboard"></i>
                                            <input type="text" class="input-lg" name="Suggestion" id="Suggestion2" maxlength="60" placeholder="請輸入選項C" value="<%= _viewModel.Suggestion!=null && _viewModel.Suggestion.Length>2 ? _viewModel.Suggestion[2] : null %>" />
                                        </label>
                                        <p class="note"><strong>Note:</strong> 最多僅能輸入60個中英文字</p>
                                    </section>
                                    <section class="col col-6">
                                        <label class="label">選項D</label>
                                        <label class="input">
                                            <i class="icon-append far fa-keyboard"></i>
                                            <input type="text" class="input-lg" name="Suggestion" id="Suggestion3" maxlength="60" placeholder="請輸入選項D" value="<%= _viewModel.Suggestion!=null && _viewModel.Suggestion.Length>3 ? _viewModel.Suggestion[3] : null %>" />
                                        </label>
                                        <p class="note"><strong>Note:</strong> 最多僅能輸入60個中英文字</p>
                                    </section>
                                </div>
                            </fieldset>
                            <div>
                                <hr class="simple">
                            </div>
                            <fieldset>
                                <div class="row">
                                    <section class="col col-6">
                                        <label class="label">答案</label>
                                        <div class="inline-group">
                                            <label class="radio">
                                                <input type="radio" name="RightAnswerIndex" id="RightAnswerIndex" value="0" <%= _viewModel.RightAnswerIndex==0 ? "checked" : null %> />
                                                <i></i>A</label>
                                            <label class="radio">
                                                <input type="radio" name="RightAnswerIndex" value="1" <%= _viewModel.RightAnswerIndex==1 ? "checked" : null %> />
                                                <i></i>B</label>
                                            <label class="radio">
                                                <input type="radio" name="RightAnswerIndex" value="2" <%= _viewModel.RightAnswerIndex==2 ? "checked" : null %> />
                                                <i></i>C</label>
                                            <label class="radio">
                                                <input type="radio" name="RightAnswerIndex" value="3" <%= _viewModel.RightAnswerIndex==3 ? "checked" : null %> />
                                                <i></i>D</label>
                                        </div>
                                    </section>
                                </div>
                            </fieldset>
                            <fieldset>
                                <div class="row">
                                    <section class="col col-6">
                                        <label class="label">回饋點數</label>
                                        <label class="input">
                                            <i class="icon-append fa fa-money"></i>
                                            <input type="text" class="input-lg" name="BonusPoint" id="BonusPoint" maxlength="60" placeholder="請輸入回饋點數" value="<%= _viewModel.BonusPoint %>" />
                                        </label>
                                        <p class="note"><strong>Note:</strong> 僅能輸入1~100正整數</p>
                                    </section>
                                </div>
                            </fieldset>

                            <footer>
                                <button type="submit" name="submit" class="btn btn-primary">
                                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                                </button>
                            </footer>
                        </form>

                    </div>
                    <!-- end widget content -->

                </div>
                <!-- end widget div -->

            </div>
            <!-- end widget -->
        </article>
        <!-- END COL -->

    </div>
    <script>
        $(function () {

            $pageFormValidator.settings.submitHandler = function (form) {


                if (!$('input[name="RightAnswerIndex"]').is(':checked')) {
                    $('#RightAnswerIndex-error').css('display', 'block');
                    $('#RightAnswerIndex-error').text('請選擇一個正確答案!!');
                    return;
                }

                var result=true;
                //$('input[name="Suggestion"]').each(function (idx) {
                //    var $this = $(this);
                //    if ($this.val().length == 0) {
                //        var id = '#Suggestion' + idx + '-error';
                //        $(id).css('display', 'block');
                //        $(id).text('請輸入選項!!');
                //        result = false;
                //    }
                //});

                return result;

            };

            $('#AskerID').rules('add', {
                'required': true,
                'messages': {
                    'required': '請選擇提問者'
                }
            });

            $('#BonusPoint').rules('add', {
                'number': true,
                'required': true,
                'min': 1,
                'max': 100,
                'messages': {
                    'required': '請輸入回饋點數',
                    'number': '僅能輸入1~100正整數',
                    'min': '僅能輸入1~100正整數',
                    'max': '僅能輸入1~100正整數'
                }
            });

            $('#question').rules('add', {
                'required': true,
                'messages': {
                    'required': '請輸入題目'
                }
            });

            $('input[name="Suggestion"]').each(function (idx) {
                $(this).rules('add', {
                    'required': true,
                    'messages': {
                        'required': '請輸入選項'
                    }
                });
            });

        });
    </script>

</asp:Content>
<script runat="server">

    ModelStateDictionary _modelState;
    PDQQuestionViewModel _viewModel;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _viewModel = (PDQQuestionViewModel)ViewBag.ViewModel;
    }

</script>
