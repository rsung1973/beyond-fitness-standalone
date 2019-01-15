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

<nav>
    <ul>
        <% Html.RenderPartial("~/Views/Layout/NavItem/Lessons.ascx", _userProfile); %>
        <% Html.RenderPartial("~/Views/Layout/NavItem/Members.ascx", _userProfile); %>
        <% Html.RenderPartial("~/Views/Layout/NavItem/Report.ascx", _userProfile); %>
        <% Html.RenderPartial("~/Views/Layout/NavItem/Professional.ascx", _userProfile); %>
        <% Html.RenderPartial("~/Views/Layout/NavItem/SystemInfo.ascx", _userProfile); %>
        <%  if (_userProfile == null)
            { %>
        <li>
            <a href="<%= VirtualPathUtility.ToAbsolute("~/Account/Index") %>" title="關於我們"><i class="fa fa-lg fa-fw fa-graduation-cap"></i><span class="menu-item-parent">關於我們</span></a>
        </li>
        <%  }
            if (!(_userProfile != null && (_userProfile.CurrentUserRole.RoleID == (int)Naming.RoleID.Coach || _userProfile.CurrentUserRole.RoleID==(int)Naming.RoleID.Administrator)))
            { %>
                <li>
                    <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Professional") %>" title="專業體能訓練"><i class="fa fa-lg fa-fw fa-heartbeat"></i><span class="menu-item-parent">專業訓練</span></a>
                </li>
                <li>
                    <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Blog") %>" title="專業知識"><i class="fa fa-lg fa-fw fa-puzzle-piece"></i><span class="menu-item-parent">專業知識</span></a>
                </li>
                <li>
                    <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Rental") %>" title="場地租借"><i class="fa fa-lg fa-fw fa-at"></i><span class="menu-item-parent">場地租借</span></a>
                </li>
                <li>
                    <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Products") %>" title="相關商品"><i class="fa fa-lg fa-fw fa-product-hunt"></i><span class="menu-item-parent">相關商品</span></a>
                </li>
                <li>
                    <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Cooperation") %>" title="相關合作"><i class="fa fa-lg fa-fw fa-link"></i><span class="menu-item-parent">相關合作</span></a>
                </li>
                <li>
                    <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/ContactUs") %>" title="聯絡我們"><i class="fa fa-lg fa-fw fa fa-envelope"></i><span class="menu-item-parent">聯絡我們</span></a>
                </li>
                <li>
                    <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Location") %>" title="服務據點"><i class="fa fa-lg fa-fw fa-map-marker"></i><span class="menu-item-parent">服務據點</span></a>
                </li>
        <%  }
            else
            { %>
                <li>
                    <a href="<%= VirtualPathUtility.ToAbsolute("~/Account/Logout") %>" title="登出"><i class="fa fa-lg fa-fw fa-sign-out"></i><span class="menu-item-parent">登出</span></a>
                </li>
        <%  } %>
        <% Html.RenderPartial("~/Views/Layout/NavItem/TimeLine.ascx", _userProfile); %>
    </ul>
</nav>

<%--<div class="navbar navbar-default navbar-top">
    <div class="container">
        <div class="navbar-header">
            <!-- Stat Toggle Nav Link For Mobiles -->
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                <i class="fa fa-bars"></i>
            </button>
            <!-- End Toggle Nav Link For Mobiles -->
            <a class="navbar-brand hidden-xs" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Index") %>">
                <img src="<%= VirtualPathUtility.ToAbsolute("~/images/Beyond-Fitness.png") %>" alt=""></a>
            <a class="navbar-brand visible-xs-block" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Index") %>">
                <img src="<%= VirtualPathUtility.ToAbsolute("~/images/Beyond-Fitness.png") %>" alt="" width="270" height="41"></a>
        </div>
        <div class="navbar-collapse collapse">
            <!-- Start Navigation List -->
            <ul class="nav navbar-nav navbar-right">
                <li><a id="home" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Index") %>">首頁</a></li>
                <li><a id="professional" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Professional") %>">專業體能訓練</a></li>
                <li><a id="blog" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Blog") %>">專業知識</a></li>
                <li><a id="rental" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Rental") %>">場地租借</a></li>
                <li><a id="products" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Products") %>">相關商品</a></li>
                <li><a id="cooperation" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Cooperation") %>">相關合作</a></li>
                <li><a id="contactUs" href="<%= VirtualPathUtility.ToAbsolute("~/Information/ContactUs") %>">聯絡我們</a></li>
                <%  if (_userProfile == null)
                    { %>
                <li><a id="vip" href="<%= FormsAuthentication.LoginUrl %>">會員專區</a></li>
                <%  }
                    else if (_userProfile.CurrentUserRole.RoleID == (int)Naming.RoleID.Learner)
                    { %>
                        <li><a id="vip" class="learner" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Vip") %>">會員專區</a></li>
                        <li><a id="logout" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Logout") %>">登出</a></li>
                <%  }
                    else
                    { %>
                        <li><a id="vip" href="#">會員專區</a>
                            <ul class="dropdown">
                        <%  if (_userProfile.CurrentUserRole.RoleID == (int)Naming.RoleID.Coach)
                            { %>
                                <li><a id="coach" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Coach") %>">課程管理</a>
                                </li>
                                <li><a id="member" href="<%= VirtualPathUtility.ToAbsolute("~/Member/ListAll") %>">人員管理</a>
                                </li>
                                <li><a id="pub" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Publish") %>">專業知識管理</a>                        
                                </li>
                        <%  }
                            else if (_userProfile.CurrentUserRole.RoleID == (int)Naming.RoleID.FreeAgent)
                            { %>
                                <li><a id="coach" href="<%= VirtualPathUtility.ToAbsolute("~/Account/FreeAgent") %>">課程管理</a>
                                </li>
                        <%  }
                            else if (_userProfile.CurrentUserRole.RoleID == (int)Naming.RoleID.Administrator)
                            {  %>
                                <li><a id="coach" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Coach") %>">課程管理</a>
                                </li>
                                <li><a id="member" href="<%= VirtualPathUtility.ToAbsolute("~/Member/ListAll") %>">人員管理</a>
                                </li>
                                <li><a id="pub" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Publish") %>">專業知識管理</a>
                                </li>
                        <%  } %>
                            </ul>
                        </li>
                        <li><a id="logout" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Logout") %>">登出</a></li>
                <%  } %>
            </ul>
            <!-- End Navigation List -->
        </div>
    </div>

    <!-- Mobile Menu Start -->
    <ul class="wpb-mobile-menu">
        <li><a id="m_home" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Index") %>">首頁</a></li>
        <li><a id="m_professional" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Professional") %>">專業體能訓練</a></li>
        <li><a id="m_blog" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Blog") %>">專業知識</a></li>
        <li><a id="m_rental" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Rental") %>">場地租借</a></li>
        <li><a id="m_products" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Products") %>">相關商品</a></li>
        <li><a id="m_cooperation" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Cooperation") %>">相關合作</a></li>
        <li><a id="m_contactUs" href="<%= VirtualPathUtility.ToAbsolute("~/Information/ContactUs") %>">聯絡我們</a></li>
        <%  if (_userProfile == null)
                    { %>
        <li><a id="m_vip" href="<%= FormsAuthentication.LoginUrl %>">會員專區</a></li>
        <%  }
            else if (_userProfile.CurrentUserRole.RoleID == (int)Naming.RoleID.Learner)
            { %>
                <li><a id="m_vip" class="learner" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Vip") %>">會員專區</a></li>
                <li><a id="m_logout" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Logout") %>">登出</a></li>
        <%  }
            else
            { %>
        <li><a id="m_vip" href="#">會員專區</a>
            <ul class="dropdown">
                <%  if (_userProfile.CurrentUserRole.RoleID == (int)Naming.RoleID.Coach)
                            { %>
                <li><a id="m_coach" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Coach") %>">課程管理</a>
                </li>
                <li><a id="m_member" href="<%= VirtualPathUtility.ToAbsolute("~/Member/ListAll") %>">人員管理</a>
                </li>
                <li><a id="m_pub" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Publish") %>">專業知識管理</a>
                </li>
                <%  }
                    else if (_userProfile.CurrentUserRole.RoleID == (int)Naming.RoleID.FreeAgent)
                    { %>
                <li><a id="m_coach" href="<%= VirtualPathUtility.ToAbsolute("~/Account/FreeAgent") %>">課程管理</a>
                </li>
                <%  }
                    else if (_userProfile.CurrentUserRole.RoleID == (int)Naming.RoleID.Administrator)
                    {  %>
                <li><a id="m_coach" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Coach") %>">課程管理</a>
                </li>
                <li><a id="m_member" href="<%= VirtualPathUtility.ToAbsolute("~/Member/ListAll") %>">人員管理</a>
                </li>
                <li><a id="m_pub" href="<%= VirtualPathUtility.ToAbsolute("~/Information/Publish") %>">專業知識管理</a>
                </li>
                <%  } %>
            </ul>
        </li>
        <li><a id="m_logout" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Logout") %>">登出</a></li>
        <%  } %>
    </ul>
    <!-- Mobile Menu End -->

</div>--%>

<% Html.RenderPartial("~/Views/Shared/Loading.ascx"); %>

<script>
    $('#logout').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#m_logout').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#coach').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#m_coach').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#member').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#m_member').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#pub').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#m_pub').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });

    $('.learner').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });


    <%--
    $(function () {
        window.history.forward();
    });--%>
</script>


<script runat="server">

    ModelStateDictionary _modelState;
    UserProfile _userProfile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _userProfile = Context.GetUser();
    }

</script>
