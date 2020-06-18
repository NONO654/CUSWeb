//XSS_CHECKED
(function(GLOBAL, template) {
    var checkboxPrototype = { is: 'ra-checkboxcontrol', behaviors: [] };

    checkboxPrototype.createdCallback = function() {
        var that = this;
        this.value = null;
        this.toggle = null;
        this.label = '';
        this.checked = false;
        this.map = null;
        
        this.initialization = new Promise(function(resolve, reject){
            require(['DS/Controls/Toggle'],function(WUXToggle){
            	this.toggle = new WUXToggle({
            		label: this.label,
            		checkFlag: this.checked
            	}).inject(this);
            	
            	this.toggle.addEventListener('change', function(e){
            		e.preventDefault();
            		e.stopPropagation();
            		this.checked = e.dsModel.checkFlag;
            		
            		// use the callback if defined
            		if(typeof this.updateCallback === 'function'){
            			this.updateCallback(this.checked);
            		}
            	}.bind(this));
            	resolve();
            }.bind(this));
        }.bind(this));
    };

    checkboxPrototype.setUpdateCallback = function(fn) {
    	if(typeof fn === 'function'){
            this.updateCallback = fn;
    	}
    };

    checkboxPrototype.setColor = function(value) {
        var label = this.querySelector('.checkboxLabel');
        label.style.background = value;
        console.log('We should not be using this');
    };

    checkboxPrototype.getLabel = function() {
        return this.label;
    };

    checkboxPrototype.setLabel = function(value) {
        this.label = value;
        this.updateLabel();
    };

    checkboxPrototype.getCheck = function() {
		return this.checked;
    };

    checkboxPrototype.setCheck = function(value) {
    	if(typeof value === 'boolean'){
        	this.checked = value;
    	}else{
    		console.warn('value is not boolean');
    	}
    	this._accessToggle(function(){
    		this.toggle.checkFlag = this.checked;
    	});
       // this.querySelector('.checkbox').checked = value;
    };
    

    checkboxPrototype.setValue = function(value) {
    	this.value;
    	this._accessToggle(function(){
    		this.toggle.value = this.value;
    	});
        //this.querySelector('.checkbox').value = value;
    };
    
    checkboxPrototype.setMap = function(value) {
        this.map = value;
        this.updateLabel();
    };

    checkboxPrototype.updateLabel = function() {
        var text = this.label;
        if (this.map != null) {
            text += '(' + this.map + ')';
        }
        
        this._accessToggle(function(){
        	this.toggle.label = text;
        });
    };
    
    checkboxPrototype.setTitleText = function(options){
    	var tooltipOptions = {},
    		title = options.title,
    		short = options.short,
    		long = options.long;
    	if(typeof title !== 'undefined' && title !== null){
    		tooltipOptions.title = title;
    	}
    	if(typeof short !== 'undefined' && short !== null){
    		tooltipOptions.shortHelp = short;
    	}
    	if(typeof long !== 'undefined' && long !== null){
    		tooltipOptions.longHelp = long;
    	}
    	
    	this._accessToggle(function(){
    		require(['DS/Controls/TooltipModel'],function(WUXTooltipModel){
        		this.toggle.tooltipInfos = new WUXTooltipModel(tooltipOptions);
    		}.bind(this))
    	});
    };
    
    checkboxPrototype._accessToggle = function(callback){
    	if(typeof callback === 'function'){
            if(this.toggle){
            	callback.call(this);
            }else{
            	this.initialization.then(function(){
            		callback.call(this);
            	}.bind(this));
            }
    	}
    };

    Polymer(checkboxPrototype);
    GLOBAL.DS.RAComponents.checkboxcontrol = checkboxPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
