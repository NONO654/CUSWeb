
/* global define , StuVisuServices , StuViewer , StuGeomPrimitive_ISOManager , stu__GlobeServices*/
define('DS/StuRenderEngine/StuRenderManagerNA', ['DS/StuRenderEngine/StuRenderManager'], function (RenderManager) {
	'use strict';

	RenderManager.prototype.buildViewer = function () {
		return new StuViewer();
	};

	RenderManager.prototype.buildViewpoint = function () {
		return this.main3DViewpoint;
	};

	RenderManager.prototype.buildGeomPrimitive_ISOManager = function () {
		return StuGeomPrimitive_ISOManager;
	};

	RenderManager.prototype.buildEnvironmentsManager = function () {
	    return StuEnvironmentsManager;
	};
	return RenderManager;
});

define('StuRenderEngine/StuRenderManagerNA', ['DS/StuRenderEngine/StuRenderManagerNA'], function (RenderManager) {
    'use strict';

    return RenderManager;
});

