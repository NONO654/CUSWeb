define('DS/StuModel/StuDimension', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
	'use strict';


    /**
     * Describe an Object representing a dimension.
     * It is defined by a width and a height that can be expressed in pixel or screen percentage.
     *
     * @exports Dimension
     * @class
     * @constructor
     * @public
     * @extends STU.Instance
     * @memberOf STU
	 * @alias STU.Dimension
     * @param {number} [iWidth=0] width value
     * @param {number} [iHeight=0] height value
     * @param {number} [iMode=0] values mode: 0=pixel, 1=percentage
     */
	var Dimension = function (iWidth, iHeight, iMode) {
	    Instance.call(this);
	    this.name = 'Dimension';

	    /**
         * Width value.
		 * If mode is set to 0, width value is expressed in pixel, otherwise in screen percentage.
         *
         * @member
         * @public
         * @type {number}
         */
        this.width = iWidth || 0;

	    /**
         * Height value.
		 * If mode is set to 0, width value is expressed in pixel, otherwise in screen percentage.
         *
         * @member
         * @public
         * @type {number}
         */
        this.height = iHeight || 0;

	    /**
         * Mode value.
		 * It defines whether the width and height value are expressed in pixel or screen percentage.
         * 0: pixel, 1: percentage
         *
         * @member
         * @public
         * @type {STU.Dimension.EMode}
         */
        this.mode = iMode || 0;
	};

    /**
	* An enumeration of modes for Dimension.<br/>
    * It allows to refer in the code to a specific mode of dimension whether expressed in pixel or in screen percentage.
    *
    * @enum {number}
	* @public
    */
	Dimension.EMode = {
	    ePixel: 0,
	    ePercentage: 1
	};

	Dimension.prototype = new Instance();
	Dimension.prototype.constructor = Dimension;
	Dimension.prototype.featureCatalog = 'CXPBasicTypesCatalog.feat';
	Dimension.prototype.featureStartup = 'Dimension_Spec';


	// Expose in STU namespace.
	STU.Dimension = Dimension;

	return Dimension;
});

define('StuModel/StuDimension', ['DS/StuModel/StuDimension'], function (Dimension) {
    'use strict';

    return Dimension;
});
