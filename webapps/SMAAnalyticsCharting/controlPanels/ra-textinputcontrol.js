(function(GLOBAL, template) {
    var textInputPrototype = { is: 'ra-textinputcontrol', behaviors: [] };

    textInputPrototype.createdCallback = function() {
        var that = this;

        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.querySelector('.textInput').addEventListener('change', function(
            e
        ) {
            if (typeof that.updateCallback === 'function') {
                that.updateCallback(this.value);
            }
        });
    };

    textInputPrototype.setUpdateCallback = function(fn) {
        this.updateCallback = fn;
    };

    textInputPrototype.getValue = function() {
        return this.querySelector('.textInput').value;
    };

    textInputPrototype.setValue = function(value) {
        this.querySelector('.textInput').value = value;
    };

    textInputPrototype.setLabel = function(value) {
        this.querySelector('.textLabel').textContent = value;
    };

    Polymer(textInputPrototype);
    GLOBAL.DS.RAComponents.textinputcontrol = textInputPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
