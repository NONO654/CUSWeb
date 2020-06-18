/**
 * @exports DS/XCTWebExperienceAppPlay/extensions/StuE3DActorPrototypeBuild
*/
define('DS/XCTWebExperienceAppPlay/extensions/StuE3DActorPrototypeBuild',
[
	'UWA/Core',
	'DS/XCTWebExperienceAppPlay/extensions/StuEExperienceBasePrototypeBuild',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuCATIMovable',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuIRepresentation',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuCATI3DGeoVisu',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuCATI3DXGraphicalProperties'
],

// Declaration
function (
	UWA,
	StuEExperienceBasePrototypeBuild,
    StuCATIMovable,
    StuIRepresentation,
    StuCATI3DGeoVisu,
    StuCATI3DXGraphicalProperties
	) {
	'use strict';

	/**
	 * StuE3DActorPrototypeBuild
	 * @name DS/XCTWebExperienceAppPlay/extensions/StuE3DActorPrototypeBuild
	 * @constructor
	 */

	var StuE3DActorPrototypeBuild = StuEExperienceBasePrototypeBuild.extend(
	/** @lends DS/XCTWebExperienceAppPlay/extensions/StuE3DActorPrototypeBuild.prototype **/
	{

		_Fill: function (iActor3D) {
		    var self = this;
		    iActor3D.CATIMovable = new StuCATIMovable(this.GetObject(), iActor3D);
		    iActor3D.StuIRepresentation = new StuIRepresentation(this.GetObject(), iActor3D);
		    iActor3D.CATI3DGeoVisu = new StuCATI3DGeoVisu(this.GetObject(), iActor3D);
		    iActor3D.CATI3DXGraphicalProperties = new StuCATI3DXGraphicalProperties(this.GetObject(), iActor3D);
			return this._parent(iActor3D).done(function () {
				return self._ProjectSubActors(iActor3D, self.QueryInterface('CATI3DExperienceObject'));
			});
		},

		_ProjectSubActors: function (iActor3D, iExperienceObject) {
			return this._Project(iActor3D, iExperienceObject, 'actors', 'subActors');
		}
	});

	return StuE3DActorPrototypeBuild;
});

