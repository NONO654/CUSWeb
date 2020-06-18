(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.chartdroptarget !== 'undefined') {
        return;
    }

    chartDropPrototype = {
        is: 'ra-chartdroptarget',
        behaviors: [GLOBAL.DS.RAComponents.droptarget]
    };
    chartDropPrototype.dragCounter = 0;

       
        
    chartDropPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.droptarget.createdCallback.call(this); 
        this.addPlaceholderDiv();
        this.setPlaceholderTextFn = function() {
            return '';
        };
    };

    chartDropPrototype.attachedCallback = function() {
        this.updatePlaceholder();
    };

    chartDropPrototype.setPlaceholderText = function(fn) {
        this.setPlaceholderTextFn = fn;
    };

    chartDropPrototype.addPlaceholderDiv = function() {
        this.placeholderDiv = document.createElement('div');
        this.placeholderDiv.classList.add('placeholderDiv');
        this.placeholderDiv.textContent = '';

        this.appendChild(this.placeholderDiv);
    };

    chartDropPrototype.updatePlaceholder = function() {
        var textContent = this.setPlaceholderTextFn();
        if (!textContent) {
            textContent = '';
        }
        this.placeholderDiv.textContent = textContent;
    };

    chartDropPrototype.dragHappening = function() {
        var that = this;
        // this.classList.remove('hidden');

        if (
            this.checkPlaceholderFilter() ||
            !this.checkFilter(this.getDragStartData(), true)
        ) {
            this.style.display = 'block';
            this.showPlaceholder();
        }

        this.propogateToDropHandlers(
            function(dropHandler) {
                if (!dropHandler.checkFilter(this.getDragStartData(), true)) {
                    this.style.display = 'block';
                    this.showPlaceholder();
                }
            }.bind(this)
        );
    };

    chartDropPrototype.dragEnded = function() {
        this.hidePlaceholder();
        chartDropPrototype.dragCounter = 0;
        console.log('drag ended');
    };

    chartDropPrototype.showPlaceholder = function() {
        this.placeholderDiv.classList.remove('hidden'); // show the placeholder
        this.style.display = 'block'; // show the dropzone
    };

    chartDropPrototype.hidePlaceholder = function() {
        // only hide if the the placeholder filter fails
        if (!this.checkPlaceholderFilter()) {
            this.placeholderDiv.classList.add('hidden');
            this.style.display = 'none';
        } else {
            this.showPlaceholder(); // this should be visible
        }
    };

    chartDropPrototype.setPlaceholderFilter = function(phFunc) {
        if (typeof phFunc === 'function') {
            this.placeholderFunction = phFunc;
        }
    };

    chartDropPrototype.checkPlaceholderFilter = function() {
        if (typeof this.placeholderFunction === 'function') {
            return this.placeholderFunction();
        }
        return false;
    };

    chartDropPrototype.setParameterListener = function(cb) {
        this.parameterListener = cb;
    };

    chartDropPrototype.setParameter = function(param) {
        if (typeof this.parameterLister === 'function') {
            this.parameterListener(param);
        }
    };

    chartDropPrototype.setApproximation = function(approxId) {
        this.approximation = approxId;
    };

    chartDropPrototype.highlight = function() {
        this.classList.add('highlighted');
    };

    chartDropPrototype.unhighlight = function() {
        this.classList.remove('highlighted');
    };

    Polymer(chartDropPrototype);
    GLOBAL.DS.RAComponents.chartdroptarget = chartDropPrototype;
})(this);
