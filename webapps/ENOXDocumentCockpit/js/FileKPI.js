
/**
* Component to handle 2 resizable Views on Vertical level. Can be % or px based.
*/
define('DS/ENOXDocumentCockpit/js/FileKPI', [
    'UWA/Element',
    'UWA/Class/Model',
    'DS/UIKIT/Mask',
    'DS/CoreEvents/ModelEvents',
    'DS/Handlebars/Handlebars',
    'text!DS/ENOXDocumentCockpit/html/FileKPI_template.html',
    'css!DS/ENOXDocumentCockpit/css/FileKPI.css'
],

function (
        _uwa_element_not_to_use_as_is,
        _uwa_class_model,
        Mask,
        ModelEvents,
        Handlebars,
        _html_KPIComplexity_template,
        _css_KPIComplexity
    ) {
    'use strict';

    /* Fetching the panel template through Handlebars */
    var panelTemplate = Handlebars.compile(_html_KPIComplexity_template);

    var KPIcomplexity = function () {
        this._options = {};
    };

    KPIcomplexity.prototype.init = function (options) {
        this._options.name = options.name ? options.name : null;
        this._options.originalValue = options.originalValue ? options.originalValue : 0;
        this._modelEvents = options && options.modelEvents ? options.modelEvents : new ModelEvents(); // still handle internally a modelevents (for ease of code)

        this._kpiDeltaValue = 0;
        this._currentValue = this._options.originalValue;

        this._subscribeToEvents();
        this._initDivs(); // 'create div' without appending them (render sortof)
    };

    KPIcomplexity.prototype._initDivs = function () {
        this._container = document.createElement('div');
        var container = panelTemplate(this._options);
        this._container.innerHTML = container;
        this._container = this._container.firstChild; // work around not to create an additional (useless) div
        this._kpivalueContainer = this._container.querySelector('.xmodel-kpi-originalvalue');
        // set the different 'useful' private containers : top container, bot container, and resizer (not used atm)

        this._kpiDeltaSign = this._container.querySelector('.xmodel-kpi-delta-sign');
        this._kpiDeltaValue = this._container.querySelector('.xmodel-kpi-delta-value');
        this._kpiDelta = this._container.querySelector('.xmodel-kpi-delta');
        this._kpivalue = this._container.querySelector('.xmodel-kpi-value');
        //this._kpivalue.style.height = 'unset';
        //this._kpivalue.style.overflow = 'visible !important';

    };

    // inject, append the container on a given parentContainer
    KPIcomplexity.prototype.inject = function (parentContainer) {
        parentContainer.appendChild(this._container);
    };

    KPIcomplexity.prototype.getDOMContent = function () {
        return this._container;
    };

    KPIcomplexity.prototype._subscribeToEvents = function () {
        // var that = this;
        // this._modelEvents.subscribe({ event: 'kpi-custom-update' }, function (newvalue) {
        //     that._kpiDelta.classList.add('displaynone');
        //     that.currentValue = newvalue;
        //     that._kpivalueContainer.innerHTML = newvalue;
        // });
        //
        // this._modelEvents.subscribe({ event: 'kpi-custom-delta-update' }, function (newvalue) {
        //     that._kpiDelta.classList.remove('displaynone');
        //     that.currentValue = newvalue;
        //     that._kpiDeltaValue.innerHTML = newvalue;
        //     if (newvalue < 0) {
        //         that._kpiDeltaSign.innerHTML = '-'; // sign isnt used for now, delta given should be directly positive or negative
        //     } else if (newvalue >= 0) {
        //         that._kpiDeltaSign.innerHTML = '+';
        //     }
        // });

        // this._modelEvents.subscribe({ event: 'kpi-under-computation' }, function () {
        //     //Mask.mask(that._container);
        //     UWA.extendElement(that._kpivalue);
        //     console.log(that._container);
        //     Mask.mask(that._kpivalue);
        //     that._kpivalue.querySelector('.text').innerHTML = ''; //nls_KPIcustom._computing + '...';
        //     that._kpivalue.querySelector('.spinner').style.transform = 'translate3d(40px, -2px, 0px)';
        //     that._kpivalue.querySelector('.spinner').style.height = '22px';
        // });
        //
        // this._modelEvents.subscribe({ event: 'kpi-finish-computation' }, function () {
        //     //Mask.mask(that._container);
        //     UWA.extendElement(that._kpivalue);
        //     console.log(that._container);
        //     Mask.unmask(that._kpivalue);
        //     //that._kpivalue.querySelector('.text').innerHTML = ''; //nls_KPIcustom._computing + '...';
        //     //that._kpivalue.querySelector('.spinner').style.transform = 'translate3d(40px, -2px, 0px)';
        //     //that._kpivalue.querySelector('.spinner').style.height = '22px';
        // });
    };

    return KPIcomplexity;
});
