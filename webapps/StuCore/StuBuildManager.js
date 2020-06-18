
define('DS/StuCore/StuBuildManager', ['DS/StuCore/StuContext', 'DS/StuCore/StuManager'], function (STU, Manager) {
	'use strict';

    /**
     * Describe a STU.Manager which handle build related JS side functionnalites.
     * For the moment user can only export a STU.Instance object to JSON.
     * 
     * @exports BuildManager
     * @class 
     * @constructor
     * @private
     * @extends STU.Manager
     * @memberof STU
     * @alias STU.BuildManager
     */
    var BuildManager = function ( ) {

        Manager.call(this);

        this.name = 'BuildManager';
    };

    BuildManager.prototype = new Manager();
    BuildManager.prototype.constructor = BuildManager;

    /**
     * Export the given STU.Instance object to JSON.
     * During the export process, a replacer is used to break object cycle loops and apply specific treatments.
     * 
     * @mehtod
     * @private
     * @param {STU.Instance} iInstance the instance object that need to be exported to JSON
     * @return {string} the JSON string
     */
    BuildManager.prototype.exportToJSON = function (iInstance) {
        if ( iInstance instanceof STU.Instance ) {
            var dumpJSON = JSON.stringify(iInstance, this.getReplacer());
            return dumpJSON;
        }
        else {
            console.error('Error in STU.BuildManager.exportToJSON, iInstance is not a STU.Instance!');
            return '';
        }
    };

    /**
     * Declare a replacer function that will treat each object's key and value in order to break object cycles, 
     * apply specific treatments and obtain a usable JSON string.
     * 
     * @method
     * @private
     * @return {function} a replacer function that can be used by JSON.stringify
     */
    BuildManager.prototype.getReplacer = function ( ) {
        var cache = [];
        return function (iKey, iValue ) {
            if ( typeof iValue === 'object' && iValue !== null ) {
                if ( cache.indexOf(iValue) !== -1 ) {
                    if ( iValue.stuId === undefined || iValue.name === null ) {
                        console.error('Error in STU.BuildManager.getReplacer, weak reference object does not have stuId!');
                        return 'Invalid Weak Reference Object';
                    }
                    return {weakReferenceID: iValue.stuId, weakReferenceName: iValue.name};
                }
                cache.push(iValue);
            }
            else if ( typeof iValue === 'string' ) {

            }

            return iValue;
        };
    };

    STU.registerManager(BuildManager);

    // Expose in STU namespace.
	STU.BuildManager = BuildManager;

	return BuildManager;
});

define('StuCore/StuBuildManager', ['DS/StuCore/StuBuildManager'], function (BuildManager) {
    'use strict';

    return BuildManager;
});
