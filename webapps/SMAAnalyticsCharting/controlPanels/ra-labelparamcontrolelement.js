(function(GLOBAL, template) {
    var labelParamControlElementPrototype = {
        is: 'ra-labelparamcontrolelement',
        behaviors: [GLOBAL.DS.RAComponents.paramcontrolelement]
    };

    labelParamControlElementPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.paramcontrolelement.createdCallback.call(this);

        this.showAggregationType = true;
        this.aggregationTypeSelect = null;
    };

    labelParamControlElementPrototype.setupAggregationType = function() {
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

    labelParamControlElementPrototype.setUpdateAggregationTypeCallback = function(
        fn
    ) {
        if (this.aggregationTypeSelect !== null) {
            this.aggregationTypeSelect.setUpdateCallback(fn);
        }
    };

    labelParamControlElementPrototype.setParameter = function(param) {
        this.parameter = param;

        if (this.showAggregationType === true) {
            this.setupAggregationType();
        }

        this.render();
    };

    labelParamControlElementPrototype.setShowAggregationType = function(value) {
        this.showAggregationType = value;
    };

    labelParamControlElementPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        if (typeof request !== 'undefined') {
            this.currentRequest = JSON.parse(JSON.stringify(request));
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

    labelParamControlElementPrototype.getAggregationType = function() {
        var value = null;
        if (this.aggregationTypeSelect !== null) {
            value = this.aggregationTypeSelect.getValue();
        }
        return value;
    };

    labelParamControlElementPrototype.setAggregationType = function(value) {
        if (this.aggregationTypeSelect !== null) {
            this.aggregationTypeSelect.setValue(value);
        }
    };

    Polymer(labelParamControlElementPrototype);
    GLOBAL.DS.RAComponents.labelparamcontrolelement = labelParamControlElementPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
