
define('DS/StuHuman/StuHumanMsg',
    ['DS/StuCore/StuContext'],
    function (STU) {
	'use strict';

    /**
    * Describe a human message object.
    *
    * @exports HumanMsg
    * @class
    * @constructor
    * @private
    * @memberof STU
    */
    var HumanMsg = function (iMsg, iParams) {
        this._msg = '';
        this._params = {};

        this.setMsg(iMsg);
        this.setParams(iParams);
    };

    //////////////////////////////////////////////////////////////////////////////
    //                           Prototype definitions                          //
    //////////////////////////////////////////////////////////////////////////////
    HumanMsg.prototype.constructor = HumanMsg;


    /**
    * Set message
    *
    * @method
    * @private
    * @param {String} [iMsg] Message
    * @return {STU.HumanMsg}
    */
    HumanMsg.prototype.setMsg = function (iMsg) {
        if ((undefined === iMsg) || (null === iMsg)) {
            this._msg = '';
        }
        else if (typeof iMsg !== 'string') {
            //console.log('[STU.HumanMsg.setMsg] Invalid parameter :: not a string.');
            return this;
        }
        else { this._msg = iMsg; }

        return this;
    };

    /**
    * Get message
    *
    * @method
    * @private
    * @return {String} Message
    */
    HumanMsg.prototype.getMsg = function () {
        return this._msg;
    };

    /**
    * Set parameters
    *
    * @method
    * @private
    * @param {Object} [iParams] Object of parameters
    * @return {STU.HumanMsg}
    */
    HumanMsg.prototype.setParams = function (iParams) {
        if ((undefined === iParams) || (null === iParams)) {
            this._params = {};
            return this;
        }
        else if (typeof iParams !== 'object') {
            //console.log('[STU.HumanMsg.setParams] Invalid parameter :: not an object.');
            return this;
        }
        else { this._params = iParams; }

        return this;
    };

    /**
    * Get parameters
    *
    * @method
    * @private
    * @return {Object} Parameters
    */
    HumanMsg.prototype.getParams = function () {
        return this._params;
    };

    /**
    * Add parameters
    *
    * @method
    * @private
    * @param {Object} [iParams] List of parameters to add
    * @return {STU.HumanMsg}
    */
    HumanMsg.prototype.addParams = function (iParams) {
        if ((undefined === iParams) || (null === iParams)) {
            // nothing to do
            return this;
        }
        else if (typeof iParams !== 'object') {
            //console.log('[STU.HumanMsg.addParams] Invalid parameter :: not an object.');
            return this;
        }
        else {
            for (var prop in iParams) {
                if (iParams.hasOwnProperty(prop)) {
                    this._params[prop] = iParams[prop];
                }
            }
        }

        return this;
    };

    /**
    * Is parameters object empty
    *
    * @method
    * @private
    * @return {Boolean}
    */
    HumanMsg.prototype.isEmptyParams = function () {
        for (var prop in this._params) {
            if (this._params.hasOwnProperty(prop)) {
                return false;
            }
        }

        return true;
    };

    // Expose only those entities in STU namespace.
    STU.HumanMsg = HumanMsg;

	return HumanMsg;
});

define('StuHuman/StuHumanMsg', ['DS/StuHuman/StuHumanMsg'], function (HumanMsg) {
    'use strict';

    return HumanMsg;
});
