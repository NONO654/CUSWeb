/*eslint strict: ["error", "function"]*/


define('DS/dstoolsUIServices/dsbaseServices', [
  'DS/WAFData/WAFData',
  'UWA/Utils'
], function(WAFData, Utils) {
  /**
   * @summary toolbox for client-side APIs
   * @module DS/dstoolsUIServices/dsbaseServices
   * @private
   */

  'use strict';
  //http://localhost:9421/3DRDF/service/
  var serverURL;
  var toolbox = {
    /**
     * @private
     */
    getInfosFromServiceId: function(serviceId) {
      var toReturn = {
        serverURL: '',
        tenantId: '',
        wsVersion: 'v0',
        wsEndPoint: 'invoke'
      };
      if(typeof serviceId === 'string') {
        if(serviceId.startsWith('ODTService@') === true) {
          toReturn.serverURL = serviceId.substring(11);
          toReturn.tenantId = '';
        } else {
          // FIXME: write the actual code here
        }
        // return toReturn;
      }
      else {
        // Caller should have provided the right info directly
        toReturn = serviceId;
      }
      return toReturn;
    },
    /**
     * @private
     */
    buildURL: function(contextInfos, predefinedProcedureURI, args) {
      var toReturn = contextInfos.serverURL+contextInfos.wsVersion+'/'+contextInfos.wsEndPoint+'/'+predefinedProcedureURI+'?tenantId='+contextInfos.tenantId;
      if(args !== undefined) {
        for (var key in args) {
          if(args[key] !== undefined) {
            toReturn += '&'+key+'='+args[key];
          }
        }
      }
      return toReturn;
    },
    /**
     * @private
     */
    getURLParams: function() {
      var qs = window.location.search.substring(1);
      qs = qs.split('+').join(' ');

      var params = {},
        tokens,
        re = /[?&]?([^=]+)=([^&]*)/g;

      while (tokens = re.exec(qs)) {
        params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
      }

      return params;
    },
    /**
     * @private
     */
    getRDFServerUrl: function() {
      var serverURLTmp;
      try {
        if (widget) {
          serverURLTmp = Utils.getQueryString(widget.getUrl(), 'rdfserver');
        }
      } catch (e){

      }
      if (serverURLTmp !== undefined && serverURLTmp !== null) {
        serverURL = serverURLTmp;
      }
      if (serverURL === undefined || serverURL === null) {
        console.log( 'Error: no valid rdfserver url parameter found (found:'+serverURL+'), please add ?rdfserver=<url_of_rdf_server> in the requested url (the url will be cached)');
        serverURL = 'ODTService@http://localhost:9421/3DRDF/';
        console.log('Defaulting to :' + serverURL);
      }
      return serverURL;
    },
    /**
     * @private
     */
    getRequestFunction: function(context) {
      // return WAFData.proxifiedRequest ;
      return WAFData.authenticatedRequest;
    }
  };
  return toolbox;
});
