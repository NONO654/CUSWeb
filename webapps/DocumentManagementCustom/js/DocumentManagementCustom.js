/**
 * @overview DocumentCommonUtils
 * @licence Copyright 2018 Dassault Systemes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/DocumentManagementCustom/js/DocumentManagementCustom', [
                                                                  'UWA/Core',
                                                                  'DS/WAFData/WAFData',
                                                                  'DS/CfgAuthoringContextUX/scripts/CfgAuthoringContext'
																										 ], function (UWA, WAFData, CfgAuthoringContext) {
	'use strict';

	var DocumentManagementCustom = {
    SERVICE_ROOT_URL: '/resources/v1/modeler/documents/',
    reserveDocument: function(docId, options) {
                return this._initiateService(this.SERVICE_ROOT_URL + docId+'/reserve', options);
            },
    unreserveDocument: function(docId, options) {
                return this._initiateService(this.SERVICE_ROOT_URL + docId+'/unreserve', options);
            },

	  _initiateService: function(url, options) {
           var that = this;
           var lOptions = UWA.clone(options || {}, false);
           lOptions.requestType = 'put';

           var prepareServiceRet = this._prepareService(this._initiateService.bind(this, url, options), lOptions);
           if (prepareServiceRet) { //we need to wait to get the csrf
               return prepareServiceRet;
           }

           DocumentManagementCustom.ajaxRequest({
               url: url,
               type: 'put',
               dataType: 'json',
               data: JSON.stringify({
                   csrf: this.getCsrf(lOptions.tenantUrl)
               }),
               callback: function(resp) {
                   if (resp && resp.csrf) {
                       that.setCsrf(resp.csrf, lOptions.tenantUrl);
                   }
                   if (resp && resp.success && UWA.is(options.onComplete, 'function')) {
                       options.onComplete(resp, options);
                   } else {
                       if (UWA.is(options.onFailure, 'function')) {
                           options.onFailure(resp);
                       }
                   }
               },
               headers: {
                   'content-type': 'application/json'
               }
           });
       },
       _prepareService: function(callback, iOptions) {
           window.isIFWE = true;
           var lOptions = iOptions || {};
           if (lOptions.tenant) {
               enoviaServer.tenant = lOptions.tenant;
           }
           if (lOptions.securityContext) {
               var securityContext = lOptions.securityContext;
               if (securityContext.indexOf('ctx::') !== 0) {
                   securityContext = 'ctx::' + securityContext;
               }
               enoviaServer.space = securityContext;
           }
           if (lOptions.tenantUrl) {
               enoviaServer.storageUrl = lOptions.tenantUrl;
           }

           if (!this.getCsrf(lOptions.tenantUrl) || lOptions.csrf) {
               if (lOptions.csrf) {
                   if (lOptions.csrf !== 'notNeeded') {
                     this.setCsrf(lOptions.csrf, lOptions.tenantUrl);
                   }

               } else {
                   //request csrf token then call ourself again
                   return this._getCsrf(callback, iOptions);
               }
           }
       },
        _getCsrf: function(callback, options) {
            var csrfService = '/resources/v1/application/E6WFoundation/CSRF';
            var that = this;
            var lAjaxRequestObject = {
                url: csrfService,
                type: 'get',
                dataType: 'json',
                callback: function(response) {
                    if (response && response.csrf) {
                      that.setCsrf(response.csrf, options && options.tenantUrl);

                        callback();
                    }
                },
                headers: {
                    'content-type': 'application/json'
                }
            };
            return DocumentManagementCustom.ajaxRequest(lAjaxRequestObject);

        },
        getCsrf: function(url){
          var lUrl = url || enoviaServer.storageUrl;
          return this.csrf && this.csrf[lUrl];
        },
        setCsrf: function(csrf, url) {
          var lUrl = url || enoviaServer.storageUrl;
          this.csrf = this.csrf || {};
          return this.csrf[lUrl] = csrf;
        },
        calculateFinalUrl: function(url, noParamsExceptTenant) {
                var ajaxURL = url;
                var parseURL = UWA.Utils.parseUrl(url);
                if (parseURL.protocol){
                	return ajaxURL;
                }

	            ajaxURL = window.enoviaServer.computeUrl(ajaxURL);
	            ajaxURL += (ajaxURL.indexOf('?') === -1) ? '?' : '&';
	            var enoviaServerParams = window.enoviaServer.getParams();
	            if (enoviaServerParams && enoviaServerParams.length > 0 && !noParamsExceptTenant) {
	            	ajaxURL += enoviaServerParams;
	            } else {
	            	ajaxURL += 'tenant=' + enoviaServer.tenant;
	            }

                return ajaxURL;
            },
            ajaxRequest: function(ajaxRequestObject, noParamsExceptTenant) {
                           var ajaxURL = DocumentManagementCustom.calculateFinalUrl(ajaxRequestObject.url, noParamsExceptTenant);
                           var headers = UWA.clone(ajaxRequestObject.headers || {}, false);
                           !headers['Accept-Language'] && window.widget && window.widget.lang && (headers['Accept-Language'] = window.widget.lang);
                           if (window.isIFWE) {
                               var errorCallback = ajaxRequestObject.onFailure ||
                                   function(errorMsg, data) {
                                       var resp = data || {};
                                       if (!(resp.success === false && resp.error)) {
                                           resp = {
                                               error: 'Network Error: Unable to load widget due to network or authentication error.'
                                           };
                                       }
                                       ajaxRequestObject.callback.call(this, resp);

                                   };
                               var timeoutCallback = ajaxRequestObject.onTimeout ||
                                   function() {
                                       ajaxRequestObject.callback.call(this, {
                                           error: 'Network Error: Unable to load widget due to timeout error.'
                                       });
                                   };
                               var cancelCallback = ajaxRequestObject.onCancel ||
                                   function() {
                                       ajaxRequestObject.callback.call(this, {
                                           error: 'Application Error: Request canceled.'
                                       });
                                   };
                               var xhr = WAFData.authenticatedRequest(ajaxURL, {
                                   method: ajaxRequestObject.type,
                                   type: ajaxRequestObject.dataType,
                                   proxy: 'passport',
                                   timeout: 500000,
                                   cache: 3600,
                                   data: ajaxRequestObject.data,
                                   onComplete: ajaxRequestObject.callback,
                                   onFailure: errorCallback,
                                   onCancel: cancelCallback,
                                   onTimeout: timeoutCallback,
                                   headers: headers
                               });
                               xhr = xhr || {
                                   cancel: jQuery.noop
                               };
                               return xhr;
                           }
                       },
    addCfgAuthoringContextToHeader: function(){
      var headers  = {};
          if (CfgAuthoringContext) {
           try {
               var ca = CfgAuthoringContext.get();
               if (ca.change.id.length > 0) {
                   headers['DS-Change-Authoring-Context'] = 'pid:' + ca.change.id;
               }
           } catch (err) {
           }
       }
       return headers;
    }
};
	return DocumentManagementCustom;
});
