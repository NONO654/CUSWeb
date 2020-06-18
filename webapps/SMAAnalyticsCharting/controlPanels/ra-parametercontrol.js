(function(GLOBAL, template) {
    var parameterControlPrototype = {
        is: 'ra-parametercontrol',
        behaviors: [
            GLOBAL.DS.RAComponents.control,
            GLOBAL.DS.RAComponents.droptarget
        ]
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

    parameterControlPrototype.createdCallback = function() {
        // This element SHOULD NOT call ra-control's created callback.
        // The created callback for ra-control appends its template, and we want a
        // different  template for this element.
        GLOBAL.DS.RAComponents.droptarget.createdCallback.call(this);
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.setFilter();
        this.setDropListener();

        this.parameters = [];

        this.dragTargetText = 'Drag Parameter Here';
    };

    parameterControlPrototype.setDragTargetText = function(text) {
        this.dragTargetText = text;
    };

    parameterControlPrototype.setFilter = function(filterFn) {
        var dropFilter = function(data) {
            if (typeof filterFn !== 'undefined' && !filterFn(data)) {
                return false;
            }

            return true;
        };

        this.querySelector('.controlBody').setFilter(dropFilter);
    };

    parameterControlPrototype.setupData = function() {
        var addParamData = {
            displayName: 'Drag Parameter Here',
            paramDataClass: 'addParamData',
            isPlaceholderParam: true
        };

        var emptyParamData = {
            displayName: '',
            paramDataClass: 'emptyData',
            isPlaceholderParam: true
        };

        // Remove placeholder params
        /*this.parameters = this.parameters.filter(function(param){
        if(param.isPlaceholderParam){
            return false;
        }

        return true;
    });

    if(typeof this.nParams !== 'number'){
        this.parameters.push(addParamData);
    } else if(this.nParams < this.parameters.length) {
        this.parameters.push(addParamData);

        for(var i = this.parameters.length - 1; i < this.nParams; i++){
            this.parameters.push(emptyParamData);
        }
    }*/
    };

    parameterControlPrototype.setDropListener = function(listener) {
        var that = this;

        var dropListener = function(data) {
            var parameter = data.properties;

            that.addParameterControlEntry(parameter);

            if (typeof that.changeListener === 'function') {
                that.changeListener(that.parameters);
            }
        };

        this.querySelector('.controlBody').setDropListener(dropListener);
    };

    parameterControlPrototype.setFilter = function(filter) {
        this.filterFn = filter;

        this.querySelector('.controlBody').setFilter(filter);
    };

    parameterControlPrototype.updateController = function(params, data) {
        this.parameters = params;
        this.setupData();
        this.updateEntries(data);
    };

    parameterControlPrototype.replaceParameter = function(newParam, oldParam) {
        this.parameters.find(function(param, i, parameters) {
            if (param.id === oldParam.id) {
                parameters.splice(i, 1, newParam);
            }
        });
    };

    parameterControlPrototype.addParameterControlEntry = function(
        parameter,
        index
    ) {
        if (parameter.seriesColor === undefined && typeof this.parameterColorSelector === 'function' ) {
            parameter.seriesColor = this.parameterColorSelector(parameter.id);
        
        }
         
        if (typeof index !== 'undefined') {
            this.parameters.splice(index, 0, parameter);
        } else {
            if (this.parameters.length < this.nParams) {
                this.parameters.push(parameter);
            } else {
                // Replace last parameter
                this.parameters.splice(-1, 1, parameter);
            }
        }

        this.updateEntries();
    };

    parameterControlPrototype.setChangeListener = function(listener) {
        this.changeListener = listener;
    };

    parameterControlPrototype.setParameterColorSelector = function(selector) {
        this.parameterColorSelector = selector;
    };
    parameterControlPrototype.nParameters = function(nParams) {
        if (typeof nParams !== 'undefined') {
            this.nParams = nParams;
        }

        return nParams;
    };

    parameterControlPrototype.getNParameters = function() {
        return this.nParams;
    };

    parameterControlPrototype.removeParameter = function(param) {
        if (typeof param === 'string') {
            this.parameters = this.parameters.filter(function(p) {
                if (p.id === param) {
                    return false;
                }

                return true;
            });
        } else if (typeof param.id !== 'undefined') {
            this.parameters = this.parameters.filter(function(p) {
                if (p.id === param.id) {
                    return false;
                }

                return true;
            });
        }

        this.updateEntries();

        /*if(options && options.noUpdate){
        return;
    }

    if(typeof this.changeListener === 'function'){
        this.changeListener(this.parameters);
    }*/
    };

    Polymer(parameterControlPrototype);
    GLOBAL.DS.RAComponents.parametercontrol = parameterControlPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
