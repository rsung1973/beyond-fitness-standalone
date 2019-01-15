<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="blog-post quote-post">
    <!-- Post Content -->

    <div class="user-info clearfix">
        <div class="author-image">
            <div class="user-image">
                <% _model.RenderUserPicture(this.Writer, "userImg"); %>
            </div>
            <div class="user-bio">
                <h2 class="text-primary"><%= _model.RealName %> </h2>

                <div class="hr1" style="margin-top:10px; margin-bottom:10px;"></div>
                <div class="row">
                    <div class="col-md-6">
                        <h4><span class="fa fa-user"></span>個人詳細資訊：</h4>
                        <table class="table">
                            <tr>
                                <th class="warning" class="col-xs-1 col-md-1">會員編號</th>
                                <td><%= _model.MemberCode %></td>
                            </tr>
                            <tr>
                                <th class="warning" class="col-xs-1 col-md-1">電話</th>
                                <td><%= _model.Phone %></td>
                            </tr>
                            <tr>
                                <th class="warning" class="col-xs-1 col-md-1">Email</th>
                                <td><%= _model.PID.Contains("@") ? _model.PID : null %></td>
                            </tr>
                            <%  if (_model.Birthday.HasValue)
                                { %>
                            <tr>
                                <th class="warning" class="col-xs-1 col-md-1">年鹷</th>
                                <td><%= (DateTime.Today.Year - _model.Birthday.Value.Year).ToString() %>歲</td>
                            </tr>
                            <%  } %>
                        </table>
                    </div>
                <%  if (ViewBag.ShowPerson == true)
                    {   %>
                        <div class="col-md-6">
                            <h4><span class="fa fa-tags"></span>方案設計工具結果：</h4>
                            <table class="table">
                                <tr class="info">
                                    <th>目標</th>
                                    <th>風格</th>
                                    <th>訓練水準</th>
                                </tr>
                                <tr>
                                    <td><%= _model.PDQUserAssessment!=null && _model.PDQUserAssessment.GoalAboutPDQ!=null ? _model.PDQUserAssessment.GoalAboutPDQ.Goal : null %></td>
                                    <td><%= _model.PDQUserAssessment!=null && _model.PDQUserAssessment.StyleAboutPDQ!=null ? _model.PDQUserAssessment.StyleAboutPDQ.Style : null %></td>
                                    <td><%= _model.PDQUserAssessment!=null && _model.PDQUserAssessment.TrainingLevelAboutPDQ!=null ? _model.PDQUserAssessment.TrainingLevelAboutPDQ.TrainingLevel : null %></td>
                                </tr>
                            </table>
                        </div>

                <%  }
                    else if (ViewBag.EditMySelf == true)
                    { %>
                        <div class="col-md-12">
                            <p>您的修改已經完成。</p>
                            <!-- Divider -->
                            <div class="hr1" style="margin-bottom: 10px;"></div>
                            <p><a href="<%= VirtualPathUtility.ToAbsolute(_model.CurrentUserRole.RoleID == (int)Naming.RoleID.Learner ? "~/Account/Vip" : "~/Account/Coach") %>" class="btn-system btn-small">進入會員專區 <i class="fa fa-chevron-right" aria-hidden="true"></i></a></p>
                        </div>
                <%  }
                    //else if (ViewBag.Argument is ArgumentModel)
                    //{
                    //    Html.RenderPartial(((ArgumentModel)ViewBag.Argument).PartialViewName, ((ArgumentModel)ViewBag.Argument).Model);
                    //} 
                %>
                </div>
                <%  if (ViewBag.Argument is ArgumentModel)
                    { %>
                        <div class="row">
                            <div class="col-md-12">
                                <h4><span class="fa fa-bell-o"></span>目前近況：</h4>
                                <textarea class="form-control" name="recentStatus" rows="3"><%= _model.RecentStatus %></textarea>
                            </div>
                        </div>
                <%  } %>
            </div>
        </div>
    </div>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
    }

</script>
