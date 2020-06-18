/**
* CATEPointLightActor3DGeoVisu
* @category Extension
* @name DS/CATCXPLightModel/extensions/CATEPointLightActor3DGeoVisu
* @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu}
* @augments DS/CATCXPLightModel/extensions/CATELightActor3DGeoVisu
* @constructor
*/
define('DS/CATCXPLightModel/extensions/CATEPointLightActor3DGeoVisu',
[
	'UWA/Core',
    'DS/CATCXPLightModel/extensions/CATELightActor3DGeoVisu',
    'DS/Visualization/LightNode3D',
    'DS/Visualization/ThreeJS_DS'
],

// Declaration
function (
    UWA,
    CATELightActor3DGeoVisu,
    LightNode3D,
    THREE
    ) {
    'use strict';

    var CATEPointLightActor3DGeoVisu = CATELightActor3DGeoVisu.extend(
	/** @lends DS/CATCXPLightModel/extensions/CATEPointLightActor3DGeoVisu.prototype **/
	{
		init: function () {
		    this._parent();
		},

		destroy: function () {
		    this._parent();
		},

		_Fill: function (iNode3D) {
		    this._parent(iNode3D);

		    this._lightNode3D = new LightNode3D(this._createPointLight(), this.QueryInterface('CATI3DExperienceObject').GetValueByName('_varName'));

		    iNode3D.addChild(this._lightNode3D);
		},

		GetLocalNodes: function () {
		    return this._lightNode3D;
		},

		_refreshLight: function () {
		    this._parent();
		    if (UWA.is(this._lightNode3D)) {
		        this._node3D.removeChild(this._lightNode3D);
		        this._lightNode3D.removeChildren();
		    }

		    this._lightNode3D = new LightNode3D(this._createPointLight(), this.QueryInterface('CATI3DExperienceObject').GetValueByName('_varName'));
		    this._node3D.addChild(this._lightNode3D);
		},

		_createPointLight: function () {
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var diffuseColor = expObject.GetValueByName('diffuseColor');
		    var diffuseColorEo = diffuseColor.QueryInterface('CATI3DExperienceObject');
		    var pointLight = new THREE.PointLight(this._rgbToHex(
                    diffuseColorEo.GetValueByName('r'),
                    diffuseColorEo.GetValueByName('g'),
                    diffuseColorEo.GetValueByName('b')),
                this._convertPowerForThreeLight(expObject.GetValueByName('power'))
            );
		    return pointLight;
		}
	});

    return CATEPointLightActor3DGeoVisu;
}
);
