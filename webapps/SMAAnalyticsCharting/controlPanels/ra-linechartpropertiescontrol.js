(function(GLOBAL, template) {
    var lineChartPropertiesPrototype = {
        is: 'ra-linechartpropertiescontrol',
        behaviors: [GLOBAL.DS.RAComponents.control]
    };

    lineChartPropertiesPrototype.createdCallback = function() {
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.setupAreaOn();
        this.setupPointsOn();
        this.setupPassThroughCrossover();
        this.setupStaircaseStyle();
        this.setupLine();

        this.title('Line Chart');
    };

    lineChartPropertiesPrototype.setupAreaOn = function() {
        var that = this;

        this.areaOnInput = this.querySelector('.areaOn');
        this.areaOnInput.setLabel('Show Area');

        this.areaOnInput.setUpdateCallback(function(value) {
            that.setAreaOn(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    lineChartPropertiesPrototype.setupPointsOn = function() {
        var that = this;

        this.pointsOnInput = this.querySelector('.pointsOn');
        this.pointsOnInput.setLabel('Show Points');

        this.pointsOnInput.setUpdateCallback(function(value) {
            that.setPointsOn(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    lineChartPropertiesPrototype.setupPassThroughCrossover = function() {
        var that = this;

        this.passThroughCrossoverInput = this.querySelector(
            '.passThroughCrossover'
        );
        this.passThroughCrossoverInput.setLabel('Pass Through Crossover');

        this.passThroughCrossoverInput.setUpdateCallback(function(value) {
            that.setPassThroughCrossover(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    lineChartPropertiesPrototype.setupStaircaseStyle = function() {
        var that = this;

        this.staircaseStyleInput = this.querySelector('.staircaseStyle');
        this.staircaseStyleInput.setLabel('Staircase:');

        this.staircaseStyleInput.addOption(new Option('None', 'none'));
        this.staircaseStyleInput.setValue('none');
        this.staircaseStyleInput.addOption(new Option('Left', 'left'));
        this.staircaseStyleInput.addOption(new Option('Center', 'center'));
        this.staircaseStyleInput.addOption(new Option('Right', 'right'));

        this.staircaseStyleInput.setUpdateCallback(function(value) {
            that.setStaircaseStyle(value);
            if (typeof that.updateCallback === 'function') {
                that.updateCallback();
            }
        });
    };

    lineChartPropertiesPrototype.setupLine = function() {
        this.lineControl = this.querySelector('.line');
        this.lineControl.setTitle('Line');
    };

    lineChartPropertiesPrototype.setChangeListener = function(fn) {
        this.updateCallback = fn;
        this.lineControl.setUpdateCallback(fn);
    };

    lineChartPropertiesPrototype.getAreaOn = function() {
        return this.currentRequest.areaOn;
    };

    lineChartPropertiesPrototype.setAreaOn = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.areaOn = value;
        this.areaOnInput.setCheck(value);
    };

    lineChartPropertiesPrototype.getPointsOn = function() {
        return this.currentRequest.pointsOn;
    };

    lineChartPropertiesPrototype.setPointsOn = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.pointsOn = value;
        this.pointsOnInput.setCheck(value);
    };

    lineChartPropertiesPrototype.getPassThroughCrossover = function() {
        return this.currentRequest.passThroughCrossover;
    };

    lineChartPropertiesPrototype.setPassThroughCrossover = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.passThroughCrossover = value;
        this.passThroughCrossoverInput.setCheck(value);
    };

    lineChartPropertiesPrototype.getStaircaseStyle = function() {
        return this.currentRequest.staircaseStyle;
    };

    lineChartPropertiesPrototype.setStaircaseStyle = function(value) {
        if (this.currentRequest === null) {
            this.currentRequest = {};
        }
        this.currentRequest.staircaseStyle = value;
        this.staircaseStyleInput.setValue(value);
    };

    lineChartPropertiesPrototype.setDefaultRequest = function(request) {
        this.defaultRequest = request;
        if (typeof request !== 'undefined') {
            this.currentRequest = JSON.parse(JSON.stringify(request));
            if (
                typeof this.currentRequest.areaOn !== 'undefined' &&
                this.currentRequest.areaOn !== null
            ) {
                this.setAreaOn(this.currentRequest.areaOn);
            }
            if (
                typeof this.currentRequest.pointsOn !== 'undefined' &&
                this.currentRequest.pointsOn !== null
            ) {
                this.setPointsOn(this.currentRequest.pointsOn);
            }
            if (
                typeof this.currentRequest.passThroughCrossover !==
                    'undefined' &&
                this.currentRequest.passThroughCrossover !== null
            ) {
                this.setPassThroughCrossover(
                    this.currentRequest.passThroughCrossover
                );
            }
            if (
                typeof this.currentRequest.staircaseStyle !== 'undefined' &&
                this.currentRequest.staircaseStyle !== null
            ) {
                this.setStaircaseStyle(this.currentRequest.staircaseStyle);
            }
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

    lineChartPropertiesPrototype.getRequest = function() {
        var req = this.lineControl.getRequest();
        if (req !== null) {
            if (this.currentRequest === null) {
                this.currentRequest = {};
            }
            this.currentRequest.line = req;
        }

        return this.currentRequest;
    };

    Polymer(lineChartPropertiesPrototype);
    GLOBAL.DS.RAComponents.linechartpropertiescontrol = lineChartPropertiesPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
