<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<!-- lockScreen CSS Styles  -->
<link rel="stylesheet" href="<%= VirtualPathUtility.ToAbsolute("~/lockScreen/app.css") %>" type="text/css" />

<script src="<%= VirtualPathUtility.ToAbsolute("~/lockScreen/kinetic-v4.6.js") %>"></script>
<script src="<%= VirtualPathUtility.ToAbsolute("~/lockScreen/html5-android-pattern-lockScreen.js") %>"></script>

<button id="reset-button" class="btn bg-color-red btn-lg btn-block"><i class="fa fa-eraser" aria-hidden="true"></i>重設密碼</button>
<div class="hr1" style="margin: 5px 0px;"></div>
<div id="lock-screen-container">
    <div id="lock-screen"></div>
</div>

