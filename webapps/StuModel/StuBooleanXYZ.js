define('DS/StuModel/StuBooleanXYZ', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
    'use strict';


    /**
     * Describe an Object representing an UI BooleanXYZ.
     * It is defined by an object with three boolean variables.
     *
     * @exports BooleanXYZ
     * @class
     * @constructor
     * @public
     * @extends STU.Instance
     * @memberOf STU
	 * @alias STU.BooleanXYZ
     * @param {Boolean} [iX = TRUE] initial value for the x parameter
     * @param {Boolean} [iY = TRUE] initial value for the y parameter
     * @param {Boolean} [iZ = TRUE] initial value for the z parameter
     */
    var BooleanXYZ = function (iX, iY, iZ) {
        Instance.call(this);
        this.name = 'BooleanXYZ';


        /**
         * The X parameter.
         *
         * @member
         * @public
         * @type {Boolean}
         */
        this.x = iX;

        /**
         * The Y parameter
         *
         * @member
         * @public
         * @type {Boolean}
         */
        this.y = iY;

        /**
         * The Z parameter.
         *
         * @member
         * @public
         * @type {Boolean}
         */
        this.z = iZ;

    };


    BooleanXYZ.prototype = new Instance();
    BooleanXYZ.prototype.constructor = BooleanXYZ;
    BooleanXYZ.prototype.featureCatalog = 'CXPBasicTypesCatalog.feat';
    BooleanXYZ.prototype.featureStartup = 'BooleanXYZ_Spec';

    /**
     * Set new X, Y & Z values for this STU.BooleanXYZ.
     * Values are booleans.
     *
     * @method
     * @public
     * @param {Boolean} iX corresponding to the new X value
     * @param {Boolean} iY corresponding to the new Y value
     * @param {Boolean} iZ corresponding to the new Z value
     */
    BooleanXYZ.prototype.setXYZValues = function (iX, iY, iZ) {
        this.x = iX;
        this.y = iY;
        this.z = iZ;
    };


    // Expose in STU namespace.
    STU.BooleanXYZ = BooleanXYZ;

    return BooleanXYZ;
});

define('StuModel/StuBooleanXYZ', ['DS/StuModel/StuBooleanXYZ'], function (BooleanXYZ) {
    'use strict';

    return BooleanXYZ;
});
