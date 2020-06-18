
define('DS/SMAProcRunAbaqusUI/Views/ToolOutputsView', [
    'UWA/Core',
    'UWA/Class/View',
    'UWA/Class/Debug',
    'DS/WebappsUtils/WebappsUtils',
    'DS/SMAProcADUI/ad-util/ADAMDUtil',
    'css!DS/SMAProcRunAbaqusUI/RunAbaqusWidget'
], function(UWACore, View, Debug, WebAppsUtils, ADAMDUtil) {

    'use strict';
 
    var ToolOutputsView = View.extend(Debug, {

  	  tagName: 'div',
  	  className: 'tool-facet-panel',

  	  setup: function() {
    	  this.log('********* DS/RunAbaqusWidget/Views/ToolOutputsView setup');
		      
  		  // load the view Web component
	      this._viewWCLoaded = false;
    	  var importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcADUI/ad-tool-config-output-files/ad-tool-config-output-files.html';
    	  ADAMDUtil.loadWebComponent(importPath, 'DS.SMAProcADUI.ADToolConfigOutputFiles', function () {
	  	  	this._viewWCLoaded = true;
	  	  }.bind(this));
  	  },

  	  render: function () {
		  // Give it the model once the Web component is loaded
  		  var loadCheckFunc = function() {
  			  var tool, viewWC, toolInstances = [];
  			  if (this._viewWCLoaded) {  				  
  	    		  if (this.model) {
  	    			  tool = this.model.get('toolInstance');
  	    			  if(tool.name === 'Abaqus/CAE Launcher'){
  	    				  	viewWC = UWACore.createElement('div', {
			            			'text':"'Abaqus/CAE Launcher' cannot be configured or run from Abaqus Study.  Use the 'Run Abaqus/CAE' app to open this study into Abaqus/CAE.",
			            			'class':'alert-message alert-primary'});
  	    				  viewWC.style.wordBreak = 'keep-all';
  	    			  }else{
  	    				  toolInstances.push(tool);
  	    				  viewWC = UWACore.createElement('ad-tool-config-output-files', {});
  	    				  if(this.model.get('session').onCloud){
  	    					viewWC.setAttributes({
	  		 	     			 onCloud :true
	  		 	     		  });
	  		    		  }	
  	    				  viewWC.setAttributes({
 			     			 'abaqus-study-mode' :true
 			     		  });			    		  
			    		  viewWC.tools = toolInstances;	
  	    			  }	 
	  	     		  this.container.empty();
		    		  this.container.addContent(viewWC);
		    		  this.container.addEventListener('appmessage', this.onAppMessage.bind(this));
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
	  },
  	  events:{
  		  'onFacetSelect': 'onFacetSelect'
  	  },
  	  onFacetSelect : function(){
  		  this.render();
  	  }
 	  
    });

    return ToolOutputsView;
});

