/**
 * @exports DS/CAT3DExpModel/CAT3DXModelApplication
 */
define('DS/CAT3DExpModel/CAT3DXModelApplication', [
		'UWA/Core',
		'UWA/Class/Listener',
		'DS/Core/Core',
		'DS/CAT3DExpModel/CAT3DXModel',
		'DS/CAT3DExpModel/CAT3DXModelExtension',
        'DS/CATCXPModel/CATCXPModelExtension'
],
function (
	UWA,
	Listener,
	WUX,
	CAT3DXModel,
	CAT3DXModelExtension,
    CATCXPModelExtension
	) {
	'use strict';

	/**
	* @name DS/CAT3DExpModel/CAT3DXModelApplication
    * @description
	* First layer of creative web application.
	* It loads the creative model stored in 'StuModelWeb/assets/CXPModel.json'
    * @param {Object} options for the application
	* @constructor
	*/
	var CAT3DXModelApplication = UWA.Class.extend(Listener,
	/** @lends DS/CAT3DExpModel/CAT3DXModelApplication.prototype **/
	{
		init: function (iOptions) {
			this._parent();
			this._modelExtensions = [];
			this._modelExtensions.push(new CAT3DXModelExtension());
			this._modelExtensions.push(new CATCXPModelExtension());

			this._options = iOptions;
			if (this._options.modelExtensions) {
			    for (var i = 0; i < this._options.modelExtensions.length; i++) {
			        this._modelExtensions.push(this._options.modelExtensions[i]);
			    }
			}

			this._frameWindowOptions = iOptions.frameWindowOptions;
		},

		/**
		* Callback when web application container is created.
		* @param {WebAplicationBase} iExperienceBase - the web application base. See 'DS/WebApplicationBase/WebApplicationBase' for more details
		* @param {function} iEndCB - call at the end of this method execution.
		*/
		onPostCreate: function (iExperienceBase, iEndCB) {
		    this._experienceBase = iExperienceBase;
		    iEndCB(0);
		    var self = this;
		    this._initCAT3DXModel().done(function () {
		        self.onAppReady();
		        if (self._resetPromise) {
		            self._resetPromise.resolve();
		        }
		    });
		},

		_initCAT3DXModel: function () {
		    CAT3DXModel.setExperienceBase(this._experienceBase);
		    for (var i = 0; i < this._modelExtensions.length; i++) {
		        CAT3DXModel.addExtension(this._modelExtensions[i]);
		    }
		    return this._getFactory().done(function (iFactory) {
		        CAT3DXModel.setFactory(iFactory);
		        return CAT3DXModel.start();
		    });    		    
		},

		_getFactory: function () {
		    var deferred = UWA.Promise.deferred();
		    var modelFactory = this._options.modelFactory ? this._options.modelFactory : 'DS/CAT3DExpModelLocal/CAT3DXModelFactoryLocal';
		    var factoryOptions = this._options.modelFactoryOptions ? this._options.modelFactoryOptions : {};
		    factoryOptions.factory = this._experienceBase.Factory;
		    factoryOptions.componentMap = this._experienceBase.ComponentsMap;

		    require([modelFactory], function (Factory) {
		        deferred.resolve(new Factory(factoryOptions));
		    });
		    return deferred.promise;
		},

		reset: function () {
		    this._resetPromise = UWA.Promise.deferred();
		    var self = this;
		    CAT3DXModel.clean().done(function () {
		        self._experienceBase.webApplication.requestNewExperienceBase();
		    });
		    return this._resetPromise.promise;
		},

		onAppReady: function () {
		    WUX.setFullscreen();
		    if (this._options.onAppReady) {
		        this._options.onAppReady();
		    }
		},

	    /**
		* Get application options such as picking and multi view. Called by the web application container.
        * @param {Object} iOptions - options
		* @return {Object} application options.
		*/
		getOptions: function (iOptions) {
		    var options = UWA.extend({
		        viewerOptions:
				{
				    picking: true,
				    prePicking: true,
				    multiViewer: true,
				    multiViewerFix: true,
				    mobile: false
				},
		        uiOptions:
				{
				    displayTree: false
				}
		    }, iOptions, true);
		    var options = UWA.extend(options, this._frameWindowOptions, true);

		    var viewerOptions = {};
		    var customEffects = {
		        force: true
		    };
		    var useCustomEffect = false;
		    for (var key in options.viewerOptions) {
		        if (UWA.is(this._ODTAmbiencesInitOptionsMap[key])) {
		            customEffects[this._ODTAmbiencesInitOptionsMap[key]] = typeof options.viewerOptions[key] === "object" ? options.viewerOptions[key] : options.viewerOptions[key].toString();
		            useCustomEffect = true;
		        }
		        else {
		            viewerOptions[key] = options.viewerOptions[key];
		        }
		    }

		    if (useCustomEffect) {
		        viewerOptions.ODTMode = true;
		        viewerOptions.ODTAmbiences = JSON.stringify({ effects: customEffects });
		    }

		    options.viewerOptions = viewerOptions;
		    return options;
		},

		_ODTAmbiencesInitOptionsMap: {
		    infinitePlane: 'Plane',
		    displayGrid: 'Grid',
		    mirror: 'Mirror',
		    useShadowMap: 'Shadow',
		    ssao: 'SSAO',
		    backgroundColor: 'BackgroundColor' //rgb in odt mode/ hex in normal mode
		},		
	});
	return CAT3DXModelApplication;
});
