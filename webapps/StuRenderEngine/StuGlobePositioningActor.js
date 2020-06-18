define('DS/StuRenderEngine/StuGlobePositioningActor', ['DS/StuCore/StuContext', 'DS/StuRenderEngine/StuActor3D'], function (STU, Actor3D) {
	'use strict';

	/**
     *
     * Expose Environment Location features.
     * Note: To that class, you must have the following role: <b>PLN - Planets Animator</b>
     *
     * Use STU.Experience to retrieve your locations.
	 *
	 * @example
	 * //Get the current experience
	 * var experience = STU.Experience.getCurrent();
	 *
	 * //Get all locations under the experience
	 * var location_array = experience.getActorsByType(STU.Location, true);
     * for(var i=0; i < location_array.length; i++) {   
     *      //Do stuff
	 * }
     *
     * @exports Location
     * @class 
     * @constructor
     * @noinstancector
     * @public
     * @extends STU.Actor3D
     * @memberOf STU
     * @alias STU.Location
     */
	var Location = function () {
	    Actor3D.call(this);

	    /**
        * Current latitude of the location actor (expressed in radian).
        *
        * @member
        * @instance
        * @name latitude
        * @public
        * @type {Number}
        * @memberOf STU.Location
        */
	    Object.defineProperty(this, "latitude", {
	        enumerable: true,
	        configurable: true,
	        get: function () {
	            if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
	                return this.CATI3DExperienceObject.GetValueByName('latitude');
	            }
	            else { return null; }
	        },
	        set: function (value) {
	            if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
	                this.CATI3DExperienceObject.SetValueByName('latitude', value);
	            }
	        }
	    });

	    /**
        * Current longitude of the location actor (expressed in radian).
        *
        * @member
        * @instance
        * @name longitude
        * @public
        * @type {Number}
        * @memberOf STU.Location
        */
	    Object.defineProperty(this, "longitude", {
	        enumerable: true,
	        configurable: true,
	        get: function () {
	            if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
	                return this.CATI3DExperienceObject.GetValueByName('longitude');
	            }
	            else { return null; }
	        },
	        set: function (value) {
	            if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
	                this.CATI3DExperienceObject.SetValueByName('longitude', value);
	            }
	        }
	    });

	    /**
        * Current orientation of the location actor (expressed in radian).
        *
        * @member
        * @instance
        * @name orientation
        * @public
        * @type {Number}
        * @memberOf STU.Location
        */
	    Object.defineProperty(this, "orientation", {
	        enumerable: true,
	        configurable: true,
	        get: function () {
	            if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
	                return this.CATI3DExperienceObject.GetValueByName('orientation');
	            }
	            else { return null; }
	        },
	        set: function (value) {
	            if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
	                this.CATI3DExperienceObject.SetValueByName('orientation', value);
	            }
	        }
	    });

	    /**
        * Current altitude of the location actor (expressed in mm).
        *
        * @member
        * @instance
        * @name altitude
        * @public
        * @type {Number}
        * @memberOf STU.Location
        */
	    Object.defineProperty(this, "altitude", {
	        enumerable: true,
	        configurable: true,
	        get: function () {
	            if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
	                return this.CATI3DExperienceObject.GetValueByName('altitude');
	            }
	            else { return null; }
	        },
	        set: function (value) {
	            if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
	                this.CATI3DExperienceObject.SetValueByName('altitude', value);
	            }
	        }
	    });

	    /**
        * The planetID of the planet containing the location.
        *
        * @member
        * @instance
        * @name planetID
        * @public
        * @type {Number}
        * @memberOf STU.Location
        */
	    Object.defineProperty(this, "planetID", {
	        enumerable: true,
	        configurable: true,
	        get: function () {
	            if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
	                return this.CATI3DExperienceObject.GetValueByName('planetID');
	            }
	            else { return null; }
	        },
	        set: function (value) {
	            if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
	                this.CATI3DExperienceObject.SetValueByName('planetID', value);
	            }
	        }
	    });

	};

	Location.prototype = new Actor3D();
	Location.prototype.constructor = Location;

	Location.prototype.getLocation = function () {
    	return this;
	};

    /**
    * Get the active environment's name
    *  
    * @method
    * @private
    * @return {DSMath.Vector3D} environment name, empty string if no active environment is found
    */
	Location.prototype.getGravityVector = function () {
	    var vector = this.getTransform().matrix.getThirdColumn().clone();
	    return vector.negate().normalize();
	};

    /**
     * Sets the location as the current one (other locations are hidden).
     * 
     * @method
     * @public 
     */
	Location.prototype.setAsCurrent = function () {
	    STU.Experience.getCurrent().setActiveLocation(this);
	};

    /**
     * Returns true if the location is the current one.
     *
     * @method
     * @public
     * @return {Boolean}
     */
	Location.prototype.isCurrent = function () {
	    //console.log("called in Location.prototype.isCurrent");
	    var activeLoc = STU.Experience.getCurrent().getActiveLocation();

	    if (activeLoc === this)
	        return true;
	    else
	        return false;
	};

	// Expose in STU namespace.
	STU.Location = Location;

	return Location;
});

define('StuRenderEngine/StuGlobePositioningActor', ['DS/StuRenderEngine/StuGlobePositioningActor'], function (Location) {
    'use strict';

    return Location;
});
