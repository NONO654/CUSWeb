define('DS/StuScenario/StuActTransition', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
    'use strict';

    /*****************************************************************************
    Component dedicated to ouput definition.

    @constructor
    *****************************************************************************/

    /**
    * Describe an transition object.
    *
    * @exports ActTransition
    * @class 
    * @constructor
	* @noinstancector 
    * @public
    * @extends STU.Instance
    * @memberof STU
    * @alias STU.ActTransition
    */
    var ActTransition = function (iRenderable) {
        Instance.call(this);
        this.name = "ActTransition";

    };

    //////////////////////////////////////////////////////////////////////////////
    //                           Prototype definitions                          //
    //////////////////////////////////////////////////////////////////////////////
    ActTransition.prototype = new Instance();
    ActTransition.prototype.constructor = ActTransition;

    // Expose only those entities in STU namespace.
    STU.ActTransition = ActTransition;

    return ActTransition;
});

define('StuScenario/StuActTransition', ['DS/StuScenario/StuActTransition'], function (ActTransition) {
    'use strict';

    return ActTransition;
});
