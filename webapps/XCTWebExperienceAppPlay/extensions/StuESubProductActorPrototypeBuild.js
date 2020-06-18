/**
 * @exports DS/XCTWebExperienceAppPlay/extensions/StuESubProductActorPrototypeBuild
*/
define('DS/XCTWebExperienceAppPlay/extensions/StuESubProductActorPrototypeBuild',
[
	'UWA/Core',
	'DS/XCTWebExperienceAppPlay/extensions/StuE3DActorPrototypeBuild',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuCATIMovable',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuIRepresentation',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuCATI3DGeoVisu',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuCATI3DXGraphicalProperties'
],

// Declaration
function (
	UWA,
	StuE3DActorPrototypeBuild,
    StuCATIMovable,
    StuIRepresentation,
    StuCATI3DGeoVisu,
    StuCATI3DXGraphicalProperties
	) {
	'use strict';

	/**
	 * StuESubProductActorPrototypeBuild
	 * @name DS/XCTWebExperienceAppPlay/extensions/StuESubProductActorPrototypeBuild
	 * @constructor
	 */

	var StuESubProductActorPrototypeBuild = StuE3DActorPrototypeBuild.extend(
	/** @lends DS/XCTWebExperienceAppPlay/extensions/StuESubProductActorPrototypeBuild.prototype **/
	{
		_Fill: function (iProductActor) {
		    iProductActor.CATIMovable = new StuCATIMovable(this.GetObject(), iProductActor);
		    iProductActor.StuIRepresentation = new StuIRepresentation(this.GetObject(), iProductActor);
		    iProductActor.CATI3DGeoVisu = new StuCATI3DGeoVisu(this.GetObject(), iProductActor);
		    iProductActor.CATI3DXGraphicalProperties = new StuCATI3DXGraphicalProperties(this.GetObject(), iProductActor);
			return this._parent(iProductActor);
		},

		_ProjectSubActors: function (iActor3D, iExperienceObject) {
			var self = this;
			var cache = iExperienceObject.QueryInterface('CATI3DXAssetHolder').getCache();
			var overrideChildren = (cache && cache.OverrideChildren) ? cache.OverrideChildren : [];
		
			var promises = [];
			var overrideChildrenStu = [];
			for (var i = 0; i < overrideChildren.length; ++i) {
			    promises.push(overrideChildren[i].QueryInterface('StuIPrototypeBuild').Get().done(function (iStu) {
			        overrideChildrenStu.push(iStu);
			    }));
			}
			return UWA.Promise.all(promises).done(function () {
			    if (UWA.is(overrideChildrenStu)) {
			        iActor3D['subActors'] = overrideChildrenStu;
			    }

			    //Object.defineProperty(iActor3D, 'subActors', {
			    //    enumerable: true,
			    //    configurable: true,
			    //    get: function () {
			    //        return overrideChildrenStu;
			    //    }
			    //});
			});			
		}
	});

	return StuESubProductActorPrototypeBuild;
});


