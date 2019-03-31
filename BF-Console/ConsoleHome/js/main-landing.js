$(document).ready(function () {
    "use strict";
    var mainNav = $('#main-nav'),
        slide_out_menu = $('#slide_out_menu'),
        navigation = $('#navigation'),
        $window = $(window);

    // Scroll Events
    $window.on('scroll', function (e) {

        var wScroll = $(this).scrollTop()

        // Activate menu
        if (wScroll > 20) {
            mainNav.addClass('active');
            slide_out_menu.addClass('scrolled');
        } else {
            mainNav.removeClass('active');
            slide_out_menu.removeClass('scrolled');
        };
        //Scroll Effects

    });

    // Navigation
    $('#navigation').on('click', function (e) {
        e.preventDefault();
        $(this).addClass('open');
        slide_out_menu.toggleClass('open');

        if (slide_out_menu.hasClass('open')) {
            $('.menu-close').on('click', function (e) {
                e.preventDefault();
                slide_out_menu.removeClass('open');
            })
        }
    });

    // Price Table
    var individual_price_table = $('#price_tables').find('.individual');
    var company_price_table = $('#price_tables').find('.company');

    $('.switch-toggles').find('.individual').addClass('active');
    $('#price_tables').find('.individual').addClass('active');

    $('.switch-toggles').find('.individual').on('click', function () {
        $(this).addClass('active');
        $(this).closest('.switch-toggles').removeClass('active');
        $(this).siblings().removeClass('active');
        individual_price_table.addClass('active');
        company_price_table.removeClass('active');
    });

    $('.switch-toggles').find('.company').on('click', function () {
        $(this).addClass('active');
        $(this).closest('.switch-toggles').addClass('active');
        $(this).siblings().removeClass('active');
        company_price_table.addClass('active');
        individual_price_table.removeClass('active');
    });

    // Menu For Xs Mobile Screens
    if ($(window).height() < 450) {
        slide_out_menu.addClass('xs-screen');
    }

    $(window).on('resize', function () {
        if ($(window).height() < 450) {
            slide_out_menu.addClass('xs-screen');
        } else {
            slide_out_menu.removeClass('xs-screen');
        }
    });
    // Magnific Popup
    $(".lightbox").magnificPopup();


    // Popup-Gallery
    $('.popup-gallery').find('a.popup2').magnificPopup({
        type: 'image',
        gallery: {
            enabled: true
        }
    });
    $('.popup-youtube, .popup-vimeo, .popup-gmaps').magnificPopup({
		type: 'iframe',
		mainClass: 'mfp-fade',
		removalDelay: 160,
		preloader: false,
		fixedContentPos: false,        
        disableOn: function() {
          if( $(window).width() < 600 ) {
            return 400;
          }
          return 700;
        }
	});

    $("#main-nav .nav-active li a").on('click', function () {
        $(this).parent().addClass('active').siblings().removeClass('active');

    });
    
    /* WOW Scroll Spy ===============*/
    var wow = new WOW({
        //disabled for mobile
        mobile: true
    });    
    wow.init();

    $('.testimonials-slick-slide').slick({
      dots: true,
      infinite: true,
      speed: 300,
      slidesToShow: 1,
      centerMode: true,
      autoplay: true,
      autoplaySpeed: 5000,
      prevArrow: null,
      nextArrow: null,
      fade: true,
      cssEase: 'linear'
    });

});