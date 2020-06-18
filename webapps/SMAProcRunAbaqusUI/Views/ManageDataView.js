
define('DS/SMAProcRunAbaqusUI/Views/ManageDataView', [
   'UWA/Core',
   'UWA/Class/View',
   'UWA/Class/Debug',
   'DS/WebappsUtils/WebappsUtils',
   'DS/SMAProcADUI/ad-util/ADAMDUtil',
   'css!DS/SMAProcRunAbaqusUI/RunAbaqusWidget'
], function(UWACore, View, Debug, WebAppsUtils, ADAMDUtil) {

    'use strict';

    var ManageDataView = View.extend(Debug, {
	
	  	  tagName: 'div',
	  	  className: 'tool-facet-panel',
	
	  	  setup: function() {
	  		  this.log('********* DS/RunAbaqusWidget/Views/ManageDataView setup');
  		      
	  		  // load the view Web component
	  		  window.widget.dispatchEvent("onToggleSpinner");
	  		  
  			  var importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcADUI/ad-data-view/ad-data-view.html';
  			  ADAMDUtil.loadWebComponent(importPath, null, null);
  			  
              // wait for Web components (directly and indirectly imported) that have AMD dependencies
	  		  this._viewWCLoaded = false;
              ADAMDUtil.waitForWebComponents(['DS.SMAProcADUI.ADDataView',
                                              'DS.SMAProcADUI.ADMDataRemoveDialog',
                                              'DS.SMAProcADUI.ADMDataView',
                                              'DS.SMAProcADUI.ADMultiviewExecdir',
                                              'DS.SMAProcADUI.ADMultiviewFile',
                                              'DS.SMAProcADUI.ADMultiviewFolder',
                                              'DS.SMAProcADUI.ADMultiviewPart',
                                              'DS.SMAProcADUI.ADPropertiesExecdir',
                                              'DS.SMAProcADUI.ADSession',
                                              'DS.SMAProcADUI.ADStationManager'], function () {
            	  this._viewWCLoaded = true;
	  		  }.bind(this));
	  	  },
	
	  	  render: function () {
			  // Give it the model once the Web component is loaded
	  		  var loadCheckFunc = function() {
	  			  if (this._viewWCLoaded) {
		     		  this.viewWC = UWACore.createElement('ad-data-view', {});
		    		  this.container.addContent(this.viewWC);		    		  
		    		  this.viewWC.session = this.model.get('session');
			  		  this.container.addEventListener("onNoWriteAccess", this.onNoWriteAccess.bind(this));
			  		  this.viewWC.session.addEventListener('execdirremoved', this.onExecDirRemoved.bind(this));
			  		  this.container.addEventListener('appmessage', this.onAppMessage.bind(this));
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
	  	  
	  	  onExecDirRemoved : function() {
	  		  // refresh the execution directory view
	  		  if (this.viewWC) {
	  			  this.viewWC.refresh(false, true);
	  		  }
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

    return ManageDataView;
});

