(function(GLOBAL, template) {
    var scatterChartPropertiesPrototype = {
        is: 'ra-scatterchartpropertiescontrol',
        behaviors: [GLOBAL.DS.RAComponents.control]
    };

    scatterChartPropertiesPrototype.createdCallback = function() {
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.setupLine();

        this.title('Scatter Chart');
    };

    scatterChartPropertiesPrototype.setupLine = function() {
        this.lineControl = this.querySelector('.line');
        this.lineControl.setTitle('Line');
    };

    scatterChartPropertiesPrototype.setChangeListener = function(fn) {
        this.updateCallback = fn;
        this.lineControl.setUpdateCallback(fn);
    };

    scatterChartPropertiesPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        if (typeof request !== 'undefined') {
            this.currentRequest = JSON.parse(JSON.stringify(request));
            if (
                typeof this.currentRequest.line !== 'undefined' &&
                this.currentRequest.line !== null
            ) {
                this.lineControl.setDefaultRequest(this.currentRequest.line);
            }
        } else {
            this.currentRequest = null;
        }
    };

    scatterChartPropertiesPrototype.getRequest = function() {
        var req = this.lineControl.getRequest();
        if (req !== null) {
            if (this.currentRequest === null) {
                this.currentRequest = {};
            }
            this.currentRequest.line = req;
        }

        return this.currentRequest;
    };

    Polymer(scatterChartPropertiesPrototype);
    GLOBAL.DS.RAComponents.scatterchartpropertiescontrol = scatterChartPropertiesPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
