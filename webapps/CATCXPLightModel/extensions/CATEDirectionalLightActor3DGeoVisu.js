/**
* CATEDirectionalLightActor3DGeoVisu
* @category Extension
* @name DS/CATCXPLightModel/extensions/CATEDirectionalLightActor3DGeoVisu
* @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu}
* @augments DS/CATCXPLightModel/extensions/CATELightActor3DGeoVisu
* @constructor
*/
define('DS/CATCXPLightModel/extensions/CATEDirectionalLightActor3DGeoVisu',
[
	'UWA/Core',
    'DS/CATCXPLightModel/extensions/CATELightActor3DGeoVisu',
    'DS/Visualization/LightNode3D',
    'DS/Visualization/ThreeJS_DS',
    'DS/CAT3DExpModel/CAT3DXModel',
    'DS/Visualization/Node3D'
],

// Declaration
function (
    UWA,
    CATELightActor3DGeoVisu,
    LightNode3D,
    THREE,
    CAT3DXModel,
    Node3D
    ) {
    'use strict';

    var CATEDirectionalLightActor3DGeoVisu = CATELightActor3DGeoVisu.extend(
	/** @lends DS/CATCXPLightModel/extensions/CATEDirectionalLightActor3DGeoVisu.prototype **/
	{
		init: function () {
		    this._parent();
		},

		_Fill: function (iNode3D) {
		    this._parent(iNode3D);

		    this.attachTargetToLight = true;

		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var diffuseColor = expObject.GetValueByName('diffuseColor');
		    var diffuseColorEo = diffuseColor.QueryInterface('CATI3DExperienceObject');

		    var directionalLight = this._createDirectionalLight(
                diffuseColorEo.GetValueByName('r'),
                diffuseColorEo.GetValueByName('g'),
                diffuseColorEo.GetValueByName('b'),
                expObject.GetValueByName('power')
            );
		    this.targetNode = this._createTarget(directionalLight, iNode3D);
		    this._lightNode3D = new LightNode3D(directionalLight, expObject.GetValueByName('_varName'));

		    var self = this;

		    this.listenTo(expObject, '_varposition.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshLight);
		        self.RequestVisuRefresh();
		    });

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
		    if (UWA.is(this.targetNode)) {
		        this._node3D.removeChild(this.targetNode);
		        this.targetNode.removeChildren();
		    }

		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var diffuseColor = expObject.GetValueByName('diffuseColor');
		    var diffuseColorEo = diffuseColor.QueryInterface('CATI3DExperienceObject');

		    var directionalLight = this._createDirectionalLight(
                diffuseColorEo.GetValueByName('r'),
                diffuseColorEo.GetValueByName('g'),
                diffuseColorEo.GetValueByName('b'),
                expObject.GetValueByName('power')
            );

		    this.targetNode = this._createTarget(directionalLight, this._node3D);
		    this._lightNode3D = new LightNode3D(directionalLight, expObject.GetValueByName('_varName'));


		    this._node3D.addChild(this._lightNode3D);
		},

		_createTarget: function (light3js, node3D)
		{
		    var target = new Node3D();
		    target.name = 'target';
		    node3D.addChild(target);
		    target.translate(-10, new THREE.Vector3(1, 0, 0.1));
		    if (this.attachTargetToLight) {
		        this.targetPosition = target.getMatrixWorld();
		    }
		    var vec = new THREE.Vector3();
		    light3js.target.position = vec.getPositionFromMatrix(this.targetPosition);
		    light3js.target.updateMatrixWorld();
		    return target;
		},


		_createDirectionalLight: function (r, g, b, power)
		{
		    var directionalLight = new THREE.DirectionalLight(this._rgbToHex(r, g, b),
                this._convertPowerForThreeLight(power)
            );

		    directionalLight.target = new THREE.Object3D();
		    return directionalLight;
		}
	});

    return CATEDirectionalLightActor3DGeoVisu;
}
);
