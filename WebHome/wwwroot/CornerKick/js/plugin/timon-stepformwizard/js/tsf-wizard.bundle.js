var returnVal;
/*!
 * Bal - Email NewsLetter Builder Plugin
 * Author: Rufat Askerov
 * Author Uri : https://cidcode.net
 */

;
(function(factory) {
    "use strict";

    if (typeof define === 'function' && define.amd) { // AMD
        define(['jquery'], factory);
    } else if (typeof exports == "object" && typeof module == "object") { // CommonJS
        module.exports = factory(require('jquery'));
    } else { // Browser
        factory(jQuery);
    }
})(function($, undefined) {
    "use strict";

    // -------------------------- variables -------------------------- //
    var tsfStepEffect = {
            'bounce': {
                className: 'bounce-effect'
            },
            'slideRightLeft': {
                className: 'slide-right-left-effect'
            },
            'slideLeftRight': {
                className: 'slide-left-right-effect'
            },
            'basic': {
                className: 'default-effect'
            },
            'flip': {
                className: 'flip-effect'
            },
            'transformation': {
                className: 'transformation-effect'
            },
            'slideDownUp': {
                className: 'slide-down-up-effect'
            },
            'slideUpDown': {
                className: 'slide-up-down-effect'
            }
        },
        tsfStepStyle = {
            'style1': {
                className: 'gsi-step-indicator triangle gsi-style-1'
            },
            'style2': {
                className: 'gsi-step-indicator triangle gsi-style-2'
            },
            'style3': {
                className: 'gsi-step-indicator triangle gsi-style-3'
            },
            'style4': {
                className: 'gsi-style-4'
            },
            'style5': {
                className: 'gsi-style-5'
            },
            'style5_circle': {
                className: ' gsi-style-5 gsi-number-circle'
            },
            'style6': {
                className: 'gsi-style-6'
            },
            'style7_borderTop': {
                className: 'gsi-style-7 border-top'
            },
            'style7_borderBottom': {
                className: 'gsi-style-7 border-bottom'
            },
            'style7_borderLeft': {
                className: 'gsi-style-7 border-left'
            },
            'style7_borderRight': {
                className: 'gsi-style-7 border-right'
            },

            'style7_borderTop_circle': {
                className: 'gsi-style-7 border-top gsi-number-circle'
            },
            'style7_borderBottom_circle': {
                className: 'gsi-style-7 border-bottom gsi-number-circle'
            },
            'style7_borderLeft_circle': {
                className: 'gsi-style-7 border-left gsi-number-circle'
            },
            'style7_borderRight_circle': {
                className: 'gsi-style-7 border-right gsi-number-circle'
            },

            'style8': {
                className: 'gsi-style-8'
            },
            'style8_circle': {
                className: 'gsi-style-8 gsi-number-circle'
            },

            'style9': {
                className: 'gsi-style-9'
            },
            'style10': {
                className: 'gsi-style-10'
            },
            'style11': {
                className: 'gsi-style-11'
            },
            'style12': {
                className: 'gsi-style-12'
            }
        },
        tsfNavPosition = {
            'bottom': {
                position: 'bottom',
                stepClass: '',
                containerClass: 'tsf-bottom-container',
                navStepClass: 'tsf-bottom-nav-step'
            },
            'top': {
                position: 'top',
                stepClass: '',
                containerClass: '',
                navStepClass: ''
            },
            'right': {
                position: 'right',
                stepClass: 'gsi-arrow-left gsi-vertical',
                containerClass: 'tsf-left-container',
                navStepClass: 'tsf-right-nav-step'
            },
            'left': {
                position: 'left',
                stepClass: 'gsi-vertical',
                containerClass: 'tsf-right-container',
                navStepClass: 'tsf-left-nav-step'
            }
        },
        tsfDisable = {
            'all': {
                className: 'gsi-step-no-available-all'
            },
            'after_current': {
                className: 'gsi-step-no-available-after-current'
            },
            'before_current': {
                className: 'gsi-step-no-available-before-current'
            },
            'none': {
                className: '.gsi-step-no-available-all,.gsi-step-no-available-after-current,.gsi-step-no-available-before-current'
            }
        };

    /**
     * Using all variables in plugin
     */

    var _this, _navPos, _stepEff, _left,_notShown, _notShownField, _windowWidth, _stepStyle, _width, _height, _currIndex, _from, _to, _element, _disableSteps, _stepDisable, activeIndex, _content, _parent, _oldIndex, _return, _newIndex, _id, _step_effect, _count, _finish, _first, _btnPrev, _btnNext, _btnFinish, _index, _dataType;
    var _fistVal = false,
        _isValid = true;

    var tsfWizard = function(elem, options) {
        //Private variables
        this.elem = elem;
        this.$elem = jQuery(elem);
        this.options = options;
        this.langArr;
    };
    tsfWizard.prototype = {
        defaults: {
            //global _this.config
            loading_color1: '#3B7694',
            loading_color2: '#09181F',
            showLoading: true,

            stepStyle: 'style1', // grumpy step indicator all styles
            stepEffect: 'basic',
            showStepNum: true,
            stepTransition: true, //true or false
            validation: false, //true or false
            navPosition: 'top', //'bottom' or top,right,left
            height: 'auto', //'auto' or any height (600px,400px etc)
            showButtons: true,
            manySteps: false,
            prevBtn: '<i class="fa fa-chevron-left"></i> PREV',
            nextBtn: 'NEXT <i class="fa fa-chevron-right"></i>',
            finishBtn: 'FINISH',
            disableSteps: 'none', //all | after_current | before_current | none
            onBeforeNextButtonClick: function(e) {},
            onAfterNextButtonClick: function(e) {},
            onBeforePrevButtonClick: function(e) {},
            onAfterPrevButtonClick: function(e) {},
            onBeforeFinishButtonClick: function(e) {},
            onAfterFinishButtonClick: function(e) {}
        },
        /**
         * Init Plugin
         */
        init: function() {
            _this = this;
            _this.config = $.extend({}, this.defaults, this.options);

            _navPos = tsfNavPosition[_this.config.navPosition];
            _stepEff = tsfStepEffect[_this.config.stepEffect];
            _stepStyle = tsfStepStyle[_this.config.stepStyle];

            _this.defaults_values();
            _this.events();
            _this.loadScript();

            if (_this.config.validation && !_this.config.showButtons) {
                console.error('Validation and showButtons not be true same time.')
            }

            return this;
        },
        loadScript: function() {
            if (_this.config.navPosition == 'top' || _this.config.navPosition == 'bottom') {
                _width = 0;
                _this.$elem.find('.tsf-nav li').each(function() {
                    _width += jQuery(this).width();
                });
                _this.$elem.find('.tsf-nav').css('width', (_width + 60));
            } else {
                _height = 0;
                _this.$elem.find('.tsf-nav li').each(function() {
                    _height += jQuery(this).height();
                });
                _this.$elem.find('.tsf-nav').css('height', (_height));
            }



            _this.$elem.closest('.tsf-wizard').each(function() {
                _fistVal = true;
                jQuery(this).find('.tsf-nav-step li').eq(0).click();
            });
        },
        display: function(html) {
            _this.$elem.html(html);
        },
        defaults_values: function() {

            /*set defaults*/
            _this.$elem.attr('data-step-effect', _stepEff.className);
            _this.$elem.attr('data-step-index', 0);

            /*set style*/
            _this.$elem.find('.tsf-nav-step ul').removeClass();
            _this.$elem.find('.tsf-nav-step ul').addClass(_stepStyle.className);

            if (_this.config.validation === true) {
                _this.$elem.find('.tsf-nav-step ul').addClass('gsi-step-no-available');
            }

            if (_this.config.stepTransition == true) {
                _this.$elem.find('.tsf-nav-step ul').addClass('gsi-transition');
            }
            if (_this.config.manySteps) {
                _this.$elem.find('.tsf-nav-step').addClass('tsf-nav-many-steps');
                _this.$elem.find('.tsf-nav-step ul').addClass('tsf-nav');

                if (_this.config.navPosition == 'left' || _this.config.navPosition == 'right') {
                    _this.$elem.find('.tsf-nav-many-steps').css({
                        'height': _this.config.height
                    });
                } else if (_this.config.navPosition == 'top' || _this.config.navPosition == 'bottom') {
                    _windowWidth = $(window).width();
                    if (_windowWidth < 768) {
                        _this.$elem.find('.tsf-nav').css('width', '100%');
                        _this.$elem.find('.tsf-nav-many-steps').css({
                            'height': '286px',
                            'overflow-y': 'scroll'
                        });
                    }
                }
            }



            if (!_this.config.showStepNum) {
                _this.$elem.addClass('not-show-num');
            } else {
                _this.$elem.removeClass('not-show-num');
            }

            if (_this.config.validation) {
                //_this.$elem.find('.tsf-step-content').attr('data-parsley-validate', '');

                _this.$elem.find('.tsf-step').each(function(index, section) {
                    jQuery(section).find(':input').attr('data-parsley-group', 'block-' + index);
                });
            }


            _this.$elem.find('.tsf-nav-step').addClass(_navPos.navStepClass);
            _this.$elem.find('.tsf-nav-step ul').addClass(_navPos.stepClass);
            _this.$elem.find('.tsf-container').addClass(_navPos.containerClass);

            _this.$elem.addClass(_navPos.position);

            _this.$elem.find('.tsf-container .tsf-content').css({
                'height': _this.config.height,
                'overflow-y': 'auto'
            });

            _this.$elem.find('.tsf-controls').css({
                'display': (_this.config.showButtons == true ? 'block' : 'none')
            });

            _this.disableSteps(_this.config.disableSteps);

            _this.$elem.find('[data-type="prev"]').html(String(_this.config.prevBtn));
            _this.$elem.find('[data-type="next"]').html(String(_this.config.nextBtn));
            _this.$elem.find('[data-type="finish"]').html(String(_this.config.finishBtn));

            _this.$elem.find('[data-type="next"]').click(function(e) {

                if (_this.config.validation) {
                    activeIndex = _this.$elem.find('.tsf-step.active').index();
                    _isValid = _this.$elem.find('.tsf-content').parsley().validate({
                        group: 'block-' + activeIndex
                    });
                }
                if (_this.config.onBeforeNextButtonClick !== undefined) {
                    _this.config.onBeforeNextButtonClick(e, _isValid);
                }
                if (e.isDefaultPrevented() == true) {
                    return false;
                }

                _this.buttonClick(jQuery(this));


                _currIndex = _this.$elem.find('.tsf-nav-step li.current').index(); //  _this.$elem.data('step-index');
                _from = _currIndex;
                _to = _currIndex + 1;
                //next click
                if (_this.config.onAfterNextButtonClick !== undefined) {
                    _this.config.onAfterNextButtonClick(e, _from, _to, _isValid);
                }
            });

            _this.$elem.find('[data-type="prev"]').click(function(e) {
                _currIndex = _this.$elem.find('.tsf-nav-step li.current').index();;
                _from = _currIndex;
                _to = _currIndex - 1;
                //prev click
                if (_this.config.onBeforePrevButtonClick !== undefined) {
                    _this.config.onBeforePrevButtonClick(e, _from, _to);
                }
                if (e.isDefaultPrevented() == true) {
                    return false;
                }
                _this.buttonClick(jQuery(this));

                if (_this.config.onAfterPrevButtonClick !== undefined) {
                    _this.config.onAfterPrevButtonClick(e, _from, _to);
                }
            });

            _this.$elem.find('[data-type="finish"]').click(function(e) {
                if (_this.config.validation) {
                    activeIndex = _this.$elem.data('step-index');
                    _isValid = _this.$elem.find('.tsf-content').parsley().validate({
                        group: 'block-' + activeIndex
                    });
                }
                //finish click
                if (_this.config.onBeforeFinishButtonClick !== undefined) {
                    _this.config.onBeforeFinishButtonClick(e, _isValid);
                }
                if (e.isDefaultPrevented() == true) {
                    return false;
                }

                _this.finishButtonClick(jQuery(this));

                if (_this.config.onAfterFinishButtonClick !== undefined) {
                    _this.config.onAfterFinishButtonClick(e, _isValid);
                }
            });
        },
        events: function() {
            _this.$elem.find('.tsf-nav-step li').click(function() {
                _element = jQuery(this);
                _this.wizardNavStepClick(_element, 'nav-step');
            });

            // _this.$elem.find(".tsf-wizard-btn").not('[data-type="finish"]').click(function () {
            //     _element = jQuery(this);
            //     _parent = _element.closest('.tsf-wizard');
            //
            //     _index = _parent.attr('data-step-index');
            //
            //     _dataType = _element.attr('data-type');
            //
            //     if (_dataType == 'next') {
            //         _index = parseInt(_index) + 1;
            //     } else {
            //         _index = parseInt(_index) - 1;
            //     }
            //
            //
            //     // _isValid = false;
            //
            //     if (_this.config.validation && _dataType == 'next') {
            //
            //         _content = _parent.find('.tsf-step.active').find('.tsf-step-content');
            //         if (_content.length == 0) {
            //             _this.wizardBtnClick(_index);
            //             _this.wizardNavStepClick(_element.closest('.tsf-wizard').find('.tsf-nav-step li').eq(_index), 'nav-btn');
            //         }
            //         //_content.validate();
            //
            //         // activeIndex = _this.$elem.find('.tsf-step.active').index();
            //         // _isValid = _this.$elem.find('.tsf-content').parsley().validate({ group: 'block-' + activeIndex });
            //
            //         //// console.log('validate '+_this.$elem.find('.tsf-content').parsley().validate({ group: 'block-' + activeIndex }));
            //         // console.log('validate ' + _isValid);
            //         if (_isValid) {
            //             _this.wizardBtnClick(_index);
            //             _this.wizardNavStepClick(_element.closest('.tsf-wizard').find('.tsf-nav-step li').eq(_index), 'nav-btn');
            //         }
            //
            //     } else {
            //         _this.wizardBtnClick(_index);
            //         _this.wizardNavStepClick(_element.closest('.tsf-wizard').find('.tsf-nav-step li').eq(_index), 'nav-btn');
            //     }
            // });

            // _this.$elem.find('.tsf-wizard-btn[data-type="finish"]').click(function () {
            //     _element = jQuery(this);
            //     _parent = _element.closest('.tsf-wizard');
            //
            //     //_isValid = false;
            //     if (_this.config.validation) {
            //         _content = _parent.find('.tsf-step.active').find('.tsf-step-content');
            //         // _content.validate();
            //
            //         activeIndex = _this.$elem.find('.tsf-step.active').index();
            //         //_content.on('submit', function () {
            //         //    //_isValid = _content.find('input.error').length === 0;
            //         //    return true;
            //         //});
            //         //_isValid = _this.$elem.find('.tsf-content').parsley().validate({ group: 'block-' + activeIndex });
            //
            //         if (_isValid) {
            //             //_this.wizardBtnClick(_index, _element);
            //             //_this.wizardNavStepClick(_element.parents('.tsf-wizard').find('.tsf-nav-step li').eq(_index), 'nav-btn');
            //             _this.$elem.find('.tsf-content').submit();
            //         }
            //
            //
            //
            //     }
            // });

        },
        finishButtonClick: function(_element) {
            //_element = jQuery(this);
            _parent = _element.closest('.tsf-wizard');

            //_isValid = false;
            if (_this.config.validation) {
                _content = _parent.find('.tsf-step.active').find('.tsf-step-content');
                // _content.validate();

                activeIndex = _this.$elem.find('.tsf-step.active').index();
                //_content.on('submit', function () {
                //    //_isValid = _content.find('input.error').length === 0;
                //    return true;
                //});
                //_isValid = _this.$elem.find('.tsf-content').parsley().validate({ group: 'block-' + activeIndex });

                if (_isValid) {
                    //_this.wizardBtnClick(_index, _element);
                    //_this.wizardNavStepClick(_element.parents('.tsf-wizard').find('.tsf-nav-step li').eq(_index), 'nav-btn');
                    _this.$elem.find('.tsf-content').submit();
                }



            }
        },
        buttonClick: function(_element) {
            //_element = jQuery(this);
            _parent = _element.closest('.tsf-wizard');

            _index = _parent.attr('data-step-index');

            _dataType = _element.attr('data-type');

            if (_dataType == 'next') {
                _index = parseInt(_index) + 1;
            } else {
                _index = parseInt(_index) - 1;
            }


            // _isValid = false;

            if (_this.config.validation && _dataType == 'next') {

                _content = _parent.find('.tsf-step.active').find('.tsf-step-content');
                if (_content.length == 0) {
                    _this.wizardBtnClick(_index);
                    _this.wizardNavStepClick(_element.closest('.tsf-wizard').find('.tsf-nav-step li').eq(_index), 'nav-btn');
                }
                //_content.validate();

                // activeIndex = _this.$elem.find('.tsf-step.active').index();
                // _isValid = _this.$elem.find('.tsf-content').parsley().validate({ group: 'block-' + activeIndex });

                //// console.log('validate '+_this.$elem.find('.tsf-content').parsley().validate({ group: 'block-' + activeIndex }));
                // console.log('validate ' + _isValid);
                if (_isValid) {
                    _this.wizardBtnClick(_index);
                    _this.wizardNavStepClick(_element.closest('.tsf-wizard').find('.tsf-nav-step li').eq(_index), 'nav-btn');
                }

            } else {
                _this.wizardBtnClick(_index);
                _this.wizardNavStepClick(_element.closest('.tsf-wizard').find('.tsf-nav-step li').eq(_index), 'nav-btn');
            }
        },
        disableSteps: function(disableValue) {
            _stepDisable = tsfDisable[disableValue];

            switch (disableValue) {
                case 'all':
                case 'after_current':
                case 'before_current':
                    {
                        _this.$elem.find('.tsf-nav-step ul').addClass(_stepDisable.className);
                    }
                    break;

                case 'none':
                    {
                        _this.$elem.find('.tsf-nav-step ul').removeClass(_stepDisable.className);
                    }
                    break;
            }
        },
        wizardBtnClick: function(_index) {

            // clickedItem = _this.$elem;

            if (_index == 0) {
                _count = 1;
            } else {
                _count = _this.$elem.find('.tsf-nav-step li').length;
            }
            _finish = false;
            _first = false;

            _btnPrev = _this.$elem.find('.tsf-controls [data-type="prev"]');
            _btnNext = _this.$elem.find('.tsf-controls [data-type="next"]');
            _btnFinish = _this.$elem.find('.tsf-controls [data-type="finish"]');

            //for prev
            if (_index == 0) {
                _first = true;
            } else {
                _first = false;
            }

            if (_index == -1) {
                return;
            }
            //for next
            if (_index >= (_count - 1) && _index != 0) {
                _finish = true;
            }
            //for prev
            if (_first) {
                _btnPrev.hide();
            } else {
                _btnPrev.show();
            }

            //for next
            if (_finish) {
                _btnNext.hide();
                _btnFinish.show();
            } else {
                _btnNext.show();
                _btnFinish.hide();
            }
        },
        wizardNavStepClick: function(_element, from) {

            _parent = _this.$elem; //.parents('.tsf-wizard');
            _oldIndex = _parent.find('.tsf-nav-step li.current').index();
            _return = false;
            if (_this.config.disableSteps !== 'none') {
                // console.log(_element.index());

                // _return = false;
                switch (_this.config.disableSteps) {
                    case 'all':
                        {
                            _return = true;
                        }
                        break;
                    case 'after_current':
                        {
                            if (_element.index() > _oldIndex) {
                                _return = true;
                            }
                        }
                        break;
                    case 'before_current':
                        {
                            if (_element.index() < _oldIndex) {
                                _return = true;
                            }
                        }
                        break;
                    case 'none':
                        {
                            _return = false;
                        }
                        break;
                }


            }


            if (!_fistVal) {
                // if (_element.parent().hasClass('gsi-step-no-available') && from == 'nav-step') {
                //     return false;
                // }
                if (_oldIndex < _element.index() && _element.parent().hasClass('gsi-step-no-available') && from == 'nav-step') {
                    return false;
                }
                if (_return && from == 'nav-step') {
                    return false;
                }
            }
            _fistVal = false;

            _parent.find('.tsf-nav-step li').removeClass('current');
            _element.addClass('current');
            _newIndex = _parent.find('.tsf-nav-step li.current').index();

            _id = _element.data('target');
            _step_effect = _stepEff.className; //_parent.data('step-effect');

            _parent.find('.tsf-content>.tsf-step').removeClass('active').removeClass(_step_effect);
            _parent.find('.tsf-content>.' + _id).addClass('active').addClass(_step_effect);

            _parent.attr('data-step-index', _element.index());
            /*---------------------------------------------*/

            if (_this.config.manySteps) {


                if (typeof _element.position() != "undefined") {

                    if (_this.config.navPosition == 'top' || _this.config.navPosition == 'bottom') {
                        _left = Math.round(_element.position().left);

                        _windowWidth = jQuery(window).width();

                        if (_windowWidth > 1000) {
                            _notShownField = _parent.find('.tsf-nav').width() - _parent.find('.tsf-nav-many-steps').width();

                            // console.log('_left : ' + _left);
                            // console.log('_notShownField : ' + _notShownField);

                            if (_notShownField < (_left)) {
                                _left = _notShownField;
                            } else {
                                _left = 0;
                            }
                        } else {
                            _notShown = (_parent.find('.tsf-nav').width() - _parent.find('.tsf-nav-many-steps').width() - _left);

                            if (_notShown < 60) {
                                _left = _parent.find('.tsf-nav-step li:last-child').position().left - _parent.find('.tsf-nav-many-steps').width() + _parent.find('.tsf-nav-step li:last-child').width();
                            } else {
                                _left = (_left - 80);
                            }


                            if (_newIndex == 0) {
                                _left = 0;
                            }
                        }



                        _parent.find('.tsf-nav').css('transform', 'translateX(-' + _left + 'px)');




                    } else {
                        _top = Math.round(_element.position().top) + 60;
                        _notShownField = _parent.find('.tsf-nav').height() - _parent.find('.tsf-nav-many-steps').height();
                        _allCount = _parent.find('.tsf-nav li').length;


                        _avgHeight = Math.round(_parent.find('.tsf-nav').height() / _allCount);
                        _shownCount = Math.round(parseInt(_this.config.height.replace('px', ''), 0) / _avgHeight);

                        _notShownCount = _allCount - _newIndex;



                        if (_oldIndex > _newIndex) {
                            _newIndex = _newIndex - _shownCount + 2;

                            if (_newIndex < 0) {
                                _newIndex = 0;
                            }

                            _top = _parent.find('.tsf-nav li').eq(_newIndex).position().top;
                        } else {
                            if (_notShownCount > _shownCount) {
                                _newIndex = _newIndex - 1;

                                if (_newIndex < 0) {
                                    _newIndex = 0;
                                }
                                _top = _parent.find('.tsf-nav li').eq(_newIndex).position().top;
                            } else {
                                _newIndex = _allCount - _shownCount;
                                _top = _parent.find('.tsf-nav li').eq(_newIndex).position().top;
                            }
                        }

                        _parent.find('.tsf-nav').css('transform', 'translateY(-' + _top + 'px)');

                    }
                }
            }
            /*----------------------------------------------*/

            _this.wizardBtnClick(_element.index());
        },

        /**
         * Show loading
         */
        show_loading: function() {
            if (_this.config.showLoading == true) {
                _this.$elem.css({
                    'position': 'relative'
                });
                _this.display('<div class="bal-loading-container"><div class="bal-loading"><div class="bal-loading-bounce-1" style="background-color:' + _this.config.loading_color1 + '"></div><div class="bal-loading-bounce-2" style="background-color:' + _this.config.loading_color2 + '"></div></div></div>');
            }
        },
        /*
         * Get current index
         */
        getCurrentIndex: function() {
            return _this.$elem.find('.tsf-nav-step li.current').index();
        },
        /*
         * Change next button label
         */
        nextButtonLabel: function(text) {
            _this.$elem.find('.tsf-controls [data-type="next"]').html(text);
        },
        /*
         * Change previous button label
         */
        prevButtonLabel: function(text) {
            _this.$elem.find('.tsf-controls [data-type="prev"]').html(text);
        },
        /*
         * Change finish button label
         */
        finishButtonLabel: function(text) {
            _this.$elem.find('.tsf-controls [data-type="finish"]').html(text);
        },
        /*
          goto any index

        */
        goto: function(index) {

            if (_this.getCurrentIndex() < index && _this.config.validation == true) {
                console.error('Validation is true.You can not go to the next step');
                return;
            }

            _this.wizardBtnClick(index);
            _this.wizardNavStepClick(_this.$elem.find('.tsf-nav-step li').eq(index), 'nav-btn');
        },
        setDisableSteps: function(value) {
            _this.config.disableSteps = value;
            _this.disableSteps(value);
            //_wizardNavStepClick($base.find('.tsf-nav-step li').eq(this.getCurrentIndex()), 'nav-btn');
        },

        //goto next step
        nextStep: function() {
            _index = _this.getCurrentIndex() + 1;
            _this.goto(_index);

        },
        //goto previous step
        previousStep: function() {
            _index = _this.getCurrentIndex() - 1;
            _this.goto(_index < 0 ? 0 : _index);
        },
        //validate current step
        validate: function() {
            if (_this.config.validation) {
                _isValid = _this.$elem.find('.tsf-content').parsley().validate({
                    group: 'block-' + _this.getCurrentIndex()
                });
            }
        }
    };

    $.fn.tsfWizard = function(options) {

        var _tsfWizard;
        /*
         * Change next button label
         */
        this.nextButtonLabel = function(txt) {
            _tsfWizard.nextButtonLabel(txt);
        }
        /*
         * Change previous button label
         */
        this.prevButtonLabel = function(txt) {
            _tsfWizard.prevButtonLabel(txt);
        }
        /*
         * Change finish button label
         */
        this.finishButtonLabel = function(txt) {
            _tsfWizard.finishButtonLabel(txt);
        }
        /*
         * Get current index
         */
        this.getCurrentIndex = function() {
            return _tsfWizard.getCurrentIndex();
        }


        this.goto = function(value) {
            _tsfWizard.goto(value);
        }

        this.setDisableSteps = function(value) {
            _tsfWizard.setDisableSteps(value);

        }
        this.nextStep = function() {
            _tsfWizard.nextStep();
        }
        this.previousStep = function() {
            _tsfWizard.previousStep();
        }
        this.validate = function() {
            _tsfWizard.validate();
        }

        return this.each(function() {
            _tsfWizard = new tsfWizard(this, options);
            _tsfWizard.init();
        });
    };
});

jQuery.fn.hasParent = function(e) {
    return (jQuery(this).parents(e).length == 1 ? true : false);
}
