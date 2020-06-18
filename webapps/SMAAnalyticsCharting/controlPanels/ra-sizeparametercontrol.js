(function(GLOBAL, template) {
    var sizeParameterControlPrototype = {
        is: 'ra-sizeparametercontrol',
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

    sizeParameterControlPrototype.createdCallback = function() {
        // This element SHOULD NOT call ra-control's created callback.
        // The created callback for ra-control appends its template, and we want a
        // different  template for this element.
        GLOBAL.DS.RAComponents.parametercontrol.createdCallback.call(this);

        this.scaleSlider = null;

        this.dataMap = null;
        this.linearMinValue = null;
        this.linearMaxValue = null;
        this.aggregationType = null;
        // sd4: this value overrides the one that is set in
        // ChartSizeRequest.properties file
        this.linearScaleValue = 10;

        this.showAggregationType = true;

        this.setupScaleSlider();
    };

    sizeParameterControlPrototype.setupScaleSlider = function() {
        var that = this;

        this.scaleSlider = document.createElement('ra-slidercontrol');
        this.scaleSlider.setLabel('Scale:');
        this.scaleSlider.setMinLimit(1);
        this.scaleSlider.setMaxLimit(10);
        this.scaleSlider.setValue(this.linearScaleValue);

        this.scaleSlider.setUpdateCallback(function(value) {
            that.linearScaleValue = value;
            if (typeof that.changeListener === 'function') {
                that.changeListener(that.parameters);
            }
        });

        this.querySelector('.controlBody').appendChild(this.scaleSlider);
    };

    sizeParameterControlPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        if (typeof request !== 'undefined') {
            this.currentRequest = JSON.parse(JSON.stringify(request));
            if (
                typeof this.currentRequest.baseSize !== 'undefined' &&
                this.currentRequest.baseSize !== null
            ) {
                this.scaleSlider.setValue(this.currentRequest.baseSize);
                this.linearScaleValue = this.currentRequest.baseSize;
            }
        } else {
            this.currentRequest = null;
        }
    };

    sizeParameterControlPrototype.getDataMap = function() {
        return this.dataMap;
    };

    sizeParameterControlPrototype.getLinearMinValue = function() {
        return this.linearMinValue;
    };

    sizeParameterControlPrototype.getLinearMaxValue = function() {
        return this.linearMaxValue;
    };

    sizeParameterControlPrototype.getAggregationType = function() {
        return this.aggregationType;
    };

    sizeParameterControlPrototype.getLinearScaleValue = function() {
        return this.linearScaleValue;
    };

    sizeParameterControlPrototype.setShowAggregationType = function(value) {
        this.showAggregationType = value;
    };

    sizeParameterControlPrototype.updateEntries = function() {
        // Updates entries based on internal data.
        // d3.select(this).selectAll('.placeholderParam').remove();
        var that = this;

        var pces = d3.
            select(this.querySelector('.controlBody')).
            selectAll('ra-sizeparamcontrolelement').
            data(this.parameters, function(d) {
                return d.id;
            });
        pces.exit().remove();
        pces.enter().append('ra-sizeparamcontrolelement');

        pces.each(function(d) {
            this.setShowAggregationType(that.showAggregationType);
            this.setParameter(d);

            if (
                typeof that.defaultRequest !== 'undefined' &&
                that.defaultRequest !== null
            ) {
                this.setDefaultRequest(that.defaultRequest.data);
            }
            that.dataMap = this.getDataMap();
            that.linearMinValue = this.getLinearMinValue();
            that.linearMaxValue = this.getLinearMaxValue();
            that.aggregationType = this.getAggregationType();

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
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });
            this.setUpdateAggregationTypeCallback(function(value) {
                that.aggregationType = value;
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });
        });

        pces.exit().remove();
    };

    Polymer(sizeParameterControlPrototype);
    GLOBAL.DS.RAComponents.sizeparametercontrol = sizeParameterControlPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
