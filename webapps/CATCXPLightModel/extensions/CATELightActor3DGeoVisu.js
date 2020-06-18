/**
* CATELightActor3DGeoVisu
* @category Extension
* @name DS/CATCXPLightModel/extensions/CATELightActor3DGeoVisu
* @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu}
* @augments DS/CATCXPModel/extensions/CATE3DActor3DGeoVisu
* @constructor
*/
define('DS/CATCXPLightModel/extensions/CATELightActor3DGeoVisu',
[
	'UWA/Core',
    'DS/CATCXPModel/extensions/CATE3DActor3DGeoVisu',
    'DS/Visualization/LightNode3D',
    'DS/Visualization/ThreeJS_DS',
    'DS/SceneGraphNodes/BillBoardNode3D',
    'DS/Visualization/SceneGraphFactory',
    'DS/CAT3DExpModel/CAT3DXModel',
	'DS/WebappsUtils/WebappsUtils',
    'DS/CATCXPModel/interfaces/CATICXPVariablesInit',
	'MathematicsES/MathsDef'
],

// Declaration
function (
    UWA,
    CATE3DActor3DGeoVisu,
    LightNode3D,
    THREE,
    BillBoardNode3D,
    SceneGraphFactory,
    CAT3DXModel,
    WebappsUtils,
    DSMath
    ) {
    'use strict';

    var CATELightActor3DGeoVisu = CATE3DActor3DGeoVisu.extend(
	/** @lends DS/CATCXPLightModel/extensions/CATELightActor3DGeoVisu.prototype **/
	{
		init: function () {
		    this._parent();
		},

		destroy: function () {
		    this._parent();

		    this.GetObject()._experienceBase.getManager('CAT3DXVisuManager').getViewer().renderer.recompileAllShaders();
		},

		_Fill: function (iNode3D) {
		    this._parent(iNode3D);

		    this._displayLightRep(iNode3D);

		    //this.SetIntensity(this.GetObject().GetValueByName('power'));

		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var diffuseColor = expObject.GetValueByName('diffuseColor');
		    var diffuseColorEo = diffuseColor.QueryInterface('CATI3DExperienceObject');
		    //this.SetColor(diffuseColor.QueryInterface('CATI3DExperienceObject').GetValueByName('r'),
		    //    diffuseColor.QueryInterface('CATI3DExperienceObject').GetValueByName('g'),
		    //    diffuseColor.QueryInterface('CATI3DExperienceObject').GetValueByName('b')
            //);

		    var self = this;
		    this.listenTo(expObject, 'power.CHANGED', function () {
		        //self.SetIntensity(self.QueryInterface('CATI3DExperienceObject').GetValueByName('power'));
		        self.frameVisuChanges.push(self._refreshLight);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(diffuseColorEo, 'r.CHANGED', function () {
		        //self.SetColor(diffuseColor.QueryInterface('CATI3DExperienceObject').GetValueByName('r'), self.diffuseColorG, self.diffuseColorB);
		        self.frameVisuChanges.push(self._refreshLight);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(diffuseColorEo, 'g.CHANGED', function () {
		        //self.SetColor(self.diffuseColorR, diffuseColor.QueryInterface('CATI3DExperienceObject').GetValueByName('g'), self.diffuseColorB);
		        self.frameVisuChanges.push(self._refreshLight);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(diffuseColorEo, 'b.CHANGED', function () {
		        //self.SetColor(self.diffuseColorR, self.diffuseColorG, diffuseColor.QueryInterface('CATI3DExperienceObject').GetValueByName('b'));
		        self.frameVisuChanges.push(self._refreshLight);
		        self.RequestVisuRefresh();
		    });

		    this.GetObject()._experienceBase.getManager('CAT3DXVisuManager').getViewer().renderer.recompileAllShaders();
		    this.setReady(true);
		},

		_refreshLight: function () {
			console.warn('CATELightActor3DGeoVisu._refreshLight : to be overriden !');
		    //this.power = GetIntensity();
		    //var diffuseColor = this.QueryInterface('CATI3DExperienceObject').GetValueByName('diffuseColor');
		    //this.SetColor(diffuseColor.QueryInterface('CATI3DExperienceObject').GetValueByName('r'),
		    //    diffuseColor.QueryInterface('CATI3DExperienceObject').GetValueByName('g'),
		    //    diffuseColor.QueryInterface('CATI3DExperienceObject').GetValueByName('b')
            //);
		},

		_convertPowerForThreeLight: function (power) {
		    return Math.sqrt(power * Math.PI);
		},

		_displayLightRep: function (iNode3D) {
		    //texture
		    var texture = THREE.ImageUtils.loadTexture(WebappsUtils.getWebappsBaseUrl() + 'CATCXPLightModel/assets/icons/32/' + CAT3DXModel.GetObjectUI(this.GetObject().GetType(), 'iconName'));

		    var mat = new THREE.MeshBasicMaterial({
		        map: texture,
		        side: THREE.DoubleSide
		    });
		    mat.force = true;

		    //quad
		    var size = 150.0;
		    var geomParams = {
		        width: size,
		        height: size,
		        fill: true,
		        color: new THREE.Color(0.0, 0.0, 0.0, 255.0),
                reflectivity: 0
		    };
		    var rectNode = SceneGraphFactory.createRectangleNode(geomParams);
		    rectNode.material = mat;
		    rectNode.mesh3js.castShadow = false;
		    rectNode.mesh3js.receiveShadow = false;

		    var params = {
		        viewpoint: this.GetObject()._experienceBase.getManager('CAT3DXVisuManager').getViewer().currentViewpoint,
		        position: new THREE.Vector3(),
		        name: 'Spherical Billboard',
		        type: 'Spherical'
		    };
		    this.lightRep = new BillBoardNode3D(params);
		    this.lightRep.addChild(rectNode);
		    rectNode.translate(-size/2, new THREE.Vector3(1, 1, 0));
		    iNode3D.addChild(this.lightRep);
		    this.lightRep.setMatrix(new THREE.Matrix4().setPosition(new THREE.Vector3(0, 0, 0)));
		},

		_deactivateLightRep: function() {
		    if (UWA.is(this.lightRep)) {
		        this._node3D.removeChild(this.lightRep);
		        this.lightRep.removeChildren();
		        this.lightRep = null;
		    }
		},

		_activateLightRep: function () {
		    if (this.lightRep === undefined) {
		        this._displayLightRep(this._node3D);
		    }
		},

		GetBoundingBox: function (iMode) {
		    var node = this.Get();
		    iMode = iMode ? iMode : 0;
		    var Bb;
		    if (node.visible) {
		        Bb = new THREE.Box3(new THREE.Vector3(0, 0, 0), new THREE.Vector3(0, 0, 0));
		    }
		    else {
		        Bb = node.getBoundingBox('invisibleSpace');
		    }

		    if (iMode === 0) {
		        var transform = new DSMath.Transformation();
		        var catiMovable = this.QueryInterface('CATIMovable');
		        catiMovable.GetAbsPosition(transform);
		        var matrix12 = transform.getArray();

		        var matrixWorld = new THREE.Matrix4(matrix12[0], matrix12[3], matrix12[6], matrix12[9],
                                            matrix12[1], matrix12[4], matrix12[7], matrix12[10],
                                            matrix12[2], matrix12[5], matrix12[8], matrix12[11],
                                            0.0, 0.0, 0.0, 1.0);
		        Bb.applyMatrix4(matrixWorld);
		    }
		    return Bb;
		},

		GetLocalNodes: function () {
		    //return this._lightNode3D;
		},

		_rgbToHex: function (r, g, b) {
		    return '#' + this._componentToHex(r) + this._componentToHex(g) + this._componentToHex(b);
		},

		_componentToHex: function (c) {
		    var hex = c.toString(16);
		    return hex.length === 1 ? '0' + hex : hex;
		}
	});

    return CATELightActor3DGeoVisu;
});
