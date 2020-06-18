
define('DS/StuMath/StuRay', ['DS/StuCore/StuContext', 'MathematicsES/MathsDef'], function (STU, DSMath) {
	'use strict';

	/**
	 * Describe an Object representing a ray.
	 * It is defined by an origin, a direction and a length.
	 *
	 * @exports Ray
	 * @class
	 * @constructor	 
	 * @public
	 * @memberof STU
	 * @alias STU.Ray
	 * 
	 * @param {DSMath.Point} iOrigin The ray origin.
	 * @param {DSMath.Vector3D} iDirection the ray direction.
	 * @param {number} [iLength] The length of the ray. If undefined or 0, then the ray is infinite.
	 */
	var Ray = function (iOrigin, iDirection, iLength) {

		/**
     	 * Origin of the ray.
     	 *
     	 * @member
     	 * @public
     	 * @type {DSMath.Point}
     	 */
		this.origin = iOrigin !== undefined ? iOrigin : new DSMath.Point(0, 0, 0); 

		/**
     	 * Direction of the ray.
     	 *
     	 * @member
     	 * @public
     	 * @type {DSMath.Vector3D}
     	 */
		this.direction = iDirection !== undefined ? iDirection : new DSMath.Vector3D(0, 0, 1);

		/**
     	 * Length of the ray.
     	 * If length is 0, the ray is considered as infinite.
     	 *
     	 * @member
     	 * @public
     	 * @type {number}
     	 */
		this.length = iLength !== undefined ? iLength : 0.0;

	};

	Ray.prototype.constructor = Ray;

	/**
	 * Return the origin of this STU.Ray.
	 * The origin is in the World referential.
	 *
	 * @method
	 * @private
	 * @return {DSMath.Point} instance object corresponding to the origin in 3D
	 */
	Ray.prototype.getOrigin = function () {
		return this.origin.clone();
	};

	/**
	 * Set the new origin of this STU.Ray.
	 * The origin is in the World referential.
	 *
	 * @method
	 * @private
	 * @param {DSMath.Point} iOrigin instance object corresponding to the origin in 3D
	 */
	Ray.prototype.setOrigin = function (iOrigin) {
		this.origin = iOrigin.clone();
	};

	/**
	 * Return the direction of this STU.Ray.
	 * The direction is in the World referential.
	 *
	 * @method
	 * @private
	 * @return {DSMath.Vector} instance object corresponding to the direction in 3D
	 */
	Ray.prototype.getDirection = function () {
		return this.direction.clone();
	};

	/**
	 * Set the new direction of this STU.Ray.
	 * The direction is in the World referential.
	 *
	 * @method
	 * @private
	 * @return {DSMath.Vector} iDirection instance object corresponding to the new direction in 3D
	 */
	Ray.prototype.setDirection = function (iDirection) {
		this.direction = iDirection.clone();
	};

	/**
	 * Return the length of this STU.Ray.
	 *
	 * @method
	 * @private
	 * @return {number} corresponding to the length
	 */
	Ray.prototype.getLength = function () {
		return this.length;
	};

	/**
	 * Set the new length of this STU.Ray.
	 *
	 * @method
	 * @private
	 * @return {number} iDirection corresponding to the new length
	 */
	Ray.prototype.setLength = function (iLength) {
		this.length = iLength;
	};

	// Expose in STU namespace.
	STU.Ray = Ray;

	return Ray;
});

define('StuMath/StuRay', ['DS/StuMath/StuRay'], function (Ray) {
    'use strict';

    return Ray;
});
