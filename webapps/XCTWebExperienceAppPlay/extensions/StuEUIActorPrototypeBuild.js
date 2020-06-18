/**
 * @exports DS/XCTWebExperienceAppPlay/extensions/StuEUIActorPrototypeBuild
*/
define('DS/XCTWebExperienceAppPlay/extensions/StuEUIActorPrototypeBuild',
[
	'UWA/Core',
    'DS/XCTWebExperienceAppPlay/extensions/StuEExperienceBasePrototypeBuild',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuCATICXPUIActor',
	'DS/StuCID/StuUIActor',
	'DS/StuCID/CXPText',
	'DS/StuCID/CXPImage'
],

function (
    UWA,
    StuEExperienceBasePrototypeBuild,
    StuCATICXPUIActor,
	UIActor,
	CXPText,
	CXPImage
    ) {
	'use strict';


	/**
	* StuEUIActorPrototypeBuild
	* @name  DS/XCTWebExperienceAppPlay/extensions/StuEUIActorPrototypeBuild
	* @constructor
	*/
	var StuEUIActorPrototypeBuild = StuEExperienceBasePrototypeBuild.extend(
		/** @lends DS/XCTWebExperienceAppPlay/extensions/StuEUIActorPrototypeBuild.prototype **/
		{
			_Create: function () {
			    var uiActor;
			    switch (this.QueryInterface('CATI3DExperienceObject').GetValueByName('data').QueryInterface('CATI3DExperienceObject').GetValueByName('__configurationName__')) {
					case "CXPText" :
						uiActor = new CXPText();
						break;
					case "CXPImage" :
						uiActor = new CXPImage();
						break;
					default :
						uiActor = new UIActor();
						break;
				}
				this._instance = uiActor;
				return this._Fill(uiActor).done(function () {
					return uiActor;
				});
			},

			_Fill: function (iUiActor) {
				var rep = this.QueryInterface('CATI3DXUIRep').Get();
				rep.registerPlayEvents(iUiActor);

				iUiActor.CATICXPUIActor = new StuCATICXPUIActor(this.GetObject(), iUiActor);
				return this._parent(iUiActor);
			},

			/** Get the built object.
			 * @public
			 */
			Get: function () {
				if (!UWA.is(this._instance)) {
					return this._Create();
				}
				return UWA.Promise.resolve(this._instance);
			},

			Free: function () {
				this._parent();
				var rep = this.QueryInterface('CATI3DXUIRep').Get();
				rep.releasePlayEvents();
			}
		});

	return StuEUIActorPrototypeBuild;
});
