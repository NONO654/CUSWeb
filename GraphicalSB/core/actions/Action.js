/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ps = swv6.ps || {};


(function () {
    /**
     * @class swv6.ui.Action
     * @extends swv6.util.Publisher
     * TODO: description
     */
//    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher;

    CLASS =
        swv6.ui.Action =
        function (config) {
            this.state = config.state;
            this.stateStore = {};
        };

    swv6.util.inherit(CLASS, BASE, {

        run: function () {
            if (this.state.history) {
                this.state.history.add(this);
            }

            return this.redo();
        },

        undo: function () {
            this.restore();
        },

        redo: function () {
            
        },

        store: function (value) {
            this.state.save(this.stateStore, value);
        },

        restore: function () {
            this.state.load(this.stateStore);
        }

    });

}());
