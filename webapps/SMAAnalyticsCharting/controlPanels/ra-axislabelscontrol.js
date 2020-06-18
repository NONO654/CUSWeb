(function(GLOBAL, template) {
    var axisLabelsPrototype = { is: 'ra-axislabelscontrol', behaviors: [] };

    axisLabelsPrototype.createdCallback = function() {
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.defaultRequest = null;
        this.currentRequest = null;

        this.setupVisible();
        this.setupProperties();
    };

    axisLabelsPrototype.setupVisible = function() {
        var that = this;

        this.visibleInput = this.querySelector('.visible');
        this.visibleInput.setLabel('Visible');
        this.visibleInput.setCheck(true);

        this.visibleInput.setUpdateCallback(function(value) {
            that.setVisible(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    axisLabelsPrototype.setupProperties = function() {
        this.propertiesControl = this.querySelector('.properties');
        this.propertiesControl.setTitle('Properties');
    };

    axisLabelsPrototype.setUpdateCallback = function(fn) {
        this.updateCallback = fn;
        this.propertiesControl.setUpdateCallback(fn);
    };

    axisLabelsPrototype.getVisible = function() {
        return this.currentRequest.visible;
    };

    axisLabelsPrototype.setVisible = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.visible = value;
        this.visibleInput.setCheck(value);
    };

    axisLabelsPrototype.setTitle = function(value) {
        this.querySelector('.propertiesTitle').textContent = value;
    };

    axisLabelsPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        this.currentRequest = request;

        if (request !== null) {
            if (
                typeof request.visible !== 'undefined' &&
                request.visible !== null
            ) {
                this.setVisible(request.visible);
            }
            if (
                typeof request.properties !== 'undefined' &&
                request.properties !== null
            ) {
                this.propertiesControl.setDefaultRequest(request.properties);
            }
        }
    };

    axisLabelsPrototype.getRequest = function() {
        var req = this.propertiesControl.getRequest();
        if (req !== null) {
            if (this.currentRequest === null) {
                this.currentRequest = {};
            }
            this.currentRequest.properties = req;
        }

        return this.currentRequest;
    };

    Polymer(axisLabelsPrototype);
    GLOBAL.DS.RAComponents.axislabelscontrol = axisLabelsPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
