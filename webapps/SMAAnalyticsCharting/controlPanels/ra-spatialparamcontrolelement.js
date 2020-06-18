(function(GLOBAL, template) {
    var spatialParamControlElementPrototype = {
        is: 'ra-spatialparamcontrolelement',
        behaviors: [GLOBAL.DS.RAComponents.paramcontrolelement]
    };

    spatialParamControlElementPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.paramcontrolelement.createdCallback.call(this);

        this.showFilter = true;
        this.showAggregationType = true;
        this.checkboxes = [];
        this.aggregationTypeSelect = null;
        this.minMaxSlider = null;
    };

    spatialParamControlElementPrototype.setupCheckboxes = function() {
        var strings = this.parameter.stringSortedByFreqs;

        for (var i = 0; i < strings.length; i++) {
            var check = document.createElement('ra-checkboxcontrol');
            this.checkboxes.push(check);
            check.setCheck(true);
            check.setLabel(strings[i]);
            this.querySelector('.bodyDiv').appendChild(check);
        }
    };

    spatialParamControlElementPrototype.setUpdateDiscreteValuesCallback = function(
        fn
    ) {
        var that = this;

        this.valuesCallback = fn;
        for (var i = 0; i < this.checkboxes.length; i++) {
            this.checkboxes[i].setUpdateCallback(function(v) {
                if (typeof that.valuesCallback === 'function') {
                    that.valuesCallback(that.getDiscreteValues());
                }
            });
        }
    };

    spatialParamControlElementPrototype.setupMinMaxSlider = function() {
        this.minMaxSlider = document.createElement('ra-dualslidercontrol');
        this.minMaxSlider.setLabel('Filter:');

        this.querySelector('.bodyDiv').appendChild(this.minMaxSlider);
    };

    spatialParamControlElementPrototype.setUpdateLinearMinCallback = function(
        fn
    ) {
        if (this.minMaxSlider !== null) {
            this.minMaxSlider.setUpdateMinCallback(fn);
        }
    };

    spatialParamControlElementPrototype.setUpdateLinearMaxCallback = function(
        fn
    ) {
        if (this.minMaxSlider !== null) {
            this.minMaxSlider.setUpdateMaxCallback(fn);
        }
    };

    spatialParamControlElementPrototype.setupAggregationType = function() {
        this.aggregationTypeSelect = document.createElement('ra-selectcontrol');
        this.aggregationTypeSelect.setLabel('Aggr:');

        this.aggregationTypeSelect.addOption(new Option('Count', 'COUNT'));
        this.aggregationTypeSelect.addOption(
            new Option('Count>0', 'COUNT_GT_0')
        );
        this.aggregationTypeSelect.addOption(new Option('Minimum', 'MINIMUM'));
        this.aggregationTypeSelect.addOption(new Option('Maximum', 'MAXIMUM'));
        this.aggregationTypeSelect.addOption(new Option('Mean', 'MEAN'));
        this.aggregationTypeSelect.addOption(new Option('Median', 'MEDIAN'));
        this.aggregationTypeSelect.addOption(new Option('Sum', 'SUM'));
        this.aggregationTypeSelect.addOption(new Option('AbsSum', 'ABSSUM'));
        this.aggregationTypeSelect.addOption(new Option('First', 'FIRST'));
        this.aggregationTypeSelect.setValue('MEAN');

        this.querySelector('.bodyDiv').appendChild(this.aggregationTypeSelect);
    };

    spatialParamControlElementPrototype.setUpdateAggregationTypeCallback = function(
        fn
    ) {
        if (this.aggregationTypeSelect !== null) {
            this.aggregationTypeSelect.setUpdateCallback(fn);
        }
    };

    spatialParamControlElementPrototype.setParameter = function(param) {
        this.parameter = param;

        if (this.parameter.dataType == 'STRING') {
            if (this.showFilter === true) {
                this.setupCheckboxes();
            }
        } else {
            if (this.showAggregationType === true) {
                this.setupAggregationType();
            }
            if (this.showFilter === true) {
                this.setupMinMaxSlider();
            }
        }

        this.render();
    };

    spatialParamControlElementPrototype.setShowFilter = function(value) {
        this.showFilter = value;
    };

    spatialParamControlElementPrototype.setShowAggregationType = function(
        value
    ) {
        this.showAggregationType = value;
    };

    spatialParamControlElementPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        if (typeof request !== 'undefined') {
            this.currentRequest = JSON.parse(JSON.stringify(request));
            if (
                typeof this.currentRequest.minFilterPercent !== 'undefined' &&
                this.currentRequest.minFilterPercent !== null
            ) {
                this.setLinearMinValue(this.currentRequest.minFilterPercent);
            }
            if (
                typeof this.currentRequest.maxFilterPercent !== 'undefined' &&
                this.currentRequest.maxFilterPercent !== null
            ) {
                this.setLinearMaxValue(this.currentRequest.maxFilterPercent);
            }
            if (
                typeof this.currentRequest.aggregationType !== 'undefined' &&
                this.currentRequest.aggregationType !== null
            ) {
                this.setAggregationType(this.currentRequest.aggregationType);
            }
            if (
                typeof this.currentRequest.discreteValues !== 'undefined' &&
                this.currentRequest.discreteValues !== null
            ) {
                this.setDiscreteValues(this.currentRequest.discreteValues);
            }
        } else {
            this.currentRequest = null;
        }
    };

    spatialParamControlElementPrototype.getLinearMinValue = function() {
        var value = null;
        if (this.minMaxSlider !== null) {
            value = this.minMaxSlider.getMinValue();
        }
        return value;
    };

    spatialParamControlElementPrototype.setLinearMinValue = function(value) {
        if (this.minMaxSlider !== null) {
            this.minMaxSlider.setMinValue(value);
        }
    };

    spatialParamControlElementPrototype.getLinearMaxValue = function() {
        var value = null;
        if (this.minMaxSlider !== null) {
            value = this.minMaxSlider.getMaxValue();
        }
        return value;
    };

    spatialParamControlElementPrototype.setLinearMaxValue = function(value) {
        if (this.minMaxSlider !== null) {
            this.minMaxSlider.setMaxValue(value);
        }
    };

    spatialParamControlElementPrototype.getAggregationType = function() {
        var value = null;
        if (this.aggregationTypeSelect !== null) {
            value = this.aggregationTypeSelect.getValue();
        }
        return value;
    };

    spatialParamControlElementPrototype.setAggregationType = function(value) {
        if (this.aggregationTypeSelect !== null) {
            this.aggregationTypeSelect.setValue(value);
        }
    };

    spatialParamControlElementPrototype.getDiscreteValues = function() {
        var discreteValues = [];

        for (var i = 0; i < this.checkboxes.length; i++) {
            var check = this.checkboxes[i];
            if (check.getCheck() === true) {
                discreteValues.push(check.getLabel());
            }
        }

        return discreteValues;
    };

    spatialParamControlElementPrototype.setDiscreteValues = function(value) {};

    Polymer(spatialParamControlElementPrototype);
    GLOBAL.DS.RAComponents.spatialparamcontrolelement = spatialParamControlElementPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
