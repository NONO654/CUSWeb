(function(GLOBAL) {
    // This contains a prototype for a generic axis.

    var axisPrototype = {
        is: 'ra-axis',
        behaviors: [GLOBAL.DS.RAComponents.droptarget] // Axis is a drop zone.
    };

    // Attributes 'orient' : ['left', 'right', 'top', 'bottom']

    axisPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.droptarget.createdCallback.call(this);

        this.svgs = {
            rootSvg: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'svg'
            )
        };
        this.svgs.rootSvg.classList.add('ra-axisElement-rootSvg');

        this.svgs.axis = d3.select(this.svgs.rootSvg).append('g');

        this.settings = {
            orient: 'bottom' // Default setting to make sure nothing breaks if it's
            // not here.
        };
        this.state = { rendered: false };

        this.dimensions = { height: 100, width: 100 };

        this.placeholderDiv = document.createElement('div');
        this.placeholderDiv.classList.add('ra-axis-placeholderDiv');
        this.placeholderText = document.createElement('span');
        this.placeholderDiv.appendChild(this.placeholderText);
        var text = this.getAttribute('placeholder');
        if (text) {
            this.placeholderText.textContent = text;
        }

        this.appendChild(this.placeholderDiv);

        this.scale = d3.scale.linear();

        this.axis = d3.svg.axis();
        this.axis.scale(this.scale);

        this.svgs.rootSvg.appendChild(this.svgs.axis.node());

        this.appendChild(this.svgs.rootSvg);
    };

    axisPrototype.attachedCallback = function() {
        this.updatePlaceholderText();
        this.refresh();
    };

    axisPrototype.setTargetData = function(data) {
        // Target data is passed to anything that needs to see if this is an
        // acceptable target.
        this.targetData = data;
    };

    axisPrototype.highlight = function() {
        this.classList.add('ra-axis-highlight');
    };

    axisPrototype.unHighlight = function() {
        this.classList.remove('ra-axis-highlight');
    };

    axisPrototype.refresh = function() {
        this.axis.orient(this.settings.orient);

        this.dimensions.width = this.offsetWidth;
        this.dimensions.height = this.offsetHeight;
        // Update scales
        if (
            this.settings.orient !== 'left' &&
            this.settings.orient !== 'right'
        ) {
            this.scale.range([0, this.dimensions.width]);
        } else {
            this.placeholderText.style.width = this.dimensions.height;
            this.scale.range([this.dimensions.height, 0]);
        }

        // Update positioning
        if (this.settings.orient === 'left') {
            this.svgs.axis.attr(
                'transform',
                'translate(' + this.dimensions.width + ',0)'
            );
        }

        if (typeof this.parameter !== 'undefined') {
            this.hidePlaceholder();
            this.svgs.axis.call(this.axis);
            this.classList.add('rendered');
            this.state.rendered = true;
        } else {
            this.showPlaceholder();
            this.classList.remove('rendered');
            this.state.rendered = false;
        }
    };

    axisPrototype.setScale = function(scale) {
        // Setting a scale will override inherent scaling operations.
        this.userScale = scale;
    };

    axisPrototype.setOrientation = function(orient) {
        this.settings.orient = orient;
        if (orient === 'left') {
            this.classList.add('left');
        } else if (orient === 'right') {
            this.classList.add('right');
        } else if (orient === 'bottom') {
            this.classList.add('bottom');
        } else if (orient === 'top') {
            this.classList.add('top');
        }
    };

    axisPrototype.updateOrientation = function() {
        // Updates graphical elements associated with a change of orientation
        this.axis.orient(this.settings.orient);
    };

    axisPrototype.getName = function() {
        return parameter.name;
    };

    axisPrototype.setGetName = function(getName) {
        this.getName = getName;
    };

    axisPrototype.setParameter = function(parameter) {
        this.parameter = parameter;
        this.scale.domain([parameter.min, parameter.max]);
        // this.parameterCallback(parameter);
        // this.refresh();
        this.updatePlaceholderText();
    };

    axisPrototype.setScale = function(scale) {
        this.scale.domain(scale.domain());
        this.scale.range(scale.range());
    };

    axisPrototype.setPlaceholderText = function(fn) {
        this.placeholderTextFn = fn;
    };

    axisPrototype.updatePlaceholderText = function() {
        if (typeof this.placeholderTextFn === 'function') {
            this.placeholderText.textContent = this.placeholderTextFn();
        } else if (
            typeof this.parameter !== 'undefined' &&
            typeof this.parameter.name !== 'undefined'
        ) {
            this.placeholderText.textContent =
                'Parameter: ' + this.parameter.name;
        } else {
            this.placeholderText.textContent = 'Parameter';
        }
    };

    axisPrototype.showPlaceholder = function() {
        this.placeholderDiv.classList.remove('hidden');
    };

    axisPrototype.hidePlaceholder = function() {
        this.placeholderDiv.classList.add('hidden');
    };

    axisPrototype.parameterCallback = function() {
        this.refresh();
    };

    axisPrototype.setParameterCallback = function(callback) {
        this.parameterCallback = callback;
    };

    GLOBAL.DS.RAComponents.axis = axisPrototype;
    Polymer(axisPrototype);
})(this);
