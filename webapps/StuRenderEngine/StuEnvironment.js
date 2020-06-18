
define('DS/StuRenderEngine/StuEnvironment', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
    'use strict';

    /**
	 * Describes an Object representing an environment (planet, ambience)
	 *
	 * @exports Environment
	 * @class
	 * @constructor
     * @noinstancector
     * @public
	 * @memberOf STU
     * @extends STU.Instance
     * @alias STU.Environment
	 */
    var Environment = function () {
        Instance.call(this);
        this.name = 'Environment';
    };

    Environment.prototype = new Instance();
    Environment.prototype.constructor = Environment;

    /**
     * Sets the environment as the current one.
     * 
     * @method
     * @public 
     */
    Environment.prototype.setAsCurrent = function () {
        STU.Experience.getCurrent().setActiveEnvironment(this);
    };

    /**
     * Returns true if the environment is the current one.
     *
     * @method
     * @public
     * @return {Boolean}
     */
    Environment.prototype.isCurrent = function () {
        var activeEnv = STU.Experience.getCurrent().getActiveEnvironment();

        if (activeEnv === this)
            return true;
        else
            return false;
    };

    // Expose in STU namespace.
    STU.Environment = Environment;

    return Environment;
});

define('StuRenderEngine/StuEnvironment', ['DS/StuRenderEngine/StuEnvironment'], function (Environment) {
    'use strict';

    return Environment;
});
