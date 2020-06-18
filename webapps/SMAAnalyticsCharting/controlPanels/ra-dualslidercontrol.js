(function(GLOBAL, template) {
    var dualSliderPrototype = { is: 'ra-dualslidercontrol', behaviors: [] };

    dualSliderPrototype.createdCallback = function() {
        var that = this;

        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.minSliderControl = this.querySelector('.minSlider');
        this.maxSliderControl = this.querySelector('.maxSlider');

        this.minSliderControl.min = 0;
        this.minSliderControl.max = 100;
        this.minSliderControl.value = 0;

        this.maxSliderControl.min = 0;
        this.maxSliderControl.max = 100;
        this.maxSliderControl.value = 100;

        this.minSliderControl.addEventListener('change', function(e) {
            if (typeof that.updateMinCallback === 'function') {
                that.updateMinCallback(this.value);
            }
        });
        this.maxSliderControl.addEventListener('change', function(e) {
            if (typeof that.updateMaxCallback === 'function') {
                that.updateMaxCallback(this.value);
            }
        });
    };

    dualSliderPrototype.setUpdateMinCallback = function(fn) {
        this.updateMinCallback = fn;
    };

    dualSliderPrototype.setUpdateMaxCallback = function(fn) {
        this.updateMaxCallback = fn;
    };

    dualSliderPrototype.setBackground = function(value) {
        this.querySelector('.sliderDiv').style.background = value;
    };

    dualSliderPrototype.getMinValue = function() {
        return this.minSliderControl.value;
    };

    dualSliderPrototype.setMinValue = function(value) {
        this.minSliderControl.value = value;
    };

    dualSliderPrototype.getMaxValue = function() {
        return this.maxSliderControl.value;
    };

    dualSliderPrototype.setMaxValue = function(value) {
        this.maxSliderControl.value = value;
    };

    dualSliderPrototype.setMinLimit = function(value) {
        this.minSliderControl.min = value;
        this.maxSliderControl.min = value;
    };

    dualSliderPrototype.setMaxLimit = function(value) {
        this.minSliderControl.max = value;
        this.maxSliderControl.max = value;
    };

    dualSliderPrototype.setLabel = function(value) {
        this.querySelector('.sliderLabel').textContent = value;
    };

    Polymer(dualSliderPrototype);
    GLOBAL.DS.RAComponents.dualslidercontrol = dualSliderPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
