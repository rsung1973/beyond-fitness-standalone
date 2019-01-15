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

<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <uc1:PageBanner runat="server" ID="PageBanner" Title="會員專區" TitleInEng="VIP" />

    <!-- Start Content -->
    <div id="content">
        <div class="container">

            <div class="row">

                <div class="col-md-12">

                    <!-- Classic Heading -->
                    <h4 class="classic-title"><span class="fa fa-cart-plus">新增/修改項目組</span></h4>

                    <!-- Start Contact Form -->


                        <div class="blog-post quote-post">

                            <div class="form-group has-feedback">
                                <div class="row">
                                    <div class="col-md-2">
                                        <label class="control-label" for="classno">組數：</label>
                                    </div>
                                    <div class="col-md-3">
                                        <select name="repeats" class="form-control">
                                            <option>1</option>
                                            <option>2</option>
                                            <option>3</option>
                                            <option>4</option>
                                            <option>5</option>
                                            <option>6</option>
                                            <option>7</option>
                                            <option>8</option>
                                            <option>9</option>
                                            <option>10</option>
                                            <option>11</option>
                                            <option>12</option>
                                        </select>
                                        <%  if (_item.Repeats.HasValue)
                                            { %>
                                                <script>
                                                    $('select[name="repeats"]').val(<%= _item.Repeats %>);
                                                </script>
                                        <%  } %>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <div class="row">
                                    <div class="col-md-2">
                                        <label for="exampleInputFile" class="control-label">休息：</label>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="input-group">
                                            <input class="form-control" name="breakInterval" size="16" type="number" value="<%= _item.BreakIntervalInSecond %>"/>
                                            <span class="input-group-addon">秒</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
<%--                            <div>
                                <a onclick="addTraining();" class="btn-system btn-small">新增項目 <i class="fa fa-plus-square-o" aria-hidden="true"></i></a>
                            </div>--%>

                        </div>
                        <div class="panel panel-default">
                            <!-- TABLE 1 -->
                            <% Html.RenderPartial("~/Views/Lessons/EditTrainingItemList.ascx", _item); %>
                        </div>
                        
                        <%  if (ViewBag.AssessLesson == true)
                            { %>
                                <a class="btn-system btn-medium" href="<%= VirtualPathUtility.ToAbsolute("~/Attendance/CompleteTraining") %>">回上課囉 <i class="fa fa-edit" aria-hidden="true"></i></a>
                    <%      }
                            else
                            { %>
                                <a class="btn-system btn-medium" href="<%= VirtualPathUtility.ToAbsolute("~/Lessons/CompleteTraining") %>">回預編課程 <i class="fa fa-edit" aria-hidden="true"></i></a>
                        <%  } %>
                        <a id="nextStep" class="btn-system btn-medium">確定 <i class="fa fa-thumbs-o-up" aria-hidden="true"></i></a>
                  
                    

                    <div class="hr1" style="margin-top: 5px; margin-bottom: 10px;"></div>


                    <!-- End Contact Form -->

                </div>

            </div>
        </div>
    </div>

    <!-- End content -->
    
    <% Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>

    <script>
        $('#vip,#m_vip').addClass('active');
        //$('#theForm').addClass('contact-form');

        var $addTrainingModal;

        $(function () {

            $('#breakInterval').rules('add', {
                'required': false,
                'number': true,
                'min': 0
            });
        });


        $('#nextStep').on('click', function (evt) {
            $('#loading').css('display', 'table');
            $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/ValidateToCommitTraining") %>', $('form').serialize(), function (data) {
                if (data.result) {
                    $('form').prop('action', '<%= VirtualPathUtility.ToAbsolute(ViewBag.AssessLesson==true ? "~/Attendance/CommitTraining" : "~/Lessons/CommitTraining") %>')
                        .submit();
                } else {
                    smartAlert(data.message);
                }
                $('#loading').css('display', 'none');
            });
        });

        function addTraining() {
            <%--            if (!$addTrainingModal) {
                $addTrainingModal = $('<div class="form-horizontal modal fade" tabindex="-1" role="dialog" aria-labelledby="addTrainingItem" aria-hidden="true" />');
                //$addTrainingModal.appendTo($('body'));
                $('<form method="post"/>')
                    .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Lessons/CommitTrainingItem") %>')
                    .appendTo($addTrainingModal)
                    .load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/AddTrainingItem") %>');
            }
            $addTrainingModal.modal({ show: true });
            $addTrainingModal.modal('show');--%>
            
            $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/CreateTrainingItem") %>', { 'repeats': $('select[name="repeats"]').val(), 'breakInterval': $('input[name="breakInterval"]').val() }, function (data) {
                $(data).insertBefore($('#newItem'));
            });

        }

        function deleteItem(itemID) {
            var event = event || window.event;
            confirmIt({ title: '刪除訓練項目', message: '確定刪除此訓練項目?' }, function (evt) {
                $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/DeleteTrainingItem") %>', { 'id': itemID }, function (data) {
                    if (data.result) {
                        $(event.target).parent().parent().remove();
                    } else {
                        smartAlert(data.message);
                    }
                });
            });
        }
    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    TrainingExecution _item;
    LessonPlan _plan;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _item = (TrainingExecution)this.Model;
    }



</script>
