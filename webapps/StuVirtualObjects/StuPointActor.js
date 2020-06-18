define('DS/StuVirtualObjects/StuPointActor', ['DS/StuCore/StuContext', 'MathematicsES/MathNameSpace', 'DS/StuRenderEngine/StuActor3D'], function (STU, DSMath) {
	'use strict';

	/**
	 * Describe a point object.
	 *
	 * @exports PointActor
	 * @class
	 * @constructor
	 * @public
	 * @extends STU.Actor3D
	 * @memberof STU
	 * @alias STU.PointActor
	 */
	var PointActor = function() {
		STU.Actor3D.call(this);

		//
		// A point is not clickable
		// This Object.defineProperty is intended to overwrite Actor3D.clickable
		//
		Object.defineProperty(this, 'clickable', {
			enumerable: true,
			configurable: true,
			get: function() {
				return false;
			},
			set: function() {
				this.CATI3DXGraphicalProperties.SetPickMode(false);
			}
		});

		//
		// A point has no color
		// This Object.defineProperty is intended to overwrite Actor3D.color
		//
		Object.defineProperty(this, 'color', {
			enumerable: true,
			configurable: true,
			get: function() {
				return new STU.Color(0, 0, 0);
			},
			set: function() {}
		});
	};

	//////////////////////////////////////////////////////////////////////////////
	//                           Prototype definitions                          //
	//////////////////////////////////////////////////////////////////////////////
	PointActor.prototype = new STU.Actor3D();
	PointActor.prototype.constructor = PointActor;

	/**
	 * Returns the point's coordinate of this STU.PointActor.
	 * By default, the function uses the World referential.
	 *
	 * @method
	 * @public
	 * @param {STU.Actor3D} [iRef] instance object corresponding to the referential
	 * @return {DSMath.Vector3D} instance representing the {X,Y,Z} coordinates in model unit (mm)
	 */
	PointActor.prototype.getCoordinate = function (iRef) { // IBS GLOBE REVIVAL OK
	    var oPtCoordinates = new DSMath.Vector3D();
	    /*var absPosOfRef;
	    if (iRef !== undefined && iRef !== null) {
	        if (!(iRef instanceof STU.Actor3D)) {
	            console.log('[STU.PointActor.getCoordinate] given iRef is not an Actor3D');
	            throw new TypeError('iRef argument is not a STU.Actor3D');
	        } else {
	            var absPosOfRef = iRef.getTransform();
	        }
	    }
	    else {
	        absPosOfRef = new DSMath.Transformation();
	    }
	    var absPosOfPt = this.getTransform();
	    var relPosOfPt = DSMath.Transformation.multiply(absPosOfRef.getInverse(), absPosOfPt);
	    oPtCoordinates.x = relPosOfPt.vector.x;
	    oPtCoordinates.y = relPosOfPt.vector.y;
	    oPtCoordinates.z = relPosOfPt.vector.z;
	    return oPtCoordinates;*/

	    var PosOfPt = this.getTransform(iRef);
	    oPtCoordinates.x = PosOfPt.vector.x;
	    oPtCoordinates.y = PosOfPt.vector.y;
	    oPtCoordinates.z = PosOfPt.vector.z;
	    return oPtCoordinates;
	};

	//SVV<-

	//////////////////////////////////////////////////////////////////////////////
	//                            STU expositions.                              //
	//////////////////////////////////////////////////////////////////////////////

	// Expose only those entities in STU namespace.
	STU.PointActor = PointActor;

	return PointActor;
});

define('StuVirtualObjects/StuPointActor', ['DS/StuVirtualObjects/StuPointActor'], function (PointActor) {
    'use strict';

    return PointActor;
});
