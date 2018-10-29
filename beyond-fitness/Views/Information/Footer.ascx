<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<footer>
    <div class="container">
        <div class="row footer-widgets">

            <!-- Start Subscribe & Social Links Widget -->
            <div class="col-md-4 hidden-xs">
                <div class="footer-widget social-widget">
                    <h4>合作夥伴<span class="head-line"></span></h4>
                    <ul class="social-icons">
                        <li>
                            <a href="https://www.facebook.com/BOOMFitPro" target="_blank" class="facebook"><i>
                                <img src="<%= VirtualPathUtility.ToAbsolute("~/images/partner-BOOM.png") %>" alt="" /></i></a>
                        </li>
                        <li>
                            <a class="twitter" href="https://www.facebook.com/xrevolutionfitness" target="_blank"><i>
                                <img src="<%= VirtualPathUtility.ToAbsolute("~/images/partner-X-Revolution.png") %>" alt="" /></i></a>
                        </li>
                        <li>
                            <a class="google" href="https://www.facebook.com/AkrofitnessTheGym" target="_blank"><i>
                                <img src="<%= VirtualPathUtility.ToAbsolute("~/images/partner-Akrofitness.png") %>" alt="" /></i></a>
                        </li>
                        <li>
                            <a class="dribbble" href="https://www.facebook.com/LIGHTFITNESS" target="_blank"><i>
                                <img src="<%= VirtualPathUtility.ToAbsolute("~/images/partner-lightfitness.png") %>" alt="" /></i></a>
                        </li>
                    </ul>

                </div>
            </div>
            <!-- .col-md-4 -->
            <!-- End Subscribe & Social Links Widget -->

            <!-- Start Flickr Widget -->
            <div class="col-md-4 hidden-xs">
                <div class="footer-widget flickr-widget">
                    <h4>FACE BOOK 粉絲專頁<span class="head-line"></span></h4>
                    <div class="fb-page" data-href="https://www.facebook.com/beyond.fitness.pro/" data-tabs="event" data-small-header="true" data-adapt-container-width="true" data-hide-cover="false" data-show-facepile="true" data-width="260">
                        <div class="fb-xfbml-parse-ignore">
                            <blockquote cite="https://www.facebook.com/beyond.fitness.pro/"><a href="https://www.facebook.com/beyond.fitness.pro/">Beyond Fitness Professional</a></blockquote>
                        </div>
                    </div>
                </div>
            </div>
            <!-- .col-md-4 -->
            <!-- End Flickr Widget -->


            <!-- Start Contact Widget -->
            <div class="col-md-4">
                <div class="footer-widget contact-widget">
                    <h4>
                        <img src="<%= VirtualPathUtility.ToAbsolute("~/images/footer-beyond.png") %>" class="img-responsive" alt="Footer Logo" /></h4>
                    <ul>
                        <li><span><i class="fa fa-phone" aria-hidden="true"></i></span><u><a href="tel:+886227152733">02-2715 2733</a></u></li>
                        <li><span><i class="fa fa-map-marker" aria-hidden="true"></i></span>台北市松山區南京東路四段17號B1</li>
                        <li><span><i class="fa fa-envelope-o" aria-hidden="true"></i></span><u><a href="mailto:info@beyond-fitness.tw">info@beyond-fitness.tw</a></u></li>
                    </ul>
                </div>
            </div>
            <!-- .col-md-3 -->
            <!-- End Contact Widget -->


        </div>
        <!-- .row -->

        <!-- Start Copyright -->
        <div class="copyright-section">
            <div class="row">
                <div class="col-md-12">
                    <p>&copy; 2016 BEYOND FITNESS - All Rights Reserved </p>
                </div>
            </div>
        </div>
        <!-- End Copyright -->

    </div>
</footer>
