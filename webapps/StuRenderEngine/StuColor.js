define('DS/StuRenderEngine/StuColor', ['DS/StuCore/StuContext'], function (STU) {
	'use strict';

	/**
	 * Describe an Object representing a color.
	 * It is defined by a red, green & blue pixel value.
	 * Value range  is between 0 and 255.
	 *
	 * @exports Color
	 * @class
	 * @constructor
	 * @public
	 * @memberof STU
     * @alias STU.Color
	 * @param {number} [iRed=0] red pixel value
	 * @param {number} [iGreen=0] green pixel value
	 * @param {number} [iBlue=0] blue pixel value
	 */
	var Color = function (iRed, iGreen, iBlue) {
		/**
		 * Red pixel value
		 * Value range  is between 0 and 255.
		 *
		 * @member
		 * @instance
		 * @name r
		 * @public
		 * @type {number}
		 * @memberOf STU.Color
		 */

		Object.defineProperty(this, "r", {
			enumerable: true,
			configurable: true,
			get: function () {
				return this.red;
			},
			set: function (iRed) {
				if (typeof iRed !== 'number') {
					throw new TypeError('iRed argument is not a number');
				}

				if (iRed < 0 || iRed > 255) {
					throw new RangeError('iRed argument is outside of the pixel value range 0-255');
				}

				this.red = iRed;
			}
		});


		/**
		 * Green pixel value.
		 * Value range  is between 0 and 255.
		 *
		 * @member
		 * @instance
		 * @name g
		 * @public
		 * @type {number}
		 * @memberOf STU.Color
		 */

		Object.defineProperty(this, "g", {
			enumerable: true,
			configurable: true,
			get: function () {
				return this.green;
			},
			set: function (iGreen) {
				if (typeof iGreen !== 'number') {
					throw new TypeError('iGreen argument is not a number');
				}

				if (iGreen < 0 || iGreen > 255) {
					throw new RangeError('iGreen argument is outside of the pixel value range 0-255');
				}

				this.green = iGreen;
			}
		});



		/**
		 * Blue pixel value.
		 * Value range  is between 0 and 255.
		 *
		 * @member
		 * @instance
		 * @name b
		 * @public
		 * @type {number}
		 * @memberOf STU.Color
		 */

		Object.defineProperty(this, "b", {
			enumerable: true,
			configurable: true,
			get: function () {
			    return this.blue;
			},
			set: function (iBlue) {
			    if (typeof iBlue !== 'number') {
			        throw new TypeError('iBlue argument is not a number');
				}

			    if (iBlue < 0 || iBlue > 255) {
				    throw new RangeError('iBlue argument is outside of the pixel value range 0-255');
				}

			    this.blue = iBlue;
			}
		});


		this.r = iRed || 0;
		this.g = iGreen || 0;
		this.b = iBlue || 0;
	};

	Color.prototype.constructor = Color;

	/**
	 * Set new red, green & blue pixel value for this STU.Color.
	 * Value range  is between 0 and 255.
	 *
	 * @method
	 * @public
	 * @param {number} iRed corresponding to the new red pixel value
	 * @param {number} iGreen corresponding to the new green pixel value
	 * @param {number} iBlue corresponding to the new blue pixel value
	 */
	Color.prototype.setPixelValue = function (iRed, iGreen, iBlue) {
		this.r = iRed;
		this.g = iGreen;
		this.b = iBlue;
	};



	/**
	 * Return the red pixel value of this STU.Color.
	 * Value range  is between 0 and 255.
	 * (deprecated use this.r instead)
	 *
	 * @method
	 * @private
	 * @return {number} corresponding to the red pixel value
	 * @see STU.Color#setRed
	 */
	Color.prototype.getRed = function () {
		return this.r;
	};

	/**
	 * Set a new red pixel value for this STU.Color.
	 * Value range  is between 0 and 255.
	 * (deprecated use this.r instead)
	 *
	 * @method
	 * @private
	 * @param {number} iRed corresponding to the new red pixel value
	 * @see STU.Color#getRed
	 * @see STU.Color#setPixelValue
	 */
	Color.prototype.setRed = function (iRed) {
		this.r = iRed;
	};

	/**
	 * Return the green pixel value of this STU.Color.
	 * Value range  is between 0 and 255.
	 * (deprecated use this.g instead)
	 *
	 * @method
	 * @private
	 * @return {number} corresponding to the green pixel value
	 * @see STU.Color#setGreen
	 */
	Color.prototype.getGreen = function () {
		return this.g;
	};

	/**
	 * Set a new green pixel value for this STU.Color.
	 * Value range  is between 0 and 255.
	 * (deprecated use this.g instead)
	 *
	 * @method
	 * @private
	 * @param {number} iGreen corresponding to the new green pixel value
	 * @see STU.Color#getGreen
	 * @see STU.Color#setPixelValue
	 */
	Color.prototype.setGreen = function (iGreen) {
		this.g = iGreen;
	};

	/**
	 * Return the blue pixel value of this STU.Color.
	 * Value range  is between 0 and 255.
	 * (deprecated use this.g instead)
	 *
	 * @method
	 * @private
	 * @return {number} corresponding to the blue pixel value
	 * @see STU.Color#setBlue
	 */
	Color.prototype.getBlue = function () {
		return this.blue;
	};

	/**
	 * Set a new blue pixel value for this STU.Color.
	 * Value range  is between 0 and 255.
	 * (deprecated use this.b instead)
	 *
	 * @method
	 * @private
	 * @param {number} iBlue corresponding to the new blue pixel value
	 * @see STU.Color#getBlue
	 * @see STU.Color#setPixelValue
	 */
	Color.prototype.setBlue = function (iBlue) {
		this.b = iBlue;
	};

	// Expose in STU namespace.
	STU.Color = Color;

	return Color;
});

define('StuRenderEngine/StuColor', ['DS/StuRenderEngine/StuColor'], function (Color) {
    'use strict';

    return Color;
});
