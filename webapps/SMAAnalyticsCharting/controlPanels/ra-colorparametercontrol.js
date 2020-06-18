(function(GLOBAL, template) {
    var colorParameterControlPrototype = {
        is: 'ra-colorparametercontrol',
        behaviors: [GLOBAL.DS.RAComponents.parametercontrol]
    };

    /* DESCRIPTION:
 *
 * A parameter control is a list of one or more parameters corresponding to
 * parameters which are used by a chart. The parameter control can be used to
 * set, remove, or re-order parameters on the corresponding chart.
 *
 * Parameter controls should support parameter assignment (via drag and drop),
 * parameter removal (via click on an 'x' button), and parameter swapping, via
 * dragging one parameter on the parameter control onto another parameter on the
 * control.
 *
 * Parameter control have an ordered set of parameters, which can be
 * programatically set by a chart in order to keep the control parameters
 * current with chart parameters set through user interaction with the chart
 * itself. Parameter controls also provide a method for a chart to assign a
 * callback to the control, which will be executed when the set of parameters on
 * the control is changed via user interaction with the control.
 *
 */

    colorParameterControlPrototype.createdCallback = function() {
        // This element SHOULD NOT call ra-control's created callback.
        // The created callback for ra-control appends its template, and we want a
        // different  template for this element.
        GLOBAL.DS.RAComponents.parametercontrol.createdCallback.call(this);

        this.dataMaps = [];

        this.type = 'fixed';
        // sd4: this is the default color for the glyphs etc. Not sure why it is set
        // here
        // the color is the 3dd color
        this.fixedColor = '#005685';
        this.dataMap = null;
        this.linearMinValue = null;
        this.linearMaxValue = null;
        this.aggregationType = null;
        this.discreteValues = null;

        this.showAggregationType = true;

        this.setupFixedInput();
        this.setupSeriesSelect();
    };

    colorParameterControlPrototype.setupFixedInput = function() {
        var that = this;

        this.fixedInput = document.createElement('ra-textinputcontrol');
        this.fixedInput.setLabel('Fixed:');
        this.fixedInput.setValue(this.fixedColor);

        this.fixedInput.setUpdateCallback(function(value) {
            that.fixedColor = value;
            that.type = 'fixed';
            if (typeof that.changeListener === 'function') {
                that.changeListener(that.parameters);
            }
        });

        this.querySelector('.controlBody').appendChild(this.fixedInput);
    };

    colorParameterControlPrototype.setupSeriesSelect = function() {
        var that = this;

        this.seriesSelect = document.createElement('ra-selectcontrol');
        this.seriesSelect.setLabel('Series:');

        // Get colormaps from example library
        var colorMaps = GLOBAL.DS.RAObjects.dataMaps.linearColorMaps.concat(
            GLOBAL.DS.RAObjects.dataMaps.discreteColorMaps
        );

        for (var i = 0; i < colorMaps.length; i++) {
            var d = colorMaps[i];
            if (d.type === 'discrete') {
                this.seriesSelect.addOption(new Option(d.displayName, d.guid));
                this.dataMaps.push(d);
                if (
                    this.dataMaps.length == 1 ||
                    d.defaultCode === 'seriesColorMap'
                ) {
                    this.seriesSelect.setValue(d.guid);
                }
            }
        }

        this.seriesSelect.setValue(null);

        this.seriesSelect.setUpdateCallback(function(value) {
            that.dataMap = that.getSeriesDataMap(value);
            that.type = 'bySeries';
            if (typeof that.changeListener === 'function') {
                that.changeListener(that.parameters);
            }
        });

        this.querySelector('.controlBody').appendChild(this.seriesSelect);
    };

    colorParameterControlPrototype.getSeriesDataMap = function(value) {
        for (var i = 0; i < this.dataMaps.length; i++) {
            if (this.dataMaps[i].guid === value) {
                return this.dataMaps[i];
            }
        }
        return null;
    };

    colorParameterControlPrototype.setNoParamSelectVisible = function(value) {
        if (value === 'true') {
            this.seriesSelect.style.visibility = 'visible';
        } else {
            this.seriesSelect.style.visibility = 'hidden';
        }
    };

    colorParameterControlPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        if (typeof request !== 'undefined') {
            this.currentRequest = JSON.parse(JSON.stringify(request));
            if (
                typeof this.currentRequest.type !== 'undefined' &&
                this.currentRequest.type !== null
            ) {
                this.type = this.currentRequest.type;
            }
            if (
                typeof this.currentRequest.defaultColor !== 'undefined' &&
                this.currentRequest.defaultColor !== null
            ) {
                this.fixedInput.setValue(this.currentRequest.defaultColor);
                this.fixedColor = this.currentRequest.defaultColor;
            }
            if (
                typeof this.currentRequest.dataMap !== 'undefined' &&
                this.currentRequest.dataMap !== null
            ) {
                if (this.type === 'bySeries') {
                    this.seriesSelect.setValue(this.currentRequest.dataMap);
                }
                this.dataMap = this.currentRequest.dataMap;
            }
        } else {
            this.currentRequest = null;
        }
    };

    colorParameterControlPrototype.getType = function() {
        return this.type;
    };

    colorParameterControlPrototype.getFixedColor = function() {
        return this.fixedColor;
    };

    colorParameterControlPrototype.getDataMap = function() {
        return this.dataMap;
    };

    colorParameterControlPrototype.getLinearMinValue = function() {
        return this.linearMinValue;
    };

    colorParameterControlPrototype.getLinearMaxValue = function() {
        return this.linearMaxValue;
    };

    colorParameterControlPrototype.getAggregationType = function() {
        return this.aggregationType;
    };

    colorParameterControlPrototype.getDiscreteValues = function() {
        return this.discreteValues;
    };

    colorParameterControlPrototype.setShowAggregationType = function(value) {
        this.showAggregationType = value;
    };

    colorParameterControlPrototype.updateEntries = function(colorMap) {
        // Updates entries based on internal data.
        // d3.select(this).selectAll('.placeholderParam').remove();
        var that = this;

        var pces = d3.
            select(this.querySelector('.controlBody')).
            selectAll('ra-colorparamcontrolelement').
            data(this.parameters, function(d) {
                return d.id;
            });

        // Switch back to fixed color if no parameters
        if (this.parameters.length == 0) {
            this.type = 'fixed';
        }

        pces.exit().remove();
        pces.enter().append('ra-colorparamcontrolelement');

        pces.each(function(d) {
            this.setShowAggregationType(that.showAggregationType);
            this.setParameter(d);

            if (
                typeof that.defaultRequest !== 'undefined' &&
                that.defaultRequest !== null
            ) {
                this.setDefaultRequest(that.defaultRequest.data);
            }
            that.type = 'byData';
            if (colorMap) {
                that.dataMap = colorMap;
            } else {
                that.dataMap = this.getDataMap();
            }

            that.linearMinValue = this.getLinearMinValue();
            that.linearMaxValue = this.getLinearMaxValue();
            that.aggregationType = this.getAggregationType();
            that.discreteValues = this.getDiscreteValues();

            if (typeof d.paramDataClass !== 'undefined') {
                this.classList.add(d.paramDataClass);
            }

            if (d.isPlaceholderParam) {
                this.classList.add('placeholderParam');
            }

            this.setRemoveParameterCallback(function(param) {
                that.removeParameter(param);
                that.updateEntries();
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });
            this.setParameterChangeCallback(function(newParam, oldParam) {
                that.replaceParameter(newParam, oldParam);
                that.updateEntries();
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });

            this.setUpdateDataMapCallback(function(value) {
                that.dataMap = value;
                that.type = 'byData';
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });
            this.setUpdateLinearMinCallback(function(value) {
                if (parseFloat(value) < parseFloat(that.linearMaxValue)) {
                    that.linearMinValue = value;
                } else {
                    that.linearMinValue = that.linearMaxValue;
                    this.setMinValue(that.linearMaxValue);
                }
                that.type = 'byData';
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });
            this.setUpdateLinearMaxCallback(function(value) {
                if (parseFloat(value) > parseFloat(that.linearMinValue)) {
                    that.linearMaxValue = value;
                } else {
                    that.linearMaxValue = that.linearMinValue;
                    this.setMaxValue(that.linearMinValue);
                }
                that.type = 'byData';
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });
            this.setUpdateAggregationTypeCallback(function(value) {
                that.aggregationType = value;
                that.type = 'byData';
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });
            this.setUpdateDiscreteValuesCallback(function(value) {
                that.discreteValues = value;
                that.dataMap = this.getDataMap();
                that.type = 'byData';
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });
        });

        pces.exit().remove();
    };

    Polymer(colorParameterControlPrototype);
    GLOBAL.DS.RAComponents.colorparametercontrol = colorParameterControlPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
