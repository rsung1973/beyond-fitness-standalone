
jQuery.fn.tsfWizard = function (options) {

    var defaults =
    {
        stepStyle: 'style1',       // grumpy step indicator all styles
        stepEffect: 'basic',
        showStepNum: true,
        stepTransition: true,      //true or false
        validation: false,         //true or false
        navPosition: 'top',        //'bottom' or top,right,left
        height: 'auto',            //'auto' or any height (600px,400px etc)
        showButtons: true,
        manySteps: false,
        prevBtn: '<i class="fa fa-chevron-left"></i> PREV',
        nextBtn: 'NEXT <i class="fa fa-chevron-right"></i>',
        finishBtn: 'FINISH',
        disableSteps: 'none',       //all | after_current | before_current | none
        onSlideChanged: function (e) { },
        onNextClick: function (e) { },
        onPrevClick: function (e) { },
        onPrevClick: function (e) { },
        onFinishClick: function (e) { }
    };

    var settings = $.extend({}, defaults, options);
    var base, $base;


    //get current index
    this.getCurrentIndex = function () {
        return $base.find('.tsf-nav-step li.current').index();
    }
    /*
      goto any index

    */
    this.goto = function (index) {

        if (this.getCurrentIndex() < index && settings.validation == true) {
            console.error('Validation is true.You can not go to the next step');
            return;
        }

        _wizardBtnClick(index);
        _wizardNavStepClick($base.find('.tsf-nav-step li').eq(index), 'nav-btn');
    }
    this.setDisableSteps = function (value) {
        settings.disableSteps = value;
        console.log(value);
        _disableSteps(value);
        //_wizardNavStepClick($base.find('.tsf-nav-step li').eq(this.getCurrentIndex()), 'nav-btn');
    }

    //goto next step
    this.nextStep = function () {
        _index = this.getCurrentIndex() + 1;
        this.goto(_index);

    }
    //goto previous step
    this.previousStep = function () {
        _index = this.getCurrentIndex() - 1;
        this.goto(_index < 0 ? 0 : _index);
    }

    //validate current step
    this.validate = function () {
        if (settings.validation) {
            _isValid = $base.find('.tsf-content').parsley().validate({ group: 'block-' + this.getCurrentIndex() });
        }
    }
    this.nextButtonLabel = function (text) {
        $base.find('.tsf-controls [data-type="next"]').html(text);
    }
    this.prevButtonLabel = function (text) {
        $base.find('.tsf-controls [data-type="prev"]').html(text);
    }
    this.finishButtonLabel = function (text) {
        $base.find('.tsf-controls [data-type="finish"]').html(text);
    }





    return this.each(function (i, el) {
        base = el,
        $base = $(el);


        base.init = function () {
            base.setDefaults();
            base.setEvents();
            base.loadScript();



        }
        base.setDefaults = function () {

        }
        base.loadScript = function () {


        }
        base.setEvents = function () {



        }

        base.init();
    });

};
