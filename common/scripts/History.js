
(function () {
    /**
     * @class swv6.ui.History
     * @extends swv6.util.Publisher
     * History management object.
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher;

    CLASS =
        swv6.ui.History =
        function (config) {
            CLASS.base.ctor.apply(this, arguments);

            this.addEvent('navigate');

            this.history = [];
            this.index = -1;
        };

    swv6.util.inherit(CLASS, BASE, {

        add: function (item) {
            this.index++;
            if (this.index !== this.history.length) {
                this.history.splice(this.index);
            }
            this.history.push(item);
            this.publish('navigate', this);
        },

        back: function () {
            if (this.canUndo()) {
                this.history[this.index].undo();
                this.index--;
                this.publish('navigate', this);
            }        
        },

        forward: function () {
            if (this.canRedo()) {
                this.index++;
                this.history[this.index].redo();
                this.publish('navigate', this);
            }
        },

        canUndo: function () {
            return (this.index > 0);
        },

        canRedo: function () {
            return (this.history.length !== 0) && (this.index !== (this.history.length-1));
        }

    });

}());
