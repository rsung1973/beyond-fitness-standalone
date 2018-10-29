<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
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

                <div class="col-md-5">

                    <!-- Classic Heading -->
                    <h4 class="classic-title"><span>PDQ - Step 2</span></h4>
                    <!-- Start Contact Form -->
                    <p><strong>會員編號：</strong><span class="text-primary"><%= _model.MemberCode %></span></p>
                    <p><strong>學員姓名：</strong><span class="text-primary"><%= _model.FullName() %></span></p>

                    <div class="hr1" style="margin: 5px 0px;"></div>
                    <!-- Divider -->
                    <div class="col-md-12">
                        <h4 ><span class="glyphicon glyphicon-pencil" aria-hidden="true"></span>第一步：目標</h4>
                        <div class="hr1" style="margin-top: 5px; margin-bottom: 5px;"></div>
                        <div class="form-group has-feedback">
                            <label class="control-label" for="q1">1.對於你我相處一小時，你有什麼期望？</label>
                            <textarea class="form-control" rows="3"></textarea>
                        </div>

                        <div class="form-group has-feedback">
                            <label class="control-label" for="q2">2.你希望你的訓練中產生怎樣的結果？</label>
                            <textarea class="form-control" rows="3"></textarea>
                        </div>

                        <div class="form-group has-feedback">
                            <label class="control-label" for="q3">3.在訓練方案中，你需要實現的最重要目標是什麼？</label>
                            <textarea class="form-control" rows="3"></textarea>
                            <div class="sidebar">

                                <!-- Tags Widget -->
                                <div class="widget widget-tags">
                                    <div class="tagcloud">
                                        <a >A.減肥/身強體壯/運動表現/克服疾病=  挑戰型</a>
                                        <a >B.獲得肌肉/肌肉結實和有彈性=  保守型</a>
                                    </div>
                                </div>

                            </div>
                        </div>

                        <div class="form-group has-feedback">
                            <label class="control-label" for="q4">4.你希望實現自身目標的時間是多久？</label>
                            <textarea class="form-control" rows="3"></textarea>
                        </div>

                        <div class="form-group has-feedback">
                            <label class="control-label" for="q5">5.除了訓練時段，每天願意額外花多少時間參加幫助你完成目標的活動？</label>
                            <textarea class="form-control" rows="3"></textarea>
                        </div>

                        <div class="form-group has-feedback">
                            <label class="control-label" for="q6">6.訓練計劃是否完全取決於你自己，或者有其他人、事會影響你的訓練</label>
                            <textarea class="form-control" rows="3"></textarea>
                            <div class="sidebar">

                                <!-- Tags Widget -->
                                <h6 class="classic-title"><span>確定最佳化私人教練目標</span></h6>
                                <div class="widget widget-tags">
                                    <div class="tagcloud">
                                        <a >A.獲得肌肉/使肌肉有彈性=  健美</a>
                                        <a >B.體重減輕=  減肥</a>
                                        <a >C.身強體壯/克服疾病= 健康</a>
                                        <a >D.改善運動表現/表現=  運動訓練</a>
                                    </div>
                                </div>

                            </div>
                        </div>

                    </div>

                    <a  class="btn-system btn-medium border-btn"><i class="fa fa-times" aria-hidden="true"></i>取消</a>
                    <a href="vip-pdq-2.htm" class="btn-system btn-medium">下一步<i class="fa fa-hand-o-right" aria-hidden="true"></i></a>


                    <!-- End Contact Form -->

                </div>
        </div>
    </div>
    <!-- End content -->


    <script>
        $('#vip,#m_vip').addClass('active');
        $('#theForm').addClass('contact-form');
    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
    }




</script>
