(function(GLOBAL, template) {
    var sizeParamControlElementPrototype = {
        is: 'ra-sizeparamcontrolelement',
        behaviors: [GLOBAL.DS.RAComponents.paramcontrolelement]
    };

    sizeParamControlElementPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.paramcontrolelement.createdCallback.call(this);

        this.dataMaps = [];

        this.dataMapSelect = null;
        this.aggregationTypeSelect = null;
        this.showAggregationType = true;
        this.minMaxSlider = null;
    };

    sizeParamControlElementPrototype.setupDataMapSelect = function() {
        this.dataMapSelect = document.createElement('ra-selectcontrol');
        this.dataMapSelect.setLabel('Map:');

        // Get sizemaps from global library
        var sizeMaps = GLOBAL.DS.RAObjects.dataMaps.sizeMaps;

        for (var i = 0; i < sizeMaps.length; i++) {
            var d = sizeMaps[i];
            if (d.type === 'linear') {
                this.dataMapSelect.addOption(new Option(d.displayName, d.guid));
                this.dataMaps.push(d);
                if (
                    this.dataMaps.length == 1 ||
                    d.defaultCode === 'valueSizeMap'
                ) {
                    this.dataMapSelect.setValue(d.guid);
                }
            }
        }

        this.querySelector('.bodyDiv').appendChild(this.dataMapSelect);
    };

    sizeParamControlElementPrototype.setUpdateDataMapCallback = function(fn) {
        var that = this;

        this.dataMapCallback = fn;
        this.dataMapSelect.setUpdateCallback(function(v) {
            if (typeof that.dataMapCallback === 'function') {
                that.dataMapCallback(that.getDataMap());
            }
        });
    };

    sizeParamControlElementPrototype.setupAggregationTypeSelect = function() {
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

    sizeParamControlElementPrototype.setUpdateAggregationTypeCallback = function(
        fn
    ) {
        if (this.aggregationTypeSelect !== null) {
            this.aggregationTypeSelect.setUpdateCallback(fn);
        }
    };

    sizeParamControlElementPrototype.setupMinMaxSlider = function() {
        this.minMaxSlider = document.createElement('ra-dualslidercontrol');
        this.minMaxSlider.setLabel('Filter:');

        this.querySelector('.bodyDiv').appendChild(this.minMaxSlider);
    };

    sizeParamControlElementPrototype.setUpdateLinearMinCallback = function(fn) {
        this.minMaxSlider.setUpdateMinCallback(fn);
    };

    sizeParamControlElementPrototype.setUpdateLinearMaxCallback = function(fn) {
        this.minMaxSlider.setUpdateMaxCallback(fn);
    };

    sizeParamControlElementPrototype.setParameter = function(param) {
        this.parameter = param;

        this.setupDataMapSelect();
        if (this.showAggregationType === true) {
            this.setupAggregationTypeSelect();
        }
        this.setupMinMaxSlider();

        this.render();
    };

    sizeParamControlElementPrototype.setShowAggregationType = function(value) {
        this.showAggregationType = value;
    };

    sizeParamControlElementPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        if (typeof request !== 'undefined') {
            this.currentRequest = JSON.parse(JSON.stringify(request));
            if (
                typeof this.currentRequest.dataMap !== 'undefined' &&
                this.currentRequest.dataMap !== null
            ) {
                this.setDataMap(this.currentRequest.dataMap);
            }
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
        } else {
            this.currentRequest = null;
        }
    };

    sizeParamControlElementPrototype.getDataMap = function() {
        var value = this.dataMapSelect.getValue();

        for (var i = 0; i < this.dataMaps.length; i++) {
            if (this.dataMaps[i].guid === value) {
                return this.dataMaps[i];
            }
        }

        return null;
    };

    sizeParamControlElementPrototype.setDataMap = function(value) {
        this.dataMapSelect.setValue(value);
    };

    sizeParamControlElementPrototype.getAggregationType = function() {
        var value = null;
        if (this.aggregationTypeSelect !== null) {
            value = this.aggregationTypeSelect.getValue();
        }
        return value;
    };

    sizeParamControlElementPrototype.setAggregationType = function(value) {
        if (this.aggregationTypeSelect !== null) {
            this.aggregationTypeSelect.setValue(value);
        }
    };

    sizeParamControlElementPrototype.getLinearMinValue = function() {
        return this.minMaxSlider.getMinValue();
    };

    sizeParamControlElementPrototype.setLinearMinValue = function(value) {
        this.minMaxSlider.setMinValue(value);
    };

    sizeParamControlElementPrototype.getLinearMaxValue = function() {
        return this.minMaxSlider.getMaxValue();
    };

    sizeParamControlElementPrototype.setLinearMaxValue = function(value) {
        this.minMaxSlider.setMaxValue(value);
    };

    Polymer(sizeParamControlElementPrototype);
    GLOBAL.DS.RAComponents.sizeparamcontrolelement = sizeParamControlElementPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
