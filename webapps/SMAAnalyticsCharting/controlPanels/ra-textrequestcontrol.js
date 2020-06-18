(function(GLOBAL, template) {
    var textRequestPrototype = {
        is: 'ra-textrequestcontrol',
        behaviors: [GLOBAL.DS.RAComponents.control]
    };

    textRequestPrototype.createdCallback = function() {
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.defaultRequest = null;
        this.currentRequest = null;

        this.userDefinedText = false;

        this.setupText();
        this.setupProperties();
    };

    textRequestPrototype.setupText = function() {
        var that = this;

        this.textInput = this.querySelector('.text');
        this.textInput.setLabel('Text:');

        this.textInput.setUpdateCallback(function(value) {
            that.userDefinedText = true;
            that.setText(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    textRequestPrototype.setupProperties = function() {
        this.propertiesControl = this.querySelector('.properties');
        this.propertiesControl.setTitle('Properties');
    };

    textRequestPrototype.setUpdateCallback = function(fn) {
        this.updateCallback = fn;
        this.propertiesControl.setUpdateCallback(fn);
    };

    textRequestPrototype.getText = function() {
        return this.currentRequest.text;
    };

    textRequestPrototype.setText = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.text = value;
        this.textInput.setValue(value);
    };

    textRequestPrototype.setTitle = function(value) {
        // Inherits the title method from ra-control

        this.title(value);
    };

    textRequestPrototype.isUserDefinedText = function() {
        return this.userDefinedText;
    };

    textRequestPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        this.currentRequest = request;

        if (request !== null) {
            if (typeof request.text !== 'undefined' && request.text !== null) {
                this.userDefinedText = true;
                this.setText(request.text);
            }
            if (
                typeof request.properties !== 'undefined' &&
                request.properties !== null
            ) {
                this.propertiesControl.setDefaultRequest(request.properties);
            }
        }
    };

    textRequestPrototype.getRequest = function() {
        var req = this.propertiesControl.getRequest();
        if (req !== null) {
            if (this.currentRequest === null) {
                this.currentRequest = {};
            }
            this.currentRequest.properties = req;
        }

        return this.currentRequest;
    };

    Polymer(textRequestPrototype);
    GLOBAL.DS.RAComponents.textrequestcontrol = textRequestPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
