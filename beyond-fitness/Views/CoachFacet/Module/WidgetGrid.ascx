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

<section id="widget-grid" class="">
    <!-- row -->
    <div class="row">	
        <article class="col-xs-12 col-sm-12 col-md-5 col-lg-5 padding-5">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false" data-widget-fullscreenbutton="false">
                <header>
                    <span class="widget-icon"><i class="fa fa-address-book"></i></span>
                    <h2><%= _coach!=null ? _coach.UserProfile.FullName() : _model.FullName() %></h2>
                    <div class="widget-toolbar">
                    </div>
                </header>
                <!-- widget div-->
                <div>
                    <!-- widget content -->
                    <div class="widget-body txt-color-white no-padding">
                        <div class="row" id="coachToday">
                        <%  if (_coach != null)
                            { %>
                            <%  Html.RenderPartial("~/Views/CoachFacet/Module/CoachToday.ascx", _coach); %>
                        <%  }
                            else if(_model.ServingCoach!=null)
                            {
                                Html.RenderPartial("~/Views/CoachFacet/Module/CoachToday.ascx", _model.ServingCoach);
                            }
                            else
                            {
                                Html.RenderPartial("~/Views/Member/Module/MemberToday.ascx", _model.ServingCoach); 
                            }   %>
                        </div>						
                        <div class="row">
                            <div class="col-sm-12">
                                <div class="padding-10">
                                    <ul class="nav nav-tabs">
                                        <li>
                                            <a href="#todolist_tab" data-toggle="tab"><i class="fa fa-check"></i> 待辦事項</a>
                                        </li>
                                        <!--<li>
                                            <a href="#mystudentlist_tab" data-toggle="tab">學員清單</a>
                                        </li>-->
                                        <li>
                                            <a href="#contractlist_tab" data-toggle="tab"><i class="fa fa-exclamation-triangle"></i> 合約到期(前)清單</a>
                                        </li>
                                        <li class="">
                                            <a href="#birthdaylist_tab" data-toggle="tab"><i class="fa fa-birthday-cake"></i> 生日提醒</a>
                                        </li>
                                        <li class="active">
                                            <a href="#smCalendar" data-toggle="tab" class="hidden-md hidden-lg"><i class="fa fa-calendar-alt"></i> 行事曆</a>
                                        </li>
                                    </ul>
                                    <div class="tab-content padding-top-10">
                                        <div class="tab-pane fade" id="todolist_tab">
                                            <!-- Widget ID (each widget will need unique ID)-->
                                            <%  Html.RenderAction("LessonsSummary", "CoachFacet", new { CoachID = _coach!=null ? (int?)_coach.CoachID : null }); %>
                                            <!-- end widget -->
                                        </div>
                                        <%--<div class="tab-pane fade" id="mystudentlist_tab">
                                            <!-- Widget ID (each widget will need unique ID)-->
                                            <%  if(_coach!=null)
                                                { %>
                                            <%  Html.RenderPartial("~/Views/CoachFacet/Module/LearnerListByCoach.ascx",_coach); %>
                                            <%  } %>
                                            <!-- end widget -->
                                        </div>--%>
                                        <div class="tab-pane fade" id="contractlist_tab">
                                            <!-- Widget ID (each widget will need unique ID)-->
                                            <%  Html.RenderPartial("~/Views/CoachFacet/Module/ExpiringContractList.ascx", _model); %>
                                            <!-- end widget -->
                                        </div>
                                        <div class="tab-pane fade" id="birthdaylist_tab">
                                            <!-- Widget ID (each widget will need unique ID)-->
                                            <%  Html.RenderPartial("~/Views/CoachFacet/Module/LearnerBirthdayNotification.ascx"); %>
                                            <!-- end widget -->
                                        </div>
                                        <div class="tab-pane fade in active hidden-md hidden-lg" id="smCalendar">
                                            <!-- new widget -->
                                            <!-- end widget -->
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- end row -->					
                    </div>
                    <!-- end widget content -->
                </div>
                <!-- end widget div -->
            </div>
            <!-- end widget -->
        </article>	
         <!-- NEW WIDGET START -->
        <article id="lgCalendar" class="col-md-7 col-lg-7 hidden-xs hidden-sm no-padding">
            <!-- new widget -->
            <%  Html.RenderPartial("~/Views/CoachFacet/Module/MyCalendar.ascx",_model); %>
            <!-- end widget -->
        </article>
        <!-- WIDGET END -->	       
    </div>
    <!-- end row -->
</section>
<script>
    $(function () {
        console.log($('#lgCalendar').css('display'));
        console.log($('#smCalendar').css('display'));
        if ($('.hidden-sm').css('display') == 'none') {
            $('#calendarView').appendTo($('#smCalendar'));
        } else {
            var $li = $('li.active');
            $li.removeClass('active');
            $($li.find('a').attr('href')).removeClass('active in');
            $('a[href="#<%= ViewBag.ShowTodoTab==true ? "todolist_tab" : "birthdaylist_tab" %>"]').closest('li').addClass('active');
            $('#<%= ViewBag.ShowTodoTab==true ? "todolist_tab" : "birthdaylist_tab" %>').addClass('active in');
        }

        $(window).resize(function () {
            if ($('#lgCalendar').css('display') == 'block') {
                $('#calendarView').appendTo($('#lgCalendar'));
            } else if ($('#smCalendar').css('display') == 'block') {
                $('#calendarView').appendTo($('#smCalendar'));
            }
        });
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    ServingCoach _coach;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _coach = (ServingCoach)ViewBag.CurrentCoach;
    }

</script>
