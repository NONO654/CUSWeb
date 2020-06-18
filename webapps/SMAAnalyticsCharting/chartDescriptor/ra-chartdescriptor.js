(function(GLOBAL, template) {
    var chartDescriptorPrototype = {
        is: 'ra-chartdescriptor',

        behaviors: [GLOBAL.DS.RAComponents.draggable]

        // TODO: Figure out how to get properties to work.
        /*properties : {
        icon: {
            type: String,
            value: '',
            observer: '_iconObserver'
        }
    }/*,

    _iconObserver : function(newValue, oldValue){

        if(this.querySelector('.chartdescriptor-icon') &&
        this.querySelector('.chartdescriptor-icon').setAttribute){

            this.querySelector('.chartdescriptor-icon').setAttribute('url',
    newValue);
        }

    }*/
    };

    /*
INHERITED METHODS:
setData
setDragStartCallback
setStartDataMapper
startDataMapper
startDrag
createdCallback
   -Makes element draggable, sets up dragStart callback which binds data and
calls startDrag endDrag

*/

    chartDescriptorPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.draggable.createdCallback.call(this);

        var clone = document.importNode(template.content, true);
        this.appendChild(clone);
    };

    chartDescriptorPrototype.setIconUrl = function(url) {
        this.querySelector('.chartdescriptor-icon').style['background-image'] =
            'url(' + url + ')';
    };

    chartDescriptorPrototype.setData = function(data) {
        GLOBAL.DS.RAComponents.draggable.setData.call(this, data);

        this.querySelector(
            '.chartdescriptor-text'
        ).textContent = this.data.properties.title;
    };

    chartDescriptorPrototype.addContent = function() {
        // TODO: Move all of the DOM contained here into a template in the HTML.
        /*var iconDiv = document.createElement('div');
    iconDiv.classList.add('chartdescriptor-icon');

    this.appendChild(iconDiv);

    var textSpan = document.createElement('span');
    textSpan.textContent = this.data.properties.title;
    textSpan.classList.add('chartdescriptor-text');

    this.appendChild(textSpan);*/
    };

    Polymer(chartDescriptorPrototype);
    GLOBAL.DS.RAComponents.chartdescriptor = chartDescriptorPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
