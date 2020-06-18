
define('DS/SMAProcRunAbaqusUI/Views/ToolExecutionView', [
	  'UWA/Core',
	  'UWA/Class/View',
	  'UWA/Class/Debug',
	  'DS/WebappsUtils/WebappsUtils',
	  'DS/SMAProcADUI/ad-util/ADAMDUtil',
	  'css!DS/SMAProcRunAbaqusUI/RunAbaqusWidget'
], function(UWACore, View, Debug, WebAppsUtils, ADAMDUtil) {

    'use strict';

    var ToolExecutionView = View.extend(Debug, {

    	  tagName: 'div',
    	  className: 'tool-facet-panel',

    	  setup: function() {
      	      this.log('********* DS/RunAbaqusWidget/Views/ToolExecutionView setup');
  		      
	  		  // load the view Web component
	  		  var importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcADUI/ad-tool-config-where-wrapper/ad-tool-config-where-wrapper.html';
  			  ADAMDUtil.loadWebComponent(importPath, null, null);
  			  
              // wait for Web components (directly and indirectly imported) that have AMD dependencies
	  		  this._viewWCLoaded = false;
              ADAMDUtil.waitForWebComponents(['DS.SMAProcSPUI.SPCreditsCalculator',
                                              'DS.SMAProcADUI.ADStationManager',
                                              'DS.SMAProcADUI.ADToolConfigWhere',
                                              'DS.SMAProcADUI.ADToolConfigWhereCloud',
                                              'DS.SMAProcADUI.ADToolConfigWhereWrapper'], function () {
            	  this._viewWCLoaded = true;
	  		  }.bind(this));
    	  },

    	  render: function () {
    		  // Give it the model once the Web component is loaded
	  		  var loadCheckFunc = function() {
	  			  var tool, viewWC;
	  			  if (this._viewWCLoaded) {  		  
	  				  this.container.addEventListener('appmessage', this.onAppMessage.bind(this));
		    		  var toolInstances = [];
		    		  if (this.model) {
		    			  tool = this.model.get('toolInstance');
		    			  if(tool.name === 'Abaqus/CAE Launcher'){
		    				  	viewWC = UWACore.createElement('div', {
		    				  		'text':"'Abaqus/CAE Launcher' cannot be configured or run from Abaqus Study.  Use the 'Run Abaqus/CAE' app to open this study into Abaqus/CAE.",
		    				  		'class':'alert-message alert-primary'});
		  	            		viewWC.style.wordBreak = 'keep-all';
		    			  }else{
		    				  toolInstances.push(tool);
				     		  viewWC = UWACore.createElement('ad-tool-config-where-wrapper', {});				    		  
				    		  viewWC.session = this.model.get('session');
				    		  viewWC.tools = toolInstances;		
		    			  }
		    			  this.container.addContent(viewWC);
		    		  }	    		  
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
		   }
    	  
    });

    return ToolExecutionView;
});

