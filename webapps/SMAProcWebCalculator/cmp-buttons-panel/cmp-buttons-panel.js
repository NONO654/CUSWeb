(function (window) {
    'use strict';
    var polymer = window.Polymer,
        //Private Methods
        //Event handlers
        onItemClick,
        //Enums
        _EVENT = { buttonspanelclick: 'buttonspanelclick' };
    //Event handlers
    /** This handles hiding the drop down menu when any item is clicked.
    The click event is allowed to propagate.
    * @param {click} event Triggered when any of its items is clicked     */
    onItemClick = function (event) {
        this.fire(_EVENT.buttonspanelclick, { item: Polymer.dom(event.target).innerHTML });
    };
    Polymer({
        is: 'cmp-buttons-panel',
        //Event handlers
        onItemClick: function () {
            return onItemClick.apply(this, arguments);
        }
    });
}(this));



