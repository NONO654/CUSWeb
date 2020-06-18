define('DS/StuScenario/StuActOutput', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
    'use strict';

    /*****************************************************************************
    Component dedicated to ouput definition.

    @constructor
    *****************************************************************************/

    /**
    * Describe an output object.
    *
    * @exports ActOutput
    * @class 
    * @constructor
	* @noinstancector 
    * @public
    * @extends STU.Instance
    * @memberof STU
    * @alias STU.ActOutput
    */
    var ActOutput = function (iRenderable) {
        Instance.call(this);
        this.name = "ActOutput";

    };

    //////////////////////////////////////////////////////////////////////////////
    //                           Prototype definitions                          //
    //////////////////////////////////////////////////////////////////////////////
    ActOutput.prototype = new Instance();
    ActOutput.prototype.constructor = ActOutput;

    // Expose only those entities in STU namespace.
    STU.ActOutput = ActOutput;

    return ActOutput;
});

define('StuScenario/StuActOutput', ['DS/StuScenario/StuActOutput'], function (ActOutput) {
    'use strict';

    return ActOutput;
});
