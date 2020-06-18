
define('DS/StuCore/StuDefaultReplacer', ['DS/StuCore/StuContext'], function (STU) {
	"use strict";

	/*
	 * JSON.stringify accept a custom made replacer so that a dev can tweak and customize the stringification process as he see fit. For Studio
	 * we use that entry point in order to be able to cut cycles in the graph formed by Studio Objects and references between them. In practice
	 * if you took care to flag these references as 'weak' through the use of attribute these references will be replaced in the serialization
	 * by information that can be used by the other side to re generate those references.
	 * On top of that this replace is meant to work on objects that are deriving somehow from STU.Instance which bear a replacer method. This 
	 * replacer will ensure that the replacer method on your object will be called. So if you are serializing a family of objects that has 
	 * overridden that behavior you are free to control the serialization as you see fit (and thus to cut cycles that you want to cut). You can check
	 * STU.Behavior for an example of how this can be used.
	 *
	 * It is worth noting that JSON.stringify calls a function not a class so in fact the replacer that will be used is the function that 
	 * is returned by the getReplacer method. Some data are 'hidden' in it's closure, don't remove them they are used as yet another mechanism
	 * to cut cycles. You can view the closure as a kind of serialization context which record state information while the process is progressing.
	 * If the value of the property you are processing has already been serialized the below code will automatically deal with it as a 'weak' reference
	 * and won't attempt to serialize it again in depth. It will just place in the serialization output some useful information so one can link back
	 * objects while processing the JSON string is needed.
	 *
	 * @class 
	 * @private
	 * @constructor
	 */
	var DefaultReplacer = function ( ) {
	
	};

	DefaultReplacer.prototype.constructor = DefaultReplacer;

    /*
     * @method getReplacer
	 * @private
     * @return {Function} a function that can be used by JSON.stringify. That function implement some specific treatments for some Studio
     * specificities and also maintain in it's closure information that can be viewed as a serialization context.
     */
	DefaultReplacer.prototype.getReplacer = function () {
		var track = [];
		return function ( iKey, iValue) {
            STU.trace ( function () { return "Replacer: Called on:" + iKey + " " + iValue; }, STU.eTraceMode.eVerbose, "Replacer");


            if ((iKey==="protoId") || (iKey==="parent") || (iKey==="ready")) {
                return;
            }


            if(iKey==="prototype") {

            // TODO : UnComment below lines and comment the one after
            // as soon as C++ can process weakRef info.
            /*
                if(iValue.stuId===undefined || iValue.stuId===null) {
                    return;
                }
                return new STU.WeakRef(iValue.stuId, iValue.name);
                */
                return;
            }

			if(typeof iValue === 'object' && iValue !== null) {
				if (track.indexOf(iValue)!==-1) {
                    // It basically means we have a weak ref !!
                    // TODO : UnComment below lines and comment the one after
                    // as soon as C++ can process weakRef info.
                    /*if(iValue["stuId"] !==undefined && iValue["stuId"] !==null) {
                        return new STU.WeakRef(iValue.stuId, iValue.name);
                    }*/
                    return;
				}
				track.push(iValue);

                if(iValue.replacer !==undefined && iValue.replacer !== null && typeof iValue.replacer === 'function') {
					STU.trace ( function () { return "Replacer: calling dedicated replacer on:" + iKey + " " + iValue; }, STU.eTraceMode.eVerbose, "Replacer");
					return iValue.replacer();
                }
			}
			if (typeof iValue === 'function') {
                return "internalImpl";
                //return iValue.toString();
            }
            STU.trace ( function () { return "Replacer: return value:" + iKey + " " + iValue; }, STU.eTraceMode.eVerbose, "Replacer");
			return iValue;

		};
	};

	// Expose in STU namespace.
	STU.DefaultReplacer = DefaultReplacer;

	return DefaultReplacer;
});

define('StuCore/StuDefaultReplacer', ['DS/StuCore/StuDefaultReplacer'], function (DefaultReplacer) {
    'use strict';

    return DefaultReplacer;
});
