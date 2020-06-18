define('DS/CATCXPModel/extensions/CATEVirtualPointActor3DGeoVisu',
[
	'UWA/Core',
	'DS/Visualization/SceneGraphFactory',
	'DS/CATCXPModel/extensions/CATE3DActor3DGeoVisu',
	'DS/Visualization/ThreeJS_DS',
    'DS/Visualization/Node3D',
    'DS/Mesh/MeshUtils'
],

// Declaration
function (
    UWA,
	SceneGraphFactory,
	CATE3DActor3DGeoVisu,
	THREE,
    Node3D,
	Mesh
    ) {
	'use strict';

	var CATEVirtualPathActor3DGeoVisu = CATE3DActor3DGeoVisu.extend(
		{
			init: function () {
				this._parent();
				this._pointNode = null;
			},

			destroy: function () {
				this._parent();

				if (this._pointNode) {
					this._pointNode.removeChildren();
					this._pointNode = null;
				}
			},

			setReady: function () {
				//Not used
			},

			isReady: function () {
				return true;
			},

			_Fill: function (iNode3D) {
				this._parent(iNode3D);

				// create sphere
				var expObject = this.QueryInterface('CATI3DExperienceObject');
				this._pointNode = new Node3D();;

				// set name
				this._pointNode.setName(expObject.GetValueByName('_varName'));

				// callbacks to refresh visu
				var self = this;

				iNode3D.addChild(this._pointNode);
			},

			/** 
			* @public
			*/
			GetLocalNodes: function () {
				return this._pointNode;
			},

		}
	);

	return CATEVirtualPathActor3DGeoVisu;
}
);

