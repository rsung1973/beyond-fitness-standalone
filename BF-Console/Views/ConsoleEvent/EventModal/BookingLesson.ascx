<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-body">
                <a class="closebutton" data-dismiss="modal"></a>
                <div class="row clearfix">
                    <div class="col-12">
                        <div class="card action_bar">
                            <div class="header">
                                <h2>預約 <span class="col-red"><%= _model.FullName() %></span> session</h2>
                            </div>
                            <div class="body">
                                <div class="row clearfix">
                                    <%--                                    <div class="col-lg-4 col-md-6 col-sm-6 col-12">
                                        <div class="checkbox">
                                            <input id="repeate_checkbox" type="checkbox">
                                            <label for="repeate_checkbox">
                                                週期性
                                            </label>
                                        </div>
                                    </div>
                                    <div class="col-lg-8 col-md-6 col-sm-6 col-12">
                                        <select class="form-control show-tick repeate">
                                            <option value="0">-- 請選擇重複頻率 --</option>
                                            <option value="1">每週一</option>
                                            <option value="2">每週二</option>
                                            <option value="3">每週三</option>
                                            <option value="4">每週四</option>
                                            <option value="5">每週五</option>
                                            <option value="6">每週六</option>
                                            <option value="7">每週日</option>
                                        </select>
                                        <label class="material-icons help-error-text repeate">clear 請選擇重複頻率</label>
                                    </div>
                                    <div class="col-lg-6 col-md-4 col-sm-6 col-12 repeate">
                                        <div class="input-group">
                                            <input type="text" class="form-control date" data-date-format="yyyy/mm/dd" readonly="readonly" placeholder="開始日期" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-calendar"></i>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-lg-6 col-md-4 col-sm-6 col-12 repeate">
                                        <div class="input-group">
                                            <input type="text" class="form-control date" data-date-format="yyyy/mm/dd" readonly="readonly" placeholder="結束日期" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-calendar"></i>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-lg-6 col-md-4 col-sm-6 col-12 repeate">
                                        <div class="input-group">
                                            <input type="text" class="form-control date" data-date-format="hh:ii" readonly="readonly" placeholder="上課時間" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-time"></i>
                                            </span>
                                        </div>
                                    </div>--%>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12 single">
                                        <div class="input-group">
                                            <input type="text" class="form-control datetime" data-date-format="yyyy/mm/dd hh:ii" readonly="readonly" placeholder="開始時間" name="ClassDate" value="<%= $"{_viewModel.StartDate:yyyy/MM/dd HH:mm}" %>" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-time"></i>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                                        <div>
                                            <select class="form-control show-tick" name="BranchID">
                                                <option value="">-- 請選擇地點 --</option>
                                                <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", model: -1);    %>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="row clearfix">
                                    <div class="col-12">
                                        <div class="card xl-blue inbox">
                                            <div class="cover">
                                                <ul class="mail_list list-group list-unstyled">
                                                    <li class="list-group-item xl-blue">
                                                        <div class="media">
                                                            <div class="pull-left">
                                                                <div class="thumb hidden-sm-down m-r-20">
                                                                    <% _model.PictureID.RenderUserPicture(this.Writer, new { @class = "rounded-circle popfit" }, "images/avatar/noname.png"); %>
                                                                </div>
                                                            </div>
                                                            <div class="media-body">
                                                                <div class="media-heading">
                                                                    <a class="m-r-10">搜尋結果如下：</a>
                                                                </div>
                                                                <%  bool hasChoice = false;
                                                                    var pdqStatus = _model.IsCompletePDQ();
                                                                    var contractLessons = _contracts.Join(models.GetTable<RegisterLessonContract>(), c => c.ContractID, r => r.ContractID, (c, r) => r)
                                                                                            .Select(r => r.RegisterLesson)
                                                                                            .Where(r => r.UID == _model.UID)
                                                                                            .Where(r => r.Attended != (int)Naming.LessonStatus.課程結束);
                                                                    var enterpriseLessons = _enterpriseContract.Join(models.GetTable<RegisterLessonEnterprise>(), t => t.ContractID, r => r.ContractID, (t, r) => r);
                                                                    var enterpriseLessonItems = enterpriseLessons.Select(r => r.RegisterLesson).Where(r => r.UID == _model.UID);
                                                                    if (!pdqStatus)
                                                                    {   %>
                                                                <p class="msg col-red"><i class="zmdi zmdi-info-outline"></i>PDQ尚未登打或登打不完全</p>
                                                                <%  }
                                                                    var questionnaireStatus =
                                                                        contractLessons.PromptLessonQuestionnaireRequest(models).Count() > 0
                                                                        || enterpriseLessonItems.PromptLessonQuestionnaireRequest(models).Count() > 0;
                                                                    if (questionnaireStatus)
                                                                    {   %>
                                                                <p class="msg col-red"><i class="zmdi zmdi-info-outline"></i>階段性調整計劃未填寫，請 <u>立即填寫</u> 階段性調整計劃</p>
                                                                <%  } %>
                                                            </div>
                                                        </div>
                                                    </li>
                                                </ul>
                                                <%  var lessons = models.GetTable<RegisterLesson>()
                                                            .Where(r => r.UID == _model.UID)
                                                            .Where(r => r.Attended != (int)Naming.LessonStatus.課程結束);
                                                    var enterpriseTrial = enterpriseLessons.Where(r => r.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.體驗課程);
                                                    %>
                                                <ul class="mail_list list-group list-unstyled">
                                                <%  if (_model.UserProfileExtension.CurrentTrial.HasValue)
                                                    {
                                                        var trialLesson = models.GetTable<RegisterLesson>()
                                                                .Where(r => r.UID == _model.UID).Where(r => r.LessonPriceType.Status == (int)Naming.LessonPriceStatus.體驗課程);
                                                        var trialLessonItem = trialLesson.FirstOrDefault();
                                                        var trialBookable = trialLessonItem != null && trialLessonItem.LessonTime == null;
                                                        if (trialBookable)
                                                            hasChoice = true;
                                                        %>
                                                        <li class="list-group-item">
                                                            <div class="media">
                                                                <div class="pull-left">
                                                                    <div class="controls">
                                                                        <div class="checkbox">
                                                                            <input type="checkbox" <%= trialBookable ? null : "disabled" %> id="trialLesson" name="RegisterID" value="" onclick="selectBooking(this, '<%= (int)Naming.LessonPriceStatus.體驗課程 %>');"/>
                                                                            <label for="trialLesson"></label>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="media-body">
                                                                    <div class="media-heading">
                                                                        <a class="m-r-10">體驗檢測</a>
                                                                        <small class="float-right text-muted"><time><%= trialBookable ? 1 : 0 %>/1</time></small>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </li>
                                                <%  }   %>
                                                <%  
                                                    var enterpriseTrialItem = enterpriseTrial.FirstOrDefault();
                                                    if (enterpriseTrialItem!=null)
                                                    {
                                                        var trialLesson = enterpriseTrial.Select(r => r.RegisterLesson).Where(r => r.UID == _model.UID);
                                                        var bookableLessons = trialLesson.Where(r => r.LessonTime == null);
                                                        var item = bookableLessons.FirstOrDefault();
                                                        if (item != null)
                                                        {
                                                            hasChoice = true;
                                                        }
                                                        %>
                                                        <li class="list-group-item">
                                                            <div class="media">
                                                                <div class="pull-left">
                                                                    <div class="controls">
                                                                        <div class="checkbox">
                                                                            <input type="checkbox" id="enterpriseTrial<%= item?.RegisterID %>" <%= item==null ? "disabled" : null %> name="RegisterID"  value="<%= item?.RegisterID %>" onclick="selectBooking(this, '<%= (int)Naming.LessonPriceStatus.企業合作方案 %>');" />
                                                                            <label for="enterpriseTrial<%= item?.RegisterID %>"></label>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="media-body">
                                                                    <div class="media-heading">
                                                                        <a class="m-r-10">體驗檢測（企業方案）</a>
                                                                        <small class="float-right text-muted"><time><%= bookableLessons.Count() %>/<%= trialLesson.Count() %></time></small>
                                                                    </div>
                                                                    <p class="msg"><%= enterpriseTrialItem.EnterpriseCourseContract.Subject %></p>
                                                                </div>
                                                            </div>
                                                        </li>
                                                <%  } %>
                                                <%  
                                                        foreach (var item in contractLessons)
                                                        {
                                                            var contract = item.RegisterLessonContract.CourseContract;
                                                            if(contract!=null)
                                                            {
                                                                var remainedCount = contract.RemainedLessonCount();
                                                                if (remainedCount <= 0)
                                                                    continue;

                                                                var validContract = contract.Expiration.Value >= DateTime.Today;
                                                                var bookingCount = contract.CourseContractType.ContractCode == "CFA"
                                                                        ? contract.RegisterLessonContract.Sum(c => c.RegisterLesson.GroupingLesson.LessonTime.Count())
                                                                        : item.GroupingLesson.LessonTime.Count;
                                                                var totalPaid = contract.TotalPaidAmount();
                                                                var payoffStatus = contract.TotalCost / contract.Lessons * (bookingCount + 1) <= totalPaid;
                                                                bool revisionStatus = contract.RevisionList.Any(c => c.CourseContract.Status < (int)Naming.CourseContractStatus.已生效);
                                                                bool groupComplete = item.GroupingMemberCount == item.GroupingLesson.RegisterLesson.Count ? true : false;

                                                                bool bookable = pdqStatus && groupComplete && !questionnaireStatus && validContract && payoffStatus && !revisionStatus;
                                                                if (bookable)
                                                                    hasChoice = true;
                                                    %>
                                                                <li class="list-group-item">
                                                                    <div class="media">
                                                                        <div class="pull-left">
                                                                            <div class="controls">
                                                                                <div class="checkbox">
                                                                                    <input type="checkbox" id="PTSession<%= item.RegisterID %>" <%= bookable ? null : "disabled" %> name="RegisterID" value="<%= item.RegisterID %>" onclick="selectBooking(this, '<%= (int)Naming.LessonPriceStatus.一般課程 %>');" />
                                                                                    <label for="PTSession<%= item.RegisterID %>"></label>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                        <div class="media-body">
                                                                            <div class="media-heading">
                                                                                <a class="m-r-10">P.T session - 
                                                                                    <%= contract.CourseContractType.TypeName %>(<%= contract.LessonPriceType.DurationInMinutes %>分鐘)
                                                                                </a>
                                                                                <span class="badge badge-info"><i class="zmdi zmdi-pin"></i><%= contract.CourseContractExtension.BranchStore.BranchName %></span>
                                                                                <small class="float-right text-muted"><time><%= remainedCount %>/<%= contract.Lessons %></time></small>
                                                                            </div>
                                                                            <%  if (!validContract)
                                                                                {%>
                                                                            <p class="msg col-red"><i class="zmdi zmdi-info-outline"></i>合約尚未生效或已過期</p>
                                                                            <%  }
                                                                                if (!payoffStatus)
                                                                                {   %>
                                                                            <p class="msg col-red"><i class="zmdi zmdi-info-outline"></i>合約繳款餘額不足（未繳清：<%= String.Format("{0:##,###,###,###}",contract.TotalCost-totalPaid) %>元）</p>
                                                                            <%  }
                                                                                if (revisionStatus)
                                                                                {   %>
                                                                            <p class="msg col-red"><i class="zmdi zmdi-info-outline"></i>合約服務申請進行中</p>
                                                                            <%  } %>
                                                                        </div>
                                                                    </div>
                                                                </li>
                                                    <%      }
                                                        }
                                                        foreach (var item in lessons
                                                            .Where(r => r.LessonPriceType.Status == (int)Naming.LessonPriceStatus.點數兌換課程))
                                                        {
                                                            bool bookable = item.LessonTime == null;
                                                            if (bookable)
                                                                hasChoice = true;
                                                        %>
                                                            <li class="list-group-item">
                                                                <div class="media">
                                                                    <div class="pull-left">
                                                                        <div class="controls">
                                                                            <div class="checkbox">
                                                                                <input type="checkbox" id="Other<%= item.RegisterID %>" name="RegisterID" <%= bookable ? null : "disabled" %>  value="<%= bookable ? item.RegisterID : -1 %>" onclick="selectBooking(this, '<%= item.LessonPriceType.IsWelfareGiftLesson!=null ? (int)Naming.LessonPriceStatus.一般課程 : (int)Naming.LessonPriceStatus.點數兌換課程 %>');" />
                                                                                <label for="Other<%= item.RegisterID %>"></label>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    <div class="media-body">
                                                                        <div class="media-heading">
                                                                            <a class="m-r-10">P.T session （點數兌換）</a>
                                                                            <small class="float-right text-muted"><time><%= item.RemainedLessonCount() %>/<%= item.Lessons %></time></small>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </li>
                                                    <%  }
                                                        foreach (var item in lessons.Where(r=>r.LessonPriceType.IsWelfareGiftLesson!=null))
                                                        {
                                                            var remainedCount = item.RemainedLessonCount();
                                                            bool bookable = remainedCount > 0;
                                                            if (bookable)
                                                                hasChoice = true;
                                                        %>
                                                            <li class="list-group-item">
                                                                <div class="media">
                                                                    <div class="pull-left">
                                                                        <div class="controls">
                                                                            <div class="checkbox">
                                                                                <input type="checkbox" id="gift<%= item.RegisterID %>" name="RegisterID" <%= bookable ? null : "disabled" %>  value="<%= bookable ? item.RegisterID : -1 %>" onclick="selectBooking(this, '<%= (int)Naming.LessonPriceStatus.一般課程 %>');" />
                                                                                <label for="gift<%= item.RegisterID %>"></label>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    <div class="media-body">
                                                                        <div class="media-heading">
                                                                            <a class="m-r-10">P.T session （員工福利）</a>
                                                                            <small class="float-right text-muted"><time><%= item.RemainedLessonCount() %>/<%= item.Lessons %></time></small>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </li>
                                                    <%  }
                                                        var courseContent = _enterpriseContract.Join(models.GetTable<EnterpriseCourseContent>(), t => t.ContractID, c => c.ContractID, (t, c) => c);
                                                        foreach (var content in courseContent.Where(r=>r.TypeID == (int)Naming.EnterpriseLessonTypeDefinition.體能顧問1對1課程 || r.TypeID == (int)Naming.EnterpriseLessonTypeDefinition.體能顧問1對2課程))
                                                        {
                                                            var enterprisePT = content.RegisterLessonEnterprise
                                                                    .Select(r => r.RegisterLesson).Where(r => r.UID == _model.UID);
                                                            var bookableLessons = enterprisePT.Where(r => r.LessonTime == null);
                                                            var item = bookableLessons.FirstOrDefault();
                                                            if (item != null)
                                                                hasChoice = true;
                                                            %>
                                                            <li class="list-group-item">
                                                                <div class="media">
                                                                    <div class="pull-left">
                                                                        <div class="controls">
                                                                            <div class="checkbox">
                                                                                <input type="checkbox" <%= item==null ? "disabled" : null %> id="enterprise<%= item?.RegisterID %>" name="RegisterID"  value="<%= item?.RegisterID %>" onclick="selectBooking(this, '<%= (int)Naming.LessonPriceStatus.企業合作方案 %>');" />
                                                                                <label for="enterprise<%= item?.RegisterID %>"></label>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    <div class="media-body">
                                                                        <div class="media-heading">
                                                                            <a class="m-r-10">P.T session（企業方案）- <%= content.EnterpriseLessonType.Description %></a>
                                                                            <small class="float-right text-muted"><time><%= bookableLessons.Count() %>/<%= enterprisePT.Count() %></time></small>
                                                                        </div>
                                                                        <p class="msg"><%= content.EnterpriseCourseContract.Subject %></p>
                                                                    </div>
                                                                </div>
                                                            </li>
                                                    <%  }
                                                        hasChoice = true;   %>
                                                    <li class="list-group-item">
                                                        <div class="media">
                                                            <div class="pull-left">
                                                                <div class="controls">
                                                                    <div class="checkbox">
                                                                        <input type="checkbox" id="PILesson" name="RegisterID" value="" onclick="selectBooking(this, '<%= (int)Naming.LessonPriceStatus.自主訓練 %>');"/>
                                                                        <label for="PILesson"></label>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="media-body">
                                                                <div class="media-heading">
                                                                    <a class="m-r-10">P.I session</a>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </li>
                                                <%  foreach (var content in courseContent.Where(r => r.TypeID == (int)Naming.EnterpriseLessonTypeDefinition.自主訓練))
                                                    {
                                                        var enterprisePI = content.RegisterLessonEnterprise
                                                                .Select(r => r.RegisterLesson).Where(r => r.UID == _model.UID);
                                                        var bookableLessons = enterprisePI.Where(r => r.LessonTime == null);
                                                        var item = bookableLessons.FirstOrDefault();
                                                        if (item != null)
                                                            hasChoice = true;
%>
                                                    <li class="list-group-item">
                                                        <div class="media">
                                                            <div class="pull-left">
                                                                <div class="controls">
                                                                    <div class="checkbox">
                                                                        <input type="checkbox" <%= item==null ? "disabled" : null %> id="enterprisePI<%= item?.RegisterID %>" name="RegisterID"  value="<%= item?.RegisterID %>" onclick="selectBooking(this, '<%= (int)Naming.LessonPriceStatus.企業合作方案 %>');" />
                                                                        <label for="enterprisePI<%= item?.RegisterID %>"></label>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="media-body">
                                                                <div class="media-heading">
                                                                    <a class="m-r-10">P.I session（企業方案）- <%= content.EnterpriseLessonType.Description %></a>
                                                                    <small class="float-right text-muted"><time><%= bookableLessons.Count() %>/<%= enterprisePI.Count() %></time></small>
                                                                </div>
                                                                <p class="msg"><%= content.EnterpriseCourseContract.Subject %></p>
                                                            </div>
                                                        </div>
                                                    </li>
                                                <%  }
                                                    hasChoice = true;   %>
                                                    <li class="list-group-item">
                                                        <div class="media">
                                                            <div class="pull-left">
                                                                <div class="controls">
                                                                    <div class="checkbox">
                                                                        <input type="checkbox" id="STLesson" name="RegisterID" value="" onclick="selectBooking(this, '<%= (int)Naming.LessonPriceStatus.在家訓練 %>');"/>
                                                                        <label for="STLesson"></label>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="media-body">
                                                                <div class="media-heading">
                                                                    <a class="m-r-10">S.T session</a>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <%  if (hasChoice)
                                {   %>
                           <div class="modal-footer">
                              <button type="button" class="btn btn-darkteal btn-round waves-effect" onclick="javascript:if(booking) booking();">確定</button>  
                           </div>
                            <%  } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
    <script>

        var booking;
        function selectBooking(element, lessonType) {
            $('input:checkbox').prop('checked', false);
            $(element).prop('checked', true);
            booking = function () {
                commitBooking(lessonType);
            }
        }

        function commitBooking(lessonType) {

            var $formData = $('#<%= _dialogID %> input,select,textarea').serializeObject();
            $formData.coachID = <%= _profile.UID %>;
            $formData.UID = <%= _model.UID %>;
            $formData.sessionStatus = lessonType;

            clearErrors();
            switch (lessonType) {

                case '<%= (int)Naming.LessonPriceStatus.一般課程 %>':
                case '<%= (int)Naming.LessonPriceStatus.點數兌換課程 %>':
                case '<%= (int)Naming.LessonPriceStatus.企業合作方案 %>':
                default:
                    $.post('<%= Url.Action("CommitBookingByCoach","Lessons") %>', $formData, function (data) {
                        if ($.isPlainObject(data)) {
                            if (data.result) {
                                $global.closeAllModal();
                                refreshEvents();
                                refetchCalendarEvents();
                            }
                            smartAlert(data.message);
                        } else {
                            $(data).appendTo('body').remove();
                        }
                    });
                    break;

                case '<%= (int)Naming.LessonPriceStatus.自主訓練 %>':
                    $formData.trainingBySelf = 1;
                    $.post('<%= Url.Action("CommitBookingByCoach","Lessons") %>', $formData, function (data) {
                        if ($.isPlainObject(data)) {
                            if (data.result) {
                                $global.closeAllModal();
                                refreshEvents();
                                refetchCalendarEvents();
                            }
                            smartAlert(data.message);
                        } else {
                            $(data).appendTo('body').remove();
                        }
                    });
                    break;
                case '<%= (int)Naming.LessonPriceStatus.在家訓練 %>':
                    $formData.trainingBySelf = 2;
                    $.post('<%= Url.Action("CommitBookingByCoach","Lessons") %>', $formData, function (data) {
                        if ($.isPlainObject(data)) {
                            if (data.result) {
                                $global.closeAllModal();
                                refreshEvents();
                                refetchCalendarEvents();
                            }
                            smartAlert(data.message);
                        } else {
                            $(data).appendTo('body').remove();
                        }
                    });
                    break;

                case '<%= (int)Naming.LessonPriceStatus.體驗課程 %>':
                    $.post('<%= Url.Action("CommitTrialLesson","CoachFacet",new { CoachID = _model.UID }) %>', $formData, function (data) {
                        if ($.isPlainObject(data)) {
                            if (data.result) {
                                $global.closeAllModal();
                                refreshEvents();
                                refetchCalendarEvents();
                            }
                            smartAlert(data.message);
                        } else {
                            $(data).appendTo('body').remove();
                        }
                    });
                    break;
            }
        }

        $(function () {
            equipDatetimePicker();
        });
    </script>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    CalendarEventViewModel _viewModel;
    String _dialogID = $"booking{DateTime.Now.Ticks}";
    UserProfile _profile;
    IQueryable<CourseContract> _contracts;
    IQueryable<EnterpriseCourseContract> _enterpriseContract;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _viewModel = (CalendarEventViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser();
        _contracts = models.GetTable<CourseContractMember>()
            .Where(m => m.UID == _model.UID)
                .Join(models.GetTable<CourseContract>(), m => m.ContractID, t => t.ContractID, (m, t) => t);
        _enterpriseContract = models.GetTable<EnterpriseCourseMember>()
            .Where(m => m.UID == _model.UID)
                .Join(models.GetTable<EnterpriseCourseContract>(), m => m.ContractID, t => t.ContractID, (m, t) => t);

    }


</script>
