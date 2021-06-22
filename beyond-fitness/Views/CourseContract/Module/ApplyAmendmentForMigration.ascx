<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<div class="row">
    <section class="col col-6">
        <label class="label">上課地點</label>
        <label class="select">
            <select name="BranchID" id="<%= _branchID %>">
                <%  ViewBag.IntentStore = models.GetTable<BranchStore>()
                        //.Where(b => b.BranchID != _model.CourseContractExtension.BranchID)
                        .Where(b => b.BranchID == 2)
                        .Select(b => b.BranchID).ToArray();
                    Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.cshtml", model: -1); %>
            </select>
            <i class="icon-append fa fa-at"></i>
        </label>
        <script>
            $('#<%= _branchID %>').on('change', function (evt) {
                loadPriceList();
            });
        </script>
    </section>
    <section class="col col-6">
        <label class="label">課程單價 <span class="label-warning"><i class="fa fa-info-circle"></i>原購買堂數：<%= _model.Lessons %>堂 / <%= _model.LessonPriceType.ListPrice %>元</span></label>
        <label class="select">
            <select name="PriceID" id="<%= _priceID %>">
            </select>
            <i class="icon-append fa fa-at"></i>
        </label>
        <script>
            var $priceList;
            function loadPriceList() {
                $.post('<%= Url.Action("ListLessonPrice","CourseContract") %>',{ 'branchID':$('#<%= _branchID %>').val(), 'duration':'<%= _model.LessonPriceType.DurationInMinutes %>','feature': $global.useLearnerDiscount ? '<%= (int?)Naming.LessonPriceFeature.舊會員續約 %>':null },function(data) {
                    $('select[name="PriceID"]').empty()
                    .html('<option value="">請選擇</option>')
                    .append($(data));
                    //$('input[name="Lessons"]').val('');
                    $priceList = [];
                    //$('#singlePrice').text('');
                    $('#<%= _priceID %> option[lowerLimit]').each(function(idx,element) {
                        var $opt = $(this);
                        if($opt.attr('lowerLimit')!='') {
                            $priceList.push({
                                'lowerLimit':parseInt($opt.attr('lowerLimit')),
                                'upperBound':$opt.attr('upperBound')=='' ? null : parseInt($opt.attr('upperBound')),
                                'option':$opt
                            });
                        }
                    });

                    if($priceList.length>0) {
                        $('#singlePrice').text($priceList[0].option.attr('listPrice'));
                    }

                    if($global.defaultPriceID!='') {
                        $('select[name="PriceID"]').val($global.defaultPriceID);
                        $global.defaultPriceID = '';
                    } else {
                        //if($priceList.length>0) {
                        //    matchLessonPrice();
                        //}
                    }
                });
            }

            $('#<%= _priceID %>').on('change', function (evt) {
                locationInfo();
            });


            function locationInfo() {
                var branchID = $('#<%= _branchID %>').val();
                var $option = $('#<%= _branchID %> option:selected');
                var remained = <%= _model.RemainedLessonCount() %>;
                var currPrice = <%= _model.LessonPriceType.ListPrice %> ;
                var $optPrice = $('#<%= _priceID %> option:selected');
                var newPrice = parseInt(($optPrice.attr('listPrice')+'').replace(',',''));
                $('#location').text($option.text());
                if($option.attr('value')=='2' && newPrice>currPrice) {
                    var amt = remained * (newPrice-currPrice);
                    $('#location').text($('#location').text()+'，剩餘' + remained 
                        + '堂(' + currPrice + '元)轉換至費用較高之場所依同方案價格(' + newPrice + '元)計算補足差額(' + amt + '元）。');
                }
            }

            //function matchLessonPrice() {
            //    var $this = $('input[name="Lessons"]');
            //    if($this.val()!='' && $priceList.length>0) {
            //        var lessons = parseInt($this.val());
            //        var idx;
            //        for(idx=0;idx<$priceList.length;idx++) {
            //            if(lessons>=$priceList[idx].lowerLimit) {
            //                continue;
            //            } else {
            //                break;
            //            }
            //        }
            //        if(idx>0)
            //            $priceList[idx-1].option.prop('selected',true);                                }
            //}

            $(function(){
                $global.useLearnerDiscount = <%= _useLearnerDiscount ? "true" : "false" %>;
                loadPriceList();
                locationInfo();
            });
        </script>
    </section>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContractViewModel _viewModel;
    String _dialog = "amendment" + DateTime.Now.Ticks;
    String _priceID = "priceID" + DateTime.Now.Ticks;
    String _branchID = "branchID" + DateTime.Now.Ticks;
    CourseContract _model;
    bool _useLearnerDiscount;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
        _useLearnerDiscount = models.CheckLearnerDiscount(_model.CourseContractMember.Select(m => m.UID));
    }

</script>
