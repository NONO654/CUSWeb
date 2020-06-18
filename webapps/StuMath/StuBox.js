
define('DS/StuMath/StuBox', ['DS/StuCore/StuContext', 'MathematicsES/MathsDef'], function (STU, DSMath) {
	'use strict';

	/**
	 * Describe an Object representing a 3D box, parallel to the canonical axis.
	 * 
	 * <br> The box is defined by two DSMath.Point, the first 
	 * <tt>(XMin, YMin, ZMin)</tt> called the low
	 * extremity, and the other one (<tt>(XMax, YMax, ZMax)</tt>) the high extremity.
	 *<br> A box can be seen as a set. If one of the coordinates of the low 
	 * extremity is greater
	 * than the corresponding coordinate of the high  extremity, the box is empty.
	 * In other words, a box is not empty if <tt> XMin < XMax </tt> and 
	 * <tt> YMin < YMax </tt> and <tt> ZMin < ZMax</tt>. 
	 *
	 * @exports Box
	 * @class
	 * @constructor
     * @noinstancector
	 * @public
	 * @memberof STU
	 * @alias STU.Box
	 */
	var Box = function (iLow, iHigh) {
	    /**
         * Low extrimity of the box
         *
         * @member
		 * @type {DSMath.Point}
		 * @public
		 */
	    this.low = (iLow !== undefined) ? iLow : new DSMath.Point();
	    /**
         * High extrimity of the box
         *
         * @member
		 * @type {DSMath.Point}
		 * @public
		 */
		this.high = (iHigh !== undefined) ? iHigh : new DSMath.Point();
	};

	Box.prototype.constructor = Box;

	
	// Expose in STU namespace.
	STU.Box = Box;

	return Box;
});

define('StuMath/StuBox', ['DS/StuMath/StuBox'], function (Box) {
    'use strict';

    return Box;
});

