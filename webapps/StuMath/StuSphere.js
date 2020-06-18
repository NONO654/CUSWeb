
define('DS/StuMath/StuSphere', ['DS/StuCore/StuContext', 'MathematicsES/MathsDef'], function (STU, DSMath) {
	'use strict';

	/**
	 * Describe an Object representing a sphere.
	 * It is defined by a center and a radius.
	 *
	 * @exports Sphere
	 * @class
	 * @constructor
     * @noinstancector
	 * @public
	 * @memberof STU
     * @alias STU.Sphere
	 */
	var Sphere = function () {

	    /**
         * Center of the sphere.<br/>
         * Note: the referential used to express the center of the sphere can be dependent 
         * on the context. Please refer on the documentation of the function returning a sphere
         * to know what is the referential used.
         *
         * @member
         * @public
		 * @type {DSMath.Point}		 
		 */
	    this.center = new DSMath.Point();

	    /**
         * Radius of the sphere in mms.
         *
         * @member		 
		 * @public
         * @type {number}
		 */
		this.radius = 0.0;
	};

	Sphere.prototype.constructor = Sphere;

	/**
	 * Return the center of this STU.Sphere.
	 * The center is in the World referential.
	 *
	 * @method
	 * @private
	 * @return {DSMath.Point} instance object corresponding to the center in 3D
	 */
	Sphere.prototype.getCenter = function () {
		return this.center.clone();
	};

	/**
	 * Set a new center for this STU.Sphere.
	 * The center is in the World referential.
	 *
	 * @method
	 * @private
	 * @param {DSMath.Point} iCenter instance object corresponding to the new center in 3D
	 */
	Sphere.prototype.setCenter = function (iCenter) {
		this.center = iCenter.clone();
	};

	/**
	 * Return the radius of this STU.Sphere.
	 *
	 * @method
	 * @private
	 * @return {number} corresponding to the radius
	 */
	Sphere.prototype.getRadius = function () {
		return this.radius;
	};

	/**
	 * Set a new radius for this STU.Sphere.
	 *
	 * @method
	 * @private
	 * @param {number} iRadius corresponding to the new radius
	 */
	Sphere.prototype.setRadius = function (iRadius) {
		this.radius = iRadius;
	};

	/**
	 * 
	 *
	 * @method
	 * @private
	 * @param {STU.Ray} iRay the ray for which we want to know whether it does intersect the provided sphere or not
	 * @return {Object} returns an object with a 'distance' property which should report the distance of intersection 
	 */
	Sphere.intersectRay = function (iRay) {

		if (this.center === undefined || this.center === null || iRay.direction === undefined || iRay.direction === null ||
			this.radius === undefined || this.radius === null || iRay.origin === undefined || iRay.origin === null) {
			return;
		}

		// Intersection Info
		var intersection = {};

		if (iRay.direction.squareNorm() === 0.0) {
			return intersection;
		}

		var diff = DSMath.Point.sub(iRay.origin, this.center);

		var diffOnDir = diff.dot(iRay.direction);
		var dist = diff.squareNorm() - this.radius * this.radius;
		if (dist > 0.0 && diffOnDir > 0.0) {
			// basically ray is going is opposite direction
			// so won't ever touch the sphere!
			intersection.isIntersecting = false;
			return intersection;
		}

		// Intersecting a ray and a sphere is like
		// solving a quad eq. If discriminant is
		// negative we know there is no outcome and we miss
		// the sphere (NB. Ray direction should be normalized!).
		var discri = diffOnDir * diffOnDir - dist;
		if (discri < 0.0) {
			intersection.isIntersecting = false;
			return intersection;
		}

		// If we reach this point we do intersect, let's compute
		// the distance of intersection.
		intersection.isIntersecting = true;
		intersection.distance = -diffOnDir - Math.sqrt(discri);

		var rayVec = DSMath.Vector3D.multiplyScalar(iRay.direction, intersection.distance);
		intersection.point = DSMath.Point.addVector(iRay.origin, rayVec);

		// hum hum, if we have a neg here we surely started inside!
		if (intersection.distance < 0.0) {
			intersection.isOriginInside = true;
		} else {
			intersection.isOriginInside = false;
		}

		return intersection;
	};

	/**
	 * 
	 *
	 * @method
	 * @private
	 * @param {STU.Sphere} iSphere second sphere that we want to use in the test
	 * @return {Object} returns an object containing only the boolean indicating whether there is or not collision
	 */
	Sphere.intersectSphere = function (iSphere) {
		if (this.center === undefined || this.center === null || iSphere.center === undefined || iSphere.center === null ||
			this.radius === undefined || this.radius === null || iSphere.radius === undefined || iSphere.radius === null) {
			return;
		}

		var c2c = DSMath.Point.sub(iSphere.center, this.center);
		var distSq = c2c.squareNorm();
		var rSum = this.radius + iSphere.radius;

		// Intersection Info
		var intersection = {};
		intersection.isIntersecting = distSq <= rSum * rSum;
		return intersection;
	};

	// Expose in STU namespace.
	STU.Sphere = Sphere;

	return Sphere;
});

define('StuMath/StuSphere', ['DS/StuMath/StuSphere'], function (Sphere) {
    'use strict';

    return Sphere;
});
