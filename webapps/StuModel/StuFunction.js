
define('DS/StuModel/StuFunction', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
    'use strict';

    /**
	 * @exports Function
	 * @class
	 * @constructor
     * @noinstancector
     * @private
	 * @extends STU.Instance
	 * @memberof STU
	 * @alias STU.Function
	 */
    var Function = function () {
        Instance.call(this);

        this.CATI3DExperienceObject;

        this.name = "Function";

        this.caller;
        this.parameter;
    };

    Function.prototype = new Instance();
    Function.prototype.constructor = Function;

    /**
    * Return the experience
    * @method
    * @private
    * @return {STU.Experience} instance object corresponding to the experience
    */
    Function.prototype.getExperience = function () {
        return STU.Experience.getCurrent();
    };
    
    
    // Expose in STU namespace.
    STU.Function = Function;

    Function.prototype.Dump = function() {
        console.log(this);
    }

    Function.prototype.setCaller = function (caller) {
        this.caller = caller;
    }
    Function.prototype.setParameter = function (parameter) {
        this.parameter = parameter;
    }
    Function.prototype.execute = function () {

        // if a caller has been set
        if (this.caller != undefined && this.caller != null) {
            if ( this.name in this.caller )
                return this.caller[this.name].apply(this.caller,[this.parameter]);
            else
                console.error("[Function::execute] you try to execute the function '"+this.name+"' but it does not exist in '"+this.caller.name+"'");
        }
        // if no caller is set but the function has a parent
        else if (this.parent != undefined && this.parent != null) {
            if ( this.name in this.parent)
                return this.parent[this.name].apply(this.parent,[this.parameter]);
            else
                console.error("[Function::execute] you try to execute a function without setting a 'caller' or whose parent ("+this.parent.name+") has no function called '"+this.name+"'");
        }
        else{
            console.error("[Function::execute] you try to execute a function without setting a 'caller' and having no parent");
        }

    }
    return Function;
});

define('StuModel/StuFunction', ['DS/StuModel/StuFunction'], function (Function) {
    'use strict';

    return Function;
});
