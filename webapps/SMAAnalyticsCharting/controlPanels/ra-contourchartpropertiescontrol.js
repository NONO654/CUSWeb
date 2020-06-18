/**
 * This is a copy of ra-scatterchartpropertiescontrol
 * @author sd4
 * I have removed all "line" controls
 */
(function(GLOBAL, template) {
    var contourChartPropertiesPrototype = {
        is: 'ra-contourchartpropertiescontrol',
        behaviors: [GLOBAL.DS.RAComponents.control]
    };

    contourChartPropertiesPrototype.createdCallback = function() {
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);
    };

    contourChartPropertiesPrototype.setChangeListener = function(fn) {
        this.updateCallback = fn;
    };

    contourChartPropertiesPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        if (typeof request !== 'undefined') {
            this.currentRequest = JSON.parse(JSON.stringify(request));

       } else {
            this.currentRequest = null;
        }
    };
    contourChartPropertiesPrototype.setApproximation = function(approxId) {
        this.querySelector("input").value = approxId;
    };
    contourChartPropertiesPrototype.getRequest = function() {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        try{
            this.currentRequest.approximation = this.currentRequest.approximation || {};
            this.currentRequest.approximation.approxId =  this.querySelector("input").value;
        } catch (e) {
            console.log(e)
        }
        return this.currentRequest;
    };

    Polymer(contourChartPropertiesPrototype);
    GLOBAL.DS.RAComponents.contourchartpropertiescontrol = contourChartPropertiesPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
