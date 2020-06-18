define('DS/XCTWebExperienceAppPlay/CXPWebRenderManager',
    [
        'DS/StuRenderEngine/StuRenderManager',
        'DS/XCTWebExperienceAppPlay/CXPWebViewer',
        'DS/XCTWebExperienceAppPlay/CXPWebViewpoint',
        'DS/XCTWebExperienceAppPlay/CXPWebGeomPrimitiveISOManager'
],

    function (RenderManager, CXPWebViewer, CXPWebViewpoint, StuGeomPrimitiveISOManager) {
        'use strict';

        // override goes here 
        RenderManager.prototype.buildViewer = function () {
        	return new CXPWebViewer(this._WebViewer);
        };

        RenderManager.prototype.setViewer = function (iViewer) {
        	this._WebViewer = iViewer;
        	StuGeomPrimitiveISOManager.setViewer(iViewer);
        };

        RenderManager.prototype.setViewpoint = function (iViewpoint) {
        	this._WebViewpoint = iViewpoint;
        };

        RenderManager.prototype.buildViewpoint = function () {
        	return new CXPWebViewpoint(this._WebViewpoint);
        };

        RenderManager.prototype.buildGeomPrimitive_ISOManager = function () {
        	return StuGeomPrimitiveISOManager;
        };

        RenderManager.prototype.buildGlobeServices = function () {
            return null;
        };

        RenderManager.prototype.buildEnvironmentsManager = function () {
            return {
                getActiveEnvironmentName: function () { },
                getActiveEnvironmentNumber: function () { },
                deActivateEnvironment: function () { },
                setActiveEnvironmentByName: function () { },
                initStartupEnvironment: function () { },
                getExperienceScaleFactor: function () { return 1;}
            };
        };


    	/**
		 * returns the Inverse of the size(height) of a pixel in millimeter.
		 *
		 * @method
		 * @public
		 * @return {Number}
		 */
        RenderManager.prototype.getPixelDensity = function () {
        	return 96 / 25.4; //(1/96in) //TODO test with other devices
        };

        return RenderManager;

    });
