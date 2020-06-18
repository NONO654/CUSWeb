(function(GLOBAL, template) {
    var axisTickMarkPrototype = { is: 'ra-axistickmarkcontrol', behaviors: [] };

    axisTickMarkPrototype.createdCallback = function() {
        var that = this;

        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.defaultRequest = null;
        this.currentRequest = null;

        this.setupVisible();
        this.setupColor();
        this.setupFrequency();
        this.setupWidth();
        this.setupLength();
        this.setupClearance();
        this.setupStyle();
    };

    axisTickMarkPrototype.setupVisible = function() {
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

    axisTickMarkPrototype.setupColor = function() {
        var that = this;

        this.colorInput = this.querySelector('.color');
        this.colorInput.setLabel('Color:');

        this.colorInput.setUpdateCallback(function(value) {
            that.setColor(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    axisTickMarkPrototype.setupFrequency = function() {
        var that = this;

        this.frequencyInput = this.querySelector('.frequency');
        this.frequencyInput.setLabel('Freq:');
        this.frequencyInput.setMinLimit(0);
        this.frequencyInput.setMaxLimit(10);
        this.frequencyInput.setValue(1);

        this.frequencyInput.setUpdateCallback(function(value) {
            that.setFrequency(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    axisTickMarkPrototype.setupWidth = function() {
        var that = this;

        this.widthInput = this.querySelector('.width');
        this.widthInput.setLabel('Width:');
        this.widthInput.setMinLimit(0);
        this.widthInput.setMaxLimit(5);
        this.widthInput.setValue(1);

        this.widthInput.setUpdateCallback(function(value) {
            that.setWidth(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    axisTickMarkPrototype.setupLength = function() {
        var that = this;

        this.lengthInput = this.querySelector('.length');
        this.lengthInput.setLabel('Length:');
        this.lengthInput.setMinLimit(0);
        this.lengthInput.setMaxLimit(20);
        this.lengthInput.setValue(5);

        this.lengthInput.setUpdateCallback(function(value) {
            that.setLength(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    axisTickMarkPrototype.setupClearance = function() {
        var that = this;

        this.clearanceInput = this.querySelector('.clearance');
        this.clearanceInput.setLabel('Clearance:');
        this.clearanceInput.setMinLimit(0);
        this.clearanceInput.setMaxLimit(10);
        this.clearanceInput.setValue(5);

        this.clearanceInput.setUpdateCallback(function(value) {
            that.setClearance(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    axisTickMarkPrototype.setupStyle = function() {
        var that = this;

        this.styleInput = this.querySelector('.style');
        this.styleInput.setLabel('Style:');

        this.styleInput.addOption(new Option('Solid', 'solid'));
        this.styleInput.setValue('solid');
        this.styleInput.addOption(new Option('Dash', 'dash'));
        this.styleInput.addOption(new Option('Dot', 'dot'));
        this.styleInput.addOption(new Option('Dash-dot', 'dashdot'));

        this.styleInput.setUpdateCallback(function(value) {
            that.setStyle(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    axisTickMarkPrototype.setUpdateCallback = function(fn) {
        this.updateCallback = fn;
    };

    axisTickMarkPrototype.getVisible = function() {
        return this.currentRequest.visible;
    };

    axisTickMarkPrototype.setVisible = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.visible = value;
        this.visibleInput.setCheck(value);
    };

    axisTickMarkPrototype.getColor = function() {
        return this.currentRequest.color;
    };

    axisTickMarkPrototype.setColor = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.color = value;
        this.colorInput.setValue(value);
    };

    axisTickMarkPrototype.getFrequency = function() {
        return this.currentRequest.frequency;
    };

    axisTickMarkPrototype.setFrequency = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.frequency = value;
        this.frequencyInput.setValue(value);
    };

    axisTickMarkPrototype.getWidth = function() {
        return this.currentRequest.width;
    };

    axisTickMarkPrototype.setWidth = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.width = value;
        this.widthInput.setValue(value);
    };

    axisTickMarkPrototype.getLength = function() {
        return this.currentRequest.length;
    };

    axisTickMarkPrototype.setLength = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.length = value;
        this.lengthInput.setValue(value);
    };

    axisTickMarkPrototype.getClearance = function() {
        return this.currentRequest.clearance;
    };

    axisTickMarkPrototype.setClearance = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.clearance = value;
        this.clearanceInput.setValue(value);
    };

    axisTickMarkPrototype.getStyle = function() {
        return this.currentRequest.style;
    };

    axisTickMarkPrototype.setStyle = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.style = value;
        this.styleInput.setValue(value);
    };

    axisTickMarkPrototype.setTitle = function(value) {
        this.querySelector('.propertiesTitle').textContent = value;
    };

    axisTickMarkPrototype.setDefaultRequest = function(request) {
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
                typeof request.color !== 'undefined' &&
                request.color !== null
            ) {
                this.setColor(request.color);
            }
            if (
                typeof request.frequency !== 'undefined' &&
                request.frequency !== null
            ) {
                this.setFrequency(request.frequency);
            }
            if (
                typeof request.width !== 'undefined' &&
                request.width !== null
            ) {
                this.setWidth(request.width);
            }
            if (
                typeof request.length !== 'undefined' &&
                request.length !== null
            ) {
                this.setLength(request.length);
            }
            if (
                typeof request.clearance !== 'undefined' &&
                request.clearance !== null
            ) {
                this.setClearance(request.clearance);
            }
            if (
                typeof request.style !== 'undefined' &&
                request.style !== null
            ) {
                this.setStyle(request.style);
            }
        }
    };

    axisTickMarkPrototype.getRequest = function() {
        return this.currentRequest;
    };

    Polymer(axisTickMarkPrototype);
    GLOBAL.DS.RAComponents.axistickmarkcontrol = axisTickMarkPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
