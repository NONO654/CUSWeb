(function(GLOBAL, template) {
    var paramControlElementPrototype = {
        is: 'ra-paramcontrolelement',
        behaviors: [GLOBAL.DS.RAComponents.droptarget]
    };

    paramControlElementPrototype.createdCallback = function() {
        var that = this;

        GLOBAL.DS.RAComponents.droptarget.createdCallback.call(this);

        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.parameter = null;

        this.setupCloseButton();

        this.setDropListener(function(data) {
            var newParam = data.properties;
            if (typeof that.changeParamCallback === 'function') {
                that.changeParamCallback(newParam, this.parameter);
            }
            that.setParameter(newParam);
        });
    };

    paramControlElementPrototype.setupCloseButton = function() {
        var that = this;

        this.querySelector(
            '.closeButtonDiv'
        ).addEventListener('click', function(e) {
            if (typeof that.removeParamCallback === 'function') {
                that.removeParamCallback(that.parameter);
            }
        });
    };

    paramControlElementPrototype.setRemoveParameterCallback = function(fn) {
        this.removeParamCallback = fn;
    };

    paramControlElementPrototype.setParameterChangeCallback = function(fn) {
        this.changeParamCallback = fn;
    };

    paramControlElementPrototype.render = function() {
        // Render icons

        // Render text
        var parameter = this.parameter;
        var name =
            parameter.alias ||
            parameter.displayName ||
            parameter.name ||
            parameter.id;
        this.querySelector('.textDiv').textContent = decodeURIComponent(name);
        this.querySelector('.textDiv').setAttribute('title', decodeURIComponent(name));
        
        if(parameter.seriesColor !== undefined && parameter.seriesColor !== null){  
            this.style.background = parameter.seriesColor;
            
            // generate contrast black or white color for text
            var textColor = parameter.seriesColor;
            
            if (textColor.indexOf('#') === 0) {
                textColor = textColor.slice(1);
            }
            // convert 3-digit hex to 6-digits.
            if (textColor.length === 3) {
                textColor = textColor[0] + textColor[0] + textColor[1] + textColor[1] + textColor[2] + textColor[2];
            }
            
            var r = parseInt(textColor.slice(0, 2), 16),
                g = parseInt(textColor.slice(2, 4), 16),
                b = parseInt(textColor.slice(4, 6), 16);
            
            textColor =  (r * 0.299 + g * 0.587 + b * 0.114) > 186
                ? '#000000'
                : '#FFFFFF';
            this.style.color = textColor;
         }
    };

    Polymer(paramControlElementPrototype);
    GLOBAL.DS.RAComponents.paramcontrolelement = paramControlElementPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
