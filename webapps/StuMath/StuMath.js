
define('DS/StuMath/StuMath', ['DS/StuCore/StuContext'], function (STU) {
	'use strict';

	/**
	 * STU.Math is an object reserved to serve as a container for every value or functionality related to math
	 *
	 * @namespace Math
	 * @private
	 * @memberof STU
	 */
	STU.Math = {};

	/**
	 * Constant value to convert Radian to Degree.
	 *
	 * @member
	 * @private
	 * @memberof STU.Math
	 */
	STU.Math.RadToDegree = 180.0 / Math.PI;

	/**
	 * Constant value to convert Degree to Radian.
	 *
	 * @member
	 * @private
	 * @memberof STU.Math
	 */
	STU.Math.DegreeToRad = Math.PI / 180.0;

	return STU;
});

define('StuMath/StuMath', ['DS/StuMath/StuMath'], function (STU) {
    'use strict';

    return STU;
});
