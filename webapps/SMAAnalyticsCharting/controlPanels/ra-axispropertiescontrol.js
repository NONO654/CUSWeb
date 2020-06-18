(function(GLOBAL, template) {
    var axisPropertiesPrototype = {
        is: 'ra-axispropertiescontrol',
        behaviors: [GLOBAL.DS.RAComponents.control]
    };

    axisPropertiesPrototype.createdCallback = function() {
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.defaultRequest = null;
        this.currentRequest = null;

        this.title('Properties');

        this.setupTitle();
        this.setupUnit();
        this.setupLogInput();
        this.setupAxle();
        this.setupMajorTickMarks();
        this.setupMinorTickMarks();
        this.setupMajorTickLines();
        this.setupMinorTickLines();
        this.setupAxisLabels();
    };

    axisPropertiesPrototype.setupTitle = function() {
        this.titleControl = this.querySelector('.title');
        this.titleControl.setTitle('Title');
    };

    axisPropertiesPrototype.setupUnit = function() {
        this.unitControl = this.querySelector('.unit');
        this.unitControl.setTitle('Unit');
    };

    axisPropertiesPrototype.setupLogInput = function() {
        var that = this;

        this.logInput = this.querySelector('.logarithmic');
        this.logInput.setLabel('Log');

        this.logInput.setUpdateCallback(function(value) {
            that.setLog(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    axisPropertiesPrototype.setupAxle = function() {
        this.axleControl = this.querySelector('.axle');
        this.axleControl.setTitle('Axle');
    };

    axisPropertiesPrototype.setupMajorTickMarks = function() {
        this.majorTickMarksControl = this.querySelector('.majorTickMarks');
        this.majorTickMarksControl.setTitle('Major Tick Marks');
    };

    axisPropertiesPrototype.setupMinorTickMarks = function() {
        this.minorTickMarksControl = this.querySelector('.minorTickMarks');
        this.minorTickMarksControl.setTitle('Minor Tick Marks');
    };

    axisPropertiesPrototype.setupMajorTickLines = function() {
        this.majorTickLinesControl = this.querySelector('.majorTickLines');
        this.majorTickLinesControl.setTitle('Major Tick Lines');
    };

    axisPropertiesPrototype.setupMinorTickLines = function() {
        this.minorTickLinesControl = this.querySelector('.minorTickLines');
        this.minorTickLinesControl.setTitle('Minor Tick Lines');
    };

    axisPropertiesPrototype.setupAxisLabels = function() {
        this.axisLabelsControl = this.querySelector('.labels');
        this.axisLabelsControl.setTitle('Labels');
    };

    axisPropertiesPrototype.setUpdateCallback = function(fn) {
        this.updateCallback = fn;
        this.titleControl.setUpdateCallback(fn);
        this.unitControl.setUpdateCallback(fn);
        this.axleControl.setUpdateCallback(fn);
        this.majorTickMarksControl.setUpdateCallback(fn);
        this.minorTickMarksControl.setUpdateCallback(fn);
        this.majorTickLinesControl.setUpdateCallback(fn);
        this.minorTickLinesControl.setUpdateCallback(fn);
        this.axisLabelsControl.setUpdateCallback(fn);
    };

    axisPropertiesPrototype.isUserDefinedTitleText = function() {
        return this.titleControl.isUserDefinedText();
    };

    axisPropertiesPrototype.getTitleText = function() {
        return this.titleControl.getText();
    };

    axisPropertiesPrototype.setTitleText = function(value) {
        this.titleControl.setText(value);
    };

    axisPropertiesPrototype.setLog = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.logarithmic = value;
        this.logInput.setCheck(value);
    };

    axisPropertiesPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        this.currentRequest = request;

        if (request !== null) {
            if (
                typeof request.title !== 'undefined' &&
                request.title !== null
            ) {
                this.titleControl.setDefaultRequest(request.title);
            }
            if (typeof request.unit !== 'undefined' && request.unit !== null) {
                this.unitControl.setDefaultRequest(request.unit);
            }
            if (
                typeof request.logarithmic !== 'undefined' &&
                request.logarithmic !== null
            ) {
                this.setLog(request.logarithmic);
            }
            if (typeof request.axle !== 'undefined' && request.axle !== null) {
                this.axleControl.setDefaultRequest(request.axle);
            }
            if (
                typeof request.majorTickMarks !== 'undefined' &&
                request.majorTickMarks !== null
            ) {
                this.majorTickMarksControl.setDefaultRequest(
                    request.majorTickMarks
                );
            }
            if (
                typeof request.minorTickMarks !== 'undefined' &&
                request.minorTickMarks !== null
            ) {
                this.minorTickMarksControl.setDefaultRequest(
                    request.minorTickMarks
                );
            }
            if (
                typeof request.majorTickLines !== 'undefined' &&
                request.majorTickLines !== null
            ) {
                this.majorTickLinesControl.setDefaultRequest(
                    request.majorTickLines
                );
            }
            if (
                typeof request.minorTickLines !== 'undefined' &&
                request.minorTickLines !== null
            ) {
                this.minorTickLinesControl.setDefaultRequest(
                    request.minorTickLines
                );
            }
            if (
                typeof request.labels !== 'undefined' &&
                request.labels !== null
            ) {
                this.axisLabelsControl.setDefaultRequest(request.labels);
            }
        }
    };

    axisPropertiesPrototype.getRequest = function() {
        var req = this.titleControl.getRequest();
        if (req !== null) {
            if (this.currentRequest === null) {
                this.currentRequest = {};
            }
            this.currentRequest.title = req;
        }

        req = this.unitControl.getRequest();
        if (req !== null) {
            if (this.currentRequest === null) {
                this.currentRequest = {};
            }
            this.currentRequest.unit = req;
        }

        req = this.axleControl.getRequest();
        if (req !== null) {
            if (this.currentRequest === null) {
                this.currentRequest = {};
            }
            this.currentRequest.axle = req;
        }

        req = this.majorTickMarksControl.getRequest();
        if (req !== null) {
            if (this.currentRequest === null) {
                this.currentRequest = {};
            }
            this.currentRequest.majorTickMarks = req;
        }

        req = this.minorTickMarksControl.getRequest();
        if (req !== null) {
            if (this.currentRequest === null) {
                this.currentRequest = {};
            }
            this.currentRequest.minorTickMarks = req;
        }

        req = this.majorTickLinesControl.getRequest();
        if (req !== null) {
            if (this.currentRequest === null) {
                this.currentRequest = {};
            }
            this.currentRequest.majorTickLines = req;
        }

        req = this.minorTickLinesControl.getRequest();
        if (req !== null) {
            if (this.currentRequest === null) {
                this.currentRequest = {};
            }
            this.currentRequest.minorTickLines = req;
        }

        req = this.axisLabelsControl.getRequest();
        if (req !== null) {
            if (this.currentRequest === null) {
                this.currentRequest = {};
            }
            this.currentRequest.labels = req;
        }

        return this.currentRequest;
    };

    Polymer(axisPropertiesPrototype);
    GLOBAL.DS.RAComponents.axispropertiescontrol = axisPropertiesPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
