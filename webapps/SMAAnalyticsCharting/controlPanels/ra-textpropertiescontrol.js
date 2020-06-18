(function(GLOBAL, template) {
    var textPropertiesPrototype = {
        is: 'ra-textpropertiescontrol',
        behaviors: [GLOBAL.DS.RAComponents.control]
    };

    textPropertiesPrototype.createdCallback = function() {
        var that = this;

        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.defaultRequest = null;
        this.currentRequest = null;

        this.setupColor();
        this.setupAngle();
        this.setupSize();
        this.setupFontFamily();
        this.setupFontStyle();
        this.setupFontWeight();
        this.setupJustification();
        this.setupHorizontalAlignment();
        this.setupVerticalAlignment();
    };

    textPropertiesPrototype.setupColor = function() {
        var that = this;

        this.colorInput = this.querySelector('.color');
        this.colorInput.setLabel('Color:');
        this.colorInput.setValue('#000000');

        this.colorInput.setUpdateCallback(function(value) {
            that.setColor(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    textPropertiesPrototype.setupAngle = function() {
        var that = this;

        this.angleInput = this.querySelector('.angle');
        this.angleInput.setLabel('Angle:');
        this.angleInput.setMinLimit(-180);
        this.angleInput.setMaxLimit(180);
        this.angleInput.setValue(0);

        this.angleInput.setUpdateCallback(function(value) {
            that.setAngle(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    textPropertiesPrototype.setupSize = function() {
        var that = this;

        this.sizeInput = this.querySelector('.size');
        this.sizeInput.setLabel('Size:');
        this.sizeInput.setMinLimit(8);
        this.sizeInput.setMaxLimit(72);
        this.sizeInput.setValue(12);

        this.sizeInput.setUpdateCallback(function(value) {
            that.setSize(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    textPropertiesPrototype.setupFontFamily = function() {
        var that = this;

        this.fontFamilyInput = this.querySelector('.fontFamily');
        this.fontFamilyInput.setLabel('Font:');

        this.fontFamilyInput.setUpdateCallback(function(value) {
            that.setFontFamily(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    textPropertiesPrototype.setupFontStyle = function() {
        var that = this;

        this.fontStyleInput = this.querySelector('.fontStyle');
        this.fontStyleInput.setLabel('Style:');

        this.fontStyleInput.addOption(new Option('Normal', 'normal'));
        this.fontStyleInput.setValue('normal');
        this.fontStyleInput.addOption(new Option('Italic', 'italic'));

        this.fontStyleInput.setUpdateCallback(function(value) {
            that.setFontStyle(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    textPropertiesPrototype.setupFontWeight = function() {
        var that = this;

        this.fontWeightInput = this.querySelector('.fontWeight');
        this.fontWeightInput.setLabel('Weight:');

        this.fontWeightInput.addOption(new Option('Normal', 'normal'));
        this.fontWeightInput.setValue('normal');
        this.fontWeightInput.addOption(new Option('Bold', 'bold'));

        this.fontWeightInput.setUpdateCallback(function(value) {
            that.setFontWeight(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    textPropertiesPrototype.setupJustification = function() {
        var that = this;

        this.justificationInput = this.querySelector('.justification');
        this.justificationInput.setLabel('Justify:');

        this.justificationInput.addOption(new Option('Start', 'start'));
        this.justificationInput.addOption(new Option('Middle', 'middle'));
        this.justificationInput.addOption(new Option('End', 'end'));
        this.justificationInput.setValue('end');

        this.justificationInput.setUpdateCallback(function(value) {
            that.setJustification(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    textPropertiesPrototype.setupHorizontalAlignment = function() {
        var that = this;

        this.horizontalAlignmentInput = this.querySelector(
            '.horizontalAlignment'
        );
        this.horizontalAlignmentInput.setLabel('HAlign:');

        this.horizontalAlignmentInput.addOption(new Option('Left', 'left'));
        this.horizontalAlignmentInput.addOption(new Option('Center', 'center'));
        this.horizontalAlignmentInput.setValue('center');
        this.horizontalAlignmentInput.addOption(new Option('Right', 'right'));

        this.horizontalAlignmentInput.setUpdateCallback(function(value) {
            that.setHorizontalAlignment(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    textPropertiesPrototype.setupVerticalAlignment = function() {
        var that = this;

        this.verticalAlignmentInput = this.querySelector('.verticalAlignment');
        this.verticalAlignmentInput.setLabel('VAlign:');

        this.verticalAlignmentInput.addOption(new Option('Top', 'top'));
        this.verticalAlignmentInput.addOption(new Option('Middle', 'middle'));
        this.verticalAlignmentInput.setValue('middle');
        this.verticalAlignmentInput.addOption(new Option('Bottom', 'bottom'));
        this.verticalAlignmentInput.addOption(
            new Option('Baseline', 'baseline')
        );

        this.verticalAlignmentInput.setUpdateCallback(function(value) {
            that.setVerticalAlignment(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    textPropertiesPrototype.setUpdateCallback = function(fn) {
        this.updateCallback = fn;
    };

    textPropertiesPrototype.getColor = function() {
        return this.currentRequest.color;
    };

    textPropertiesPrototype.setColor = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.color = value;
        this.colorInput.setValue(value);
    };

    textPropertiesPrototype.getAngle = function() {
        return this.currentRequest.angle;
    };

    textPropertiesPrototype.setAngle = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.angle = value;
        this.angleInput.setValue(value);
    };

    textPropertiesPrototype.getSize = function() {
        return this.currentRequest.size;
    };

    textPropertiesPrototype.setSize = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.size = value;
        this.sizeInput.setValue(value);
    };

    textPropertiesPrototype.getFontFamily = function() {
        return this.currentRequest.fontFamily;
    };

    textPropertiesPrototype.setFontFamily = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.fontFamily = value;
        this.fontFamilyInput.setValue(value);
    };

    textPropertiesPrototype.getFontStyle = function() {
        return this.currentRequest.fontStyle;
    };

    textPropertiesPrototype.setFontStyle = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.fontStyle = value;
        this.fontStyleInput.setValue(value);
    };

    textPropertiesPrototype.getFontWeight = function() {
        return this.currentRequest.fontWeight;
    };

    textPropertiesPrototype.setFontWeight = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.fontWeight = value;
        this.fontWeightInput.setValue(value);
    };

    textPropertiesPrototype.getJustification = function() {
        return this.currentRequest.justification;
    };

    textPropertiesPrototype.setJustification = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.justification = value;
        this.justificationInput.setValue(value);
    };

    textPropertiesPrototype.getHorizontalAlignment = function() {
        return this.currentRequest.horizontalAlignment;
    };

    textPropertiesPrototype.setHorizontalAlignment = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.horizontalAlignment = value;
        this.horizontalAlignmentInput.setValue(value);
    };

    textPropertiesPrototype.getVerticalAlignment = function() {
        return this.currentRequest.verticalAlignment;
    };

    textPropertiesPrototype.setVerticalAlignment = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.verticalAlignment = value;
        this.verticalAlignmentInput.setValue(value);
    };

    textPropertiesPrototype.setTitle = function(value) {
        this.title(value);
    };

    textPropertiesPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        this.currentRequest = request;

        if (request !== null) {
            if (
                typeof request.color !== 'undefined' &&
                request.color !== null
            ) {
                this.setColor(request.color);
            }
            if (
                typeof request.angle !== 'undefined' &&
                request.angle !== null
            ) {
                this.setAngle(request.angle);
            }
            if (typeof request.size !== 'undefined' && request.size !== null) {
                this.setSize(request.size);
            }
            if (
                typeof request.fontFamily !== 'undefined' &&
                request.fontFamily !== null
            ) {
                this.setFontFamily(request.fontFamily);
            }
            if (
                typeof request.fontStyle !== 'undefined' &&
                request.fontStyle !== null
            ) {
                this.setFontStyle(request.fontStyle);
            }
            if (
                typeof request.fontWeight !== 'undefined' &&
                request.fontWeight !== null
            ) {
                this.setFontWeight(request.fontWeight);
            }
            if (
                typeof request.justification !== 'undefined' &&
                request.justification !== null
            ) {
                this.setJustification(request.justification);
            }
            if (
                typeof request.horizontalAlignment !== 'undefined' &&
                request.horizontalAlignment !== null
            ) {
                this.setHorizontalAlignment(request.horizontalAlignment);
            }
            if (
                typeof request.verticalAlignment !== 'undefined' &&
                request.verticalAlignment !== null
            ) {
                this.setVerticalAlignment(request.verticalAlignment);
            }
        }
    };

    textPropertiesPrototype.getRequest = function() {
        return this.currentRequest;
    };

    Polymer(textPropertiesPrototype);
    GLOBAL.DS.RAComponents.textpropertiescontrol = textPropertiesPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
