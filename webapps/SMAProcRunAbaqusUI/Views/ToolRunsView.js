
define('DS/SMAProcRunAbaqusUI/Views/ToolRunsView', [
	'UWA/Core',
	'UWA/Class/View',
	'UWA/Class/Debug',
	'DS/WebappsUtils/WebappsUtils',
	'DS/SMAProcADUI/ad-util/ADAMDUtil',
	'css!DS/SMAProcRunAbaqusUI/RunAbaqusWidget'
], function(UWACore, View, Debug, WebAppsUtils, ADAMDUtil) {

    'use strict';

    var ToolRunsView = View.extend(Debug, {
	
	  	  tagName: 'div',
	  	  className: 'tool-facet-panel',
	
	  	  setup: function() {
    	      this.log('********* DS/RunAbaqusWidget/Views/ToolRunssView setup');
  		      
	  		  // load the view Web component
  		      this._viewWCLoaded = false;
	  		  //var importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcADUI/ad-tool-config-how/ad-tool-config-how.html';
	  		  var importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcADUI/ad-jobs-view/ad-jobs-view.html';
	  		  ADAMDUtil.loadWebComponent(importPath, 'DS.SMAProcADUI.ADJobsView', function () {
		  		  	this._viewWCLoaded = true;
		  	  	}.bind(this));
	  	  },
	
	  	  render: function () {
			  // Give it the model once the Web component is loaded
	  		  var loadCheckFunc = function() {
	  			  if (this._viewWCLoaded) {
		     		  var viewWC = UWACore.createElement('ad-jobs-view', {});
		     		  viewWC.session = this.model.get('session');
		     		  viewWC.filterByJobTitle = {
		     				  status: true,
		     				  title: this.model.get('actTitle'),
							  id: this.model.get('id')
		     		  	};
		     		  this.container.addContent(viewWC);
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
	  	  }
    });

    return ToolRunsView;
});

