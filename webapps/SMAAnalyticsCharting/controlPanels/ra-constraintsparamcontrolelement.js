(function(GLOBAL, template) {
    var constraintsParamControlElementPrototype = {
        is: 'ra-constraintsparamcontrolelement',
        behaviors: [GLOBAL.DS.RAComponents.paramcontrolelement]
    };

    constraintsParamControlElementPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.paramcontrolelement.createdCallback.call(this);
    };

    constraintsParamControlElementPrototype.setParameter = function(param) {
        this.parameter = param;

        this.render();
    };

    Polymer(constraintsParamControlElementPrototype);
    GLOBAL.DS.RAComponents.constraintsparamcontrolelement = constraintsParamControlElementPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
