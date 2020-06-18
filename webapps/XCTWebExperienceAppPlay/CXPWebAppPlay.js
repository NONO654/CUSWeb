///* global widget  */
define('DS/XCTWebExperienceAppPlay/CXPWebAppPlay',
	[
	   'UWA/Core',
	   'UWA/Class/Listener',
	   'DS/CAT3DExpModel/CAT3DXModelApplication',
	   'DS/CAT3DExpModel/CAT3DXModel',
	   'DS/XCTWebExperienceAppPlay/CXPWebAppPlayModelExtension',
	   'text!DS/XCTWebExperienceAppPlay/assets/CXPWebAppPlayPrototypeBuild.json'
	],

	function (UWA, Listener, CAT3DXModelApplication, CAT3DXModel,
		CXPWebAppPlayModelExtension, CXPWebAppPlayPrototypeBuild) {
		'use strict';

		var CXPWebAppPlay = CAT3DXModelApplication.extend(Listener, {

			init: function (iOptions) {
				this._parent(iOptions);

				this._modelExtensions.push(new CXPWebAppPlayModelExtension());
			},

			onAppReady: function () {
				this._parent();
				this._experienceBase.getManager('CXPWebPlayManager').AddProtobuildSpec(JSON.parse(CXPWebAppPlayPrototypeBuild));
			},

			getOptions: function (iOptions) {
				return this._parent(UWA.extend({
					'viewerOptions':
					{
						displayGrid: true,
						infinitePlane: true,
						ssao: true,
						useShadowMap: true,
						backgroundColor: { red: 0.925, green: 0.925, blue: 0.925 }
					}
				}, iOptions, true));
			},

			getWorkBench: function () {
				return {
				    module: 'XCTWebExperienceAppPlay',
					name: 'CXPWebAppPlay'
				};
			}
		});

		return CXPWebAppPlay;

	});
