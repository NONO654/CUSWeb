define('DS/CXP3DPlay/CXP3DPlayApp',
	[
	   'UWA/Core',
	   'UWA/Class/Listener',
	   'DS/XCTWebExperienceAppPlay/CXPWebAppPlay',
       'DS/CAT3DExpLinkContext/CAT3DExpPlatformMediaLinkContext',
	   'UWA/Class/Promise',
       'DS/CAT3DExpModel/CAT3DXModel',

	   // Web Specific Define Overrides
	   'DS/XCTWebExperienceAppPlay/CXPWebRenderEngineDefine',
	   'DS/XCTWebExperienceAppPlay/StuTriggerZonesDefine',
	   'DS/XCTWebExperienceAppPlay/StuUIActorDefine',
       'DS/XCTWebExperienceAppPlay/StuCamerasDefine',
       'DS/XCTWebExperienceAppPlay/StuUIActorDefine',
       'DS/XCTWebExperienceAppPlay/StuEnvServicesDefine'
	],

	function (UWA, Listener, CXPWebAppPlay, CAT3DExpPlatformMediaLinkContext, Promise, CAT3DXModel) {
	    'use strict';

	    var CXPWebApp3DPlay = CXPWebAppPlay.extend(Listener, {

	        init: function (iPlayExperience, iInput) {
	            iPlayExperience.frmWindow.loadActionBar({
	                workbenchModule: 'XCTWebExperienceAppPlay',
	                workbench: 'CXPWebAppPlay.xml'
	            });

	            this._asset = iInput.asset;
	            this._parent({
	                FrameWindow: iPlayExperience.frmWindow,
	            });

	            this._experienceBase = iPlayExperience._experienceBase;
	            var self = this;
	            CAT3DXModel.clean().done(function () {
	                return self._initCAT3DXModel();
	            }).done(function () {
	                self.onAppReady();
	            });
	        },

	        onAppReady: function () {
	            this._parent();

	            if (!UWA.is(this._asset)) {
	                console.error("CXPWeb3DPlay.onAppReady() : asset is not set ! Please use setAsset() to assign an asset to load !");
	                return;
	            }

	            var linkContext = new CAT3DExpPlatformMediaLinkContext(this._asset);
	            var self = this;
	            this._experienceBase.getManager("CAT3DXLoaderManager").loadLink(linkContext, ['CXPExperience_Spec']).done(function (iExperienceLoaded) {
	                var experienceGeoVisu = iExperienceLoaded.QueryInterface('CATI3DGeoVisu');
	                self._experienceBase.getManager("CAT3DXVisuManager").setRoot(experienceGeoVisu);
	                self._experienceBase.getManager("CAT3DXVisuManager").setContent(iExperienceLoaded.QueryInterface('CATI3DGeoVisu'));
	                self._experienceBase.getManager("CAT3DXUIManager").setContent(iExperienceLoaded.QueryInterface('CATI3DXUIRep'));

	                self._reframeOnGeoVisu(experienceGeoVisu);
	            });            
	        },

	        _reframeOnGeoVisu: function (iGeoVisu) {
	            if (iGeoVisu.isReady()) {
	                this._reframeViewpoint();
	            } else {
	                var self = this;
	                this.listenTo(iGeoVisu, 'readyChanged', function (iReady) {                      
	                    if (iReady) {
	                        self.stopListening(iGeoVisu, 'readyChanged');
	                        self._reframeViewpoint();
	                    }
	                });
	            }
	        },

	        _reframeViewpoint: function (iGeoVisu) {
	            var viewer = this._experienceBase.getManager("CAT3DXVisuManager").getViewer();
	            viewer.setRenderFrameCB(function () {
	                viewer.setRenderFrameCB(null);
	                viewer.currentViewpoint.reframe();
	            });	            
	        }
	    });

	    return CXPWebApp3DPlay;

	});
