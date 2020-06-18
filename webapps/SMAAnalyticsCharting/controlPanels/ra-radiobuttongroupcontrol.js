//XSS_CHECKED
(function(GLOBAL, template) {
    var radiobuttongroupPrototype = { is: 'ra-radiobuttongroupcontrol', behaviors: [] };

    radiobuttongroupPrototype.createdCallback = function() {
        var that = this;
        this.buttonGroup = null;
        this.selected = null;
        this.initialization = new Promise(function(resolve, reject){
            require(['DS/Controls/ButtonGroup', 'DS/Controls/Toggle'],function(WUXButtonGroup, WUXToggle){
            	this.buttonGroup = new WUXButtonGroup().inject(this);
            	
            	this.WUXToggle = WUXToggle; // we'll need this later ...
            	
            	this.buttonGroup.addEventListener('change', function(e){
            		e.preventDefault();
            		e.stopPropagation();
            		
            		// use the callback if defined
            		if(typeof this.updateCallback === 'function'){
            			this.updateCallback(e.dsModel.value[0]);
            		}
            	}.bind(this));
            	resolve();
            }.bind(this));
        }.bind(this));
    };

    radiobuttongroupPrototype.setUpdateCallback = function(fn) {
    	if(typeof fn === 'function'){
            this.updateCallback = fn;
    	}
    };

    radiobuttongroupPrototype.setCheck = function(value) {
    	this.selected = value;
    	
    	this._accessButtonGroup(function(){
    		this.buttonGroup.getButtonFromValue(this.selected).checkFlag = true;
    	});
      
    };
    
    radiobuttongroupPrototype.addRadioButton = function(options) {    	
    	this._accessButtonGroup(function(){            
            this.buttonGroup.addChild(new this.WUXToggle({ type: 'radio', label: options.label, 
                value: options.value, checkFlag: options.checkFlag }))
    		
    		
    	});
        
    };
        
    radiobuttongroupPrototype._accessButtonGroup = function(callback){
    	if(typeof callback === 'function'){
            if(this.buttonGroup){
            	callback.call(this);
            }else{
            	this.initialization.then(function(){
            		callback.call(this);
            	}.bind(this));
            }
    	}
    };

    Polymer(radiobuttongroupPrototype);
    GLOBAL.DS.RAComponents.radiobuttongroupcontrol = radiobuttongroupPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
