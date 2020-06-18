(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.callbacks !== 'undefined') {
        return;
    }

    /*
 * This element defines callback behavior for ra elements. It is not intended to
 * be instantiated as an element, but to be used as a behavior for other
 * elements.
 */

    var callbacksElementPrototype = { is: 'ra-callbacks', behaviors: [] };

    callbacksElementPrototype.addCallback = function(type, cb) {
        if (typeof this.callbacks[type] === 'undefined') {
            this.callbacks[type] = [];
        }
        this.callbacks[type].push(cb);
    };

    callbacksElementPrototype.removeCallback = function(type, cb) {
        if (typeof cb === 'undefined') {
            this.callbacks[type] = [];
        } else {
            var index = this.callbacks[type].indexOf(cb);
            if (index !== -1) {
                this.callbacks[type].splice(index, 1);
            }
        }
    };

    callbacksElementPrototype.executeCallbacks = function(type, args) {
        var that = this;

        if (this.callbacks[type] instanceof Array) {
            this.callbacks[type].forEach(function(cb) {
                cb.call(that, args);
            });
        }
    };

    Polymer(callbacksElementPrototype);
    GLOBAL.DS.RAComponents.callbacks = callbacksElementPrototype;
})(this);
