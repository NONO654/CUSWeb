/**
* CATESpotLightActor3DGeoVisu
* @category Extension
* @name DS/CATCXPLightModel/extensions/CATESpotLightActor3DGeoVisu
* @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu}
* @augments DS/CATCXPLightModel/extensions/CATELightActor3DGeoVisu
* @constructor
*/
define('DS/CATCXPLightModel/extensions/CATESpotLightActor3DGeoVisu',
[
	'UWA/Core',
    'DS/CATCXPLightModel/extensions/CATELightActor3DGeoVisu',
    'DS/Visualization/LightNode3D',
    'DS/Visualization/ThreeJS_DS',
    'DS/Visualization/Node3D'
    //'DS/SWXWebLaunchPad/SWXWebFormExt1/src/threejs-r80/build/three.js'
],

// Declaration
function (
    UWA,
    CATELightActor3DGeoVisu,
    LightNode3D,
    THREE,
    Node3D
    //THREE_R80
    ) {
    'use strict';

    var CATESpotLightActor3DGeoVisu = CATELightActor3DGeoVisu.extend(
	/** @lends DS/CATCXPLightModel/extensions/CATESpotLightActor3DGeoVisu.prototype **/
	{
		init: function () {
		    this._parent();
		},

		_Fill: function (iNode3D) {
		    this._parent(iNode3D);
		    //this.SetOuterAngle(this.QueryInterface('CATI3DExperienceObject').GetValueByName('outerAngle'));
		    //this.SetPenumbra(this.QueryInterface('CATI3DExperienceObject').GetValueByName('innerAngle'));
		    //this.SetCastShadow(this.QueryInterface('CATI3DExperienceObject').GetValueByName('castShadows'));

		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var diffuseColor = expObject.GetValueByName('diffuseColor');
		    var diffuseColorEo = diffuseColor.QueryInterface('CATI3DExperienceObject');

		    this.attachTargetToLight = true;

		    var spotLight = this._createSpotLight(
                diffuseColorEo.GetValueByName('r'),
                diffuseColorEo.GetValueByName('g'),
                diffuseColorEo.GetValueByName('b'),
                expObject.GetValueByName('power'),
                expObject.GetValueByName('outerAngle'),
                expObject.GetValueByName('innerAngle'),
                expObject.GetValueByName('castShadows')
            );
		    this.targetNode = this._initTarget(spotLight, iNode3D);
		    this._lightNode3D = new LightNode3D(spotLight, expObject.GetValueByName('_varName'));

		    var self = this;
		    this.listenTo(expObject, 'outerAngle.CHANGED', function () {
		        //self.SetOuterAngle(expObject.GetValueByName('outerAngle'));
		        self.frameVisuChanges.push(self._refreshLight);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(expObject, 'innerAngle.CHANGED', function () {
		        //self.SetPenumbra(expObject.GetValueByName('innerAngle'));
		        self.frameVisuChanges.push(self._refreshLight);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(expObject, 'castShadows.CHANGED', function () {
		        //self.SetCastShadow(expObject.GetValueByName('castShadows'));
		        self.frameVisuChanges.push(self._refreshLight);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(expObject, '_varposition.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshLight);
		        self.RequestVisuRefresh();
		    });

		    iNode3D.addChild(this._lightNode3D);

		},

		GetLocalNodes: function () {
		    return this._lightNode3D;
		},

		_getDirection: function () {
		    if (this.targetNode && this._node3D && this._lightNode3D) {
		        var targetPos = new THREE.Vector3().getPositionFromMatrix(this.targetNode.getMatrixWorld());
		        var lightPos = new THREE.Vector3().getPositionFromMatrix(this._node3D.getMatrixWorld());
		        return new THREE.Vector3(targetPos.x - lightPos.x, targetPos.y - lightPos.y, targetPos.z - lightPos.z).normalize();
		    }
		    return undefined;
		},


		//SetTargetPositionTst: function (x, y, z) {
		//    var targetPosition = new THREE.Matrix4(1, 0, 0, 0,
        //                                           0, 1, 0, 0,
        //                                           0, 0, 1, 0,
        //                                           x, y, z, 1);
		//    //targetPosition.setPosition(x, y, z);
		//    this.SetTargetPosition(targetPosition);
		//},

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

		    var spotLight = this._createSpotLight(
                diffuseColorEo.GetValueByName('r'),
                diffuseColorEo.GetValueByName('g'),
                diffuseColorEo.GetValueByName('b'),
                expObject.GetValueByName('power'),
                expObject.GetValueByName('outerAngle'),
                expObject.GetValueByName('innerAngle'),
                expObject.GetValueByName('castShadows')
            );

		    this.targetNode = this._createTarget(spotLight, this._node3D);
		    this._lightNode3D = new LightNode3D(spotLight, expObject.GetValueByName('_varName'));
		    this._node3D.addChild(this._lightNode3D);
		},



		_getOuterAngle: function (angle) {
		    return (angle / 2 % 360) / 360 * 2 * Math.PI;
		},

		_getInnerAngle: function () {
		    return Math.max(this.QueryInterface('CATI3DExperienceObject').GetValueByName('innerAngle') / 100.0 * this._getOuterAngle() - 0.001, 0.0);
		},

		_createSpotLight: function (r, g, b, power, outerAngle, penumbra, castShadow) {

		    var spotLight = new THREE.SpotLight(this._rgbToHex(r, g, b),
                    this._convertPowerForThreeLight(power),
                    0, //distance
                    this._getOuterAngle(outerAngle),
                    1 //exponent
            );
		    spotLight.castShadow = castShadow;
		    spotLight.penumbra = Math.min(1, Math.max(0, penumbra / this._getOuterAngle(outerAngle)));

		    spotLight.target = new THREE.Object3D();
		    return spotLight;
		},

		_initTarget: function (light3js, node3D) {
		    var _varposition = this.QueryInterface('CATI3DExperienceObject').GetValueByName('_varposition');
		    var target = new Node3D();
		    target.name = 'target';
            if (this.attachTargetToLight)
		        {node3D.addChild(target);}
		    target.setMatrix(new THREE.Matrix4(_varposition[0], _varposition[3], _varposition[6], _varposition[9],
		        							            _varposition[1], _varposition[4], _varposition[7], _varposition[10],
		        							            _varposition[2], _varposition[5], _varposition[8], _varposition[11],
		        							            0.0, 0.0, 0.0, 1.0));
		    target.translate(10, new THREE.Vector3(1, 0, 0.1));
		    if (this.attachTargetToLight)
		        {this.targetPosition = target.getMatrixWorld();}

		    var vec = new THREE.Vector3();
		    light3js.target.position = vec.getPositionFromMatrix(this.targetPosition);
		    light3js.target.updateMatrixWorld();
		    return target;
		},

		_createTarget: function (light3js, node3D) {
		    var target = new Node3D();
		    target.name = 'target';
		    node3D.addChild(target);
		    target.translate(10, this._getDirection());//new THREE.Vector3(1, 0, 0.1));

		    if (this.attachTargetToLight)
		        {this.targetPosition = target.getMatrixWorld();}

		    var vec = new THREE.Vector3();
		    light3js.target.position = vec.getPositionFromMatrix(this.targetPosition);
		    light3js.target.updateMatrixWorld();
		    return target;
		},

		//_initShadows: function (directionalLight) {
		//    directionalLight.shadowCameraLeft = -3000.0;
		//    directionalLight.shadowCameraRight = 3000.0;
		//    directionalLight.shadowCameraBottom = -3000.0;
		//    directionalLight.shadowCameraTop = 3000.0;
		//    directionalLight.shadowCameraNear = 10;
		//    directionalLight.shadowCameraFar = 10000;
		//    directionalLight.shadowBias = 0.0001;
		//    directionalLight.shadowDarkness = 0.0;
		//    directionalLight.shadowMapWidth = 1024;
		//    directionalLight.shadowMapHeight = 1024;
		//},

		_updateShadows: function (light3js) {
		//    if (light3js.castShadow) {
		//        //var distLightScene = light3js.position.distanceTo(light3js.target.position);

		//        var angle = Math.PI * Math.max(0.1, 0.5 - this.GetObject()._experienceBase.getManager('CAT3DXVisuManager').getViewer().dirLightLatitude);
		//        var side = Math.sin(angle) + (Math.cos(angle) + 1) / Math.tan(angle);

		//        var radius = 1;
		//        //if (light3js.shadowCamera && !light3js.LiSPSM) {

		//        //    light3js.shadowCamera.far = distLightScene + side;//* boundingSphere.radius;
		//        //    light3js.shadowCamera.near = Math.max(0.001 * light3js.shadowCamera.far, distLightScene - radius);//boundingSphere.radius);
		//        //    light3js.shadowCamera.left = -radius;//boundingSphere.radius;
		//        //    light3js.shadowCamera.right = radius;//boundingSphere.radius;
		//        //    light3js.shadowCamera.bottom = -radius;//boundingSphere.radius;
		//        //    light3js.shadowCamera.top = radius;//boundingSphere.radius;

		//        //    //light.shadowCamera.fov = (360.0 / Math.PI) * 2.0 * Math.atan( boundingScene.radius / distLightScene );

		//        //    light3js.shadowCamera.updateProjectionMatrix();

		//        //} else {

		//            light3js.shadowCameraFar = 1000;//distLightScene + side * radius;//boundingSphere.radius;
		//            light3js.shadowCameraNear = Math.max(0.001 * light3js.shadowCameraFar, 0);//boundingSphere.radius);
		    light3js.shadowCameraFov = this.QueryInterface('CATI3DExperienceObject').GetValueByName('outerAngle');
		//        //}
		//    }
		}
	});

    return CATESpotLightActor3DGeoVisu;
}
);
