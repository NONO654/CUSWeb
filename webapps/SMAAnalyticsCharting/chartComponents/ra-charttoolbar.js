/* globals Polymer */
(function(GLOBAL, template) {
    'use strict';
    
    var chartToolbar = {
        is: 'ra-charttoolbar',
        behaviors: [GLOBAL.DS.RAComponents.chartcomponent]
    };
    
    chartToolbar.activeButton = null;
    chartToolbar.buttons = {};
    
    chartToolbar.createdCallback = function(){
        GLOBAL.DS.RAComponents.chartcomponent.createdCallback.call(this);
        // make sure these are initialized correctly for the instance, may not be necessary
        this.buttons = {};
        this.activeButton = null;
    };
    
    chartToolbar.addButton = function(_id, options){
        var button = document.createElement('span');
        button.classList.add('ra-chart-button');
        button._buttonOptions = options;
        this.buttons[_id] = button;
        
        options = options || {};
        
        if(typeof options.isActive === 'boolean' && options.isActive){
            this.activateButton(_id);
        }
        
        if(options.classList){
            var list = [];
            if(options.classList instanceof Array){
                list = options.classList
            }else if(typeof options.classList.split === 'function'){
                list = options.classList.split(' ');
            }
            list.forEach(function(_class){
                button.classList.add(_class);
            });
        }
        
        if(options.displayName){
            button.title = options.displayName;
        }
        
        if(typeof options.clickCallback === 'function'){
            button.addEventListener('click',options.clickCallback)
        }
        
        this.appendChild(button);
    };
    
    chartToolbar.activateButton = function(_id){
        if(this.activeButton){
            if(this.activateButton === this.buttons[_id]){
                // button is already active, don't continue
                return;
            }
            this.activeButton.classList.remove('ra-chart-activebutton');
            if(typeof this.activeButton._buttonOptions.deactivateCallback === 'function'){
                this.activeButton._buttonOptions.deactivateCallback();
            }
        }
        if(this.buttons[_id]){
            //qw8 - .add() throws an error in IE and doesn't seem to do anything.
            //this.buttons[_id].classList.add();
            this.activeButton = this.buttons[_id];
        }
        if(this.activeButton){
            this.activeButton.classList.add('ra-chart-activebutton');
        }
    };
    
    Polymer(chartToolbar);
    GLOBAL.DS.RAComponents.chartToolbar = chartToolbar;
})(this, document._currentScript.parentElement.querySelector('template'));
