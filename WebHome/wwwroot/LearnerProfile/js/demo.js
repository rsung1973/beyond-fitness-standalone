$(function() {
    skinChanger();
    CustomScrollbar();
});
"use strict";

//Skin changer
function skinChanger() {
    $('.right-sidebar .choose-skin li').on('click', function() {
        var $body = $('body');
        var $this = $(this);

        var existTheme = $('.right-sidebar .choose-skin li.active').data('theme');
        $('.right-sidebar .choose-skin li').removeClass('active');
        $body.removeClass('theme-' + existTheme);
        $this.addClass('active');

        $body.addClass('theme-' + $this.data('theme'));
    });
}

// All Custom Scrollbar JS
function CustomScrollbar() {
    $('.sidebar .menu .list').slimscroll({
        height: 'calc(100vh - 60px)',
        color: '#546e7a',
        position: 'left',
        size: '2px',
        alwaysVisible: false,
        borderRadius: '3px',
        railBorderRadius: '0'
    });

    $('.navbar-right .dropdown-menu .body .menu').slimscroll({
        height: '254px',
        color: 'rgba(0,0,0,0.2)',
        size: '3px',
        alwaysVisible: false,
        borderRadius: '3px',
        railBorderRadius: '0'
    });
    $('.chat-widget').slimscroll({
        height: '300px',
        color: 'rgba(0,0,0,0.4)',
        size: '2px',
        alwaysVisible: false,
        borderRadius: '3px',
        railBorderRadius: '2px'
    });

    $('.right-sidebar .slim_scroll').slimscroll({
        height: 'calc(100vh - 70px)',
        color: 'rgba(0,0,0,0.4)',
        size: '2px',
        alwaysVisible: false,
        borderRadius: '3px',
        railBorderRadius: '0'
    });

   
}

// Theme Light and Dark  =======
$('.theme-light-dark .t-light').on('click', function() {
    $('body').removeClass('menu_dark');
});

$('.theme-light-dark .t-dark').on('click', function() {
    $('body').addClass('menu_dark');
});

//==========
$(".ls-toggle-btn").on('click',function() {
    $("body").toggleClass("ls-toggle-menu");
});

//Chat widget js =======
$(function() {
    $('.chat-launcher').on('click', function() {
        $('.chat-launcher').toggleClass('active');
        $('.chat-wrapper').toggleClass('is-open');
    });
});
//=========
$('.form-control').on("focus", function() {
    $(this).parent('.input-group').addClass("input-group-focus");
}).on("blur", function() {
    $(this).parent(".input-group").removeClass("input-group-focus");
});

