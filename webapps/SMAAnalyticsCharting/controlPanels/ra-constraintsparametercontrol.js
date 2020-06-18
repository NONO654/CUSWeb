(function(GLOBAL, template) {
    var constraintsParameterControlPrototype = {
        is: 'ra-constraintsparametercontrol',
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

    constraintsParameterControlPrototype.createdCallback = function() {
        // This element SHOULD NOT call ra-control's created callback.
        // The created callback for ra-control appends its template, and we want a
        // different  template for this element.
        GLOBAL.DS.RAComponents.parametercontrol.createdCallback.call(this);

        this.defaultRequest = null;
        this.currentRequest = null;
    };

    constraintsParameterControlPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        if (typeof request !== 'undefined') {
            this.currentRequest = JSON.parse(JSON.stringify(request));
        } else {
            this.currentRequest = null;
        }
    };

    constraintsParameterControlPrototype.updateEntries = function() {
        // Updates entries based on internal data.
        // d3.select(this).selectAll('.placeholderParam').remove();
        var that = this;

        var pces = d3.
            select(this.querySelector('.controlBody')).
            selectAll('ra-constraintsparamcontrolelement').
            data(this.parameters, function(d) {
                return d.id;
            });

        pces.exit().remove();
        pces.enter().append('ra-constraintsparamcontrolelement');

        pces.each(function(d) {
            this.setParameter(d);
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
                if (typeof that.changeListener === 'function') {
                    that.changeListener(that.parameters);
                }
            });
        });

        pces.exit().remove();
    };

    Polymer(constraintsParameterControlPrototype);
    GLOBAL.DS.RAComponents.constraintsparametercontrol = constraintsParameterControlPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
