(function(GLOBAL, template) {
    var spatialParameterControlPrototype = {
        is: 'ra-spatialparametercontrol',
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

    spatialParameterControlPrototype.createdCallback = function() {
        // This element SHOULD NOT call ra-control's created callback.
        // The created callback for ra-control appends its template, and we want a
        // different  template for this element.
        GLOBAL.DS.RAComponents.parametercontrol.createdCallback.call(this);

        this.axisProperties = null;
        this.axisMinMaxSlider = null;

        this.axisMinValue = null;
        this.axisMaxValue = null;
        this.paramMinValue = [];
        this.paramMaxValue = [];
        this.aggregationType = [];
        this.discreteValues = [];

        this.showParamFilter = true;
        this.showAggregationType = true;

        this.setupAxisProperties();
        
        //sd4: pipe the drop to the drop-target inside
        var that = this;
        this.addEventListener('drop', function(e) {
            var dt = that.querySelector('ra-droptarget');
            if(dt && dt.onDrop) {
            	dt.onDrop(e);
            }
            if(dt && dt.onDragLeave) {
            	dt.onDragLeave(e);
            }
        });
    };

    spatialParameterControlPrototype.setupAxisProperties = function() {
        var that = this;

        this.axisProperties = document.createElement(
            'ra-axispropertiescontrol'
        );
        this.querySelector('.controlBody').appendChild(this.axisProperties);

        this.axisProperties.setUpdateCallback(function() {
            if (typeof that.changeListener === 'function') {
                that.changeListener(that.parameters);
            }
        });
    };

    spatialParameterControlPrototype.setupAxisFilter = function() {
        var that = this;

        this.axisMinMaxSlider = document.createElement('ra-dualslidercontrol');
        this.axisMinMaxSlider.setLabel('Filter:');
        this.querySelector('.controlBody').appendChild(this.axisMinMaxSlider);

        this.axisMinValue = this.axisMinMaxSlider.getMinValue();
        this.axisMaxValue = this.axisMinMaxSlider.getMaxValue();

        this.axisMinMaxSlider.setUpdateMinCallback(function(value) {
            if (parseFloat(value) < parseFloat(that.axisMaxValue)) {
                that.axisMinValue = value;
            } else {
                that.axisMinValue = that.axisMaxValue;
                this.setMinValue(that.axisMaxValue);
            }
            if (typeof that.changeListener === 'function') {
                that.changeListener(that.parameters);
            }
        });
        this.axisMinMaxSlider.setUpdateMaxCallback(function(value) {
            if (parseFloat(value) > parseFloat(that.axisMinValue)) {
                that.axisMaxValue = value;
            } else {
                that.axisMaxValue = that.axisMinValue;
                this.setMaxValue(that.axisMinValue);
            }
            if (typeof that.changeListener === 'function') {
                that.changeListener(that.parameters);
            }
        });
    };

    spatialParameterControlPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        if (typeof request !== 'undefined') {
            this.currentRequest = JSON.parse(JSON.stringify(request));
            if (typeof this.currentRequest.axisProperties !== 'undefined') {
                this.axisProperties.setDefaultRequest(
                    this.currentRequest.axisProperties
                );
            }
        } else {
            this.currentRequest = null;
        }
    };

    spatialParameterControlPrototype.getAxisProperties = function() {
        return this.axisProperties.getRequest();
    };

    spatialParameterControlPrototype.isUserDefinedAxisTitleText = function() {
        return this.axisProperties.isUserDefinedTitleText();
    };

    spatialParameterControlPrototype.getAxisMinValue = function() {
        return this.axisMinValue;
    };

    spatialParameterControlPrototype.getAxisMaxValue = function() {
        return this.axisMaxValue;
    };

    spatialParameterControlPrototype.getLinearMinValue = function(index) {
        if (typeof index === 'undefined' || index === null) {
            index = 0;
        }
        return this.paramMinValue[index];
    };

    spatialParameterControlPrototype.getLinearMaxValue = function(index) {
        if (typeof index === 'undefined' || index === null) {
            index = 0;
        }
        return this.paramMaxValue[index];
    };

    spatialParameterControlPrototype.getAggregationType = function(index) {
        if (typeof index === 'undefined' || index === null) {
            index = 0;
        }
        return this.aggregationType[index];
    };

    spatialParameterControlPrototype.getDiscreteValues = function(index) {
        if (typeof index === 'undefined' || index === null) {
            index = 0;
        }
        return this.discreteValues[index];
    };

    spatialParameterControlPrototype.setShowAxisFilter = function(value) {
        if (value === true) {
            this.setupAxisFilter();
        }
    };

    spatialParameterControlPrototype.setShowParamFilter = function(value) {
        this.showParamFilter = value;
    };

    spatialParameterControlPrototype.setShowAggregationType = function(value) {
        this.showAggregationType = value;
    };

    spatialParameterControlPrototype.updateEntries = function() {
        // Updates entries based on internal data.
        // d3.select(this).selectAll('.placeholderParam').remove();
        var that = this;

        // If we haven't specified a user-defined title:
        // Set axis title to parameter name if only one parameter,
        // or blank if no parameters.
        if (this.axisProperties.isUserDefinedTitleText() === false) {
            if (this.parameters.length >= 1) {
                var paramDisplayName = this.parameters[0].displayName;
                
                 for (var i = 1; i < this.parameters.length; i++) {
                    paramDisplayName = paramDisplayName + ', ';
                    paramDisplayName = paramDisplayName +                    
                        this.parameters[i].displayName;
                }
                
                that.axisProperties.setTitleText(
                    decodeURIComponent(paramDisplayName)
                );
            } else if (this.parameters.length === 0) {
                that.axisProperties.setTitleText(null);
            }
        }

        var pces = d3.
            select(this.querySelector('.controlBody')).
            selectAll('ra-spatialparamcontrolelement').
            data(this.parameters, function(d) {
                return d.id;
            });
        pces.exit().remove();
        pces.enter().append('ra-spatialparamcontrolelement');

        pces.each(function(d, i) {
            this.setShowFilter(that.showParamFilter);
            this.setShowAggregationType(that.showAggregationType);
            this.setParameter(d);

            if (
                typeof that.defaultRequest !== 'undefined' &&
                that.defaultRequest !== null
            ) {
                if (typeof that.defaultRequest.data !== 'undefined') {
                    this.setDefaultRequest(that.defaultRequest.data);
                } else if (typeof that.defaultRequest.series !== 'undefined') {
                    this.setDefaultRequest(that.defaultRequest.series[0]);
                }
            }
            that.paramMinValue[i] = this.getLinearMinValue();
            that.paramMaxValue[i] = this.getLinearMaxValue();
            that.aggregationType[i] = this.getAggregationType();
            that.discreteValues[i] = this.getDiscreteValues();

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

            this.setUpdateLinearMinCallback(function(value) {
                if (parseFloat(value) < parseFloat(that.paramMaxValue[i])) {
                    that.paramMinValue[i] = value;
                } else {
                    that.paramMinValue[i] = that.paramMaxValue[i];
                    this.setMinValue(that.paramMaxValue[i]);
                }
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });
            this.setUpdateLinearMaxCallback(function(value) {
                if (parseFloat(value) > parseFloat(that.paramMinValue[i])) {
                    that.paramMaxValue[i] = value;
                } else {
                    that.paramMaxValue[i] = that.paramMinValue[i];
                    this.setMaxValue(that.paramMinValue[i]);
                }
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });

            this.setUpdateAggregationTypeCallback(function(value) {
                that.aggregationType[i] = value;
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });

            this.setUpdateDiscreteValuesCallback(function(value) {
                that.discreteValues[i] = value;
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });
        });

        pces.exit().remove();
    };

    Polymer(spatialParameterControlPrototype);
    GLOBAL.DS.RAComponents.spatialparametercontrol = spatialParameterControlPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
