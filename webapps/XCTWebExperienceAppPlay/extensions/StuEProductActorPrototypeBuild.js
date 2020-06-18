/**
 * @exports DS/XCTWebExperienceAppPlay/extensions/StuEProductActorPrototypeBuild
*/
define('DS/XCTWebExperienceAppPlay/extensions/StuEProductActorPrototypeBuild',
[
	'UWA/Core',
	'DS/XCTWebExperienceAppPlay/extensions/StuE3DActorPrototypeBuild'
],

// Declaration
function (
	UWA,
	StuE3DActorPrototypeBuild
	) {
	'use strict';

	/**
	 * StuEProductActorPrototypeBuild
	 * @name DS/XCTWebExperienceAppPlay/extensions/StuEProductActorPrototypeBuild
	 * @constructor
	 */

	var StuEProductActorPrototypeBuild = StuE3DActorPrototypeBuild.extend(
	/** @lends DS/XCTWebExperienceAppPlay/extensions/StuEProductActorPrototypeBuild.prototype **/
	{
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
			promises.push(this._BuildProjectValue(iExperienceObject, 'actors'));
			return UWA.Promise.all(promises).done(function () {
			    var projectValue = iActor3D.CATI3DExperienceObject.GetValueByName('actors');
			    projectValue = projectValue.concat(overrideChildrenStu);
			    if (UWA.is(projectValue)) {
			        iActor3D['subActors'] = projectValue;
			    }

			    //Object.defineProperty(iActor3D, 'subActors', {
			    //    enumerable: true,
			    //    configurable: true,
			    //    get: function () {
			    //        var actors = iActor3D.CATI3DExperienceObject.GetValueByName('actors');
			    //        return actors.concat(overrideChildrenStu);
			    //    }
			    //});
			});
		}
	});

	return StuEProductActorPrototypeBuild;
});


