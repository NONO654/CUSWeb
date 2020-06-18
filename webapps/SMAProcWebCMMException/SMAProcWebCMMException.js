/*
  Empty place-holder file used to prevent any 404 HTTP error when
  referencing concatenated JS file in debug (-g) mode.

  When using mkmk without debug an egraph.js file is created
  containing the concatenation of all files in SMAProcWebCMMException.mweb; this file
  is returned by mkrun webserver on request of any of the URL
  SMAProcWebCMMException/xxx.js where xxx is the name of one of the original file in
  SMAProcWebCMMException.mweb/src. To speedup the page loading by preventing useless
  GET requests of SMAProcWebCMMException/xxx.js files that would return the same
  concatenated content the recommendation is to include in the page
  SMAProcWebCMMException/SMAProcWebCMMException.js with an explicit script element. But since the
  concatenated file is not created by "mkmk -g" that would trigger a
  404 error. To prevent this error this empty file is available and
  will be returned in debug mode.
*/

/// <amd-module name="DS/SMAProcWebCMMException/SMAProcWebCMMError"/>
var __extends = (this && this.__extends) || (function () {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
define("DS/SMAProcWebCMMException/SMAProcWebCMMError", ["require", "exports"], function (require, exports) {
    "use strict";
    /**
    * The SMAProcWebCMMError constructor creates an SMAProcWebCMMError object.
    * Instances of SMAProcWebCMMError objects are thrown when runtime errors occur in PCW.
    * The SMAProcWebCMMError object can also be used as a base object for user-defined errors.
    *
    * Constructor args:
    *     @param name {String} - Name of the error, This name will be used by the users to handle the thrown error
    *     @param message {String} - Meaningful description about the error, SMAProcWebCMMError doesn't have any built in mechanism for localization.
    *         Users creating this error should manage their own localization.
    *     @param errorData {Object} - Object with details about the error data. This data can be used for taking some corrective action by developers or
    *         just more information to help debug the error
    *     @param errorToBeChained    {Object} - Error to be added as chain to help users find the root cause that triggered the error
    *
    * Syntax:
    *     new SMAProcWebCMMError(name, message, errorData, errorToBeChained)
    *
    * Properties:
    *     name
    *     message
    *     stack
    *
    * Methods:
    *     getErrorData()
    *     getErrorChain())
    *
    * Example:
    *     try{
    *         throw new SMAProcWebCMMError('SMAProcWebCMMError', 'SMAProcWebCMMError message', {value:  0}, {});
    *     }
    *     catch(e){
    *         console.log(error.stack);
    *     }
    */
    var SMAProcWebCMMError = (function (_super) {
        __extends(SMAProcWebCMMError, _super);
        function SMAProcWebCMMError(name, message, errorData, errorToBeChained) {
            var _this = _super.call(this, message) || this;
            _this.setErrorData = function (errorData) {
                this._errorContext = this._errorContext || {};
                this._errorContext.errorData = errorData;
            };
            _this.name = name;
            _this._errorContext = {
                errorData: errorData,
                errorChain: errorToBeChained
            };
            return _this;
        }
        SMAProcWebCMMError.prototype.getErrorData = function () {
            return this._errorContext ? this._errorContext.errorData : {};
        };
        ;
        SMAProcWebCMMError.prototype.getErrorChain = function () {
            return this._errorContext ? this._errorContext.errorChain : null;
        };
        ;
        return SMAProcWebCMMError;
    }(Error));
    return SMAProcWebCMMError;
});

