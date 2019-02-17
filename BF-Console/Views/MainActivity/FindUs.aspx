<%@ Page Title="" Language="C#" AutoEventWireup="true" MasterPageFile="~/Views/MainActivity/Template/MainPage.Master" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="BFConsole.Views.MainActivity.Resources" %>

<asp:Content ID="CustomHeader" ContentPlaceHolderID="CustomHeader" runat="server">

</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section class="section-branch">
        <div class="container">
            <div class="row">
                <div class="col-sm-6">
                    <h1> <%: NamingItem.FindNanjingBranch %>
                        <a href="tel://+886-2-2715-2733" class="tel">(02)2715-2733</a>
                    </h1>
                    <a href="https://maps.google.com/?q=台北市大安區大安路一段75巷21號B1" target="_blank" class="add">
                        <%: NamingItem.FindNanjingBranchAdd %>
                    </a>
                    <p><%: NamingItem.FindNanjingBranchDesc1 %></p>
                    <p><%: NamingItem.FindNanjingBranchDesc2 %></p>
                    <a href="javascript:$('').launchDownload('<%= Url.Action("Team", "MainActivity") %>', {'branchName':'Nanjing'});" class="more"><%: NamingItem.OurTeam %><i class="pl-1 fa fa-angle-right"></i></a>
                </div>
                <div class="col-sm-6 p-t-20">
                    <div id="map-arena" class="map-canvas small"></div>
                </div>
            </div>
        </div>
    </section>
    <section class="section-branch second">
        <div class="container">
            <div class="row">
                <div class="col-sm-6">
                    <h1><%: NamingItem.FindXinyiBranch %>
                        <a href="tel://+886-2-2720-0530" class="tel">(02)2720-0530</a>
                    </h1>
                    <a href="https://maps.google.com/?q=台北市信義區信義路五段16號2樓之2" target="_blank" class="add">
                        <%: NamingItem.FindXinyiBranchAdd %>
                    </a>
                    <p><%: NamingItem.FindXinyiBranchDesc1 %></p>
                    <p><%: NamingItem.FindXinyiBranchDesc2 %></p>
                    <a href="javascript:$('').launchDownload('<%= Url.Action("Team", "MainActivity") %>', {'branchName':'Xinyi'});" class="more"><%: NamingItem.OurTeam %><i class="pl-1 fa fa-angle-right"></i></a>
                </div>
                <div class="col-sm-6 p-t-20">
                    <div id="map-101" class="map-canvas small"></div>
                </div>
            </div>
        </div>
    </section>
    <section class="section-branch second">
        <div class="container">
            <div class="row">
                <div class="col-sm-6">
                    <h1><%: NamingItem.FindZhongxiaoBranch %>
                        <a href="tel://+886-2-2776-9932" class="tel">(02)2776-9932</a>
                    </h1>
                    <a href="https://maps.google.com/?q=台北市大安區大安路一段75巷21號B1" target="_blank" class="add">
                        <%: NamingItem.FindZhongxiaoBranchAdd %>
                    </a>                    
                    <p><%: NamingItem.FindZhongxiaoBranchDesc1 %></p>
                    <p><%: NamingItem.FindZhongxiaoBranchDesc2 %></p>
                    <a href="javascript:$('').launchDownload('<%= Url.Action("Team", "MainActivity") %>', {'branchName':'Zhongxiao'});" class="more"><%: NamingItem.OurTeam %><i class="pl-1 fa fa-angle-right"></i></a>
                </div>
                <div class="col-sm-6 p-t-20">
                    <div id="map-sogo" class="map-canvas small"></div>
                </div>
            </div>
        </div>
    </section>
    <!-- // 聯絡我們 -->
    <%  Html.RenderPartial("~/Views/MainActivity/Module/ContactItem.ascx"); %>
    
</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">
        <!-- Google map-->
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyA3OuzgVBIrXUdm0wsRqiPUxAXg3CAULFI&callback=initMap" async defer></script>
    <script>
        function initMap() {
            var arenaStation = new google.maps.LatLng(25.0519269, 121.55007599999999); //南京
            var oneooneStation = new google.maps.LatLng(25.032599, 121.562962); //信義
            var sogoStation = new google.maps.LatLng(25.042265, 121.547384); //忠孝

            var mapArenaOptions = {
                scaleControl: true,
                center: arenaStation,
                zoom: 17,
                zoomControl: true,
                panControl: false,
                mapTypeControl: false,
                streetViewControl: false,
                scrollwheel: false,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            var map101Options = {
                scaleControl: true,
                center: oneooneStation,
                zoom: 17,
                zoomControl: true,
                panControl: false,
                mapTypeControl: false,
                streetViewControl: false,
                scrollwheel: false,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            var mapSogoOptions = {
                scaleControl: true,
                center: sogoStation,
                zoom: 18,
                zoomControl: true,
                panControl: false,
                mapTypeControl: false,
                streetViewControl: false,
                scrollwheel: false,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            var myIcon = new google.maps.MarkerImage("images/landing/marker.png", null, null, null, new google.maps.Size(50, 50));

            var mapArena = new google.maps.Map(document.getElementById('map-arena'), mapArenaOptions);
            var map101 = new google.maps.Map(document.getElementById('map-101'), map101Options);
            var mapSogo = new google.maps.Map(document.getElementById('map-sogo'), mapSogoOptions);

            var arenaMarker = new google.maps.Marker({
                position: arenaStation,
                map: mapArena,
                icon: myIcon
            });
            var oneooneMarker = new google.maps.Marker({
                position: oneooneStation,
                map: map101,
                icon: myIcon
            });
            var sogoMarker = new google.maps.Marker({
                position: sogoStation,
                map: mapSogo,
                icon: myIcon
            });

            google.maps.event.addListener(arenaMarker, 'click', function() {
                window.open("http://maps.google.com/?q=台北市松山區南京東路四段17號B1");
            });

            google.maps.event.addListener(oneooneMarker, 'click', function() {
                window.open("http://maps.google.com/?q=台北市信義區信義路五段16號2樓之2");
            });

            google.maps.event.addListener(sogoMarker, 'click', function() {
                window.open("http://maps.google.com/?q=台北市大安區大安路一段75巷21號1F");
            });

            var styledMapType = new google.maps.StyledMapType(
                [{
                        elementType: 'geometry',
                        stylers: [{
                            color: '#242f3e'
                        }]
                    },
                    {
                        elementType: 'labels.text.stroke',
                        stylers: [{
                            color: '#242f3e'
                        }]
                    },
                    {
                        elementType: 'labels.text.fill',
                        stylers: [{
                            color: '#746855'
                        }]
                    },
                    {
                        featureType: 'administrative.locality',
                        elementType: 'labels.text.fill',
                        stylers: [{
                            color: '#d59563'
                        }]
                    }, {
                        featureType: "poi.business",
                        elementType: "labels.text",
                        stylers: [{
                            visibility: "off"
                        }]
                    }, {
                        featureType: "poi.business",
                        elementType: "labels.icon",
                        stylers: [{
                            visibility: "off"
                        }]
                    }, {
                        featureType: "poi.place_of_worship",
                        elementType: "labels.text",
                        stylers: [{
                            visibility: "off"
                        }]
                    }, {
                        featureType: "poi.place_of_worship",
                        elementType: "labels.icon",
                        stylers: [{
                            visibility: "off"
                        }]
                    }, {
                        featureType: "poi.government",
                        elementType: "labels.text",
                        stylers: [{
                            color: '#d59563'
                        }]
                    }, {
                        featureType: "poi.government",
                        elementType: "labels.icon",
                        stylers: [{
                            color: '#d59563'
                        }]
                    },
                    {
                        featureType: 'road',
                        elementType: 'geometry',
                        stylers: [{
                            color: '#38414e'
                        }]
                    },
                    {
                        featureType: 'road',
                        elementType: 'geometry.stroke',
                        stylers: [{
                            color: '#212a37'
                        }]
                    },
                    {
                        featureType: 'road',
                        elementType: 'labels.text.fill',
                        stylers: [{
                            color: '#9ca5b3'
                        }]
                    },
                    {
                        featureType: 'road.highway',
                        elementType: 'geometry',
                        stylers: [{
                            color: '#746855'
                        }]
                    },
                    {
                        featureType: 'road.highway',
                        elementType: 'geometry.stroke',
                        stylers: [{
                            color: '#1f2835'
                        }]
                    },
                    {
                        featureType: 'road.highway',
                        elementType: 'labels.text.fill',
                        stylers: [{
                            color: '#f3d19c'
                        }]
                    },
                    {
                        featureType: 'transit',
                        elementType: 'geometry',
                        stylers: [{
                            color: '#2f3948'
                        }]
                    },
                    {
                        featureType: 'transit.station',
                        elementType: 'labels.text.fill',
                        stylers: [{
                            color: '#d59563'
                        }]
                    },
                    {
                        featureType: 'water',
                        elementType: 'geometry',
                        stylers: [{
                            color: '#17263c'
                        }]
                    },
                    {
                        featureType: 'water',
                        elementType: 'labels.text.fill',
                        stylers: [{
                            color: '#515c6d'
                        }]
                    },
                    {
                        featureType: 'water',
                        elementType: 'labels.text.stroke',
                        stylers: [{
                            color: '#17263c'
                        }]
                    }
                ], {
                    name: 'Styled Map'
                });

            mapArena.mapTypes.set('map_styles', styledMapType);
            mapArena.setMapTypeId('map_styles');

            map101.mapTypes.set('map_styles', styledMapType);
            map101.setMapTypeId('map_styles');

            mapSogo.mapTypes.set('map_styles', styledMapType);
            mapSogo.setMapTypeId('map_styles');

        }
    </script>

</asp:Content>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
    }

</script>
