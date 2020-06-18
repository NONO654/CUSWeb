(function(GLOBAL) {
    var controlPanelPrototype = { is: 'ra-controlpanel', behaviors: [] };

    controlPanelPrototype.clearPanel = function() {
        while (this.lastChild) {
            this.removeChild(this.lastChild);
        }
    };

    controlPanelPrototype.getControl = function(controlName) {
        controlName = controlName || 'ra-control';

        var control = document.createElement(controlName);
        this.appendChild(control);
        return control;
    };

    controlPanelPrototype.currentChart = function(chart) {
        if (typeof chart !== 'undefined') {
            this._currentChart = chart;
        }

        return this._currentChart;
    };

    Polymer(controlPanelPrototype);
    GLOBAL.DS.RAComponents.controlPanel = controlPanelPrototype;
})(this);
