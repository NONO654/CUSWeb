define('DS/StuPictureResource/StuPictureResource', ['DS/StuCore/StuContext', 'DS/StuModel/StuResource'], function (STU) {
    'use strict';

    /**
     * Describes the Picture (also called Image) resource object.
     * 
     * @exports PictureResource
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends STU.Resource
     * @memberOf STU
	 * @alias STU.PictureResource
     */
    var PictureResource = function () {
        STU.Resource.call(this);
        this.CATICXPPictureResource;
        this.name = "PictureResource";
    };

    PictureResource.prototype = new STU.Resource();
    PictureResource.prototype.constructor = PictureResource;
    
    /**
     * Returns the Size in pixel of this STU.PictureResource
     *
     * @method
     * @private
     * @return {Object} with 2 properties {w,h}: 'w' represents the width and 'h' represnts the height
     */

    PictureResource.prototype.getPixelSize = function () {
        var size = { w: 0, h: 0 };
        this.CATICXPPictureResource.GetSizeInPixel(size);
        return size;
    };
      
    /**
     * Returns an image as a native object (CATPixelImage) build from this STU.PictureResource
     *
     * @method
     * @private
     * @return {CATPixelImage} The image build from this STU.PictureResource
     */

    PictureResource.prototype.getPixelImage = function () {
        return this.CATICXPPictureResource.GetPixelImage();
    };

    // Expose only those entities in STU namespace.
    STU.PictureResource = PictureResource;

    return PictureResource;
});

define('StuPictureResource/StuPictureResource', ['DS/StuPictureResource/StuPictureResource'], function (PictureResource) {
    'use strict';

    return PictureResource;
});
