/**
* CATECXPSpotLight
* @category Extension
* @name DS/CATCXPLightModel/extensions/CATECXPSpotLight
* @description Implements {@link DS/CATCXPLightModel/interfaces/CATICXPSpotLight CATICXPSpotLight}
* @constructor
*/
define('DS/CATCXPLightModel/extensions/CATECXPSpotLight',
// dependencies
[
    'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
    'DS/Visualization/Node3D',
    'DS/Visualization/ThreeJS_DS',
    'DS/Visualization/LightNode3D'
],

function (
    UWA,
    CAT3DXInterfaceImpl,
    Node3D,
    THREE,
    LightNode3D
    ) {
    'use strict';


    var CATECXPSpotLight = CAT3DXInterfaceImpl.extend(
	/** @lends DS/CATCXPLightModel/extensions/CATECXPSpotLight.prototype **/
    {
        init: function () {
            this._parent();
        },

        Build: function () {
            this.geovisuNode = this.QueryInterface('CATI3DGeoVisu');
            this.geovisuNode.GetNode();
        },

        GetTargetPosition: function () {
            if (this.geovisuNode.attachTargetToLight)
                {var targetPos = this.geovisuNode.targetNode.getMatrixWorld();}
            else
                {var targetPos = this.geovisuNode._lightNode3D.light3js.target.matrixWorld;}
            return targetPos;
        },

        AttachTargetToLight: function (attached) {
            this.geovisuNode.attachTargetToLight = attached;
            if (attached)
                {this.geovisuNode.targetNode.setMatrix(this.geovisuNode._lightNode3D.light3js.target.matrixWorld);}
        },

        SetOuterAngle: function (angle) {
            this.QueryInterface('CATI3DExperienceObject').SetValueByName('outerAngle', angle);
        },

        GetOuterAngle: function () {
            return this.QueryInterface('CATI3DExperienceObject').GetValueByName('outerAngle');
        },

        SetPenumbra: function (penumbra) {
            this.QueryInterface('CATI3DExperienceObject').SetValueByName('innerAngle', penumbra);
        },

        GetPenumbra: function () {
            return this.QueryInterface('CATI3DExperienceObject').GetValueByName('innerAngle');
        },

        SetCastShadow: function (castShadow) {
            this.QueryInterface('CATI3DExperienceObject').SetValueByName('castShadows', castShadow);
        },

        GetCastShadow: function () {
            return this.QueryInterface('CATI3DExperienceObject').GetValueByName('castShadows');
        },

        SetTargetPosition: function (targetPosition) {
            this.targetPosition = targetPosition;

            if (this.geovisuNode.targetNode === undefined) {
                this.geovisuNode.targetNode = new Node3D('target');
                this.geovisuNode._node3D.addChild(this.geovisuNode.targetNode);
            }
            this.geovisuNode.targetNode.setMatrix(targetPosition);

            var expObject = this.QueryInterface('CATI3DExperienceObject');
            var diffuseColor = expObject.GetValueByName('diffuseColor');
            var diffuseColorEo = diffuseColor.QueryInterface('CATI3DExperienceObject');
        	// TODO : use public API of CATI3DGeoVisu. 
        	// this.geovisuNode.destroy() + this.geovisuNode.GetNode() should work
            var light = this.geovisuNode._createSpotLight(
                diffuseColorEo.GetValueByName('r'),
                diffuseColorEo.GetValueByName('g'),
                diffuseColorEo.GetValueByName('b'),
                expObject.GetValueByName('power'),
                expObject.GetValueByName('outerAngle'),
                expObject.GetValueByName('innerAngle'),
                expObject.GetValueByName('castShadows')
            );
            light.target.position = new THREE.Vector3().getPositionFromMatrix(this.geovisuNode.targetNode.getMatrixWorld());
            light.target.updateMatrixWorld();

            if (UWA.is(this.geovisuNode._lightNode3D)) {
                this.geovisuNode._node3D.removeChild(this.geovisuNode._lightNode3D);
                this.geovisuNode._lightNode3D.removeChildren();
            }
            this.geovisuNode._lightNode3D = new LightNode3D(light, expObject.GetValueByName('_varName'));
            this.geovisuNode._node3D.addChild(this.geovisuNode._lightNode3D);
        }

    });

    return CATECXPSpotLight;
});
