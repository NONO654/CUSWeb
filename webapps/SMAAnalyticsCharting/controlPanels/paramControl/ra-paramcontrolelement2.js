(function(GLOBAL, template) {
    var pcePrototype = {
        is: 'ra-paramcontrolelement2',
        behaviors: [GLOBAL.DS.RAComponents.droptarget]
    };

    pcePrototype.createdCallback = function() {
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

    pcePrototype.setupCloseButton = function() {
        var that = this;

        this.querySelector(
            '.closeButtonDiv'
        ).addEventListener('click', function(e) {
            if (typeof that.removeParamCallback === 'function') {
                that.removeParamCallback(that.parameter);
            }
        });
    };

    pcePrototype.onRemoveParameter = function(fn) {
        this.removeParamCallback = fn;
    };

    pcePrototype.onParameterChange = function(fn) {
        this.changeParamCallback = fn;
    };

    pcePrototype.setParameter = function(param) {
        this.parameter = param;

        this.render();
    };

    pcePrototype.render = function() {
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
    };

    Polymer(pcePrototype);
    GLOBAL.DS.RAComponents.paramcontrolelement2 = pcePrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
