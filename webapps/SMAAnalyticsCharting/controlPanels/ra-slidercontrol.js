(function(GLOBAL, template) {
    var sliderPrototype = { is: 'ra-slidercontrol', behaviors: [] };

    sliderPrototype.createdCallback = function() {
        var that = this;

        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.sliderControl = this.querySelector('.slider');

        this.sliderControl.min = 0;
        this.sliderControl.max = 100;
        this.sliderControl.value = 0;

        this.sliderControl.addEventListener('change', function(e) {
            if (typeof that.updateCallback === 'function') {
                that.updateCallback(this.value);
            }
        });
    };

    sliderPrototype.setUpdateCallback = function(fn) {
        this.updateCallback = fn;
    };

    sliderPrototype.getValue = function() {
        return this.sliderControl.value;
    };

    sliderPrototype.setValue = function(value) {
        this.sliderControl.value = value;
    };

    sliderPrototype.setMinLimit = function(value) {
        this.sliderControl.min = value;
    };

    sliderPrototype.setMaxLimit = function(value) {
        this.sliderControl.max = value;
    };

    sliderPrototype.setStep = function(value) {
        this.sliderControl.step = value;
    };

    sliderPrototype.setLabel = function(value) {
        this.querySelector('.sliderLabel').textContent = value;
    };

    Polymer(sliderPrototype);
    GLOBAL.DS.RAComponents.slidercontrol = sliderPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
