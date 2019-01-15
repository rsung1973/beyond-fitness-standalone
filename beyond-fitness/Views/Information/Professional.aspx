<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <!-- RIBBON -->
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-heartbeat"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>專業訓練</li>
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
    <!-- END RIBBON -->
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
    <h1 class="page-title txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-heartbeat"></i>專業訓練
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">
    <div class="row">

        <div class="col-sm-12">

            <div class="well well-sm bg-color-darken txt-color-white">

                <h1>Professional, <small>8 Plans</small></h1>
                <div class="row">

                    <div class="col-xs-12 col-sm-6 col-md-3">
                        <div class="panel panel-darken pricing-big">
                            <img runat="server" src="~/img/ribbon.png" class="ribbon" alt="">
                            <div class="panel-heading">
                                <h3 class="panel-title">私人體能訓練顧問</h3>
                            </div>
                            <div class="panel-body no-padding text-align-center">
                                <div class="the-price">
                                    <img class="img-thumbnail" runat="server" src="~/img/professional/professional-fitness-01.jpg" alt="私人體能訓練顧問" />
                                </div>
                                <div class="price-features">
                                    <ul class="list-unstyled text-left">
                                        <li><i class="fa fa-check text-success"></i>我們擁有豐富的實務訓練經驗及充實的科學訓練背景知識。</li>
                                        <li><i class="fa fa-check text-success"></i>私人體能訓練課程就是依據客戶個人整體健康數據、全方位體能及生活評估，規劃出最有效率以及最貼近客戶需求的體能計劃。我們最大的榮耀是讓客戶得以在最好的環境、生活、時間中取得最大的訓練價值價值。</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xs-12 col-sm-6 col-md-3">
                        <div class="panel panel-darken pricing-big">

                            <div class="panel-heading">
                                <h3 class="panel-title">專業運動顧問</h3>
                            </div>
                            <div class="panel-body no-padding text-align-center">
                                <div class="the-price">
                                    <img class="img-thumbnail" runat="server" src="~/img/professional/professional-fitness-02.jpg" alt="專業運動顧問" />
                                </div>
                                <div class="price-features">
                                    <ul class="list-unstyled text-left">
                                        <li><i class="fa fa-check text-success"></i>提供最專業的運動競技能力訓練計畫，國際級的肌力與體能訓練專家(Strength and Conditioning Professional)將運動科學（Sport Science）與肌力及體能訓練（Strength and Conditioning）整合成有效率、有計畫性的科學化訓練系統，協助客戶特定運動項目需求分析，針對每一年度的重要賽事，強化其肌力體能與各種傷害防護訓練。</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xs-12 col-sm-6 col-md-3">
                        <div class="panel panel-darken pricing-big">
                            <div class="panel-heading">
                                <h3 class="panel-title">青少年體能訓練顧問</h3>
                            </div>
                            <div class="panel-body no-padding text-align-center">
                                <div class="the-price">
                                    <img class="img-thumbnail" runat="server" src="~/img/professional/professional-fitness-03.jpg" alt="青少年體能訓練顧問" />
                                </div>
                                <div class="price-features">
                                    <ul class="list-unstyled text-left">
                                        <li><i class="fa fa-check text-success"></i>Beyond Fitness 擁有完善、安全及專業體能訓練背景知識，提供學齡兒童及青少年健康成長、多元發展體能訓練計畫。全程將由相關體能訓練專家團隊，陪同教學、訓練、紀錄與監控評值。</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xs-12 col-sm-6 col-md-3">
                        <div class="panel panel-darken pricing-big">

                            <div class="panel-heading">
                                <h3 class="panel-title">銀髮族體能訓練顧問</h3>
                            </div>
                            <div class="panel-body no-padding text-align-center">
                                <div class="the-price">
                                    <img class="img-thumbnail" runat="server" src="~/img/professional/professional-fitness-04.jpg" alt="銀髮族體能訓練顧問" />
                                </div>
                                <div class="price-features">
                                    <ul class="list-unstyled text-left">
                                        <li><i class="fa fa-check text-success"></i>針對每位銀髮族做出最貼心，最安全。最照顧以及最完整四大方向健康體能訓練規劃流程，同時擁有相關的醫療合作機構及多方轉介服務，可提供最專業、最安全與最貼近銀髮族生活中的全方位健康體能需求規劃。</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <hr>

                <div class="row">

                    <div class="col-xs-12 col-sm-6 col-md-3">
                        <div class="panel panel-darken pricing-big">
                            <img runat="server" src="~/img/ribbon.png" class="ribbon" alt="">
                            <div class="panel-heading">
                                <h3 class="panel-title">小班制及團體課程規劃</h3>
                            </div>
                            <div class="panel-body no-padding text-align-center">
                                <div class="the-price">
                                    <img class="img-thumbnail" runat="server" src="~/img/professional/professional-fitness-05.jpg" alt="小班制及團體課程規劃" />
                                </div>
                                <div class="price-features">
                                    <ul class="list-unstyled text-left">
                                        <li><i class="fa fa-check text-success"></i>針對每位銀髮族做出最貼心，最安全。最照顧以及最完整四大方向健康體能訓練規劃流程，同時擁有相關的醫療合作機構及多方轉介服務，可提供最專業、最安全與最貼近銀髮族生活中的全方位健康體能需求規劃。</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xs-12 col-sm-6 col-md-3">
                        <div class="panel panel-darken pricing-big">

                            <div class="panel-heading">
                                <h3 class="panel-title">矯正訓練及復健後訓練</h3>
                            </div>
                            <div class="panel-body no-padding text-align-center">
                                <div class="the-price">
                                    <img class="img-thumbnail" runat="server" src="~/img/professional/professional-fitness-06.jpg" alt="矯正訓練及復健後訓練" />
                                </div>
                                <div class="price-features">
                                    <ul class="list-unstyled text-left">
                                        <li><i class="fa fa-check text-success"></i>擁有多家醫療合作機構，如復建科醫師（Rehab Doctor），物理治療單位（Physical Therapy, RT）在於非體能訓練專業部分，將適度轉介(Transfer)相關機構，經醫療或診斷恢復後，再檢測(detecting)。如復原後身體基本功能狀態良好，才開始逐步重建(Rebuilding)肌力及體能，進行專業的矯正訓練、功能性訓練 (Functional Training)，將為客戶打造最安全、最專業的訓練流程及健康規劃。</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xs-12 col-sm-6 col-md-3">
                        <div class="panel panel-darken pricing-big">

                            <div class="panel-heading">
                                <h3 class="panel-title">孕婦產前產後運動顧問</h3>
                            </div>
                            <div class="panel-body no-padding text-align-center">
                                <div class="the-price">
                                    <img class="img-thumbnail" runat="server" src="~/img/professional/professional-fitness-07.jpg" alt="孕婦產前產後運動顧問" />
                                </div>
                                <div class="price-features">
                                    <ul class="list-unstyled text-left">
                                        <li><i class="fa fa-check text-success"></i>在安全環境下，適當的運動能提供孕婦增進腸胃消化、循環代謝、免疫系統以及增加有利於分娩之身體條件，同時能刺激其胎兒生長發育，有利於胎兒之感覺、器官、平衡、呼吸及免疫系統發展。</li>
                                        <li><i class="fa fa-check text-success"></i>提供專業的孕婦運動訓練規劃，包含安全運動、生活飲食及健康相關建議規劃。以嚴謹的運動動作篩選，嚴格的運動強度即時監控，規劃產前運動、產後運動，內容包括輕度有氧適能、瑜珈、呼吸等相關訓練。</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xs-12 col-sm-6 col-md-3">
                        <div class="panel panel-darken pricing-big">

                            <div class="panel-heading">
                                <h3 class="panel-title">訓練派遣與企業顧問</h3>
                            </div>
                            <div class="panel-body no-padding text-align-center">
                                <div class="the-price">
                                    <img class="img-thumbnail" runat="server" src="~/img/professional/professional-fitness-08.jpg" alt="訓練派遣與企業顧問" />
                                </div>
                                <div class="price-features">
                                    <ul class="list-unstyled text-left">
                                        <li><i class="fa fa-check text-success"></i>提供各項到府派遣私人體能訓練服務包含專業體能顧問(Personal Trainer)、瑜珈(Yoga)、皮拉提斯(Pilates)以及各種符合客戶需求的體能規劃訓練。</li>
                                        <li><i class="fa fa-check text-success"></i>有最專業的體能訓練顧問團隊，能為各種企業公司提供長期規劃之健康體能訓練企劃，包括定期動作功能性篩檢、矯正動作訓練、肌力體能訓練及各種體能檢測等服務。</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

        </div>

    </div>
</asp:Content>
