
define('DS/StuRenderEngine/StuIntersection', ['DS/StuCore/StuContext'], function (STU) {
	'use strict';

	/**
	 * Describe an Object representing an intersection.
	 * It is defined by a point, a normal and an intersected STU.Actor.
	 *
	 * @exports Intersection
	 * @class
	 * @constructor
	 * @noinstancector
	 * @public
	 * @memberof STU
	 * @alias STU.Intersection
	 */
	var Intersection = function () {

		/**
     	 * World coordinates of the point of intersection between the ray and actor's geometry.
     	 *
     	 * @member
     	 * @public
     	 * @type {DSMath.Point}
     	 */
		this.point;

		/**
     	 * Normal of the geometry at intersection point.
     	 *
     	 * @member
     	 * @public
     	 * @type {DSMath.Vector3D}
     	 */
		this.normal;

		/**
     	 * Intersected actor.
     	 *
     	 * @member
     	 * @public
     	 * @type {STU.Actor3D}
     	 */
		this.actor;
	};

	Intersection.prototype.constructor = Intersection;

	/**
	 * Return the point of this STU.Intersection.
	 * Use the World referential.
	 *
	 * @method
	 * @private
	 * @return {DSMath.Point} instance object corresponding to the point
	 * @see STU.Intersection#setPoint
	 */
	Intersection.prototype.getPoint = function () {
		return this.point.clone();
	};

	/**
	 * Set a new point for this STU.Intersection.
	 * Use the World referential.
	 *
	 * @method
	 * @private
	 * @param {DSMath.Point} iPoint instance object corresponding to the point
	 * @see STU.Intersection#getPoint
	 */
	Intersection.prototype.setPoint = function (iPoint) {
		this.point = iPoint.clone();
	};

	/**
	 * Return the normal of this STU.Intersection.
	 * Use the World referential.
	 *
	 * @method
	 * @private
	 * @return {DSMath.Vector3D} instance object corresponding to the normal
	 * @see STU.Intersection#setNormal
	 */
	Intersection.prototype.getNormal = function () {
		return this.normal.clone();
	};

	/**
	 * Set a new normal for this STU.Intersection.
	 * Use the World referential.
	 *
	 * @method
	 * @private
	 * @param {DSMath.Vector3D} iNormal instance object corresponding to the normal
	 * @see STU.Intersection#getNormal
	 */
	Intersection.prototype.setNormal = function (iNormal) {
		this.normal = iNormal.clone();
	};

	/**
	 * Return the intersected STU.Actor of this STU.Intersection.
	 *
	 * @method
	 * @private
	 * @return {STU.Actor} instance object corresponding to the intersected actor
	 * @see STU.Intersection#setActor
	 */
	Intersection.prototype.getActor = function () {
		return this.actor;
	};

	/**
	 * Set a new intersected STU.Actor for this STU.Intersection.
	 *
	 * @method
	 * @private
	 * @param {STU.Actor} iActor instance object corresponding to the intersected actor
	 * @see STU.Intersection#getActor
	 */
	Intersection.prototype.setActor = function (iActor) {
		this.actor = iActor;
	};

	// Expose in STU namespace.
	STU.Intersection = Intersection;

	return Intersection;
});

define('StuRenderEngine/StuIntersection', ['DS/StuRenderEngine/StuIntersection'], function (Intersection) {
    'use strict';

    return Intersection;
});
