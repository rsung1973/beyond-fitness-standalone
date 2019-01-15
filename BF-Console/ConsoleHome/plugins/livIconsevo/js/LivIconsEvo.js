/********************************************************************************************
 * @name:       LivIconsEvo.js - the main JS file of LivIcons (Live Icons) Evolution
 * @version:    2.4.XXX (XXX is a total number of icons)
 * @URL:        https://livicons.com
 * @copyright:  (c) 2013-2018 DeeThemes (http://codecanyon.net/user/DeeThemes)
 * @licenses:   http://codecanyon.net/licenses/regular
                http://codecanyon.net/licenses/extended
*********************************************************************************************/

;(function(jQuery, undefined) {

    "use strict";

    //for WordPress
    var isWP = false,
        TweenMax = window.TweenMax,
        TimelineMax = window.TimelineMax,
        Power0 = window.Power0,
        Snap = window.Snap,
        verge = window.verge;
    if (window.DeeThemes_GS && window.DeeThemes_Snap && window.DeeThemes_Verge) {
        isWP = true;
    };
    if (isWP) {
        TweenMax =  window.DeeThemes_GS.TweenMax,
        TimelineMax =  window.DeeThemes_GS.TimelineMax,
        Power0 = window.DeeThemes_GS.Power0,
        Snap =  window.DeeThemes_Snap,
        verge =  window.DeeThemes_Verge;
    };

    //Getting LivIcons Evolution default options
    var def_options = LivIconsEvoDefaults();

    //In case of forgetting to add the ending slash
    if ( !def_options.pathToFolder.match(/(\/)$/) && def_options.pathToFolder.trim() !== '' ) {
        def_options.pathToFolder += '/';
    };

    //check for IE9 - IE11 and Edge for line drawing effect. (It doesn't work in those browsers if stroke-width is not integer)
    var isIE = ('ActiveXObject' in window) ? true : false,
        isEdge = (navigator.userAgent.match(/Edge\/\d+/)) ? true : false;

    //the main function to create LivIcon Evolution
    function _createLiviconEvo (holder, options) {
        //to prevent "flickering"
        holder.css('visibility', 'hidden');

        //create Snap object
        var svg = Snap(holder.find('svg')[0]);
        svg.attr({preserveAspectRatio:"xMinYMin meet"});
        var svg_center_origin = svg.attr('viewBox').w / 2 +' '+ svg.attr('viewBox').h / 2;
        svg.selectAll('desc').forEach(function (d) {if (d.innerSVG() == 'Created with Snap') {jQuery(d.node).text('LivIcons Evolution');}});

        //jQuery object
        var $svg = jQuery(svg.node);

        //creating service groups for rotation, flipping and sharp edges
        var init_gr = svg.select('g.lievo-main'),
            gr = svg.g().addClass('lievo-setrotation');
        svg.prepend(gr);
        gr = gr.g().addClass('lievo-setsharp');
        gr = gr.g().addClass('lievo-setflip');
        gr.append(init_gr);


        /***********Visualization**********/

        //leave only one icon's data for morph's state
        if (options.morph) {
            if (options.morphState === 'end') {
                $svg.find('g.lievo-main g.lievo-morphstartstate').remove();
                options.curMorphState = "end";
            } else {
                $svg.find('g.lievo-main g.lievo-morphendstate').remove();
                options.curMorphState = "start";
            };
        } else {
            options.curMorphState = 'not morph';
        };

        //leave only one icon style
        switch (options.style) {
            case 'solid': {
                $svg.find('g.lievo-main g.lievo-solidicon').siblings(':not(g.lievo-common)').remove();
                break;
            }
            case 'lines':
            case 'lines-alt':
            case 'linesAlt': {
                $svg.find('g.lievo-main g.lievo-lineicon').siblings(':not(g.lievo-common)').remove();
                break;
            }
            default: {
                //original or filled icon
                $svg.find('g.lievo-main g.lievo-filledicon').siblings(':not(g.lievo-common)').remove();
            }
        };
        
        //adding invisible rectangle for "tryToSharpen" option
        var helper_rect = init_gr.rect(-19,-19,4,4).addClass('lievo-checkshift lievo-donotdraw lievo-nohoverstroke lievo-nohovercolor').attr({fill: 'none', stroke:'#ffffff', 'stroke-width': 2, 'stroke-linecap': 'butt', 'stroke-linejoin':'round', opacity: 0});
        if (svg.attr('data-shift')) {
            if (svg.attr('data-shift') === 'x') {
                helper_rect.attr('x', -20);
            } else if (svg.attr('data-shift') === 'y') {
                helper_rect.attr('y', -20);
            } else if (svg.attr('data-shift') === 'xy') {
                helper_rect.attr({'x': -20, 'y':-20});
            };
        };
        if (options.style === 'solid' && svg.attr('data-solidshift')) {
            if (svg.attr('data-solidshift') === 'x') {
                helper_rect.attr('x', -19.5);
            } else if (svg.attr('data-solidshift') === 'y') {
                helper_rect.attr('y', -19.5);
            } else if (svg.attr('data-solidshift') === 'xy') {
                helper_rect.attr({'x': -19.5, 'y':-19.5});
            };
        };

        //morph icons can have an image inside
        if (options.morph && options.morphImage) {
            var img_container = svg.select('.lievo-morphimage');
            if (img_container) {
                var pattern = svg.ptrn(0, 0, '100%', '100%', 0, 0, 0, 0);
                pattern.node.removeAttribute('viewBox');
                var pat_g = pattern.attr('patternUnits', 'userSpaceOnUse').addClass('lievo-morphpattern').toDefs().g();
            } else {
                options.morphImage = false;
            };
            var backup_fill = svg.select('.lievo-morphimage').attr('fill');
            pat_g.rect(0,0,60,60).attr({fill: backup_fill, stroke:'#ffffff', 'stroke-width': 0}).addClass('lievo-donotdraw');
        };

        //select all SVG primitives
        var shapes = svg.selectAll('circle, ellipse, image, line, path, polygon, polyline, rect, text, use');
        shapes.forEach(function(shape) {
            if (!jQuery(shape.node).attr('stroke')) {
                shape.attr({stroke: 'none', 'stroke-width': 0});
            };
            if (!jQuery(shape.node).attr('fill')) {
                shape.attr('fill', 'none');
            };
        });

        //change stroke styles for linecap and linejoin
        if (options.strokeStyle === 'round') {
            shapes.forEach(function(shape) {
                if ( shape.attr('stroke') !== 'none' && !shape.hasClass('lievo-savelinecap') ) {
                    shape.node.setAttribute('stroke-linecap', 'round');
                    shape.node.setAttribute('stroke-linejoin', 'round');
                };
            });
        } else if (options.strokeStyle === 'square') {
            shapes.forEach(function(shape) {
                if ( shape.attr('stroke') !== 'none' && !shape.hasClass('lievo-savelinecap') ) {
                    shape.node.setAttribute('stroke-linecap', 'square');
                    shape.node.setAttribute('stroke-linejoin', 'miter');
                    if (!shape.attr('stroke-miterlimit')) {
                        shape.attr('stroke-miterlimit', '10');
                    };
                };
            });
        };

        //storing init data
        shapes.forEach(function(shape) {
            shape.data('initStrokeWidth', shape.attr('stroke-width'));
            shape.data('initStrokeLinecap', shape.attr('stroke-linecap'));
            shape.data('initStrokeLinejoin', shape.attr('stroke-linejoin'));
        });

        //change icon style
        switch (options.style) {
            case 'filled': {
                shapes.forEach(function(shape) {
                    if ( shape.attr('stroke') !== 'none' && !shape.hasClass('lievo-savestroke') ) {
                        shape.attr('stroke', options.strokeColor);
                    };
                    if ( shape.attr('fill') !== 'none' && !shape.hasClass('lievo-savefill') ) {
                        shape.attr('fill', options.fillColor);
                    };
                    if ( shape.hasClass('lievo-likestroke') ) {
                        shape.attr('fill', options.strokeColor);
                    };
                });
                break;
            }
            case 'lines': {
                shapes.forEach(function(shape) {
                    if ( shape.attr('stroke') !== 'none' && !shape.hasClass('lievo-savestroke') ) {
                        shape.attr('stroke', options.strokeColor);
                    };
                    if (!shape.hasClass('lievo-savefill')) {
                        shape.attr('fill', 'none');
                    };
                    if ( shape.hasClass('lievo-likestroke') ) {
                        shape.attr('fill', options.strokeColor);
                    };
                });
                break;
            }
            case 'lines-alt':
            case 'linesAlt': {
                shapes.forEach(function(shape) {
                    if ( shape.hasClass('lievo-altstroke') ) {
                        if ( shape.attr('stroke') !== 'none' ) {
                            shape.attr('stroke', options.strokeColorAlt);
                        };
                        if ( shape.hasClass('lievo-likestroke') ) {
                            shape.attr('fill', options.strokeColorAlt);
                        } else {
                            if (!shape.hasClass('lievo-savefill')) {
                                shape.attr('fill', 'none');
                            };
                        };
                    } else {
                        if ( shape.attr('stroke') !== 'none' && !shape.hasClass('lievo-savestroke') ) {
                            shape.attr('stroke', options.strokeColor);
                        };
                        if ( shape.hasClass('lievo-likestroke') ) {
                            shape.attr('fill', options.strokeColor);
                        } else {
                            if (!shape.hasClass('lievo-savefill')) {
                                shape.attr('fill', 'none');
                            };
                        };
                    };
                });
                break;
            }
            case 'solid': {
                shapes.forEach(function(shape) {
                    if ( shape.hasClass('lievo-solidbg') ) {
                        if ( shape.attr('stroke') !== 'none' && !shape.hasClass('lievo-savestroke') ) {
                            shape.attr('stroke', options.solidColorBg);
                        };
                        if ( shape.attr('fill') !== 'none' && !shape.hasClass('lievo-savefill') ) {
                            shape.attr('fill', options.solidColorBg);
                        };
                    } else {
                        if ( shape.attr('stroke') !== 'none' && !shape.hasClass('lievo-savestroke') ) {
                            shape.attr('stroke', options.solidColor);
                        };
                        if ( shape.attr('fill') !== 'none' && !shape.hasClass('lievo-savefill') ) {
                            shape.attr('fill', options.solidColor);
                        };
                    };
                });
                break;
            }
            default: {
                //do nothing, leave 'original' style
                break;
            }
        };

        //exactly now set the width of holder
        holder.css('width', options.size);

        //for WordPress
        if (isWP && holder.hasClass('livicon-evo-back-in-combined')) {
            holder.parent('.livicon-evo-combined').css('width', options.size);
            holder.css('width', '100%');
        };

        //morph icons can have an image inside
        if (options.morph && options.morphImage) {
            pat_g.image(options.morphImage, 0, 0, '100%', '100%');
            pattern.select('image').attr('preserveAspectRatio', 'xMidYMid slice');
            svg.select('.lievo-morphimage').attr('fill', pattern);
        };

        //change stroke-width
        var half_stroke;
        var strokeWidthCalc = function () {
            options.scaleStrokeFactor = holder.width() / 60;
            if (options.scaleStrokeFactor <= 0) {
                options.scaleStrokeFactor = 1;
            };
            if (options.strokeWidth !== 'original') {
                shapes.forEach(function(shape) {
                    if (shape.attr('stroke') !== 'none') {
                        var units = (''+options.strokeWidth).replace(/[0-9.]/g, ''),
                            cur_stroke_factor = shape.data('initStrokeWidth').replace(/[^0-9.]/g, '') / 2,
                            res_stroke = +(''+options.strokeWidth).replace(/[^0-9.]/g, '') / options.scaleStrokeFactor * cur_stroke_factor;
                        shape.node.setAttribute('stroke-width', res_stroke + units);
                        shape.data('curStrokeWidth', res_stroke + units);
                    };
                });
                half_stroke = (''+options.strokeWidth).replace(/[^0-9.]/g, '') / options.scaleStrokeFactor / 2;
            } else {
                if (options.tryToSharpen && options.scaleStrokeFactor < 0.5) {
                    shapes.forEach(function(shape) {
                        if (shape.attr('stroke') !== 'none') {
                            var units = shape.data('initStrokeWidth').replace(/[0-9.]/g, ''),
                                cur_stroke_factor = shape.data('initStrokeWidth').replace(/[^0-9.]/g, '') / 2,
                                res_stroke = 1 / options.scaleStrokeFactor * cur_stroke_factor;
                            shape.node.setAttribute('stroke-width', res_stroke + units);
                            shape.data('curStrokeWidth', res_stroke + units);
                        };
                    });
                    half_stroke = 1 / options.scaleStrokeFactor / 2;
                } else {
                    shapes.forEach(function(shape) {
                        if (shape.attr('stroke') !== 'none') {
                            shape.data('curStrokeWidth', shape.data('initStrokeWidth'));
                        };
                    });
                    half_stroke = svg.select('.lievo-checkshift').attr('stroke-width').replace(/[^0-9.]/g, '') / 2;
                };
            };

            //calculating stroke-width on hover
            if (options.strokeWidthFactorOnHover === 0 || options.strokeWidthFactorOnHover) {
                shapes.forEach(function(shape) {
                    if ( shape.attr('stroke') !== 'none' && !shape.hasClass('lievo-nohoverstroke') ) {
                        var curSW = shape.data('curStrokeWidth');
                        if (curSW) {
                            var units = (''+curSW).replace(/[0-9.]/g, ''),
                                res_stroke = +(''+curSW.replace(/[^0-9.]/g, '')) * options.strokeWidthFactorOnHover;
                            shape.data('hoverStrokeWidth', res_stroke + units);
                        };
                    };
                });
            };
        };
        strokeWidthCalc();
        if (options.keepStrokeWidthOnResize) {
            jQuery(window).on('resize', function () {
                strokeWidthCalc();
            });
        };

        //choosing color action on hover or when morphed
        if (options.colorsOnHover) {
            var color_action = options.colorsOnHover;
        };
        //if colorsWhenMorph for morph icons, then colorsOnHover is disabled
        if (options.morph && options.colorsWhenMorph) {
            options.colorsOnHover = false;
            var color_action = options.colorsWhenMorph;
        };

        //storing data and calculation colors change
        shapes.forEach(function(shape) {
            var fill = jQuery(shape.node).attr('fill');
            shape.data('curFill', fill);
            shape.data('curStroke', shape.attr('stroke'));
            shape.data('curOpacity', shape.attr('opacity'));

            //calculating colors on hover or colors for change when morph
            if (color_action) {
                if ( fill === 'none' ) {
                    shape.data('actionFill', 'none');
                } else if (fill.toLowerCase().match(/url\(/)) {
                    shape.data('actionFill', fill);
                } else {
                    if (color_action === 'lighter') {
                        if ( options.style === 'solid' && shape.hasClass('lievo-solidbg') ) {
                            var color = options.solidColorBgAction;
                        } else {
                            var color = LighterDarker(fill, -options.saturation, options.brightness);
                        };
                    } else if (color_action === 'darker') {
                        if ( options.style === 'solid' && shape.hasClass('lievo-solidbg') ) {
                            var color = options.solidColorBgAction;
                        } else {
                            var color = LighterDarker(fill, options.saturation, -options.brightness);
                        };
                    } else if (color_action.replace(/[^hue]/g, '') === 'hue') {
                        if ( options.style === 'solid' && shape.hasClass('lievo-solidbg') ) {
                            var color = options.solidColorBgAction;
                        } else {
                            var color = hueRotate(fill, color_action.replace(/[^0-9.]/g, '') ? color_action.replace(/[^0-9.]/g, '') : 0);
                        };
                    } else if (color_action === 'custom') {
                        var color;
                        switch (options.style) {
                            case 'solid': {
                                if ( shape.hasClass('lievo-solidbg') ) {
                                    color = options.solidColorBgAction;
                                } else {
                                    color = options.solidColorAction;
                                };
                                break;
                            }
                            case 'lines': {
                                color = options.strokeColorAction;
                                break;
                            }
                            case 'lines-alt':
                            case 'linesAlt': {
                                if (shape.hasClass('lievo-altstroke')) {
                                    color = options.strokeColorAltAction;
                                } else {
                                    color = options.strokeColorAction;
                                };
                                break;
                            }
                            default: {
                                //original or filled icon
                                if ( shape.hasClass('lievo-likestroke') ) {
                                    color = options.strokeColorAction;
                                } else {
                                    color = options.fillColorAction;
                                };
                                break;
                            }
                        };
                    };
                    shape.data('actionFill', color);
                };

                if ( shape.attr('stroke') === 'none' ) {
                    shape.data('actionStroke', 'none');
                } else {
                    if (color_action === 'lighter') {
                        if ( options.style === 'solid' && shape.hasClass('lievo-solidbg') ) {
                            var color = options.solidColorBgAction;
                        } else {
                            var color = LighterDarker(shape.attr('stroke'), -options.saturation, options.brightness);
                        };
                    } else if (color_action === 'darker') {
                        if ( options.style === 'solid' && shape.hasClass('lievo-solidbg') ) {
                            var color = options.solidColorBgAction;
                        } else {
                            var color = LighterDarker(shape.attr('stroke'), options.saturation, -options.brightness);
                        };
                    } else if (color_action.replace(/[^hue]/g, '') === 'hue') {
                        if ( options.style === 'solid' && shape.hasClass('lievo-solidbg') ) {
                            var color = options.solidColorBgAction;
                        } else {
                            var color = hueRotate(shape.attr('stroke'), color_action.replace(/[^0-9.]/g, '') ? color_action.replace(/[^0-9.]/g, '') : 0);
                        };
                    } else if (color_action === 'custom') {
                        var color;
                        switch (options.style) {
                            case 'solid': {
                                if ( shape.hasClass('lievo-solidbg') ) {
                                    color = options.solidColorBgAction;
                                } else {
                                    color = options.solidColorAction;
                                };
                                break;
                            }
                            case 'lines': {
                                color = options.strokeColorAction;
                                break;
                            }
                            case 'lines-alt':
                            case 'linesAlt': {
                                if ( shape.hasClass('lievo-altstroke') ) {
                                    color = options.strokeColorAltAction;
                                } else {
                                    color = options.strokeColorAction;
                                };
                                break;
                            }
                            default: {
                                //original or filled icon
                                color = options.strokeColorAction;
                                break;
                            }
                        };
                    };
                    shape.data('actionStroke', color);
                };
            };
        });

        //set rotation and/or flip
        if (options.rotate) {
            TweenMax.set(svg.select('g.lievo-setrotation').node, {rotation: options.rotate, svgOrigin: svg_center_origin});
            if (options.morph && options.morphImage && !options.allowMorphImageTransform) {
                var patt_g = pattern.select('g');
                if (!options.flipVertical && options.flipHorizontal) {
                    patt_g.transform('r' + options.rotate + ',30,30');
                } else if (options.flipVertical && !options.flipHorizontal) {
                    patt_g.transform('r' + options.rotate + ',30,30');
                } else {
                    patt_g.transform('r' + (-options.rotate) + ',30,30');
                };
            };
        };
        if (options.flipVertical && !options.flipHorizontal) {
            svg.select('g.lievo-setflip').transform('s1,-1,30,30');
            if (options.morph && options.morphImage && !options.allowMorphImageTransform) {
                pattern.select('image').transform('s1,-1,30,30');
            };
        } else if (options.flipHorizontal && !options.flipVertical) {
            svg.select('g.lievo-setflip').transform('s-1,1,30,30');
            if (options.morph && options.morphImage && !options.allowMorphImageTransform) {
                pattern.select('image').transform('s-1,1,30,30');
            };
        } else if (options.flipVertical && options.flipHorizontal) {
            svg.select('g.lievo-setflip').transform('s-1,-1,30,30');
            if (options.morph && options.morphImage && !options.allowMorphImageTransform) {
                pattern.select('image').transform('s-1,-1,30,30');
            };
        };


        /***********Animations***********/

        if (options.animated) {
            //getting global animation options from SVG icon file
            if (svg.attr('data-animoptions')) {
                var svg_opts = JSON.parse( svg.attr('data-animoptions').replace(/\'/g,'"') );
                if (svg_opts.duration) {
                    options.def_duration = strToNum(svg_opts.duration);
                } else {
                    options.def_duration = 1;
                };
                if (svg_opts.repeat) {
                    if (svg_opts.repeat === 'loop') {
                        options.def_repeat = -1;
                    } else {
                        options.def_repeat = strToNum(svg_opts.repeat);
                    };
                } else {
                    options.def_repeat = 0;
                };
                if (svg_opts.repeatDelay) {
                    options.def_repeatDelay = strToNum(svg_opts.repeatDelay);
                } else {
                    options.def_repeatDelay = 0.5;
                };
            } else {
                options.def_duration = 1;
                options.def_repeat = 0;
                options.def_repeatDelay = 0.5;
            };

            //calculating duration
            if (options.duration === 'default') {
                options.use_duration = options.def_duration;
            } else {
                options.use_duration = strToNum(options.duration);
            };
            if (isNaN(options.use_duration)) {
                options.use_duration = 1;
            };

            //calculating repeat
            if (options.repeat === 'default') {
                options.use_repeat = options.def_repeat;
            } else if (options.repeat === 'loop') {
                options.use_repeat = -1;
            } else {
                options.use_repeat = strToNum(options.repeat);
            };
            if (isNaN(options.use_repeat)) {
                options.use_repeat = 0;
            };
            if (options.use_repeat !== -1 && options.use_repeat < 0) {
                options.use_repeat = 0;
            };

            //calculating a delay before repeats
            if (options.repeatDelay === 'default') {
                options.use_repeatDelay = options.def_repeatDelay;
            } else {
                options.use_repeatDelay = strToNum(options.repeatDelay);
            };
            if (isNaN(options.use_repeatDelay)) {
                options.use_repeatDelay = options.def_repeatDelay;
            };

            //to prevent firing onUpdate callbacks before onStart ones
            if (options.delay <= 0) {options.delay = 0.001};
            if (options.use_repeatDelay <= 0) {options.use_repeatDelay = 0.001};
            if (options.drawDelay <= 0) {options.drawDelay = 0.001};
            if (options.eraseDelay <= 0) {options.eraseDelay = 0.001};

            //morph icons can't be repeated
            if (options.morph) {
                options.def_repeat = 0;
                options.use_repeat = 0;
                options.def_repeatDelay = 0;
                options.use_repeatDelay = 0;
            };
        } else {
            options.def_duration = 0;
            options.def_repeat = 0;
            options.def_repeatDelay = 0;
        };

        //Timeline for icon's drawing
        var drawTL = holder.data('drawTL');
        if (drawTL) {
            drawTL.pause().kill().clear();
        } else {
            var drawTL = new TimelineMax({paused: true});
        };

        //Timeline for icon's animation
        var mainTL = holder.data('mainTL');
        if (mainTL) {
            mainTL.pause().kill().clear();
        } else {
            var mainTL = new TimelineMax({paused: true});
        };

        if (options.animated) {
            //creates animations of each SVG shape
            var animated_shapes = svg.selectAll('circle, ellipse, g, image, line, path, polygon, polyline, rect, text, use');
            var defaultTL = new TimelineMax();

            if (options.morph && options.colorsWhenMorph) {
                var colorTL = new TimelineMax();
                animated_shapes.forEach(function(shape) {
                    if (options.morphState !== 'end') {
                        if ( !shape.hasClass('lievo-nohovercolor') && shape.type.toLowerCase() !== 'g' ) {
                            var stroke = shape.data('actionStroke'),
                                fill = shape.data('actionFill');
                            if ( stroke && stroke !== 'none' ) {
                                var tween_stroke = TweenMax.to(shape.node, options.use_duration, {stroke: stroke});
                                colorTL.add(tween_stroke, 0);
                            };
                            if ( fill && fill !== 'none' && !fill.match(/url\(/) ) {
                                var tween_fill = TweenMax.to(shape.node, options.use_duration, {fill: fill});
                                colorTL.add(tween_fill, 0);
                            };
                        };
                    } else {
                        if ( !shape.hasClass('lievo-nohovercolor') && shape.type.toLowerCase() !== 'g' ) {
                            var stroke = shape.data('actionStroke'),
                                fill = shape.data('actionFill');
                            if ( stroke && stroke !== 'none' ) {
                                TweenMax.set(shape.node, {stroke: stroke});
                            };
                            if ( fill && fill !== 'none' && !fill.match(/url\(/) ) {
                                TweenMax.set(shape.node, {fill: fill});
                            };

                            stroke = shape.data('curStroke');
                            fill = shape.data('curFill');
                            if ( stroke && stroke !== 'none') {
                                var tween_stroke = TweenMax.to(shape.node, options.use_duration, {stroke: stroke});
                                colorTL.add(tween_stroke, 0);
                            };
                            if ( fill && fill !== 'none' && !fill.match(/url\(/) ) {
                                var tween_fill = TweenMax.to(shape.node, options.use_duration, {fill: fill});
                                colorTL.add(tween_fill, 0);
                            };
                        };
                    };
                });
            };

            animated_shapes.forEach(function(shape) {
                if (shape.attr('data-animdata')) {
                    var animdata = JSON.parse(shape.attr('data-animdata').replace(/\'/g,'"')),
                        tl_temp = new TimelineMax();
                    animdata.steps.forEach(function (steps, i) {
                        for(var key in steps.vars) {
                            if ( steps.vars.hasOwnProperty(key) ) {
                                steps.vars[key] = strToNum(steps.vars[key]);
                                if (steps.vars[key] !== 'none') {
                                    steps.vars[key] = strToBool(steps.vars[key]);
                                };
                            };
                        };

                        if (strToNum(steps.duration) === 0) {
                            steps.duration = 0.001;
                        };

                        if (steps.vars.ease === 'none' || !steps.vars.ease) {
                            steps.vars.ease = Power0.easeNone;
                        } else {
                            steps.vars.ease = parseEase(steps.vars.ease);
                        };

                        if (steps.vars.path) {
                            steps.vars.morphSVG = steps.vars.path;
                        };

                        if (steps.vars.bezier && steps.vars.bezier.values) {
                            if( typeof steps.vars.bezier.values === 'string' ) {
                                var str = Snap.path.toCubic(steps.vars.bezier.values).toString();
                                str = str.replace(/[M|m]/g,'').replace(/[C|c]/g,',');
                                var arr = str.split(',');
                                steps.vars.bezier.values = [];
                                for (var i = 0; i < arr.length; i+=2) {
                                    var point = {};
                                    point.x = arr[i];
                                    point.y = arr[i+1];
                                    steps.vars.bezier.values.push(point);
                                };
                            };
                        };

                        if (isIE || isEdge) {//special actions for IE9-IE11 and MS Edge
                            if (steps.vars.drawSVG) {
                                if (steps.vars.drawSVG === '0%' || steps.vars.drawSVG === 0) {
                                    var tween = TweenMax.to(shape.node, +steps.duration, steps.vars);
                                    tween.eventCallback("onStart", function () {
                                        if (shape.data('initStrokeLinecap').toLowerCase() === 'square') {
                                            TweenMax.set(shape.node, {attr:{'stroke-linecap': 'round'}});
                                        };
                                        if (shape.data('initStrokeLinejoin').toLowerCase() === 'miter') {
                                            TweenMax.set(shape.node, {attr:{'stroke-linejoin': 'round'}});
                                        };
                                    });
                                } else if (steps.vars.drawSVG === '100%') {
                                    var tween = TweenMax.to(shape.node, +steps.duration, steps.vars);
                                    tween.eventCallback("onComplete", function () {
                                        if (shape.data('initStrokeLinecap').toLowerCase() === 'square') {
                                            TweenMax.set(shape.node, {attr:{'stroke-linecap': 'square'}});
                                        };
                                        if (shape.data('initStrokeLinejoin').toLowerCase() === 'miter') {
                                            TweenMax.set(shape.node, {attr:{'stroke-linejoin': 'miter'}});
                                        };
                                    });
                                } else {
                                    var tween = TweenMax.to(shape.node, +steps.duration, steps.vars);
                                };
                            } else {
                                var tween = TweenMax.to(shape.node, +steps.duration, steps.vars);
                            };
                        } else {
                            var tween = TweenMax.to(shape.node, +steps.duration, steps.vars);
                        };

                        tl_temp.add(tween, steps.position || '+=0');
                        defaultTL.add(tl_temp, 0);
                    });
                    shape.node.removeAttribute('data-animdata');
                };
            });
            mainTL.add(defaultTL, 0);
            defaultTL.duration(options.use_duration);
            if (options.morph && options.colorsWhenMorph) {
                mainTL.add(colorTL, 0);
                colorTL.duration(options.use_duration);
            };
            mainTL.delay(options.delay).repeat(options.use_repeat).repeatDelay(options.use_repeatDelay);
        } else {
            var shapes = svg.selectAll('circle, ellipse, g, image, line, path, polygon, polyline, rect, text, use');
            shapes.forEach(function(shape) {
                shape.node.removeAttribute('data-animdata');
            });
        };//end if animated

        //storing timelines
        holder.data('drawTL', drawTL);
        holder.data('mainTL', mainTL);

        //events on what element
        if (options.eventOn === 'self' || !options.eventOn) {
            options.event_elem = holder;
        } else if (options.eventOn === 'parent') {
            options.event_elem = holder.parent();
        } else if (options.eventOn === 'grandparent') {
            options.event_elem = holder.parent().parent();
        } else {
            options.event_elem = jQuery(options.eventOn);
        };

        //for WordPress
        if (isWP && holder.hasClass('livicon-evo-back-in-combined')) {
            var target_elem = holder.parent('.livicon-evo-combined');
            if (options.eventOn === 'self' || !options.eventOn) {
                options.event_elem = target_elem;
            } else if (options.eventOn === 'parent') {
                options.event_elem = target_elem.parent();
            } else if (options.eventOn === 'grandparent') {
                options.event_elem = target_elem.parent().parent();
            };
        };
        if (isWP && holder.parent().hasClass('livicon-evo-front-in-combined')) {
            var target_elem = holder.parent('.livicon-evo-front-in-combined');
            if (options.eventOn === 'self' || !options.eventOn) {
                options.event_elem = holder;
            } else if (options.eventOn === 'parent') {
                options.event_elem = target_elem.parent();
            } else if (options.eventOn === 'grandparent') {
                options.event_elem = target_elem.parent().parent();
            };
        };

        if (options.animated) {
            //if icon is not "morph"
            if (!options.morph) {

                //regular icon is clicked
                if (options.eventType === 'click') {
                    var _clickHandler = function() {
                        if (options.use_repeat === -1) {
                            if (!options.ending) {
                                if (options.drawn) {
                                    options.ending = true;
                                    holder.playLiviconEvo();
                                };
                            } else {
                                if (mainTL.isActive()) {
                                    mainTL.tweenTo(mainTL.duration(), {onComplete:
                                        function () {
                                            mainTL.pause().totalProgress(0);
                                            if (typeof options.afterAnim == 'function') {
                                                options.afterAnim();
                                            };
                                            options.ending = false;
                                        }
                                    });
                                };
                            };
                        } else {
                            if (options.drawn) {
                                holder.playLiviconEvo();
                                options.ending = false;
                            };
                        };
                    };
                    options.event_elem.on('click.LiviconEvo', _clickHandler);

                //regular icon is hovered
                } else if (options.eventType === 'hover') {
                    var _hoverInHandler = function() {
                        if (!options.ending) {
                            if (options.drawn) {
                                holder.playLiviconEvo();
                            };
                        };
                    };
                    var _hoverOutHandler = function() {
                        if (mainTL.isActive()) {
                            options.ending = true;
                            mainTL.tweenTo(mainTL.duration(), {onComplete:
                                function () {
                                    mainTL.pause().totalProgress(0);
                                    if (options.use_repeat === -1) {
                                        if (typeof options.afterAnim == 'function') {
                                            options.afterAnim();
                                        };
                                    };
                                    options.ending = false;
                                }
                            });
                        };
                    };

                    //if looped animation
                    if (options.use_repeat === -1) {
                        options.event_elem.on('mouseenter.LiviconEvo', _hoverInHandler).on('mouseleave.LiviconEvo', _hoverOutHandler);

                    //if not looped animation
                    } else {
                        options.event_elem.on('mouseenter.LiviconEvo', function () {
                            if (options.drawn) {
                                holder.playLiviconEvo();
                            };
                        });
                    };
                };

            // animated "morph" icon
            } else if (options.morph) {

                //"morph" icon is clicked
                if (options.eventType === 'click') {
                    var _clickHandler = function() {
                        if ( options.drawn ) {
                            holder.playLiviconEvo();
                        };
                    };
                    options.event_elem.on('click.LiviconEvo', _clickHandler);

                //"morph" icon is hovered
                } else if (options.eventType === 'hover') {
                    var _hoverInHandler = function() {
                        if (options.drawn) {
                            holder.playLiviconEvo();
                        };
                    };
                    var _hoverOutHandler = function() {
                        if (options.drawn) {
                            mainTL.reverse();
                        };
                    };
                    options.event_elem.on('mouseenter.LiviconEvo', _hoverInHandler).on('mouseleave.LiviconEvo', _hoverOutHandler);
                };
            };
        };//end if animated

        //changing colors on hover
        if (options.colorsOnHover) {
            var _hoverColorsIn = function() {
                if ( !drawTL.isActive() && options.drawn) {
                    shapes.forEach(function(shape) {
                        if ( !shape.hasClass('lievo-nohovercolor') ) {
                            var stroke = shape.data('actionStroke'),
                                fill = shape.data('actionFill');
                            if ( stroke && stroke !== 'none' ) {
                                TweenMax.to(shape.node, options.colorsHoverTime, {stroke: stroke});
                            };
                            if ( fill && fill !== 'none' && !fill.match(/url\(/) ) {
                                TweenMax.to(shape.node, options.colorsHoverTime, {fill: fill});
                            };
                        };
                    });
                };
            };
            var _hoverColorsOut = function() {
                if ( !drawTL.isActive() && options.drawn) {
                    shapes.forEach(function(shape) {
                        if ( !shape.hasClass('lievo-nohovercolor') ) {
                            var stroke = shape.data('curStroke'),
                                fill = shape.data('curFill');
                            if ( stroke && stroke !== 'none') {
                                TweenMax.to(shape.node, options.colorsHoverTime, {stroke: stroke});
                            };
                            if ( fill && fill !== 'none' && !fill.match(/url\(/) ) {
                                TweenMax.to(shape.node, options.colorsHoverTime, {fill: fill});
                            };
                        };
                    });
                };
            };
            options.event_elem.on('mouseenter.LiviconEvo', _hoverColorsIn ).on('mouseleave.LiviconEvo', _hoverColorsOut );
        };

        //changing stroke-width on hover
        if (options.strokeWidthFactorOnHover === 0 || options.strokeWidthFactorOnHover) {
            var _hoverStrokeWidthIn = function() {
                if ( !drawTL.isActive() && options.drawn) {
                    shapes.forEach(function(shape) {
                        if ( !shape.hasClass('lievo-nohoverstroke') ) {
                            var stroke = shape.data('hoverStrokeWidth');
                            if (stroke) {
                                TweenMax.to(shape.node, options.strokeWidthOnHoverTime, {attr:{'stroke-width': stroke}});
                            };
                        };
                    });
                };
            };
            var _hoverStrokeWidthOut = function() {
                if ( !drawTL.isActive() && options.drawn) {
                    shapes.forEach(function(shape) {
                        if ( !shape.hasClass('lievo-nohoverstroke') ) {
                            var stroke = shape.data('curStrokeWidth');
                            if (stroke) {
                                TweenMax.to(shape.node, options.strokeWidthOnHoverTime, {attr:{'stroke-width': stroke}});
                            };
                        };
                    });
                };
            };
            options.event_elem.on('mouseenter.LiviconEvo', _hoverStrokeWidthIn ).on('mouseleave.LiviconEvo', _hoverStrokeWidthOut );
        };

        //adding touch events
        if (options.touchEvents) {
            if ( options.animated ||
                options.colorsOnHover ||
                (options.strokeWidthFactorOnHover === 0 || options.strokeWidthFactorOnHover)
                ) {
                options.event_elem.on('touchstart.LiviconEvo', function(e) {
                    e.preventDefault();
                    options.event_elem.trigger('mouseenter.LiviconEvo');
                }).on('touchend.LiviconEvo', function() {
                    options.event_elem.trigger('mouseleave.LiviconEvo');
                    try {
                        options.event_elem[0].click();
                    } catch (err) {
                        if (typeof document.createEvent  == 'function') {
                            var evt = document.createEvent('MouseEvents');
                            evt.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
                            options.event_elem.get(0).dispatchEvent(evt);
                        } else if (typeof window.MouseEvent == 'function') {
                            var evt = new MouseEvent('click', {
                              'bubbles': true,
                              'cancelable': true
                            });
                            options.event_elem.get(0).dispatchEvent(evt);
                        };
                    };
                });
            };
        }; //end if touchEvents

        //making icons sharp
        var pos = holder.find('svg')[0].getScreenCTM();
        if (pos) {
            //fix sub-pixel render bug in Firefox and IE
            var left_shift = (-pos.e % 1),
                top_shift = (-pos.f % 1);
            if (left_shift == 0) {
                left_shift = 0;
            } else if (left_shift <= -0.5) {
                left_shift = left_shift+1;
            };
            if (top_shift == 0) {
                top_shift = 0;
            } else if (top_shift <= -0.5) {
                top_shift = top_shift+1;
            };
            holder.find('svg').css({left: left_shift + 'px', top: top_shift + 'px'});

            //shift for pixel sharp
            if (options.tryToSharpen) {
                var bb = svg.select('.lievo-checkshift'),
                    ptrn = svg.select('.lievo-morphpattern'),
                    mtx = Snap.matrix();

                if (bb) {
                    bb = bb.getBBox();
                    if( (bb.x + half_stroke) * pos.a % 1 !== 0 ) {
                        TweenMax.set(svg.select('g.lievo-setsharp').node, {
                            x: '+=' + ( ( (bb.x - half_stroke) * pos.a % 1 ) / pos.a || 0 ),
                            svgOrigin: svg_center_origin
                        });
                        mtx.e = ( ( (bb.x - half_stroke) * pos.a % 1 ) / pos.a || 0 );
                    };
                    if( (bb.y + half_stroke) * pos.d % 1 !== 0 ) {
                        TweenMax.set(svg.select('g.lievo-setsharp').node, {
                            y: '+=' + ( ( (bb.y - half_stroke) * pos.d % 1 ) / pos.d || 0 ),
                            svgOrigin: svg_center_origin
                        });
                        mtx.f = ( ( (bb.y - half_stroke) * pos.d % 1 ) / pos.d || 0 );
                    };
                    if (ptrn) {
                        ptrn.attr('patternTransform', mtx.toString());
                    };
                };
            };
        };

        //draw lines of an icon
        if (options.drawOnViewport && !options.drawOnce) {
            //calculating viewport's shift
            var shift, svg_h = holder.find('svg').get(0).getBoundingClientRect().height;
            switch (options.viewportShift) {
                case 'none':
                case false: {
                    shift = 1;
                    break;
                }
                case 'one-half':
                case 'oneHalf': {
                    shift = svg_h/2;
                    break;
                }
                case 'one-third':
                case 'oneThird': {
                    shift = svg_h/3;
                    break;
                }
                case 'full': {
                    shift = svg_h;
                    break;
                }
                default: {//one-half
                    shift = svg_h/2;
                    break;
                }
            };
            var checkViewport = function () {
                if (!options.drawOnce) {
                    var win_h = jQuery(window).height();
                    if (shift > win_h) {
                        shift = win_h - 10;
                    };
                    if ( verge.inViewport(holder, -shift) ) {
                        holder.pauseLiviconEvo();
                        holder.drawLiviconEvo();
                        options.drawOnce = true;
                    };
                };
            };
            checkViewport();
            jQuery(window).on('resize scroll', function () {
                checkViewport();
            });
        } else {
            holder.css('visibility', 'visible');
            options.drawOnce = true;
            options.drawn = true;
            if (options.autoPlay) {
                holder.playLiviconEvo();
            };
        };
    };//end _createLiviconEvo()

    //the jQuery plugin
    jQuery.fn.extend({

        //The main method. Have to be called first before any other ones
        addLiviconEvo: function (opt, val) {

            if (arguments.length < 2) {
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                } else {
                    var js_options = {};
                };
            } else {
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                } else {
                    var js_options = {};
                    js_options[opt] = val;
                };
            };

            return this.each(function() {
                var holder = jQuery(this),
                    init_options = holder.data('options'),
                    saved_options = holder.data('saved_options'),
                    options = {};

                //adding class for CSS styling
                holder.addClass('livicon-evo-holder');

                //Unbind previously attached events
                if (saved_options && saved_options.event_elem) {
                    saved_options.event_elem.off('.LiviconEvo');
                    saved_options.event_elem = undefined;
                };

                //create object with options from data-options attribute
                if (!!init_options) {
                    init_options = init_options.split(';');
                    init_options.forEach(function(property) {
                        var tmp = property.trim().split(/:(.+)/);
                        if (!!tmp[0] && !!tmp[1]) {
                            options[tmp[0].trim()] = tmp[1].trim();
                        };
                    });
                };

                //combine all options from defaults, from data-options attribute and any JavaScript passed
                options = jQuery.extend( cloneObj(def_options), options, js_options );

                //check for icon name in init options
                if (!options.name) {
                    holder.addClass('livicon-evo-error').html('<span><acronym title="Please check the &quot;name&quot; option of your SVG LivIconEvo file.">Name Error</acronym></span>');
                    return;
                };
                if ( !options.name.match(/(\.svg)$/) ) {
                    options.name += '.svg';
                };

                //Convert string options to numbers and boolean where necessary
                for (var key in options) {
                    if ( options.hasOwnProperty(key) ) {
                        options[key] = strToNum(options[key]);
                        options[key] = strToBool(options[key]);
                    };
                };

                //add service options (do NOT pass them directly!)
                if ( options.name.match(/morph+(-)/) ) {
                    options.morph = true;
                } else {
                    options.morph = false;
                };
                options.drawOnce = false;
                options.drawn = false;
                options.ending = false;

                //Storing options as object assigned to initial element (div with class .livicon-evo for example)
                holder.removeData('saved_options');
                holder.data('saved_options', options);

                //execute beforeAdd callback function
                if (typeof options.beforeAdd == 'function') {
                    options.beforeAdd();
                };

                //load SVG icon file into a page and create LiviconEvo
                jQuery.ajax({
                    url: options.pathToFolder + options.name,
                    type: 'GET',
                    dataType: 'text',
                    global: true,
                    success: function (code) {
                        holder.removeClass('livicon-evo-error');

                        //make IDs unique
                        var arr = code.match(/(id=[\"'](.*?)[\"'])/gi);
                        if (!!arr) {
                            arr.forEach(function (ndx) {
                                ndx = ndx.replace(/id=[\"']/i, '').replace(/[\"']/, '');
                                var re = new RegExp(ndx, 'g');
                                code = code.replace( re, ndx +'_'+ uniqueNum() );
                            });
                        };

                        //creating Snap.Fragment
                        code = Snap.parse(code);

                        //adding result SVG code into the holder
                        var wrapper = holder.empty().append('<div>').children().addClass('lievo-svg-wrapper');
                        try {
                            wrapper[0].appendChild(code.node);
                        } catch (err) {
                            wrapper.html(code.node);
                        }

                        //creating LiviconEvo
                        _createLiviconEvo (holder, options);

                        //execute afterAdd callback function
                        if (typeof options.afterAdd == 'function') {
                            options.afterAdd();
                        };
                    },
                    error: function(xhr, err){
                        holder.addClass('livicon-evo-error');
                        if (xhr.status === 0 && err === 'error') {
                            holder.html('<span><acronym title="Please use LivIconsEvo script on a working local or internet connected webserver, it does NOT work directly opened from a HDD.">Network Error</acronym></span>');
                            return;
                        } else if (xhr.status === 404 && err === 'error') {
                            holder.html('<span><acronym title="Please check the &quot;name&quot; option and/or default &quot;pathToFolder&quot; one where all SVG LivIconEvo files are placed.">Not Found</acronym></span>');
                            return;
                        } else {
                            holder.html('<span><acronym title="There is an unknown error. Please check for messages in Console (F12 key).">Unknown Error</acronym></span>');
                            return;
                        };
                    }
                });//end AJAX

            });//end return

        },//end addLiviconEvo

        //the method for updating LiviconEvo with new (if any) passed options
        updateLiviconEvo: function (opt, val) {

            if (arguments.length < 2) {
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                } else {
                    var js_options = {};
                };
            } else {
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                } else {
                    var js_options = {};
                    js_options[opt] = val;
                };
            };
            return this.each(function() {
                var holder = jQuery(this),
                    options = holder.data('saved_options');

                //if previously created
                if (options) {

                    //Unbind previously attached events
                    if (options.event_elem) {
                        options.event_elem.off('.LiviconEvo');
                    };
                    options.event_elem = undefined;

                    //Clone options as a new object
                    options = cloneObj(options);
                    //combine options from saved and any new ones JavaScript passed
                    options = jQuery.extend( options, js_options );
                    if ( !options.name.match(/(\.svg)$/) ) {
                        options.name += '.svg';
                    };

                    //Convert string options to numbers and boolean where necessary
                    for (var key in options) {
                        if ( options.hasOwnProperty(key) ) {
                            options[key] = strToNum(options[key]);
                            options[key] = strToBool(options[key]);
                        };
                    };

                    //add inner options (do NOT pass them directly!)
                    if (options.name.match(/morph+(-)/)) {
                        options.morph = true;
                    } else {
                        options.morph = false;
                    };
                    options.drawOnce = false;
                    options.drawn = false;
                    options.ending = false;

                    //Storing options as object assigned to initial element (div for ex.)
                    holder.data('saved_options', options);

                    //execute beforeUpdate callback function
                    if (typeof options.beforeUpdate == 'function') {
                        options.beforeUpdate();
                    };

                    //load SVG icon file into a page and create LiviconEvo
                    jQuery.ajax({
                        url: options.pathToFolder + options.name,
                        type: 'GET',
                        dataType: 'text',
                        global: true,
                        success: function (code) {
                            holder.addClass('livicon-evo-holder').removeClass('livicon-evo-error');

                            //make IDs unique
                            var arr = code.match(/(id=[\"'](.*?)[\"'])/gi);
                            if (!!arr) {
                                arr.forEach(function (ndx) {
                                    ndx = ndx.replace(/id=[\"']/i, '').replace(/[\"']/, '');
                                    var re = new RegExp(ndx, 'g');
                                    code = code.replace( re, ndx +'_'+ uniqueNum() );
                                });
                            };

                            //creating Snap.Fragment
                            code = Snap.parse(code);

                            //adding result SVG code into the holder
                            var wrapper = holder.empty().append('<div>').children().addClass('lievo-svg-wrapper');
                            try {
                                wrapper[0].appendChild(code.node);
                            } catch (err) {
                                wrapper.html(code.node);
                            }

                            //creating LiviconEvo
                            _createLiviconEvo (holder, options);

                            //execute afterUpdate callback function
                            if (typeof options.afterUpdate == 'function') {
                                options.afterUpdate();
                            };
                        },
                        error: function(xhr, err){
                            holder.addClass('livicon-evo-error');
                            if (xhr.status === 0 && err === 'error') {
                                holder.html('<span><acronym title="Please use LivIconsEvo script on a working local or internet connected webserver, it does NOT work directly opened from a HDD.">Network Error</acronym></span>');
                                return;
                            } else if (xhr.status === 404 && err === 'error') {
                                holder.html('<span><acronym title="Please check the &quot;name&quot; option and/or default &quot;pathToFolder&quot; one where all SVG LivIconEvo files are placed.">Not Found</acronym></span>');
                                return;
                            } else {
                                holder.html('<span><acronym title="There is an unknown error. Please check for messages in Console (F12 key).">Unknown Error</acronym></span>');
                                return;
                            };
                        }
                    });//end AJAX

                } else {//first creation
                    holder.addLiviconEvo(js_options);
                };

            });//end return

        },//end updateLiviconEvo

        //the method for changing of LiviconEvo (through erase, update and draw)
        changeLiviconEvo: function (opt, val) {

            if (arguments.length < 2) {
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                } else {
                    var js_options = {};
                };
            } else {
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                } else {
                    var js_options = {};
                    js_options[opt] = val;
                };
            };

            //Convert string options to numbers and boolean where necessary
            for (var key in js_options) {
                if ( js_options.hasOwnProperty(key) ) {
                    js_options[key] = strToNum(js_options[key]);
                    js_options[key] = strToBool(js_options[key]);
                };
            };

            return this.each(function() {
                var holder = jQuery(this),
                    data = holder.data(),
                    options = data.saved_options;

                //if previously created
                if (options) {

                    var drawTL = data.drawTL,
                        mainTL = data.mainTL,
                        shapes = holder.find('circle, ellipse, line, path, polygon, polyline, rect');


                    //Unbind previously attached events
                    if (options.event_elem) {
                        options.event_elem.off('.LiviconEvo');
                    };
                    options.event_elem = undefined;

                    //Clone saved options as a new object
                    options = cloneObj(options);

                    //combine saved options and new ones JavaScript passed
                    options = jQuery.extend( options, js_options );

                    drawTL.pause().totalProgress(0).clear();
                    mainTL.pause().totalProgress(0);
                    options.drawn = true;
                    if (js_options.drawOnViewport == false) {
                        options.drawOnViewport = false;
                    } else {
                        options.drawOnViewport = true;
                    };

                    holder.eraseLiviconEvo(options);
                    var st = setTimeout(function(){
                        holder.updateLiviconEvo(options);
                        clearTimeout(st);
                        }, (options.eraseDelay + options.eraseTime + options.eraseStagger*shapes.length) * 1000
                    );

                } else {//first creation
                    holder.addLiviconEvo(js_options);
                };

            });//end return
        },//end changeLiviconEvo

        //the method for line drawing of LiviconEvo
        drawLiviconEvo: function (opt, val, force) {
            if (arguments.length <= 1) {
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                } else {
                    var js_options = {};
                    js_options.force = opt;
                };
            } else if (arguments.length === 2){
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                    js_options.force = val;
                } else {
                    var js_options = {};
                    js_options[opt] = val;
                    if (!js_options.force) {
                        js_options.force = false;
                    };
                };
            } else {
                var js_options = {};
                js_options[opt] = val;
                js_options.force = force;
            };

            //Convert string options to numbers and boolean where necessary
            for (var key in js_options) {
                if ( js_options.hasOwnProperty(key) ) {
                    js_options[key] = strToNum(js_options[key]);
                    js_options[key] = strToBool(js_options[key]);
                };
            };

            return this.each(function() {
                var holder = jQuery(this),
                    data = holder.data(),
                    options = data.saved_options;

                if (options) {
                    var drawTL = data.drawTL,
                        mainTL = data.mainTL,
                        drawDelay = (js_options.drawDelay === 0 || js_options.drawDelay) ? js_options.drawDelay : options.drawDelay,
                        drawTime = (js_options.drawTime === 0 || js_options.drawTime) ? js_options.drawTime : options.drawTime,
                        drawStagger = (js_options.drawStagger === 0 || js_options.drawStagger) ? js_options.drawStagger : options.drawStagger,
                        drawStartPoint = js_options.drawStartPoint ? js_options.drawStartPoint : options.drawStartPoint,
                        drawColor = js_options.drawColor ? js_options.drawColor : options.drawColor,
                        drawColorTime = (js_options.drawColorTime === 0 || js_options.drawColorTime) ? js_options.drawColorTime : options.drawColorTime,
                        drawEase = js_options.drawEase ? js_options.drawEase : options.drawEase,
                        beforeDraw = js_options.beforeDraw ? js_options.beforeDraw : options.beforeDraw,
                        afterDraw = js_options.afterDraw ? js_options.afterDraw : options.afterDraw,
                        duringDraw = js_options.duringDraw ? js_options.duringDraw : options.duringDraw,
                        drawReversed = (typeof js_options.drawReversed != 'undefined') ? js_options.drawReversed : options.drawReversed,
                        shapes = holder.find('circle, ellipse, line, path, polygon, polyline, rect').not('.lievo-morphpattern').not('.lievo-donotdraw').not('.lievo-nohovercolor').get();

                    //to prevent firing onUpdate callbacks before onStart ones
                    drawTL.eventCallback('onStart', null);
                    drawTL.eventCallback('onComplete', null);
                    drawTL.eventCallback('onUpdate', null);

                    if (drawDelay <= 0) {drawDelay = 0.001};
                    if (drawTime <= 0) {drawTime = 0.001};

                    if ( strToBool(js_options.force) ) {
                        drawTL.clear();
                        drawTL.pause().totalProgress(0);
                        mainTL.pause().totalProgress(0);
                        options.drawn = false;
                    };

                    if (!drawTL.isActive() && !mainTL.isActive() && !options.drawn) {

                        if (drawReversed) {
                            shapes.reverse();
                        };
                        if (options.morph && options.colorsWhenMorph) {
                            var snap_shapes = Snap(holder.find('svg')[0]).selectAll('circle, ellipse, image, line, path, polygon, polyline, rect, text, use');
                            snap_shapes.forEach(function(shape) {
                                shape.data('curFill', jQuery(shape.node).attr('fill'));
                                shape.data('curStroke', shape.attr('stroke'));
                                shape.data('curOpacity', shape.attr('opacity'));
                            });
                            var same_color = Snap(holder.find('svg')[0]).select('.lievo-checkshift');
                            same_color = same_color.data('actionStroke');
                        };


                        var _tweenStart = function() {
                            var snap_target = Snap(this.target);
                            if (isIE || isEdge) {
                                if (snap_target.data('initStrokeLinecap').toLowerCase() === 'square') {
                                    TweenMax.set(this.target, {attr:{'stroke-linecap': 'round'}});
                                };
                                if (snap_target.data('initStrokeLinejoin').toLowerCase() === 'miter') {
                                    TweenMax.set(this.target, {attr:{'stroke-linejoin': 'round'}});
                                };

                            };
                            if (drawColor !== 'same') {
                                TweenMax.set(this.target, {strokeOpacity: 1, stroke: drawColor});
                                if (snap_target.data('curStroke') === 'none') {
                                    snap_target.attr({'stroke-width': 1/options.scaleStrokeFactor});
                                };
                            } else {
                                TweenMax.set(this.target, {strokeOpacity: 1});
                                if (snap_target.data('curStroke') === 'none') {
                                    snap_target.attr({'stroke-width': 1/options.scaleStrokeFactor, stroke: snap_target.data('curFill')});
                                };
                                if (options.style === 'solid' && snap_target.hasClass('lievo-solidbg')) {
                                    if (options.morph && options.colorsWhenMorph && options.morphState === 'end') {
                                        if (same_color) {
                                            snap_target.attr({stroke: same_color});
                                        } else {
                                            snap_target.attr({stroke: options.solidColorAction});
                                        };
                                    } else {
                                        snap_target.attr({stroke: options.solidColor});
                                    };
                                };
                            };
                        };

                        var _tweenComplete = function() {
                            var snap_target = Snap(this.target);
                            if (isIE || isEdge) {
                                if (snap_target.data('initStrokeLinecap').toLowerCase() === 'square') {
                                    TweenMax.set(this.target, {attr:{'stroke-linecap': 'square'}});
                                };
                                if (snap_target.data('initStrokeLinejoin').toLowerCase() === 'miter') {
                                    TweenMax.set(this.target, {attr:{'stroke-linejoin': 'miter'}});
                                };
                            };
                            TweenMax.to(this.target, drawColorTime, {stroke: snap_target.data('curStroke'), fillOpacity: 1});
                        };

                        var _allTweensComplete = function() {
                            options.drawn = true;
                        };

                        //Clear to avoid conflicts with eraseLiviconEvo
                        drawTL.clear();

                        //add beforeDraw callback function
                        if (typeof beforeDraw == 'function') {
                            drawTL.eventCallback('onStart', beforeDraw);
                        };

                        //add duringDraw callback function
                        if (typeof duringDraw == 'function') {
                            drawTL.eventCallback('onUpdate', duringDraw);
                        };

                        //add afterDraw callback function
                        drawTL.eventCallback('onComplete', function () {
                            if (typeof afterDraw == 'function') {
                                afterDraw();
                            };
                            if (options.autoPlay) {
                                holder.playLiviconEvo();
                            };
                        });

                        drawTL.delay(drawDelay);
                        TweenMax.set(shapes, {strokeOpacity: 0, fillOpacity: 0});
                        holder.css('visibility', 'visible');

                        if (typeof drawEase == 'string') {
                            drawEase = parseEase(drawEase);
                        };

                        switch (drawStartPoint) {
                            case 'middle': {
                                //as always due to IE9+ we need a special decisions :)
                                TweenMax.set(shapes, {drawSVG:"0% 100%"});
                                drawTL.staggerFrom(shapes, drawTime, {drawSVG:"50% 50%", ease: drawEase, onStart: _tweenStart, onComplete: _tweenComplete}, drawStagger, 0, _allTweensComplete);
                                break;
                            }
                            case 'end': {
                                drawTL.staggerFromTo(shapes, drawTime, {drawSVG:"100% 100%"}, {drawSVG:"0% 100%", ease: drawEase, onStart: _tweenStart, onComplete: _tweenComplete}, drawStagger, 0, _allTweensComplete);
                                break;
                            }
                            default: {// including 'start' value
                                drawTL.staggerFromTo(shapes, drawTime, {drawSVG:"0% 0%"}, {drawSVG:"0% 100%", ease: drawEase, onStart: _tweenStart, onComplete: _tweenComplete}, drawStagger, 0, _allTweensComplete);
                            }
                        };
                        drawTL.restart(true);
                    };
                } else {
                    js_options.drawOnViewport = true;
                    holder.addLiviconEvo(js_options);
                };
            });//end return
        },//end drawLiviconEvo

        //the method for erasing (disappearing) of LiviconEvo
        eraseLiviconEvo: function (opt, val, force) {
            if (arguments.length <= 1) {
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                } else {
                    var js_options = {};
                    js_options.force = opt;
                };
            } else if (arguments.length === 2){
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                    js_options.force = val;
                } else {
                    var js_options = {};
                    js_options[opt] = val;
                    if (!js_options.force) {
                        js_options.force = false;
                    };
                };
            } else {
                var js_options = {};
                js_options[opt] = val;
                js_options.force = force;
            };

            //Convert string options to numbers and boolean where necessary
            for (var key in js_options) {
                if ( js_options.hasOwnProperty(key) ) {
                    js_options[key] = strToNum(js_options[key]);
                    js_options[key] = strToBool(js_options[key]);
                };
            };

            return this.each(function() {
                var holder = jQuery(this),
                    data = holder.data(),
                    options = data.saved_options;

                if (options) {
                    var drawTL = data.drawTL,
                        mainTL = data.mainTL,
                        eraseDelay = (js_options.eraseDelay === 0 || js_options.eraseDelay) ? js_options.eraseDelay : options.eraseDelay,
                        eraseTime = (js_options.eraseTime === 0 || js_options.eraseTime) ? js_options.eraseTime : options.eraseTime,
                        eraseStagger = (js_options.eraseStagger === 0 || js_options.eraseStagger) ? js_options.eraseStagger : options.eraseStagger,
                        eraseStartPoint = js_options.eraseStartPoint ? js_options.eraseStartPoint : options.eraseStartPoint,
                        eraseEase = js_options.eraseEase ? js_options.eraseEase : options.eraseEase,
                        beforeErase = js_options.beforeErase ? js_options.beforeErase : options.beforeErase,
                        afterErase = js_options.afterErase ? js_options.afterErase : options.afterErase,
                        duringErase = js_options.duringErase ? js_options.duringErase : options.duringErase,
                        eraseReversed = (typeof js_options.eraseReversed != 'undefined') ? js_options.eraseReversed : options.eraseReversed,
                        shapes = holder.find('circle, ellipse, line, path, polygon, polyline, rect').not('.lievo-donotdraw').not('.lievo-nohovercolor').get();

                    //to prevent firing onUpdate callbacks before onStart ones
                    if (eraseDelay <= 0) {eraseDelay = 0.001};
                    drawTL.eventCallback('onStart', null);
                    drawTL.eventCallback('onComplete', null);
                    drawTL.eventCallback('onUpdate', null);

                    if ( strToBool(js_options.force) ) {
                        drawTL.clear();
                        drawTL.pause().totalProgress(0);
                        mainTL.pause().totalProgress(0);
                        options.drawn = true;
                    };

                    if (!drawTL.isActive() && !mainTL.isActive() && options.drawn) {
                        if (eraseReversed) {
                            shapes.reverse();
                        };

                        if (options.morph && options.colorsWhenMorph) {
                            var snap_shapes = Snap(holder.find('svg')[0]).selectAll('circle, ellipse, image, line, path, polygon, polyline, rect, text, use');
                            snap_shapes.forEach(function(shape) {
                                shape.data('curFill', jQuery(shape.node).attr('fill'));
                                shape.data('curStroke', shape.attr('stroke'));
                                shape.data('curOpacity', shape.attr('opacity'));
                            });
                        };

                        var _tweenStart = function() {
                            if (Snap(this.target).data('curStroke') === 'none') {
                                Snap(this.target).attr({'stroke-width': 1/options.scaleStrokeFactor, stroke: Snap(this.target).data('curFill')});
                            };
                            TweenMax.to(this.target, eraseTime, {fillOpacity: 0});
                        };

                        var _tweenComplete = function() {
                            TweenMax.set(this.target, {strokeOpacity: 0, fillOpacity: 0});
                            if (Snap(this.target).data('curStroke') === 'none') {
                                TweenMax.set(this.target, {'stroke-width': 0, stroke:'none'});
                            };
                        };

                        var _allTweensComplete = function() {
                            options.drawn = false;
                        };

                        //Clear to avoid conflicts with drawLiviconEvo
                        drawTL.clear();

                        //add beforeErase callback function
                        if (typeof beforeErase == 'function') {
                            drawTL.eventCallback('onStart', beforeErase);
                        };

                        //add afterErase callback function
                        if (typeof afterErase == 'function') {
                            drawTL.eventCallback('onComplete', afterErase);
                        };

                        //add duringErase callback function
                        if (typeof duringErase == 'function') {
                            drawTL.eventCallback('onUpdate', duringErase);
                        };

                        if (typeof eraseEase == 'string') {
                            eraseEase = parseEase(eraseEase);
                        };

                        drawTL.delay(eraseDelay);
                        TweenMax.set(shapes, {strokeOpacity: 1, fillOpacity: 1});
                        holder.css('visibility', 'visible');

                        switch (eraseStartPoint) {
                            case 'middle': {
                                drawTL.staggerFromTo(shapes, eraseTime, {drawSVG:"0% 100%"}, {drawSVG:"50% 50%", ease: eraseEase, onStart: _tweenStart, onComplete: _tweenComplete}, options.eraseStagger, 0, _allTweensComplete);
                                break;
                            }
                            case 'end': {
                                drawTL.staggerFromTo(shapes, eraseTime, {drawSVG:"0% 100%"}, {drawSVG:"100% 100%", ease: eraseEase, onStart: _tweenStart, onComplete: _tweenComplete}, options.eraseStagger, 0, _allTweensComplete);
                                break;
                            }
                            default: {// including 'start' value
                                drawTL.staggerFromTo(shapes, eraseTime, {drawSVG:"0% 100%"}, {drawSVG:0, ease: eraseEase, onStart: _tweenStart, onComplete: _tweenComplete}, options.eraseStagger, 0, _allTweensComplete);
                            }
                        };
                        drawTL.restart(true);
                    };
                } else {
                    holder.addLiviconEvo(js_options);
                };
            });//end return
        },//end eraseLiviconEvo

        //the method to animate LiviconEvo
        playLiviconEvo: function (opt, val, force) {
            if (arguments.length <= 1) {
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                } else {
                    var js_options = {};
                    js_options.force = opt;
                };
            } else if (arguments.length === 2){
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                    js_options.force = val;
                } else {
                    var js_options = {};
                    js_options[opt] = val;
                    if (!js_options.force) {
                        js_options.force = false;
                    };
                };
            } else {
                var js_options = {};
                js_options[opt] = val;
                js_options.force = force;
            };

            //Convert string options to numbers and boolean where necessary
            for (var key in js_options) {
                if ( js_options.hasOwnProperty(key) ) {
                    js_options[key] = strToNum(js_options[key]);
                    js_options[key] = strToBool(js_options[key]);
                };
            };

            return this.each(function() {
                var holder = jQuery(this),
                    data = holder.data(),
                    options = data.saved_options;

                if (options) {
                    var drawTL = data.drawTL,
                        mainTL = data.mainTL,
                        duration = (js_options.duration === 0 || js_options.duration) ? js_options.duration : options.duration,
                        delay = (js_options.delay === 0 || js_options.delay) ? js_options.delay : options.delay,
                        repeat = (js_options.repeat === 0 || js_options.repeat) ? js_options.repeat : options.repeat,
                        repeatDelay = (js_options.repeatDelay === 0 || js_options.repeatDelay) ? js_options.repeatDelay : options.repeatDelay,
                        beforeAnim = js_options.beforeAnim ? js_options.beforeAnim : options.beforeAnim,
                        afterAnim = js_options.afterAnim ? js_options.afterAnim : options.afterAnim,
                        duringAnim = js_options.duringAnim ? js_options.duringAnim : options.duringAnim;

                    if (options.animated) {

                        if ( strToBool(js_options.force) ) {
                            drawTL.pause().totalProgress(1);
                            mainTL.pause().totalProgress(0);
                            options.drawn = true;
                        };

                        if (duration === 'default') {
                            duration = options.def_duration;
                        };
                        //getting icon's nested time-lines and adjust duration
                        var nestedTLs = mainTL.getChildren(false, false, true);
                        nestedTLs.forEach(function (tl) {
                            tl.duration( duration );
                        })

                        //to prevent firing onUpdate callback before onStart one
                        if (delay <= 0) {delay = 0.001};
                        mainTL.delay( delay );

                        if (repeat === 'default') {
                            repeat = options.def_repeat;
                        } else if (repeat === 'loop') {
                            repeat = -1;
                        };

                        if (repeatDelay === 'default') {
                            repeatDelay = options.def_repeatDelay;
                        };
                        //to prevent firing onUpdate callback before onStart one
                        if (repeatDelay <= 0) {repeatDelay = 0.001};

                        if (!options.morph) {// not morph icon

                            mainTL.repeat( repeat ).repeatDelay( repeatDelay );

                            //add beforeAnim callback function
                            if (typeof beforeAnim == 'function') {
                                mainTL.eventCallback("onStart", beforeAnim);
                            };

                            //add afterAnim callback function (only fired when not looped)
                            if (typeof afterAnim == 'function') {
                                if (repeat !== -1) {
                                    mainTL.eventCallback("onComplete", afterAnim);
                                };
                            };

                            //add duringAnim callback function
                            if (typeof duringAnim == 'function') {
                                mainTL.eventCallback("onUpdate", duringAnim);
                            };

                            if ( !drawTL.isActive() && !mainTL.isActive() && options.drawn) {
                                var prog = mainTL.totalProgress();
                                if (mainTL.paused() && prog > 0 && prog < 1) {
                                    mainTL.resume();
                                } else {
                                    mainTL.restart(true);
                                    options.ending = true;
                                };
                            };

                        } else {//morph icon

                            //morph icons can't be repeated or looped
                            mainTL.repeat(0).repeatDelay(0);

                            //add beforeAnim callback function
                            if (typeof beforeAnim == 'function') {
                                mainTL.eventCallback("onStart", beforeAnim);
                            };

                            //add duringAnim callback function
                            if (typeof duringAnim == 'function') {
                                mainTL.eventCallback("onUpdate", duringAnim);
                            };

                            //add afterAnim callback function
                            mainTL.eventCallback("onComplete", function () {
                                if (options.morphState === 'end') {
                                    options.curMorphState = 'start';
                                } else {
                                    options.curMorphState = 'end';
                                };
                                if (typeof afterAnim == 'function') {
                                    afterAnim();
                                };
                            });
                            mainTL.eventCallback("onReverseComplete", function () {
                                if (options.morphState === 'end') {
                                    options.curMorphState = 'end';
                                } else {
                                    options.curMorphState = 'start';
                                };
                                if (typeof afterAnim == 'function') {
                                    afterAnim();
                                };
                            });

                            if ( !drawTL.isActive() && !mainTL.isActive() && options.drawn) {
                                var prog = mainTL.progress();
                                if (prog === 0) {
                                    mainTL.restart(true);
                                } else if (mainTL.paused() && prog > 0 && prog < 1) {
                                    mainTL.resume();
                                } else {
                                    mainTL.pause().reverse(0);
                                };
                            };
                        };
                    };
                } else {
                    holder.addLiviconEvo(js_options);
                };
            });//end return
        },//end playLiviconEvo

        //the method to stop LiviconEvo
        stopLiviconEvo: function () {
            return this.each(function() {
                var holder = jQuery(this),
                    data = holder.data(),
                    options = data.saved_options;
                if (options) {
                    var mainTL = data.mainTL;
                    if (!options.morph) {
                        mainTL.pause().totalProgress(0);
                        options.ending = false;
                    } else {
                        mainTL.pause().progress(0);
                    };
                } else {
                    holder.addLiviconEvo();
                };
            });
        },//end stopLiviconEvo

        //the method to pause LiviconEvo
        pauseLiviconEvo: function () {
            return this.each(function() {
                var mainTL = jQuery(this).data('mainTL');
                if (!!mainTL) {
                    mainTL.pause();
                };
            });
        },//end pauseLiviconEvo

        //the method to resume LiviconEvo
        resumeLiviconEvo: function () {
            return this.each(function() {
                var mainTL = jQuery(this).data('mainTL');
                if (!!mainTL) {
                    mainTL.resume();
                };
            });
        },//end resumeLiviconEvo

        //the method to remove LiviconEvo
        removeLiviconEvo: function(opt, val, total) {
            if (arguments.length <= 1) {
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                } else {
                    var js_options = {};
                    js_options.total = opt;
                };
            } else if (arguments.length === 2){
                if ( opt === Object(opt) ) {
                    var js_options = opt;
                    js_options.total = val;
                } else {
                    var js_options = {};
                    js_options[opt] = val;
                    if (!js_options.total) {
                        js_options.total = false;
                    };
                };
            } else {
                var js_options = {};
                js_options[opt] = val;
                js_options.total = total;
            };

            return this.each(function() {
                var holder = jQuery(this),
                    options = holder.data('saved_options');

                if (options) {
                    var beforeRemove = js_options.beforeRemove ? js_options.beforeRemove : options.beforeRemove,
                        afterRemove = js_options.afterRemove ? js_options.afterRemove : options.afterRemove;

                    //Unbind previously attached events
                    if (options.event_elem) {
                        options.event_elem.off('.LiviconEvo');
                    };
                    options.event_elem = undefined;

                    //execute beforeRemove callback function
                    if (typeof beforeRemove == 'function') {
                        beforeRemove();
                    };

                    holder.removeData('saved_options drawTL mainTL');

                    if ( strToBool(js_options.total) ) {
                        holder.remove();
                    } else {
                        holder.empty();
                    };

                    //execute afterRemove callback function
                    if (typeof afterRemove == 'function') {
                        afterRemove();
                    };
                };
            });//end return
        },//end removeLiviconEvo

        //the method to get/set current morph icon state
        //returns: 'start' or 'end' for morph icons
        liviconEvoState: function (setter) {
            if (arguments.length === 0) {
                return jQuery(this).data('saved_options').curMorphState;
            } else if (arguments.length >= 1){
                return this.each(function() {
                    var holder = jQuery(this),
                        options = holder.data('saved_options'),
                        mainTL = jQuery(this).data('mainTL');
                    if (setter.toLowerCase() === 'start') {
                        if (!!mainTL && options.morph) {
                            if (options.morphState === 'end') {
                                mainTL.pause().progress(1);
                            } else {
                                mainTL.pause().progress(0);
                            };
                            options.curMorphState = 'start';
                        };
                    } else if (setter.toLowerCase() === 'end') {
                        if (!!mainTL && options.morph) {
                            if (options.morphState === 'end') {
                                mainTL.pause().progress(0);
                            } else {
                                mainTL.pause().progress(1);
                            };
                            options.curMorphState = 'end';
                        };
                    };
                });
            };
        },//end liviconEvoState

        //the method to get all the saved options
        liviconEvoOptions: function () {
            var options = jQuery(this).data('saved_options');
            if (options) {
                var temp = {};
                temp.afterAdd = options.afterAdd;
                temp.afterAnim = options.afterAnim;
                temp.afterDraw = options.afterDraw;
                temp.afterErase = options.afterErase;
                temp.afterRemove = options.afterRemove;
                temp.afterUpdate = options.afterUpdate;
                temp.allowMorphImageTransform = options.allowMorphImageTransform;
                temp.animated = options.animated;
                temp.autoPlay = options.autoPlay;
                temp.beforeAdd = options.beforeAdd;
                temp.beforeAnim = options.beforeAnim;
                temp.beforeDraw = options.beforeDraw;
                temp.beforeErase = options.beforeErase;
                temp.beforeRemove = options.beforeRemove;
                temp.beforeUpdate = options.beforeUpdate;
                temp.brightness = options.brightness;
                temp.colorsHoverTime = options.colorsHoverTime;
                temp.colorsOnHover = (options.colorsOnHover === false ? 'none' : options.colorsOnHover);
                temp.colorsWhenMorph = (options.colorsWhenMorph === false ? 'none' : options.colorsWhenMorph);
                temp.delay = (options.delay === 0.001 ? 0 : options.delay);
                temp.drawColor = options.drawColor;
                temp.drawColorTime = options.drawColorTime;
                temp.drawDelay = (options.drawDelay === 0.001 ? 0 : options.drawDelay);
                temp.drawEase = options.drawEase;
                temp.drawOnViewport = options.drawOnViewport;
                temp.drawReversed = options.drawReversed;
                temp.drawStagger = options.drawStagger;
                temp.drawStartPoint = options.drawStartPoint;
                temp.drawTime = options.drawTime;
                temp.duration = options.duration;
                temp.duringAnim = options.duringAnim;
                temp.duringDraw = options.duringDraw;
                temp.duringErase = options.duringErase;
                temp.eraseDelay = (options.eraseDelay === 0.001 ? 0 : options.eraseDelay);
                temp.eraseEase = options.eraseEase;
                temp.eraseReversed = options.eraseReversed;
                temp.eraseStagger = options.eraseStagger;
                temp.eraseStartPoint = options.eraseStartPoint;
                temp.eraseTime = options.eraseTime;
                temp.eventOn = options.eventOn;
                temp.eventType = (options.eventType === false ? 'none' : options.eventType);
                temp.fillColor = options.fillColor;
                temp.fillColorAction = options.fillColorAction;
                temp.flipHorizontal = options.flipHorizontal;
                temp.flipVertical = options.flipVertical;
                temp.keepStrokeWidthOnResize = options.keepStrokeWidthOnResize;
                temp.morphImage = (options.morphImage === false ? 'none' : options.morphImage);
                temp.morphState = options.morphState;
                temp.name = options.name;
                temp.pathToFolder = options.pathToFolder;
                temp.repeat = options.repeat;
                temp.repeatDelay = options.repeatDelay;
                temp.rotate = (options.rotate === false ? 'none' : options.rotate);
                temp.saturation = options.saturation;
                temp.size = options.size;
                temp.solidColor = options.solidColor;
                temp.solidColorAction = options.solidColorAction;
                temp.solidColorBg = options.solidColorBg;
                temp.solidColorBgAction = options.solidColorBgAction;
                temp.strokeColor = options.strokeColor;
                temp.strokeColorAction = options.strokeColorAction;
                temp.strokeColorAlt = options.strokeColorAlt;
                temp.strokeColorAltAction = options.strokeColorAltAction;
                temp.strokeStyle = options.strokeStyle;
                temp.strokeWidth = options.strokeWidth;
                temp.strokeWidthFactorOnHover = (options.strokeWidthFactorOnHover === false ? 'none' : options.strokeWidthFactorOnHover);
                temp.strokeWidthOnHoverTime = options.strokeWidthOnHoverTime;
                temp.style = options.style;
                temp.touchEvents = options.touchEvents;
                temp.tryToSharpen = options.tryToSharpen;
                temp.viewportShift = (options.viewportShift === false ? 'none' : options.viewportShift);
                temp.def_duration = options.def_duration;
                temp.def_repeat = options.def_repeat;
                temp.def_repeatDelay = options.def_repeatDelay;
                return temp;
            } else {
                return undefined;
            };
        }//end liviconEvoOptions


    });//end jQuery plugin

    //add LivIcons Evolution to elements with default class .livicon-evo
    jQuery(document).ready(function() {
        jQuery('.livicon-evo').addLiviconEvo();
    });

    //bug-fix for some mobile devices
    jQuery(window).on('orientationchange', function(){
        jQuery(window).resize();
    });

    /*******Helper functions******/
    //unique number from 1
    uniqueNum.counter = 1;
    function uniqueNum () {
        return uniqueNum.counter++;
    };

    // function for cloning object
    function cloneObj(obj){
        if(obj == null || typeof(obj) != 'object') {
            return obj;
        };
        var temp = new obj.constructor();
        for(var key in obj) {
            temp[key] = cloneObj(obj[key]);
        };
        return temp;
    };

    // converts string to boolean
    function strToBool(str){
        if (typeof str == 'string' || str instanceof String) {
            var str_lower = str.toLowerCase();
            switch(str_lower){
                case 'true': case 'yes': return true;
                case 'false': case 'no': case 'none': return false;
                default: return str;
            }
        } else {
            return str;
        };
    };

    // converts string to number
    function strToNum(str){
        if (typeof str == 'string' || str instanceof String) {
            if ( (+str) || str == '0' ) {
                return +str;
            } else {
                return str;
            };
        } else {
            return str;
        };
    };

    //parse ease string and return an Object
    function parseEase(string) {
        var easing = string.split(".");
        if (easing.length === 2 && easing[0] !== 'SteppedEase') {
            if (isWP) {
                return window.DeeThemes_GS[easing[0]][easing[1]];
            };
            return window[easing[0]][easing[1]];
        };
        var cfgExp = /true|false|(-?\d*\.?\d*(?:e[\-+]?\d+)?)[0-9]/ig;
        var config = string.match(cfgExp).map(JSON.parse);
        if (easing[0] !== 'SteppedEase') {
            if (isWP) {
                return window.DeeThemes_GS[easing[0]][easing[1]].config.apply(null, config);
            };
            return window[easing[0]][easing[1]].config.apply(null, config);
        } else {
            if (isWP) {
                return window.DeeThemes_GS[easing[0]].config.apply(null, config);
            };
            return window[easing[0]].config.apply(null, config);
        };
    };

    //Calculates lighter or darker color
    function LighterDarker(color,ds,dv) {
        var init = Snap.color(color),
            c = Snap.rgb2hsb(init.r, init.g, init.b);
        c.s = c.s + ds;
        if (c.s < 0) {c.s = 0};
        if (c.s > 1) {c.s = 1};
        c.b = c.b + dv;
        if (c.b < 0) {c.b = 0};
        if (c.b > 1) {c.b = 1};
        return Snap.hsb(c.h, c.s, c.b);
    };

    //Calculates hue rotation
    function hueRotate(color,deg) {
        var init = Snap.color(color),
            c = Snap.rgb2hsb(init.r, init.g, init.b);
        deg = Math.abs(deg) / 360 % 1;
        c.h = (c.h + deg) % 1;
        return Snap.hsb(c.h, c.s, c.b);
    };
})(jQuery);//end of anonymous func