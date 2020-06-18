(function(GLOBAL, template) {
    var selectPrototype = { is: 'ra-selectcontrol', behaviors: [] };

    selectPrototype.createdCallback = function() {
        var that = this;

        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.querySelector('.select').addEventListener('change', function(e) {
            if (typeof that.updateCallback === 'function') {
                that.updateCallback(this.value);
            }
        });
    };

    selectPrototype.setUpdateCallback = function(fn) {
        this.updateCallback = fn;
    };

    selectPrototype.addOption = function(option) {
        this.querySelector('.select').add(option);
    };

    selectPrototype.getValue = function() {
        return this.querySelector('.select').value;
    };

    selectPrototype.setValue = function(value) {
        this.querySelector('.select').value = value;
    };

    selectPrototype.setLabel = function(value) {
        this.querySelector('.selectLabel').textContent = value;
    };

    Polymer(selectPrototype);
    GLOBAL.DS.RAComponents.selectcontrol = selectPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
