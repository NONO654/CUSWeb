
define('DS/SMAProcRunAbaqusUI/Views/ToolSettingsView', [
	'UWA/Core',
	'UWA/Class/View',
	'UWA/Class/Debug',
	'DS/WebappsUtils/WebappsUtils',
	'DS/SMAProcADUI/ad-util/ADAMDUtil',
	'css!DS/SMAProcRunAbaqusUI/RunAbaqusWidget'
], function(UWACore, View, Debug, WebAppsUtils, ADAMDUtil) {

    'use strict';

    var ToolSettingsView = View.extend(Debug, {
	
	  	  tagName: 'div',
	  	  className: 'tool-facet-panel',
	
	  	  setup: function() {
    	      this.log('********* DS/RunAbaqusWidget/Views/ToolSettingsView setup');
  		      
	  		  // load the view Web component
  		      this._viewWCLoaded = false;
  		      window.widget.dispatchEvent("onToggleSpinner");
	  		  //var importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcADUI/ad-tool-config-how/ad-tool-config-how.html';
	  		  var importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcADUI/ad-tool-config-options/ad-tool-config-options.html';
	  		  ADAMDUtil.loadWebComponent(importPath, 'DS.SMAProcADUI.ADToolConfigOptions', function () {
		  		  	this._viewWCLoaded = true;
		  	  	}.bind(this));	 
	  		  
	  		  importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcADUI/ad-tool-config-simtoso-as/ad-tool-config-simtoso-as.html';
	  		  ADAMDUtil.loadWebComponent(importPath, 'DS.SMAProcADUI.ADToolConfigSimToSOAS', function () {
		  		  	this._viewWC2Loaded = true;
		  	  	}.bind(this));	
	  		  
	  		  this._subpanels = {};
	  	  },
	
	  	  render: function () {
			  // Give it the model once the Web component is loaded
	  		  var loadCheckFunc = function() {
	  			  if (this._viewWCLoaded && this._viewWC2Loaded) {		
		    		  var toolInstances = [];	
		    		  if (this.model) {
		    			  toolInstances.push(this.model.get('toolInstance'));
		    		  }
		    		  
	  				  this.viewWC = this._getSubpanel.call(this, toolInstances[0]);
	  				  this.container.empty();
		    		  this.container.addContent(this.viewWC);
		    		  this.container.addEventListener("updatetitle", this._updatetitle.bind(this));
		    		  this.container.addEventListener("toggleRun", this._togglerun.bind(this));	  
		    		  this.container.addEventListener('appmessage', this.onAppMessage.bind(this));
		    
		    		  if(this.viewWC){
		    			  this.viewWC.tools = toolInstances;
		    		  }
		    		  
		    		  this.container.addEventListener("onNoWriteAccess", this.onNoWriteAccess.bind(this));
		    		  window.widget.dispatchEvent("onToggleSpinner");
	  			  }
	  			  else {
	  				  window.setTimeout(loadCheckFunc.bind(this), 100);
	  			  }
	  		  }.bind(this);
	  		  
			  window.setTimeout(loadCheckFunc.bind(this), 1);
		    
			  return this;
	  	  },
	
	  	  destroy: function () {
	  	      this.model = null;
	  	      this._parent();
	  	  },
	  	  
	  	onNoWriteAccess : function(event){
	        event.stopPropagation();
	        event.cancelBubble = true;
	  		window.widget.dispatchEvent("onNoWriteAccess");
		},

	  	_updatetitle : function(event){
	        event.stopPropagation();
	        event.cancelBubble = true;	  		
	  		this.model.set("title", "Job: " + event.detail.title);
	  		this.model.set("actTitle", event.detail.title);	  		
	  	},
	  	
	  	_togglerun : function(event){
	  		event.stopPropagation();
	  		event.cancelBubble = true;	  		
	  		this.model.set("isRunnable", !event.detail.disable);
	  	},
	  	
	  	_toggleSpinner : function(event){
	  		event.stopPropagation();
	  		event.cancelBubble = true;	 
	  		window.widget.dispatchEvent("onToggleSpinner");
	  	},
	  	
	    _getSubpanel : function (tool) {
	        var subpanel = this._subpanels[tool.toolType];
	        if (typeof subpanel === 'undefined' || !subpanel) {
	            // create the right panel
	            if (DS.SMAProcADUI.ADToolManager.TOOLTYPES.osCommand === tool.toolType || DS.SMAProcADUI.ADToolManager.TOOLTYPES.osCommandSimToSO === tool.toolType) {
	                subpanel = new DS.SMAProcADUI.ADToolConfigOptions();
	            } else if (DS.SMAProcADUI.ADToolManager.TOOLTYPES.simToSO === tool.toolType) {
	                subpanel = new DS.SMAProcADUI.ADToolConfigSimToSOAS();
	            } else if (tool.name === 'Abaqus/CAE Launcher'){
	            	subpanel= UWACore.createElement('div', {
	            		'text':"'Abaqus/CAE Launcher' cannot be configured or run from Abaqus Study.  Use the 'Run Abaqus/CAE' app to open this study into Abaqus/CAE.",
	            		'class':'alert-message alert-primary'});
	            	subpanel.style.wordBreak = 'keep-all';
	            } else {
	                subpanel = null;
	            }
	            
	            // save to map
	            if (subpanel) {
	                this._subpanels[tool.toolType] = subpanel;
	                subpanel.id = tool.toolType + 'Panel';	                
	            }
	        }
	        return subpanel;
	    },
	    
		onAppMessage : function (event) {
		      var message = {};
		     
		      if (event.detail.level !== 'clear-urgent' && event.detail.level !== 'clear-status') {
		          message.type = event.detail.level;
		          message.text = event.detail.message;
		          if (event.detail.level === 'success' || event.detail.level === 'info') {
		              message.autoRemove = true;
		          }
		          //Trigger message event	            
	              window.widget.dispatchEvent("onAppMessage", message);
		      }
		      return;
		},
	  	events:{
	  	 'onFacetSelect': 'onFacetSelect'
	  	},
	  	onFacetSelect : function(){
	  		if(this._viewWCLoaded && this._viewWC2Loaded && this.viewWC){
	  			if(this.viewWC.validateOptions){
	  				this.viewWC.validateOptions();
	  			}
	  		}
	  	}	  	
    });

    return ToolSettingsView;
});

