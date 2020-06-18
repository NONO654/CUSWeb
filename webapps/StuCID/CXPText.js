define('DS/StuCID/CXPText', ['DS/StuCore/StuContext',
                                'DS/StuCID/StuUIActor',
                                'DS/StuModel/StuActor',
                                'DS/EPEventServices/EPEvent'],
function (STU, UIActor, Actor, Event )
{
	'use strict';


    /**
    * Describe a STU.CXPText which represents a 2D UI text actor.
    *
    * @exports CXPText
    * @class
    * @constructor
    * @noinstancector
    * @private
    * @extends STU.UIActor
    * @memberof STU
    * @alias STU.CXPText
    */
	var CXPText = function () {

        UIActor.call(this);
    };


	CXPText.prototype = new UIActor();
	CXPText.prototype.constructor = CXPText;

    CXPText.prototype.setText = function (iText) {
        this.text = iText;
    }

	// Expose in STU namespace.
	STU.CXPText = CXPText;

	return CXPText;
});

define('StuCID/CXPText', ['DS/StuCID/CXPText'], function (CXPText) {
    'use strict';

    return CXPText;
});
