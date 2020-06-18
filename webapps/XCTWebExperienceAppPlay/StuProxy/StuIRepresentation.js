/**
 * @exports DS/XCTWebExperienceAppPlay/StuProxy/StuIRepresentation
*/

define('DS/XCTWebExperienceAppPlay/StuProxy/StuIRepresentation',
[
	'UWA/Core',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuProxy',
	'DS/Visualization/ThreeJS_DS'
],

// Declaration
function (
    UWA,
    StuProxy,
	THREE
    ) {
    'use strict';

    /**
	 * StuIRepresentation
	 * @name DS/XCTWebExperienceAppPlay/StuProxy/StuIRepresentation
	 * @constructor
	 */

    var StuIRepresentation = StuProxy.extend(
	/** @lends DS/XCTWebExperienceAppPlay/StuProxy/StuIRepresentation.prototype **/
    {
        init: function (iModelObject, iStuObject) {
            this._parent(iModelObject, iStuObject);
            this._modelObject = iModelObject;
        },
    	/** 
        * @public
        */
    	GetBoundingSphere: function (oSphere) {
    	    var pathElement = this._modelObject.QueryInterface('CATI3DGeoVisu').GetPathElement();
    	    var viewer = this._modelObject._experienceBase.getManager('CAT3DXVisuManager').getViewer();
    		var bS;
    		if (this._modelObject.QueryInterface('CATI3DGeoVisu').GetOverride().getVisibility()) {
    		    bS = pathElement.getBoundingSphere(viewer, 'visibleSpace');
    		}
    		else {
    		    bS = pathElement.getBoundingSphere(viewer, 'invisibleSpace');
    		}

    		oSphere.center.x = bS.center.x;
    		oSphere.center.y = bS.center.y;
    		oSphere.center.z = bS.center.z;
    		oSphere.radius = bS.radius;
    	},

    	/** 
        * @public
        */
    	GetBoundingBox: function (oBox, iTransform, iMode) {
    	    var modelGeoVisu = this._modelObject.QueryInterface('CATI3DGeoVisu');
    	    var pathElement = modelGeoVisu.GetPathElement();
    	    var viewer = this._modelObject._experienceBase.getManager('CAT3DXVisuManager').getViewer();
    		iMode = iMode ? iMode : 0;
    		var Bb;
    		if (modelGeoVisu.GetOverride().getVisibility()) {
    		    Bb = pathElement.getBoundingBox(null, viewer, 'visibleSpace');
    		}
    		else {
    		    Bb = pathElement.getBoundingBox(null, viewer, 'invisibleSpace');
    		}

    		if (iMode === 0) {
    			var matrix12 = iTransform.getArray();

    			var matrixWorld = new THREE.Matrix4(matrix12[0], matrix12[3], matrix12[6], matrix12[9],
											matrix12[1], matrix12[4], matrix12[7], matrix12[10],
											matrix12[2], matrix12[5], matrix12[8], matrix12[11],
											0.0, 0.0, 0.0, 1.0);
    			Bb.applyMatrix4(matrixWorld);
    		}

    		oBox.high.x = Bb.max.x;
    		oBox.high.y = Bb.max.y;
    		oBox.high.z = Bb.max.z;

    		oBox.low.x = Bb.min.x;
    		oBox.low.y = Bb.min.y;
    		oBox.low.z = Bb.min.z;
    	},

    	/** 
        * @public
        */
    	GetOrientedBoundingBox: function (oBox, iParams, iTransform) {
    	    var pathElement;
    	    var modelGeoVisu = this._modelObject.QueryInterface('CATI3DGeoVisu');
    	    if (iParams.excludeChildren){
    	        pathElement = modelGeoVisu.GetPathElement().clone();
    	        pathElement.externalPath.push(modelGeoVisu.GetLocalNodes());
    	    } else {
    	        pathElement = modelGeoVisu.GetPathElement();
    	    }
    	    var viewer = this._modelObject._experienceBase.getManager('CAT3DXVisuManager').getViewer();
    		var orientation = iParams.orientation ? iParams.orientation.getArray() : null;

    		var Bb;
    		if (modelGeoVisu.GetOverride().getVisibility()) {
    		    Bb = pathElement.getBoundingBox(null, viewer, 'visibleSpace');
    		}
    		else {
    		    Bb = pathElement.getBoundingBox(null, viewer, 'invisibleSpace');
    		}

    		if (orientation) {
    			var matrix12 = iTransform.getArray();

    			var matrixWorld = new THREE.Matrix4(matrix12[0], matrix12[3], matrix12[6], matrix12[9],
								   matrix12[1], matrix12[4], matrix12[7], matrix12[10],
								   matrix12[2], matrix12[5], matrix12[8], matrix12[11],
								   0.0, 0.0, 0.0, 1.0);

    			var matrixOrientation = new THREE.Matrix4(orientation[0], orientation[3], orientation[6], orientation[9],
								   orientation[1], orientation[4], orientation[7], orientation[10],
								   orientation[2], orientation[5], orientation[8], orientation[11],
								   0.0, 0.0, 0.0, 1.0);

    			var invMatrixOrientation = new THREE.Matrix4();
    			invMatrixOrientation = invMatrixOrientation.getInverse(matrixOrientation);
    			var matrixTransfo = new THREE.Matrix4();
    			matrixTransfo.multiplyMatrices(matrixWorld, invMatrixOrientation);

    			Bb.applyMatrix4(matrixTransfo);
    		}

    		oBox.high.x = Bb.max.x;
    		oBox.high.y = Bb.max.y;
    		oBox.high.z = Bb.max.z;

    		oBox.low.x = Bb.min.x;
    		oBox.low.y = Bb.min.y;
    		oBox.low.z = Bb.min.z;
    	}
    });

    return StuIRepresentation;
});

