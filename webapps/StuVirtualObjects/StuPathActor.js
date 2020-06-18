define('DS/StuVirtualObjects/StuPathActor', ['DS/StuCore/StuContext', 'MathematicsES/MathsDef', 'DS/StuRenderEngine/StuActor3D'], function (STU, DSMath) {
    'use strict';

    /**
    * Describe a path object.
    *
    * @exports PathActor
    * @class
    * @constructor
    * @public
    * @extends STU.Actor3D
    * @memberof STU
    * @alias STU.PathActor
    */
    var PathActor = function () {
        STU.Actor3D.call(this);

        this.VIAIIxpVirtualPath;

        //
        // A path is not clickable
        // This Object.defineProperty is intended to overwrite Actor3D.clickable
        //
        // Object.defineProperty(this, 'clickable', {
        //     enumerable: true,
        //     configurable: true,
        //     get: function () {
        //         return false;
        //     },
        //     set: function (iVisible) {
        //         if (iVisible != 1 && iVisible != 0) {
        //             throw new TypeError('iVisible argument is not a boolean');
        //         }

        //         if (this.CATI3DXGraphicalProperties !== null && this.CATI3DXGraphicalProperties !== undefined){
        //             this.CATI3DXGraphicalProperties.SetShowMode(iVisible == 1);
        //         }
        //     }
        // });


        //
        // A path has no color
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
    PathActor.prototype = new STU.Actor3D();
    PathActor.prototype.constructor = PathActor;


    /**
     * Process to execute when this STU.PathActor is deactivating.
     *
     * @method
     * @private
     */
    // PathActor.prototype.onDeactivate = function() {
    //     console.log('PathActor.prototype.onDeactivate');
    //     this.CATI3DXGraphicalProperties.SetPickMode(true);
    // };

    /**
     * Returns the length of this STU.PathActor.
     *
     * @method
     * @public
     * @return {number} The length value in model unit (mm)
     */
    PathActor.prototype.getLength = function () {
        return this.VIAIIxpVirtualPath.GetLength();
    };

    /**
     * Returns the point's coordinate of this STU.PathActor corresponding to the given length ratio.
		 * if you want the point at the curvilinear distance d from the start of the path, you must enter as parameter value:
		 *   iParam = d/L where L = total length of path given by getLength function
     * By default, the function uses the World referential.
     *
     * @method
     * @public
     * @param {number} iParam curvilinear distance from start of Path express in ratio of length within the range [0,1]
     * @param {STU.Actor3D} [iRef] instance object corresponding to the referential
     * @return {DSMath.Vector3D} instance representing the {X,Y,Z} coordinates in model unit (mm)
     */
    PathActor.prototype.getValue = function (iParam, iRef) {
        var oCoordinates = new DSMath.Vector3D();
        oCoordinates.x = 0;
        oCoordinates.y = 0;
        oCoordinates.z = 0;

        if (iParam > 1 || iParam < 0) {
            console.log('[STU.PathActor.getValue] ratio of length not within the range [0,1]');
            throw new TypeError('iParam argument is not within the range [0,1]');
        }

        if (iRef !== undefined && iRef !== null) {
            if (!(iRef instanceof STU.Actor3D)) {
                console.log('[STU.PathActor.getValue] given iRef is not an Actor3D');
                throw new TypeError('iRef argument is not a STU.Actor3D');
            }
            else {
                if (iRef.CATIMovable !== undefined && iRef.CATIMovable !== null) {
                    this.VIAIIxpVirtualPath.GetValue(iParam, iRef.CATIMovable, oCoordinates);
                }
                else {
                    console.log('[STU.PathActor.getValue] given Actor3D as iRef has no CATIMovable property');
                    throw new TypeError('iRef argument is a STU.Actor3D without CATIMovable property');
                }
            }
        }
        else {
            this.VIAIIxpVirtualPath.GetValue(iParam, null, oCoordinates);
        }
        return oCoordinates;
    };

		/**
		 * Returns an array of point corresponding to the discretization of this STU.PathActor
		 * iParam is the distance separating 2 contiguous points, expressed as a ratio of the Length of the path given by getLength function 
		 * By default, the function uses the World referential.
		 *
		 * @method
		 * @public
		 * @param {number} iParam curvilinear distance increment between 2 Points express in ratio of path's length within the range [0,1]
		 * @param {STU.Actor3D} [iRef] instance object corresponding to the referential
		 * @return {Array.<DSMath.Vector3D>} array of DSMath.Vector3D corresponding to the discretization Point (coordinates in model unit (mm))
		 */
    PathActor.prototype.getDiscretization = function (iParam, iRef) {
    	var oPoints = [];

    	if (iParam > 1 || iParam < 0) {
    		console.log('[STU.PathActor.getDiscretization] lenght ratio increment not within the range [0,1]');
    		throw new TypeError('iParam argument is not within the range [0,1]');
    	}

    	if (iRef !== undefined && iRef !== null) {
    		if (!(iRef instanceof STU.Actor3D)) {
    			console.log('[STU.PathActor.getDiscretization] given iRef is not an Actor3D');
    			throw new TypeError('iRef argument is not a STU.Actor3D');
    		}
    		else {
    			if (iRef.CATIMovable !== undefined && iRef.CATIMovable !== null) {
    				this.VIAIIxpVirtualPath.GetDiscretization(iParam, iRef.CATIMovable, oPoints);
    			}
    			else {
    				console.log('[STU.PathActor.getDiscretization] given Actor3D as iRef has no CATIMovable property');
    				throw new TypeError('iRef argument is a STU.Actor3D without CATIMovable property');
    			}
    		}
    	}
    	else {
    		this.VIAIIxpVirtualPath.GetDiscretization(iParam, null, oPoints);
    	}
    	return oPoints;
    };

	//-> Following code will be deleted from Monday April 3rd 2017
	/**
     ****************************************************************************************
		 *											DO NOT USE : PRIVATE AND DEPRECATED API
		 *																USE getValue INSTEAD
		 ****************************************************************************************
		 * Returns the point's coordinate of this STU.PathActor corresponding to the given param.
     * By default, the function uses the World referential.
     *
     * @method
     * @private
     * @param {number} iParam curvilinear param within the range [0,1]
     * @param {STU.Actor3D} [iRef] instance object corresponding to the referential
     * @return {DSMath.Vector3D} instance representing the {X,Y,Z} coordinates in model unit (mm)
     */
    PathActor.prototype.getValue_Deprecated = function (iParam, iRef) {
    	var oCoordinates = new DSMath.Vector3D();
    	oCoordinates.x = 0;
    	oCoordinates.y = 0;
    	oCoordinates.z = 0;

    	if (iParam > 1 || iParam < 0) {
    		console.log('[STU.PathActor.getValue_Deprecated] param not within the range [0,1]');
    		throw new TypeError('iParam argument is not within the range [0,1]');
    	}

    	if (iRef !== undefined && iRef !== null) {
    		if (!(iRef instanceof STU.Actor3D)) {
    			console.log('[STU.PathActor.getValue_Deprecated] given iRef is not an Actor3D');
    			throw new TypeError('iRef argument is not a STU.Actor3D');
    		}
    		else {
    			if (iRef.CATIMovable !== undefined && iRef.CATIMovable !== null) {
    				this.VIAIIxpVirtualPath.GetValue_Deprecated(iParam, iRef.CATIMovable, oCoordinates);
    			}
    			else {
    				console.log('[STU.PathActor.getValue_Deprecated] given Actor3D as iRef has no CATIMovable property');
    				throw new TypeError('iRef argument is a STU.Actor3D without CATIMovable property');
    			}
    		}
    	}
    	else {
    		this.VIAIIxpVirtualPath.GetValue_Deprecated(iParam, null, oCoordinates);
    	}
    	return oCoordinates;
    };
		//Following code will be deleted from Monday April 3rd 2017 <-


    //////////////////////////////////////////////////////////////////////////////
    //                            STU expositions.                              //
    //////////////////////////////////////////////////////////////////////////////

    // Expose only those entities in STU namespace.
    STU.PathActor = PathActor;

    return PathActor;
});

define('StuVirtualObjects/StuPathActor', ['DS/StuVirtualObjects/StuPathActor'], function (PathActor) {
    'use strict';

    return PathActor;
});
