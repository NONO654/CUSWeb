define('DS/StuCID/CXPImage', ['DS/StuCore/StuContext',
                                'DS/StuCID/StuUIActor',
                                'DS/StuModel/StuActor',
                                'DS/EPEventServices/EPEvent'],
function (STU, UIActor, Actor, Event )
{
	'use strict';


    /**
    * Describe a STU.CXPImage which represents a 2D UI image actor.
    *
    * @exports CXPImage
    * @class
    * @constructor
    * @noinstancector
    * @private
    * @extends STU.UIActor
    * @memberof STU
    * @alias STU.CXPImage
    */
	var CXPImage = function () {

        UIActor.call(this);
    };


	CXPImage.prototype = new UIActor();
	CXPImage.prototype.constructor = CXPImage;

    CXPImage.prototype.setImage = function (iImageRsc) {
        this.image = iImageRsc;
    }

	// Expose in STU namespace.
	STU.CXPImage = CXPImage;

	return CXPImage;
});

define('StuCID/CXPImage', ['DS/StuCID/CXPImage'], function (CXPImage) {
    'use strict';

    return CXPImage;
});
