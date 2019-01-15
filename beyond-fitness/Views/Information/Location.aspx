<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <!-- RIBBON -->
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-map-marker"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>服務據點</li>
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
        <i class="fa-fw fa fa-map-marker"></i>服務據點
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">
    <div class="row">

        <!-- NEW WIDGET START -->
        <article class="col-xs-12 col-sm-6 col-md-6 col-lg-6">

            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget jarviswidget-color-white" id="wid-id-1" data-widget-editbutton="false" data-widget-deletebutton="false" data-widget-fullscreenbutton="false" data-widget-togglebutton="false" data-widget-custombutton="false" data-widget-colorbutton="false">
                <!-- widget options:
								usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">

								data-widget-colorbutton="false"
								data-widget-editbutton="false"
								data-widget-togglebutton="false"
								data-widget-deletebutton="false"
								data-widget-fullscreenbutton="false"
								data-widget-custombutton="false"
								data-widget-collapsed="true"
								data-widget-sortable="false"

								-->
                <header>
                    <span class="widget-icon"><i class="fa fa-map-marker"></i></span>
                    <h2>小巨蛋</h2>
                </header>

                <!-- widget div-->
                <div>

                    <!-- widget edit box -->
                    <div class="jarviswidget-editbox">
                        <!-- This area used as dropdown edit box -->

                    </div>
                    <!-- end widget edit box -->

                    <!-- widget content -->
                    <div class="widget-body bg-color-darken txt-color-white no-padding">

                        <div id="map_canvas1" class="google_maps"></div>

                    </div>
                    <!-- end widget content -->

                </div>
                <!-- end widget div -->

            </div>
            <!-- end widget -->

        </article>
        <!-- WIDGET END -->

        <!-- NEW WIDGET START -->
        <article class="col-xs-12 col-sm-6 col-md-6 col-lg-6">

            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget jarviswidget-color-white" id="wid-id-1" data-widget-editbutton="false" data-widget-deletebutton="false" data-widget-fullscreenbutton="false" data-widget-togglebutton="false" data-widget-custombutton="false" data-widget-colorbutton="false">
                <!-- widget options:
                                usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">

                                data-widget-colorbutton="false"
                                data-widget-editbutton="false"
                                data-widget-togglebutton="false"
                                data-widget-deletebutton="false"
                                data-widget-fullscreenbutton="false"
                                data-widget-custombutton="false"
                                data-widget-collapsed="true"
                                data-widget-sortable="false"

                                -->
                <header>
                    <span class="widget-icon"><i class="fa fa-map-marker"></i></span>
                    <h2>101</h2>
                </header>

                <!-- widget div-->
                <div>

                    <!-- widget edit box -->
                    <div class="jarviswidget-editbox">
                        <!-- This area used as dropdown edit box -->

                    </div>
                    <!-- end widget edit box -->

                    <!-- widget content -->
                    <div class="widget-body bg-color-darken txt-color-white no-padding">

                        <div id="map_canvas2" class="google_maps"></div>

                    </div>
                    <!-- end widget content -->

                </div>
                <!-- end widget div -->

            </div>
            <!-- end widget -->

        </article>
        <!-- WIDGET END -->

    </div>
    <script type="text/javascript">
		
        $(document).ready(function () {

            pageSetUp();

            var pagefunction = function () {

                // Grey Scale
                var greyscale_style = [{
                    "featureType": "road.highway",
                    "stylers": [{
                        "visibility": "off"
                    }]
                }, {
                    "featureType": "landscape",
                    "stylers": [{
                        "visibility": "off"
                    }]
                }, {
                    "featureType": "transit",
                    "stylers": [{
                        "visibility": "off"
                    }]
                }, {
                    "featureType": "poi",
                    "stylers": [{
                        "visibility": "off"
                    }]
                }, {
                    "featureType": "poi.park",
                    "stylers": [{
                        "visibility": "on"
                    }]
                }, {
                    "featureType": "poi.park",
                    "elementType": "labels",
                    "stylers": [{
                        "visibility": "off"
                    }]
                }, {
                    "featureType": "poi.park",
                    "elementType": "geometry.fill",
                    "stylers": [{
                        "color": "#d3d3d3"
                    }, {
                        "visibility": "on"
                    }]
                }, {
                    "featureType": "poi.medical",
                    "stylers": [{
                        "visibility": "off"
                    }]
                }, {
                    "featureType": "poi.medical",
                    "stylers": [{
                        "visibility": "off"
                    }]
                }, {
                    "featureType": "road",
                    "elementType": "geometry.stroke",
                    "stylers": [{
                        "color": "#cccccc"
                    }]
                }, {
                    "featureType": "water",
                    "elementType": "geometry.fill",
                    "stylers": [{
                        "visibility": "on"
                    }, {
                        "color": "#cecece"
                    }]
                }, {
                    "featureType": "road.local",
                    "elementType": "labels.text.fill",
                    "stylers": [{
                        "visibility": "on"
                    }, {
                        "color": "#808080"
                    }]
                }, {
                    "featureType": "administrative",
                    "elementType": "labels.text.fill",
                    "stylers": [{
                        "visibility": "on"
                    }, {
                        "color": "#808080"
                    }]
                }, {
                    "featureType": "road",
                    "elementType": "geometry.fill",
                    "stylers": [{
                        "visibility": "on"
                    }, {
                        "color": "#fdfdfd"
                    }]
                }, {
                    "featureType": "road",
                    "elementType": "labels.icon",
                    "stylers": [{
                        "visibility": "off"
                    }]
                }, {
                    "featureType": "water",
                    "elementType": "labels",
                    "stylers": [{
                        "visibility": "off"
                    }]
                }, {
                    "featureType": "poi",
                    "elementType": "geometry.fill",
                    "stylers": [{
                        "color": "#d2d2d2"
                    }]
                }];


                /*
                 * Google Maps Initialize
                 */



                $this = $("#map_canvas");
                $zoom_level = ($this.data("gmap-zoom") || 5);
                $data_lat = ($this.data("gmap-lat") || 29.895883);
                $data_lng = ($this.data("gmap-lng") || -80.650635);

                var greyStyleMap = new google.maps.StyledMapType(greyscale_style, {
                    name: "Greyscale"
                });


                // grey
                function generate_map_1() {
                    var coords = new google.maps.LatLng(25.0519269, 121.55007599999999);


                    var mapOptions = {
                        center: coords,
                        zoom: 16,
                        zoomControlOptions: {
                            style: google.maps.ZoomControlStyle.DEFAULT
                        },
                        icon_url: $('#map').data('marker-img'),
                        overviewMapControl: true,
                        mapTypeId: google.maps.MapTypeId.ROADMAP
                    };

                    map = new google.maps.Map(document.getElementById('map_canvas1'), mapOptions);

                    var icon = {
                        url: mapOptions.icon_url,
                        origin: new google.maps.Point(0, 0)
                    };

                    var marker = new google.maps.Marker({
                        position: coords,
                        map: map,
                        icon: icon,
                        draggable: false
                    });

                    // Setup skin for the map
                    map.mapTypes.set('greyscale_style', greyStyleMap);
                    //map.setMapTypeId('greyscale_style');

                }

                function generate_map_2() {
                    var coords = new google.maps.LatLng(25.033026, 121.562909);

                    var mapOptions = {
                        center: coords,
                        zoom: 16,
                        zoomControlOptions: {
                            style: google.maps.ZoomControlStyle.DEFAULT
                        },
                        icon_url: $('#map').data('marker-img'),
                        overviewMapControl: true,
                        mapTypeId: google.maps.MapTypeId.ROADMAP
                    };

                    map = new google.maps.Map(document.getElementById('map_canvas2'), mapOptions);

                    var icon = {
                        url: mapOptions.icon_url,
                        origin: new google.maps.Point(0, 0)
                    };

                    var marker = new google.maps.Marker({
                        position: coords,
                        map: map,
                        icon: icon,
                        draggable: false
                    });

                    // Setup skin for the map
                    map.mapTypes.set('greyscale_style', greyStyleMap);
                    //map.setMapTypeId('greyscale_style');

                }


                generate_map_1();
                generate_map_2();


            };

            $(window).unbind('gMapsLoaded');
            $(window).bind('gMapsLoaded', pagefunction);
            window.loadGoogleMaps();
        });

    </script>

</asp:Content>
