/**
* CATECXPDirectionalLight
* @category Extension
* @name DS/CATCXPLightModel/extensions/CATECXPDirectionalLight
* @description Implements {@link DS/CATCXPLightModel/interfaces/CATICXPDirectionalLight CATICXPDirectionalLight}
* @constructor
*/
define('DS/CATCXPLightModel/extensions/CATECXPDirectionalLight',
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

    var CATECXPDirectionalLight = CAT3DXInterfaceImpl.extend(
	/** @lends DS/CATCXPLightModel/extensions/CATECXPDirectionalLight.prototype **/
    {
        init: function () {
            this._parent();
        },

        Build: function () {
            this.geovisuNode = this.QueryInterface('CATI3DGeoVisu');
            this.geovisuNode.GetNode();
        },

        SetDirection: function (direction) {
            var node = new Node3D();
            this.direction = direction;
            node.translateX(direction.x);
            node.translateY(direction.y);
            node.translateZ(direction.z);
            this.SetTargetPosition(node.getMatrixWorld());
        },

        GetDirection: function () {
            if (this.geovisuNode.targetNode && this.geovisuNode._node3D && this.geovisuNode._lightNode3D) {
                var targetPos = new THREE.Vector3().getPositionFromMatrix(this.geovisuNode.targetNode.getMatrixWorld());
                var lightPos = new THREE.Vector3().getPositionFromMatrix(this.geovisuNode._node3D.getMatrixWorld());
                return new THREE.Vector3(targetPos.x - lightPos.x, targetPos.y - lightPos.y, targetPos.z - lightPos.z).normalize();
            }
            return undefined;
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
            var diffuseColorEO = diffuseColor.QueryInterface('CATI3DExperienceObject');
        	// TODO : use public API of CATI3DGeoVisu. 
        	// this.geovisuNode.destroy() + this.geovisuNode.GetNode() should work
            var light = this.geovisuNode._createDirectionalLight(
                    diffuseColorEO.GetValueByName('r'),
                    diffuseColorEO.GetValueByName('g'),
                    diffuseColorEO.GetValueByName('b'),
                    expObject.GetValueByName('power')
            );
            light.target.position = new THREE.Vector3().getPositionFromMatrix(this.geovisuNode.targetNode.getMatrixWorld());
            light.target.updateMatrixWorld();

            if (UWA.is(this.geovisuNode._lightNode3D)) {
                this.geovisuNode._node3D.removeChild(this.geovisuNode._lightNode3D);
                this.geovisuNode._lightNode3D.removeChildren();
            }
            this.geovisuNode._lightNode3D = new LightNode3D(light, expObject.GetValueByName('_varName'));
            this.geovisuNode._node3D.addChild(this.geovisuNode._lightNode3D);
        },

        GetTargetPosition: function () {
            if (this.geovisuNode.attachTargetToLight)
                {return this.geovisuNode.targetNode.getMatrixWorld();}
            return this.geovisuNode._lightNode3D.light3js.target.matrixWorld;
        },

        AttachTargetToLight: function (attached) {
            this.geovisuNode.attachTargetToLight = attached;
            if (attached)
                {this.geovisuNode.targetNode.setMatrix(this.geovisuNode._lightNode3D.light3js.target.matrixWorld);}
        },

    });

    return CATECXPDirectionalLight;
});
