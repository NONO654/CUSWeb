(function(GLOBAL, template) {
    if (GLOBAL.DS.RAComponents.control) {
        return;
    }

    var controlPrototype = { is: 'ra-control', behaviors: [] };

    controlPrototype.createdCallback = function() {
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.collapsed = false;
    };

    controlPrototype.attachedCallback = function() {};

    controlPrototype.title = function(title) {
        var that = this;

        this._title = title;

        var titleDiv = this.querySelector('.controlTitle');
        if(titleDiv) {
            titleDiv.textContent = title;
    
            titleDiv.addEventListener('click', function(e) {
                if (that.collapsed) {
                    that.querySelector('.controlBody').classList.remove('hidden');
    
                    that.collapsed = false;
                } else {
                    that.querySelector('.controlBody').classList.add('hidden');
    
                    that.collapsed = true;
                }
            });
        }
    };

    Polymer(controlPrototype);
    GLOBAL.DS.RAComponents.control = controlPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
