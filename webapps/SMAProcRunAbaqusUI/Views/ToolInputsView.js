
define('DS/SMAProcRunAbaqusUI/Views/ToolInputsView', [
    'UWA/Core',
    'UWA/Class/View',
    'UWA/Class/Debug',
    'DS/WebappsUtils/WebappsUtils',
	'DS/SMAProcADUI/ad-util/ADAMDUtil',
    'css!DS/SMAProcRunAbaqusUI/RunAbaqusWidget'
], function(UWACore, View, Debug, WebAppsUtils, ADAMDUtil) {

    'use strict';

    var ToolInputsView = View.extend(Debug, {

    	  tagName: 'div',
    	  className: 'tool-facet-panel',

    	  setup: function() {
      	      this.log('********* DS/RunAbaqusWidget/Views/ToolInputsView setup');
  		      
	  		  // load the view Web component
	  		  var importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcADUI/ad-tool-config-input-files/ad-tool-config-input-files.html';
	  		  ADAMDUtil.loadWebComponent(importPath, null, null);
	  		  
	  		  // load the view Web component
	  		  importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcADUI/ad-mdata-view/ad-mdata-view.html';
	  		  ADAMDUtil.loadWebComponent(importPath, null, null);
  			  
              // wait for Web components (directly and indirectly imported) that have AMD dependencies
	  		  this._viewWCLoaded = false;
              ADAMDUtil.waitForWebComponents(['DS.SMAProcADUI.ADMDataRemoveDialog',
                                              'DS.SMAProcADUI.ADMDataView',
                                              'DS.SMAProcADUI.ADSession',
                                              'DS.SMAProcADUI.ADStationManager'], function () {
            	  this._viewWCLoaded = true;
	  		  }.bind(this));
    	  },
    	  
    	  _renderForm: function () {
    		  // Give it the model once the Web component is loaded
	  		  var loadCheckFunc = function() {
	  			  if (this._viewWCLoaded) {
		     		  var viewWC = UWACore.createElement('ad-tool-config-input-files', {});
		    		  this.container.addContent([
		    		                             {
		    		                            	 tag: 'div',
		    		                            	 styles: {
		    		                            	        'margin-bottom': '30px'
		    		                            	    },
		    		                            	 html: viewWC
		    		                             }                               
		    		                             ]);
		    		  
		    		  var toolInstances = [];
		    		  if (this.model) {
		    			  toolInstances.push(this.model.get('toolInstance'));
		    		  }
		    		  viewWC.tools = toolInstances;
		    		  viewWC.refresh();
		    		  
		    		  
		    		  var viewmdataWC = UWACore.createElement('ad-mdata-view', {});
		    		  this.container.addContent([
		    		                             {
		    		                            	 tag: 'div',
		    		                            	 html: viewmdataWC
		    		                             }
		    		                             ]);
		    		  viewmdataWC.session = this.model.get('session');
		    		  viewmdataWC.refresh();
		    		  
	  			  }
	  			  else {
	  				  window.setTimeout(loadCheckFunc.bind(this), 100);
	  			  }
	  		  }.bind(this);
	  		  
			  window.setTimeout(loadCheckFunc.bind(this), 1);
    	    
    		  return this;
    	  },
    	  
    	  _renderTest: function () {
    		  var form = UWACore.createElement('ad-test-databinding', {});
    		  this.container.addContent(form);
    		  
    		  // Give it the model as an array once the component is loaded
	  		  var formReadyTimerFunc = function() {
	  			  if (typeof(form.linkName) !== 'undefined') {
		    		  form.linkName = 'NBCNews.com';
		    		  form.linkDescription = 'NBC News';
		    		  form.linkURL = 'http://www.nbcnews.com';
	  			  }
	  			  else {
	  				  window.setTimeout(formReadyTimerFunc.bind(this), 100);
	  			  }
	  		  };
	  		  
			  window.setTimeout(formReadyTimerFunc.bind(this), 2000);
    	  },

    	  render: function () {
    		  this._renderForm();
    		  //this._renderTest();
    	    
    		  return this;
    	  },

    	  destroy: function () {
     	      this.model = null;
    	      this._parent();
    	  }
    });

    return ToolInputsView;
});

