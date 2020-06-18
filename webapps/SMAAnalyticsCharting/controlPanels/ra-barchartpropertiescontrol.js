(function(GLOBAL, template) {
    var barChartPropertiesPrototype = {
        is: 'ra-barchartpropertiescontrol',
        behaviors: [GLOBAL.DS.RAComponents.control]
    };

    barChartPropertiesPrototype.createdCallback = function() {
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.setupBordersOn();
        this.setupLayout();
        this.setupShape();
        this.setupBarWidth();
        this.setupBarOffset();
        this.setupValueLabels();
        this.setupBarStartValue();

        this.title('Bar Chart');
    };

    barChartPropertiesPrototype.setupBordersOn = function() {
        var that = this;

        this.bordersOnInput = this.querySelector('.bordersOn');
        this.bordersOnInput.setLabel('Borders');

        this.bordersOnInput.setUpdateCallback(function(value) {
            that.setBordersOn(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    barChartPropertiesPrototype.setupLayout = function() {
        var that = this;

        this.layoutInput = this.querySelector('.layout');
        this.layoutInput.setLabel('Layout:');

        this.layoutInput.addOption(new Option('Clustered', 'clustered'));
        this.layoutInput.setValue('clustered');
        this.layoutInput.addOption(new Option('Stacked', 'stacked'));
        this.layoutInput.addOption(new Option('Paretto', 'paretto'));
        this.layoutInput.addOption(new Option('Cumulative', 'cumulative'));

        this.layoutInput.setUpdateCallback(function(value) {
            that.setLayout(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    barChartPropertiesPrototype.setupShape = function() {
        var that = this;

        this.shapeInput = this.querySelector('.shape');
        this.shapeInput.setLabel('Shape:');

        this.shapeInput.addOption(new Option('Rectangle', 'rectangle'));
        this.shapeInput.setValue('rectangle');
        this.shapeInput.addOption(new Option('Triangle', 'triangle'));

        this.shapeInput.setUpdateCallback(function(value) {
            that.setShape(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    barChartPropertiesPrototype.setupBarWidth = function() {
        var that = this;

        this.barWidthInput = this.querySelector('.barWidth');
        this.barWidthInput.setLabel('Width:');
        this.barWidthInput.setMinLimit(0);
        this.barWidthInput.setMaxLimit(1);
        this.barWidthInput.setStep(0.01);
        this.barWidthInput.setValue(0.5);

        this.barWidthInput.setUpdateCallback(function(value) {
            that.setBarWidth(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    barChartPropertiesPrototype.setupBarOffset = function() {
        var that = this;

        this.barOffsetInput = this.querySelector('.barOffset');
        this.barOffsetInput.setLabel('Offset:');
        this.barOffsetInput.setMinLimit(0);
        this.barOffsetInput.setMaxLimit(1);
        this.barOffsetInput.setStep(0.01);
        this.barOffsetInput.setValue(0);

        this.barOffsetInput.setUpdateCallback(function(value) {
            that.setBarOffset(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    barChartPropertiesPrototype.setupValueLabels = function() {
        var that = this;

        this.valueLabelsInput = this.querySelector('.valueLabels');
        this.valueLabelsInput.setLabel('Labels');

        this.valueLabelsInput.setUpdateCallback(function(value) {
            that.setValueLabels(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    barChartPropertiesPrototype.setupBarStartValue = function() {
        var that = this;

        this.barStartValueInput = this.querySelector('.barStartValue');
        this.barStartValueInput.setLabel('Start:');

        this.barStartValueInput.setUpdateCallback(function(value) {
            that.setBarStartValue(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    barChartPropertiesPrototype.setChangeListener = function(listener) {
        this.updateCallback = listener;
    };

    barChartPropertiesPrototype.getBordersOn = function() {
        return this.currentRequest.bordersOn;
    };

    barChartPropertiesPrototype.setBordersOn = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.bordersOn = value;
        this.bordersOnInput.setCheck(value);
    };

    barChartPropertiesPrototype.getLayout = function() {
        return this.currentRequest.layout;
    };

    barChartPropertiesPrototype.setLayout = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.layout = value;
        this.layoutInput.setValue(value);
    };

    barChartPropertiesPrototype.getShape = function() {
        return this.currentRequest.shape;
    };

    barChartPropertiesPrototype.setShape = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.shape = value;
        this.shapeInput.setValue(value);
    };

    barChartPropertiesPrototype.getBarWidth = function() {
        return this.currentRequest.barWidth;
    };

    barChartPropertiesPrototype.setBarWidth = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.barWidth = value;
        this.barWidthInput.setValue(value);
    };

    barChartPropertiesPrototype.getBarOffset = function() {
        return this.currentRequest.barOffset;
    };

    barChartPropertiesPrototype.setBarOffset = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.barOffset = value;
        this.barOffsetInput.setValue(value);
    };

    barChartPropertiesPrototype.getValueLabels = function() {
        return this.currentRequest.valueLabels;
    };

    barChartPropertiesPrototype.setValueLabels = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.valueLabels = value;
        this.valueLabelsInput.setCheck(value);
    };

    barChartPropertiesPrototype.getBarStartValue = function() {
        return this.currentRequest.barStartValue;
    };

    barChartPropertiesPrototype.setBarStartValue = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.barStartValue = value;
        this.barStartValueInput.setValue(value);
    };

    barChartPropertiesPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        if (typeof request !== 'undefined') {
            this.currentRequest = JSON.parse(JSON.stringify(request));
            if (
                typeof this.currentRequest.bordersOn !== 'undefined' &&
                this.currentRequest.bordersOn !== null
            ) {
                this.setBordersOn(this.currentRequest.bordersOn);
            }
            if (
                typeof this.currentRequest.layout !== 'undefined' &&
                this.currentRequest.layout !== null
            ) {
                this.setLayout(this.currentRequest.layout);
            }
            if (
                typeof this.currentRequest.shape !== 'undefined' &&
                this.currentRequest.shape !== null
            ) {
                this.setShape(this.currentRequest.shape);
            }
            if (
                typeof this.currentRequest.barWidth !== 'undefined' &&
                this.currentRequest.barWidth !== null
            ) {
                this.setBarWidth(this.currentRequest.barWidth);
            }
            if (
                typeof this.currentRequest.barOffset !== 'undefined' &&
                this.currentRequest.barOffset !== null
            ) {
                this.setBarOffset(this.currentRequest.barOffset);
            }
            if (
                typeof this.currentRequest.valueLabels !== 'undefined' &&
                this.currentRequest.valueLabels !== null
            ) {
                this.setValueLabels(this.currentRequest.valueLabels);
            }
            if (
                typeof this.currentRequest.barStartValue !== 'undefined' &&
                this.currentRequest.barStartValue !== null
            ) {
                this.setBarStartValue(this.currentRequest.barStartValue);
            }
        } else {
            this.currentRequest = null;
        }
    };

    barChartPropertiesPrototype.getRequest = function() {
        return this.currentRequest;
    };

    Polymer(barChartPropertiesPrototype);
    GLOBAL.DS.RAComponents.barchartpropertiescontrol = barChartPropertiesPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
