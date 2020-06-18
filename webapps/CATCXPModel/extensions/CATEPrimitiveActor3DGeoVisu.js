/**
 * CATEPrimitiveActor3DGeoVisu
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu} 
 * @augments DS/CATCXPModel/extensions/CATE3DActor3DGeoVisu
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu',
[
	'UWA/Core',
    'DS/CATCXPModel/extensions/CATE3DActor3DGeoVisu'
],

// Declaration
function (
    UWA,
    CATE3DActor3DGeoVisu
    ) {
    'use strict';

    var CATEPrimitiveActor3DGeoVisu = CATE3DActor3DGeoVisu.extend(
	/** @lends DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu.prototype **/
	{
		init: function () {
			this._parent();

		},

		_Fill: function (iNode3D) {
		    this._parent(iNode3D);
		    this.setReady(true);
		}
	});

    return CATEPrimitiveActor3DGeoVisu;
}
);
