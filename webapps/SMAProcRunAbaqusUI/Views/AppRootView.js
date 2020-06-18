
define('DS/SMAProcRunAbaqusUI/Views/AppRootView', [
   'UWA/Core',
   'UWA/Class/Debug',
   'DS/W3DXComponents/Views/Item/SkeletonRootView'   
], function(UWACore, Debug, SkeletonRootView) {

    'use strict';
	  
    var AppRootView = SkeletonRootView.extend(Debug, {
	
	  	  setup: function() {
	  		  console.log('********* DS/RunAbaqusWidget/Views/AppRootView setup');
	  		  this._parent();
	  	  },
	
	  	  render: function () {
	  		  this._parent();
	  		  return this;
	  	  },
	
	  	  // We override this destroy method to ...
	  	  destroy: function () {
	  	      this.model = null;
	  	      this._parent();
	  	  }
    });

    return AppRootView;
});

