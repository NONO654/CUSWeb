(function(GLOBAL, template) {
    var shapeParamControlElementPrototype = {
        is: 'ra-shapeparamcontrolelement',
        behaviors: [GLOBAL.DS.RAComponents.paramcontrolelement]
    };

    shapeParamControlElementPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.paramcontrolelement.createdCallback.call(this);

        this.dataMaps = [];

        this.dataMapSelect = null;
        this.aggregationTypeSelect = null;
        this.showAggregationType = true;
        this.checkboxes = [];
        this.minMaxSlider = null;
    };

    shapeParamControlElementPrototype.setupDataMapSelect = function() {
        this.dataMapSelect = document.createElement('ra-selectcontrol');
        this.dataMapSelect.setLabel('Map:');

        // Get shapemaps from example library
        var shapeMaps = GLOBAL.DS.RAObjects.dataMaps.binnedShapeMaps.concat(
            GLOBAL.DS.RAObjects.dataMaps.discreteShapeMaps
        );
        var defaultCode = 'valueShapeMap';
        var type = 'binned';
        if (this.parameter.dataType === 'STRING') {
            type = 'discrete';
            defaultCode = 'discreteShapeMap';
        }

        for (var i = 0; i < shapeMaps.length; i++) {
            var d = shapeMaps[i];
            if (d.type === type) {
                this.dataMapSelect.addOption(new Option(d.displayName, d.guid));
                this.dataMaps.push(d);
                if (
                    this.dataMaps.length == 1 ||
                    d.defaultCode === defaultCode
                ) {
                    this.dataMapSelect.setValue(d.guid);
                }
            }
        }

        this.querySelector('.bodyDiv').appendChild(this.dataMapSelect);
    };

    shapeParamControlElementPrototype.setUpdateDataMapCallback = function(fn) {
        var that = this;

        this.dataMapCallback = fn;
        this.dataMapSelect.setUpdateCallback(function(v) {
            if (typeof that.dataMapCallback === 'function') {
                that.dataMapCallback(that.getDataMap());
            }
        });
    };

    shapeParamControlElementPrototype.setupAggregationTypeSelect = function() {
        this.aggregationTypeSelect = document.createElement('ra-selectcontrol');
        this.aggregationTypeSelect.setLabel('Aggr:');

        if (this.parameter.dataType === 'STRING') {
            this.aggregationTypeSelect.addOption(new Option('First', 'FIRST'));
            this.aggregationTypeSelect.setValue('FIRST');
            this.aggregationTypeSelect.addOption(
                new Option('Minimum', 'MINIMUM')
            );
            this.aggregationTypeSelect.addOption(
                new Option('Maximum', 'MAXIMUM')
            );
            this.aggregationTypeSelect.addOption(new Option('Count', 'COUNT'));
        } else {
            this.aggregationTypeSelect.addOption(new Option('Count', 'COUNT'));
            this.aggregationTypeSelect.addOption(
                new Option('Count>0', 'COUNT_GT_0')
            );
            this.aggregationTypeSelect.addOption(
                new Option('Minimum', 'MINIMUM')
            );
            this.aggregationTypeSelect.addOption(
                new Option('Maximum', 'MAXIMUM')
            );
            this.aggregationTypeSelect.addOption(new Option('Mean', 'MEAN'));
            this.aggregationTypeSelect.addOption(
                new Option('Median', 'MEDIAN')
            );
            this.aggregationTypeSelect.addOption(new Option('Sum', 'SUM'));
            this.aggregationTypeSelect.addOption(
                new Option('AbsSum', 'ABSSUM')
            );
            this.aggregationTypeSelect.addOption(new Option('First', 'FIRST'));
            this.aggregationTypeSelect.setValue('MEAN');
        }

        this.querySelector('.bodyDiv').appendChild(this.aggregationTypeSelect);
    };

    shapeParamControlElementPrototype.setUpdateAggregationTypeCallback = function(
        fn
    ) {
        if (this.aggregationTypeSelect !== null) {
            this.aggregationTypeSelect.setUpdateCallback(fn);
        }
    };

    shapeParamControlElementPrototype.setupMinMaxSlider = function() {
        this.minMaxSlider = document.createElement('ra-dualslidercontrol');
        this.minMaxSlider.setLabel('Filter:');

        this.querySelector('.bodyDiv').appendChild(this.minMaxSlider);
    };

    shapeParamControlElementPrototype.setUpdateLinearMinCallback = function(
        fn
    ) {
        if (this.minMaxSlider !== null) {
            this.minMaxSlider.setUpdateMinCallback(fn);
        }
    };

    shapeParamControlElementPrototype.setUpdateLinearMaxCallback = function(
        fn
    ) {
        if (this.minMaxSlider !== null) {
            this.minMaxSlider.setUpdateMaxCallback(fn);
        }
    };

    shapeParamControlElementPrototype.setupCheckboxes = function() {
        var strings = this.parameter.stringSortedByFreqs;

        for (var i = 0; i < strings.length; i++) {
            var check = document.createElement('ra-checkboxcontrol');
            this.checkboxes.push(check);
            check.setCheck(true);
            check.setLabel(strings[i]);
            this.querySelector('.bodyDiv').appendChild(check);
        }
    };

    shapeParamControlElementPrototype.setUpdateDiscreteValuesCallback = function(
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

    shapeParamControlElementPrototype.setParameter = function(param) {
        this.parameter = param;

        this.setupDataMapSelect();
        if (this.showAggregationType === true) {
            this.setupAggregationTypeSelect();
        }
        if (this.parameter.dataType == 'STRING') {
            this.setupCheckboxes();

            // Run once to configure the checkboxes
            this.getDataMap();
        } else {
            this.setupMinMaxSlider();
        }

        this.render();
    };

    shapeParamControlElementPrototype.setShowAggregationType = function(value) {
        this.showAggregationType = value;
    };

    shapeParamControlElementPrototype.setDefaultRequest = function(request) {
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

    shapeParamControlElementPrototype.getDataMap = function() {
        var value = this.dataMapSelect.getValue();

        if (this.parameter.dataType === 'STRING') {
            for (var i = 0; i < this.dataMaps.length; i++) {
                var dataMap = this.dataMaps[i];
                if (dataMap.guid === value) {
                    var dataMapLength = dataMap.shapes.length;
                    if (dataMapLength < 1) {
                        break;
                    }
                    var newDataMap = {
                        guid: 'uiDiscreteShapeMap',
                        displayName: 'uiDiscreteShapeMap',
                        type: 'discrete',
                        inputs: [],
                        shapes: []
                    };

                    for (var j = 0; j < this.checkboxes.length; j++) {
                        var checkbox = this.checkboxes[j];
                        if (checkbox.getCheck() === true) {
                            var shape = dataMap.shapes[j % dataMapLength];
                            checkbox.setMap(shape);
                            newDataMap.shapes.push(shape);
                            newDataMap.inputs.push(checkbox.getLabel());
                        } else {
                            checkbox.setMap(null);
                        }
                    }

                    return newDataMap;
                }
            }
        } else {
            for (var i = 0; i < this.dataMaps.length; i++) {
                if (this.dataMaps[i].guid === value) {
                    return this.dataMaps[i];
                }
            }
        }

        return null;
    };

    shapeParamControlElementPrototype.setDataMap = function(value) {
        this.dataMapSelect.setValue(value);
        updateSliderBackground();
    };

    shapeParamControlElementPrototype.getAggregationType = function() {
        var value = null;
        if (this.aggregationTypeSelect !== null) {
            value = this.aggregationTypeSelect.getValue();
        }
        return value;
    };

    shapeParamControlElementPrototype.setAggregationType = function(value) {
        if (this.aggregationTypeSelect !== null) {
            this.aggregationTypeSelect.setValue(value);
        }
    };

    shapeParamControlElementPrototype.getLinearMinValue = function() {
        var value = null;
        if (this.minMaxSlider !== null) {
            value = this.minMaxSlider.getMinValue();
        }
        return value;
    };

    shapeParamControlElementPrototype.setLinearMinValue = function(value) {
        if (this.minMaxSlider !== null) {
            this.minMaxSlider.setMinValue(value);
        }
    };

    shapeParamControlElementPrototype.getLinearMaxValue = function() {
        var value = null;
        if (this.minMaxSlider !== null) {
            value = this.minMaxSlider.getMaxValue();
        }
        return value;
    };

    shapeParamControlElementPrototype.setLinearMaxValue = function(value) {
        if (this.minMaxSlider !== null) {
            this.minMaxSlider.setMaxValue(value);
        }
    };

    shapeParamControlElementPrototype.getDiscreteValues = function() {
        var discreteValues = [];

        for (var i = 0; i < this.checkboxes.length; i++) {
            var check = this.checkboxes[i];
            if (check.getCheck() === true) {
                discreteValues.push(check.getLabel());
            }
        }

        return discreteValues;
    };

    shapeParamControlElementPrototype.setDiscreteValues = function(value) {};

    Polymer(shapeParamControlElementPrototype);
    GLOBAL.DS.RAComponents.shapeparamcontrolelement = shapeParamControlElementPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
